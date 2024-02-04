# Implement the syscalls

.section .text
.align 4

int_handler:
    # Salvar o contexto
    csrrw sp, mscratch, sp # Troca sp com mscratch
    addi sp, sp, -28       # Aloca espaço na pilha
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    sw a1, 16(sp)
    sw a2, 20(sp)
    sw ra, 24(sp)
    
    # Trata a exceção
    li t0, 10
    beq a7, t0, setEngine
    li t0, 11
    beq a7, t0, setHandBrake
    li t0, 12
    beq a7, t0, readSensors
    li t0, 13
    beq a7, t0, readDistance
    li t0, 15
    beq a7, t0, getPosition
    li t0, 16
    beq a7, t0, getRotation
    li t0, 17
    beq a7, t0, readSerial
    li t0, 18
    beq a7, t0, writeSerial
    li t0, 20
    beq a7, t0, getTime
    setEngine:
        jal Syscall_set_engine_and_steering
        j recuperarContexto
    setHandBrake:
        jal Syscall_set_handbrake
        j recuperarContexto
    readSensors:
        jal Syscall_read_sensors
        j recuperarContexto
    readDistance:
        jal Syscall_read_sensor_distance
        j recuperarContexto
    getPosition:
        jal Syscall_get_position
        j recuperarContexto
    getRotation:
        jal Syscall_get_rotation
        j recuperarContexto
    readSerial:
        jal Syscall_read_serial
        j recuperarContexto
    writeSerial:
        jal Syscall_write_seral
        j recuperarContexto
    getTime:
        jal Syscall_get_systime
    
    recuperarContexto:
    # Recupera o contexto
    csrr t0, mepc  # load return address (address of the instruction that invoked the syscall)
    addi t0, t0, 4 # adds 4 to the return address (to return after ecall) 
    csrw mepc, t0  # stores the return address back on mepc
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    lw a1, 16(sp)
    lw a2, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 28        # Desaloca espaço da pilha
    csrrw sp, mscratch, sp # Troca sp com mscratch novamente
    mret                   # Recover remaining context (pc <- mepc)

Syscall_set_engine_and_steering:
    la t0, car_base_address
    lw t0, (t0)

    # Verificar a validade dos parâmetros
    # 1) a0 = -1 | a0 = 0 | a0 = 1
    li t1, -1
    li t2, 0
    li t3, 1
    beq a0, t1, a0Valid
    beq a0, t2, a0Valid
    beq a0, t3, a0Valid
    # se não entrou por nenhum dos 3, então a0 é inválido.
    li a0, -1 # retorno indicando valor inválido
    ret
    a0Valid:
    # 2) -127 <= a1 <= 127
    li t1, 128
    li t2, -127
    bge a1, t1, a1Invalid # se a1 >= 128, então a1 é inválido
    blt a1, t2, a1Invalid # se a1 < -127, então a1 é inválido
    j bothValid
    a1Invalid:
    li a0, -1 # retorno indicando valor inválido
    ret
    bothValid:
    # Parâmetros válidos
    sb a0, 0x21(t0)
    sb a1, 0x20(t0)
    li a0, 0
    ret

Syscall_set_handbrake:
    la t0, car_base_address
    lw t0, (t0)
    sb a0, 0x22(t0)
    ret

Syscall_read_sensors:
    la t0, car_base_address
    lw t0, (t0)
    # register line camera
    li t1, 1
    sb t1, 1(t0)
    whileRegisterLineCamera:
        lb t1, 1(t0)
        bnez t1, whileRegisterLineCamera
    # capture the data
    li t1, 256
    forSyscall_read_sensors:
        lb t2, 0x24(t0)  # ler o byte da luminosidade
        sb t2, 0(a0)     # guardar o byte lido no endereço desejado
        addi a0, a0, 1
        addi t0, t0, 1
        addi t1, t1, -1
        bnez t1, forSyscall_read_sensors    
    ret

Syscall_read_sensor_distance:
    la t0, car_base_address
    lw t0, (t0)
    li t1, 1
    sb t1, 2(t0)
    whileReadSensorDistance:
        lb t1, 2(t0)
        bnez t1, whileReadSensorDistance
    lw a0, 0x1C(t0)
    ret

