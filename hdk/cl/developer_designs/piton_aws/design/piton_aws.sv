// Copyright (c) 2019 Princeton University
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of Princeton University nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY PRINCETON UNIVERSITY "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL PRINCETON UNIVERSITY BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// Filename: aws_system.v
// Author: gchirkov
// Description: Wrapper over system.v for aws


`include "define.tmp.h"
`include "piton_system.vh"

// The way Macros should be defined: 
// define PITON_FPGA_SYNTH
// define PITON_NO_JTAG
// define PITON_FPGA_MC_DDR3
// undef PITONSYS_NO_MC
// undef VC707_BOARD GENESYS2_BOARD WHATEVER_BOARD
// define F1_BOARD
// undef PITONSYS_SPI
// define PITONSYS_UART
// undef PITON_CHIPSET_DIFF_CLK
// undef PITON_CLKS_SIM
// undef PITON_CHIPSET_CLKS_GEN
// undef PITON_PASSTHRU_CLKS_GEN
// define PITON_CLKS_CHIPSET
// undef PITONSYS_INC_PASSTHRU
// undef PITON_CLKS_PASSTHRU



//  PITON_NO_CHIP_BRIDGE        This indicates no chip bridge should be used on
//                              off chip link.  The 3 NoCs are exposed as credit
//                              based interfaces directly.  This is mainly used for FPGA
//                              where there are no pin constraints. Cannot be used with
//                              PITONSYS_INC_PASSTHRU. Note that if PITON_NO_CHIP_BRIDGE
//                              is set, io_clk is not really used.



