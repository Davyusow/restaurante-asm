# Matheus Aroxa, Davyusow Farias, Lucas Carvalho, 1va 2026.1
# Descricao: testes das funcoes de mesas.

.data
	telefone_teste1: 	.asciiz "81 99090-9090"
	telefone_teste2: 	.asciiz "81 98080-8080"

	telefone_novo: .asciiz "81 98765-4321"
	nome_novo:     .asciiz "Maria Santos"
	
	# Labels de testes
	label_teste1:		.asciiz "========== TESTE 1: iniciar_mesa =========="
	label_teste2:		.asciiz "========== TESTE 2: mesa_ad_item =========="
	label_item_invalido:	.asciiz "--- Teste: Item inválido (> 20) ---"
	label_mesa_inexistente:	.asciiz "--- Teste: Mesa inexistente ---"
	label_teste3:		.asciiz "========== TESTE 3: mesa_rm_item =========="
	label_item_nao_consta:	.asciiz "--- Teste: Item não existe na comanda ---"
	label_teste4:		.asciiz "========== TESTE 4: mesa_pagar =========="
	label_mesa_nao_iniciou:	.asciiz "--- Teste: Mesa não iniciada ---"
	label_teste5:		.asciiz "========== TESTE 5: mesa_fechar =========="
	label_fechar_inexistente:	.asciiz "--- Teste: Fechar mesa inexistente ---"
	label_teste6:		.asciiz "========== TESTE 6: mesa_parcial =========="
	label_teste7:		.asciiz "========== TESTE 7: Mesa desocupada =========="
	
	debug_fmt_fim: 		.asciiz "[DEBUG] formatar_mesas completo"
	debug_ad_fim: 		.asciiz "[DEBUG] mesa_ad_item teste completo"

.text
.globl test
#.extern arr_mesas, 3480

test:
	la 		$s0, arr_mesas	# Endereço inicial do array das mesas
	
	# Inicializar mesas
	jal 	formatar_mesas
	
	# ===== TESTE 1: iniciar_mesa =====
	la 		$a0, label_teste1
	jal 	print
	
	# Iniciar mesa 1
	li   $a0, 1              # id = 1
	la   $a1, telefone_novo  # telefone
	la   $a2, nome_novo      # nome
	jal  iniciar_mesa
	
	# ===== TESTE 2: mesa_ad_item =====
	la 		$a0, label_teste2
	jal 	print
	
	# Adicionar item 5 na mesa 1
	li 		$a0, 1			# mesa 1
	li 		$a1, 5			# item 5
	jal 	mesa_ad_item
	
	# Adicionar item 10 na mesa 1
	li 		$a0, 1
	li 		$a1, 10
	jal 	mesa_ad_item
	
	# Adicionar item 5 novamente (deve incrementar quantidade)
	li 		$a0, 1
	li 		$a1, 5
	jal 	mesa_ad_item
	
	# Teste: item inválido (> 20)
	la 		$a0, label_item_invalido
	jal 	print
	li 		$a0, 1
	li 		$a1, 25
	jal 	mesa_ad_item
	
	# Teste: mesa inexistente
	la 		$a0, label_mesa_inexistente
	jal 	print
	li 		$a0, 20
	li 		$a1, 5
	jal 	mesa_ad_item
	
	# ===== TESTE 3: mesa_rm_item =====
	la 		$a0, label_teste3
	jal 	print
	
	# Remover item 5 da mesa 1
	li 		$a0, 1
	li 		$a1, 5
	jal 	mesa_rm_item
	
	# Remover item 10 da mesa 1
	li 		$a0, 1
	li 		$a1, 10
	jal 	mesa_rm_item
	
	# Teste: remover item que não existe
	la 		$a0, label_item_nao_consta
	jal 	print
	li 		$a0, 1
	li 		$a1, 15
	jal 	mesa_rm_item
	
	# ===== TESTE 4: mesa_pagar =====
	la 		$a0, label_teste4
	jal 	print
	
	# Adicionar item novamente para ter saldo
	li 		$a0, 1
	li 		$a1, 5
	jal 	mesa_ad_item
	
	# Fazer pagamento parcial
	li 		$a0, 1
	li 		$a1, 5000		# 50 reais em centavos
	jal 	mesa_pagar
	
	# Outro pagamento
	li 		$a0, 1
	li 		$a1, 2500
	jal 	mesa_pagar
	
	# Teste: mesa não iniciada
	la 		$a0, label_mesa_nao_iniciou
	jal 	print
	li 		$a0, 2
	li 		$a1, 1000
	jal 	mesa_pagar
	
	# ===== TESTE 6: mesa_parcial =====
	la 		$a0, label_teste6
	jal 	print
	
	# Gerar relatório da mesa 1 (ANTES de fechar!)
	li 		$a0, 1
	jal 	mesa_parcial
	
	# ===== TESTE 5: mesa_fechar =====
	la 		$a0, label_teste5
	jal 	print
	
	# Tentar fechar sem quitar (será rejeitado se houver saldo devedor)
	li 		$a0, 1
	jal 	mesa_fechar
	
	# Teste: mesa inexistente
	la 		$a0, label_fechar_inexistente
	jal 	print
	li 		$a0, 20
	jal 	mesa_fechar
	
	# ===== TESTE 7: Mesa 2 desocupada =====
	la 		$a0, label_teste7
	jal 	print
	
	# Tentar adicionar item em mesa não iniciada
	li 		$a0, 2
	li 		$a1, 5
	jal 	mesa_ad_item
	
	# Tentar remover item em mesa não iniciada
	li 		$a0, 2
	li 		$a1, 5
	jal 	mesa_rm_item
	
	j 	sair

sair:
	addi 		$v0, $0, 10 # Serviço para encerrar o programa
	syscall
