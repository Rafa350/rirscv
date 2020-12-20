module GPIO (

    logic  input        i_clock,
    input  logic        i_reset,
    
    output logic [7:0]  o_pins,
    
    input  logic [3:0]  i_addr,
    input  logic        i_cs,
    input  logic        i_wrEnable,
    input  logic [15:0] i_wrData,
    output logic [15:0] o_rdData);
       
    always_comb
        casez ({i_rst, i_addr, i_cs})
            7'b0_0000_?: o_rdata = o_pins;
            7'b1_????_?: o_rdata = 0;
        endcase
        
    always_ff @posedge(i_Clock) begin
        casez ({i_rst, i_addr, i_cs, i_we}) 
            7'b0_0000_1_1: o_pins <= i_wdata;
            7'b1_????_?_?: o_pins <= 0;
        endcase
    end

endmodule
