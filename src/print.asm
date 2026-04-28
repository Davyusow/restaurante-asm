.data
        pula_linha:     .asciiz "\n"

.macro endl
        la      $a0, pula_linha
        li      $v0, 4
        syscall
.end_macro
.text
.globl print_int
.globl print

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