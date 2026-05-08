.data
	# Constantes
	.eqv MESA_TAM		224 # O tamanho em bytes de uma mesa na memória + estrutura com comanda
	.eqv MESA_COUNT		15 # Quantidade de mesas no array
	.eqv COMANDA_MAX	20 # Máximo de pedidos por mesa
	.eqv ITEM_COMANDA_TAM	8  # Tamanho de um item da comanda (4 bytes id + 4 bytes quantidade)
	
	# offsets para separar onde fica cada atributo na memória alocada da mesa (alinhados a 4 bytes)
	.eqv OFFSET_ID			0   # 4 bytes
	.eqv OFFSET_OCUPADA 	4   # 4 bytes (bool com padding)
	.eqv OFFSET_RESPONSAVEL	8   # 20 bytes (até byte 27, alinhar para 28)
	.eqv OFFSET_TELEFONE	28  # 12 bytes (até byte 39, alinhar para 40)
	.eqv OFFSET_COMANDA		40  # Início da comanda (20 itens * 8 bytes = 160 bytes, até byte 199, alinhar para 200)
	.eqv OFFSET_TOTAL_PAGO	200 # 4 bytes
	.eqv OFFSET_SALDO_DEVEDOR 204 # 4 bytes

	.macro get_mesa(%reg_preservar)
	    addiu $sp, $sp, -8			# Armazena 2 bytes na pilha
	    sw   $ra, 4($sp)			# Preserva a entradas da função, e endereço correto na pilha antes de chamar a busca   
	    sw   %reg_preservar, 0($sp)
	    jal  buscar_mesa_id			# Busca o endereço da mesa de mesmo ID
	    lw   %reg_preservar, 0($sp) # restaura a entrada original
	    lw   $ra, 4($sp)			# Restaura o endereço do return
	    addiu $sp, $sp, 8
	.end_macro

	# Mensagens de sucesso e erro
	msg_sucesso:				.asciiz "Atendimento iniciado com sucesso"
	msg_mesa_ocupada:			.asciiz "Falha: mesa ocupada"
	msg_mesa_inexistente:		.asciiz "Falha: mesa inexistente"
	msg_mesa_nao_iniciou:		.asciiz "Falha: mesa nao iniciou atendimento"
	msg_item_adicionado:		.asciiz "Item adicionado com sucesso"
	msg_item_removido:			.asciiz "Item removido com sucesso"
	msg_item_invalido:			.asciiz "Falha: codigo do item invalido"
	msg_item_nao_cadastrado:	.asciiz "Falha: item não cadastrado no cardápio"
	msg_item_nao_consta:		.asciiz "Falha: item nao consta na conta"
	msg_pagamento_realizado:	.asciiz "Pagamento realizado com sucesso"
	msg_saldo_devedor:			.asciiz "Falha: saldo devedor ainda não quitado. Valor restante: R$ "
	msg_mesa_fechada:			.asciiz "Mesa fechada com sucesso"
	msg_relatorio_itens:		.asciiz "--- Itens pedidos ---"
	msg_relatorio_total:		.asciiz "Valor total: "
	msg_relatorio_pago:			.asciiz "Valor pago: "
	msg_relatorio_devedor:		.asciiz "Saldo devedor: "
	quebra_linha:				.asciiz "\n"
	
	.align 4
	arr_mesas: .space 		3360   # 15 * 224 = 3360 bytes (alinhado a 4 bytes)

.text
.globl buscar_mesa_id
.globl set_is_ocupada
.globl iniciar_mesa
.globl mesa_ad_item
.globl mesa_rm_item
.globl mesa_pagar
.globl mesa_fechar
.globl mesa_parcial
.globl formatar_mesas
.globl arr_mesas

