.section .text
.globl _start

read:
    # guarda o input em a1

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
        lbu s8, 0(s0)
        beq s8, t1, contLargura # sai do loop se s8 ler um caracter de espaço
        beq s8, t3, contLargura # sai do loop se s8 ler um \n
        addi s8, s8, -48 # transformar em int
        mul t2, t2, t3 # multiplicar t2 por 10
        add t2, t2, s8 # somar t2 com s8 e guardar em t2
        addi s0, s0, 1
    contLargura:
        mv a0, t2
    
    # altura
    addi s0, s0, 1 # pular o espaço
    li t2, 0
    enquantoAltura:
        lbu s8, 0(s0)
        beq s8, t1, contAltura # sai do loop se s8 ler um caracter de espaço
        beq s8, t3, contAltura # sai do loop se s8 ler um \n
        addi s8, s8, -48 # transformar em int
        mul t2, t2, t3 # multiplicar t2 por 10
        add t2, t2, s8 # somar t2 com s8 e guardar em t2

        addi s0, s0, 1
    contAltura:
        mv a1, t2
    
    mv s1, a0 # guarda a largura em s1
    mv s2, a1 # guarda a altura em s2
    # syscall
    li a7, 2201
    ecall
    ret


iterarPixels:
    # iterar pixel a pixel para ir printando no output
    # iterar no número de elementos da imagem = largura * altura
    li t0, 0 # número pra iterar
    enquanto:
        lbu t1, 0(s0) # ler o número do pixel em questão

        # setar o a2
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
        rem a0, t0, s1
        div a1, t0, s1

        # setPixel
        # a0: coordenada X
        # a1: coordenada Y
        # a2: cor
        li a7, 2200 # syscall number para setar um pixel
set_pix:
        ecall

        addi t0, t0, 1
        bge t0, s3, cont # deve sair do laço se o número de iteração for maior do que o número de elementos
        addi s0, s0, 1
        j enquanto
    cont:
        ret

_start:

    # abrir o arquivo

    jal openArq
    mv s4, a0 # guardar o fd em s4

    # setCanvasSize
    li a0, 10
    li a1, 10
    li a7, 2201
    mv s1, a0
    mv s2, a1
    ecall

    # definir o tamanho do output - largura: s1, altura: s2
    mul s3, s1, s2 # número de elementos da imagem guardado em s3

    # ler o conteúdo do arquivo (todos os elementos restantes = altura * largura bytes)
    addi a2, s3, 13 # quantidade de bytes a serem lidos (numero de elementos da imagem + header)
    jal read

    # chamar a função pra iterar o arquivo
    la s0, input
    addi s0, s0, 13 # pular o header
    jal iterarPixels

    # exit
    li a0, 0
    li a7, 93
    ecall

.section .bss
input: .skip 0x4001c # buffer para ler 4001c bytes
.section .data
input_file: .asciz "image.pgm"