.text
.globl print_int
.globl print
.globl print_raw

# Precisa alocar no $a0 o valor antes de imprimir!
# Mostra uma string no terminal (com quebra de linha)
print:
        addiu   $sp, $sp, -4
        sw      $ra, 0($sp)
        jal     mmio_print_string
        li      $a0, 10
        jal     mmio_write_char
        lw      $ra, 0($sp)
        addiu   $sp, $sp, 4
        jr      $ra

# Mostra uma string sem quebra de linha
print_raw:
        addiu   $sp, $sp, -4
        sw      $ra, 0($sp)
        jal     mmio_print_string
        lw      $ra, 0($sp)
        addiu   $sp, $sp, 4
        jr      $ra

# Mostra um inteiro no terminal (com quebra de linha)
print_int:
        addiu   $sp, $sp, -4
        sw      $ra, 0($sp)
        jal     mmio_print_int
        li      $a0, 10
        jal     mmio_write_char
        lw      $ra, 0($sp)
        addiu   $sp, $sp, 4
        jr      $ra