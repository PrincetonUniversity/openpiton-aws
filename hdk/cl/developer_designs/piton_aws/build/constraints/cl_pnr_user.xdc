# This contains the CL specific constraints for Top level PNR

create_pblock pblock_CL_top

add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddra_axi4_dest_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/gen_ddr_tst[0].*}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_cores.DDR4_0*}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_inst[0].*}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_stat[0].*}]
resize_pblock [get_pblocks pblock_CL_top] -add {CLOCKREGION_X0Y10:CLOCKREGION_X5Y14}

set_property PARENT pblock_CL [get_pblocks pblock_CL_top]



create_pblock pblock_CL_mid

add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/system}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_mem_bus_cdc}]

add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/axi_xbar}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/dma_axi4_reg_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/master_axi4_reg_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddra_axi4_src_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddrb_axi4_src_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddrc_axi4_src_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddrd_axi4_src_slice}]

add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddrc_axi4_dest_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddrb_axi4_dest_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/gen_ddr_tst[1].*}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_cores.DDR4_1*}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_inst[1].*}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_stat[1].*}]

#resize_pblock [get_pblocks pblock_CL_mid] -add {CLOCKREGION_X0Y5:CLOCKREGION_X3Y9}
resize_pblock [get_pblocks pblock_CL_mid] -add {SLICE_X88Y300:SLICE_X107Y599}
resize_pblock [get_pblocks pblock_CL_mid] -add {DSP48E2_X11Y120:DSP48E2_X13Y239}
resize_pblock [get_pblocks pblock_CL_mid] -add {LAGUNA_X12Y240:LAGUNA_X15Y479}
resize_pblock [get_pblocks pblock_CL_mid] -add {RAMB18_X7Y120:RAMB18_X7Y239}
resize_pblock [get_pblocks pblock_CL_mid] -add {RAMB36_X7Y60:RAMB36_X7Y119}
resize_pblock [get_pblocks pblock_CL_mid] -add {URAM288_X2Y80:URAM288_X2Y159}
resize_pblock [get_pblocks pblock_CL_mid] -add {CLOCKREGION_X0Y5:CLOCKREGION_X2Y9}
set_property SNAPPING_MODE ON [get_pblocks pblock_CL_mid]

set_property PARENT pblock_CL [get_pblocks pblock_CL_mid]



create_pblock pblock_CL_bot

add_cells_to_pblock [get_pblocks pblock_CL_bot] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_uart}]

add_cells_to_pblock [get_pblocks pblock_CL_bot] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddrd_axi4_dest_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_bot] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/gen_ddr_tst[2].*}]
add_cells_to_pblock [get_pblocks pblock_CL_bot] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_cores.DDR4_2*}]
add_cells_to_pblock [get_pblocks pblock_CL_bot] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_inst[2].*}]
add_cells_to_pblock [get_pblocks pblock_CL_bot] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_stat[2].*}]

#resize_pblock [get_pblocks pblock_CL_bot] -add {CLOCKREGION_X0Y0:CLOCKREGION_X3Y4}
resize_pblock [get_pblocks pblock_CL_bot] -add {SLICE_X88Y0:SLICE_X107Y299}
resize_pblock [get_pblocks pblock_CL_bot] -add {DSP48E2_X11Y0:DSP48E2_X13Y119}
resize_pblock [get_pblocks pblock_CL_bot] -add {LAGUNA_X12Y0:LAGUNA_X15Y239}
resize_pblock [get_pblocks pblock_CL_bot] -add {RAMB18_X7Y0:RAMB18_X7Y119}
resize_pblock [get_pblocks pblock_CL_bot] -add {RAMB36_X7Y0:RAMB36_X7Y59}
resize_pblock [get_pblocks pblock_CL_bot] -add {URAM288_X2Y0:URAM288_X2Y79}
resize_pblock [get_pblocks pblock_CL_bot] -add {CLOCKREGION_X0Y0:CLOCKREGION_X2Y4}
set_property SNAPPING_MODE ON [get_pblocks pblock_CL_bot]

set_property PARENT pblock_CL [get_pblocks pblock_CL_bot]

#set_clock_groups -name TIG_SRAI_1 -asynchronous -group [get_clocks -of_objects [get_pins static_sh/SH_DEBUG_BRIDGE/inst/bsip/inst/USE_SOFTBSCAN.U_TAP_TCKBUFG/O]] -group [get_clocks -of_objects [get_pins WRAPPER_INST/SH/kernel_clks_i/clkwiz_sys_clk/inst/CLK_CORE_DRP_I/clk_inst/mmcme3_adv_inst/CLKOUT0]]
#set_clock_groups -name TIG_SRAI_2 -asynchronous -group [get_clocks -of_objects [get_pins static_sh/SH_DEBUG_BRIDGE/inst/bsip/inst/USE_SOFTBSCAN.U_TAP_TCKBUFG/O]] -group [get_clocks drck]
#set_clock_groups -name TIG_SRAI_3 -asynchronous -group [get_clocks -of_objects [get_pins static_sh/SH_DEBUG_BRIDGE/inst/bsip/inst/USE_SOFTBSCAN.U_TAP_TCKBUFG/O]] -group [get_clocks -of_objects [get_pins static_sh/pcie_inst/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]

