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

    logic [31:0] s_axi_awid = {cl_axi_mstr_q2.awid, sh_cl_dma_pcis_q2.awid};
    logic [127:0] s_axi_awaddr = {cl_axi_mstr_q2.awaddr, sh_cl_dma_pcis_q2.awaddr};
    logic [15:0] s_axi_awlen = {cl_axi_mstr_q2.awlen, sh_cl_dma_pcis_q2.awlen};
    logic [5:0] s_axi_awsize = {cl_axi_mstr_q2.awsize, sh_cl_dma_pcis_q2.awsize};
    logic [1:0] s_axi_awvalid = {cl_axi_mstr_q2.awvalid, sh_cl_dma_pcis_q2.awvalid};
    logic [1:0] s_axi_awready;

    logic [1023:0] s_axi_wdata = {cl_axi_mstr_q2.wdata, sh_cl_dma_pcis_q2.wdata};
    logic [127:0] s_axi_wstrb = {cl_axi_mstr_q2.wstrb, sh_cl_dma_pcis_q2.wstrb};
    logic [1:0] s_axi_wlast = {cl_axi_mstr_q2.wlast, sh_cl_dma_pcis_q2.wlast};
    logic [1:0] s_axi_wvalid = {cl_axi_mstr_q2.wvalid, sh_cl_dma_pcis_q2.wvalid};
    logic [1:0] s_axi_wready;

    logic [31:0]s_axi_bid;
    logic [3:0]s_axi_bresp;
    logic [1:0]s_axi_bvalid;
    logic [1:0] s_axi_bready = {cl_axi_mstr_q2.bready, sh_cl_dma_pcis_q2.bready};

    logic [31:0] s_axi_arid = {cl_axi_mstr_q2.arid, sh_cl_dma_pcis_q2.arid};
    logic [127:0] s_axi_araddr = {cl_axi_mstr_q2.araddr, sh_cl_dma_pcis_q2.araddr};
    logic [15:0] s_axi_arlen = {cl_axi_mstr_q2.arlen, sh_cl_dma_pcis_q2.arlen};
    logic [5:0] s_axi_arsize = {cl_axi_mstr_q2.arsize, sh_cl_dma_pcis_q2.arsize};
    logic [1:0] s_axi_arvalid = {cl_axi_mstr_q2.arvalid, sh_cl_dma_pcis_q2.arvalid};
    logic [1:0] s_axi_arready;

    logic [31:0] s_axi_rid;
    logic [1023:0] s_axi_rdata;
    logic [3:0] s_axi_rresp;
    logic [1:0] s_axi_rlast;
    logic [1:0] s_axi_rvalid;
    logic [1:0] s_axi_rready = {cl_axi_mstr_q2.rready, sh_cl_dma_pcis_q2.rready};

    assign cl_axi_mstr_q2.awready = s_axi_awready[1];
    assign cl_axi_mstr_q2.wready = s_axi_wready[1];
    assign cl_axi_mstr_q2.bid = s_axi_bid[31:16];
    assign cl_axi_mstr_q2.bresp = s_axi_bresp[3:2];
    assign cl_axi_mstr_q2.bvalid = s_axi_bvalid[1];
    assign cl_axi_mstr_q2.arready = s_axi_arready[1];
    assign cl_axi_mstr_q2.rid = s_axi_rid[31:16];
    assign cl_axi_mstr_q2.rdata = s_axi_rdata[1023:512];
    assign cl_axi_mstr_q2.rresp = s_axi_rresp[3:2];
    assign cl_axi_mstr_q2.rlast = s_axi_rlast[1];
    assign cl_axi_mstr_q2.rvalid = s_axi_rvalid[1];

    assign sh_cl_dma_pcis_q2.awready = s_axi_awready[0];
    assign sh_cl_dma_pcis_q2.wready = s_axi_wready[0];
    assign sh_cl_dma_pcis_q2.bid = s_axi_bid[15:0];
    assign sh_cl_dma_pcis_q2.bresp = s_axi_bresp[1:0];
    assign sh_cl_dma_pcis_q2.bvalid = s_axi_bvalid[0];
    assign sh_cl_dma_pcis_q2.arready = s_axi_arready[0];
    assign sh_cl_dma_pcis_q2.rid = s_axi_rid[15:0];
    assign sh_cl_dma_pcis_q2.rdata = s_axi_rdata[511:0];
    assign sh_cl_dma_pcis_q2.rresp = s_axi_rresp[1:0];
    assign sh_cl_dma_pcis_q2.rlast = s_axi_rlast[0];
    assign sh_cl_dma_pcis_q2.rvalid = s_axi_rvalid[0];


    axi_crossbar_0 axi_xbar (
          .aclk(aclk),                      // input wire aclk
          .aresetn(slr1_sync_aresetn),                // input wire aresetn

          .s_axi_awid(s_axi_awid),          // input wire [31 : 0] s_axi_awid
          .s_axi_awaddr(s_axi_awaddr),      // input wire [127 : 0] s_axi_awaddr
          .s_axi_awlen(s_axi_awlen),        // input wire [15 : 0] s_axi_awlen
          .s_axi_awsize(s_axi_awsize),      // input wire [5 : 0] s_axi_awsize
          .s_axi_awburst(4'b0101),    // input wire [3 : 0] s_axi_awburst
          .s_axi_awlock(2'b0),      // input wire [1 : 0] s_axi_awlock
          .s_axi_awcache(8'b00110011),    // input wire [7 : 0] s_axi_awcache
          .s_axi_awprot(6'b010010),      // input wire [5 : 0] s_axi_awprot
          .s_axi_awqos(8'b0),        // input wire [7 : 0] s_axi_awqos
          .s_axi_awvalid(s_axi_awvalid),    // input wire [1 : 0] s_axi_awvalid
          .s_axi_awready(s_axi_awready),    // output wire [1 : 0] s_axi_awready
          .s_axi_wdata(s_axi_wdata),        // input wire [1023 : 0] s_axi_wdata
          .s_axi_wstrb(s_axi_wstrb),        // input wire [127 : 0] s_axi_wstrb
          .s_axi_wlast(s_axi_wlast),        // input wire [1 : 0] s_axi_wlast
          .s_axi_wvalid(s_axi_wvalid),      // input wire [1 : 0] s_axi_wvalid
          .s_axi_wready(s_axi_wready),      // output wire [1 : 0] s_axi_wready
          .s_axi_bid(s_axi_bid),            // output wire [31 : 0] s_axi_bid
          .s_axi_bresp(s_axi_bresp),        // output wire [3 : 0] s_axi_bresp
          .s_axi_bvalid(s_axi_bvalid),      // output wire [1 : 0] s_axi_bvalid
          .s_axi_bready(s_axi_bready),      // input wire [1 : 0] s_axi_bready
          .s_axi_arid(s_axi_arid),          // input wire [31 : 0] s_axi_arid
          .s_axi_araddr(s_axi_araddr),      // input wire [127 : 0] s_axi_araddr
          .s_axi_arlen(s_axi_arlen),        // input wire [15 : 0] s_axi_arlen
          .s_axi_arsize(s_axi_arsize),      // input wire [5 : 0] s_axi_arsize
          .s_axi_arburst(4'b0101),    // input wire [3 : 0] s_axi_arburst
          .s_axi_arlock(2'b0),      // input wire [1 : 0] s_axi_arlock
          .s_axi_arcache(8'b00110011),    // input wire [7 : 0] s_axi_arcache
          .s_axi_arprot(6'b010010),      // input wire [5 : 0] s_axi_arprot
          .s_axi_arqos(8'b0),        // input wire [7 : 0] s_axi_arqos
          .s_axi_arvalid(s_axi_arvalid),    // input wire [1 : 0] s_axi_arvalid
          .s_axi_arready(s_axi_arready),    // output wire [1 : 0] s_axi_arready
          .s_axi_rid(s_axi_rid),            // output wire [31 : 0] s_axi_rid
          .s_axi_rdata(s_axi_rdata),        // output wire [1023 : 0] s_axi_rdata
          .s_axi_rresp(s_axi_rresp),        // output wire [3 : 0] s_axi_rresp
          .s_axi_rlast(s_axi_rlast),        // output wire [1 : 0] s_axi_rlast
          .s_axi_rvalid(s_axi_rvalid),      // output wire [1 : 0] s_axi_rvalid
          .s_axi_rready(s_axi_rready),      // input wire [1 : 0] s_axi_rready

          .m_axi_awid(cl_sh_ddr_q.awid),          // output wire [15 : 0] m_axi_awid
          .m_axi_awaddr(cl_sh_ddr_q.awaddr),      // output wire [63 : 0] m_axi_awaddr
          .m_axi_awlen(cl_sh_ddr_q.awlen),        // output wire [7 : 0] m_axi_awlen
          .m_axi_awsize(cl_sh_ddr_q.awsize),      // output wire [2 : 0] m_axi_awsize
          .m_axi_awburst(),    // output wire [1 : 0] m_axi_awburst
          .m_axi_awlock(),      // output wire [0 : 0] m_axi_awlock
          .m_axi_awcache(),    // output wire [3 : 0] m_axi_awcache
          .m_axi_awprot(),      // output wire [2 : 0] m_axi_awprot
          .m_axi_awregion(),  // output wire [3 : 0] m_axi_awregion
          .m_axi_awqos(),        // output wire [3 : 0] m_axi_awqos
          .m_axi_awvalid(cl_sh_ddr_q.awvalid),    // output wire [0 : 0] m_axi_awvalid
          .m_axi_awready(cl_sh_ddr_q.awready),    // input wire [0 : 0] m_axi_awready
          .m_axi_wdata(cl_sh_ddr_q.wdata),        // output wire [511 : 0] m_axi_wdata
          .m_axi_wstrb(cl_sh_ddr_q.wstrb),        // output wire [63 : 0] m_axi_wstrb
          .m_axi_wlast(cl_sh_ddr_q.wlast),        // output wire [0 : 0] m_axi_wlast
          .m_axi_wvalid(cl_sh_ddr_q.wvalid),      // output wire [0 : 0] m_axi_wvalid
          .m_axi_wready(cl_sh_ddr_q.wready),      // input wire [0 : 0] m_axi_wready
          .m_axi_bid(cl_sh_ddr_q.bid),            // input wire [15 : 0] m_axi_bid
          .m_axi_bresp(cl_sh_ddr_q.bresp),        // input wire [1 : 0] m_axi_bresp
          .m_axi_bvalid(cl_sh_ddr_q.bvalid),      // input wire [0 : 0] m_axi_bvalid
          .m_axi_bready(cl_sh_ddr_q.bready),      // output wire [0 : 0] m_axi_bready
          .m_axi_arid(cl_sh_ddr_q.arid),          // output wire [15 : 0] m_axi_arid
          .m_axi_araddr(cl_sh_ddr_q.araddr),      // output wire [63 : 0] m_axi_araddr
          .m_axi_arlen(cl_sh_ddr_q.arlen),        // output wire [7 : 0] m_axi_arlen
          .m_axi_arsize(cl_sh_ddr_q.arsize),      // output wire [2 : 0] m_axi_arsize
          .m_axi_arburst(),    // output wire [1 : 0] m_axi_arburst
          .m_axi_arlock(),      // output wire [0 : 0] m_axi_arlock
          .m_axi_arcache(),    // output wire [3 : 0] m_axi_arcache
          .m_axi_arprot(),      // output wire [2 : 0] m_axi_arprot
          .m_axi_arregion(),  // output wire [3 : 0] m_axi_arregion
          .m_axi_arqos(),        // output wire [3 : 0] m_axi_arqos
          .m_axi_arvalid(cl_sh_ddr_q.arvalid),    // output wire [0 : 0] m_axi_arvalid
          .m_axi_arready(cl_sh_ddr_q.arready),    // input wire [0 : 0] m_axi_arready
          .m_axi_rid(cl_sh_ddr_q.rid),            // input wire [15 : 0] m_axi_rid
          .m_axi_rdata(cl_sh_ddr_q.rdata),        // input wire [511 : 0] m_axi_rdata
          .m_axi_rresp(cl_sh_ddr_q.rresp),        // input wire [1 : 0] m_axi_rresp
          .m_axi_rlast(cl_sh_ddr_q.rlast),        // input wire [0 : 0] m_axi_rlast
          .m_axi_rvalid(cl_sh_ddr_q.rvalid),      // input wire [0 : 0] m_axi_rvalid
          .m_axi_rready(cl_sh_ddr_q.rready)      // output wire [0 : 0] m_axi_rready
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


endmodule
