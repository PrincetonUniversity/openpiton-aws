// Amazon FPGA Hardware Development Kit
//
// Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License"). You may not use
// this file except in compliance with the License. A copy of the License is
// located at
//
//    http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
// implied. See the License for the specific language governing permissions and
// limitations under the License.

module piton_aws_xbar
(
    input aclk,
    input aresetn,

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
    // Master interface from Piton
    //-----------------------------------------

        axi_bus_t.master cl_axi_mstr_bus,

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
        output  cl_sh_ddr_rready
);
/*
//----------------------------
// Internal signals
//----------------------------

    axi_bus_t cl_sh_ddr_q();
    axi_bus_t cl_sh_ddr_q2();
    axi_bus_t sh_cl_dma_pcis_q();
    axi_bus_t sh_cl_dma_pcis_q2();
    axi_bus_t cl_axi_mstr_q();
    axi_bus_t cl_axi_mstr_q2();


//----------------------------
// End Internal signals
//----------------------------

//reset synchronizers
    (* dont_touch = "true" *) logic slr0_sync_aresetn;
    (* dont_touch = "true" *) logic slr1_sync_aresetn;
    (* dont_touch = "true" *) logic slr2_sync_aresetn;
    lib_pipe #(.WIDTH(1), .STAGES(4)) slr0_pipe_rst_n (.clk(aclk), .rst_n(1'b1), .in_bus(aresetn), .out_bus(slr0_sync_aresetn));
    lib_pipe #(.WIDTH(1), .STAGES(4)) slr1_pipe_rst_n (.clk(aclk), .rst_n(1'b1), .in_bus(aresetn), .out_bus(slr1_sync_aresetn));
    lib_pipe #(.WIDTH(1), .STAGES(4)) slr2_pipe_rst_n (.clk(aclk), .rst_n(1'b1), .in_bus(aresetn), .out_bus(slr2_sync_aresetn));

//----------------------------
// flop the input of interconnect for dma
// back to back for SLR crossing
//----------------------------

    src_register_slice dma_axi4_src_slice (
        .aclk          (aclk),
        .aresetn       (slr2_sync_aresetn),
        .s_axi_awid    (sh_cl_dma_pcis_awid),
        .s_axi_awaddr  (sh_cl_dma_pcis_awaddr),
        .s_axi_awlen   (sh_cl_dma_pcis_awlen),
        .s_axi_awsize  (sh_cl_dma_pcis_awsize),
        .s_axi_awvalid (sh_cl_dma_pcis_awvalid),
        .s_axi_awready (cl_sh_dma_pcis_awready),
        .s_axi_wdata   (sh_cl_dma_pcis_wdata),
        .s_axi_wstrb   (sh_cl_dma_pcis_wstrb),
        .s_axi_wlast   (sh_cl_dma_pcis_wlast),
        .s_axi_wvalid  (sh_cl_dma_pcis_wvalid),
        .s_axi_wready  (cl_sh_dma_pcis_wready),
        .s_axi_bid     (cl_sh_dma_pcis_bid),
        .s_axi_bresp   (cl_sh_dma_pcis_bresp),
        .s_axi_bvalid  (cl_sh_dma_pcis_bvalid),
        .s_axi_bready  (sh_cl_dma_pcis_bready),
        .s_axi_arid    (sh_cl_dma_pcis_arid),
        .s_axi_araddr  (sh_cl_dma_pcis_araddr),
        .s_axi_arlen   (sh_cl_dma_pcis_arlen),
        .s_axi_arsize  (sh_cl_dma_pcis_arsize),
        .s_axi_arvalid (sh_cl_dma_pcis_arvalid),
        .s_axi_arready (cl_sh_dma_pcis_arready),
        .s_axi_rid     (cl_sh_dma_pcis_rid),
        .s_axi_rdata   (cl_sh_dma_pcis_rdata),
        .s_axi_rresp   (cl_sh_dma_pcis_rresp),
        .s_axi_rlast   (cl_sh_dma_pcis_rlast),
        .s_axi_rvalid  (cl_sh_dma_pcis_rvalid),
        .s_axi_rready  (sh_cl_dma_pcis_rready),

        .m_axi_awid    (sh_cl_dma_pcis_q.awid),
        .m_axi_awaddr  (sh_cl_dma_pcis_q.awaddr),
        .m_axi_awlen   (sh_cl_dma_pcis_q.awlen),
        .m_axi_awvalid (sh_cl_dma_pcis_q.awvalid),
        .m_axi_awsize  (sh_cl_dma_pcis_q.awsize),
        .m_axi_awready (sh_cl_dma_pcis_q.awready),
        .m_axi_wdata   (sh_cl_dma_pcis_q.wdata),
        .m_axi_wstrb   (sh_cl_dma_pcis_q.wstrb),
        .m_axi_wvalid  (sh_cl_dma_pcis_q.wvalid),
        .m_axi_wlast   (sh_cl_dma_pcis_q.wlast),
        .m_axi_wready  (sh_cl_dma_pcis_q.wready),
        .m_axi_bresp   (sh_cl_dma_pcis_q.bresp),
        .m_axi_bvalid  (sh_cl_dma_pcis_q.bvalid),
        .m_axi_bid     (sh_cl_dma_pcis_q.bid),
        .m_axi_bready  (sh_cl_dma_pcis_q.bready),
        .m_axi_arid    (sh_cl_dma_pcis_q.arid),
        .m_axi_araddr  (sh_cl_dma_pcis_q.araddr),
        .m_axi_arlen   (sh_cl_dma_pcis_q.arlen),
        .m_axi_arsize  (sh_cl_dma_pcis_q.arsize),
        .m_axi_arvalid (sh_cl_dma_pcis_q.arvalid),
        .m_axi_arready (sh_cl_dma_pcis_q.arready),
        .m_axi_rid     (sh_cl_dma_pcis_q.rid),
        .m_axi_rdata   (sh_cl_dma_pcis_q.rdata),
        .m_axi_rresp   (sh_cl_dma_pcis_q.rresp),
        .m_axi_rlast   (sh_cl_dma_pcis_q.rlast),
        .m_axi_rvalid  (sh_cl_dma_pcis_q.rvalid),
        .m_axi_rready  (sh_cl_dma_pcis_q.rready)
    );

    dest_register_slice dma_axi4_dest_slice (
        .aclk          (aclk),
        .aresetn       (slr1_sync_aresetn),
        .s_axi_awid    (sh_cl_dma_pcis_q.awid),
        .s_axi_awaddr  (sh_cl_dma_pcis_q.awaddr),
        .s_axi_awlen   (sh_cl_dma_pcis_q.awlen),
        .s_axi_awvalid (sh_cl_dma_pcis_q.awvalid),
        .s_axi_awsize  (sh_cl_dma_pcis_q.awsize),
        .s_axi_awready (sh_cl_dma_pcis_q.awready),
        .s_axi_wdata   (sh_cl_dma_pcis_q.wdata),
        .s_axi_wstrb   (sh_cl_dma_pcis_q.wstrb),
        .s_axi_wlast   (sh_cl_dma_pcis_q.wlast),
        .s_axi_wvalid  (sh_cl_dma_pcis_q.wvalid),
        .s_axi_wready  (sh_cl_dma_pcis_q.wready),
        .s_axi_bid     (sh_cl_dma_pcis_q.bid),
        .s_axi_bresp   (sh_cl_dma_pcis_q.bresp),
        .s_axi_bvalid  (sh_cl_dma_pcis_q.bvalid),
        .s_axi_bready  (sh_cl_dma_pcis_q.bready),
        .s_axi_arid    (sh_cl_dma_pcis_q.arid),
        .s_axi_araddr  (sh_cl_dma_pcis_q.araddr),
        .s_axi_arlen   (sh_cl_dma_pcis_q.arlen),
        .s_axi_arvalid (sh_cl_dma_pcis_q.arvalid),
        .s_axi_arsize  (sh_cl_dma_pcis_q.arsize),
        .s_axi_arready (sh_cl_dma_pcis_q.arready),
        .s_axi_rid     (sh_cl_dma_pcis_q.rid),
        .s_axi_rdata   (sh_cl_dma_pcis_q.rdata),
        .s_axi_rresp   (sh_cl_dma_pcis_q.rresp),
        .s_axi_rlast   (sh_cl_dma_pcis_q.rlast),
        .s_axi_rvalid  (sh_cl_dma_pcis_q.rvalid),
        .s_axi_rready  (sh_cl_dma_pcis_q.rready),

        .m_axi_awid    (sh_cl_dma_pcis_q2.awid),
        .m_axi_awaddr  (sh_cl_dma_pcis_q2.awaddr),
        .m_axi_awlen   (sh_cl_dma_pcis_q2.awlen),
        .m_axi_awvalid (sh_cl_dma_pcis_q2.awvalid),
        .m_axi_awsize  (sh_cl_dma_pcis_q2.awsize),
        .m_axi_awready (sh_cl_dma_pcis_q2.awready),
        .m_axi_wdata   (sh_cl_dma_pcis_q2.wdata),
        .m_axi_wstrb   (sh_cl_dma_pcis_q2.wstrb),
        .m_axi_wvalid  (sh_cl_dma_pcis_q2.wvalid),
        .m_axi_wlast   (sh_cl_dma_pcis_q2.wlast),
        .m_axi_wready  (sh_cl_dma_pcis_q2.wready),
        .m_axi_bresp   (sh_cl_dma_pcis_q2.bresp),
        .m_axi_bvalid  (sh_cl_dma_pcis_q2.bvalid),
        .m_axi_bid     (sh_cl_dma_pcis_q2.bid),
        .m_axi_bready  (sh_cl_dma_pcis_q2.bready),
        .m_axi_arid    (sh_cl_dma_pcis_q2.arid),
        .m_axi_araddr  (sh_cl_dma_pcis_q2.araddr),
        .m_axi_arlen   (sh_cl_dma_pcis_q2.arlen),
        .m_axi_arsize  (sh_cl_dma_pcis_q2.arsize),
        .m_axi_arvalid (sh_cl_dma_pcis_q2.arvalid),
        .m_axi_arready (sh_cl_dma_pcis_q2.arready),
        .m_axi_rid     (sh_cl_dma_pcis_q2.rid),
        .m_axi_rdata   (sh_cl_dma_pcis_q2.rdata),
        .m_axi_rresp   (sh_cl_dma_pcis_q2.rresp),
        .m_axi_rlast   (sh_cl_dma_pcis_q2.rlast),
        .m_axi_rvalid  (sh_cl_dma_pcis_q2.rvalid),
        .m_axi_rready  (sh_cl_dma_pcis_q2.rready)
    );

//----------------------------
// flop the input of interconnect for master
// back to back for SLR crossing
//----------------------------
    src_register_slice master_axi4_src_slice (
        .aclk          (aclk),
        .aresetn       (slr0_sync_aresetn),

        .s_axi_awid    (cl_axi_mstr_bus.awid),
        .s_axi_awaddr  (cl_axi_mstr_bus.awaddr),
        .s_axi_awlen   (cl_axi_mstr_bus.awlen),
        .s_axi_awvalid (cl_axi_mstr_bus.awvalid),
        .s_axi_awsize  (cl_axi_mstr_bus.awsize),
        .s_axi_awready (cl_axi_mstr_bus.awready),
        .s_axi_wdata   (cl_axi_mstr_bus.wdata),
        .s_axi_wstrb   (cl_axi_mstr_bus.wstrb),
        .s_axi_wlast   (cl_axi_mstr_bus.wlast),
        .s_axi_wvalid  (cl_axi_mstr_bus.wvalid),
        .s_axi_wready  (cl_axi_mstr_bus.wready),
        .s_axi_bid     (cl_axi_mstr_bus.bid),
        .s_axi_bresp   (cl_axi_mstr_bus.bresp),
        .s_axi_bvalid  (cl_axi_mstr_bus.bvalid),
        .s_axi_bready  (cl_axi_mstr_bus.bready),
        .s_axi_arid    (cl_axi_mstr_bus.arid),
        .s_axi_araddr  (cl_axi_mstr_bus.araddr),
        .s_axi_arlen   (cl_axi_mstr_bus.arlen),
        .s_axi_arvalid (cl_axi_mstr_bus.arvalid),
        .s_axi_arsize  (cl_axi_mstr_bus.arsize),
        .s_axi_arready (cl_axi_mstr_bus.arready),
        .s_axi_rid     (cl_axi_mstr_bus.rid),
        .s_axi_rdata   (cl_axi_mstr_bus.rdata),
        .s_axi_rresp   (cl_axi_mstr_bus.rresp),
        .s_axi_rlast   (cl_axi_mstr_bus.rlast),
        .s_axi_rvalid  (cl_axi_mstr_bus.rvalid),
        .s_axi_rready  (cl_axi_mstr_bus.rready),

        .m_axi_awid    (cl_axi_mstr_q.awid),
        .m_axi_awaddr  (cl_axi_mstr_q.awaddr),
        .m_axi_awlen   (cl_axi_mstr_q.awlen),
        .m_axi_awvalid (cl_axi_mstr_q.awvalid),
        .m_axi_awsize  (cl_axi_mstr_q.awsize),
        .m_axi_awready (cl_axi_mstr_q.awready),
        .m_axi_wdata   (cl_axi_mstr_q.wdata),
        .m_axi_wstrb   (cl_axi_mstr_q.wstrb),
        .m_axi_wvalid  (cl_axi_mstr_q.wvalid),
        .m_axi_wlast   (cl_axi_mstr_q.wlast),
        .m_axi_wready  (cl_axi_mstr_q.wready),
        .m_axi_bresp   (cl_axi_mstr_q.bresp),
        .m_axi_bvalid  (cl_axi_mstr_q.bvalid),
        .m_axi_bid     (cl_axi_mstr_q.bid),
        .m_axi_bready  (cl_axi_mstr_q.bready),
        .m_axi_arid    (cl_axi_mstr_q.arid),
        .m_axi_araddr  (cl_axi_mstr_q.araddr),
        .m_axi_arlen   (cl_axi_mstr_q.arlen),
        .m_axi_arsize  (cl_axi_mstr_q.arsize),
        .m_axi_arvalid (cl_axi_mstr_q.arvalid),
        .m_axi_arready (cl_axi_mstr_q.arready),
        .m_axi_rid     (cl_axi_mstr_q.rid),
        .m_axi_rdata   (cl_axi_mstr_q.rdata),
        .m_axi_rresp   (cl_axi_mstr_q.rresp),
        .m_axi_rlast   (cl_axi_mstr_q.rlast),
        .m_axi_rvalid  (cl_axi_mstr_q.rvalid),
        .m_axi_rready  (cl_axi_mstr_q.rready)
    );

    dest_register_slice master_axi4_dest_slice (
        .aclk          (aclk),
        .aresetn       (slr1_sync_aresetn),
        .s_axi_awid    (cl_axi_mstr_q.awid),
        .s_axi_awaddr  (cl_axi_mstr_q.awaddr),
        .s_axi_awlen   (cl_axi_mstr_q.awlen),
        .s_axi_awvalid (cl_axi_mstr_q.awvalid),
        .s_axi_awsize  (cl_axi_mstr_q.awsize),
        .s_axi_awready (cl_axi_mstr_q.awready),
        .s_axi_wdata   (cl_axi_mstr_q.wdata),
        .s_axi_wstrb   (cl_axi_mstr_q.wstrb),
        .s_axi_wlast   (cl_axi_mstr_q.wlast),
        .s_axi_wvalid  (cl_axi_mstr_q.wvalid),
        .s_axi_wready  (cl_axi_mstr_q.wready),
        .s_axi_bid     (cl_axi_mstr_q.bid),
        .s_axi_bresp   (cl_axi_mstr_q.bresp),
        .s_axi_bvalid  (cl_axi_mstr_q.bvalid),
        .s_axi_bready  (cl_axi_mstr_q.bready),
        .s_axi_arid    (cl_axi_mstr_q.arid),
        .s_axi_araddr  (cl_axi_mstr_q.araddr),
        .s_axi_arlen   (cl_axi_mstr_q.arlen),
        .s_axi_arvalid (cl_axi_mstr_q.arvalid),
        .s_axi_arsize  (cl_axi_mstr_q.arsize),
        .s_axi_arready (cl_axi_mstr_q.arready),
        .s_axi_rid     (cl_axi_mstr_q.rid),
        .s_axi_rdata   (cl_axi_mstr_q.rdata),
        .s_axi_rresp   (cl_axi_mstr_q.rresp),
        .s_axi_rlast   (cl_axi_mstr_q.rlast),
        .s_axi_rvalid  (cl_axi_mstr_q.rvalid),
        .s_axi_rready  (cl_axi_mstr_q.rready),

        .m_axi_awid    (cl_axi_mstr_q2.awid),
        .m_axi_awaddr  (cl_axi_mstr_q2.awaddr),
        .m_axi_awlen   (cl_axi_mstr_q2.awlen),
        .m_axi_awvalid (cl_axi_mstr_q2.awvalid),
        .m_axi_awsize  (cl_axi_mstr_q2.awsize),
        .m_axi_awready (cl_axi_mstr_q2.awready),
        .m_axi_wdata   (cl_axi_mstr_q2.wdata),
        .m_axi_wstrb   (cl_axi_mstr_q2.wstrb),
        .m_axi_wvalid  (cl_axi_mstr_q2.wvalid),
        .m_axi_wlast   (cl_axi_mstr_q2.wlast),
        .m_axi_wready  (cl_axi_mstr_q2.wready),
        .m_axi_bresp   (cl_axi_mstr_q2.bresp),
        .m_axi_bvalid  (cl_axi_mstr_q2.bvalid),
        .m_axi_bid     (cl_axi_mstr_q2.bid),
        .m_axi_bready  (cl_axi_mstr_q2.bready),
        .m_axi_arid    (cl_axi_mstr_q2.arid),
        .m_axi_araddr  (cl_axi_mstr_q2.araddr),
        .m_axi_arlen   (cl_axi_mstr_q2.arlen),
        .m_axi_arsize  (cl_axi_mstr_q2.arsize),
        .m_axi_arvalid (cl_axi_mstr_q2.arvalid),
        .m_axi_arready (cl_axi_mstr_q2.arready),
        .m_axi_rid     (cl_axi_mstr_q2.rid),
        .m_axi_rdata   (cl_axi_mstr_q2.rdata),
        .m_axi_rresp   (cl_axi_mstr_q2.rresp),
        .m_axi_rlast   (cl_axi_mstr_q2.rlast),
        .m_axi_rvalid  (cl_axi_mstr_q2.rvalid),
        .m_axi_rready  (cl_axi_mstr_q2.rready)
    );


//----------------------------
// flop the output of interconnect for DDRC
// back to back for SLR crossing
//----------------------------

    src_register_slice ddrc_axi4_src_slice (
        .aclk           (aclk),
        .aresetn        (slr1_sync_aresetn),

        .s_axi_awid     (cl_sh_ddr_q.awid),
        .s_axi_awaddr   (cl_sh_ddr_q.awaddr),
        .s_axi_awlen    (cl_sh_ddr_q.awlen),
        .s_axi_awsize   (cl_sh_ddr_q.awsize),
        .s_axi_awvalid  (cl_sh_ddr_q.awvalid),
        .s_axi_awready  (cl_sh_ddr_q.awready),
        .s_axi_wdata    (cl_sh_ddr_q.wdata),
        .s_axi_wstrb    (cl_sh_ddr_q.wstrb),
        .s_axi_wlast    (cl_sh_ddr_q.wlast),
        .s_axi_wvalid   (cl_sh_ddr_q.wvalid),
        .s_axi_wready   (cl_sh_ddr_q.wready),
        .s_axi_bid      (cl_sh_ddr_q.bid),
        .s_axi_bresp    (cl_sh_ddr_q.bresp),
        .s_axi_bvalid   (cl_sh_ddr_q.bvalid),
        .s_axi_bready   (cl_sh_ddr_q.bready),
        .s_axi_arid     (cl_sh_ddr_q.arid),
        .s_axi_araddr   (cl_sh_ddr_q.araddr),
        .s_axi_arlen    (cl_sh_ddr_q.arlen),
        .s_axi_arsize   (cl_sh_ddr_q.arsize),
        .s_axi_arvalid  (cl_sh_ddr_q.arvalid),
        .s_axi_arready  (cl_sh_ddr_q.arready),
        .s_axi_rid      (cl_sh_ddr_q.rid),
        .s_axi_rdata    (cl_sh_ddr_q.rdata),
        .s_axi_rresp    (cl_sh_ddr_q.rresp),
        .s_axi_rlast    (cl_sh_ddr_q.rlast),
        .s_axi_rvalid   (cl_sh_ddr_q.rvalid),
        .s_axi_rready   (cl_sh_ddr_q.rready),

        .m_axi_awid     (cl_sh_ddr_q2.awid),
        .m_axi_awaddr   (cl_sh_ddr_q2.awaddr),
        .m_axi_awlen    (cl_sh_ddr_q2.awlen),
        .m_axi_awsize   (cl_sh_ddr_q2.awsize),
        .m_axi_awvalid  (cl_sh_ddr_q2.awvalid),
        .m_axi_awready  (cl_sh_ddr_q2.awready),
        .m_axi_wdata    (cl_sh_ddr_q2.wdata),
        .m_axi_wstrb    (cl_sh_ddr_q2.wstrb),
        .m_axi_wlast    (cl_sh_ddr_q2.wlast),
        .m_axi_wvalid   (cl_sh_ddr_q2.wvalid),
        .m_axi_wready   (cl_sh_ddr_q2.wready),
        .m_axi_bid      (cl_sh_ddr_q2.bid),
        .m_axi_bresp    (cl_sh_ddr_q2.bresp),
        .m_axi_bvalid   (cl_sh_ddr_q2.bvalid),
        .m_axi_bready   (cl_sh_ddr_q2.bready),
        .m_axi_arid     (cl_sh_ddr_q2.arid),
        .m_axi_araddr   (cl_sh_ddr_q2.araddr),
        .m_axi_arlen    (cl_sh_ddr_q2.arlen),
        .m_axi_arsize   (cl_sh_ddr_q2.arsize),
        .m_axi_arvalid  (cl_sh_ddr_q2.arvalid),
        .m_axi_arready  (cl_sh_ddr_q2.arready),
        .m_axi_rid      (cl_sh_ddr_q2.rid),
        .m_axi_rdata    (cl_sh_ddr_q2.rdata),
        .m_axi_rresp    (cl_sh_ddr_q2.rresp),
        .m_axi_rlast    (cl_sh_ddr_q2.rlast),
        .m_axi_rvalid   (cl_sh_ddr_q2.rvalid),
        .m_axi_rready   (cl_sh_ddr_q2.rready)
    );

    dest_register_slice ddrc_axi4_dest_slice (
        .aclk           (aclk),
        .aresetn        (slr1_sync_aresetn),

        .s_axi_awid     (cl_sh_ddr_q2.awid),
        .s_axi_awaddr   (cl_sh_ddr_q2.awaddr),
        .s_axi_awlen    (cl_sh_ddr_q2.awlen),
        .s_axi_awsize   (cl_sh_ddr_q2.awsize),
        .s_axi_awvalid  (cl_sh_ddr_q2.awvalid),
        .s_axi_awready  (cl_sh_ddr_q2.awready),
        .s_axi_wdata    (cl_sh_ddr_q2.wdata),
        .s_axi_wstrb    (cl_sh_ddr_q2.wstrb),
        .s_axi_wlast    (cl_sh_ddr_q2.wlast),
        .s_axi_wvalid   (cl_sh_ddr_q2.wvalid),
        .s_axi_wready   (cl_sh_ddr_q2.wready),
        .s_axi_bid      (cl_sh_ddr_q2.bid),
        .s_axi_bresp    (cl_sh_ddr_q2.bresp),
        .s_axi_bvalid   (cl_sh_ddr_q2.bvalid),
        .s_axi_bready   (cl_sh_ddr_q2.bready),
        .s_axi_arid     (cl_sh_ddr_q2.arid),
        .s_axi_araddr   (cl_sh_ddr_q2.araddr),
        .s_axi_arlen    (cl_sh_ddr_q2.arlen),
        .s_axi_arsize   (cl_sh_ddr_q2.arsize),
        .s_axi_arvalid  (cl_sh_ddr_q2.arvalid),
        .s_axi_arready  (cl_sh_ddr_q2.arready),
        .s_axi_rid      (cl_sh_ddr_q2.rid),
        .s_axi_rdata    (cl_sh_ddr_q2.rdata),
        .s_axi_rresp    (cl_sh_ddr_q2.rresp),
        .s_axi_rlast    (cl_sh_ddr_q2.rlast),
        .s_axi_rvalid   (cl_sh_ddr_q2.rvalid),
        .s_axi_rready   (cl_sh_ddr_q2.rready),

        .m_axi_awid     (cl_sh_ddr_awid),
        .m_axi_awaddr   (cl_sh_ddr_awaddr),
        .m_axi_awlen    (cl_sh_ddr_awlen),
        .m_axi_awsize   (cl_sh_ddr_awsize),
        .m_axi_awvalid  (cl_sh_ddr_awvalid),
        .m_axi_awready  (sh_cl_ddr_awready),
        .m_axi_wdata    (cl_sh_ddr_wdata),
        .m_axi_wstrb    (cl_sh_ddr_wstrb),
        .m_axi_wlast    (cl_sh_ddr_wlast),
        .m_axi_wvalid   (cl_sh_ddr_wvalid),
        .m_axi_wready   (sh_cl_ddr_wready),
        .m_axi_bid      (sh_cl_ddr_bid),
        .m_axi_bresp    (sh_cl_ddr_bresp),
        .m_axi_bvalid   (sh_cl_ddr_bvalid),
        .m_axi_bready   (cl_sh_ddr_bready),
        .m_axi_arid     (cl_sh_ddr_arid),
        .m_axi_araddr   (cl_sh_ddr_araddr),
        .m_axi_arlen    (cl_sh_ddr_arlen),
        .m_axi_arsize   (cl_sh_ddr_arsize),
        .m_axi_arvalid  (cl_sh_ddr_arvalid),
        .m_axi_arready  (sh_cl_ddr_arready),
        .m_axi_rid      (sh_cl_ddr_rid),
        .m_axi_rdata    (sh_cl_ddr_rdata),
        .m_axi_rresp    (sh_cl_ddr_rresp),
        .m_axi_rlast    (sh_cl_ddr_rlast),
        .m_axi_rvalid   (sh_cl_ddr_rvalid),
        .m_axi_rready   (cl_sh_ddr_rready)
    );



*/



