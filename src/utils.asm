# Diretório de funções gerais do projeto
.data
        pula_linha:     .asciiz "\n"

.macro endl
        la      $a0, pula_linha
        li      $v0, 4
        syscall
.end_macro

.text
.globl print    # Expõe a label print para os arquivos do mesmo diretório
.globl print_int
.globl strcmp

# Precisa alocar no $a0 o valor antes de imprimir!
# Mostra uma string no terminal
print:
        li      $v0, 4  # syscall para imprimir a string
        syscall         # Chama o syscall
        endl
        jr      $ra     # Retorna o ponteiro da função

# Mostra um inteiro no terminal
print_int:
        li      $v0, 1
        syscall
        endl
        jr      $ra

# Compara duas strings
# Retorna positivo caso seja uma letra maior
# Retorna 0 se for igual
# Retorna negativo se for uma letra menor
strcmp:
loop:
        lb     $t0, 0($a0) # Carrega o primeiro bit da primeira string
        lb     $t1, 0($a1) # Carrega o primeiro bit da segunda string

        bne    $t0, $t1, diff   # Se os bytes forem diferentes, calcula a diferença
        beq    $t0, $zero, igual   # Se ambos são '\0' as strings são iguais

        addi   $a0, $a0, 1      # Avança os índices
        addi   $a1, $a1, 1      #
        j      loop

diff:
        sub    $v0, $t0, $t1    # string1[i] - string2[i]
        jr     $ra
igual:
        li     $v0, 0
        jr     $ra

