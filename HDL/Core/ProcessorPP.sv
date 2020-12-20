`include "RV.svh"

module ProcessorPP
    import Types::*;
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    input  logic         i_clock,  // Clock
    input  logic         i_reset,  // Reset
    DataMemoryBus.master dataBus,  // Bus de la memoria de dades
    InstMemoryBus.master instBus); // Bus de la memoria d'instruccions


    // ------------------------------------------------------------------------
    // Stage IF
    // ------------------------------------------------------------------------

    Inst     IF_inst;
    InstAddr IF_pc;

    StageIF
    stageIF (
        .i_clock  (i_clock),   // Clock
        .i_reset  (i_reset),   // Reset
        .instBus  (instBus),   // Bus de la memoria d'instruccio
        .i_pcNext (ID_pcNext), // Adressa de salt
        .o_inst   (IF_inst),   // Instruccio
        .o_pc     (IF_pc));    // Adressa de la instruccio


    // ------------------------------------------------------------------------
    // Pipeline IF-ID
    // ------------------------------------------------------------------------

    Inst     IFID_inst;
    InstAddr IFID_pc;

`ifdef DEBUG
    int      IFID_dbgTick;
    logic    IFID_dbgOk;
    InstAddr IFID_dbgPc;
    Inst     IFID_dbgInst;
