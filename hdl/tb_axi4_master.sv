`timescale 1ns / 1ps
//`include "axi4_master_v1_0_tb_include.svh"

import axi_vip_pkg::*;
import bd_axi_vip_0_0_pkg::*;

module tb_axi4_master();

parameter P_TARGET_SLAVE_BASE_ADDR = 32'h10000000;
parameter integer P_BURST_LEN    = 16;
parameter integer P_ID_WIDTH     = 1;
parameter integer P_ADDR_WIDTH   = 32;
parameter integer P_DATA_WIDTH   = 32;
parameter integer P_AWUSER_WIDTH = 1;
parameter integer P_ARUSER_WIDTH = 1;
parameter integer P_WUSER_WIDTH  = 1;
parameter integer P_RUSER_WIDTH  = 1;
parameter integer P_BUSER_WIDTH  = 1;

bit                      tb_clock;
bit                      tb_reset;
xil_axi_uint             error_cnt = 0;
xil_axi_uint             comparison_cnt = 0;
axi_transaction          wr_transaction;   
axi_transaction          rd_transaction;   
axi_monitor_transaction  mst_monitor_transaction;  
axi_monitor_transaction  master_moniter_transaction_queue[$];  
xil_axi_uint             master_moniter_transaction_queue_size =0;  
axi_monitor_transaction  mst_scb_transaction;  
axi_monitor_transaction  passthrough_monitor_transaction;  
axi_monitor_transaction  passthrough_master_moniter_transaction_queue[$];  
xil_axi_uint             passthrough_master_moniter_transaction_queue_size =0;  
axi_monitor_transaction  passthrough_mst_scb_transaction;  
axi_monitor_transaction  passthrough_slave_moniter_transaction_queue[$];  
xil_axi_uint             passthrough_slave_moniter_transaction_queue_size =0;  
axi_monitor_transaction  passthrough_slv_scb_transaction;  
axi_monitor_transaction  slv_monitor_transaction;  
axi_monitor_transaction  slave_moniter_transaction_queue[$];  
xil_axi_uint             slave_moniter_transaction_queue_size =0;  
axi_monitor_transaction  slv_scb_transaction;  
xil_axi_uint             mst_agent_verbosity = 0;  
xil_axi_uint             slv_agent_verbosity = 0;  
xil_axi_uint             passthrough_agent_verbosity = 0;  
xil_axi_ulong            mem_rd_addr;
xil_axi_ulong            mem_wr_addr;
bit [P_DATA_WIDTH-1:0]   write_data;
bit                      write_strb[];
bit [P_DATA_WIDTH-1:0]   read_data;
bit                      tb_init;
bit                      tb_done;
bit                      tb_error;
bit                      tb_asserted;
bit [159:0]              tb_status;

reg [P_ID_WIDTH - 1:0] tb_awid;
reg [P_ADDR_WIDTH - 1:0] tb_awaddr;
reg [P_DATA_WIDTH - 1:0] tb_wdata;
reg [P_DATA_WIDTH/8-1:0] tb_wstrb;
reg [1:0] tb_awburst;
reg [2:0] tb_awsize;
reg [3:0] tb_awcache;
reg [7:0] tb_awlen;
reg [0:0] tb_awlock;
reg [2:0] tb_awprot;
reg [3:0] tb_awqos;
reg tb_awvalid;
reg tb_wvalid;
reg tb_wlast;
wire tb_awready;
wire tb_wready;

reg tb_bready;  
wire [P_ID_WIDTH - 1:0] tb_bid;
wire [1:0] tb_bresp;
wire tb_bvalid;

reg tb_arvalid;
reg [P_ADDR_WIDTH - 1:0] tb_araddr;
reg [1:0] tb_arburst;
reg [2:0] tb_arsize;
reg [3:0] tb_arcache;
reg [0:0] tb_arid;
reg [7:0] tb_arlen;
reg [0:0] tb_arlock;
reg [2:0] tb_arprot;
reg [3:0] tb_arqos;

