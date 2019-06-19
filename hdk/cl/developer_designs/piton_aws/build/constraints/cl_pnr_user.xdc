# This contains the CL specific constraints for Top level PNR

create_pblock pblock_CL_top

# DDRA
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddra_axi4_dest_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/gen_ddr_tst[0].*}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_cores.DDR4_0*}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_inst[0].*}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_stat[0].*}]

# Chipset + piton_shell
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/system/chipset}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_mem_bus_cdc}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_uart}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/axi_xbar}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/dma_axi4_reg_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/master_axi4_reg_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddra_axi4_src_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddrb_axi4_src_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddrc_axi4_src_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddrd_axi4_src_slice}]

# Tiles (y = 0)
#add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/system/chip/tile0}]
#add_cells_to_pblock [get_pblocks pblock_CL_top] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/system/chip/tile1}]

# Set-up
resize_pblock [get_pblocks pblock_CL_top] -add {CLOCKREGION_X0Y10:CLOCKREGION_X5Y14}
set_property PARENT pblock_CL [get_pblocks pblock_CL_top]



create_pblock pblock_CL_mid

# DDR B, C
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddrc_axi4_dest_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddrb_axi4_dest_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/gen_ddr_tst[1].*}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_cores.DDR4_1*}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_inst[1].*}]
add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_stat[1].*}]

# Tiles (y = 1)
#add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/system/chip/tile2}]
#add_cells_to_pblock [get_pblocks pblock_CL_mid] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/system/chip/tile3}]

# Set-up
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

# DDR D
add_cells_to_pblock [get_pblocks pblock_CL_bot] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/piton_aws_xbar/ddrd_axi4_dest_slice}]
add_cells_to_pblock [get_pblocks pblock_CL_bot] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/gen_ddr_tst[2].*}]
add_cells_to_pblock [get_pblocks pblock_CL_bot] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_cores.DDR4_2*}]
add_cells_to_pblock [get_pblocks pblock_CL_bot] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_inst[2].*}]
add_cells_to_pblock [get_pblocks pblock_CL_bot] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/piton_aws_mc/sh_ddr/ddr_stat[2].*}]

# Tiles (y = 2)
#add_cells_to_pblock [get_pblocks pblock_CL_bot] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/system/chip/tile4}]
#add_cells_to_pblock [get_pblocks pblock_CL_bot] [get_cells -quiet -hierarchical -filter {NAME =~ WRAPPER_INST/CL/system/chip/tile5}]

# Set-up
resize_pblock [get_pblocks pblock_CL_bot] -add {SLICE_X88Y0:SLICE_X107Y299}
resize_pblock [get_pblocks pblock_CL_bot] -add {DSP48E2_X11Y0:DSP48E2_X13Y119}
resize_pblock [get_pblocks pblock_CL_bot] -add {LAGUNA_X12Y0:LAGUNA_X15Y239}
resize_pblock [get_pblocks pblock_CL_bot] -add {RAMB18_X7Y0:RAMB18_X7Y119}
resize_pblock [get_pblocks pblock_CL_bot] -add {RAMB36_X7Y0:RAMB36_X7Y59}
resize_pblock [get_pblocks pblock_CL_bot] -add {URAM288_X2Y0:URAM288_X2Y79}
resize_pblock [get_pblocks pblock_CL_bot] -add {CLOCKREGION_X0Y0:CLOCKREGION_X2Y4}
set_property SNAPPING_MODE ON [get_pblocks pblock_CL_bot]
set_property PARENT pblock_CL [get_pblocks pblock_CL_bot]
