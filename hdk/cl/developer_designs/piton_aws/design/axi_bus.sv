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

`ifndef AXI_BUS
`define AXI_BUS

`include "noc_axi4_bridge_define.vh"
 
   interface axi_bus_t;
      logic[`AXI4_ID_WIDTH-1:0]     awid;
      logic[`AXI4_ADDR_WIDTH-1:0]   awaddr;
      logic[`AXI4_LEN_WIDTH-1:0]    awlen;
      logic[`AXI4_SIZE_WIDTH-1:0]   awsize;
      logic[`AXI4_BURST_WIDTH-1:0]  awburst;
      logic                         awlock;
      logic[`AXI4_CACHE_WIDTH-1:0]  awcache;
      logic[`AXI4_PROT_WIDTH-1:0]   awprot;
      logic[`AXI4_QOS_WIDTH-1:0]    awqos;
      logic[`AXI4_REGION_WIDTH-1:0] awregion;
      logic[`AXI4_USER_WIDTH-1:0]   awuser;
      logic                         awvalid;
      logic                         awready;
   
      logic[`AXI4_ID_WIDTH-1:0]     wid;
      logic[`AXI4_DATA_WIDTH-1:0]   wdata;
      logic[`AXI4_STRB_WIDTH-1:0]   wstrb;
      logic                         wlast;
      logic[`AXI4_USER_WIDTH-1:0]   wuser;
      logic                         wvalid;
      logic                         wready;
         
      logic[`AXI4_ID_WIDTH-1:0]     bid;
      logic[`AXI4_RESP_WIDTH-1:0]   bresp;
      logic[`AXI4_USER_WIDTH-1:0]   buser;
      logic                         bvalid;
      logic                         bready;
         
      logic[`AXI4_ID_WIDTH-1:0]     arid;
      logic[`AXI4_ADDR_WIDTH-1:0]   araddr;
      logic[`AXI4_LEN_WIDTH-1:0]    arlen;
      logic[`AXI4_SIZE_WIDTH-1:0]   arsize;
      logic[`AXI4_BURST_WIDTH-1:0]  arburst;
      logic                         arlock;
      logic[`AXI4_CACHE_WIDTH-1:0]  arcache;
      logic[`AXI4_PROT_WIDTH-1:0]   arprot;
      logic[`AXI4_QOS_WIDTH-1:0]    arqos;
      logic[`AXI4_REGION_WIDTH-1:0] arregion;
      logic[`AXI4_USER_WIDTH-1:0]   aruser;
      logic                         arvalid;
      logic                         arready;
         
      logic[`AXI4_ID_WIDTH-1:0]     rid;
      logic[`AXI4_DATA_WIDTH-1:0]   rdata;
      logic[`AXI4_RESP_WIDTH-1:0]   rresp;
      logic                         rlast;
      logic[`AXI4_USER_WIDTH-1:0]   ruser;
      logic                         rvalid;
      logic                         rready;

      modport master (input awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion, awuser, awvalid, output awready,
                      input wid, wdata, wstrb, wlast, wuser, wvalid, output wready,
                      output bid, bresp, buser, bvalid, input bready,
                      input arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, aruser, arvalid, output arready,
                      output rid, rdata, rresp, rlast, ruser, rvalid, input rready);

      modport slave (output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion, awuser, awvalid, input awready,
                output wid, wdata, wstrb, wlast, wuser, wvalid, input wready,
                input bid, bresp, buser, bvalid, output bready,
                output arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, aruser, arvalid, input arready,
                input rid, rdata, rresp, rlast, ruser, rvalid, output rready);

   endinterface

`endif //AXI_BUS
