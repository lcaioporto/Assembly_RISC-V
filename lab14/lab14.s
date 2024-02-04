.section .text
.align 4

int_handler:
    ###### Syscall and Interrupts handler ######

    # <= Implement your syscall handler here 
    # Salvar o contexto
    csrrw sp, mscratch, sp # Troca sp com mscratch
    addi sp, sp, -16 # Aloca espaço na pilha
    sw t0, 0(sp) # Salva t0
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    
    # Trata a exceção
    li t0, 10
    bne a7, t0, pular
    jal Syscall_set_engine_and_steering
    pular:
    # Recupera o contexto
    csrr t0, mepc  # load return address (address of the instruction that invoked the syscall)
    addi t0, t0, 4 # adds 4 to the return address (to return after ecall) 
    csrw mepc, t0  # stores the return address back on mepc
    lw t0, 0(sp) # Recupera t0
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    addi sp, sp, 16 # Desaloca espaço da pilha
    csrrw sp, mscratch, sp # Troca sp com mscratch novamente

    mret           # Recover remaining context (pc <- mepc)

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
    # se não entrou em nenhum dos 3, então a0 é inválido.
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

.globl _start
_start:
    la t0, int_handler  # Load the address of the routine that will handle interrupts
    csrw mtvec, t0      # (and syscalls) on the register MTVEC to set the interrupt array.

    # Mudar para MODO USUÁRIO
    csrr t1, mstatus # Update the mstatus.MPP
    li t2, ~0x1800 # field (bits 11 and 12)
    and t1, t1, t2 # with value 00 (U-mode)
    csrw mstatus, t1
    la t0, user_main # Loads the user software
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

    # Pular pra user_main
    mret

.globl control_logic
control_logic:
    li t2, 2400
    # ir reto
    for1:
        li a0, 1
        li a1, 0
        li a7, 10
        ecall
        addi t2, t2, -1
        bnez t2, for1
    
    # virar pra esquerda
    li t2, 1300
    for2:
        li a0, 0
        li a1, -100
        li a7, 10
        ecall
        addi t2, t2, -1
        bnez t2, for2

.section .bss
.align 4
# pilha ISRs
isr_stack:
.skip 1024
isr_stack_end:

.section .data
car_base_address: .word 0xFFFF0100