# =========================================================================
# Função: strncmp
# Descrição: Compara os n primeiro chars de duas strings
# Argumentos:
#   $a0 - str1
#   $a1 - str2
#   $a2 - n
# Retorno:
#   $v0 - -1 (str1 < str2); 0 (string iguais); 1 (str1 > str2)
# =========================================================================

.text
.globl strncmp

strncmp:
strncmp_loop:
        beq $a2, $0, fim_iguais

        lb $t0, 0($a0)
        lb $t1, 0($a1)

        bne $t0, $t1, fim_diferentes

        beq $t0, $0, fim_iguais

        addi $a0, $a0, 1
        addi $a1, $a1, 1
        addi $a2, $a2, -1

        j strncmp_loop

fim_diferentes:
            slt $t2, $t0, $t1             
            
            bne $t2, $zero, retorna_menos_um 
            
            li $v0, 1                     # Retorna 1
            jr $ra
            
        retorna_menos_um:
            li $v0, -1                    # Retorna -1
            jr $ra

fim_iguais:
        li $v0, 0
        jr $ra