axi_interconnect axi_interconnect (
  .INTERCONNECT_ACLK(aclk),        // input wire INTERCONNECT_ACLK
  .INTERCONNECT_ARESETN(aresetn),  // input wire INTERCONNECT_ARESETN
  
  .S00_AXI_ARESET_OUT_N(),  // output wire S00_AXI_ARESET_OUT_N
  .S00_AXI_ACLK(aclk),                        // input wire S00_AXI_ACLK
  .S00_AXI_AWID(cl_axi_mstr_bus.awid),                  // input wire [7 : 0] S00_AXI_AWID
  .S00_AXI_AWADDR(cl_axi_mstr_bus.awaddr),              // input wire [63 : 0] S00_AXI_AWADDR
  .S00_AXI_AWLEN(cl_axi_mstr_bus.awlen),                // input wire [7 : 0] S00_AXI_AWLEN
  .S00_AXI_AWSIZE(cl_axi_mstr_bus.awsize),              // input wire [2 : 0] S00_AXI_AWSIZE
  .S00_AXI_AWBURST(cl_axi_mstr_bus.awburst),            // input wire [1 : 0] S00_AXI_AWBURST
  .S00_AXI_AWLOCK(cl_axi_mstr_bus.awlock),              // input wire S00_AXI_AWLOCK
  .S00_AXI_AWCACHE(cl_axi_mstr_bus.awcache),            // input wire [3 : 0] S00_AXI_AWCACHE
  .S00_AXI_AWPROT(cl_axi_mstr_bus.awprot),              // input wire [2 : 0] S00_AXI_AWPROT
  .S00_AXI_AWQOS(cl_axi_mstr_bus.awqos),                // input wire [3 : 0] S00_AXI_AWQOS
  .S00_AXI_AWVALID(cl_axi_mstr_bus.awvalid),            // input wire S00_AXI_AWVALID
  .S00_AXI_AWREADY(cl_axi_mstr_bus.awready),            // output wire S00_AXI_AWREADY
  .S00_AXI_WDATA(cl_axi_mstr_bus.wdata),                // input wire [511 : 0] S00_AXI_WDATA
  .S00_AXI_WSTRB(cl_axi_mstr_bus.wstrb),                // input wire [63 : 0] S00_AXI_WSTRB
  .S00_AXI_WLAST(cl_axi_mstr_bus.wlast),                // input wire S00_AXI_WLAST
  .S00_AXI_WVALID(cl_axi_mstr_bus.wvalid),              // input wire S00_AXI_WVALID
  .S00_AXI_WREADY(cl_axi_mstr_bus.wready),              // output wire S00_AXI_WREADY
  .S00_AXI_BID(cl_axi_mstr_bus.bid),                    // output wire [7 : 0] S00_AXI_BID
  .S00_AXI_BRESP(cl_axi_mstr_bus.bresp),                // output wire [1 : 0] S00_AXI_BRESP
  .S00_AXI_BVALID(cl_axi_mstr_bus.bvalid),              // output wire S00_AXI_BVALID
  .S00_AXI_BREADY(cl_axi_mstr_bus.bready),              // input wire S00_AXI_BREADY
  .S00_AXI_ARID(cl_axi_mstr_bus.arid),                  // input wire [7 : 0] S00_AXI_ARID
  .S00_AXI_ARADDR(cl_axi_mstr_bus.araddr),              // input wire [63 : 0] S00_AXI_ARADDR
  .S00_AXI_ARLEN(cl_axi_mstr_bus.arlen),                // input wire [7 : 0] S00_AXI_ARLEN
  .S00_AXI_ARSIZE(cl_axi_mstr_bus.arsize),              // input wire [2 : 0] S00_AXI_ARSIZE
  .S00_AXI_ARBURST(cl_axi_mstr_bus.arburst),            // input wire [1 : 0] S00_AXI_ARBURST
  .S00_AXI_ARLOCK(cl_axi_mstr_bus.arlock),              // input wire S00_AXI_ARLOCK
  .S00_AXI_ARCACHE(cl_axi_mstr_bus.arcache),            // input wire [3 : 0] S00_AXI_ARCACHE
  .S00_AXI_ARPROT(cl_axi_mstr_bus.arprot),              // input wire [2 : 0] S00_AXI_ARPROT
  .S00_AXI_ARQOS(cl_axi_mstr_bus.arqos),                // input wire [3 : 0] S00_AXI_ARQOS
  .S00_AXI_ARVALID(cl_axi_mstr_bus.arvalid),            // input wire S00_AXI_ARVALID
  .S00_AXI_ARREADY(cl_axi_mstr_bus.arready),            // output wire S00_AXI_ARREADY
  .S00_AXI_RID(cl_axi_mstr_bus.rid),                    // output wire [7 : 0] S00_AXI_RID
  .S00_AXI_RDATA(cl_axi_mstr_bus.rdata),                // output wire [511 : 0] S00_AXI_RDATA
  .S00_AXI_RRESP(cl_axi_mstr_bus.rresp),                // output wire [1 : 0] S00_AXI_RRESP
  .S00_AXI_RLAST(cl_axi_mstr_bus.rlast),                // output wire S00_AXI_RLAST
  .S00_AXI_RVALID(cl_axi_mstr_bus.rvalid),              // output wire S00_AXI_RVALID
  .S00_AXI_RREADY(cl_axi_mstr_bus.rready),              // input wire S00_AXI_RREADY

  .S01_AXI_ARESET_OUT_N(),  // output wire S01_AXI_ARESET_OUT_N
  .S01_AXI_ACLK(aclk),                  // input wire S01_AXI_ACLK
  .S01_AXI_AWID(sh_cl_dma_pcis_awid),                  // input wire [7 : 0] S01_AXI_AWID
  .S01_AXI_AWADDR(sh_cl_dma_pcis_awaddr),              // input wire [63 : 0] S01_AXI_AWADDR
  .S01_AXI_AWLEN(sh_cl_dma_pcis_awlen),                // input wire [7 : 0] S01_AXI_AWLEN
  .S01_AXI_AWSIZE(sh_cl_dma_pcis_awsize),              // input wire [2 : 0] S01_AXI_AWSIZE
  .S01_AXI_AWBURST(2'b01),            // input wire [1 : 0] S01_AXI_AWBURST
  .S01_AXI_AWLOCK(1'b0),              // input wire S01_AXI_AWLOCK
  .S01_AXI_AWCACHE(4'b0011),            // input wire [3 : 0] S01_AXI_AWCACHE
  .S01_AXI_AWPROT(3'b0),              // input wire [2 : 0] S01_AXI_AWPROT
  .S01_AXI_AWQOS(4'b0),                // input wire [3 : 0] S01_AXI_AWQOS
  .S01_AXI_AWVALID(sh_cl_dma_pcis_awvalid),            // input wire S01_AXI_AWVALID
  .S01_AXI_AWREADY(cl_sh_dma_pcis_awready),            // output wire S01_AXI_AWREADY
  .S01_AXI_WDATA(sh_cl_dma_pcis_wdata),                // input wire [511 : 0] S01_AXI_WDATA
  .S01_AXI_WSTRB(sh_cl_dma_pcis_wstrb),                // input wire [63 : 0] S01_AXI_WSTRB
  .S01_AXI_WLAST(sh_cl_dma_pcis_wlast),                // input wire S01_AXI_WLAST
  .S01_AXI_WVALID(sh_cl_dma_pcis_wvalid),              // input wire S01_AXI_WVALID
  .S01_AXI_WREADY(cl_sh_dma_pcis_wready),              // output wire S01_AXI_WREADY
  .S01_AXI_BID(cl_sh_dma_pcis_bid),                    // output wire [7 : 0] S01_AXI_BID
  .S01_AXI_BRESP(cl_sh_dma_pcis_bresp),                // output wire [1 : 0] S01_AXI_BRESP
  .S01_AXI_BVALID(cl_sh_dma_pcis_bvalid),              // output wire S01_AXI_BVALID
  .S01_AXI_BREADY(sh_cl_dma_pcis_bready),              // input wire S01_AXI_BREADY
  .S01_AXI_ARID(sh_cl_dma_pcis_arid),                  // input wire [7 : 0] S01_AXI_ARID
  .S01_AXI_ARADDR(sh_cl_dma_pcis_araddr),              // input wire [63 : 0] S01_AXI_ARADDR
  .S01_AXI_ARLEN(sh_cl_dma_pcis_arlen),                // input wire [7 : 0] S01_AXI_ARLEN
  .S01_AXI_ARSIZE(sh_cl_dma_pcis_arsize),              // input wire [2 : 0] S01_AXI_ARSIZE
  .S01_AXI_ARBURST(2'b01),            // input wire [1 : 0] S01_AXI_ARBURST
  .S01_AXI_ARLOCK(1'b0),              // input wire S01_AXI_ARLOCK
  .S01_AXI_ARCACHE(4'b0011),            // input wire [3 : 0] S01_AXI_ARCACHE
  .S01_AXI_ARPROT(3'b0),              // input wire [2 : 0] S01_AXI_ARPROT
  .S01_AXI_ARQOS(4'b0),                // input wire [3 : 0] S01_AXI_ARQOS
  .S01_AXI_ARVALID(sh_cl_dma_pcis_arvalid),            // input wire S01_AXI_ARVALID
  .S01_AXI_ARREADY(cl_sh_dma_pcis_arready),            // output wire S01_AXI_ARREADY
  .S01_AXI_RID(cl_sh_dma_pcis_rid),                    // output wire [7 : 0] S01_AXI_RID
  .S01_AXI_RDATA(cl_sh_dma_pcis_rdata),                // output wire [511 : 0] S01_AXI_RDATA
  .S01_AXI_RRESP(cl_sh_dma_pcis_rresp),                // output wire [1 : 0] S01_AXI_RRESP
  .S01_AXI_RLAST(cl_sh_dma_pcis_rlast),                // output wire S01_AXI_RLAST
  .S01_AXI_RVALID(cl_sh_dma_pcis_rvalid),              // output wire S01_AXI_RVALID
  .S01_AXI_RREADY(sh_cl_dma_pcis_rready),              // input wire S01_AXI_RREADY

  .M00_AXI_ARESET_OUT_N(),  // output wire M00_AXI_ARESET_OUT_N
  .M00_AXI_ACLK(aclk),                        // input wire M00_AXI_ACLK
  .M00_AXI_AWID(cl_sh_ddr_awid),                  // input wire [7 : 0] M00_AXI_AWID
  .M00_AXI_AWADDR(cl_sh_ddr_awaddr),              // input wire [63 : 0] M00_AXI_AWADDR
  .M00_AXI_AWLEN(cl_sh_ddr_awlen),                // input wire [7 : 0] M00_AXI_AWLEN
  .M00_AXI_AWSIZE(cl_sh_ddr_awsize),              // input wire [2 : 0] M00_AXI_AWSIZE
  .M00_AXI_AWBURST(cl_sh_ddr_awburst),            // input wire [1 : 0] M00_AXI_AWBURST
  .M00_AXI_AWLOCK(),              // input wire M00_AXI_AWLOCK
  .M00_AXI_AWCACHE(),            // input wire [3 : 0] M00_AXI_AWCACHE
  .M00_AXI_AWPROT(),              // input wire [2 : 0] M00_AXI_AWPROT
  .M00_AXI_AWQOS(),                // input wire [3 : 0] M00_AXI_AWQOS
  .M00_AXI_AWVALID(cl_sh_ddr_awvalid),            // input wire M00_AXI_AWVALID
  .M00_AXI_AWREADY(sh_cl_ddr_awready),            // output wire M00_AXI_AWREADY
  .M00_AXI_WDATA(cl_sh_ddr_wdata),                // input wire [511 : 0] M00_AXI_WDATA
  .M00_AXI_WSTRB(cl_sh_ddr_wstrb),                // input wire [63 : 0] M00_AXI_WSTRB
  .M00_AXI_WLAST(cl_sh_ddr_wlast),                // input wire M00_AXI_WLAST
  .M00_AXI_WVALID(cl_sh_ddr_wvalid),              // input wire M00_AXI_WVALID
  .M00_AXI_WREADY(sh_cl_ddr_wready),              // output wire M00_AXI_WREADY
  .M00_AXI_BID(sh_cl_ddr_bid),                    // output wire [7 : 0] M00_AXI_BID
  .M00_AXI_BRESP(sh_cl_ddr_bresp),                // output wire [1 : 0] M00_AXI_BRESP
  .M00_AXI_BVALID(sh_cl_ddr_bvalid),              // output wire M00_AXI_BVALID
  .M00_AXI_BREADY(cl_sh_ddr_bready),              // input wire M00_AXI_BREADY
  .M00_AXI_ARID(cl_sh_ddr_arid),                  // input wire [7 : 0] M00_AXI_ARID
  .M00_AXI_ARADDR(cl_sh_ddr_araddr),              // input wire [63 : 0] M00_AXI_ARADDR
  .M00_AXI_ARLEN(cl_sh_ddr_arlen),                // input wire [7 : 0] M00_AXI_ARLEN
  .M00_AXI_ARSIZE(cl_sh_ddr_arsize),              // input wire [2 : 0] M00_AXI_ARSIZE
  .M00_AXI_ARBURST(cl_sh_ddr_arburst),            // input wire [1 : 0] M00_AXI_ARBURST
  .M00_AXI_ARLOCK(),              // input wire M00_AXI_ARLOCK
  .M00_AXI_ARCACHE(),            // input wire [3 : 0] M00_AXI_ARCACHE
  .M00_AXI_ARPROT(),              // input wire [2 : 0] M00_AXI_ARPROT
  .M00_AXI_ARQOS(),                // input wire [3 : 0] M00_AXI_ARQOS
  .M00_AXI_ARVALID(cl_sh_ddr_arvalid),            // input wire M00_AXI_ARVALID
  .M00_AXI_ARREADY(sh_cl_ddr_arready),            // output wire M00_AXI_ARREADY
  .M00_AXI_RID(sh_cl_ddr_rid),                    // output wire [7 : 0] M00_AXI_RID
  .M00_AXI_RDATA(sh_cl_ddr_rdata),                // output wire [511 : 0] M00_AXI_RDATA
  .M00_AXI_RRESP(sh_cl_ddr_rresp),                // output wire [1 : 0] M00_AXI_RRESP
  .M00_AXI_RLAST(sh_cl_ddr_rlast),                // output wire M00_AXI_RLAST
  .M00_AXI_RVALID(sh_cl_ddr_rvalid),              // output wire M00_AXI_RVALID
  .M00_AXI_RREADY(cl_sh_ddr_rready)               // input wire M00_AXI_RREADY
);

endmodule
