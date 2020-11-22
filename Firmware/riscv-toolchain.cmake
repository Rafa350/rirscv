set(CMAKE_SYSTEM_NAME generic)
set(CMAKE_SYSTEM_PROCESSOR RISCV)

set(TOOLCHAIN_BIN /opt/riscv32/bin)    
set(TOOLCHAIN_PREFIX riscv32-unknown-elf-)    

find_program(CMAKE_C_COMPILER
    NAMES ${TOOLCHAIN_PREFIX}gcc
    PATH ${TOOLCHAIN_BIN}
)    

find_program(CMAKE_CXX_COMPILER
    NAMES ${TOOLCHAIN_PREFIX}g++
    PATH ${TOOLCHAIN_BIN}
)    

find_program(CMAKE_ASM_COMPILER
    NAMES ${TOOLCHAIN_PREFIX}as
    PATH ${TOOLCHAIN_BIN}
)    

find_program(CMD_OBJCOPY
    NAMES ${TOOLCHAIN_PREFIX}objcopy
    PATH ${TOOLCHAIN_BIN}
)    

find_program(CMD_OBJDUMP
    NAMES ${TOOLCHAIN_PREFIX}objdump
    PATH ${TOOLCHAIN_BIN}
)    

find_program(CMD_SIZE
    NAMES ${TOOLCHAIN_PREFIX}size
    PATH ${TOOLCHAIN_BIN}
)    


