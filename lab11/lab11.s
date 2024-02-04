.section .text
.globl _start

_start:
    li s0, 0xFFFF0100 # base adress - car
    li a0, 13900 # valor máximo para iteração de ir reto
    li a1, 0    # contador
    moveForward:
        li t0, 1
        sb t0, 0x21(s0)
        beq a1, a0, stopMovingForward
        addi a1, a1, 1
        j moveForward
    stopMovingForward:

    li a0, 8000
    li a1, 0
    turnLeft:
        li t0, -100
        sb t0, 0x20(s0)
        beq a1, a0, stopTurningLeft
        addi a1, a1, 1
        j turnLeft
    stopTurningLeft:
    # exit
    li a0, 0
    li a7, 93
    ecall