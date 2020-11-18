module PipelineIFID 
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5) 
(

    input logic                 i_Clock,
    input logic                 i_Reset,
    
    input logic  [PC_WIDTH-1:0] i_PC,
    input logic  [31:0]         i_Inst,
    
    output logic [PC_WIDTH-1:0] o_PC,
    output logic [31:0]         o_Inst);
    
    
    always_ff @(posedge i_Clock) begin
        o_PC   <= i_Reset ? -4 : i_PC;
        o_Inst <= i_Reset ?  0 : i_Inst;
    end


endmodule
