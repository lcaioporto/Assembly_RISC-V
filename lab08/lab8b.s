.section .text
.globl _start
/*
Registradores reservados:
s0: endereço do input
s1: largura
s2: altura
s3: largura * altura (número de elementos da imagem)
s4: file descriptor do input
s5: endereço da matriz de filtragem
*/

read:
    # guarda o input em a1
    
    li a2, 262179 
    la a1, input #  buffer to read the data
    li a7, 63 # syscall read (63)
    mv a0, s4 # set fd
    ecall
    ret

openArq:
    la a0, input_file    # address for the file path
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # mode
    li a7, 1024          # syscall open 
    ecall
    ret

setCanvasSize:
    # a0: canvas width (0-512)
    # a1: canvas height (0-512)
    # caracteres: 3-9 contém o tamanho do canvas a ser colocado
    addi s0, s0, 3 # pular o P5 e o espaço inicial
    # largura
    li t1, 32 # ascii do espaço
    li t2, 0 # acumulador
    li t3, 10 # multiplicador
    enquantoLargura:
        lbu t4, 0(s0)
        beq t4, t1, contLargura # sai do loop se t4 ler um caracter de espaço
        beq t4, t3, contLargura # sai do loop se t4 ler um \n
        addi t4, t4, -48 # transformar em int
        mul t2, t2, t3 # multiplicar t2 por 10
        add t2, t2, t4 # somar t2 com t4 e guardar em t2
        addi s0, s0, 1
        j enquantoLargura
    contLargura:
        mv a0, t2 # deixar o resultado guardado em a0
    
    # altura
    addi s0, s0, 1 # pular o espaço entre os dígitos da largura e os dígitos da altura
    li t2, 0 # acumulador
    enquantoAltura:
        lbu t4, 0(s0)
        beq t4, t1, contAltura # sai do loop se t4 ler um caracter de espaço
        beq t4, t3, contAltura # sai do loop se t4 ler um \n
        addi t4, t4, -48 # transformar em int
        mul t2, t2, t3 # multiplicar t2 por 10
        add t2, t2, t4 # somar t2 com t4 e guardar em t2
        addi s0, s0, 1
        j enquantoAltura
    contAltura:
        mv a1, t2 # deixar o resultado guardado em a1
    
    mv s1, a0 # guarda a largura em s1
    mv s2, a1 # guarda a altura em s2
    # syscall
    li a7, 2201
    ecall

    addi s0, s0, 5 # pular o maxval (255) e o \n - deixar o s0 apontando para o primeiro pixel da imagem
    ret