# Assumindo que $s0 tem o endereço do array das mesas, e $a0 o índice
iniciar_mesa:
	addiu 	$sp, $sp, -20 	# para $ra + 3 argumentos
	sw 		$ra, 16($sp)	# preserva retorno de quem chamou iniciar_mesa
	sw 		$a0, 12($sp)	  	# Salva o id
	sw 		$a1, 8($sp)		# Salva o telefone
	sw 		$a2, 4($sp)   	# Salva o nome

	li 		$t0, 1
	li 		$t1, 15
	
	blt 	$a0, $t0, mesa_inexistente	# se id < 1, mesa inexistente
	bgt 	$a0, $t1, mesa_inexistente	# se id > 15, mesa inexistente
	addi 	$a0, $a0, -1

	jal  	buscar_mesa_id 	# Busca o índice correto
	move 	$t2, $v0 		# Endereço da mesa
	lb 		$t3, OFFSET_OCUPADA($t2)	# $t3 é o status de ocupada

	bne 	$t3, $0, mesa_ja_ocupada

	# Chama o set_telefone
	move 	$a0, $a0		# Mantém o id
	lw 		$a1, 8($sp) 	# Recupera o telefone
	jal 	set_telefone

	# Chama set_responsavel
	lw 		$a0, 12($sp)		# Recupera o id
	addi 	$a0, $a0, -1		# Corrige o id
	lw 		$a1, 4($sp) 	# Recupera o nome
	jal 	set_nome_responsavel

	# Chama set_is_ocupada
	lw 		$a0, 12($sp)		# Recupera o id
	addi 		$a0, $a0, -1  		# Converte o índice
	li 		$a1, 1 			# Ocupar
	jal 	set_is_ocupada

	la 		$a0, msg_sucesso
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	
	li 		$v0, 0						# Retorna 0 (sucesso)
	
	j 		iniciar_mesa_fim

mesa_inexistente:
	la 		$a0, msg_mesa_inexistente
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	
	li 		$v0, 1						# Retorna 1 (mesa inexistente)
	j 		iniciar_mesa_fim

mesa_ja_ocupada:
	la 		$a0, msg_mesa_ocupada
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	
	li 		$v0, 2						# Retorna 2 (mesa ocupada)

iniciar_mesa_fim:
	lw 		$ra, 16($sp)
	addiu 	$sp, $sp, 20
	jr 		$ra


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

	addi 	$a0, $v0, OFFSET_TELEFONE 	# $a0 é o ponterio para o destino
	addiu 	$sp, $sp, -4
	sw 		$ra, 0($sp)
	jal 	strcpy
	lw 		$ra, 0($sp)
	addiu 	$sp, $sp, 4
	jr 		$ra

# Assumindo que $s0 tem o endereço do array das mesas, e $a0 o índice buscado
# e que $a1 tem o nome do responsável
set_nome_responsavel:
	get_mesa $a1

	addi 	$a0, $v0, OFFSET_RESPONSAVEL #
	addiu 	$sp, $sp, -4
	sw 		$ra, 0($sp)
	jal 	strcpy
	lw 		$ra, 0($sp)
	addiu 	$sp, $sp, 4
	jr 		$ra

# Assumindo que $s0 tem o endereço do array das mesas, e $a0 o índice
formatar_mesas:
	addiu	$sp, $sp, -4	# Reservar espaço para $ra
	sw		$ra, 0($sp)	# Salvar $ra
	
	li 		$t0, 0 		# i = 0
	
loop_mesas:
	bge 	$t0, MESA_COUNT, fim_fmt_mesa	# se i >= MESA_COUNT sai do loop

	move 	$a0, $t0 	# $a0 = i
	
	# Buscar mesa
	jal 	buscar_mesa_id
	move 	$t4, $v0  # Salvar endereço da mesa em $t4
	
	# Desocupar mesa
	sb 		$zero, OFFSET_OCUPADA($t4)
	
	# Limpar comanda
	addi 	$t1, $t4, OFFSET_COMANDA
	li 		$t2, 0
	li 		$t3, COMANDA_MAX
	
clear_comanda:
	bge 	$t2, $t3, fim_clear_comanda
	sw 		$zero, 0($t1)
	sw 		$zero, 4($t1)
	addi 	$t1, $t1, 8
	addi 	$t2, $t2, 1
	j 		clear_comanda
	
fim_clear_comanda:
	# Limpar totais
	sw 		$zero, OFFSET_TOTAL_PAGO($t4)
	sw 		$zero, OFFSET_SALDO_DEVEDOR($t4)

	addi 	$t0, $t0, 1 # i++

	j loop_mesas

fim_fmt_mesa:
	lw		$ra, 0($sp)	# Recuperar $ra
	addiu	$sp, $sp, 4	# Liberar espaço
	jr 		$ra


