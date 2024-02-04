.section .text
.globl _start

readByte:
    sb s1, 2(s0) # ler um byte de input
    forRead:
        lb t0, 2(s0) # verificar se o input ainda está lendo
        beqz t0, stopRead # se t0 == 0, significa que o input terminou de ler
        j forRead
    stopRead:
    lb a0, 3(s0) # guarda o byte lido em a0
    ret

writeByte:
    # printa o valor que está em 1(s0)
    sb s1, 0(s0) # ativar a write
    forWrite:
        lb t0, 0(s0)
        beqz t0, stopWrite # se t0 == 0, terminou de printar
        j forWrite
    stopWrite:
    ret

executeOperation1:
    li t1, '\n'
    for1:
        # ler até encontrar um '\n'
        jal readByte
        sb a0, 1(s0) # colocar a0 como valor a ser printado
        jal writeByte # printar
        beq a0, t1, stop1 # se o byte lido for '\n', sai do loop
        j for1
    stop1:
    j exit

executeOperation2:
    li t1, '\n'
    la t2, output
    li t3, 0 # contador auxiliar
    for2:
        # ler até encontrar um '\n'
        jal readByte
        sb a0, 0(t2) # colocar o valor lido (a0) no vetor do output (t2)
        beq a0, t1, stop2 # se o byte lido for '\n', sai do loop
        addi t2, t2, 1
        addi t3, t3, 1
        j for2
    stop2:
    # printar o output invertido
    forPrintarInvertido:
        addi t2, t2, -1
        addi t3, t3, -1
        lb t4, 0(t2)
        sb t4, 1(s0)
        jal writeByte
        beqz t3, stopPrintarInvertido
        j forPrintarInvertido
    stopPrintarInvertido:
    sb t1, 1(s0)
    jal writeByte
    j exit

executeOperation3:
    li t1, '\n'
    la t2, input
    li t3, 0
    for3:
        # ler até encontrar um '\n'
        jal readByte
        sb a0, 0(t2) # colocar o valor lido (a0) no vetor do input (t2)
        beq a0, t1, stop3 # se o byte lido for '\n', sai do loop
        addi t2, t2, 1
        addi t3, t3, 1
        j for3
    stop3:
    sub a0, t2, t3 # fazer a0 apontar para o primeiro dígito (a0 = t2 - t3)
    li a3, '\n' # condição de parada da atoi
    jal atoi # converter o número pra int
    la a1, output
    li a2, 16
    jal itoa
    # o número convertido para hexadecimal está em a0
    forPrintOp3: # printar até o '\n'
        lb t0, 0(a0)
        sb t0, 1(s0)
        jal writeByte
        beq t0, t1, stopPrintOp3
        addi a0, a0, 1
        j forPrintOp3
    stopPrintOp3:
    j exit

executeOperation4:
    li t1, ' '
    la t2, input
    li t3, 0
    li s8, '+'
    li s9, '-'
    li s10, '*'
    li s11, '/'
    forPrimeiroNumero:
        # ler até encontrar um ' '
        jal readByte
        sb a0, 0(t2) # colocar o valor lido (a0) no vetor do input (t2)
        beq a0, t1, stopPrimeiroNumero # se o byte lido for ' ', sai do loop
        addi t2, t2, 1
        addi t3, t3, 1
        j forPrimeiroNumero
    stopPrimeiroNumero:
    sub a0, t2, t3 # fazer a0 apontar para o primeiro dígito (a0 = t2 - t3)
    li a3, ' ' # condição de parada da atoi
    jal atoi # converter o número pra int - fica em a0
    mv s5, a0 # primeiro número fica em s5
    primeiroNumeroLidoAAAAAAAAA:
    jal readByte # ler a operação
    mv s6, a0 # a operação fica em s6

    jal readByte # ler o espaço entre o sinal e o segundo número

    li t1, '\n' # condição de parada do segundo número
    la t2, input
    li t3, 0

    forSegundoNumero:
        # ler até encontrar um '\n'
        jal readByte
        sb a0, 0(t2) # colocar o valor lido (a0) no vetor do input (t2)
        beq a0, t1, stopSegundoNumero # se o byte lido for '\n', sai do loop
        addi t2, t2, 1
        addi t3, t3, 1
        j forSegundoNumero
    stopSegundoNumero:
    sub a0, t2, t3 # fazer a0 apontar para o primeiro dígito (a0 = t2 - t3)
    li a3, '\n' # condição de parada da atoi
    jal atoi # converter o número pra int - fica em a0
    mv s7, a0 # segundo número fica em s7
    segundoNumeroLidoAAAAAAAAA:
    # Avaliar a operação
    beq s6, s8, soma
    beq s6, s9, subtracao
    beq s6, s10, multiplicacao
    beq s6, s11, divisao
    soma:
        add a0, s5, s7
        j finishAndPrint
    subtracao:
        sub a0, s5, s7
        j finishAndPrint
    multiplicacao:
        mul a0, s5, s7
        j finishAndPrint
    divisao:
        div a0, s5, s7
    finishAndPrint:
        la a1, output
        li a2, 10
        jal itoa # converter a0, resultado da operação, em uma string com final '\n'
        forPrintOp4: # printar até o '\n'
            lb t0, 0(a0)
            sb t0, 1(s0)
            jal writeByte
            beq t0, t1, stopPrintOp4
            addi a0, a0, 1
            j forPrintOp4
    stopPrintOp4:
    j exit