iterarPixels:
    # iterar pixel a pixel para ir printando no output
    # começar a ler a partir do segundo elemento da da segunda linha
    /*
    REGISTRADORES TEMPORÁRIOS:
    s9: x iteração maior
    s10: y iteração maior
    t1: iteração em k
    t2: iteração em q
    t6: igual a 2 - verificador dos loops de q e k
    s6: acumulador do somatório para cálculo de Mout[i][j]
    */
    li t6, 2 # verificador dos loops q,k
    li s6, 0 # acumulador do somatório
    li s10, 1 # y deve começar em 1: iterar a partir da primeira linha
    forY:
        li s9, 1 # x começa no segundo elemento
        forX:
            # setar a0 (X) e a1 (Y) do OUTPUT
            mv a0, s9 # j - coluna
            mv a1, s10 # i - linha
            
            li s6, 0 # zerar o acumulador do loop k,q

            li t1, 0 # k
            enquantoK:
                li t2, 0 # q
                enquantoQ:
                    # inicializar registradores
                    li s8, 0
                    li s11, 0
                    li t4, 0
                    li s7, 0
                    
                    # 1) acessar t3 = w[k][q]
                    lb t3, 0(s5) # pega em t3 o w[k][q]

                    # 2) acessar s8 = Win[i+k-1][j+q-1]

                        # a) calcular t4 = i+k-1
                        add t4, a1, t1 # i+k
                        addi t4, t4, -1 # i+k-1

                        # b) calcular s7 = j+q-1
                        add s7, t2, a0 # j+q
                        addi s7, s7, -1 # j+q-1

                        # c) acessar s8 = Win[t4][s7]
                        mul s8, t4, s1 # t4 * número de colunas
                        add s8, s8, s7 # somar s7
                        add s11, s0, s8 # pular o s0 até acessar o elemento desejado
                        lbu s8, 0(s11) # acessar a posição

                    # multiplicar t3 = w[k][q]*Win[i+k-1][j+q-1]
                    mul t3, t3, s8

                    add s6, s6, t3 # adicionar no acumulador
                    addi s5, s5, 1 # somar 1 na posição do pixel atual de w
                    beq t2, t6, contQ # se q == 2, sai do loop
                    addi t2, t2, 1 # aumentar q
                    j enquantoQ
                contQ:
                    beq t1, t6, contK # se k == 2, sai do loop
                    addi t1, t1, 1
                    j enquantoK
            contK:
                la s5, w # recuparar o endereço inicial de w

            # fazer as comparações pro valor do pixel - Resultado ta em t3
            # se pixel < 0, então pixel = 0; se pixel > 255, então pixel = 255
            li t5, 255 # coloca 255 em t5
            blt s6, zero, pixelMenor0 # se s6 < 0, pula pra pixelMenor0
            bge s6, t5, pixelMaior255 # se s6 >= 255, pula pra pixelMaior255
            j contNormal
            pixelMenor0:
                li s6, 0
                j contNormal
            pixelMaior255:
                li s6, 255
            
            contNormal:
                # setar o a2
                slli t4, s6, 24
                slli t0, s6, 16
                slli t2, s6, 8

                li a2, 255
                add a2, a2, t4
                add a2, a2, t0
                add a2, a2, t2
            # setPixel
            # a0: coordenada X
            # a1: coordenada Y
            # a2: cor
            li a7, 2200 # syscall number para setar um pixel
            ecall

            addi s9, s9, 1 # somar 1 em X
            addi t0, s1, -1 # subtrai 1 da largura para fazer a comparação do X
            beq s9, t0, contX # sai quando x = largura - 1
            j forX
        contX:
            addi s10, s10, 1 # somar 1 em Y
            addi t0, s2, -1 # subtrai 1 da altura total
            beq s10, t0, contY # sai do loop se y = altura - 1
            j forY
    contY:
        ret

