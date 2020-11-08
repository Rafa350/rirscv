//`define PIPELINE


module top(
    input  wire       CLOCK_50,
    input  wire [1:0] KEY,
    input  wire [3:0] SW,
    output wire [7:0] LED);
    
    parameter DATA_DBUS_WIDTH = 32;
    parameter ADDR_DBUS_WIDTH = 32;
    parameter DATA_IBUS_WIDTH = 32;
    parameter ADDR_IBUS_WIDTH = 32;
    
    logic clk;
    assign clk = ~KEY[0];

    logic rst;
    assign rst = ~KEY[1];
    
    logic [ADDR_IBUS_WIDTH-1:0] pgm_addr;
    logic [DATA_IBUS_WIDTH-1:0] pgm_inst;    

    logic [DATA_DBUS_WIDTH-1:0] mem_wdata;
    logic [DATA_DBUS_WIDTH-1:0] mem_rdata;
    logic [ADDR_DBUS_WIDTH-1:0] mem_addr;
    logic mem_we;
    
    assign LED[5:0] = pgm_inst[31:26];
    assign LED[7:6] = pgm_addr[1:0];

    // -------------------------------------------------------------------
    // Memoria RAM
    //
    logic ram_we;
    mem #(
        .DATA_WIDTH (DATA_DBUS_WIDTH),
        .ADDR_WIDTH (DATA_DBUS_WIDTH))
    mem (
        .i_clk   (clk),
        .i_we    (mem_we),
        .i_addr  (mem_addr),
        .i_wdata (mem_wdata),
        .o_rdata (mem_rdata));
      
    // -------------------------------------------------------------------
    // Memoria de programa
    //    
    pgm #(
        .ADDR_WIDTH (ADDR_IBUS_WIDTH),
        .INST_WIDTH (DATA_IBUS_WIDTH))
    pgm (
        .i_addr (pgm_addr),
        .o_inst (pgm_inst));

    // -------------------------------------------------------------------
    // CPU
    //
`ifdef PIPELINE
    cpu_pipeline #(
`else    
    cpu #(
`endif    
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH), 
        .ADDR_DBUS_WIDTH (ADDR_DBUS_WIDTH),
        .DATA_IBUS_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_IBUS_WIDTH (ADDR_IBUS_WIDTH)) 
    cpu (
        .i_clk       (clk),
        .i_rst       (rst),
        .o_pgm_addr  (pgm_addr),
        .i_pgm_inst  (pgm_inst),
        .o_mem_we    (mem_we),  
        .i_mem_rdata (mem_rdata),
        .o_mem_wdata (mem_wdata),
        .o_mem_addr  (mem_addr));
       
endmodule