atoi:
    # input: (a0) ponteiro pra uma str
    # input (a3) condição de parada da string
    # output: converter essa string pra um int
    # ao iterar, ignorar o char lido se ele não estiver entre 48 (incluso) e 57 (incluso)
    li t1, ' '
    # li t2, '\n'
    li t3, 48
    li t4, 58
    li t5, 10
    li a1, 0 # output temporário
    li a2, '-'
    li t6, 0 # faz um controle de fluxo pra verificar a presença de '-' na str - se for 0, não tem, c.c, tem.
    forAtoi:
        lb t0, 0(a0)
        beq t0, a3, stopAtoi # sai do loop se o char lido é igual a a3
        bge t0, t4, naoEhInt # o char lido não é int se t0 >= 58
        blt t0, t3, naoEhInt # o char lido não é int se t0 < 48
        # caso t0 seja int
        addi t0, t0, -48 # transformar t0 em int
        mul a1, a1, t5 # multiplicar a1 por 10
        add a1, a1, t0 # somar a1 com t0 e guardar em a1
        naoEhInt:
            bne t0, a2, naoTemSinalDeMenos # verifica se tem um sinal de '-' no caractere
            li t6, 1 # indica que esse sinal de '-' existe, então o número final deve ser multiplicado por -1
            naoTemSinalDeMenos:
                addi a0, a0, 1
                j forAtoi
    stopAtoi:
        li t0, 0
        beq t6, t0, numeroPositivo # verifica se tem um sinal de '-'
        neg a1, a1 
        numeroPositivo:
            mv a0, a1
    ret

itoa:
    # a0: (int) valor de input
    # a1: (* char) ponteiro pra str do output
    # a2: (int) base a ser usada - 10 ou 16
    # fazer: converter o int em a0 para um char com '\n' no final
    li t0, 16
    beq a2, t0, base16
    base10:
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
        addi t0, t0, - 1  # número de dígitos - 1
        li t2, 1
        elevar10:
            beqz t0, stopElevar10
            mul t2, t1, t2
            addi t0, t0, -1
            j elevar10
        stopElevar10:
        # OBS: t2 = 10^(número de dígitos - 1)
        # PASSO 3: aplicar o algoritmo pra passar pra char
        mv a3, a1 # passar o ponteiro do str pra a3, pra modificar apenas esse ponteiro cópia, e não o original
        li t0, 10
        bge a0, zero, forToChar # se a0 > 0, não precisa colocar um sinal de '-'
        # caso a0 < 0, colocar o sinal de '-' na frente
        li t5, '-'
        sb t5, 0(a3)
        addi a3, a3, 1
        neg a0, a0
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
            sb t0, 0(a3) # colocar o '\n' ao final da str
            mv a0, a1 # colocar o ponteiro do str em a0
        j continuaItoa
    base16:
        # PASSO 1: contar quantos dígitos tem a0
        li t0, 0 # contador
        li t1, 16 # divisor
        mv t2, a0
        forContar16:
            divu t2, t2, t1 # dividir a0 por 16 e guardar em t2
            addi t0, t0, 1 # adicionar no contador
            beqz t2, stopContar16 # sai do loop se t2 == 0
            j forContar16
        stopContar16:
        mv a4, t0 # salvar a quantidade de dígitos em a4
        # PASSO 2: fazer 16^(número de dígitos - 1)
        addi t0, t0, -1  # número de dígitos - 1
        li t2, 1
        elevar16:
            beqz t0, stopElevar16
            mul t2, t1, t2
            addi t0, t0, -1
            j elevar16
        stopElevar16:
        # OBS: t2 = 16^(número de dígitos - 1)
        # PASSO 3: aplicar o algoritmo pra passar pra char
        mv a3, a1 # passar o ponteiro do str pra a3, pra modificar apenas esse ponteiro cópia, e não o original
        li t0, 16
        li a5, 10
        forToChar16:
            beqz a4, stopToChar16 # se não tiver mais nenhum dígito pra colocar no output, sai do loop
            divu t1, a0, t2 # divide a0 por t2 e guarda em t1
            # se t1 >= 10, pula pra entre0e9
            bge t1, a5, entre10e15
            addi t1, t1, 48 # soma t1 com 48 e guarda em t1 pra converter pra char
            j continualoop
            entre10e15:
                addi t1, t1, 55 # soma 55 se t1 > 55
            continualoop:
            sb t1, 0(a3) # coloca t1 na posição 0 de a3 (output)
            remu a0, a0, t2 # calcula o resto da div de a0 por t2 e guarda em a0
            addi a3, a3, 1 # colocar o ponteiro do str pra direita
            addi a4, a4, -1 # subtrai 1 da quantidade de dígitos restantes pra colocar no output
            divu t2, t2, t0 # divide t2 por 16
            j forToChar16
        stopToChar16:
            li t0, 10 # '\n'
            sb t0, 0(a3) # colocar o '\n' ao final da str
            mv a0, a1 # colocar o ponteiro do str em a0
    continuaItoa:
    ret

_start:
    la s0, base_adress # serial port: base memory address
    lw s0, 0(s0)
    la s2, input # registrador separado para o input
    li s1, 1 # registrador reservado para o número 1
    # regitradores auxiliares para comparação de valores
    li t2, 2
    li t3, 3
    li t4, 4

    # Ler a operação
    jal readByte
    mv t0, a0
    addi t0, t0, -48 # converter pra int
    mv a1, t0
    jal readByte # pular '\n'
    mv t0, a1
    # Verificar qual operação deve ser feita
    beq t0, s1, executeOperation1
    beq t0, t2, executeOperation2
    beq t0, t3, executeOperation3
    beq t0, t4, executeOperation4

exit:
    # exit
    li a0, 0
    li a7, 93
    ecall

.section .bss
input: .skip 10000
output: .skip 10000
.section .data
base_adress: .word 0xFFFF0100