wire tb_arready;
wire [P_DATA_WIDTH-1:0] tb_rdata;
wire [P_ID_WIDTH - 1:0] tb_rid;
wire tb_rlast;
reg tb_rready;
wire [1:0] tb_rresp;
wire tb_rvalid;

reg [P_AWUSER_WIDTH-1:0] tb_awuser;
reg [P_WUSER_WIDTH-1:0] tb_wuser;
reg [P_ARUSER_WIDTH-1:0] tb_aruser;
wire [P_RUSER_WIDTH-1:0] tb_ruser;
wire [P_BUSER_WIDTH-1:0] tb_buser;

bd_axi_vip_0_0_slv_mem_t slv_agent_0;

axi4_master_v1_0_M00_AXI #
(
    .C_M_TARGET_SLAVE_BASE_ADDR(P_TARGET_SLAVE_BASE_ADDR),
    .C_M_AXI_BURST_LEN(P_BURST_LEN),
    .C_M_AXI_ID_WIDTH(P_ID_WIDTH),
	.C_M_AXI_ADDR_WIDTH(P_ADDR_WIDTH),
    .C_M_AXI_DATA_WIDTH(P_DATA_WIDTH),
    .C_M_AXI_AWUSER_WIDTH(P_AWUSER_WIDTH),
    .C_M_AXI_ARUSER_WIDTH(P_ARUSER_WIDTH),
    .C_M_AXI_WUSER_WIDTH(P_WUSER_WIDTH),
    .C_M_AXI_RUSER_WIDTH(P_RUSER_WIDTH),
    .C_M_AXI_BUSER_WIDTH(P_BUSER_WIDTH)
)
axi4_master_i
(
    .INIT_AXI_TXN(tb_init),
    .TXN_DONE(tb_done),
    .ERROR(tb_error),
    
    .M_AXI_ACLK(tb_clock),
    .M_AXI_ARESETN(tb_reset),
    
    .M_AXI_AWID(tb_awid),
    .M_AXI_AWADDR(tb_awaddr),
    .M_AXI_AWLEN(tb_awlen),
    .M_AXI_AWSIZE(tb_awsize),
    .M_AXI_AWBURST(tb_awburst),
    .M_AXI_AWLOCK(tb_awlock),
    .M_AXI_AWCACHE(tb_awcache),
    .M_AXI_AWPROT(tb_awprot),
    .M_AXI_AWQOS(tb_awqos),
    .M_AXI_AWUSER(tb_awuser),
    .M_AXI_AWVALID(tb_awvalid),
    .M_AXI_AWREADY(tb_awready),
    .M_AXI_WDATA(tb_wdata),
    .M_AXI_WSTRB(tb_wstrb),
    .M_AXI_WLAST(tb_wlast),
    .M_AXI_WUSER(tb_wuser),
    .M_AXI_WVALID(tb_wvalid),
    .M_AXI_WREADY(tb_wready),
    .M_AXI_BID(tb_bid),
    .M_AXI_BRESP(tb_bresp),
    .M_AXI_BUSER(tb_buser),
    .M_AXI_BVALID(tb_bvalid),
    .M_AXI_BREADY(tb_bready),
    .M_AXI_ARID(tb_arid),
    .M_AXI_ARADDR(tb_araddr),
    .M_AXI_ARLEN(tb_arlen),
    .M_AXI_ARSIZE(tb_arsize),
    .M_AXI_ARBURST(tb_arburst),
    .M_AXI_ARLOCK(tb_arlock),
    .M_AXI_ARCACHE(tb_arcache),
    .M_AXI_ARPROT(tb_arprot),
    .M_AXI_ARQOS(tb_arqos),
    .M_AXI_ARUSER(tb_aruser),
    .M_AXI_ARVALID(tb_arvalid),
    .M_AXI_ARREADY(tb_arready),
    .M_AXI_RID(tb_rid),
    .M_AXI_RDATA(tb_rdata),
    .M_AXI_RRESP(tb_rresp),
    .M_AXI_RLAST(tb_rlast),
    .M_AXI_RUSER(tb_ruser),
    .M_AXI_RVALID(tb_rvalid),
    .M_AXI_RREADY(tb_rready)
);

