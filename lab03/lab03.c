int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall write code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
        : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

#define STDIN_FD  0
#define STDOUT_FD 1

//Função auxiliar

int powNumber(int numero, int potencia) {
  //eleva o número a potência dada
  int resultado = 1;
  if (potencia != 0) {
    for (int i = 0; i < potencia; i++) {
        resultado *= numero;
    }
    return resultado;
  }
  return 1;
}

void iniciaVetor(char vetor[], int tamanho) {
    for (int i = 0; i < tamanho; i++) {
        vetor[i] = '0';
    }
}

//Entrada com número inteiro
void positiveIntToBinary(int num, char resultado[]) {
  //transforma um número inteiro poistivo em um binário
  char auxiliar[35];
  //inicializar
  resultado[0] = '0';
  resultado[1] = 'b';
  iniciaVetor(auxiliar, 35);
  //conversão
  int index = 0;
  while (num > 0) {
    auxiliar[index] = num % 2 + '0';
    num /= 2;
    index++;
  }
  //inverter o binary
  for (int i = 31; i >= 0; i--) {
    resultado[33 - i] = auxiliar[i];
  }
}

void negativeIntToBinary (int num, char resultado[]) {
  //transforma um número inteiro negativo em um binário
  num -= 1;
  char auxBinary[35];
  positiveIntToBinary(num, auxBinary);
  //complemento de 2
  for (int i = 2; i < 34; i++) {
    if (auxBinary[i] == '1') {
      resultado[i] = '0';
    }
    else {
      resultado[i] = '1';
    }
  }
}

void hexadecimalToBinary (char hexadecimal[], char resultado[], int n) {
  int digitValue;
  char aux[35];
  iniciaVetor(resultado, 35);
  int indexResultado = 33;
  for (int i = n - 2; i > 1; i--) {
    char currDigit = hexadecimal[i];
    if (currDigit == 'a' || currDigit == 'b' || currDigit == 'c' || currDigit == 'd' || currDigit == 'e' || currDigit == 'f') {
      digitValue = currDigit - 87;
    }
    else {
      digitValue = currDigit - '0';
    }
    positiveIntToBinary(digitValue, aux);
    resultado[indexResultado - 3] = aux[30];
    resultado[indexResultado - 2] = aux[31];
    resultado[indexResultado - 1] = aux[32];
    resultado[indexResultado] = aux[33];
    indexResultado -= 4;
  }
}

//Conversão de binário para ...

unsigned int binaryToInt (char binary[], int isEndinness, int *eh_negativo) {
  //converte o número binário para inteiro
  unsigned int resultado = 0;
  if (binary[2] == '0' || isEndinness) { //o binário representa um número positivo
    for (int i = 33; i > 1; i--) {
      if (binary[i] == '1') {
        resultado += powNumber(2, 33 - i);
      }
    }
  }
  else { //o binário representa um número negativo
    *eh_negativo = 1;
    char auxiliar[35];
    //fazer uma cópia do binário para não alterá-lo diretamente
    for (int i = 0; i < 35; i++) {
      auxiliar[i] = binary[i];
    }
    for (int i = 33; i > 1; i--) { //inverter os '0' e '1'
      if (auxiliar[i] == '1') {
        auxiliar[i] = '0';
      }
      else {
        auxiliar[i] = '1';
      }
    }
    //calcular o valor
    for (int i = 33; i >= 0; i--) {
      char c = auxiliar[i];
      if (c == '1') {
        resultado += powNumber(2, 33 - i);
      }
    }
    //somar 1
    resultado += 1;
  }
  return resultado;
}

