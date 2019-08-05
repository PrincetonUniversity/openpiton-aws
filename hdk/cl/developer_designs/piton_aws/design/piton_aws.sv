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

module piton_aws
(
	`include "cl_ports.vh"
);

`include "cl_id_defines.vh"          // Defines for ID0 and ID1 (PCI ID's)
`include "piton_aws_defines.vh"

// TIE OFF ALL UNUSED INTERFACES
// Including all the unused interface to tie off

`include "unused_apppf_irq_template.inc"
`include "unused_cl_sda_template.inc"
`include "unused_pcim_template.inc"
`include "unused_flr_template.inc"
`include "unused_ddr_a_b_d_template.inc"
`include "unused_sh_bar1_template.inc"


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
//////////////////////////// clocks ///////////////////////////////////
///////////////////////////////////////////////////////////////////////

    logic shell_clk;
    logic piton_clk;

    assign shell_clk = clk_main_a0; //125 mhz, recipe A0 OR 250 mhz, recipe A1
    assign piton_clk = clk_extra_b1; //62.5 mhz, recipe B1 OR 125 mhz, recipe B0 OR 100 mhz, recipe B5

///////////////////////////////////////////////////////////////////////
//////////////////////////// clocks ///////////////////////////////////
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
//////////////////////////// resets ///////////////////////////////////
///////////////////////////////////////////////////////////////////////


    (* dont_touch = "true" *) logic pipe_piton_rst_n;
    logic pre_piton_rst_n;
    logic piton_rst_n;

    lib_pipe #(.WIDTH(1), .STAGES(4)) PIPE_piton_rst_n (.clk(shell_clk), .rst_n(1'b1), .in_bus(sh_cl_status_vdip[15]), .out_bus(pipe_piton_rst_n));

    always_ff @(negedge pipe_piton_rst_n or posedge piton_clk)
       if (!pipe_piton_rst_n)
       begin
          pre_piton_rst_n <= 0;
          piton_rst_n <= 0;
       end
       else
       begin
          pre_piton_rst_n <= 1;
          piton_rst_n <= pre_piton_rst_n;
       end


    (* dont_touch = "true" *) logic pipe_shell_rst_n;
    logic pre_shell_rst_n;
    logic shell_rst_n;

    lib_pipe #(.WIDTH(1), .STAGES(4)) PIPE_shell_rst_n (.clk(shell_clk), .rst_n(1'b1), .in_bus(rst_main_n), .out_bus(pipe_shell_rst_n));

    always_ff @(negedge pipe_shell_rst_n or posedge shell_clk)
       if (!pipe_shell_rst_n)
       begin
          pre_shell_rst_n <= 0;
          shell_rst_n <= 0;
       end
       else
       begin
          pre_shell_rst_n <= 1;
          shell_rst_n <= pre_shell_rst_n;
       end


///////////////////////////////////////////////////////////////////////
//////////////////////////// resets ///////////////////////////////////
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
////////////////////// leds and switches //////////////////////////////
///////////////////////////////////////////////////////////////////////

    logic [15:0] sw;
    logic [15:0] sw_q;
    logic [15:0] sw_q_q;
    logic [15:0] leds;
    logic [15:0] leds_q;
    logic [15:0] leds_q_q;

    always_ff @(posedge piton_clk)
       if (!piton_rst_n)
       begin
          sw_q <= 0;
          sw_q_q <= 0;
       end
       else
       begin
          sw_q <= sh_cl_status_vdip;
          sw_q_q <= sw_q;
       end

    always_ff @(posedge shell_clk)
       if (!shell_rst_n)
       begin
          leds_q <= 0;
          leds_q_q <= 0;
       end
       else
       begin
          leds_q <= leds;
          leds_q_q <= leds_q;
       end

    assign sw = sw_q_q;
    assign cl_sh_status_vled = leds_q_q; 
 


///////////////////////////////////////////////////////////////////////
////////////////////// leds and switches //////////////////////////////
///////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////
/////////////////////////// piton /////////////////////////////////////
///////////////////////////////////////////////////////////////////////

    // For uart
    `ifdef PITONSYS_UART
        logic piton_uart_tx;
        logic piton_uart_rx;
        `ifdef PITONSYS_UART2
            logic piton_uart_tx2;
            logic piton_uart_rx2;
        `endif
    `endif

    `ifndef PITONSYS_NO_MC
    // for ddr
    axi_bus_t piton_mem_bus();
    logic ddr_ready_piton;
    `endif

    (* dont_touch = "true" *) logic sys_sync_rst_n;
    lib_pipe #(.WIDTH(1), .STAGES(4)) sys_slc_rst_n (.clk(piton_clk), .rst_n(1'b1), .in_bus(piton_rst_n), .out_bus(sys_sync_rst_n));

    system system(
        // Clocks and resets
        .sys_clk(piton_clk),
        .sys_rst_n(sys_sync_rst_n),

    `ifndef PITONSYS_NO_MC
        .mc_clk(shell_clk),
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

        .ddr_ready(ddr_ready_piton),
    `endif

    `ifdef PITONSYS_UART
        .uart_tx(piton_uart_tx),
        .uart_rx(piton_uart_rx),
        `ifdef PITONSYS_UART2
            .uart_tx2(piton_uart_tx2),
            .uart_rx2(piton_uart_rx2)
        `endif
    `endif

        .sw(sw[7:0]), 
        .leds(leds[7:0]) 

    );
    assign leds[15:8] = 0;

///////////////////////////////////////////////////////////////////////
/////////////////////////// piton /////////////////////////////////////
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
/////////////////////////// mem subsystem /////////////////////////////
///////////////////////////////////////////////////////////////////////
    `ifndef PITONSYS_NO_MC

        logic ddr_ready_shell;

        (* dont_touch = "true" *) logic piton_aws_xbar_sync_rst_n;
        lib_pipe #(.WIDTH(1), .STAGES(4)) piton_aws_xbar_slc_rst_n (.clk(shell_clk), .rst_n(1'b1), .in_bus(shell_rst_n), .out_bus(piton_aws_xbar_sync_rst_n));

        logic ddr_ready_q;
        logic ddr_ready_q_q;
        always_ff @(posedge piton_clk)
            if (!piton_rst_n)
            begin
              ddr_ready_q <= 0;
              ddr_ready_q_q <= 0;
            end
            else
            begin
              ddr_ready_q <= ddr_ready_shell;
              ddr_ready_q_q <= ddr_ready_q;
            end
        assign ddr_ready_piton = ddr_ready_q_q;
        assign ddr_ready_shell = sh_cl_ddr_is_ready;

        axi_bus_t shell_mem_bus();
        piton_aws_addr_translator piton_aws_addr_translator(
            .in(piton_mem_bus),
            .out(shell_mem_bus)
        );

        piton_aws_xbar piton_aws_xbar(
            .aclk                  (shell_clk),
            .aresetn               (piton_aws_xbar_sync_rst_n),

            .cl_axi_mstr_bus       (shell_mem_bus),

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
            .sh_cl_dma_pcis_rready (sh_cl_dma_pcis_rready),

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
            .cl_sh_ddr_rready      (cl_sh_ddr_rready)

        );
    `else 
        `include "unused_ddr_c_template.inc"
        `include "unused_dma_pcis_template.inc"
    `endif


///////////////////////////////////////////////////////////////////////
/////////////////////////// mem subsystem//////////////////////////////
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
///////////////// aws uart module /////////////////////////////////////
///////////////////////////////////////////////////////////////////////
    
    `ifdef PITONSYS_UART
        logic shell_uart_tx;
        logic shell_uart_rx;

        assign shell_uart_rx = piton_uart_tx;
        assign piton_uart_rx = shell_uart_tx;

        (* dont_touch = "true" *) logic aws_uart_sync_rst_n;
        lib_pipe #(.WIDTH(1), .STAGES(4)) aws_uart_slc_rst_n (.clk(shell_clk), .rst_n(1'b1), .in_bus(shell_rst_n), .out_bus(aws_uart_sync_rst_n));
        piton_aws_uart piton_aws_uart (

            .clk(shell_clk),
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
            .rx(shell_uart_rx),
            .tx(shell_uart_tx)
        );
        
        `ifdef PITONSYS_UART2
            logic shell_uart_tx2;
            logic shell_uart_rx2;

            assign shell_uart_rx2 = piton_uart_tx2;
            assign piton_uart_rx2 = shell_uart_tx2;

            piton_aws_uart piton_aws_uart2 (

                .clk(shell_clk),
                .sync_rst_n(aws_uart_sync_rst_n),

                // AXILite slave interface

                //Write address
                .s_awvalid(sh_bar1_awvalid),
                .s_awaddr(sh_bar1_awaddr),
                .s_awready(bar1_sh_awready),
                                                                                                                                   
                //Write data                                                                                                                
                .s_wvalid(sh_bar1_wvalid),
                .s_wdata(sh_bar1_wdata),
                .s_wstrb(sh_bar1_wstrb),
                .s_wready(bar1_sh_wready),
                                                                                                                                   
                //Write response                                                                                                            
                .s_bvalid(bar1_sh_bvalid),
                .s_bresp(bar1_sh_bresp),
                .s_bready(sh_bar1_bready),
                                                                                                                                   
                //Read address                                                                                                              
                .s_arvalid(sh_bar1_arvalid),
                .s_araddr(sh_bar1_araddr),
                .s_arready(bar1_sh_arready),
                                                                                                                                   
                //Read data/response                                                                                                        
                .s_rvalid(bar1_sh_rvalid),
                .s_rdata(bar1_sh_rdata),
                .s_rresp(bar1_sh_rresp),
                .s_rready(sh_bar1_rready),

                // UART interface
                .rx(shell_uart_rx2),
                .tx(shell_uart_tx2)
            );

        `endif

    `else // PITONSYS_UART
        `include "unused_sh_ocl_template.inc"
    `endif

///////////////////////////////////////////////////////////////////////
///////////////// aws uart module /////////////////////////////////////
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
///////////////// Debug dridge ////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
/*
    cl_debug_bridge CL_DEBUG_BRIDGE (
        .clk(shell_clk),
        .S_BSCAN_drck(drck),
        .S_BSCAN_shift(shift),
        .S_BSCAN_tdi(tdi),
        .S_BSCAN_update(update),
        .S_BSCAN_sel(sel),
        .S_BSCAN_tdo(tdo),
        .S_BSCAN_tms(tms),
        .S_BSCAN_tck(tck),
        .S_BSCAN_runtest(runtest),
        .S_BSCAN_reset(reset),
        .S_BSCAN_capture(capture),
        .S_BSCAN_bscanid_en(bscanid_en)
    );
*/
///////////////////////////////////////////////////////////////////////
///////////////// Debug dridge ////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

endmodule // aws_shell
