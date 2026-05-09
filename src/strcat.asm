# =========================================================================
# Função: strcat
# Descrição: concatena duas strings
# Argumentos:
#   $a0 - destino
#   $a1 - origem
# Retorno:
#   $v0 - retorna o endereço do destino
# =========================================================================

.text
.globl strcat

strcat:
    move $v0, $a0 #guarda o endereco do destino
percorre_destino:
    lb $t0, 0($a0) #le o byte atual do destino
    beq $t0, $0, concatena

    addi $a0, $a0, 1 #avanca no destino
    j percorre_destino

concatena:
    lb $t1, 0($a1)
    beq $t1, $0, fim #encerra quando chegar no fim da string de origem

    sb $t1, 0($a0) #copia byte da origem

    addi $a0, $a0, 1
    addi $a1, $a1, 1

    j concatena

fim:
    sb $0, 0($a0) #finaliza a string
    jr $ra