#include "sim.h"
#include "RISCV.h"
#include "RISCVMemory.h"


#define PIPELINE


#ifdef PIPELINE
    #define TRACE_FILE_NAME "waves_pp/trace.fst"
#else
    #define TRACE_FILE_NAME "waves_sc/trace.fst"
#endif


// Els temps son en ticks de simulacio (simTime). Per que sigui totalment
// asincron, els temps d'activacio o desactivacio no poden ser multiples
// de 10, ja que el temp del sistems (clock) es cada 10 ticks del temps
// de simulacio (simTime)
//
#define CLOCK_MAX           50000  // Nombre de ticks a simular
#define CLOCK_START             0  // Tick per iniciar clk
#define CLOCK_TICKS            10  // Tics per cicle clk

#define CLOCK_RST_SET           0  // Tic per iniciar el reset
#define CLOCK_RST_CLR           7  // Tic per acabar el reset


using namespace Simulation;
using namespace RISCV;


class CPUTestbench: public Testbench<Vtop, VerilatedFstC> {

    public:
        CPUTestbench();
        void run();
        void dumpDataMemory(addr_t addr, unsigned length);
};


/// ----------------------------------------------------------------------
/// \bried    Contructor de l'objecte
/// \param    rom: Memoria rom
/// \param    ram: Memoria ram
///
CPUTestbench::CPUTestbench() {
}


/// ----------------------------------------------------------------------
/// \brief    Executa la simulacio.
///
void CPUTestbench::run() {

    std::string traceFileName(TRACE_FILE_NAME);

    Vtop *top = getTop();

    top->i_clock = 0;
    top->i_reset = 0;

    openTrace(traceFileName);

    unsigned tick;
    do {
        tick = getTickCount();

        // Genera la senyal 'clock'
        //
        if (tick >= CLOCK_START) {
            if ((tick % 10) == 0)
                top->i_clock = 0;
            else if ((tick % 10) == 5)
                top->i_clock = 1;
        }

        // Genera la senyal de 'reset'
        //
        if (tick == CLOCK_RST_CLR)
            top->i_reset = 0;
        else if (tick == CLOCK_RST_SET)
            top->i_reset = 1;

    } while (nextTick() && (tick < CLOCK_MAX));

    closeTrace();
}


/// ----------------------------------------------------------------------
/// \brief    Llista un bloc de memoria de dades
/// \param    addr: Adressa del bloc
/// \param    length: Longitut del bloc
///
void CPUTestbench::dumpDataMemory(
    RISCV::addr_t addr,
    unsigned length) {

    Vtop *top = getTop();
    long long memObj = top->top->dataMem->getMemObj();
    Memory *mem = (Memory*) memObj;

    printf("Data memory dump:\n");
    mem->dump(addr, length);
    printf("\n");
}


/// ----------------------------------------------------------------------
/// \brief    Entrada a l'aplicacio.
/// \param    argc: Nombre d'arguments.
/// \param    argv: Llista d'arguments.
/// \param    env: Variables del sistema.
/// \return   0 si tot es correcte.
///
int main(
    int argc,
    char **argv,
    char **env) {

    printf("RISCV RTL Simulator V1.0\n\n");

    CPUTestbench *tb = new CPUTestbench();
    if (tb) {
        tb->run();
        tb->dumpDataMemory(RISCV_DMEM_BASE, 128);
        delete tb;
    }

    return 0;
}