# mesa_ad_item: $a0 = id_mesa (1-15), $a1 = id_item (1-20)
# Retorna: $v0 = 0 (sucesso), 1 (mesa inexistente), 2 (mesa não iniciada), 3 (item inválido), 4 (item não cadastrado)
mesa_ad_item:
	addiu 	$sp, $sp, -16
	sw 		$ra, 12($sp)
	sw 		$a0, 8($sp)
	sw 		$a1, 4($sp)
	
	# Validar ID da mesa
	li 		$t0, 1
	li 		$t1, 15
	blt 	$a0, $t0, ad_item_mesa_inexistente
	bgt 	$a0, $t1, ad_item_mesa_inexistente
	
	# Validar ID do item
	li 		$t0, 1
	li 		$t1, 20
	blt 	$a1, $t0, ad_item_invalido
	bgt 	$a1, $t1, ad_item_invalido
	
	# Buscar mesa
	addi 	$a0, $a0, -1
	jal 	buscar_mesa_id
	move 	$t2, $v0  # Endereço da mesa
	
	# Verificar se mesa está ocupada
	lb 		$t3, OFFSET_OCUPADA($t2)
	beq 	$t3, $zero, ad_item_nao_iniciado
	
	# TODO: Verificar se item existe no cardápio (chamar função de cardápio)
	# Por enquanto, apenas adicionar o item
	
	# Procurar espaço na comanda ou incrementar quantidade se já existe
	lw 		$a0, 4($sp)  # Recuperar ID do item
	move 	$t4, $t2
	addi 	$t4, $t4, OFFSET_COMANDA
	li 		$t5, 0  # contador de itens
	
busca_item_ad:
	bge 	$t5, COMANDA_MAX, ad_item_novo
	lw 		$t6, 0($t4)  # ID do item
	beq 	$t6, $a0, ad_item_incrementa  # Item já existe
	addi 	$t4, $t4, 8
	addi 	$t5, $t5, 1
	j 		busca_item_ad
	
ad_item_incrementa:
	lw 		$t6, 4($t4)  # Quantidade
	addi 	$t6, $t6, 1
	sw 		$t6, 4($t4)
	j 		ad_item_sucesso
	
ad_item_novo:
	# Encontrar primeiro espaço vazio
	move 	$t4, $t2
	addi 	$t4, $t4, OFFSET_COMANDA
	li 		$t5, 0
	
busca_espaco:
	bge 	$t5, COMANDA_MAX, ad_item_sem_espaco
	lw 		$t6, 0($t4)
	beq 	$t6, $zero, espaco_encontrado
	addi 	$t4, $t4, 8
	addi 	$t5, $t5, 1
	j 		busca_espaco
	
espaco_encontrado:
	lw 		$a0, 4($sp)
	sw 		$a0, 0($t4)  # ID do item
	li 		$t6, 1
	sw 		$t6, 4($t4)  # Quantidade = 1
	
ad_item_sucesso:
	la 		$a0, msg_item_adicionado
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 0
	j 		ad_item_fim
	
ad_item_sem_espaco:
	la 		$a0, msg_item_adicionado  # Considerar como sucesso mesmo cheio
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 0
	j 		ad_item_fim
	
ad_item_mesa_inexistente:
	la 		$a0, msg_mesa_inexistente
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 1
	j 		ad_item_fim
	
ad_item_nao_iniciado:
	la 		$a0, msg_mesa_nao_iniciou
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 2
	j 		ad_item_fim
	
ad_item_invalido:
	la 		$a0, msg_item_invalido
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 3
	
ad_item_fim:
	lw 		$ra, 12($sp)
	addiu 	$sp, $sp, 16
	jr 		$ra


# mesa_rm_item: $a0 = id_mesa (1-15), $a1 = id_item (1-20)
# Retorna: $v0 = 0 (sucesso), 1 (mesa inexistente), 2 (mesa não iniciada), 3 (item inválido), 4 (item não consta)
mesa_rm_item:
	addiu 	$sp, $sp, -16
	sw 		$ra, 12($sp)
	sw 		$a0, 8($sp)
	sw 		$a1, 4($sp)
	
	# Validar ID da mesa
	li 		$t0, 1
	li 		$t1, 15
	blt 	$a0, $t0, rm_item_mesa_inexistente
	bgt 	$a0, $t1, rm_item_mesa_inexistente
	
	# Validar ID do item
	li 		$t0, 1
	li 		$t1, 20
	blt 	$a1, $t0, rm_item_invalido
	bgt 	$a1, $t1, rm_item_invalido
	
	# Buscar mesa
	addi 	$a0, $a0, -1
	jal 	buscar_mesa_id
	move 	$t2, $v0  # Endereço da mesa
	
	# Verificar se mesa está ocupada
	lb 		$t3, OFFSET_OCUPADA($t2)
	beq 	$t3, $zero, rm_item_nao_iniciado
	
	# Procurar e remover o item
	lw 		$a0, 4($sp)  # Recuperar ID do item
	move 	$t4, $t2
	addi 	$t4, $t4, OFFSET_COMANDA
	li 		$t5, 0  # contador de itens
	
