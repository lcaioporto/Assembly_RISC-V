.section .text
.globl read
.globl write
.globl puts
.globl gets
.globl atoi
.globl itoa
.globl linked_list_search
.globl exit

read:
    # guarda o input em a1
    li a0, 0  # file descriptor = 0 (stdin)
    li a2, 1
    la a1, input #  buffer to read the data
    li a7, 63 # syscall read (63)
    ecall
    ret

write:
    # printa o conteúdo de a1
    li a0, 1            # file descriptor = 1 (stdout)
    li a2, 1            # size - 1 byte
    //la a1, output     # buffer
    li a7, 64           # syscall write (64)
    ecall
    ret

puts:
    # input: ponteiro pra uma string que termina com '\0' (a0)
    # fazer: printar a string toda e no final colocar um '\n'
    mv a1, a0 # colocar o ponteiro (a0) em a1
    mv t6, ra
    li t1, 0 # comparador - '\0'
    li t2, '\n'
    forPuts:
        lb t0, 0(a1) # pegar o caracter atual
        beq t0, t1, stopPuts # se o caracter lido for um '\0', sai do loop
        mv t5, a1 # faz isso pra não perder o conteúdo de a1 dps do ecall
        jal write # printar o caractere lido
        mv a1, t5
        addi a1, a1, 1 # passar para o próximo caractere
        j forPuts
    stopPuts:
        //addi a1, a1, 1
        sb t2, 0(a1) # colocar o '\n' no output
        jal write # printar o '\n'
    li a0, 1 # retorno informando que a função funcionou adequadamente
    mv ra, t6
    ret

gets:
    # entrada: a0 - ponteiro pra uma string onde será guardado o input
    # output: str com o input (a0)
    mv t6, ra
    la t1, input
    li t2, '\n'
    li t3, 0 # contador auxiliar - conta o tamanho do input
    li t5, 0 # '\0'
    mv a3, a0
    forGets:
        jal read # le um char
        lb t0, 0(t1) # pegar o char lido
        beq t0, t2, stopGets # sai do loop se o caractere lido é um '\n'
        sb t0, 0(a3) # colocar o char lido no str
        addi a3, a3, 1 # colocar o ponteiro do str uma casa pra direita
        addi t3, t3, 1 # somar 1 no contador de dígitos
        j forGets
    stopGets:
        sb t5, 0(a3) # colocar o '\0' ao final da string
        lb s10, 0(a3)
        neg t3, t3 # pegar o negativo do contador
        add a3, a3, t3 # subtrair do ponteiro o contador - deixar o a3 apontando pro primeiro caractere lido
    mv a0, a3
    mv ra, t6
    ret

atoi:
    # input: (a0) ponteiro pra uma str
    # output: converter essa string pra um int
    # ao iterar, ignorar o char lido se ele não estiver entre 48 (incluso) e 57 (incluso)
    li t1, ' '
    li t2, 0 # '\0'
    li t3, 48
    li t4, 58
    li t5, 10
    li a1, 0 # output temporário
    li a2, '-'
    li t6, 0 # faz um controle de fluxo pra verificar a presença de '-' na str - se for 0, não tem, c.c, tem.
    forAtoi:
        lb t0, 0(a0)
        beq t0, t2, stopAtoi # sai do loop se o char lido é um '\0'
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
    # fazer: converter o int em a0 para um char com '\0' no final
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
            li t0, 0 # '\0'
            sb t0, 0(a3) # colocar o '\0' ao final da str
            mv a0, a1 # colocar o ponteiro do str em a0
        j continuaItoa
    base16:
        # PASSO 1: contar quantos dígitos tem a0
        li t0, 0 # contador
        li t1, 16 # divisor
        mv t2, a0
        forContar16:
            div t2, t2, t1 # dividir a0 por 16 e guardar em t2
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
            div t1, a0, t2 # divide a0 por t2 e guarda em t1
            # se t1 >= 10, pula pra entre0e9
            bge t1, a5, entre10e15
            addi t1, t1, 48 # soma t1 com 48 e guarda em t1 pra converter pra char
            j continualoop
            entre10e15:
                addi t1, t1, 55 # soma 55 se t1 > 55
            continualoop:
            sb t1, 0(a3) # coloca t1 na posição 0 de a3 (output)
            rem a0, a0, t2 # calcula o resto da div de a0 por t2 e guarda em a0
            addi a3, a3, 1 # colocar o ponteiro do str pra direita
            addi a4, a4, -1 # subtrai 1 da quantidade de dígitos restantes pra colocar no output
            div t2, t2, t0 # divide t2 por 16
            j forToChar16
        stopToChar16:
            li t0, 0 # '\0'
            sb t0, 0(a3) # colocar o '\0' ao final da str
            mv a0, a1 # colocar o ponteiro do str em a0
    continuaItoa:
    ret

linked_list_search:
    # input: ponteiro pro head node (a0) e o valor buscado (a1)
    /*
    REGISTRADORES:
    t6: contador de node
    */
    li t5, 10 # '\n'
    mv a5, ra
    li t6, 0 # contador
    lw t1, 0(a0) # primeiro número
    lw t2, 4(a0) # segundo número
    add t1, t1, t2 # somar os dois números e guardar em t1
    beq t1, a1, tem # se t1 for igual ao input, já sai e printa
    enquanto:
        # iterar a linked list
        lw t3, 8(a0) # ler o próximo node
        mv a0, t3 # colocar o node em a0
        beq a0, zero, naoTem # caso não tenha mais node
        lw t1, 0(a0) # ler o primeiro número do próximo node
        lw t2, 4(a0) # ler o segundo número do próximo node
        add t1, t1, t2 # somar e guardar em t1
        addi t6, t6, 1
        beq t1, a1, tem
        j enquanto
    naoTem:
        li t6, -1
    tem:
    mv a0, t6
    mv ra, a5
    ret

exit:
    # input: a0 return code
    li a7, 93
    ecall

.section .bss
input: .skip 10 # buffer para ler 10 bytes
output: .skip 30