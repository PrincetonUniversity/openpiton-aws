// ========== Copyright Header Begin ============================================
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
// ========== Copyright Header End ============================================

module piton_aws_mc (
        input                           clk,
        input                           rst_n,

    //-----------------------------------------
    // interface from piton
    //-----------------------------------------

        axi_bus_t.master mem_bus,

    //-----------------------------------------
    // sh_cl_dma_pcis interface from shell for dma accesses
    //-----------------------------------------

        input[5:0] sh_cl_dma_pcis_awid,
        input[63:0] sh_cl_dma_pcis_awaddr,
        input[7:0] sh_cl_dma_pcis_awlen,
        input[2:0] sh_cl_dma_pcis_awsize,
        input sh_cl_dma_pcis_awvalid,
        output logic cl_sh_dma_pcis_awready,

        input[511:0] sh_cl_dma_pcis_wdata,
        input[63:0] sh_cl_dma_pcis_wstrb,
        input sh_cl_dma_pcis_wlast,
        input sh_cl_dma_pcis_wvalid,
        output logic cl_sh_dma_pcis_wready,

        output logic[5:0] cl_sh_dma_pcis_bid,
        output logic[1:0] cl_sh_dma_pcis_bresp,
        output logic cl_sh_dma_pcis_bvalid,
        input sh_cl_dma_pcis_bready,

        input[5:0] sh_cl_dma_pcis_arid,
        input[63:0] sh_cl_dma_pcis_araddr,
        input[7:0] sh_cl_dma_pcis_arlen,
        input[2:0] sh_cl_dma_pcis_arsize,
        input sh_cl_dma_pcis_arvalid,
        output logic cl_sh_dma_pcis_arready,

        output logic[5:0] cl_sh_dma_pcis_rid,
        output logic[511:0] cl_sh_dma_pcis_rdata,
        output logic[1:0] cl_sh_dma_pcis_rresp,
        output logic cl_sh_dma_pcis_rlast,
        output logic cl_sh_dma_pcis_rvalid,
        input sh_cl_dma_pcis_rready,

    //-----------------------------------------
    // cl_sh_ddr interface to shell for access to DDR C
    //-----------------------------------------

        output [15:0] cl_sh_ddr_awid,
        output [63:0] cl_sh_ddr_awaddr,
        output [7:0] cl_sh_ddr_awlen,
        output [2:0] cl_sh_ddr_awsize,
        output [1:0] cl_sh_ddr_awburst,              //Burst mode, only INCR is supported, must be tied to 2'b01
        output  cl_sh_ddr_awvalid,
        input sh_cl_ddr_awready,

        output [15:0] cl_sh_ddr_wid,
        output [511:0] cl_sh_ddr_wdata,
        output [63:0] cl_sh_ddr_wstrb,
        output  cl_sh_ddr_wlast,
        output  cl_sh_ddr_wvalid,
        input sh_cl_ddr_wready,

        input[15:0] sh_cl_ddr_bid,
        input[1:0] sh_cl_ddr_bresp,
        input sh_cl_ddr_bvalid,
        output  cl_sh_ddr_bready,

        output [15:0] cl_sh_ddr_arid,
        output [63:0] cl_sh_ddr_araddr,
        output [7:0] cl_sh_ddr_arlen,
        output [2:0] cl_sh_ddr_arsize,
        output [1:0] cl_sh_ddr_arburst,              //Burst mode, only INCR is supported, must be tied to 2'b01
        output  cl_sh_ddr_arvalid,
        input sh_cl_ddr_arready,

        input[15:0] sh_cl_ddr_rid,
        input[511:0] sh_cl_ddr_rdata,
        input[1:0] sh_cl_ddr_rresp,
        input sh_cl_ddr_rlast,
        input sh_cl_ddr_rvalid,
        output  cl_sh_ddr_rready,

    //-----------------------------------------
    // DDR A/B/D pins
    //-----------------------------------------

        // ------------------- DDR4 x72 RDIMM 2100 Interface A ----------------------------------
        input                CLK_300M_DIMM0_DP,
        input                CLK_300M_DIMM0_DN,
        output               M_A_ACT_N,
        output [16:0]        M_A_MA,
        output [1:0]         M_A_BA,
        output [1:0]         M_A_BG,
        output [0:0]         M_A_CKE,
        output [0:0]         M_A_ODT,
        output [0:0]         M_A_CS_N,
        output [0:0]         M_A_CLK_DN,
        output [0:0]         M_A_CLK_DP,
        output               M_A_PAR,
        inout  [63:0]        M_A_DQ,
        inout  [7:0]         M_A_ECC,
        inout  [17:0]        M_A_DQS_DP,
        inout  [17:0]        M_A_DQS_DN,
        output               cl_RST_DIMM_A_N,

        // ------------------- DDR4 x72 RDIMM 2100 Interface B ----------------------------------
        input                CLK_300M_DIMM1_DP,
        input                CLK_300M_DIMM1_DN,
        output               M_B_ACT_N,
        output [16:0]        M_B_MA,
        output [1:0]         M_B_BA,
        output [1:0]         M_B_BG,
        output [0:0]         M_B_CKE,
        output [0:0]         M_B_ODT,
        output [0:0]         M_B_CS_N,
        output [0:0]         M_B_CLK_DN,
        output [0:0]         M_B_CLK_DP,
        output               M_B_PAR,
        inout  [63:0]        M_B_DQ,
        inout  [7:0]         M_B_ECC,
        inout  [17:0]        M_B_DQS_DP,
        inout  [17:0]        M_B_DQS_DN,
        output               cl_RST_DIMM_B_N,


        // ------------------- DDR4 x72 RDIMM 2100 Interface D ----------------------------------
        input                CLK_300M_DIMM3_DP,
        input                CLK_300M_DIMM3_DN,
        output               M_D_ACT_N,
        output [16:0]        M_D_MA,
        output [1:0]         M_D_BA,
        output [1:0]         M_D_BG,
        output [0:0]         M_D_CKE,
        output [0:0]         M_D_ODT,
        output [0:0]         M_D_CS_N,
        output [0:0]         M_D_CLK_DN,
        output [0:0]         M_D_CLK_DP,
        output               M_D_PAR,
        inout  [63:0]        M_D_DQ,
        inout  [7:0]         M_D_ECC,
        inout  [17:0]        M_D_DQS_DP,
        inout  [17:0]        M_D_DQS_DN,
        output               cl_RST_DIMM_D_N,

    //-----------------------------------------
    // DDR stat pins
    //-----------------------------------------

        input [7:0] sh_ddr_stat_addr0,               //Stats address
        input sh_ddr_stat_wr0,                       //Stats write strobe
        input sh_ddr_stat_rd0,                       //Stats read strobe
        input [31:0] sh_ddr_stat_wdata0,             //Stats write data
        output logic ddr_sh_stat_ack0,               //Stats cycle ack
        output logic[31:0] ddr_sh_stat_rdata0,       //Stats cycle read data
        output logic[7:0] ddr_sh_stat_int0,          //Stats interrupt

        input [7:0] sh_ddr_stat_addr1,
        input sh_ddr_stat_wr1, 
        input sh_ddr_stat_rd1, 
        input [31:0] sh_ddr_stat_wdata1,
        output logic ddr_sh_stat_ack1,
        output logic[31:0] ddr_sh_stat_rdata1,
        output logic[7:0] ddr_sh_stat_int1,

        input [7:0] sh_ddr_stat_addr2,
        input sh_ddr_stat_wr2, 
        input sh_ddr_stat_rd2, 
        input [31:0] sh_ddr_stat_wdata2,
        output logic ddr_sh_stat_ack2,
        output logic[31:0] ddr_sh_stat_rdata2,
        output logic[7:0] ddr_sh_stat_int2, 

        output logic [2:0] ddr_ready_2d

);