busca_item_rm:
	bge 	$t5, COMANDA_MAX, rm_item_nao_consta
	lw 		$t6, 0($t4)  # ID do item
	beq 	$t6, $a0, rm_item_decrementou  # Item encontrado
	addi 	$t4, $t4, 8
	addi 	$t5, $t5, 1
	j 		busca_item_rm
	
rm_item_decrementou:
	lw 		$t6, 4($t4)  # Quantidade
	addi 	$t6, $t6, -1
	bne 	$t6, $zero, rm_item_decrementou
	
	# Se quantidade chegou a 0, remover o item
	sw 		$zero, 0($t4)
	sw 		$zero, 4($t4)
	
#rm_item_decrementou:
#	sw 		$t6, 4($t4)
#	la 		$a0, msg_item_removido
#	jal 	print
#	la 		$a0, quebra_linha
#	jal 	print
#	li 		$v0, 0
#	j 		rm_item_fim
	
rm_item_mesa_inexistente:
	la 		$a0, msg_mesa_inexistente
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 1
	j 		rm_item_fim
	
rm_item_nao_iniciado:
	la 		$a0, msg_mesa_nao_iniciou
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 2
	j 		rm_item_fim
	
rm_item_invalido:
	la 		$a0, msg_item_invalido
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 3
	j 		rm_item_fim
	
rm_item_nao_consta:
	la 		$a0, msg_item_nao_consta
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 4
	
rm_item_fim:
	lw 		$ra, 12($sp)
	addiu 	$sp, $sp, 16
	jr 		$ra


# mesa_pagar: $a0 = id_mesa (1-15), $a1 = valor em centavos
# Retorna: $v0 = 0 (sucesso), 1 (mesa inexistente), 2 (mesa não iniciada)
mesa_pagar:
	addiu 	$sp, $sp, -12
	sw 		$ra, 8($sp)
	sw 		$a0, 4($sp)
	
	# Validar ID da mesa
	li 		$t0, 1
	li 		$t1, 15
	blt 	$a0, $t0, pagar_mesa_inexistente
	bgt 	$a0, $t1, pagar_mesa_inexistente
	
	# Buscar mesa
	addi 	$a0, $a0, -1
	jal 	buscar_mesa_id
	move 	$t2, $v0  # Endereço da mesa
	
	# Verificar se mesa está ocupada
	lb 		$t3, OFFSET_OCUPADA($t2)
	beq 	$t3, $zero, pagar_nao_iniciado
	
	# Atualizar total pago
	lw 		$t4, OFFSET_TOTAL_PAGO($t2)
	add 	$t4, $t4, $a1
	sw 		$t4, OFFSET_TOTAL_PAGO($t2)

	#Subtrair do saldo devedor
	lw 		$t5, OFFSET_SALDO_DEVEDOR($t2)
	bgt 	$a1, $t5, pagamento_maior
	sub 	$t5, $t5, $a1 #Subtraio do valor pago atualmente apenas, não de todos os valores pagos, por isso nao passo $t4
	sw		$t5, OFFSET_SALDO_DEVEDOR($t2)
	j		pagamento_concluir

	pagamento_maior:
	sw $zero, OFFSET_SALDO_DEVEDOR($t2) # Se o pagamento for maior que o valor devedor, zera o valor devedor (não fica negativo)
	
	pagamento_concluir:
	la 		$a0, msg_pagamento_realizado
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 0
	j 		pagar_fim
	
pagar_mesa_inexistente:
	la 		$a0, msg_mesa_inexistente
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 1
	j 		pagar_fim
	
pagar_nao_iniciado:
	la 		$a0, msg_mesa_nao_iniciou
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 2
	
pagar_fim:
	lw 		$ra, 8($sp)
	addiu 	$sp, $sp, 12
	jr 		$ra


