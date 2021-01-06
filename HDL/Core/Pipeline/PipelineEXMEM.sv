`include "RV.svh"


module PipelineEXMEM
    import Types::*;
(
    // Senyals de control
    input  logic       i_clock,        // Clock
    input  logic       i_reset,        // Reset
    input  logic       i_flush,        // Descarta les acciona d'escriptura

`ifdef DEBUG
    // Senyals d'entrada de depuracio
    input  int         i_dbgTick,        // Numero de tick
    input  logic       i_dbgOk,          // Indicador d'iInstruccio executada
    input  Inst        i_dbgInst,        // Instruccio
    input  RegAddr     i_dbgRegWrAddr,   // Registre per escriure
    input  logic       i_dbgRegWrEnable, // Autoritzacio d'escriptura en registre

    // Senyals de sortidade depuracio
    output int         o_dbgTick,        // Numero de tick
    output logic       o_dbgOk,          // Indicador d'instruccio executada
    output Inst        o_dbgInst,        // Instruccio
    output RegAddr     o_dbgRegWrAddr,   // Registre per escriure
    output logic       o_dbgRegWrEnable, // Autoritzacio d'escriptura en registre
`endif

    // Senyals d'entrada al pipeline
    input  InstAddr    i_pc,             // Adressa de la instruccio
    input  Data        i_result,
    input  Data        i_dataB,
    input  logic       i_memWrEnable,    // Autoritza l'escriptura en la memoria
    input  logic       i_memRdEnable,    // Habilita la lectura de la memoria
    input  DataAccess  i_memAccess,      // Tamany del access a la memoria
    input  logic       i_memUnsigned,    // Lectura de memoria sense signe
    input  RegAddr     i_regWrAddr,
    input  logic       i_regWrEnable,    // Autoritza l'escriptura en els registres
    input  logic [1:0] i_regWrDataSel,

    // Senyals de sortida del pipeline
    output InstAddr    o_pc,
    output Data        o_result,
    output Data        o_dataB,
    output logic       o_memWrEnable,  // Autoritza l'escriptura en memoria
    output logic       o_memRdEnable,  // Autoritza la lectura de la memoria
    output DataAccess  o_memAccess,    // Tamany del acces a la memoria
    output logic       o_memUnsigned,  // Lectura de memoria sense signe
    output RegAddr     o_regWrAddr,
    output logic       o_regWrEnable,
    output logic [1:0] o_regWrDataSel);


    always_ff @(posedge i_clock) begin
        o_pc             <= i_reset ? {$size(InstAddr){1'b0}} : i_pc;
        o_result         <= i_reset ? {$size(Data){1'b0}}     : i_result;
        o_dataB          <= i_reset ? {$size(Data){1'b0}}     : i_dataB;
        o_memWrEnable    <= i_reset ? 1'b0                    : (i_flush ? 1'b0 : i_memWrEnable);
        o_memRdEnable    <= i_reset ? 1'b0                    : (i_flush ? 1'b0 : i_memRdEnable);
        o_memAccess      <= i_reset ? DataAccess_Word         : i_memAccess;
        o_memUnsigned    <= i_reset ? 1'b0                    : i_memUnsigned;
        o_regWrAddr      <= i_reset ? {$size(RegAddr){1'b0}}  : i_regWrAddr;
        o_regWrEnable    <= i_reset ? 1'b0                    : (i_flush ? 1'b0 : i_regWrEnable);
        o_regWrDataSel   <= i_reset ? 2'b0                    : i_regWrDataSel;
`ifdef DEBUG
        o_dbgTick        <= i_dbgTick;
        o_dbgOk          <= (i_reset | i_flush) ? 1'b0 : i_dbgOk;
        o_dbgInst        <= i_dbgInst;
        o_dbgRegWrAddr   <= i_dbgRegWrAddr;
        o_dbgRegWrEnable <= i_dbgRegWrEnable;
`endif
    end


endmodule