module piton_aws
(
	`include "cl_ports.vh"
);

`include "cl_id_defines.vh"          // Defines for ID0 and ID1 (PCI ID's)
`include "piton_aws_defines.vh"

// TIE OFF ALL UNUSED INTERFACES
// Including all the unused interface to tie off

`include "unused_sh_bar1_template.inc"
`include "unused_apppf_irq_template.inc"
`include "unused_cl_sda_template.inc"
`include "unused_pcim_template.inc"
`include "unused_flr_template.inc"

// Unused 'full' signals
assign cl_sh_dma_rd_full  = 1'b0;
assign cl_sh_dma_wr_full  = 1'b0;

// Unused
assign cl_sh_status0 = 32'h0;
assign cl_sh_status1 = 32'h0;

// Hardcoded vals from Amazon
assign cl_sh_id0 = `CL_SH_ID0;
assign cl_sh_id1 = `CL_SH_ID1;



///////////////////////////////////////////////////////////////////////
////////////////////// clocks and resets //////////////////////////////
///////////////////////////////////////////////////////////////////////

logic clk;
(* dont_touch = "true" *) logic pipe_rst_n;
logic pre_sync_rst_n;
(* dont_touch = "true" *) logic sync_rst_n;

assign clk = clk_main_a0;

lib_pipe #(.WIDTH(1), .STAGES(4)) PIPE_RST_N (.clk(clk), .rst_n(1'b1), .in_bus(rst_main_n), .out_bus(pipe_rst_n));

always_ff @(negedge pipe_rst_n or posedge clk)
   if (!pipe_rst_n)
   begin
      pre_sync_rst_n <= 0;
      sync_rst_n <= 0;
   end
   else
   begin
      pre_sync_rst_n <= 1;
      sync_rst_n <= pre_sync_rst_n;
   end

///////////////////////////////////////////////////////////////////////
////////////////////// clocks and resets //////////////////////////////
///////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////
/////////////////////////// piton /////////////////////////////////////
///////////////////////////////////////////////////////////////////////

    // For uart
    logic piton_tx;
    logic piton_rx;

    // for ddr
    axi_bus_t piton_mem_bus();
    logic ddr_ready;

    (* dont_touch = "true" *) logic sys_sync_rst_n;
    lib_pipe #(.WIDTH(1), .STAGES(4)) sys_slc_rst_n (.clk(clk), .rst_n(1'b1), .in_bus(sync_rst_n), .out_bus(sys_sync_rst_n));

    system system(
        // Clocks and resets
        .clk(clk),
        .sys_rst_n(sys_sync_rst_n),

    `ifdef PITON_ARIANE
    	.tck_i(1'b0),
    	.tms_i(1'b0),
    	.trst_ni(1'b0),
    	.td_i(1'b0),
    	.td_o(),
    `endif

        .m_axi_awid(piton_mem_bus.awid),
        .m_axi_awaddr(piton_mem_bus.awaddr),
        .m_axi_awlen(piton_mem_bus.awlen),
        .m_axi_awsize(piton_mem_bus.awsize),
        .m_axi_awburst(piton_mem_bus.awburst),
        .m_axi_awlock(piton_mem_bus.awlock),
        .m_axi_awcache(piton_mem_bus.awcache),
        .m_axi_awprot(piton_mem_bus.awprot),
        .m_axi_awqos(piton_mem_bus.awqos),
        .m_axi_awregion(piton_mem_bus.awregion),
        .m_axi_awuser(piton_mem_bus.awuser),
        .m_axi_awvalid(piton_mem_bus.awvalid),
        .m_axi_awready(piton_mem_bus.awready),

        // AXI Write Data Channel Signals
        .m_axi_wid(piton_mem_bus.wid),
        .m_axi_wdata(piton_mem_bus.wdata),
        .m_axi_wstrb(piton_mem_bus.wstrb),
        .m_axi_wlast(piton_mem_bus.wlast),
        .m_axi_wuser(piton_mem_bus.wuser),
        .m_axi_wvalid(piton_mem_bus.wvalid),
        .m_axi_wready(piton_mem_bus.wready),

        // AXI Read Address Channel Signals
        .m_axi_arid(piton_mem_bus.arid),
        .m_axi_araddr(piton_mem_bus.araddr),
        .m_axi_arlen(piton_mem_bus.arlen),
        .m_axi_arsize(piton_mem_bus.arsize),
        .m_axi_arburst(piton_mem_bus.arburst),
        .m_axi_arlock(piton_mem_bus.arlock),
        .m_axi_arcache(piton_mem_bus.arcache),
        .m_axi_arprot(piton_mem_bus.arprot),
        .m_axi_arqos(piton_mem_bus.arqos),
        .m_axi_arregion(piton_mem_bus.arregion),
        .m_axi_aruser(piton_mem_bus.aruser),
        .m_axi_arvalid(piton_mem_bus.arvalid),
        .m_axi_arready(piton_mem_bus.arready),

        // AXI Read Data Channel Signals
        .m_axi_rid(piton_mem_bus.rid),
        .m_axi_rdata(piton_mem_bus.rdata),
        .m_axi_rresp(piton_mem_bus.rresp),
        .m_axi_rlast(piton_mem_bus.rlast),
        .m_axi_ruser(piton_mem_bus.ruser),
        .m_axi_rvalid(piton_mem_bus.rvalid),
        .m_axi_rready(piton_mem_bus.rready),

        // AXI Write Response Channel Signals
        .m_axi_bid(piton_mem_bus.bid),
        .m_axi_bresp(piton_mem_bus.bresp),
        .m_axi_buser(piton_mem_bus.buser),
        .m_axi_bvalid(piton_mem_bus.bvalid),
        .m_axi_bready(piton_mem_bus.bready),

        .ddr_ready(ddr_ready),

        .uart_tx(piton_tx),
        .uart_rx(piton_rx),

        .sw({8'b0, sh_cl_status_vdip[7:0]}), 
        .leds(cl_sh_status_vled[7:0]) 

    );

///////////////////////////////////////////////////////////////////////
/////////////////////////// piton /////////////////////////////////////
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
/////////////////////////// mem subsystem /////////////////////////////
///////////////////////////////////////////////////////////////////////

    (* dont_touch = "true" *) logic piton_aws_mc_sync_rst_n;
    lib_pipe #(.WIDTH(1), .STAGES(4)) piton_aws_mc_slc_rst_n (.clk(clk), .rst_n(1'b1), .in_bus(sync_rst_n), .out_bus(piton_aws_mc_sync_rst_n));
    piton_aws_mc piton_aws_mc(
        .clk                   (clk),
        .rst_n                 (piton_aws_mc_sync_rst_n),

        .piton_mem_bus         (piton_mem_bus),

        .sh_cl_dma_pcis_awid   (sh_cl_dma_pcis_awid),
        .sh_cl_dma_pcis_awaddr (sh_cl_dma_pcis_awaddr),
        .sh_cl_dma_pcis_awlen  (sh_cl_dma_pcis_awlen),
        .sh_cl_dma_pcis_awsize (sh_cl_dma_pcis_awsize),
        .sh_cl_dma_pcis_awvalid(sh_cl_dma_pcis_awvalid),
        .cl_sh_dma_pcis_awready(cl_sh_dma_pcis_awready),
        .sh_cl_dma_pcis_wdata  (sh_cl_dma_pcis_wdata),
        .sh_cl_dma_pcis_wstrb  (sh_cl_dma_pcis_wstrb),
        .sh_cl_dma_pcis_wlast  (sh_cl_dma_pcis_wlast),
        .sh_cl_dma_pcis_wvalid (sh_cl_dma_pcis_wvalid),
        .cl_sh_dma_pcis_wready (cl_sh_dma_pcis_wready),
        .cl_sh_dma_pcis_bid    (cl_sh_dma_pcis_bid),
        .cl_sh_dma_pcis_bresp  (cl_sh_dma_pcis_bresp),
        .cl_sh_dma_pcis_bvalid (cl_sh_dma_pcis_bvalid),
        .sh_cl_dma_pcis_bready (sh_cl_dma_pcis_bready),
        .sh_cl_dma_pcis_arid   (sh_cl_dma_pcis_arid),
        .sh_cl_dma_pcis_araddr (sh_cl_dma_pcis_araddr),
        .sh_cl_dma_pcis_arlen  (sh_cl_dma_pcis_arlen),
        .sh_cl_dma_pcis_arsize (sh_cl_dma_pcis_arsize),
        .sh_cl_dma_pcis_arvalid(sh_cl_dma_pcis_arvalid),
        .cl_sh_dma_pcis_arready(cl_sh_dma_pcis_arready),
        .cl_sh_dma_pcis_rid    (cl_sh_dma_pcis_rid),
        .cl_sh_dma_pcis_rdata  (cl_sh_dma_pcis_rdata),
        .cl_sh_dma_pcis_rresp  (cl_sh_dma_pcis_rresp),
        .cl_sh_dma_pcis_rlast  (cl_sh_dma_pcis_rlast),
        .cl_sh_dma_pcis_rvalid (cl_sh_dma_pcis_rvalid),

        .cl_sh_ddr_awid        (cl_sh_ddr_awid),
        .cl_sh_ddr_awaddr      (cl_sh_ddr_awaddr),
        .cl_sh_ddr_awlen       (cl_sh_ddr_awlen),
        .cl_sh_ddr_awsize      (cl_sh_ddr_awsize),
        .cl_sh_ddr_awburst     (cl_sh_ddr_awburst),
        .cl_sh_ddr_awvalid     (cl_sh_ddr_awvalid),
        .sh_cl_ddr_awready     (sh_cl_ddr_awready),
        .cl_sh_ddr_wid         (cl_sh_ddr_wid),
        .cl_sh_ddr_wdata       (cl_sh_ddr_wdata),
        .cl_sh_ddr_wstrb       (cl_sh_ddr_wstrb),
        .cl_sh_ddr_wlast       (cl_sh_ddr_wlast),
        .cl_sh_ddr_wvalid      (cl_sh_ddr_wvalid),
        .sh_cl_ddr_wready      (sh_cl_ddr_wready),
        .sh_cl_ddr_bid         (sh_cl_ddr_bid),
        .sh_cl_ddr_bresp       (sh_cl_ddr_bresp),
        .sh_cl_ddr_bvalid      (sh_cl_ddr_bvalid),
        .cl_sh_ddr_bready      (cl_sh_ddr_bready),
        .cl_sh_ddr_arid        (cl_sh_ddr_arid),
        .cl_sh_ddr_araddr      (cl_sh_ddr_araddr),
        .cl_sh_ddr_arlen       (cl_sh_ddr_arlen),
        .cl_sh_ddr_arsize      (cl_sh_ddr_arsize),
        .cl_sh_ddr_arburst     (cl_sh_ddr_arburst),
        .cl_sh_ddr_arvalid     (cl_sh_ddr_arvalid),
        .sh_cl_ddr_arready     (sh_cl_ddr_arready),
        .sh_cl_ddr_rid         (sh_cl_ddr_rid),
        .sh_cl_ddr_rdata       (sh_cl_ddr_rdata),
        .sh_cl_ddr_rresp       (sh_cl_ddr_rresp),
        .sh_cl_ddr_rlast       (sh_cl_ddr_rlast),
        .sh_cl_ddr_rvalid      (sh_cl_ddr_rvalid),
        .cl_sh_ddr_rready      (cl_sh_ddr_rready),

        .CLK_300M_DIMM0_DP     (CLK_300M_DIMM0_DP),
        .CLK_300M_DIMM0_DN     (CLK_300M_DIMM0_DN),
        .M_A_ACT_N             (M_A_ACT_N),
        .M_A_MA                (M_A_MA),
        .M_A_BA                (M_A_BA),
        .M_A_BG                (M_A_BG),
        .M_A_CKE               (M_A_CKE),
        .M_A_ODT               (M_A_ODT),
        .M_A_CS_N              (M_A_CS_N),
        .M_A_CLK_DN            (M_A_CLK_DN),
        .M_A_CLK_DP            (M_A_CLK_DP),
        .M_A_PAR               (M_A_PAR),
        .M_A_DQ                (M_A_DQ),
        .M_A_ECC               (M_A_ECC),
        .M_A_DQS_DP            (M_A_DQS_DP),
        .M_A_DQS_DN            (M_A_DQS_DN),
        .cl_RST_DIMM_A_N       (cl_RST_DIMM_A_N),

        .CLK_300M_DIMM1_DP     (CLK_300M_DIMM1_DP),
        .CLK_300M_DIMM1_DN     (CLK_300M_DIMM1_DN),
        .M_B_ACT_N             (M_B_ACT_N),
        .M_B_MA                (M_B_MA),
        .M_B_BA                (M_B_BA),
        .M_B_BG                (M_B_BG),
        .M_B_CKE               (M_B_CKE),
        .M_B_ODT               (M_B_ODT),
        .M_B_CS_N              (M_B_CS_N),
        .M_B_CLK_DN            (M_B_CLK_DN),
        .M_B_CLK_DP            (M_B_CLK_DP),
        .M_B_PAR               (M_B_PAR),
        .M_B_DQ                (M_B_DQ),
        .M_B_ECC               (M_B_ECC),
        .M_B_DQS_DP            (M_B_DQS_DP),
        .M_B_DQS_DN            (M_B_DQS_DN),
        .cl_RST_DIMM_B_N       (cl_RST_DIMM_B_N),

        .CLK_300M_DIMM3_DP     (CLK_300M_DIMM3_DP),
        .CLK_300M_DIMM3_DN     (CLK_300M_DIMM3_DN),
        .M_D_ACT_N             (M_D_ACT_N),
        .M_D_MA                (M_D_MA),
        .M_D_BA                (M_D_BA),
        .M_D_BG                (M_D_BG),
        .M_D_CKE               (M_D_CKE),
        .M_D_ODT               (M_D_ODT),
        .M_D_CS_N              (M_D_CS_N),
        .M_D_CLK_DN            (M_D_CLK_DN),
        .M_D_CLK_DP            (M_D_CLK_DP),
        .M_D_PAR               (M_D_PAR),
        .M_D_DQ                (M_D_DQ),
        .M_D_ECC               (M_D_ECC),
        .M_D_DQS_DP            (M_D_DQS_DP),
        .M_D_DQS_DN            (M_D_DQS_DN),
        .cl_RST_DIMM_D_N       (cl_RST_DIMM_D_N),

        .sh_ddr_stat_addr0     (sh_ddr_stat_addr0),
        .sh_ddr_stat_wr0       (sh_ddr_stat_wr0),
        .sh_ddr_stat_rd0       (sh_ddr_stat_rd0),
        .sh_ddr_stat_wdata0    (sh_ddr_stat_wdata0),
        .ddr_sh_stat_ack0      (ddr_sh_stat_ack0),
        .ddr_sh_stat_rdata0    (ddr_sh_stat_rdata0),
        .ddr_sh_stat_int0      (ddr_sh_stat_int0),

        .sh_ddr_stat_addr1     (sh_ddr_stat_addr1),
        .sh_ddr_stat_wr1       (sh_ddr_stat_wr1),
        .sh_ddr_stat_rd1       (sh_ddr_stat_rd1),
        .sh_ddr_stat_wdata1    (sh_ddr_stat_wdata1),
        .ddr_sh_stat_ack1      (ddr_sh_stat_ack1),
        .ddr_sh_stat_rdata1    (ddr_sh_stat_rdata1),
        .ddr_sh_stat_int1      (ddr_sh_stat_int1),

        .sh_ddr_stat_addr2     (sh_ddr_stat_addr2),
        .sh_ddr_stat_wr2       (sh_ddr_stat_wr2),
        .sh_ddr_stat_rd2       (sh_ddr_stat_rd2),
        .sh_ddr_stat_wdata2    (sh_ddr_stat_wdata2),
        .ddr_sh_stat_ack2      (ddr_sh_stat_ack2),
        .ddr_sh_stat_rdata2    (ddr_sh_stat_rdata2),
        .ddr_sh_stat_int2      (ddr_sh_stat_int2), 

        .ddr_ready(ddr_ready)

    );


///////////////////////////////////////////////////////////////////////
/////////////////////////// mem subsystem//////////////////////////////
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
///////////////// aws uart module /////////////////////////////////////
///////////////////////////////////////////////////////////////////////

    logic shell_tx;
    logic shell_rx;

    assign shell_rx = piton_tx;
    assign piton_rx = shell_tx;

    (* dont_touch = "true" *) logic aws_uart_sync_rst_n;
    lib_pipe #(.WIDTH(1), .STAGES(4)) aws_uart_slc_rst_n (.clk(clk), .rst_n(1'b1), .in_bus(sync_rst_n), .out_bus(aws_uart_sync_rst_n));
    piton_aws_uart piton_aws_uart (

        .clk(clk),
        .sync_rst_n(aws_uart_sync_rst_n),

        // AXILite slave interface

        //Write address
        .s_awvalid(sh_ocl_awvalid),
        .s_awaddr(sh_ocl_awaddr),
        .s_awready(ocl_sh_awready),
                                                                                                                                   
        //Write data                                                                                                                
        .s_wvalid(sh_ocl_wvalid),
        .s_wdata(sh_ocl_wdata),
        .s_wstrb(sh_ocl_wstrb),
        .s_wready(ocl_sh_wready),
                                                                                                                                   
        //Write response                                                                                                            
        .s_bvalid(ocl_sh_bvalid),
        .s_bresp(ocl_sh_bresp),
        .s_bready(sh_ocl_bready),
                                                                                                                                   
        //Read address                                                                                                              
        .s_arvalid(sh_ocl_arvalid),
        .s_araddr(sh_ocl_araddr),
        .s_arready(ocl_sh_arready),
                                                                                                                                   
        //Read data/response                                                                                                        
        .s_rvalid(ocl_sh_rvalid),
        .s_rdata(ocl_sh_rdata),
        .s_rresp(ocl_sh_rresp),
        .s_rready(sh_ocl_rready),


        // UART interface
        .rx          (shell_rx),
        .tx          (shell_tx)
    );

///////////////////////////////////////////////////////////////////////
///////////////// aws uart module /////////////////////////////////////
///////////////////////////////////////////////////////////////////////

endmodule // aws_shell