Syscall_get_position:
    # a0 <- x
    # a1 <- y
    # a2 <- z
    la t0, car_base_address
    lw t0, 0(t0)
    li t1, 1
    sb t1, 0(t0)
    whileGetPosition:
        lb t1, 0(t0)
        bnez t1, whileGetPosition
    
    # X
    lw t1, 0x10(t0)
    sw t1, 0(a0)
    # Y
    lw t1, 0x14(t0)
    sw t1, 0(a1)
    # Z
    lw t1, 0x18(t0)
    sw t1, 0(a2)
    # retornar
    ret

Syscall_get_rotation:
    # a0 <- Euler angle in x
    # a1 <- Euler angle in y
    # a2 <- Euler angle in z
    la t0, car_base_address
    lw t0, 0(t0)
    li t1, 1
    sb t1, 0(t0)
    whileGetRotation:
        lb t1, 0(t0)
        bnez t1, whileGetRotation
    # X
    lw t1, 0x4(t0)
    sw t1, 0(a0)
    # Y
    lw t1, 0x8(t0)
    sw t1, 0(a1)
    # Z
    lw t1, 0xC(t0)
    sw t1, 0(a2)
    # retornar
    ret

Syscall_read_serial:
    # a0 - buffer
    # a1 - size
    # retorna quantos bytes foram lidos
    la t0, serial_port_base_address
    lw t0, 0(t0)
    li t2, 0                             # contador
    whileReadSerial:
        li t1, 1
        sb t1, 2(t0)                     # ler um byte de input
        forReadSerial:
            lb t1, 2(t0)                 # verificar se o input ainda está lendo
            bnez t1, forReadSerial       # se t1 == 0, significa que o input terminou de ler
        lb t3, 3(t0)                     # pegar o byte lido em t3
        # VERIFICAÇÃO
        beqz t3, invalidByte             # se t3 == 0, invalidByte -> parar o loop
        li t1, '\n'
        beq t3, t1, invalidByte          # se t3 == '\n', invalidByte -> parar o loop
        j validByte
        invalidByte:
        # Se o byte lido for null, encerramos a leitura
        sb t3, 0(a0)
        mv a0, t2
        ret
        validByte:
        sb t3, 0(a0)
        addi t2, t2, 1
        addi a0, a0, 1
        addi a1, a1, -1
        bnez a1, whileReadSerial
    mv a0, t2
    ret

Syscall_write_seral:
    # a0 - buffer
    # a1 - size
    la t0, serial_port_base_address
    lw t0, 0(t0)
    whileWriteSerial:
        li t1, 1
        lb t2, 0(a0) # ler o byte a ser escrito
        sb t2, 1(t0) # colocar byte a ser escrito no devido lugar
        sb t1, 0(t0) # escrever um byte 
        forWriteSerial:
            lb t1, 0(t0) # verificar se o input ainda está lendo
            bnez t1, forWriteSerial # se t1 == 0, significa que o input terminou de ler
        
        addi a0, a0, 1
        addi a1, a1, -1
        bnez a1, whileWriteSerial
    ret

Syscall_get_systime:
    la t0, gpt_base_address
    lw t0, (t0)
    li t1, 1
    sb t1, 0(t0) # start reading the current system time
    forGetTime:
        lb t1, 0(t0)
        bnez t1, forGetTime
    lw a0, 4(t0) # ler o tempo
    ret

.globl _start
_start:
    la t0, int_handler  # Load the address of the routine that will handle interrupts
    csrw mtvec, t0      # (and syscalls) on the register MTVEC to set the interrupt array.

    # Mudar para MODO USUÁRIO
    csrr t1, mstatus # Update the mstatus.MPP
    li t2, ~0x1800 # field (bits 11 and 12)
    and t1, t1, t2 # with value 00 (U-mode)
    csrw mstatus, t1
    la t0, main # Loads the user software
    csrw mepc, t0 # entry point into mepc

    # Inicializar a stack
    la t0, isr_stack_end
    csrw mscratch, t0

    # habilitar interrupção externa
    csrr t1, mie
    li t2, 0x800
    or t1, t1, t2
    csrw mie, t1
    # habilita interrupções globais
    csrr t1, mstatus
    ori t1, t1, 0x8
    csrw mstatus, t1

    # pilha de usuário
    li sp, 0x07FFFFFC

    mret # PC <= MEPC; mode <= MPP;

.section .bss
.align 4
# pilha ISRs
isr_stack:
.skip 1024
isr_stack_end:

.section .data
gpt_base_address: .word 0xFFFF0100
car_base_address: .word 0xFFFF0300
serial_port_base_address: .word 0xFFFF0500