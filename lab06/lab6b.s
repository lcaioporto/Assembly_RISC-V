/*
Input:
SDDDD SDDDD\nDDDD DDDD DDDD DDDD\n (32 bytes)
 Yb     Xc    Ta   Tb   Tc   Tr

Output:
SDDDD SDDDD\n (12 bytes)
*/

.section .text
.globl _start

read:
    # guarda o input em a1

    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_address #  buffer to read the data
    li a2, 32  # size (reads only 32 bytes)
    li a7, 63 # syscall read (63)
    ecall
    ret

write:
    # printa o conteúdo de a1

    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output       # buffer
    li a2, 12            # size - 12 bytes
    li a7, 64           # syscall write (64)
    ecall
    ret

babylonian_method:
    # input: a0 (y)
    # output: a0 (k' aplicado 10x)

    # initial guess
    li t0, 2 # coloca 2 em t0
    div t1, a0, t0 # divide a0 por 2 e guarda em t1 (t1 = y/2); t1 = k

    # aplicar o método
    li t4, 20 # coloca 20 em t4
    inicio:
        div t2, a0, t1 # calcula a0/t1 (y/k) e guarda em t2
        add t2, t1, t2 # calcula t1 + t2 (k + y/k) e guarda em t2
        div t3, t2, t0 # calcula t2/2 ((k+y/k)/2) e guarda em t3 (t3 = k')

    mv t1, t3 # copia t3 para t1 (k = k')
    addi t4, t4, -1 # subtrai 1 de t4
    bge t4, zero, inicio # loop (iterar 10 vezes)
    mv a0, t3 # coloca o valor de t3 em a0 (output)

    ret

charToIntComSinal:
    # recebe de input o a1
    # output: a0

    # 1o digito
    lb t0, 1(a1) # pega a posição 0 de a1 e coloca em t0
    addi t0, t0, -48 # converte pra t0 para int somando -48
    li t1, 1000 # coloca 1000 em t1
    mul a0, t0, t1 # multiplica t0 por 1000 e guarda em a0

    # 2o digito
    lb t0, 2(a1) # pega a posição 1 de a1 e coloca em t0
    addi t0, t0, -48 # converte pra t0 para int somando -48
    li t1, 100 # coloca 100 em t1
    mul t1, t0, t1 # multiplica t0 por 100 e guarda em t1
    add a0, a0, t1 # soma t1 com a0 e guarda em a0

    # 3o digito
    lb t0, 3(a1) # pega a posição 2 de a1 e coloca em t0
    addi t0, t0, -48 # converte pra t0 para int somando -48
    li t1, 10 # coloca 10 em t1
    mul t1, t0, t1 # multiplica t0 por 10
    add a0, a0, t1 # soma t1 com a0 e guarda em a0

    # 4o digito
    lb t0, 4(a1) # pega a posição 3 de a1 e coloca em t0
    addi t0, t0, -48 # converte pra t0 para int somando -48
    # aqui eu não multiplico por nada porque já ta na casa da unidade
    add a0, a0, t0 # soma t0 com a0 e guarda em a0

    # Sinal
    lb t0, 0(a1)
    # 43: '+'; 45: '-'
    li t1, 45 # coloca 45 ('-') em t1
    beq t0, t1, negativeNumber # caso t0 == t1 (sinal negativo), pule pra negativeNumber
    li t1, 43 # coloca 43 em t1 ('+')
    beq t0, t1, positiveNumber # caso t0 == t1 (sinal positivo), pule pra positive Number
    negativeNumber:
        li t1, -1 # coloca -1 em t1
        mul a0, a0, t1 # multiplica a0 por -1 e guarda em a0
    positiveNumber:
        ret

charToIntSemSinal:
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

