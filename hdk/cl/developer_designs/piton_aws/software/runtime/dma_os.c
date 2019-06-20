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

#define MEM_1MB              (1ULL << 20)
#define MEM_1GB              (1ULL << 30)
#define	MEM_16GB              (1ULL << 34)
#define OS_OFFSET            (2 * MEM_16GB)

/* use the standard out logger */
static const struct logger *logger = &logger_stdout;

void usage(const char* program_name);
int get_fds(int slot_id, int* read_fd, int* write_fd);
int dma_os(int read_df, int write_fd, const char* os_img_filename, size_t begin);
int clear_mem(int read_fd, int write_fd, size_t begin, size_t end);

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

    /* get fds */
    int read_fd = -1;
    int write_fd = -1;
    rc = get_fds(slot_id, &read_fd, &write_fd);
    fail_on(rc, out, "Couldn't get file descriptors for DMA");

    /* clear first MB of memory */
    rc = clear_mem(read_fd, write_fd, (uint64_t) 0, 4 * MEM_1GB); 
    fail_on(rc, out, "Clearing memory failed!");

    /* load os */
    rc = dma_os(read_fd, write_fd, os_img_filename, OS_OFFSET);
    fail_on(rc, out, "OS DMA failed!");

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


int clear_mem(int read_fd, int write_fd, size_t begin, size_t end) {
    int rc = 0;;
    size_t buffer_size = MEM_1GB;
    
    if ( (end <= begin) || ((end - begin) % buffer_size != 0) ) {
        rc = -1;
    }
    fail_on(rc, out, "Wrong mem clearing params");

    uint8_t *write_buffer = calloc(buffer_size, sizeof(uint8_t));
    uint8_t *read_buffer = calloc(buffer_size, sizeof(uint8_t));
    if (write_buffer == NULL || read_buffer == NULL) {
        rc = -ENOMEM;
        goto out;
    }

    size_t pos = begin;
    bool passed = true;
    while(1) {
        rc = fpga_dma_burst_write(write_fd, write_buffer, buffer_size, pos);
        fail_on(rc, out, "DMA write failed");

        rc = fpga_dma_burst_read(read_fd, read_buffer, buffer_size, pos);
        fail_on(rc, out, "DMA read failed");

        uint64_t differ = buffer_compare(read_buffer, write_buffer, buffer_size);
    
        if (differ != 0) {
            log_error("Clearing memory failed with %lu bytes which differ", differ);
            passed = false;
            break;
        }

        pos += buffer_size;
        if (pos >= end) {
            break;
        } 
    }

    if (passed) {
        log_info("Clearing memory: success!");
    } else { 
        log_info("Clearing memory: failure!");
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