`endif

    PipelineIFID
    pipelineIFID (
        .i_clock   (i_clock),
        .i_reset   (i_reset),
        .i_stall   (ID_bubble),
        .i_pc      (IF_pc),
        .i_inst    (IF_inst),
        .o_pc      (IFID_pc),
        .o_inst    (IFID_inst)

`ifdef DEBUG
        ,
        .i_dbgTick (dbg_Tick),
        .i_dbgOk   (1'b1),
        .i_dbgPc   (IF_pc),
        .i_dbgInst (IF_inst),
        .o_dbgTick (IFID_dbgTick),
        .o_dbgOk   (IFID_dbgOk),
        .o_dbgPc   (IFID_dbgPc),
        .o_dbgInst (IFID_dbgInst)
`endif
    );


    // ------------------------------------------------------------------------
    // Stage ID
    // ------------------------------------------------------------------------

    Data        ID_dataA;
    Data        ID_dataB;
    Data        ID_instIMM;
    logic       ID_isLoad;
    RegAddr     ID_regWrAddr;
    logic       ID_regWrEnable;
    logic [1:0] ID_regWrDataSel;
    logic       ID_memWrEnable;
    AluOp       ID_aluControl;
    logic [1:0] ID_operandASel;
    logic [1:0] ID_operandBSel;
    InstAddr    ID_pcNext;
    logic       ID_bubble;

    StageID
    stageID (
        .i_clock           (i_clock),           // Clock
        .i_reset           (i_reset),           // Reset
        .i_inst            (IFID_inst),         // Instruccio
        .i_pc              (IFID_pc),           // Adressa de la instruccio
        .i_EX_RegWrAddr    (IDEX_regWrAddr),
        .i_EX_RegWrEnable  (IDEX_regWrEnable),
        .i_EX_RegWrDataSel (IDEX_regWrDataSel),
        .i_EX_RegWrData    (EX_result),
        .i_EX_IsLoad       (IDEX_isLoad),       // Indica si hi ha una instruccio Load en EX
        .i_MEM_RegWrAddr   (EXMEM_regWrAddr),
        .i_MEM_RegWrEnable (EXMEM_regWrEnable),
        .i_MEM_RegWrData   (EXMEM_result),      // El valor a escriure en el registre
        .i_MEM_IsLoad      (EXMEM_isLoad),      // Indica si hi ha una instruccio Load en MEM
        .i_WB_RegWrAddr    (MEMWB_regWrAddr),   // Adressa del registre on escriure
        .i_WB_RegWrData    (MEMWB_regWrData),   // Dades del registre on escriure
        .i_WB_RegWrEnable  (MEMWB_regWrEnable), // Habilita escriure en el registre
        .o_dataA           (ID_dataA),          // Dades A
        .o_dataB           (ID_dataB),          // Dades B
        .o_instIMM         (ID_instIMM),
        .o_isLoad          (ID_isLoad),
        .o_bubble          (ID_bubble),         // Indica si cal generar bombolla
        .o_regWrAddr       (ID_regWrAddr),      // Registre per escriure
        .o_regWrEnable     (ID_regWrEnable),    // Habilita escriure en el registre
        .o_regWrDataSel    (ID_regWrDataSel),
        .o_memWrEnable     (ID_memWrEnable),    // Habilita escriure en memoria
        .o_aluControl      (ID_aluControl),
        .o_operandASel     (ID_operandASel),
        .o_operandBSel     (ID_operandBSel),
        .o_pcNext          (ID_pcNext));         // Adressa de la propera instruccio per salt


    // ------------------------------------------------------------------------
    // Pipeline ID-EX
    // ------------------------------------------------------------------------

    InstAddr    IDEX_pc;
    Data        IDEX_dataA;
    Data        IDEX_dataB;
    Data        IDEX_instIMM;
    RegAddr     IDEX_regWrAddr;
    logic       IDEX_regWrEnable;
    logic [1:0] IDEX_regWrDataSel;
    logic       IDEX_memWrEnable;
    logic       IDEX_isLoad;
    AluOp       IDEX_aluControl;
    logic [1:0] IDEX_operandASel;
    logic [1:0] IDEX_operandBSel;

`ifdef DEBUG
    int      IDEX_dbgTick;
    logic    IDEX_dbgOk;
    InstAddr IDEX_dbgPc;
    Inst     IDEX_dbgInst;
    RegAddr  IDEX_dbgRegWrAddr;
    logic    IDEX_dbgRegWrEnable;
`endif

    PipelineIDEX
    pipelineIDEX (
        .i_clock          (i_clock),
        .i_reset          (i_reset),
        .i_flush          (ID_bubble),
        .i_instIMM        (ID_instIMM),
        .i_dataA          (ID_dataA),
        .i_dataB          (ID_dataB),
        .i_regWrAddr      (ID_regWrAddr),
        .i_regWrEnable    (ID_regWrEnable),
        .i_regWrDataSel   (ID_regWrDataSel),
        .i_memWrEnable    (ID_memWrEnable),
        .i_isLoad         (ID_isLoad),
        .i_operandASel    (ID_operandASel),
        .i_operandBSel    (ID_operandBSel),
        .i_aluControl     (ID_aluControl),
        .i_pc             (IFID_pc),
        .o_instIMM        (IDEX_instIMM),
        .o_dataA          (IDEX_dataA),
        .o_dataB          (IDEX_dataB),
        .o_regWrAddr      (IDEX_regWrAddr),
        .o_regWrEnable    (IDEX_regWrEnable),
        .o_regWrDataSel   (IDEX_regWrDataSel),
        .o_memWrEnable    (IDEX_memWrEnable),
        .o_isLoad         (IDEX_isLoad),
        .o_aluControl     (IDEX_aluControl),
        .o_operandASel    (IDEX_operandASel),
        .o_operandBSel    (IDEX_operandBSel),
        .o_pc             (IDEX_pc)

`ifdef DEBUG
        ,
        .i_dbgTick        (IFID_dbgTick),
        .i_dbgOk          (IFID_dbgOk),
        .i_dbgPc          (IFID_dbgPc),
        .i_dbgInst        (IFID_dbgInst),
        .i_dbgRegWrAddr   (ID_regWrAddr),
        .i_dbgRegWrEnable (ID_regWrEnable),
        .o_dbgTick        (IDEX_dbgTick),
        .o_dbgOk          (IDEX_dbgOk),
        .o_dbgPc          (IDEX_dbgPc),
        .o_dbgInst        (IDEX_dbgInst),
        .o_dbgRegWrAddr   (IDEX_dbgRegWrAddr),
        .o_dbgRegWrEnable (IDEX_dbgRegWrEnable)
`endif
    );


    // ------------------------------------------------------------------------
    // Stage EX
    // ------------------------------------------------------------------------

    Data EX_result;
    Data EX_dataB;

    StageEX
    stageEX (
        .i_dataA       (IDEX_dataA),
        .i_dataB       (IDEX_dataB),
        .i_instIMM     (IDEX_instIMM),
        .i_pc          (IDEX_pc),
        .i_operandASel (IDEX_operandASel),
        .i_operandBSel (IDEX_operandBSel),
        .i_aluControl  (IDEX_aluControl),
        .o_result      (EX_result),
        .o_dataB       (EX_dataB));

    // ------------------------------------------------------------------------
    // Pipeline EX-MEM
    // ------------------------------------------------------------------------

    logic [PC_WIDTH-1:0]   EXMEM_pc;
    logic [DATA_WIDTH-1:0] EXMEM_result;
    logic [DATA_WIDTH-1:0] EXMEM_dataB;
    logic [REG_WIDTH-1:0]  EXMEM_regWrAddr;
    logic                  EXMEM_regWrEnable;
    logic [1:0]            EXMEM_regWrDataSel;
    logic                  EXMEM_memWrEnable;
    logic                  EXMEM_isLoad;

`ifdef DEBUG
    int      EXMEM_dbgTick;
    logic    EXMEM_dbgOk;
    InstAddr EXMEM_dbgPc;
    Inst     EXMEM_dbgInst;
    RegAddr  EXMEM_dbgRegWrAddr;
    logic    EXMEM_dbgRegWrEnable;
`endif

    PipelineEXMEM
    pipelineEXMEM (
        .i_clock          (i_clock),
        .i_reset          (i_reset),
        .i_flush          (0),
        .i_pc             (IDEX_pc),
        .i_result         (EX_result),
        .i_dataB          (EX_dataB),
        .i_memWrEnable    (IDEX_memWrEnable),
        .i_regWrAddr      (IDEX_regWrAddr),
        .i_regWrEnable    (IDEX_regWrEnable),
        .i_regWrDataSel   (IDEX_regWrDataSel),
        .i_isLoad         (IDEX_isLoad),
        .o_pc             (EXMEM_pc),
        .o_result         (EXMEM_result),
        .o_dataB          (EXMEM_dataB),
        .o_memWrEnable    (EXMEM_memWrEnable),
        .o_regWrAddr      (EXMEM_regWrAddr),
        .o_regWrEnable    (EXMEM_regWrEnable),
        .o_regWrDataSel   (EXMEM_regWrDataSel),
        .o_isLoad         (EXMEM_isLoad)

`ifdef DEBUG
        ,
        .i_dbgTick        (IDEX_dbgTick),
        .i_dbgOk          (IDEX_dbgOk),
        .i_dbgPc          (IDEX_dbgPc),
        .i_dbgInst        (IDEX_dbgInst),
        .i_dbgRegWrAddr   (IDEX_dbgRegWrAddr),
        .i_dbgRegWrEnable (IDEX_dbgRegWrEnable),
        .o_dbgTick        (EXMEM_dbgTick),
        .o_dbgOk          (EXMEM_dbgOk),
        .o_dbgPc          (EXMEM_dbgPc),
        .o_dbgInst        (EXMEM_dbgInst),
        .o_dbgRegWrAddr   (EXMEM_dbgRegWrAddr),
        .o_dbgRegWrEnable (EXMEM_dbgRegWrEnable)
`endif
    );


    // ------------------------------------------------------------------------
    // Stage MEM
    // ------------------------------------------------------------------------

    Data MEM_regWrData;

    StageMEM
    stageMEM (
        .dataBus        (dataBus),            // Interficie amb la memoria de dades
        .i_pc           (EXMEM_pc),           // Adressa de la instruccio
        .i_result       (EXMEM_result),       // Adressa per escriure en memoria
        .i_dataB        (EXMEM_dataB),        // Dades per escriure
        .i_regWrDataSel (EXMEM_regWrDataSel), // Seleccio de dades d'escriptura en el registre
        .i_memWrEnable  (EXMEM_memWrEnable),  // Autoritzacio d'escriptura en memoria
        .o_regWrData    (MEM_regWrData));     // Dades per escriure en el registre


    // ------------------------------------------------------------------------
    // Pipeline MEM-WB
    // ------------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] MEMWB_regWrData;
    logic [REG_WIDTH-1:0]  MEMWB_regWrAddr;
    logic                  MEMWB_regWrEnable;

`ifdef DEBUG
    int      MEMWB_dbgTick;
    logic    MEMWB_dbgOk;
    InstAddr MEMWB_dbgPc;
    Inst     MEMWB_dbgInst;
    RegAddr  MEMWB_dbgRegWrAddr;
    logic    MEMWB_dbgRegWrEnable;
    Data     MEMWB_dbgRegWrData;
    DataAddr MEMWB_dbgMemWrAddr;
    logic    MEMWB_dbgMemWrEnable;
    Data     MEMWB_dbgMemWrData;

`endif

    PipelineMEMWB
    pipelineMEMWB (
        .i_clock          (i_clock),
        .i_reset          (i_reset),
        .i_flush          (0),
        .i_regWrAddr      (EXMEM_regWrAddr),
        .i_regWrEnable    (EXMEM_regWrEnable),
        .i_regWrData      (MEM_regWrData),
        .o_regWrAddr      (MEMWB_regWrAddr),
        .o_regWrEnable    (MEMWB_regWrEnable),
        .o_regWrData      (MEMWB_regWrData)

`ifdef DEBUG
        ,
        .i_dbgTick        (EXMEM_dbgTick),
        .i_dbgOk          (EXMEM_dbgOk),
        .i_dbgPc          (EXMEM_dbgPc),
        .i_dbgInst        (EXMEM_dbgInst),
        .i_dbgRegWrAddr   (EXMEM_dbgRegWrAddr),
        .i_dbgRegWrEnable (EXMEM_dbgRegWrEnable),
        .i_dbgRegWrData   (MEM_regWrData),
        .i_dbgMemWrAddr   (dataBus.addr),
        .i_dbgMemWrEnable (dataBus.wrEnable),
        .i_dbgMemWrData   (dataBus.wrData),
        .o_dbgTick        (MEMWB_dbgTick),
        .o_dbgOk          (MEMWB_dbgOk),
        .o_dbgPc          (MEMWB_dbgPc),
        .o_dbgInst        (MEMWB_dbgInst),
        .o_dbgRegWrAddr   (MEMWB_dbgRegWrAddr),
        .o_dbgRegWrEnable (MEMWB_dbgRegWrEnable),
        .o_dbgRegWrData   (MEMWB_dbgRegWrData),
        .o_dbgMemWrAddr   (MEMWB_dbgMemWrAddr),
        .o_dbgMemWrEnable (MEMWB_dbgMemWrEnable),
        .o_dbgMemWrData   (MEMWB_dbgMemWrData)
`endif
    );


    // ------------------------------------------------------------------------
    // Stage WB
    // Es teoric, en la practica no te cap implementacio, ja que es la part
    // d'escriptura en els registres, que es troben en el stage ID.
    // ------------------------------------------------------------------------


    // ------------------------------------------------------------------------
    // Trace
    // Traçat de l'ultima intruccio executada.
    // ------------------------------------------------------------------------

`ifdef DEBUG
    int dbg_Tick;

    DebugController
    dbg(
        .i_clock       (i_clock),
        .i_reset       (i_reset),
        .i_stall       (ID_bubble),
        .i_tick        (MEMWB_dbgTick),
        .i_ok          (MEMWB_dbgOk),
        .i_pc          (MEMWB_dbgPc),
        .i_inst        (MEMWB_dbgInst),
        .i_regWrAddr   (MEMWB_dbgRegWrAddr),
        .i_regWrEnable (MEMWB_dbgRegWrEnable),
        .i_regWrData   (MEMWB_dbgRegWrData),
        .i_memWrAddr   (MEMWB_dbgMemWrAddr),
        .i_memWrEnable (MEMWB_dbgMemWrEnable),
        .i_memWrData   (MEMWB_dbgMemWrData),
        .o_tick        (dbg_Tick));
`endif


endmodule