xIntToChar:
    # recebe de input o a0 (*PULAR O SINAL*)
    # output: guardar o X no output
    la s2, output

    # 1o digito
    li t0, 1000 # coloca 1000 em t0
    div t1, a0, t0 # divide a0 por t0 e guarda em t1
    addi t1, t1, 48 # soma 48 em t1 e guarda em t1 para converter para char
    sb t1, 1(s2) # coloca t1 na posição 1 de s2 (output)
    rem a0, a0, t0 # calcula o resto da div de a0 por 1000 e guarda em a0

    # 2o digito
    li t0, 100 # coloca 100 em t0
    div t1, a0, t0 # divide a0 por t0 e guarda em t1
    addi t1, t1, 48 # soma t1 com 48 e guarda em t1 pra converter pra char
    sb t1, 2(s2) # coloca t1 na posição 2 de s2 (output)
    rem a0, a0, t0 # calcula o resto da div de a0 por 100 e guarda em a0

    # 3o digito
    li t0, 10 # coloca 10 em t0
    div t1, a0, t0 # caclula a divisão de a0 por t0 e guarda em t1
    addi t1, t1, 48 # soma t1 com 48 e guarda em t1
    sb t1, 3(s2) # coloca t1 na posição 3 de s2 (output)
    rem a0, a0, t0 # resto da div de a0 por 10 e guarda em a0

    # 4o digito
    li t0, 1 # coloca 1 em t0
    div t1, a0, t0 # divide a0 por t0 e guarda em t1
    addi t1, t1, 48 # soma t1 com 48 e guarda em t1
    sb t1, 4(s2) # coloca t1 na posição 4 de s2 (output)

    # adicionar espaço ao final
    li t1, ' ' # coloca um espaço em t1
    sb t1, 5(s2) # adiciona um espaço na posição 5 de s2

    ret

yIntToChar:
    # recebe de input o a0 (*PULAR O SINAL*)
    # output: s2
    la s2, output

    # 1o digito
    li t0, 1000 # coloca 1000 em t0
    div t1, a0, t0 # divide a0 por t0 e guarda em t1
    addi t1, t1, 48 # soma 48 em t1 e guarda em t1 para converter para char
    sb t1, 7(s2) # coloca t1 na posição 0 de s2 (output)
    rem a0, a0, t0 # calcula o resto da div de a0 por 1000 e guarda em a0

    # 2o digito
    li t0, 100 # coloca 100 em t0
    div t1, a0, t0 # divide a0 por t0 e guarda em t1
    addi t1, t1, 48 # soma t1 com 48 e guarda em t1 pra converter pra char
    sb t1, 8(s2) # coloca t1 na posição 1 de s2 (output)
    rem a0, a0, t0 # calcula o resto da div de a0 por 100 e guarda em a0

    # 3o digito
    li t0, 10 # coloca 10 em t0
    div t1, a0, t0 # caclula a divisão de a0 por t0 e guarda em t1
    addi t1, t1, 48 # soma t1 com 48 e guarda em t1
    sb t1, 9(s2) # coloca t1 na posição 2 de s2 (output)
    rem a0, a0, t0 # resto da div de a0 por 10 e guarda em a0

    # 4o digito
    li t0, 1 # coloca 1 em t0
    div t1, a0, t0 # divide a0 por t0 e guarda em t1
    addi t1, t1, 48 # soma t1 com 48 e guarda em t1
    sb t1, 10(s2) # coloca t1 na posição 3 de s2 (output)

    # adicionar \n ao final
    li t1, 10 # coloca um \n em t1
    sb t1, 11(s2) # adiciona um \n na posição 11 de s2

    ret

calcDa:
    # calcular a distância entre eu e o satélite A
    # input: s3 (Ta), a3 (Tr)
    # output: a4 (Da)
    li t2, 3
    li t3, 10

    sub t0, a3, s3 # faz (Tr - Ta) e guarda em t0
    # multiplicar pela velocidade (*0,3)
    mul a4, t0, t2 # faz (Tr - Ta)*3 e guarda em a4 (output)
    div a4, a4, t3 # faz (Tr - Ta)*3/10 e guarda em a4 (output)

    ret

calcDb:
    # calcular a distância entre eu e o satélite B
    # input: s4 (Tb), a3 (Tr)
    # output: a5 (Db)
    li t2, 3
    li t3, 10

    sub t0, a3, s4 # faz (Tr - Tb) e guarda em t0
    # multiplicar pela velocidade (*0,3)
    mul a5, t0, t2 # faz (Tr - Tb)*3 e guarda em a5 (output)
    div a5, a5, t3 # faz (Tr - Tb)*0,3 e guarda em a5 (output)

    ret