// Define the addition pipeline stag
// needed to close timing for the various
// place where ATG (Automatic Test Generator)
// is defined
localparam NUM_CFG_STGS_CL_DDR_ATG = 8;


///////////////////////////////////////////////////////////////////////
///////////////////////// aws_mem_logic ///////////////////////////////
///////////////////////////////////////////////////////////////////////

    axi_bus_t sh_cl_dma_pcis_bus();
    axi_bus_t cl_sh_ddr_bus();
    axi_bus_t lcl_cl_sh_ddra();
    axi_bus_t lcl_cl_sh_ddrb();
    axi_bus_t lcl_cl_sh_ddrd();
    axi_bus_t mem_bus_translated();

    piton_aws_addr_translator piton_aws_addr_translator (
    .in(mem_bus), 
    .out(mem_bus_translated)
);

    // Unused 'full' signals
    assign cl_sh_dma_rd_full  = 1'b0;
    assign cl_sh_dma_wr_full  = 1'b0;


    assign sh_cl_dma_pcis_bus.awvalid = sh_cl_dma_pcis_awvalid;
    assign sh_cl_dma_pcis_bus.awaddr = sh_cl_dma_pcis_awaddr;
    assign sh_cl_dma_pcis_bus.awid[5:0] = sh_cl_dma_pcis_awid;
    assign sh_cl_dma_pcis_bus.awlen = sh_cl_dma_pcis_awlen;
    assign sh_cl_dma_pcis_bus.awsize = sh_cl_dma_pcis_awsize;
    assign cl_sh_dma_pcis_awready = sh_cl_dma_pcis_bus.awready;
    assign sh_cl_dma_pcis_bus.wvalid = sh_cl_dma_pcis_wvalid;
    assign sh_cl_dma_pcis_bus.wdata = sh_cl_dma_pcis_wdata;
    assign sh_cl_dma_pcis_bus.wstrb = sh_cl_dma_pcis_wstrb;
    assign sh_cl_dma_pcis_bus.wlast = sh_cl_dma_pcis_wlast;
    assign cl_sh_dma_pcis_wready = sh_cl_dma_pcis_bus.wready;
    assign cl_sh_dma_pcis_bvalid = sh_cl_dma_pcis_bus.bvalid;
    assign cl_sh_dma_pcis_bresp = sh_cl_dma_pcis_bus.bresp;
    assign sh_cl_dma_pcis_bus.bready = sh_cl_dma_pcis_bready;
    assign cl_sh_dma_pcis_bid = sh_cl_dma_pcis_bus.bid[5:0];
    assign sh_cl_dma_pcis_bus.arvalid = sh_cl_dma_pcis_arvalid;
    assign sh_cl_dma_pcis_bus.araddr = sh_cl_dma_pcis_araddr;
    assign sh_cl_dma_pcis_bus.arid[5:0] = sh_cl_dma_pcis_arid;
    assign sh_cl_dma_pcis_bus.arlen = sh_cl_dma_pcis_arlen;
    assign sh_cl_dma_pcis_bus.arsize = sh_cl_dma_pcis_arsize;
    assign cl_sh_dma_pcis_arready = sh_cl_dma_pcis_bus.arready;
    assign cl_sh_dma_pcis_rvalid = sh_cl_dma_pcis_bus.rvalid;
    assign cl_sh_dma_pcis_rid = sh_cl_dma_pcis_bus.rid[5:0];
    assign cl_sh_dma_pcis_rlast = sh_cl_dma_pcis_bus.rlast;
    assign cl_sh_dma_pcis_rresp = sh_cl_dma_pcis_bus.rresp;
    assign cl_sh_dma_pcis_rdata = sh_cl_dma_pcis_bus.rdata;
    assign sh_cl_dma_pcis_bus.rready = sh_cl_dma_pcis_rready;

    assign cl_sh_ddr_awid = cl_sh_ddr_bus.awid;
    assign cl_sh_ddr_awaddr = cl_sh_ddr_bus.awaddr;
    assign cl_sh_ddr_awlen = cl_sh_ddr_bus.awlen;
    assign cl_sh_ddr_awsize = cl_sh_ddr_bus.awsize;
    assign cl_sh_ddr_awvalid = cl_sh_ddr_bus.awvalid;
    assign cl_sh_ddr_bus.awready = sh_cl_ddr_awready;
    assign cl_sh_ddr_wid = 16'b0;
    assign cl_sh_ddr_wdata = cl_sh_ddr_bus.wdata;
    assign cl_sh_ddr_wstrb = cl_sh_ddr_bus.wstrb;
    assign cl_sh_ddr_wlast = cl_sh_ddr_bus.wlast;
    assign cl_sh_ddr_wvalid = cl_sh_ddr_bus.wvalid;
    assign cl_sh_ddr_bus.wready = sh_cl_ddr_wready;
    assign cl_sh_ddr_bus.bid = sh_cl_ddr_bid;
    assign cl_sh_ddr_bus.bresp = sh_cl_ddr_bresp;
    assign cl_sh_ddr_bus.bvalid = sh_cl_ddr_bvalid;
    assign cl_sh_ddr_bready = cl_sh_ddr_bus.bready;
    assign cl_sh_ddr_arid = cl_sh_ddr_bus.arid;
    assign cl_sh_ddr_araddr = cl_sh_ddr_bus.araddr;
    assign cl_sh_ddr_arlen = cl_sh_ddr_bus.arlen;
    assign cl_sh_ddr_arsize = cl_sh_ddr_bus.arsize;
    assign cl_sh_ddr_arvalid = cl_sh_ddr_bus.arvalid;
    assign cl_sh_ddr_bus.arready = sh_cl_ddr_arready;
    assign cl_sh_ddr_bus.rid = sh_cl_ddr_rid;
    assign cl_sh_ddr_bus.rresp = sh_cl_ddr_rresp;
    assign cl_sh_ddr_bus.rvalid = sh_cl_ddr_rvalid;
    assign cl_sh_ddr_bus.rdata = sh_cl_ddr_rdata;
    assign cl_sh_ddr_bus.rlast = sh_cl_ddr_rlast;
    assign cl_sh_ddr_rready = cl_sh_ddr_bus.rready;

    (* dont_touch = "true" *) logic piton_aws_xbar_sync_rst_n;
    lib_pipe #(.WIDTH(1), .STAGES(4)) piton_aws_xbar_slc_sync_rst_n (.clk(clk), .rst_n(1'b1), .in_bus(rst_n), .out_bus(piton_aws_xbar_sync_rst_n));

    piton_aws_xbar piton_aws_xbar (
        .aclk(clk),
        .aresetn(piton_aws_xbar_sync_rst_n),

        .sh_cl_dma_pcis_bus(sh_cl_dma_pcis_bus),
        .cl_axi_mstr_bus(mem_bus_translated),

        .lcl_cl_sh_ddra(lcl_cl_sh_ddra),
        .lcl_cl_sh_ddrb(lcl_cl_sh_ddrb),
        .lcl_cl_sh_ddrd(lcl_cl_sh_ddrd),
        .cl_sh_ddr_bus (cl_sh_ddr_bus)
      );

