# =========================================================================
# Função: memcpy
# Descrição: Copia um bloco de memória de 'source' para 'destination'.
# Argumentos:
#   $a0 - destination (Endereço do bloco de memória de destino)
#   $a1 - source (Endereço do bloco de memória de origem)
#   $a2 - num (Número total de bytes a serem copiados)
# Retorno:
#   $v0 - destination (O mesmo endereço passado em $a0)
# =========================================================================

.text
.globl memcpy

memcpy:
        move $v0, $a0 #salva o endereço de destino em v0

memcpy_loop:
        #sai do loop quando o contador for zero
        beq $a2, $zero, memcpy_end

        # Copia de fato: 1 byte por vez
        lb $t0, 0($a1)          # Carrega 1 byte da origem para $t0
        sb $t0, 0($a0)          # Armazena esse byte no destino

        # Atualiza os ponteiros e o contador
        addi $a1, $a1, 1        # Avança 1 byte no ponteiro de origem
        addi $a0, $a0, 1        # Avança 1 byte no ponteiro de destino
        addi $a2, $a2, -1       # Decrementa o contador

        # Volta para o início do loop
        j memcpy_loop

memcpy_end:
        jr $ra #volta para o ponto inicial de chamada da função
