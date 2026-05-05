.data
	# Constantes
	.eqv MESA_TAM		49 # O tamanho em bytes de uma mesa ma memória
	.eqv MESA_COUNT		20 # Quantidade de mesas no array
	
	# offsets para separar onde fica cada atributo na memória alocada da mesa
	.eqv OFFSET_ID		0
	.eqv OFFSET_OCUPADA 	4
	.eqv OFFSET_RESPONSAVEL	5
	.eqv OFFSET_TELEFONE	35
	.eqv OFFSET_ENDERECO    48

	arr_mesas: .space 		980   # 20 * 49 = 980 bytes
.text
.globl buscar_mesa_id
.globl set_is_ocupada

# Essa função inteira pode ser removida
test:
	la 	$s0, arr_mesas	# Endereço inicial do array das mesas
	move 	$a0, $0 	# índice = 0
	jal  	buscar_mesa_id
	lb 	$a0, OFFSET_OCUPADA($v0)
	jal 	print_int	# Imprime o estado atual da mesa[0]

	move 	$a0, $0
	li 	$a1, 1
	jal 	set_is_ocupada

	move 	$a0, $0 	
	jal  	buscar_mesa_id
	lb 	$a0, OFFSET_OCUPADA($v0)
	jal 	print_int

	j 	sair

# Assumindo que $s0 tem o endereço do array das mesas, e $a0 o índice buscado
# $v0: Retorna o valor da struct , $v1: Retorna o endereço da mesa
buscar_mesa_id:
	li 	$t1, MESA_TAM   # para trocar a mesa de forma mais direta
	mul 	$t3, $a0, $t1   # i * MESA_TAM
	add 	$t4, $t3, $s0   # t4 = &mesas[i]
	
	lw 	$v1, OFFSET_ID($t4) 	# Retorna
	move 	$v0, $t4 	  	# $v0 = t4
	jr 	$ra

# Assumindo que $s0 tem o endereço do array das mesas, e $a0 o índice buscado
# e $a1 1 ou 0, para definir se a mesa será ocupada
set_is_ocupada:
	addi 	$sp, $sp, -8	# Armazena 2 bytes na pilha
	sw   	$ra, 4($sp)	# Preserva a entradas da função, e endereço correto na pilha antes de chamar a busca   
    	sw   	$a1, 0($sp)

	jal 	buscar_mesa_id  # Busca o endereço da mesa de mesmo ID

	lw   $a1, 0($sp)        # restaura a entrada original
    	lw   $ra, 4($sp)	# Restaura o endereço do return
    	addi $sp, $sp, 8

    	beq  $a1, $zero, set_livre
	
	set_ocupada:
	    li   $t1, 1
	    sb   $t1, OFFSET_OCUPADA($v0)
	    jr   $ra

	set_livre:
		sb   $zero, OFFSET_OCUPADA($v0)
		jr   $ra
sair:
	addi 		$v0, $0, 10 # Serviço para encerrar o programa
	syscall		
