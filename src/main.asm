# Fluxo principal
.data
        hello_msg: .asciiz "Hello, World!"
        
        buffer: .space 51
        buffer_banner_flag: .asciiz "res-shell>>"

.text


.globl mmio_shell_loop

mmio_shell_loop:

        #Imprimindo na tela a flag
        la $a0, buffer_banner_flag # Passando como parametro o endereço da flag para $a0
        jal mmio_imprimir_tela # Chamo a funcao de impressao do MMIO para imprimir a flag no shell

        #Declarando o buffer, passando como parâmetro e escrevendo nele o que foi escrito no shell pelo usuário
        la $a0, buffer # Carrega o endereço do buffer para $a0
        li $a1, 51     # Carrega o tamanho do buffer para $a1
        jal mmio_echo_ler_para_buffer # Chama a função de echo do MMIO

.globl main

main:
        la      $a0, hello_msg  # Carrega a mensagem para a impressão
        jal     print           # Imprime a mensagem
        j       exit            # Pula para o fim do programa

exit:
        li      $v0, 10         # Carrega a função de saída para o syscall
        syscall                 # Chama o syscall para encerrar o programa