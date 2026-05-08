# Fluxo principal
.data   
        buffer: .space 51
        buffer_banner_flag: .asciiz "res-shell>>"

.text


.globl mmio_shell_loop

mmio_shell_loop:

        # Imprimindo na tela a flag
        la $a0, buffer_banner_flag # Passando como parametro o endereço da flag para $a0
        jal mmio_imprimir_tela # Chamo a funcao de impressao do MMIO para imprimir a flag no shell

        # Declarando o buffer e o passando como parâmetro, escrevendo nele o que foi escrito no shell pelo usuário
        la $a0, buffer # Carrega o endereço do buffer para $a0
        li $a1, 51     # Carrega o tamanho do buffer para $a1
        jal mmio_echo_ler_para_buffer # Chama a função de echo do MMIO

        # Checa se o usuário apenas apertou enter, para economizar instrucoes
        la $a0, buffer # Carrega em $a0 o endereco do inicio do array buffer
        lb $t0, 0($a0) # Carrega em $t0 o valor desse indice
        beq $t0, $zero, mmio_shell_loop # Checa se o valor é nulo, ou seja, apenas digitou \n

        # Passa o buffer como argumento para a funcao que checara o comando
        la $a0, buffer
        jal checar_comando

        j mmio_shell_loop
