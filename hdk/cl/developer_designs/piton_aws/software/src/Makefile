# Amazon FPGA Hardware Development Kit
#
# Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use
# this file except in compliance with the License. A copy of the License is
# located at
#
#    http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
# implied. See the License for the specific language governing permissions and
# limitations under the License.

INCLUDES = -I$(SDK_DIR)/userspace/include -I$(CL_DIR)/software/include

CC = gcc
CFLAGS = -D_GNU_SOURCE -D_XOPEN_SOURCE -DCONFIG_LOGLEVEL=4 -std=gnu11 -g -Wall -Werror $(INCLUDES)

LDLIBS = -lfpga_mgmt -lpthread -lbsd -lutil 

SRC =  dma_os.c uart2.c read_mem.c uart.c
OBJ = $(SRC:.c=.o)


all: uart uart2 dma_os check_env read_mem $(BIN)

dma_os: $(OBJ) ../include/dma_os.h
	$(CC) $(CFLAGS) -o dma_os dma_os.o  $(LDFLAGS) $(LDLIBS)

read_mem: $(OBJ) ../include/dma_os.h
	$(CC) $(CFLAGS) -o read_mem read_mem.o  $(LDFLAGS) $(LDLIBS)

uart: $(OBJ) ../include/uart.h
	$(CC) $(CFLAGS) -o uart uart.o $(LDFLAGS) $(LDLIBS) 

uart2: $(OBJ) ../include/uart.h
	$(CC) $(CFLAGS) -o uart2 uart2.o $(LDFLAGS) $(LDLIBS) 

clean:
	rm -f *.o dma_os uart uart2 read_mem

check_env:
ifndef SDK_DIR
    $(error SDK_DIR is undefined. Try "source sdk_setup.sh" to set the software environment)
endif
