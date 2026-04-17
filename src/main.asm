# Fluxo principal
.data
        hello_msg: .asciiz "Hello, World!"

.text
.globl main

main:
        la      $a0, hello_msg  # Carrega a mensagem para a impressão
        jal     print           # Imprime a mensagem
        j       exit            # Pula para o fim do programa

exit:
        li      $v0, 10         # Carrega a função de saída para o syscall
        syscall                 # Chama o syscall para encerrar o programa