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

#include <stdint.h>
#include <sys/types.h>

uint64_t buffer_compare(uint8_t *bufa, uint8_t *bufb,
    size_t buffer_size);

int check_slot_config(int slot_id);
void usage(const char* program_name);
int get_fds(int slot_id, int* read_fd, int* write_fd);
int dma_os(int read_df, int write_fd, const char* os_img_filename, size_t begin);
int fill_mem(int read_fd, int write_fd, size_t begin, size_t end, uint8_t byte, size_t buffer_size);
int fill_ariane_mem_region(int read_fd, int write_fd);

#define MEM_1MB              (1ULL << 20)
#define MEM_1GB              (1ULL << 30)
#define	MEM_16GB              (1ULL << 34)
#define OS_OFFSET            (2 * MEM_16GB)
