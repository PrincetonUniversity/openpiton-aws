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

#include "fpga_pci.h"
#include "fpga_mgmt.h"
#include "fpga_dma.h"
#include "utils/lcd.h"

#include "common.h"

#define	MEM_16G              (1ULL << 34)
#define OS_OFFSET            (3 * MEM_16G)
#define MEM_1MB              (1ULL << 20)
#define BUFFER_SIZE          (MEM_1MB)

/* use the standard out logger */
static const struct logger *logger = &logger_stdout;

void usage(const char* program_name);
int dma_os(int slot_id, const char* os_img_filename);

int main(int argc, char **argv) {
    int rc;
    int slot_id = 0;
    char os_img_filename[1024] = {0};

    switch (argc) {
    case 2:
        sscanf(argv[1], "%s", os_img_filename);
        break;
    default:
        usage(argv[0]);
        return 1;
    }

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

    /* load os */
    rc = dma_os(slot_id, os_img_filename);
    fail_on(rc, out, "DMA example failed");

out:
    log_info("TEST %s", (rc == 0) ? "PASSED" : "FAILED");
    return rc;
}

void usage(const char* program_name) {
    printf("usage: %s <os_img_file>\n", program_name);
}

/**
 * Write OS into dimm3, zero first MB of dimm0
 */
int dma_os(int slot_id, const char* os_img_filename) {
    int rc;
    
    FILE* os_img_file = fopen(os_img_filename, "r");
    if (os_img_file == NULL) {
        rc = -ENOENT;
        goto out;
    }

    size_t buffer_size = BUFFER_SIZE;

    int write_fd = -1;
    int read_fd = -1;

    uint8_t *write_buffer = malloc(buffer_size);
    uint8_t *read_buffer = malloc(buffer_size);
    if (write_buffer == NULL || read_buffer == NULL) {
        rc = -ENOMEM;
        goto out;
    }

    read_fd = fpga_dma_open_queue(FPGA_DMA_XDMA, slot_id, /*channel*/ 0, /*is_read*/ true);
    fail_on((rc = (read_fd < 0) ? -1 : 0), out, "unable to open read dma queue");

    write_fd = fpga_dma_open_queue(FPGA_DMA_XDMA, slot_id, /*channel*/ 0, /*is_read*/ false);
    fail_on((rc = (write_fd < 0) ? -1 : 0), out, "unable to open write dma queue");

    size_t pos = OS_OFFSET;
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

    // Clear first MB of memory
    if (passed) {
        uint8_t zeroes[MEM_1MB] = {0};
        rc = fpga_dma_burst_write(write_fd, zeroes, MEM_1MB , 0);
        fail_on(rc, out, "DMA write failed");

        rc = fpga_dma_burst_read(read_fd, read_buffer, MEM_1MB, 0);
        fail_on(rc, out, "DMA read failed");

        uint64_t differ = buffer_compare(read_buffer, zeroes, MEM_1MB);
    
        if (differ != 0) {
            log_error("OS image write failed with %lu bytes which differ", differ);
            passed = false;
        }
    	if (passed) {
            log_info("First MB zeroed!");
        } else { 
            log_info("Zeroing failed!");
        }
    }
    
    rc = (passed) ? 0 : 1;

out:
    if (write_buffer != NULL) {
        free(write_buffer);
    }
    if (read_buffer != NULL) {
        free(read_buffer);
    }
    if (write_fd >= 0) {
        close(write_fd);
    }
    if (read_fd >= 0) {
        close(read_fd);
    }
    if (os_img_file != NULL) {
        fclose(os_img_file);
    }
    /* if there is an error code, exit with status 1 */
    return (rc != 0 ? 1 : 0);
}

