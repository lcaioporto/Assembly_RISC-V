.section .text
.globl _start

read:
    # guarda o input em a1

    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_address #  buffer to read the data
    li a2, 20  # size (reads only 20 bytes)
    li a7, 63 # syscall read (63)
    ecall
    ret

write:
    # printa o conteúdo de a1

    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output       # buffer
    li a2, 5            # size - 5 bytes
    li a7, 64           # syscall write (64)
    ecall
    ret

charToInt:
    # recebe de input o a1
    # output: a0

    # 1o digito
    lb t0, 0(a1) # pega a posição 0 de a1 e coloca em t0
    addi t0, t0, -48 # converte pra t0 para int somando -48
    li t1, 1000 # coloca 1000 em t1
    mul a0, t0, t1 # multiplica t0 por 1000 e guarda em a0

    # 2o digito
    lb t0, 1(a1) # pega a posição 1 de a1 e coloca em t0
    addi t0, t0, -48 # converte pra t0 para int somando -48
    li t1, 100 # coloca 100 em t1
    mul t1, t0, t1 # multiplica t0 por 100 e guarda em t1
    add a0, a0, t1 # soma t1 com a0 e guarda em a0

    # 3o digito
    lb t0, 2(a1) # pega a posição 2 de a1 e coloca em t0
    addi t0, t0, -48 # converte pra t0 para int somando -48
    li t1, 10 # coloca 10 em t1
    mul t1, t0, t1 # multiplica t0 por 10
    add a0, a0, t1 # soma t1 com a0 e guarda em a0

    # 4o digito
    lb t0, 3(a1) # pega a posição 3 de a1 e coloca em t0
    addi t0, t0, -48 # converte pra t0 para int somando -48
    # aqui eu não multiplico por nada porque já ta na casa da unidade
    add a0, a0, t0 # soma t0 com a0 e guarda em a0

    ret

intToChar:
    # recebe de input o a0
    # output: s2
    la s2, output

    # 1o digito
    li t0, 1000 # coloca 1000 em t0
    div t1, a0, t0 # divide a0 por t0 e guarda em t1
    addi t1, t1, 48 # soma 48 em t1 e guarda em t1 para converter para char
    sb t1, 0(s2) # coloca t1 na posição 0 de s2 (output)
    rem a0, a0, t0 # calcula o resto da div de a0 por 1000 e guarda em a0

    # 2o digito
    li t0, 100 # coloca 100 em t0
    div t1, a0, t0 # divide a0 por t0 e guarda em t1
    addi t1, t1, 48 # soma t1 com 48 e guarda em t1 pra converter pra char
    sb t1, 1(s2) # coloca t1 na posição 1 de s2 (output)
    rem a0, a0, t0 # calcula o resto da div de a0 por 100 e guarda em a0

    # 3o digito
    li t0, 10 # coloca 10 em t0
    div t1, a0, t0 # caclula a divisão de a0 por t0 e guarda em t1
    addi t1, t1, 48 # soma t1 com 48 e guarda em t1
    sb t1, 2(s2) # coloca t1 na posição 2 de s2 (output)
    rem a0, a0, t0 # resto da div de a0 por 10 e guarda em a0

    # 4o digito
    li t0, 1 # coloca 1 em t0
    div t1, a0, t0 # divide a0 por t0 e guarda em t1
    addi t1, t1, 48 # soma t1 com 48 e guarda em t1
    sb t1, 3(s2) # coloca t1 na posição 3 de s2 (output)

    # adicionar espaço ao final
    li t1, ' ' # coloca um espaço em t1
    sb t1, 4(s2) # adiciona um espaço na posição 4 de s2
    ret

babylonian_method:
    # input: a0 (y)
    # output: a0 (k' aplicado 10x)

    # initial guess
    li t0, 2 # coloca 2 em t0
    div t1, a0, t0 # divide a0 por 2 e guarda em t1 (t1 = y/2); t1 = k

    # aplicar o método
    li t4, 9 # coloca 9 em t4
    inicio:
        div t2, a0, t1 # calcula a0/t1 (y/k) e guarda em t2
        add t2, t1, t2 # calcula t1 + t2 (k + y/k) e guarda em t2
        div t3, t2, t0 # calcula t2/2 ((k+y/k)/2) e guarda em t3 (t3 = k')

    mv t1, t3 # copia t3 para t1 (k = k')
    addi t4, t4, -1 # subtrai 1 de t4
    bge t4, zero, inicio # loop (iterar 10 vezes)
    mv a0, t3 # coloca o valor de t3 em a0 (output)

    ret

_start:
    li s5, 5 # coloca 5 em s5
    li s8, 3 # auxiliar pro loop
    li s9, 3
    li s10, 2
    li s11, 1

    jal read # ler o input do usuário (input = a1)
    mv t6, a1
    
    loop:
        jal charToInt # transformar os 4 primeiros dígitos em um inteiro (int vai pra a0)
        jal babylonian_method # o resultado do método fica em a0
        jal intToChar # o resultado fica guardado no adress do output
        bnez s8, skip_space # condicional pra colocar um '\n' no final do char
        li t0, 10
        sb t0, 4(s2)
        skip_space:
            jal write # printar número
    
    addi t6, t6, 5
    mv a1, t6
    addi s8, s8, -1
    bge s8, zero, loop
    /*
    beq s8, s9, first # se s8 == 3, pula pra first
    beq s8, s10, second # se s8 == 2, pula pra second
    beq s8, s11, third # se s8 == 1, pula pra third

    first:
        addi a1, a1, 5 # atualizar a1
        beq s8, s9, basic # pula pra basic
    second:
        addi a1, a1, 10 # atualizar a1
        beq s8, s10, basic # pula pra basic
    third:
        addi a1, a1, 15 # atualizar a1

    basic:
        addi s8, s8, -1
        bge s8, zero, loop
    */
    
    # exit
    li a0, 0
    li a7, 93
    ecall

.section .bss
output: .skip 0x5 #define a posição de memória para o output
input_address: .skip 0x14  # buffer para ler 20 bytes