calcDc:
    # calcular a distância entre eu e o satélite C
    # input: s5 (Tc), a3 (Tr)
    # output: a6 (Dc)
    li t2, 3
    li t3, 10

    sub t0, a3, s5 # faz (Tr - Tc) e guarda em t0
    # multiplicar pela velocidade (*0,3)
    mul a6, t0, t2 # faz (Tr - Tc)*3 e guarda em a6 (output)
    div a6, a6, t3 # faz (Tr - Tc)*0,3 e guarda em a6 (output)

    ret

calcY:
    # calcular o valor da minha coordenada y
    # input: a4 (Da), a5 (Db), s10 (Yb)
    # output: s0 (y)

    mul t0, a4, a4 # faz Da**2 e guarda em t0
    mul t1, s10, s10 # faz Yb**2 e guarda em t1
    mul t2, a5, a5 # faz Db**2 e guarda em t2
    slli t3, s10, 1 # faz 2Yb
    //li t3, 2 # coloca 2 em t3
    //mul t3, s10, t3 # faz (2*Yb) e guarda em t3
    /*
        t0 = Da^2
        t1 = Yb^2
        t2 = Db^2
        t3 = 2Yb
    */
    add t0, t0, t1 # faz (Da**2 + Yb**2) e guarda em t0
    sub t0, t0, t2 # faz (Da**2 + Yb**2 - Db**2) e guarda em t0
    div s0, t0, t3 # faz (Da**2 + Yb**2 - Db**2)/(2*Yb) e guarda em s0 (output)

    ret

calcX:
    # calcular o valor da minha coordenada x
    # input: a4 (Da), s0 (y), s9 (Xc), a6 (Dc)
    # output: s1 (x)
    mv s11, ra # coloca em s11 o valor de ra (pra n perder o endereço da _start)

    # aplicar a fórmula
    mul t0, a4, a4 # faz (Da**2) e guarda em t0
    mul t1, s0, s0 # faz (y**2) e guarda em t1
    sub t0, t0, t1 # faz (Da**2 - y**2) e guarda em t0
    mv a0, t0 # coloca t0 em a0 pra chamar a babylonian_method
    jal babylonian_method # calcula (Da**2 - y**2)**(1/2) e devolve o valor em a0
    mv t0, a0 # coloca em t0 o a0
    li t1, -1 # coloca -1 em t1
    mul t1, t0, t1 # multiplica t0 por t1 (-1) e guarda em t1

    # t0: x = sqrt(Da^2 - y^2)
    # t1: x = -sqrt(Da^2 - y^2)

    #comparar os valores usando a Eq. 3 ((x - Xc)^2 + y^2 = Dc^2)

    mul t6, a6, a6 # faz (Dc^2) e guarda em t6

    # caso 1: t0 - calcular o valor comparativo 1 (t2)
    sub t4, t0, s9 # faz (x - Xc) e guarda em t4
    mul t4, t4, t4 # faz (x - Xc)**2 e guarda e t4
    mul t5, s0, s0 # faz (y)^2 e guarda em t5
    add t4, t4, t5 # faz (x - Xc)**2 + (y)^2 e guarda em t4
    sub t2, t4, t6 # faz ((x - Xc)**2 + (y)^2) - Dc^2 pra comparar - guarda em t2

    mul t2, t2, t2
   
    # caso 2: t1
    sub t4, t1, s9 # faz (x - Xc) e guarda em t4
    mul t4, t4, t4 # faz (x - Xc)**2 e guarda e t4
    mul t5, s0, s0 # faz (y)^2 e guarda em t5
    add t4, t4, t5 # faz (x - Xc)**2 + (y)^2 e guarda em t4
    sub t3, t4, t6 # faz ((x - Xc)**2 + (y)^2) - Dc^2 pra comparar - coloca em t3 (valor comparativo 2_

    mul t3, t3, t3

    # vamos chutar que estamos no caso em que t0 é o valor mais adequado, ou seja, t2 < t3
    mv s1, t0 # coloca t0 em s1 (output)
    # mas, se t3 < t2, então vamos pular e colocar t1 em s1 (output)
    bltu t2, t3, t2MenorQuet3 # if (t2 < t3) - skip o trecho t3MenorQuet2

    # caso t3 < t2, t1 é o valor mais adequado
    mv s1, t1 # coloca t1 em s1 (output)

    t2MenorQuet3:
        mv ra, s11 # coloca a posição da _start de novo em ra
        ret # retorna a função
    
