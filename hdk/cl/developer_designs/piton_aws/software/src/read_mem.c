/*
 * Amazon FPGA Hardware Development Kit
 *
 * Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Amazon Software License (the "License"). You may not use
 * this file except in compliance with the License. A copy of the License is
 * located at
 *
 *    http://aws.amazon.com/asl/
 *
 * or in the "license" file accompanying this file. This file is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
 * implied. See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <poll.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <stdint.h>
#include <assert.h>

#include <fpga_pci.h>
#include <fpga_mgmt.h>
#include <fpga_dma.h>
#include <utils/lcd.h>
#include <utils/sh_dpi_tasks.h>

#include "dma_os.h"

/* use the standard out logger */
static const struct logger *logger = &logger_stdout;
int read_mem(int read_fd, size_t begin, size_t end, size_t buffer_size);

int main(int argc, char **argv) {
    int rc;
    int slot_id = 0;

    /* setup logging to print to stdout */
    rc = log_init("test_dram_dma");
    fail_on(rc, out, "Unable to initialize the log.");
    rc = log_attach(logger, NULL, 0);
    fail_on(rc, out, "%s", "Unable to attach to the log.");

    /* initialize the fpga_plat library */
    rc = fpga_mgmt_init();
    fail_on(rc, out, "Unable to initialize the fpga_mgmt library");

    /* check that the AFI is loaded */
    log_info("Checking to see if the right AFI is loaded...");
    rc = check_slot_config(slot_id);
    fail_on(rc, out, "slot config is not correct");

    /* get fds */
    int read_fd = -1;
    int write_fd = -1;
    rc = get_fds(slot_id, &read_fd, &write_fd);
    fail_on(rc, out, "Couldn't get file descriptors for DMA");

    /* read mem */ 
    rc = read_mem(read_fd, 2*MEM_1GB, 2*MEM_1GB + 32*MEM_1MB, MEM_1MB);
    fail_on(rc, out, "read_mem failed!");

out:
    if (write_fd >= 0) {
        close(write_fd);
    }
    if (read_fd >= 0) {
        close(read_fd);
    }
    
    log_info("Memory initialization %s", (rc == 0) ? "PASSED" : "FAILED");
    return rc;
}


static const uint16_t AMZ_PCI_VENDOR_ID = 0x1D0F; /* Amazon PCI Vendor ID */
static const uint16_t PCI_DEVICE_ID = 0xF001;

uint64_t buffer_compare(uint8_t *bufa, uint8_t *bufb,
    size_t buffer_size)
{
    size_t i;
    uint64_t differ = 0;
    for (i = 0; i < buffer_size; ++i) {
        if (bufa[i] != bufb[i]) {
            differ += 1;
        }
    }

    return differ;
}

int check_slot_config(int slot_id)
{
    int rc;
    struct fpga_mgmt_image_info info = {0};

    /* get local image description, contains status, vendor id, and device id */
    rc = fpga_mgmt_describe_local_image(slot_id, &info, 0);
    fail_on(rc, out, "Unable to get local image information. Are you running "
        "as root?");

    /* check to see if the slot is ready */
    if (info.status != FPGA_STATUS_LOADED) {
        rc = 1;
        fail_on(rc, out, "Slot %d is not ready", slot_id);
    }

    /* confirm that the AFI that we expect is in fact loaded */
    if (info.spec.map[FPGA_APP_PF].vendor_id != AMZ_PCI_VENDOR_ID ||
        info.spec.map[FPGA_APP_PF].device_id != PCI_DEVICE_ID)
    {
        rc = 1;
        char sdk_path_buf[512];
        char *sdk_env_var;
        sdk_env_var = getenv("SDK_DIR");
        snprintf(sdk_path_buf, sizeof(sdk_path_buf), "%s",
            (sdk_env_var != NULL) ? sdk_env_var : "<aws-fpga>");
        log_error(
            "...\n"
            "  The slot appears loaded, but the pci vendor or device ID doesn't match the\n"
            "  expected values. You may need to rescan the fpga with \n"
            "    fpga-describe-local-image -S %i -R\n"
            "  Note that rescanning can change which device file in /dev/ a FPGA will map to.\n",
            slot_id);
        log_error(
            "...\n"
            "  To remove and re-add your xdma driver and reset the device file mappings, run\n"
            "    sudo rmmod xdma && sudo insmod \"%s/sdk/linux_kernel_drivers/xdma/xdma.ko\"\n",
            sdk_path_buf);
        fail_on(rc, out, "The PCI vendor id and device of the loaded image are "
                         "not the expected values.");
    }

    char dbdf[16];
    snprintf(dbdf,
                  sizeof(dbdf),
                  PCI_DEV_FMT,
                  info.spec.map[FPGA_APP_PF].domain,
                  info.spec.map[FPGA_APP_PF].bus,
                  info.spec.map[FPGA_APP_PF].dev,
                  info.spec.map[FPGA_APP_PF].func);
    log_info("Operating on slot %d with id: %s", slot_id, dbdf);

out:
    return rc;
}


void usage(const char* program_name) {
    printf("usage: %s <os_img_file>\n", program_name);
}

int get_fds(int slot_id, int* read_fd, int* write_fd) {
    int rc;
    
    *read_fd = fpga_dma_open_queue(FPGA_DMA_XDMA, slot_id, /*channel*/ 0, /*is_read*/ true);
    fail_on((rc = (read_fd < 0) ? -1 : 0), out, "unable to open read dma queue");

    *write_fd = fpga_dma_open_queue(FPGA_DMA_XDMA, slot_id, /*channel*/ 0, /*is_read*/ false);
    fail_on((rc = (write_fd < 0) ? -1 : 0), out, "unable to open write dma queue");

out:
    /* if there is an error code, exit with status 1 */
    return (rc != 0 ? 1 : 0);
}


