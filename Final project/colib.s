# The CoLib layer must implement the routines of the Control API in RISC-V assembly language.
.section .text
.globl set_engine
.globl set_handbrake
.globl read_sensor_distance
.globl get_position
.globl get_rotation
.globl get_time
.globl puts
.globl gets
.globl atoi
.globl itoa
.globl strlen_custom
.globl approx_sqrt
.globl get_distance
.globl fill_and_pop

set_engine:
    li a7, 10
    ecall
    ret

set_handbrake:
    li a7, 11
    ecall
    ret

read_sensor_distance:
    li a7, 13
    ecall
    ret

get_position:
    li a7, 15
    ecall
    ret

get_rotation:
    li a7, 16
    ecall
    ret

get_time:
    li a7, 20
    ecall
    ret

puts:
    # input: ponteiro pra uma string que termina com '\0' (a0)
    # fazer: printar a string toda e no final colocar um '\n'
    addi sp, sp, -4
    sw ra, 0(sp)

    forPuts:
        lb t0, 0(a0)        # pegar o caracter atual
        beqz t0, stopPuts   # se o caracter lido for um '\0', sai do loop

        addi sp, sp, -4     # alocar espaço na pilha
        sw a0, 0(sp)        # salvar a0 antes de pular pra outra função

        la a0, output
        sb t0, 0(a0)        # colocar o caractere lido (t0) no buffer a ser printado
        jal writeByte       # printar o caractere lido
        
        lw a0, 0(sp)        # recuperar o conteúdo de a0
        addi sp, sp, 4      # desalocar espaço na pilha

        addi a0, a0, 1      # passar para o próximo caractere
        j forPuts
    stopPuts:
        li t2, '\n'
        la a0, output
        sb t2, 0(a0)
        jal writeByte       # printar o '\n'
    
    lw ra, 0(sp)            # recuperar ra
    addi sp, sp, 4
    ret

gets:
    # entrada: a0 - ponteiro pra uma string onde será guardado o input
    # output: str com o input (a0)
    addi sp, sp, -4
    sw ra, 0(sp)             # salvar ra

    li t3, 0                 # contador auxiliar - conta o tamanho do input
    mv a3, a0                # a3 <- a0
    forGets:
        la a0, input
        jal readByte         # lê um byte e guarda ele no address de a0 (e retorna o número de bytes lidos em a0)
        la a0, input
        lb a0, 0(a0)         # pegar o byte lido em a0
        li t2, '\n'
        beq a0, t2, stopGets # sai do loop se o caractere lido é um '\n'
        sb a0, 0(a3)         # colocar o char lido no buffer pra guardar o input
        addi a3, a3, 1       # colocar o ponteiro da str uma casa pra direita
        addi t3, t3, 1       # somar 1 no contador de dígitos
        j forGets
    stopGets:
        sb zero, 0(a3)       # colocar o '\0' ao final da string
        sub a0, a3, t3       # subtrair do ponteiro o contador - deixar o a0 apontando pro primeiro caractere lido
    
    lw ra, 0(sp)             # recuperar ra
    addi sp, sp, 4
    ret

atoi:
    # input: (a0) ponteiro pra uma str que termina com '\0'
    # output: converter essa string pra um int
    # ao iterar, ignorar o char lido se ele não estiver entre 48 (incluso) e 57 (incluso)
    li t3, 48
    li t4, 58
    li t5, 10
    li a1, 0                                 # output temporário
    li a2, '-'
    li t6, 1                                 # faz um controle de fluxo pra verificar a presença de '-' na str - se for 0, não tem, c.c, tem.
    forAtoi:
        lb t0, 0(a0)                         # ler o byte "atual"
        beqz t0, stopAtoi                    # sai do loop se o char lido é um '\0'
        bge t0, t4, naoEhInt                 # o char lido não é int se t0 >= 58
        blt t0, t3, naoEhInt                 # o char lido não é int se t0 < 48
        # caso t0 seja int
        addi t0, t0, -48                     # transformar t0 em int
        mul a1, a1, t5                       # multiplicar a1 por 10
        add a1, a1, t0                       # somar a1 com t0 e guardar em a1
        
        naoEhInt:
        bne t0, a2, naoTemSinalDeMenos       # verifica se tem um sinal de '-' no caractere
        li t6, -1                            # indica que esse sinal de '-' existe, então o número final deve ser multiplicado por -1
        naoTemSinalDeMenos:
        addi a0, a0, 1
        j forAtoi

    stopAtoi:
    mul a0, a1, t6                           # verificação do sinal do número
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
            li t0, 0 # '\0'
            sb t0, 0(a3) # colocar o '\0' ao final da str
            mv a0, a1 # colocar o ponteiro do str em a0
    continuaItoa:
    ret

