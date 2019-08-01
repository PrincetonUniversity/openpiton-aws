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

// Filename: aws_uart.v
// Author: gchirkov
// Description: AXI4-UART interface to access from AWS host

module piton_aws_eth
(   
  input clk,
  input sync_rst_n,

  // AXILite slave interface

    //Write address
    input s_awvalid,
    input[31:0] s_awaddr,
    output s_awready,
                                                                                                                               
    //Write data                                                                                                                
    input s_wvalid,
    input[31:0] s_wdata,
    input[3:0] s_wstrb,
    output s_wready,
                                                                                                                               
    //Write response                                                                                                            
    output s_bvalid,
    output [1:0] s_bresp,
    input s_bready,
                                                                                                                               
    //Read address                                                                                                              
    input s_arvalid,
    input[31:0] s_araddr,
    output s_arready,
                                                                                                                               
    //Read data/response                                                                                                        
    output s_rvalid,
    output [31:0] s_rdata,
    output [1:0] s_rresp,
    input  s_rready,

    input eth_clk, 
    output eth_tx_val,
    output [3:0] eth_tx_data,
    input eth_rx_val,
    input [3:0] eth_rx_data
);

//-------------------------------------------------
// Flop interface
//-------------------------------------------------

  // Write address                                                                                                              
  wire        s_awvalid_q;
  wire [31:0] s_awaddr_q;
  wire        s_awready_q;
                                                                                                                              
  // Write data                                                                                                                
  wire        s_wvalid_q;
  wire [31:0] s_wdata_q;
  wire [ 3:0] s_wstrb_q;
  wire        s_wready_q;
                                                                                                                              
  // Write response                                                                                                            
  wire        s_bvalid_q;
  wire [ 1:0] s_bresp_q;
  wire        s_bready_q;
                                                                                                                              
  // Read address                                                                                                              
  wire        s_arvalid_q;
  wire [31:0] s_araddr_q;
  wire        s_arready_q;
                                                                                                                              
  // Read data/response                                                                                                        
  wire        s_rvalid_q;
  wire [31:0] s_rdata_q;
  wire [ 1:0] s_rresp_q;
  wire        s_rready_q;

  axi_register_slice_light axil_ocl_reg_slc (
    .aclk          (clk),
    .aresetn       (sync_rst_n),
    .s_axi_awaddr  (s_awaddr),
    .s_axi_awvalid (s_awvalid),
    .s_axi_awready (s_awready),
    .s_axi_wdata   (s_wdata),
    .s_axi_wstrb   (s_wstrb),
    .s_axi_wvalid  (s_wvalid),
    .s_axi_wready  (s_wready),
    .s_axi_bresp   (s_bresp),
    .s_axi_bvalid  (s_bvalid),
    .s_axi_bready  (s_bready),
    .s_axi_araddr  (s_araddr),
    .s_axi_arvalid (s_arvalid),
    .s_axi_arready (s_arready),
    .s_axi_rdata   (s_rdata),
    .s_axi_rresp   (s_rresp),
    .s_axi_rvalid  (s_rvalid),
    .s_axi_rready  (s_rready),
   
    .m_axi_awaddr  (s_awaddr_q),
    .m_axi_awprot  (),
    .m_axi_awvalid (s_awvalid_q),
    .m_axi_awready (s_awready_q),
    .m_axi_wdata   (s_wdata_q),
    .m_axi_wstrb   (s_wstrb_q),
    .m_axi_wvalid  (s_wvalid_q),
    .m_axi_wready  (s_wready_q),
    .m_axi_bresp   (s_bresp_q),
    .m_axi_bvalid  (s_bvalid_q),
    .m_axi_bready  (s_bready_q),
    .m_axi_araddr  (s_araddr_q),
    .m_axi_arvalid (s_arvalid_q),
    .m_axi_arready (s_arready_q),
    .m_axi_rdata   (s_rdata_q),
    .m_axi_rresp   (s_rresp_q),
    .m_axi_rvalid  (s_rvalid_q),
    .m_axi_rready  (s_rready_q)
  );




mac_eth_axi_lite aws_mac_eth_axi_lite (
  .s_axi_aclk       (clk),       // input wire s_axi_aclk
  .s_axi_aresetn    (sync_rst_n),    // input wire s_axi_aresetn
  .ip2intc_irpt     (),     // output wire ip2intc_irpt

  .s_axi_awaddr     (s_awaddr_q[12:0]),     // input wire [12 : 0] s_axi_awaddr
  .s_axi_awvalid    (s_awvalid_q),    // input wire s_axi_awvalid
  .s_axi_awready    (s_awready_q),    // output wire s_axi_awready

  .s_axi_wdata      (s_wdata_q),      // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb      (s_wstrb_q),      // input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid     (s_wvalid_q),     // input wire s_axi_wvalid
  .s_axi_wready     (s_wready_q),     // output wire s_axi_wready

  .s_axi_bresp      (s_bresp_q),      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid     (s_bvalid_q),     // output wire s_axi_bvalid
  .s_axi_bready     (s_bready_q),     // input wire s_axi_bready

  .s_axi_araddr     (s_araddr_q[12:0]),     // input wire [12 : 0] s_axi_araddr
  .s_axi_arvalid    (s_arvalid_q),    // input wire s_axi_arvalid
  .s_axi_arready    (s_arready_q),    // output wire s_axi_arready

  .s_axi_rdata      (s_rdata_q),      // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp      (s_rresp_q),      // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid     (s_rvalid_q),     // output wire s_axi_rvalid
  .s_axi_rready     (s_rready_q),     // input wire s_axi_rready


  .phy_rst_n        (),                     // output wire phy_rst_n

  .phy_tx_clk       (eth_clk),       // input wire phy_tx_clk
  .phy_tx_en        (eth_tx_val),        // output wire phy_tx_en
  .phy_tx_data      (eth_tx_data),      // output wire [3 : 0] phy_tx_data

  .phy_rx_clk       (eth_clk),       // input wire phy_rx_clk
  .phy_dv           (eth_rx_val),           // input wire phy_dv
  .phy_rx_data      (eth_rx_data),      // input wire [3 : 0] phy_rx_data
  .phy_rx_er        (1'b0),                 // input wire phy_rx_er

  .phy_crs          (1'b0),                 // input wire phy_crs
  .phy_col          (1'b0)                  // input wire phy_col
);

endmodule