inicializarMout:
    # iterar pixel a pixel para ir printando no output
    # iterar no número de elementos da imagem = largura * altura

    # 1a ITERAÇÃO - COLOCAR PRETO NA 1a LINHA
    li t0, 0 # número pra iterar as colunas
    enquantoLinha1:
        # setar o a2
        li t1, 0 # código pro preto

        slli t4, t1, 24
        slli t3, t1, 16
        slli t2, t1, 8

        li a2, 255
        add a2, a2, t4
        add a2, a2, t3
        add a2, a2, t2
        
        # setar a0 (X) e a1 (Y)
        # resto da divisão de t0 por s1 (largura) me da a coluna atual: a0
        # divisão de t0 por s1 (largura) me da a linha atual
        mv a0, t0 # coluna = contador
        li a1, 0 # linha 0

        # setPixel
        # a0: coordenada X
        # a1: coordenada Y
        # a2: cor
        li a7, 2200 # syscall number para setar um pixel
        ecall

        addi t0, t0, 1
        bge a0, s1, contLinha1 # deve sair do laço se o número de iteração for igual ao número de colunas 
        j enquantoLinha1
    contLinha1:
    
    # 2a ITERAÇÃO - COLOCAR PRETO NA 1a COLUNA
    li t0, 1 # redefinir o contador - começar a partir da linha 1
    enquantoColuna1:
        # setar o a2
        li t1, 0 # código pro preto

        slli t4, t1, 24
        slli t3, t1, 16
        slli t2, t1, 8

        li a2, 255
        add a2, a2, t4
        add a2, a2, t3
        add a2, a2, t2
        
        # setar a0 (X) e a1 (Y)
        # resto da divisão de t0 por s1 (largura) me da a coluna atual: a0
        # divisão de t0 por s1 (largura) me da a linha atual
        li a0, 0  # coluna 0
        mv a1, t0 # linha = contador

        # setPixel
        # a0: coordenada X
        # a1: coordenada Y
        # a2: cor
        li a7, 2200 # syscall number para setar um pixel
        ecall

        addi t0, t0, 1
        bge a1, s2, contColuna1 # deve sair do laço se o número de iteração for igual ao número de linhas
        j enquantoColuna1
    contColuna1:

    # 3a ITERAÇÃO - COLOCAR PRETO NA ÚLTIMA COLUNA
    li t0, 1 # redefinir o contador - começar a partir da linha 1
    enquantoColunaFinal:
        # setar o a2
        li t1, 0 # código pro preto

        slli t4, t1, 24
        slli t3, t1, 16
        slli t2, t1, 8

        li a2, 255
        add a2, a2, t4
        add a2, a2, t3
        add a2, a2, t2
        
        # setar a0 (X) e a1 (Y)
        # resto da divisão de t0 por s1 (largura) me da a coluna atual: a0
        # divisão de t0 por s1 (largura) me da a linha atual
        addi a0, s1, -1 # coluna = última coluna
        mv a1, t0 # linha = contador

        # setPixel
        # a0: coordenada X
        # a1: coordenada Y
        # a2: cor
        li a7, 2200 # syscall number para setar um pixel
        ecall

        addi t0, t0, 1
        bge a1, s2, contColunaFinal # deve sair do laço se o número de iteração for igual ao número de linhas
        j enquantoColunaFinal
    contColunaFinal:

    # 4a ITERAÇÃO - COLOCAR PRETO NA ÚLTIMA LINHA
    li t0, 0 # número pra iterar as colunas

    enquantoLinhaFinal:
        # setar o a2
        li t1, 0 # código pro preto

        slli t4, t1, 24
        slli t3, t1, 16
        slli t2, t1, 8

        li a2, 255
        add a2, a2, t4
        add a2, a2, t3
        add a2, a2, t2
        
        # setar a0 (X) e a1 (Y)
        # resto da divisão de t0 por s1 (largura) me da a coluna atual: a0
        # divisão de t0 por s1 (largura) me da a linha atual
        mv a0, t0 # coluna = contador
        addi a1, s2, -1 # última linha da imagem

        # setPixel
        # a0: coordenada X
        # a1: coordenada Y
        # a2: cor
        li a7, 2200 # syscall number para setar um pixel
        ecall

        addi t0, t0, 1
        bge a0, s1, contLinhaFinal # deve sair do laço se o número de iteração for igual ao número de colunas 
        j enquantoLinhaFinal
    contLinhaFinal:
        ret

inicializarW:
    la s5, w # endereço para w
    li t0, -1 # variável a ser colocada em w[i!=1][j!=1]
    li t1, 8 # variável a ser colocada em w[1][1]

    sb t0, 0(s5)
    sb t0, 1(s5)
    sb t0, 2(s5)
    sb t0, 3(s5)
    sb t1, 4(s5)
    sb t0, 5(s5)
    sb t0, 6(s5)
    sb t0, 7(s5)
    sb t0, 8(s5)

    ret

_start:

    # abrir o arquivo

    jal openArq
    mv s4, a0 # guardar o fd em s4

    jal read # lê o arquivo todo
    la s0, input
    jal setCanvasSize

    # definir o tamanho do output - largura: s1, altura: s2
    mul s3, s1, s2 # número de elementos da imagem guardado em s3

    # inicializar a matriz de filtragem
    jal inicializarW

    # inicializar as bordas do Mout
    jal inicializarMout

    # chamar a função pra iterar o arquivo aplicando a matriz de filtragem
    jal iterarPixels

    # exit
    li a0, 0
    li a7, 93
    ecall

.section .bss
input: .skip 262179 # buffer para ler 262179 bytes
w: .skip 0xA # matriz de filtro
.section .data
input_file: .asciz "image.pgm"