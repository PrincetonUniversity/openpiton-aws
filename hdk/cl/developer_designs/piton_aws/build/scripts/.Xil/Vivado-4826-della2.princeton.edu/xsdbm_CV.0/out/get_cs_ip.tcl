#
#Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
#
set_param power.enableLutRouteBelPower 1
set_param power.enableCarry8RouteBelPower 1
set_param power.enableUnconnectedCarry8PinPower 1
set_param hd.clockRoutingWireReduction 0
set_param power.BramSDPPropagationFix 1
set_param synth.enableIncremental 0
set_param chipscope.flow 0
set part xcvu9p-flgb2104-2-i
set board_part_repo_paths {}
set board_part {}
set board_connections {}
set tool_flow Vivado
set ip_vlnv xilinx.com:ip:xsdbm:3.0
set ip_module_name xsdbm
set params {{{PARAM_VALUE.C_BSCAN_MODE} {false} {PARAM_VALUE.C_BSCAN_MODE_WITH_CORE} {false} {PARAM_VALUE.C_CLK_INPUT_FREQ_HZ} {300000000} {PARAM_VALUE.C_ENABLE_CLK_DIVIDER} {false} {PARAM_VALUE.C_EN_BSCANID_VEC} {false} {PARAM_VALUE.C_NUM_BSCAN_MASTER_PORTS} {0} {PARAM_VALUE.C_TWO_PRIM_MODE} {false} {PARAM_VALUE.C_USER_SCAN_CHAIN} {1} {PARAM_VALUE.C_USE_EXT_BSCAN} {true} {PARAM_VALUE.C_XSDB_NUM_SLAVES} {4}}}
set output_xci /tigress/gchirkov/aws-fpga/hdk/cl/examples/cl_dram_dma/build/scripts/.Xil/Vivado-4826-della2.princeton.edu/xsdbm_CV.0/out/result.xci
set output_dcp /tigress/gchirkov/aws-fpga/hdk/cl/examples/cl_dram_dma/build/scripts/.Xil/Vivado-4826-della2.princeton.edu/xsdbm_CV.0/out/result.dcp
set output_dir /tigress/gchirkov/aws-fpga/hdk/cl/examples/cl_dram_dma/build/scripts/.Xil/Vivado-4826-della2.princeton.edu/xsdbm_CV.0/out
set ip_repo_paths /tigress/gchirkov/aws-fpga/hdk/common/shell_v04261818/design/cache/ddr4_phy
set ip_output_repo ./.cache/ip
set ip_cache_permissions {read write}

set oopbus_ip_repo_paths [get_param chipscope.oopbus_ip_repo_paths]

set synth_opts {}
set xdc_files {}