# mesa_fechar: $a0 = id_mesa (1-15)
# Retorna: $v0 = 0 (sucesso), 1 (mesa inexistente), 2 (saldo devedor não quitado)
mesa_fechar:
	addiu 	$sp, $sp, -12
	sw 		$ra, 8($sp)
	sw 		$a0, 4($sp)
	
	# Validar ID da mesa
	li 		$t0, 1
	li 		$t1, 15
	blt 	$a0, $t0, fechar_mesa_inexistente
	bgt 	$a0, $t1, fechar_mesa_inexistente
	
	# Buscar mesa
	addi 	$a0, $a0, -1
	jal 	buscar_mesa_id
	move 	$t2, $v0  # Endereço da mesa
	
	# Verificar saldo devedor (TODO: calcular saldo_devedor = total - pago)
	lw 		$t3, OFFSET_SALDO_DEVEDOR($t2)
	bne 	$t3, $zero, fechar_saldo_devedor
	
	# Desocupar mesa
	li 		$a0, 0  # índice já corrigido
	lw 		$a0, 4($sp)
	addi 	$a0, $a0, -1
	li 		$a1, 0
	jal 	set_is_ocupada
	
	# Limpar comanda
	lw 		$a0, 4($sp)
	addi 	$a0, $a0, -1
	jal 	buscar_mesa_id
	addi 	$t1, $v0, OFFSET_COMANDA
	li 		$t2, 0
	li 		$t3, COMANDA_MAX
	
clear_fechar:
	bge 	$t2, $t3, fim_clear_fechar
	sw 		$zero, 0($t1)
	sw 		$zero, 4($t1)
	addi 	$t1, $t1, 8
	addi 	$t2, $t2, 1
	j 		clear_fechar
	
fim_clear_fechar:
	lw 		$a0, 4($sp)
	addi 	$a0, $a0, -1
	jal 	buscar_mesa_id
	sw 		$zero, OFFSET_TOTAL_PAGO($v0)
	sw 		$zero, OFFSET_SALDO_DEVEDOR($v0)
	
	la 		$a0, msg_mesa_fechada
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 0
	j 		fechar_fim
	
fechar_mesa_inexistente:
	la 		$a0, msg_mesa_inexistente
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 1
	j 		fechar_fim
	
fechar_saldo_devedor:
	la 		$a0, msg_saldo_devedor
	jal 	print
	# TODO: Formatar valor em R$ XXXX,XX
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 2
	
fechar_fim:
	lw 		$ra, 8($sp)
	addiu 	$sp, $sp, 12
	jr 		$ra


# mesa_parcial: $a0 = id_mesa (1-15)
# Retorna: $v0 = 0 (sucesso), 1 (mesa inexistente)
# Imprime o relatório de consumo
mesa_parcial:
	addiu 	$sp, $sp, -16
	sw 		$ra, 12($sp)
	sw 		$a0, 8($sp)
	
	# Validar ID da mesa
	li 		$t0, 1
	li 		$t1, 15
	blt 	$a0, $t0, parcial_mesa_inexistente
	bgt 	$a0, $t1, parcial_mesa_inexistente
	
	# Converter ID (1-15) para índice (0-14)
	addi 	$a0, $a0, -1
	
	# Buscar mesa
	jal 	buscar_mesa_id
	move 	$t2, $v0	# $t2 = endereço da mesa
	
	# Verificar se mesa foi iniciada (OFFSET_OCUPADA == 1)
	lb 		$t3, OFFSET_OCUPADA($t2)
	beq 	$t3, $zero, parcial_mesa_nao_iniciada
	
	# Imprimir cabeçalho do relatório
	la 		$a0, msg_relatorio_itens
	jal 	print
	
	# TODO: Listar itens da comanda com quantidades
	# Por enquanto, apenas imprimir os totais
	
	# Imprimir valor total
	la 		$a0, msg_relatorio_total
	jal 	print_raw
	lw 		$a0, OFFSET_TOTAL_PAGO($t2)
	jal 	print_int
	la 		$a0, quebra_linha
	jal 	print
	
	# Imprimir valor pago
	la 		$a0, msg_relatorio_pago
	jal 	print_raw
	lw 		$a0, OFFSET_TOTAL_PAGO($t2)
	jal 	print_int
	la 		$a0, quebra_linha
	jal 	print
	
	# Imprimir saldo devedor
	la 		$a0, msg_relatorio_devedor
	jal 	print_raw
	lw 		$a0, OFFSET_SALDO_DEVEDOR($t2)
	jal 	print_int
	la 		$a0, quebra_linha
	jal 	print
	
	li 		$v0, 0
	j 		parcial_fim

parcial_mesa_nao_iniciada:
	la 		$a0, msg_mesa_nao_iniciou
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 2
	j 		parcial_fim
	
parcial_mesa_inexistente:
	la 		$a0, msg_mesa_inexistente
	jal 	print
	la 		$a0, quebra_linha
	jal 	print
	li 		$v0, 1
	
parcial_fim:
	lw 		$ra, 12($sp)
	addiu 	$sp, $sp, 16
	jr 		$ra		
