.section .text
.globl _start
/*
REGISTRADORES:
s0: endereço do input
s1: número que deseja-se procurar (input)
s2: output
*/
readNumber:
    # guarda o input em a1
    li a0, 0  # file descriptor = 0 (stdin)
    li a2, 10
    la a1, input #  buffer to read the data
    li a7, 63 # syscall read (63)
    ecall
    ret

write:
    # printa o conteúdo de a1

    li a0, 1            # file descriptor = 1 (stdout)
    li a2, 20            # size - 20 bytes
    la a1, output       # buffer
    li a7, 64           # syscall write (64)
    ecall
    ret

charToInt:
    # recebe de input o s0
    # output com o número
    # Verificar o sinal
    li s11, 1 # indicador de número positivo ou negativo. Se s11 == -1, o número é negativo; c.c o número é positivo
    lb t0, 0(s0) # pegar o primeiro dígito
    li t1, 45 # coloca 45 ('-') em t1
    beq t0, t1, negativeNumber # se o primeiro dígito for um '-', o número é negativo
    j positiveNumber
    negativeNumber:
        li s11, -1
        addi s0, s0, 1 # pular o sinal
    positiveNumber:

    li t1, 32 # ascii do espaço
    li t2, 0 # acumulador
    li t3, 10 # multiplicador
    enquantoNumero:
        lbu t4, 0(s0)
        beq t4, t3, contNumero # sai do loop se t4 ler um \n
        addi t4, t4, -48 # transformar em int
        mul t2, t2, t3 # multiplicar t2 por 10
        add t2, t2, t4 # somar t2 com t4 e guardar em t2
        addi s0, s0, 1
        j enquantoNumero
    contNumero:
        mv s1, t2 # deixar o resultado guardado em s1

    # Sinal
    li t0, 0
    mul s1, s1, s11 # determinar o sinal do número
    ret

buscarIndex:
    /*
    REGISTRADORES:
    t6: contador de node
    */
    la s2, output
    li t5, 10 # '\n'
    mv s11, ra
    li t6, 0 # contador
    la t0, head_node # node inicial
    lw t1, 0(t0) # primeiro número
    lw t2, 4(t0) # segundo número
    debugando:
    add t1, t1, t2 # somar os dois números e guardar em t1
    beq t1, s1, stopAndPrint # se t1 for igual ao input, já sai e printa
    enquanto:
        lw t3, 8(t0) # ler o próximo node
        mv t0, t3 # colocar o node em t0
        beq t0, zero, naoTem # caso não tenha mais node
        lw t1, 0(t0) # ler o primeiro número do próximo node
        lw t2, 4(t0) # ler o segundo número do próximo node
        add t1, t1, t2 # somar e guardar em t1
        addi t6, t6, 1
        beq t1, s1, stopAndPrint
        j enquanto
    stopAndPrint:
        jal intToChar
        jal write
        j tem
    naoTem:
        li t4, 45 # colocar o '-'
        li t6, 49 # código ascii pro 1
        sb t4, 0(s2)
        sb t6, 1(s2)
        sb t5, 2(s2)
        jal write
    tem:
    mv ra, s11
    ret

intToChar:
    //converter t6 pra char e printar
    mv s10, ra
    mv a0, t6
    la a3, output
    # PASSO 1: contar quantos dígitos tem a0
        li t0, 0 # contador
        li t1, 10 # divisor
        mv t2, a0
        forContar:
            div t2, t2, t1 # dividir a0 por 10 e guardar em t2
            addi t0, t0, 1 # adicionar no contador
            beqz t2, stopContar # sai do loop se t2 == 0
            j forContar
        stopContar:
        mv a4, t0 # salvar a quantidade de dígitos em a4
        # PASSO 2: fazer 10^(número de dígitos - 1)
        addi t0, t0, -1  # número de dígitos - 1
        li t2, 1
        elevar10:
            beqz t0, stopElevar10
            mul t2, t1, t2
            addi t0, t0, -1
            j elevar10
        stopElevar10:
        # OBS: t2 = 10^(número de dígitos - 1)
        # PASSO 3: aplicar o algoritmo pra passar pra char
        li t0, 10
        bge a0, zero, forToChar # se a0 > 0, não precisa colocar um sinal de '-'
        # caso a0 < 0, colocar o sinal de '-' na frente
        li t5, '-'
        sb t5, 0(a3)
        addi a3, a3, 1
        forToChar:
            beqz a4, stopToChar # se não tiver mais nenhum dígito pra colocar no output, sai do loop
            div t1, a0, t2 # divide a0 por t2 e guarda em t1
            addi t1, t1, 48 # soma t1 com 48 e guarda em t1 pra converter pra char
            sb t1, 0(a3) # coloca t1 na posição 0 de a3 (output)
            rem a0, a0, t2 # calcula o resto da div de a0 por t2 e guarda em a0
            addi a3, a3, 1 # colocar o ponteiro do str pra direita
            addi a4, a4, -1 # subtrai 1 da quantidade de dígitos restantes pra colocar no output
            div t2, t2, t0 # divide t2 por 10
            j forToChar
        stopToChar:
            li t0, '\n'
            sb t0, 0(a3) # colocar o '\0' ao final da str
            mv a0, a1 # colocar o ponteiro do str em a0
    stop:
        mv ra, s10
        ret

_start:
    jal readNumber
    la s0, input
    jal charToInt # input fica em s1
    jal buscarIndex
    # exit
    li a0, 0
    li a7, 93
    ecall

.section .bss
input: .skip 10 # buffer para ler 10 bytes
output: .skip 30