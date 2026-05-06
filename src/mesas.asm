.data
	# Constantes
	.eqv MESA_TAM		49 # O tamanho em bytes de uma mesa ma memória
	.eqv MESA_COUNT		15 # Quantidade de mesas no array
	
	# offsets para separar onde fica cada atributo na memória alocada da mesa
	.eqv OFFSET_ID		0
	.eqv OFFSET_OCUPADA 	4
	.eqv OFFSET_RESPONSAVEL	5
	.eqv OFFSET_TELEFONE	35
	.eqv OFFSET_ENDERECO    48

	arr_mesas: .space 		735   # 15 * 49 = 980 bytes

	.macro get_mesa(%reg_preservar)
	    addi $sp, $sp, -8			# Armazena 2 bytes na pilha
	    sw   $ra, 4($sp)			# Preserva a entradas da função, e endereço correto na pilha antes de chamar a busca   
	    sw   %reg_preservar, 0($sp)
	    jal  buscar_mesa_id			# Busca o endereço da mesa de mesmo ID
	    lw   %reg_preservar, 0($sp) # restaura a entrada original
	    lw   $ra, 4($sp)			# Restaura o endereço do return
	    addi $sp, $sp, 8
	.end_macro

	## .data de testes

	telefone_teste1: 	.asciiz "81 99090-9090"
	telefone_teste2: 	.asciiz "81 98080-8080"

.text
.globl buscar_mesa_id
.globl set_is_ocupada

# Essa função inteira pode ser removida
test:
	la 		$s0, arr_mesas	# Endereço inicial do array das mesas
	
	# Teste se consigo ocupar uma mesa
	move 	$a0, $0 	# índice = 0
	jal  	buscar_mesa_id
	lb 		$a0, OFFSET_OCUPADA($v0)
	jal 	print_int	# Imprime o estado atual da mesa[0]

	move 	$a0, $0
	li 		$a1, 1
	jal 	set_is_ocupada

	move 	$a0, $0 	
	jal  	buscar_mesa_id
	lb 	$a0, OFFSET_OCUPADA($v0)
	jal 	print_int

	## Teste se consigo trocar um número:

	move 	$a0, $0
	la 		$a1, telefone_teste1 	# inserindo o primeiro número para o set
	jal 	set_telefone

	move 	$a0, $0
	jal 	buscar_mesa_id
	addi 	$a0, $v0, OFFSET_TELEFONE	# $a0 = endereço do campo telefone
	jal 	print						# Imprime "81 99090-9090"

	# trocando o número pela segunda vez
	move 	$a0, $0
	la 		$a1, telefone_teste2	# fonte = "81 98080-8080"
	jal 	set_telefone

	move 	$a0, $0
	jal 	buscar_mesa_id
	addi 	$a0, $v0, OFFSET_TELEFONE	# $a0 = endereço do campo telefone
	jal 	print						# Imprime "81 98080-8080"


	j 	sair

# Assumindo que $s0 tem o endereço do array das mesas, e $a0 o índice buscado
# $v0: Retorna o valor da struct , $v1: Retorna o endereço da mesa
buscar_mesa_id:
	li 	$t1, MESA_TAM   # para trocar a mesa de forma mais direta
	mul 	$t3, $a0, $t1   # i * MESA_TAM
	add 	$t4, $t3, $s0   # t4 = &mesas[i]
	
	lw 	$v1, OFFSET_ID($t4) 	# endereço da mesa
	move 	$v0, $t4 	  	# valor da struct
	jr 	$ra

# Assumindo que $s0 tem o endereço do array das mesas, e $a0 o índice buscado
# e $a1 1 ou 0, para definir se a mesa será ocupada
set_is_ocupada:
	get_mesa 	$a1

	beq  $a1, $zero, set_livre
	
	set_ocupada:
    li   $t1, 1
    sb   $t1, OFFSET_OCUPADA($v0)
    jr   $ra

	set_livre:
	sb   $zero, OFFSET_OCUPADA($v0)
	jr   $ra

# Assumindo que $s0 tem o endereço do array das mesas, e $a0 o índice buscado
# e que $a1 tem o número de contato
set_telefone:
	get_mesa $a1

	addi 	$a0, $v0, OFFSET_TELEFONE 	# $t0 é o ponterio para o destino
	j 		strcpy

# Assumindo que $s0 tem o endereço do array das mesas
# TODO: Falta inserir aqui a limpeza dos 
formatar_mesas:
	li 		$t0, 0 		# i = 0
	
loop_mesas:
	bge 	$t0, MESA_COUNT, fim_fmt_mesa	# se i >= MESA_COUNT sai do loop

	move 	$a0, $t0 	# $a0 = i
	li 		$ai, 0 		# $ai = 0 para desocupar
	jal 	set_is_ocupada

	addi 	$t0, $t0, 1 # i++

	j loop_mesas

fim_fmt_mesa:
	jr 		$ra


sair:
	addi 		$v0, $0, 10 # Serviço para encerrar o programa
	syscall		