_start:
    jal read # lê todo o input de 32 bytes e guarda em a1

    # converter os inputs pra char e salvar nos registradores reservados

    # Yb
    jal charToIntComSinal # pegar o Yb em a0
    mv s10, a0 # colocar o Yb no registrador reservado pra ele (s10)
    addi a1, a1, 6 # mover o ponteiro a1 6 casas para a direita (ir para o próx. número)

    # Xc
    jal charToIntComSinal # pegar o Xc em a0
    mv s9, a0 # colocar Xc no registrador reservado pra ele (s9)
    addi a1, a1, 6 # somar 6 no ponteiro de a1 pra ele apontar pro próx. número

    # Ta
    jal charToIntSemSinal # pegar o Ta em a0
    mv s3, a0 # colocar Ta no registrador reservado para ele (s3)
    addi a1, a1, 5 # mover o ponteiro a1 5 casas para a direita (ler o próx. número)

    # Tb
    jal charToIntSemSinal # pegar o Tb em a0
    mv s4, a0 # colocar Ta no registrador reservado para ele (s4)
    addi a1, a1, 5 # mover o ponteiro a1 5 casas para a direita (ler o próx. número)

    # Tc
    jal charToIntSemSinal # pegar o Tc em a0
    mv s5, a0 # colocar Ta no registrador reservado para ele (s5)
    addi a1, a1, 5 # mover o ponteiro a1 5 casas para a direita (ler o próx. número)

    # Tr
    jal charToIntSemSinal # pegar o Tr em a0
    mv a3, a0 # colocar Ta no registrador reservado para ele (a3)

    # manipular os dados

    # 1) calcular Da, Db, Dc
    jal calcDa # calc. Da e salva em a4
    jal calcDb # calc. Db e salva em a5
    jal calcDc # calc. Dc e salva em a6

    # 2) calcular X e Y
    jal calcY # calc. Y e salva em s0
    jal calcX # calc. X e salva em s1

    # printar os resultados
    # 43: '+'; 45: '-'

    la s8, output # coloca o endereço de output em s8 - auxiliar pra colocar os sinais

    # printar X
    
    #primeiro, vamos supor que x > 0
    li t1, 43 # coloca '+' em t1
    sb t1, 0(s8) # coloca o '+' na posição 0 do endereço do output
    # agora vamos avaliar os casos
    //blt s1, zero, xNegativo # caso x < 0
    blt zero, s1, xPositivo # caso x > 0

    //xNegativo: # coloca um sinal de '-' na posição 0 de output
    li t1, 45 # coloca '-' em t1
    sb t1, 0(s8)
    neg s1, s1

    xPositivo: # segue o código normalmente pq o sinal já foi colocado
    mv a0, s1 # coloca o valor de s1 em a0
    jal xIntToChar # chama xIntToChar, que converte o valor de a0 (x) em char e já coloca no endereço de output adequadamente

    # printar Y

    #primeiro, vamos supor que y > 0
    li t1, 43 # coloca '+' em t1
    sb t1, 6(s8) # coloca o '+' na posição 6 do endereço do output
    # agora vamos avaliar os casos
    blt s0, zero, yNegativo # caso y < 0
    blt zero, s0, yPositivo # caso y > 0

    yNegativo: # coloca um sinal de '-' na posição 6 de output
        li t1, 45
        sb t1, 6(s8)
        neg s0, s0
    
    yPositivo: # segue o código normalmente pq o sinal já foi colocado
        mv a0, s0 # coloca o valor de s0 (y) em a0
        jal yIntToChar # chama yIntToChar, que converte o valor de a0 (y) em char e já coloca no endereço de output adequadamente

    #print

    jal write

    # exit
    li a0, 0
    li a7, 93
    ecall

.section .bss
output: .skip 0xC #define a posição de memória para o output (12 Bytes)
input_address: .skip 0x20  # buffer para ler 32 bytes