/**
 * Write OS into dimm3
 */
int dma_os(int read_fd, int write_fd, const char* os_img_filename, size_t begin) {
    int rc;
    
    FILE* os_img_file = fopen(os_img_filename, "r");
    if (os_img_file == NULL) {
        rc = -ENOENT;
        goto out;
    }

    size_t buffer_size = MEM_1MB;

    uint8_t *write_buffer = calloc(buffer_size, sizeof(uint8_t));
    uint8_t *read_buffer = calloc(buffer_size, sizeof(uint8_t));
    if (write_buffer == NULL || read_buffer == NULL) {
        rc = -ENOMEM;
        goto out;
    }

    size_t pos = begin;
    bool passed = true;
    while(1) {
        size_t bytes_read = fread(write_buffer, 1, buffer_size, os_img_file);

        rc = fpga_dma_burst_write(write_fd, write_buffer, bytes_read, pos);
        fail_on(rc, out, "DMA write failed");

        rc = fpga_dma_burst_read(read_fd, read_buffer, bytes_read, pos);
        fail_on(rc, out, "DMA read failed");

        uint64_t differ = buffer_compare(read_buffer, write_buffer, bytes_read);
    
        if (differ != 0) {
            log_error("OS image write failed with %lu bytes which differ", differ);
            passed = false;
            break;
        }

        if (bytes_read != buffer_size) {
            break;
        }
        pos += bytes_read;
    }

    if (passed) {
        log_info("OS image written!");
    } else { 
        log_info("OS image write failed!");
    }

    
    rc = (passed) ? 0 : 1;

out:
    if (write_buffer != NULL) {
        free(write_buffer);
    }
    if (read_buffer != NULL) {
        free(read_buffer);
    }
    if (os_img_file != NULL) {
        fclose(os_img_file);
    }
    /* if there is an error code, exit with status 1 */
    return (rc != 0 ? 1 : 0);
}


int fill_mem(int read_fd, int write_fd, size_t begin, size_t end, uint8_t byte, size_t buffer_size) {
    int rc = 0;
    
    if ( (end <= begin) || ((end - begin) % buffer_size != 0) ) {
        rc = -1;
    }
    fail_on(rc, out, "Wrong mem filling params");

    uint8_t *write_buffer = calloc(buffer_size, sizeof(uint8_t));
    uint8_t *read_buffer = calloc(buffer_size, sizeof(uint8_t));
    if (write_buffer == NULL || read_buffer == NULL) {
        rc = -ENOMEM;
        goto out;
    }

    memset(read_buffer, byte, buffer_size);
    memset(write_buffer, byte, buffer_size);

    size_t pos = begin;
    bool passed = true;
    while(1) {
        rc = fpga_dma_burst_write(write_fd, write_buffer, buffer_size, pos);
        fail_on(rc, out, "DMA write failed");

        rc = fpga_dma_burst_read(read_fd, read_buffer, buffer_size, pos);
        fail_on(rc, out, "DMA read failed");

        uint64_t differ = buffer_compare(read_buffer, write_buffer, buffer_size);
    
        if (differ != 0) {
            log_error("Filling memory failed with %lu bytes which differ", differ);
            passed = false;
            break;
        }

        pos += buffer_size;
        if (pos >= end) {
            break;
        } 
    }

    if (passed) {
        log_info("Filling memory: success!");
    } else { 
        log_info("Filling memory: failure!");
    }

    rc = (passed) ? 0 : 1;

out:
    if (write_buffer != NULL) {
        free(write_buffer);
    }
    if (read_buffer != NULL) {
        free(read_buffer);
    }
    
    /* if there is an error code, exit with status 1 */
    return (rc != 0 ? 1 : 0);
}

int read_mem(int read_fd, size_t begin, size_t end, size_t buffer_size) {
    int rc = 0;
    
    if ( (end <= begin) || ((end - begin) % buffer_size != 0) ) {
        rc = -1;
    }
    fail_on(rc, out, "Wrong mem filling params");

    uint8_t *read_buffer = calloc(buffer_size, sizeof(uint8_t));
    if (read_buffer == NULL) {
        rc = -ENOMEM;
        goto out;
    }

    memset(read_buffer, 0x00, buffer_size);
    FILE*  file = fopen("memory3.bin", "wb");
    assert(file != NULL);

    size_t pos = begin;
    bool passed = true;
    while(1) {
        rc = fpga_dma_burst_read(read_fd, read_buffer, buffer_size, pos);
        fail_on(rc, out, "DMA read failed");

	for (uint64_t i = 0; i < buffer_size; i++) {
            //printf("%02x", read_buffer[i]);
        }
        //printf("\n");

        fwrite(read_buffer, buffer_size, 1, file); 

        pos += buffer_size;
        if (pos >= end) {
            break;
        } 
    }

    fclose(file);

    if (passed) {
        log_info("Reading memory: success!");
    } else { 
        log_info("Reading memory: failure!");
    }

    rc = (passed) ? 0 : 1;

out:
    if (read_buffer != NULL) {
        free(read_buffer);
    }
    
    /* if there is an error code, exit with status 1 */
    return (rc != 0 ? 1 : 0);
}