strlen_custom:
    li t1, 0 # contador
    whileStringNaoAcabou:
        lb t0, 0(a0) # pegar o caractere atual
        addi a0, a0, 1
        addi t1, t1, 1
        bnez t0, whileStringNaoAcabou # se o caractere lido não for null, volta
    
    addi a0, t1, -1 # descontar o '\0'
    ret

approx_sqrt:
    # input: a0 (value)
    # input: a1 (número de iterações)
    # output: a0 (k' aplicado 10x)

    # initial guess
    li t0, 2 # coloca 2 em t0
    div t1, a0, t0 # divide a0 por 2 e guarda em t1 (t1 = y/2); t1 = k

    # aplicar o método
    loopSqrt:
        div t2, a0, t1 # calcula a0/t1 (y/k) e guarda em t2
        add t2, t1, t2 # calcula t1 + t2 (k + y/k) e guarda em t2
        div t3, t2, t0 # calcula t2/2 ((k+y/k)/2) e guarda em t3 (t3 = k')

        mv t1, t3         # copia t3 para t1 (k = k')
        addi a1, a1, -1   # subtrai 1 de a1
        bnez a1, loopSqrt # loop (iterar a1 vezes)
    
    mv a0, t3 # coloca o valor de t3 em a0 (output)
    ret

get_distance:
    /*
    Parameters:
        a0: X coordinate of point A.
        a1: Y coordinate of point A.
        a2: Z coordinate of point A.
        a3: X coordinate of point B.
        a4: Y coordinate of point B.
        a5: Z coordinate of point B.
    Returns:
        Euclidean distance between the two points.
    */
    # salvar ra
    addi sp, sp, -4
    sw ra, 0(sp)

    # calcular t0 = (Xb - Xa) = (a3 - a0)
    sub t0, a3, a0
    # calcular t0 = (a3 - a0)^2
    mul t0, t0, t0

    # calcular t1 = (Yb - Ya) = (a4 - a1)
    sub t1, a4, a1
    # calcular t1 = (a4 - a1)^2
    mul t1, t1, t1

    # calcular t2 = (Zb - Za) = (a5 - a2)
    sub t2, a5, a2
    # calcular t2 = (a5 - a2)^2
    mul t2, t2, t2

    # calcular a0 = t0 + t1 + t2
    add t0, t0, t1 # t0 = t0 + t1
    add a0, t0, t2 # a0 = t0+t2
    li a1, 11      # 11 iterações para obter uma aproximação pra raíz
    # obter a0 = sqrt(a0) com 11 iterações
    jal approx_sqrt

    # recuperar ra
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

fill_and_pop:
    /*
    It copies all fields from the head node to the fill node and 
    returns the next node on the linked list (head->next).
    Parameters:
        a0: current head of the linked list
        a1: node struct to be filled with values from the current head node. 
    Returns:
        Next node on the linked list (a0).
    */
    # obter o valor de x
    lw t0, (a0)
    sw t0, (a1)
    # obter o valor de y
    lw t0, 4(a0)
    sw t0, 4(a1)
    # obter o valor de z
    lw t0, 8(a0)
    sw t0, 8(a1)
    # obter a_x
    lw t0, 12(a0)
    sw t0, 12(a1)
    # obter a_y
    lw t0, 16(a0)
    sw t0, 16(a1)
    # obter a_z
    lw t0, 20(a0)
    sw t0, 20(a1)
    # obter action
    lw t0, 24(a0)
    sw t0, 24(a1)
    # obter ponteiro para o próximo node
    lw a0, 28(a0)
    sw a0, 28(a1)
    ret

readByte:
    li a1, 1
    li a7, 17
    ecall
    ret

writeByte:
    li a1, 1
    li a7, 18
    ecall
    ret

.section .bss
input: .skip 20
output: .skip 20