///////////////////////////////////////////////////////////////////////
///////////////////////// aws_mem_logic ///////////////////////////////
///////////////////////////////////////////////////////////////////////


//-----------------------------------------
// DDR controller instantiation
//-----------------------------------------
    logic [7:0] sh_ddr_stat_addr_q[2:0];
    logic[2:0] sh_ddr_stat_wr_q;
    logic[2:0] sh_ddr_stat_rd_q;
    logic[31:0] sh_ddr_stat_wdata_q[2:0];
    logic[2:0] ddr_sh_stat_ack_q;
    logic[31:0] ddr_sh_stat_rdata_q[2:0];
    logic[7:0] ddr_sh_stat_int_q[2:0];


    lib_pipe #(.WIDTH(1+1+8+32), .STAGES(NUM_CFG_STGS_CL_DDR_ATG)) pipe_ddr_stat0 (.clk(clk), .rst_n(rst_n),
                                                   .in_bus({sh_ddr_stat_wr0, sh_ddr_stat_rd0, sh_ddr_stat_addr0, sh_ddr_stat_wdata0}),
                                                   .out_bus({sh_ddr_stat_wr_q[0], sh_ddr_stat_rd_q[0], sh_ddr_stat_addr_q[0], sh_ddr_stat_wdata_q[0]})
                                                   );

    lib_pipe #(.WIDTH(1+8+32), .STAGES(NUM_CFG_STGS_CL_DDR_ATG)) pipe_ddr_stat_ack0 (.clk(clk), .rst_n(rst_n),
                                                   .in_bus({ddr_sh_stat_ack_q[0], ddr_sh_stat_int_q[0], ddr_sh_stat_rdata_q[0]}),
                                                   .out_bus({ddr_sh_stat_ack0, ddr_sh_stat_int0, ddr_sh_stat_rdata0})
                                                   );

    lib_pipe #(.WIDTH(1+1+8+32), .STAGES(NUM_CFG_STGS_CL_DDR_ATG)) pipe_ddr_stat1 (.clk(clk), .rst_n(rst_n),
                                                   .in_bus({sh_ddr_stat_wr1, sh_ddr_stat_rd1, sh_ddr_stat_addr1, sh_ddr_stat_wdata1}),
                                                   .out_bus({sh_ddr_stat_wr_q[1], sh_ddr_stat_rd_q[1], sh_ddr_stat_addr_q[1], sh_ddr_stat_wdata_q[1]})
                                                   );

    lib_pipe #(.WIDTH(1+8+32), .STAGES(NUM_CFG_STGS_CL_DDR_ATG)) pipe_ddr_stat_ack1 (.clk(clk), .rst_n(rst_n),
                                                   .in_bus({ddr_sh_stat_ack_q[1], ddr_sh_stat_int_q[1], ddr_sh_stat_rdata_q[1]}),
                                                   .out_bus({ddr_sh_stat_ack1, ddr_sh_stat_int1, ddr_sh_stat_rdata1})
                                                   );

    lib_pipe #(.WIDTH(1+1+8+32), .STAGES(NUM_CFG_STGS_CL_DDR_ATG)) pipe_ddr_stat2 (.clk(clk), .rst_n(rst_n),
                                                   .in_bus({sh_ddr_stat_wr2, sh_ddr_stat_rd2, sh_ddr_stat_addr2, sh_ddr_stat_wdata2}),
                                                   .out_bus({sh_ddr_stat_wr_q[2], sh_ddr_stat_rd_q[2], sh_ddr_stat_addr_q[2], sh_ddr_stat_wdata_q[2]})
                                                   );

    lib_pipe #(.WIDTH(1+8+32), .STAGES(NUM_CFG_STGS_CL_DDR_ATG)) pipe_ddr_stat_ack2 (.clk(clk), .rst_n(rst_n),
                                                   .in_bus({ddr_sh_stat_ack_q[2], ddr_sh_stat_int_q[2], ddr_sh_stat_rdata_q[2]}),
                                                   .out_bus({ddr_sh_stat_ack2, ddr_sh_stat_int2, ddr_sh_stat_rdata2})
                                                   );

    //convert to 2D
    logic[15:0] cl_sh_ddr_awid_2d[2:0];
    logic[63:0] cl_sh_ddr_awaddr_2d[2:0];
    logic[7:0] cl_sh_ddr_awlen_2d[2:0];
    logic[2:0] cl_sh_ddr_awsize_2d[2:0];
    logic[1:0] cl_sh_ddr_awburst_2d[2:0];
    logic cl_sh_ddr_awvalid_2d [2:0];
    logic[2:0] sh_cl_ddr_awready_2d;

    logic[15:0] cl_sh_ddr_wid_2d[2:0];
    logic[511:0] cl_sh_ddr_wdata_2d[2:0];
    logic[63:0] cl_sh_ddr_wstrb_2d[2:0];
    logic[2:0] cl_sh_ddr_wlast_2d;
    logic[2:0] cl_sh_ddr_wvalid_2d;
    logic[2:0] sh_cl_ddr_wready_2d;

    logic[15:0] sh_cl_ddr_bid_2d[2:0];
    logic[1:0] sh_cl_ddr_bresp_2d[2:0];
    logic[2:0] sh_cl_ddr_bvalid_2d;
    logic[2:0] cl_sh_ddr_bready_2d;

    logic[15:0] cl_sh_ddr_arid_2d[2:0];
    logic[63:0] cl_sh_ddr_araddr_2d[2:0];
    logic[7:0] cl_sh_ddr_arlen_2d[2:0];
    logic[2:0] cl_sh_ddr_arsize_2d[2:0];
    logic[1:0] cl_sh_ddr_arburst_2d[2:0];
    logic[2:0] cl_sh_ddr_arvalid_2d;
    logic[2:0] sh_cl_ddr_arready_2d;

    logic[15:0] sh_cl_ddr_rid_2d[2:0];
    logic[511:0] sh_cl_ddr_rdata_2d[2:0];
    logic[1:0] sh_cl_ddr_rresp_2d[2:0];
    logic[2:0] sh_cl_ddr_rlast_2d;
    logic[2:0] sh_cl_ddr_rvalid_2d;
    logic[2:0] cl_sh_ddr_rready_2d;

    assign cl_sh_ddr_awid_2d = '{lcl_cl_sh_ddrd.awid, lcl_cl_sh_ddrb.awid, lcl_cl_sh_ddra.awid};
    assign cl_sh_ddr_awaddr_2d = '{lcl_cl_sh_ddrd.awaddr, lcl_cl_sh_ddrb.awaddr, lcl_cl_sh_ddra.awaddr};
    assign cl_sh_ddr_awlen_2d = '{lcl_cl_sh_ddrd.awlen, lcl_cl_sh_ddrb.awlen, lcl_cl_sh_ddra.awlen};
    assign cl_sh_ddr_awsize_2d = '{lcl_cl_sh_ddrd.awsize, lcl_cl_sh_ddrb.awsize, lcl_cl_sh_ddra.awsize};
    assign cl_sh_ddr_awvalid_2d = '{lcl_cl_sh_ddrd.awvalid, lcl_cl_sh_ddrb.awvalid, lcl_cl_sh_ddra.awvalid};
    assign cl_sh_ddr_awburst_2d = {2'b01, 2'b01, 2'b01};
    assign {lcl_cl_sh_ddrd.awready, lcl_cl_sh_ddrb.awready, lcl_cl_sh_ddra.awready} = sh_cl_ddr_awready_2d;

    assign cl_sh_ddr_wid_2d = '{lcl_cl_sh_ddrd.wid, lcl_cl_sh_ddrb.wid, lcl_cl_sh_ddra.wid};
    assign cl_sh_ddr_wdata_2d = '{lcl_cl_sh_ddrd.wdata, lcl_cl_sh_ddrb.wdata, lcl_cl_sh_ddra.wdata};
    assign cl_sh_ddr_wstrb_2d = '{lcl_cl_sh_ddrd.wstrb, lcl_cl_sh_ddrb.wstrb, lcl_cl_sh_ddra.wstrb};
    assign cl_sh_ddr_wlast_2d = {lcl_cl_sh_ddrd.wlast, lcl_cl_sh_ddrb.wlast, lcl_cl_sh_ddra.wlast};
    assign cl_sh_ddr_wvalid_2d = {lcl_cl_sh_ddrd.wvalid, lcl_cl_sh_ddrb.wvalid, lcl_cl_sh_ddra.wvalid};
    assign {lcl_cl_sh_ddrd.wready, lcl_cl_sh_ddrb.wready, lcl_cl_sh_ddra.wready} = sh_cl_ddr_wready_2d;

    assign {lcl_cl_sh_ddrd.bid, lcl_cl_sh_ddrb.bid, lcl_cl_sh_ddra.bid} = {sh_cl_ddr_bid_2d[2], sh_cl_ddr_bid_2d[1], sh_cl_ddr_bid_2d[0]};
    assign {lcl_cl_sh_ddrd.bresp, lcl_cl_sh_ddrb.bresp, lcl_cl_sh_ddra.bresp} = {sh_cl_ddr_bresp_2d[2], sh_cl_ddr_bresp_2d[1], sh_cl_ddr_bresp_2d[0]};
    assign {lcl_cl_sh_ddrd.bvalid, lcl_cl_sh_ddrb.bvalid, lcl_cl_sh_ddra.bvalid} = sh_cl_ddr_bvalid_2d;
    assign cl_sh_ddr_bready_2d = {lcl_cl_sh_ddrd.bready, lcl_cl_sh_ddrb.bready, lcl_cl_sh_ddra.bready};

    assign cl_sh_ddr_arid_2d = '{lcl_cl_sh_ddrd.arid, lcl_cl_sh_ddrb.arid, lcl_cl_sh_ddra.arid};
    assign cl_sh_ddr_araddr_2d = '{lcl_cl_sh_ddrd.araddr, lcl_cl_sh_ddrb.araddr, lcl_cl_sh_ddra.araddr};
    assign cl_sh_ddr_arlen_2d = '{lcl_cl_sh_ddrd.arlen, lcl_cl_sh_ddrb.arlen, lcl_cl_sh_ddra.arlen};
    assign cl_sh_ddr_arsize_2d = '{lcl_cl_sh_ddrd.arsize, lcl_cl_sh_ddrb.arsize, lcl_cl_sh_ddra.arsize};
    assign cl_sh_ddr_arvalid_2d = {lcl_cl_sh_ddrd.arvalid, lcl_cl_sh_ddrb.arvalid, lcl_cl_sh_ddra.arvalid};
    assign cl_sh_ddr_arburst_2d = {2'b01, 2'b01, 2'b01};
    assign {lcl_cl_sh_ddrd.arready, lcl_cl_sh_ddrb.arready, lcl_cl_sh_ddra.arready} = sh_cl_ddr_arready_2d;

    assign {lcl_cl_sh_ddrd.rid, lcl_cl_sh_ddrb.rid, lcl_cl_sh_ddra.rid} = {sh_cl_ddr_rid_2d[2], sh_cl_ddr_rid_2d[1], sh_cl_ddr_rid_2d[0]};
    assign {lcl_cl_sh_ddrd.rresp, lcl_cl_sh_ddrb.rresp, lcl_cl_sh_ddra.rresp} = {sh_cl_ddr_rresp_2d[2], sh_cl_ddr_rresp_2d[1], sh_cl_ddr_rresp_2d[0]};
    assign {lcl_cl_sh_ddrd.rdata, lcl_cl_sh_ddrb.rdata, lcl_cl_sh_ddra.rdata} = {sh_cl_ddr_rdata_2d[2], sh_cl_ddr_rdata_2d[1], sh_cl_ddr_rdata_2d[0]};
    assign {lcl_cl_sh_ddrd.rlast, lcl_cl_sh_ddrb.rlast, lcl_cl_sh_ddra.rlast} = sh_cl_ddr_rlast_2d;
    assign {lcl_cl_sh_ddrd.rvalid, lcl_cl_sh_ddrb.rvalid, lcl_cl_sh_ddra.rvalid} = sh_cl_ddr_rvalid_2d;
    assign cl_sh_ddr_rready_2d = {lcl_cl_sh_ddrd.rready, lcl_cl_sh_ddrb.rready, lcl_cl_sh_ddra.rready};

    (* dont_touch = "true" *) logic sh_ddr_sync_rst_n;
    lib_pipe #(.WIDTH(1), .STAGES(4)) sh_ddr_slc_rst_n (.clk(clk), .rst_n(1'b1), .in_bus(rst_n), .out_bus(sh_ddr_sync_rst_n));
    sh_ddr #(
             .DDR_A_PRESENT(1),
             .DDR_B_PRESENT(0),
             .DDR_D_PRESENT(0)
       ) sh_ddr
       (
       .clk(clk),
       .rst_n(sh_ddr_sync_rst_n),

       .stat_clk(clk),
       .stat_rst_n(sh_ddr_sync_rst_n),


       .CLK_300M_DIMM0_DP(CLK_300M_DIMM0_DP),
       .CLK_300M_DIMM0_DN(CLK_300M_DIMM0_DN),
       .M_A_ACT_N(M_A_ACT_N),
       .M_A_MA(M_A_MA),
       .M_A_BA(M_A_BA),
       .M_A_BG(M_A_BG),
       .M_A_CKE(M_A_CKE),
       .M_A_ODT(M_A_ODT),
       .M_A_CS_N(M_A_CS_N),
       .M_A_CLK_DN(M_A_CLK_DN),
       .M_A_CLK_DP(M_A_CLK_DP),
       .M_A_PAR(M_A_PAR),
       .M_A_DQ(M_A_DQ),
       .M_A_ECC(M_A_ECC),
       .M_A_DQS_DP(M_A_DQS_DP),
       .M_A_DQS_DN(M_A_DQS_DN),
       .cl_RST_DIMM_A_N(cl_RST_DIMM_A_N),


       .CLK_300M_DIMM1_DP(CLK_300M_DIMM1_DP),
       .CLK_300M_DIMM1_DN(CLK_300M_DIMM1_DN),
       .M_B_ACT_N(M_B_ACT_N),
       .M_B_MA(M_B_MA),
       .M_B_BA(M_B_BA),
       .M_B_BG(M_B_BG),
       .M_B_CKE(M_B_CKE),
       .M_B_ODT(M_B_ODT),
       .M_B_CS_N(M_B_CS_N),
       .M_B_CLK_DN(M_B_CLK_DN),
       .M_B_CLK_DP(M_B_CLK_DP),
       .M_B_PAR(M_B_PAR),
       .M_B_DQ(M_B_DQ),
       .M_B_ECC(M_B_ECC),
       .M_B_DQS_DP(M_B_DQS_DP),
       .M_B_DQS_DN(M_B_DQS_DN),
       .cl_RST_DIMM_B_N(cl_RST_DIMM_B_N),

       .CLK_300M_DIMM3_DP(CLK_300M_DIMM3_DP),
       .CLK_300M_DIMM3_DN(CLK_300M_DIMM3_DN),
       .M_D_ACT_N(M_D_ACT_N),
       .M_D_MA(M_D_MA),
       .M_D_BA(M_D_BA),
       .M_D_BG(M_D_BG),
       .M_D_CKE(M_D_CKE),
       .M_D_ODT(M_D_ODT),
       .M_D_CS_N(M_D_CS_N),
       .M_D_CLK_DN(M_D_CLK_DN),
       .M_D_CLK_DP(M_D_CLK_DP),
       .M_D_PAR(M_D_PAR),
       .M_D_DQ(M_D_DQ),
       .M_D_ECC(M_D_ECC),
       .M_D_DQS_DP(M_D_DQS_DP),
       .M_D_DQS_DN(M_D_DQS_DN),
       .cl_RST_DIMM_D_N(cl_RST_DIMM_D_N),

       //------------------------------------------------------
       // DDR-4 Interface from CL (AXI-4)
       //------------------------------------------------------
       .cl_sh_ddr_awid(cl_sh_ddr_awid_2d),
       .cl_sh_ddr_awaddr(cl_sh_ddr_awaddr_2d),
       .cl_sh_ddr_awlen(cl_sh_ddr_awlen_2d),
       .cl_sh_ddr_awsize(cl_sh_ddr_awsize_2d),
       .cl_sh_ddr_awvalid(cl_sh_ddr_awvalid_2d),
       .cl_sh_ddr_awburst(cl_sh_ddr_awburst_2d),
       .sh_cl_ddr_awready(sh_cl_ddr_awready_2d),

       .cl_sh_ddr_wid(cl_sh_ddr_wid_2d),
       .cl_sh_ddr_wdata(cl_sh_ddr_wdata_2d),
       .cl_sh_ddr_wstrb(cl_sh_ddr_wstrb_2d),
       .cl_sh_ddr_wlast(cl_sh_ddr_wlast_2d),
       .cl_sh_ddr_wvalid(cl_sh_ddr_wvalid_2d),
       .sh_cl_ddr_wready(sh_cl_ddr_wready_2d),

       .sh_cl_ddr_bid(sh_cl_ddr_bid_2d),
       .sh_cl_ddr_bresp(sh_cl_ddr_bresp_2d),
       .sh_cl_ddr_bvalid(sh_cl_ddr_bvalid_2d),
       .cl_sh_ddr_bready(cl_sh_ddr_bready_2d),

       .cl_sh_ddr_arid(cl_sh_ddr_arid_2d),
       .cl_sh_ddr_araddr(cl_sh_ddr_araddr_2d),
       .cl_sh_ddr_arlen(cl_sh_ddr_arlen_2d),
       .cl_sh_ddr_arsize(cl_sh_ddr_arsize_2d),
       .cl_sh_ddr_arvalid(cl_sh_ddr_arvalid_2d),
       .cl_sh_ddr_arburst(cl_sh_ddr_arburst_2d),
       .sh_cl_ddr_arready(sh_cl_ddr_arready_2d),

       .sh_cl_ddr_rid(sh_cl_ddr_rid_2d),
       .sh_cl_ddr_rdata(sh_cl_ddr_rdata_2d),
       .sh_cl_ddr_rresp(sh_cl_ddr_rresp_2d),
       .sh_cl_ddr_rlast(sh_cl_ddr_rlast_2d),
       .sh_cl_ddr_rvalid(sh_cl_ddr_rvalid_2d),
       .cl_sh_ddr_rready(cl_sh_ddr_rready_2d),

       .sh_cl_ddr_is_ready(ddr_ready_2d),

       .sh_ddr_stat_addr0  (sh_ddr_stat_addr_q[0]) ,
       .sh_ddr_stat_wr0    (sh_ddr_stat_wr_q[0]     ) ,
       .sh_ddr_stat_rd0    (sh_ddr_stat_rd_q[0]     ) ,
       .sh_ddr_stat_wdata0 (sh_ddr_stat_wdata_q[0]  ) ,
       .ddr_sh_stat_ack0   (ddr_sh_stat_ack_q[0]    ) ,
       .ddr_sh_stat_rdata0 (ddr_sh_stat_rdata_q[0]  ),
       .ddr_sh_stat_int0   (ddr_sh_stat_int_q[0]    ),

       .sh_ddr_stat_addr1  (sh_ddr_stat_addr_q[1]) ,
       .sh_ddr_stat_wr1    (sh_ddr_stat_wr_q[1]     ) ,
       .sh_ddr_stat_rd1    (sh_ddr_stat_rd_q[1]     ) ,
       .sh_ddr_stat_wdata1 (sh_ddr_stat_wdata_q[1]  ) ,
       .ddr_sh_stat_ack1   (ddr_sh_stat_ack_q[1]    ) ,
       .ddr_sh_stat_rdata1 (ddr_sh_stat_rdata_q[1]  ),
       .ddr_sh_stat_int1   (ddr_sh_stat_int_q[1]    ),

       .sh_ddr_stat_addr2  (sh_ddr_stat_addr_q[2]) ,
       .sh_ddr_stat_wr2    (sh_ddr_stat_wr_q[2]     ) ,
       .sh_ddr_stat_rd2    (sh_ddr_stat_rd_q[2]     ) ,
       .sh_ddr_stat_wdata2 (sh_ddr_stat_wdata_q[2]  ) ,
       .ddr_sh_stat_ack2   (ddr_sh_stat_ack_q[2]    ) ,
       .ddr_sh_stat_rdata2 (ddr_sh_stat_rdata_q[2]  ),
       .ddr_sh_stat_int2   (ddr_sh_stat_int_q[2]    )
       );

//-----------------------------------------
// DDR controller instantiation
//-----------------------------------------

endmodule 
