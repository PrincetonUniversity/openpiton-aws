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

set HDK_SHELL_DIR $::env(HDK_SHELL_DIR)
set HDK_SHELL_DESIGN_DIR $::env(HDK_SHELL_DESIGN_DIR)
set CL_DIR $::env(CL_DIR)
set ORIGINAL_CL_DIR $::env(ORIGINAL_CL_DIR)

set UNUSED_TEMPLATES_DIR $HDK_SHELL_DESIGN_DIR/interfaces

#---- Developr would replace this section with design files ----

## Change file names and paths below to reflect your CL area.  DO NOT include AWS RTL files.
set DV_ROOT $::env(DV_ROOT)
source $DV_ROOT/tools/src/proto/vivado/setup.tcl

set PITON_AWS_RTL_IMPL_FILES [list \
    "${ORIGINAL_CL_DIR}/design/axi_bus.sv" \
    "${ORIGINAL_CL_DIR}/design/piton_aws.sv" \
    "${ORIGINAL_CL_DIR}/design/piton_aws_uart.v" \
    "${ORIGINAL_CL_DIR}/design/piton_aws_eth.sv" \
    "${ORIGINAL_CL_DIR}/design/piton_aws_xbar.sv" \
    "${ORIGINAL_CL_DIR}/design/piton_aws_addr_translator.sv" 
]

set PITON_AWS_INCLUDE_DIRS [list \
    "${UNUSED_TEMPLATES_DIR}" \
    "${ORIGINAL_CL_DIR}/design"

]

set PITON_AWS_XCI_IP_FILES [list \
#  "${ORIGINAL_CL_DIR}/design/xilinx/ip_cores/ila_read/ila_read.xci" \
  "${ORIGINAL_CL_DIR}/design/xilinx/ip_cores/ila_write/ila_write.xci" \
  "${ORIGINAL_CL_DIR}/design/xilinx/ip_cores/ila_buffer/ila_buffer.xci" \
  "${ORIGINAL_CL_DIR}/design/xilinx/ip_cores/axi_protocol_checker_0/axi_protocol_checker_0.xci" \
  "${ORIGINAL_CL_DIR}/design/xilinx/ip_cores/ila_axi_protocol_checker/ila_axi_protocol_checker.xci" 
]

#---- End of section replaced by Developr ---

set TOOL_VERSION $::env(VIVADO_TOOL_VERSION)
set vivado_version [string range [version -short] 0 5]
puts "AWS FPGA: VIVADO_TOOL_VERSION $TOOL_VERSION"
puts "vivado_version $vivado_version"
