#define STDIN_FD  0
#define STDOUT_FD 1

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

//given code
void hex_code(int val) {
    //used to write the resulting hexadecimal value
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;
    
    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(1, hex, 11);
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
      resultado[indexResultado] = 'A';
    }
    else if (valorAtual == 11) {
      resultado[indexResultado] = 'B';
    }
    else if (valorAtual == 12) {
      resultado[indexResultado] = 'C';
    }
    else if (valorAtual == 13) {
      resultado[indexResultado] = 'D';
    }
    else if (valorAtual == 14) {
      resultado[indexResultado] = 'E';
    }
    else if (valorAtual == 15) {
      resultado[indexResultado] = 'F';
    }
    indexResultado -= 1;
  }
}

int charToInt(char numero[], int qtdBytes) {
  //dado um char que representa um inteiro, converte-o para inteiro
  int resultado = 0;
  int currDigit;
  for (int i = qtdBytes - 1; i >= 0; i--) {
    currDigit = numero[i] - '0';
    resultado += currDigit * powNumber(10, qtdBytes - 1 - i);
  }
  return resultado;
}

void pack(char binary[], char resultadoBinary[], int start_bit, int end_bit) {
    int indexBinary = 33;
    for (int i = start_bit; i <= end_bit; i++) {
        resultadoBinary[33 - i] = binary[indexBinary];
        indexBinary--;
    }
}

int main()
{
  char str[32];
  /* Read up to 30 bytes from the standard input into the str buffer */
  int n = read(STDIN_FD, str, 30);
  //iterar o vetor pra ler de número em número
  int idNumeroAtual = 0;
  char binary[35];
  char resultadoBinary[35];
  char hexadecimalOutput[35];

  for (int i = 0; i < 29; i+=6) {
    idNumeroAtual += 1;
    char currNumber[6];
    //set the current number
    currNumber[0] = str[i];
    currNumber[1] = str[i+1];
    currNumber[2] = str[i+2];
    currNumber[3] = str[i+3];
    currNumber[4] = str[i+4];
    //deal with the number
    if (currNumber[0] == '+') { //número positivo
        currNumber[0] = '0'; //ignorar o sinal
        int number = charToInt(currNumber, 5);
        positiveIntToBinary(number, binary);
    }
    else { //número negativo
        currNumber[0] = '0'; //ignorar o sinal
        int number = charToInt(currNumber, 5);
        negativeIntToBinary(number, binary);
    }

    if (idNumeroAtual == 1) { //primeiro número
        pack(binary, resultadoBinary, 0, 2);
    }
    else if (idNumeroAtual == 2) {
        pack(binary, resultadoBinary, 3, 10);
    }
    else if (idNumeroAtual == 3) {
        pack(binary, resultadoBinary, 11, 15);
    }
    else if (idNumeroAtual == 4) {
        pack(binary, resultadoBinary, 16, 20);
    }
    else if (idNumeroAtual == 5) {
        pack(binary, resultadoBinary, 21, 31);
    }
  }
  //converter o binário pra hexadecimal
  binaryToHexadecimal(resultadoBinary, hexadecimalOutput);
  hexadecimalOutput[0] = '0';
  hexadecimalOutput[1] = 'x';
  hexadecimalOutput[34] = '\n';
  int comecaPrintar = 0;
  //printar o hexadecimal
  write(STDOUT_FD, &hexadecimalOutput[0], 1);
  write(STDOUT_FD, &hexadecimalOutput[1], 1);
  for (int i = 2; i < 35; i++) {
    if (comecaPrintar || hexadecimalOutput[i] != '0') {
        write(STDOUT_FD, &hexadecimalOutput[i], 1);
        comecaPrintar = 1;
    }
  }
  return 0;
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}