void binaryToHexadecimal (char binary[], char resultado[]) {
  int indexResultado = 33;
  //inicializar
  iniciaVetor(resultado, 35);
  for (int i = 33; i >= 5; i-=4) {
    int valorAtual = 0;
    //contas dos 4 dígitos
    if (binary[i] == '1') {
      valorAtual += powNumber(2, 0);
    }
    if (binary[i-1] == '1') {
      valorAtual += powNumber(2, 1);
    }
    if (binary[i-2] == '1') {
      valorAtual += powNumber(2, 2);
    }
    if (binary[i-3] == '1') {
      valorAtual += powNumber(2, 3);
    }
    //transformar para hexadecimal
    if (valorAtual >= 0 && valorAtual <= 9) {
      resultado[indexResultado] = valorAtual + '0'; //conversão int-char
    }
    else if (valorAtual == 10) {
      resultado[indexResultado] = 'a';
    }
    else if (valorAtual == 11) {
      resultado[indexResultado] = 'b';
    }
    else if (valorAtual == 12) {
      resultado[indexResultado] = 'c';
    }
    else if (valorAtual == 13) {
      resultado[indexResultado] = 'd';
    }
    else if (valorAtual == 14) {
      resultado[indexResultado] = 'e';
    }
    else if (valorAtual == 15) {
      resultado[indexResultado] = 'f';
    }
    indexResultado -= 1;
  }
}

void invertEndianness (char binary[], char resultado[]) {
  //a partir do número binário, inverte o edianness
  iniciaVetor(resultado, 35);
  //realizar a troca de endianess
  int indexResultado = 33;
  int i = 2;
  do {
    resultado[indexResultado - 7] = binary[i];
    resultado[indexResultado - 6] = binary[i+1];
    resultado[indexResultado - 5] = binary[i+2];
    resultado[indexResultado - 4] = binary[i+3];
    resultado[indexResultado - 3] = binary[i+4];
    resultado[indexResultado - 2] = binary[i+5];
    resultado[indexResultado - 1] = binary[i+6];
    resultado[indexResultado] = binary[i+7];
    indexResultado -= 8;
    i += 8;
  } while (i <= 33);
}

//Funções auxiliares

int charToInt(char numero[], int qtdBytes) {
  //dado um char que representa um inteiro, converte-o para inteiro
  int resultado = 0;
  int currDigit;
  for (int i = qtdBytes - 2; i >= 0; i--) {
    currDigit = numero[i] - '0';
    resultado += currDigit * powNumber(10, qtdBytes - 2 - i);
  }
  return resultado;
}

void intToChar (unsigned int num, char resultado[]) {
  //converte um inteiro positivo pra um char
  iniciaVetor(resultado, 50);
  int index = 49;

  while (num > 0) {
    resultado[index] = num%10 + '0';
    num/=10;
    index--;
  }
}

