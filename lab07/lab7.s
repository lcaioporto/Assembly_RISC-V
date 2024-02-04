.section .text
.globl _start
/*

p1 = (d1 XOR d2) XOR d4

*/
read:
    # guarda o input em a1

    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_address #  buffer to read the data
    li a2, 13 # size (reads only 13 bytes)
    li a7, 63 # syscall read (63)
    ecall
    ret

write:
    # printa o conteúdo de a1

    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output       # buffer
    li a2, 15            # size - 15 bytes
    li a7, 64           # syscall write (64)
    ecall
    ret

encoding:
    # input: a1 - input do usuário
    # output - já colocar no output address
    lb t0, 0(a1) # pegar o d1
    lb t1, 1(a1) # pegar o d2
    lb t2, 2(a1) # pegar o d3
    lb t3, 3(a1) # pegar o d4
    addi t0, t0, -48
    addi t1, t1, -48
    addi t2, t2, -48
    addi t3, t3, -48

    # calcular p1 - s0
    xor t4, t0, t1 # (d1 XOR d2)
    xor s0, t4, t3 # p1 = (d1 XOR d2) XOR d4

    # calcular p2 - s1
    xor t4, t0, t2 # (d1 XOR d3)
    xor s1, t4, t3 # p1 = (d1 XOR d3) XOR d4

    # calcular p3 - s2
    xor t4, t1, t2 # (d2 XOR d3)
    xor s2, t4, t3 # p1 = (d2 XOR d3) XOR d4

    # converter pra char p1, p2 e colocar em output
    addi s0, s0, 48
    addi s1, s1, 48
    sb s0, 0(s3) # colocar p1 em 0 de output
    sb s1, 1(s3) # colocar p2 em 1 de output

    # d1
    addi t0, t0, 48
    sb t0, 2(s3) # colocar o d1 em 2 de output

    # p3
    addi s2, s2, 48
    sb s2, 3(s3) # colocar p3 em 3 de output

    # converter d2, d3, d4 pra char
    addi t1, t1, 48
    addi t2, t2, 48
    addi t3, t3, 48

    #colocar d2, d3, d4 em output
    sb t1, 4(s3) # colocar o d2 em 4 de output
    sb t2, 5(s3) # colocar o d3 em 5 de output
    sb t3, 6(s3) # colocar o d4 em 6 de output

    # '\n'
    li t0, 10
    sb t0, 7(s3) # colocar o '\n' no final da linha 1

    ret

decoding:
    # input: a1
    # output: escrever em output
    li t0, 0
    li t1, 0
    li t2, 0
    li t3, 0
    li t4, 0
    li t5, 0
    li s0, 0

    lb t0, 7(a1) # pegar o d1
    lb t1, 9(a1) # pegar o d2
    lb t2, 10(a1) # pegar o d3
    lb t3, 11(a1) # pegar o d4

    # colocar em output
    sb t0, 8(s3) # colocar d1 em 8 de s3
    sb t1, 9(s3) # colocar d2 em 9 de s3
    sb t2, 10(s3) # colocar d3 em 10 de s3
    sb t3, 11(s3) # colocar d4 em 11 de s3

    li t4, 10
    sb t4, 12(s3) # colocar o '\n' no final linha 2

    # verificar a validade

    # chutar que não tem erro (0)
    li t6, 48
    sb t6, 13(s3)

    # converter d1, d2, d3, d4 pra int
    addi t0, t0, -48
    addi t1, t1, -48
    addi t2, t2, -48
    addi t3, t3, -48

    lb s0, 5(a1) # pegar o p1 (s0)
    addi s0, s0, -48 # converter pra int
    # comparar pra p1 - salvar em t5
    xor t5, s0, t0 # p1 XOR d1
    xor t5, t5, t1 # (p1 XOR d1) XOR d2
    xor t5, t5, t3 # ((p1 XOR d1) XOR d2) XOR d4
    bnez t5, erro

    lb s0, 6(a1) # pegar o p2 (s0)
    addi s0, s0, -48 # converter pra int
    # comparar pra p2 - salvar em t5
    xor t5, s0, t0 # p2 XOR d1
    xor t5, t5, t2 # (p2 XOR d1) XOR d3
    xor t5, t5, t3 # ((p2 XOR d1) XOR d3) XOR d4
    bnez t5, erro

    lb s0, 8(a1) # pegar o p3 (s0)
    addi s0, s0, -48 # converter pra int
    # comparar pra p3 - salvar em t5
    xor t5, s0, t1 # p3 XOR d2
    xor t5, t5, t2 # (p3 XOR d2) XOR d3
    xor t5, t5, t3 # ((p3 XOR d2) XOR d3) XOR d4
    bnez t5, erro
    j sem_erro

    erro: # coloca 1 na posição 13 de output
        li t0, 49
        sb t0, 13(s3)
    sem_erro:
        # colocar o '\n' no final da linha 3
        li t0, 10
        sb t0, 14(s3)
        ret

_start:
    jal read
    la s3, output
    jal encoding
    jal decoding
    jal write
    # exit
    li a0, 0
    li a7, 93
    ecall

.section .bss
output: .skip 0xF #define a posição de memória para o output (15 bytes)
input_address: .skip 0xD  # buffer para ler 13 bytes