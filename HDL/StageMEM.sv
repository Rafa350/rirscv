module StageMEM 
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    input  logic                  i_Clock,
    input  logic                  i_Reset,
    
    input  logic [DATA_WIDTH-1:0] i_MemRdData,
    output logic [DATA_WIDTH-1:0] o_MemWrData,
    output logic [ADDR_WIDTH-1:0] o_MemAddr,
    output logic                  o_MemWrEnable,
    
    input  logic [PC_WIDTH-1:0]   i_PC,
    input  logic [DATA_WIDTH-1:0] i_Result,
    input  logic [DATA_WIDTH-1:0] i_MemWrData,

    input  logic                  i_MemWrEnable,

    input  logic [1:0]            i_RegWrDataSel,   
    output logic [DATA_WIDTH-1:0] o_RegWrData);


    // ------------------------------------------------------------------------
    // Interface amb la memoria de dades.
    // ------------------------------------------------------------------------
    
    assign o_MemAddr     = i_Result[ADDR_WIDTH-1:0];
    assign o_MemWrEnable = i_MemWrEnable;
    assign o_MemWrData   = i_MemWrData;
    
    
    /// -----------------------------------------------------------------------
    /// Evalua PC + 4
    /// -----------------------------------------------------------------------
    
    logic [PC_WIDTH-1:0] Adder_Result;
    
    HalfAdder #(
        .WIDTH (PC_WIDTH))
    Adder (
        .i_OperandA (i_PC),
        .i_OperandB (4),
        .o_Result   (Adder_Result));
    
    
    // ------------------------------------------------------------------------
    // Selecciona les dades per escriure en el registre de destinacio en 
    // funcio de la senyal i_RegWrDataSel
    //
    //     2'b00: El resultat de la ALU
    //     2'b01: El valor lleigit de la memoria de dades
    //     2'b10: El valor de PC + 4
    //
    // ------------------------------------------------------------------------
    
    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    RegWrDataSelector (
        .i_Select (i_RegWrDataSel),  
        .i_Input0 (i_Result),       
        .i_Input1 (i_MemRdData),    
        .i_Input2 ({{DATA_WIDTH-PC_WIDTH{1'b0}}, Adder_Result}), 
        .o_Output (o_RegWrData));
    // verilator lint_on PINMISSING

endmodule