int main()
{
  char str[35];
  /* Read up to 20 bytes from the standard input into the str buffer */
  int n = read(STDIN_FD, str, 32);
  //vetores para conversões
  char binary[35];
  char hexadecimal[35];
  char endianess[35];
  char charNumEndianess[51];
  char sinalNegativo = '-';
  //Tipos de entradas
  if (str[0] == '0' && str[1] == 'x') { //ENTRADA: hexadecimal
    //HEXADECIMAL -> BINÁRIO
    hexadecimalToBinary(str, binary, n);
    binary[0] = '0';
    binary[1] = 'b';
    binary[34] = '\n';
    //printar o binário
    int comecouBy = 0;
    write(STDOUT_FD, &binary[0], 1);
    write(STDOUT_FD, &binary[1], 1);
    for (int i = 2; i < 35; i++) {
        if (comecouBy || binary[i] == '1') {
            write(STDOUT_FD, &binary[i], 1);
            comecouBy = 1;
        }
    }

    //BINÁRIO -> INT
    int eh_negativo = 0;
    unsigned int number = binaryToInt(binary, 0, &eh_negativo);
    intToChar(number, charNumEndianess);
    charNumEndianess[50] = '\n';
    int comecouCharNumber = 0;
    //printar o resultado
    if (eh_negativo) {
      write(STDOUT_FD, &sinalNegativo, 1);//printf("%c", '-');
    }
    for (int i = 0; i < 51; i++) {
      if (comecouCharNumber || charNumEndianess[i] != '0') {
        write(STDOUT_FD, &charNumEndianess[i], 1);//printf("%c", charNumEndianess[i]);
        comecouCharNumber = 1;
      }
    }

    //PRINTAR O HEXA
    str[n-1] = '\n';
    for (int i = 0; i < n; i++) {
      write(STDOUT_FD, &str[i], 1);//printf("%c", str[i]);
    }

  }
  else if (str[0] == '-') { //ENTRADA: inteiro negativo
    //INTEIRO NEGATIVO -> BINÁRIO
    str[0] = '0'; //alterar o sinal de negativo
    int num = charToInt(str, n); //converter para inteiro
    negativeIntToBinary(num, binary);
    binary[0] = '0';
    binary[1] = 'b';
    binary[34] = '\n';
    //printar o binário
    int comecouBy = 0;
    write(STDOUT_FD, &binary[0], 1); //printf("%c", binary[0]);
    write(STDOUT_FD, &binary[1], 1); //printf("%c", binary[1]);
    for (int i = 2; i < 35; i++) {
        if (comecouBy || binary[i] == '1') {
            write(STDOUT_FD, &binary[i], 1); //printf("%c", binary[i]);
            comecouBy = 1;
        }
    }

    //PRINTAR O PRÓPRIO NÚMERO
    write(STDOUT_FD, &sinalNegativo, 1); //printf("%c", '-');
    str[n-1] = '\n';
    for (int i = 1; i < n; i++) {
      write(STDOUT_FD, &str[i], 1); //printf("%c", str[i]);
    }

    //BINÁRIO -> HEXADECIMAL
    binaryToHexadecimal(binary, hexadecimal);
    hexadecimal[34] = '\n';
    int comecouHexa = 0;
    hexadecimal[1] = 'x';
    write(STDOUT_FD, &hexadecimal[0], 1); //printf("%c", hexadecimal[0]);
    write(STDOUT_FD, &hexadecimal[1], 1); //printf("%c", hexadecimal[1]);
    for (int i = 2; i < 35; i++) {
        if (comecouHexa || hexadecimal[i] != '0') {
            write(STDOUT_FD, &hexadecimal[i], 1); //printf("%c", hexadecimal[i]);
            comecouHexa = 1;
        }
    }

  }

  else //ENTRADA: inteiro positivo
  { 
    //INT POS. -> BINARY
    int num = charToInt(str, n);
    positiveIntToBinary(num, binary);
    binary[34] = '\n';
    int comecouBy = 0;
    //printar
    write(STDOUT_FD, &binary[0], 1); //printf("%c", binary[0]);
    write(STDOUT_FD, &binary[1], 1); //printf("%c", binary[1]);
    for (int i = 2; i < 35; i++) {
        if (comecouBy || binary[i] == '1') {
            write(STDOUT_FD, &binary[i], 1); //printf("%c", binary[i]);
            comecouBy = 1;
        }
    }

    //INT POS. -> CHAR
    str[n-1] = '\n';
    for (int i = 0; i < n; i++) {
      write(STDOUT_FD, &str[i], 1); //printf("%c", str[i]);
    }

    //BINARY -> HEXADECIMAL
    binaryToHexadecimal(binary, hexadecimal);
    hexadecimal[34] = '\n';
    int comecouHexa = 0;
    hexadecimal[1] = 'x';
    write(STDOUT_FD, &hexadecimal[0], 1); //printf("%c", hexadecimal[0]);
    write(STDOUT_FD, &hexadecimal[1], 1); //printf("%c", hexadecimal[1]);
    for (int i = 2; i < 35; i++) {
        if (comecouHexa || hexadecimal[i] != '0') {
            write(STDOUT_FD, &hexadecimal[i], 1); //printf("%c", hexadecimal[i]);
            comecouHexa = 1;
        }
    }
  }

    //INVERTER O ENDIANESS
    invertEndianness(binary, endianess);
    endianess[1] = 'b';
    endianess[34] = '\n';
    unsigned int numEndianess = binaryToInt(endianess, 1, 0);
    //converter o int do endianness para char
    intToChar(numEndianess, charNumEndianess);
    charNumEndianess[50] = '\n';
    int comecouCharEnd = 0;
    //printar o resultado
    for (int i = 0; i < 51; i++) {
      if (comecouCharEnd || charNumEndianess[i] != '0') {
        write(STDOUT_FD, &charNumEndianess[i], 1); //printf("%c", charNumEndianess[i]);
        comecouCharEnd = 1;
      }
    }
  return 0;
}


void _start()
{
  int ret_code = main();
  exit(ret_code);
}