bd_wrapper BD_WRAPPER
(
    .CLOCK(tb_clock),
    .RESET(tb_reset),
    .S_AXI_araddr(tb_araddr),
    .S_AXI_arburst(tb_arburst),
    .S_AXI_arcache(tb_arcache),
    .S_AXI_arid(tb_arid),
    .S_AXI_arlen(tb_arlen),
    .S_AXI_arlock(tb_arlock),
    .S_AXI_arprot(tb_arprot),
    .S_AXI_arqos(tb_arqos),
    .S_AXI_arready(tb_arready),
    //.S_AXI_aruser(tb_aruser),
    .S_AXI_arvalid(tb_arvalid),
    .S_AXI_awaddr(tb_awaddr),
    .S_AXI_awburst(tb_awburst),
    .S_AXI_awcache(tb_awcache),
    .S_AXI_awid(tb_awid),
    .S_AXI_awlen(tb_awlen),
    .S_AXI_awlock(tb_awlock),
    .S_AXI_awprot(tb_awprot),
    .S_AXI_awqos(tb_awqos),
    .S_AXI_awready(tb_awready),
    //.S_AXI_awuser(tb_awuser),
    .S_AXI_awvalid(tb_awvalid),
    .S_AXI_bid(tb_bid),
    .S_AXI_bready(tb_bready),
    .S_AXI_bresp(tb_bresp),
    //.S_AXI_buser(tb_buser),
    .S_AXI_bvalid(tb_bvalid),
    .S_AXI_rdata(tb_rdata),
    .S_AXI_rid(tb_rid),
    .S_AXI_rlast(tb_rlast),
    .S_AXI_rready(tb_rready),
    .S_AXI_rresp(tb_rresp),
    //.S_AXI_ruser(tb_ruser),
    .S_AXI_rvalid(tb_rvalid),
    .S_AXI_wdata(tb_wdata),
    .S_AXI_wlast(tb_wlast),
    .S_AXI_wready(tb_wready),
    .S_AXI_wstrb(tb_wstrb),
    //.S_AXI_wuser(tb_wuser),
    .S_AXI_wvalid(tb_wvalid),    
    .PC_ASSERTED(tb_asserted),
    .PC_STATUS(tb_status)
); 
  
initial begin
    slv_agent_0 = new("slave vip agent",BD_WRAPPER.bd_i.axi_vip_0.inst.IF);
    slv_agent_0.vif_proxy.set_dummy_drive_type(XIL_AXI_VIF_DRIVE_NONE);
    slv_agent_0.set_agent_tag("Slave VIP");
    slv_agent_0.set_verbosity(slv_agent_verbosity);
    slv_agent_0.start_slave();
    $timeformat (-12, 1, " ps", 1);
end

initial begin
    tb_reset = 0;
    #200ns;
    tb_reset = 1;
    repeat (5) @(negedge tb_clock); 
end

initial begin
    tb_init = 0;
    #300ns;
    tb_init = 1;
    #20ns;
    tb_init = 0;
    $display("EXAMPLE TEST M00_AXI:");
    wait (tb_done == 1'b1);
    $display("M00_AXI: PTGEN_TEST_FINISHED!");
    if (tb_error) begin
        $display("PTGEN_TEST: FAILED!");
    end else begin
        $display("PTGEN_TEST: PASSED!");
    end
    #100ns;
    $finish;
end

initial begin
    #1;
    forever begin
        slv_agent_0.monitor.item_collected_port.get(slv_monitor_transaction);
        slave_moniter_transaction_queue.push_back(slv_monitor_transaction);
        slave_moniter_transaction_queue_size++;
    end
end

always #5 tb_clock = !tb_clock;

endmodule
