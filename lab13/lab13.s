.section .text
.globl _start
.globl play_note
.globl gpt_isr

play_note:
    # a0: channel (ch)
    # a1: instrument ID (inst)
    # a2: musical note (note)
    # a3: note velocity (vel)
    # a4: note duration (dur)
    li t0, 0xFFFF0300 # base: midi_synthesizer.js
    sh a1, 2(t0)
    sb a2, 4(t0)
    sb a3, 5(t0)
    sh a4, 6(t0)
    sb a0, 0(t0)
    ret

gpt_isr:
    # salvar o contexto
    csrrw sp, mscratch, sp
    addi sp, sp, -12
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)

    li t1, 0xFFFF0100 # base: GPT
    la t2, _system_time
    # ler o tempo
    li t0, 1
    sb t0, 0(t1)

    enquantoLe:   # ficar na iteração até t0 virar 0, ou seja, até a leitura terminar
        lb t0, 0(t1)
        bnez t0, enquantoLe
    
    lw t0, 4(t1)  # pegar o tempo
    sw t0, 0(t2)  # colocar tempo no _system_time

    # set gpt interrupts - generates an external interrupt after 100ms
    li t0, 100
    sw t0, 8(t1)

    # recuperar o contexto
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    addi sp, sp, 12
    csrrw sp, mscratch, sp
    # retornar
    mret

_start:
    # setar a localização do rótulo que vai tratar a exceção
    la t0, gpt_isr
    csrw mtvec, t0

    # fazer o mscratch apontar pro topo da pilha de ISRs
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

    # set gpt interrupts - generates an external interrupt after 100ms
    li t1, 0xFFFF0100 # base: GPT
    li t0, 100
    sw t0, 8(t1)

    #jump to main
    jal main

.section .bss
.align 4
# pilha ISRs
isr_stack:
.skip 1024
isr_stack_end:

.section .data
.globl _system_time
_system_time: .word 0