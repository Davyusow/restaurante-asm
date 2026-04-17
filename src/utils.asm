# Diretório de funções gerais do projeto
.data

.text
.globl print    # Expõe a label print para os arquivos do mesmo diretório

# Precisa alocar no $a0 o valor antes de imprimir!
print:
        li      $v0, 4  # syscall para imprimir a string
        syscall         # Chama o syscall
        jr $ra          # Retorna o ponteiro da função


