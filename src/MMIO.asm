
.data
str_cmd_invalido: .asciiz "Comando invalido\n"
str_cmd_cardapio_ad: .asciiz "cardapio_ad"
cmd_cardapio_ad_sucesso: .asciiz "Item adicionado com sucesso"
cmd_cardapio_ad_erro: .asciiz "Falha: número de item já cadastrado"

str_cmd_cardapio_rm: .asciiz "cardapio_rm"
cmd_cardapio_rm_sucesso: .asciiz "Item removido com sucesso"
cmd_cardapio_rm_inexistente: .asciiz "Código informado não possui item cadastrado no cardápio"
cmd_cardapio_rm_invalido: .asciiz "Falha: código de item inválido"

str_cmd_cardapio_list: .asciiz "cardapio_list"

str_cmd_cardapio_format: .asciiz "cardapio_format"

str_cmd_mesa_iniciar: .asciiz "mesa_iniciar"
cmd_mesa_iniciar_sucesso: .asciiz "Atendimento iniciado com sucesso"
cmd_mesa_iniciar_ocupada: .asciiz "“Falha: mesa ocupada"
cmd_mesa_iniciar_inexistente: .asciiz "Falha: mesa inexistente"

str_cmd_mesa_ad_item: .asciiz "mesa_ad_item"
cmd_mesa_ad_item_sucesso: .asciiz "Item adicionado com sucesso"
cmd_mesa_ad_item_invalido: .asciiz "Falha: código de item inválido"

.text
# OBS: Todos os registradores do tipo $t_ utilizados recebem o VALOR na memoria, nao o endereco

# VALORES
# $t0 = VALOR do \n em ascii
# $t1 = VALOR do Receiver Control
# $t2 = VALOR do Receiver Data 
# $t3 = VALOR do Transmitter Control 

# $t4 = indice que vai percorrer o array do buffer de String
# $t5 = tamanho do array do buffer de String ($a1)
# $t6 = registrador que vai checar quantos caracteres ja foram escritos no buffer

# Enderecos
# $s0 = indice que vai percorrer os registradores do MMIO, recebe o endereco do Receiver Control (0xFFFF0000)

# ENDERECO do Receiver Control = 0xFFFF0000 0($s0)
# ENDERECO do Receiver Data = 0xFFFF0004 4($s0)
# ENDERECO do Transmitter Control = 0xFFFF0008 8($s0)
# ENDERECO do Transmitter Data = 0xFFFF000c 12($s0)

# $s1 = endereco base do array do buffer de String ($a0)


.globl mmio_echo_ler_para_buffer # mmio_echo_ler_para_buffer (reg $a0 endereco do buffer, reg $a1 tamanho do buffer). A função lê o que o usuário escreve no teclado por meio do echo e armazena no buffer

mmio_echo_ler_para_buffer: 
	add $s1, $a0, $zero # Armazena em $s1 o endereco base do array do Buffer
	add $t4, $s1, $zero # Armazena em $t4 o indice zero do array buffer
	addi $t0, $zero, '\n' #Armazena em $t0 o valor ascii do \n

	li $s0, 0xFFFF0000 # $s0 Recebe o ENDERECO do Receiver Control, que sera usado como base para acessar os outros registradores

	espera_Receiver_disponivel: # Enquanto o ultimo bit do Receiver Control for zero, ou seja nao houver tecla digitada, volte no loop e esteja sempre disponvel para receber, abordagem polling   
		lw $t1, ($s0) # Recebe o VALOR do Receiver Control
		beq $t1, $zero, espera_Receiver_disponivel # Se nao foi digitado caractere, continua esperando
	
	lw $t2, 4($s0) # Recebe o byte transferido (caractere) do Receiver Data, que possui endereco 0xFFFF0004, vizinho ao Receiver Control

	espera_Transmitter_disponivel: # Enquanto o ultimo bit do Transmitter Control for zero, ou seja, nao estiver disponivel para escrever, tente novamente, ate estar
		lw $t3, 8($s0) # Recebe o VALOR do Transmitter Control
		beq $t3, $zero, espera_Transmitter_disponivel # Se estiver ocupado continua esperando
	
	sw $t2, 12($s0)# Armazena no Transmitter Data o valor guardado em $t2 (valor guardado no Receiver Data)


	#Checagem se o caracter inserido eh um \n
	beq $t2, $t0, enter_funcao # Checa se o caractere atual da String eh um \n

	add $t5, $a1, $zero # Armazeno em $t5 o tamanho do buffer
	sub $t6, $t4, $s1 # Subtrai do endereco atual o valor do endereco inicial, assim, se por exemplo, eu estiver no indice 30 do Array, seria tipo: 1030 (endereco atual) - 1000 (endereco base), ou seja, ja escrevi 30 caracteres, e armazeno isso em $t6

	beq $t5, $t6, enter_funcao # Caso tenha escrito ja 50 caracteres, nao armazeno mais, para nao dar overflow, e parto para o enter_funcao

	sb $t2, 0($t4) # Armazena no buffer
	addi $t4, $t4, 1 # Itero o valor do array e desloco (como se fosse um Buffer[i++])

	j espera_Receiver_disponivel

	enter_funcao:
		sb $zero, 0($t4) #Adiciono um /0 no fim da string para nao haver erro algum
		# Aqui deve-se fazer varios if's aninhados checando se o valor da string (buffer) eh igual ao valor de algum comando ja predefinido
		jr $ra # Volta para o lugar onde a funcao foi chamada

.globl mmio_imprimir_tela # mmio_imprimir_tela (reg $a0 string). Essa funcao serve para imprimir na tela mensagens predefinidas, armazenadas numa string que é passada como parametro em $a0, como por exemplo, o banner do buffer ou mensagens de erro e de retorno de comando

mmio_imprimir_tela: 
	li $s0, 0xFFFF0000 # $s0 Recebe o ENDERECO do Receiver Control, que sera usado como base para acessar os outros registradores
	add $t4, $a0, $zero # Armazena em $t4 o indice zero do array da string a ser impressa

	lb $t2, ($t4) # Escrevo em $t2 um caractere da string a ser impressa
	beq $t2, $zero, fim_impressao # Se o caractere for \0, ou seja, o fim da string, termina a impressao

	espera_Transmitter_disponivel: # Enquanto o ultimo bit do Transmitter Control for zero, ou seja, nao estiver disponivel para escrever, tente novamente, ate estar
		lw $t3, 8($s0) # Recebe o VALOR do Transmitter Control
		beq $t3, $zero, espera_Transmitter_disponivel # Se estiver ocupado continua esperando

	sw $t2, 12($s0) # Armazena em Transmitter Data esse caractere
	addi $t4, $t4, 1 # Desloco o indice para o proximo caractere da string
	j espera_Transmitter_disponivel # Volta para o loop de impressao, para imprimir o proximo caractere

	fim_impressao:
		jr $ra # Volta para o lugar onde a funcao foi chamada

.globl mmio_dividir_token # mmio_dividir_token (reg $a0 string). Funcao que divide a string do buffer em tokens, usando o caractere "-" como delimitador, adicionando \0 no final de cada token

mmio_dividir_token:

	beq $a0, $zero, string_nula # Se o endereco da string for zero, ou seja, nao houver string, termina a funcao
	addi $t4, $a0, $zero # Armazena em $t4 o indice zero do array da string a ser dividida
	
	mmio_dividir_token_loop:
	# $t5 vai receber o VALOR do indice atual da string
	# $t6 vai receber o valor em ascii de "-"

	lb $t5, 0($t4) # Carrega o valor do indice atual da string
	beq $t5, $zero, fim_da_string # Se o caractere for \0 termina a divisao

	addi $t6, $zero, '-' # Passa o valor ascii de "-" para $t6
	beq $t5, $t6, separador_string # Se o caractere for "-" divide a string

	addi $t4, $t4, 1 # Desloca o indice para o proximo caractere da string
	j mmio_dividir_token_loop 

	separador_string:
	sb $zero, 0($t4) # Substitui o "-" por \0, dividindo a string em um token e um resto, que pode ser um, ou vários tokens a serem divididos
	addiu $v1, $t4, 1 # O registrador de retorno $v1 vai retornar o resto dos tokens, ou seja, o indice apos o fim do primeiro token
	move $v0, $a0 # O registrador de retorno $v0 vai retornar o primeiro token
	jr $ra # Volta para o lugar onde a funcao foi chamada

	fim_da_string:
	move $v1, $zero # Como chegou no fim da string, nao ha resto para retornar em $v1, logo retorna 0
	move $v0, $a0 # Retorna o token da string
	jr $ra # Volta para o lugar onde a funcao foi chamada

	string_nula:
	move $v1, $zero # Como a string eh nula o resto sera zero
	move $v0, $zero # E o token de $v0 tambem sera zero
	jr $ra # Volta para o lugar onde a funcao foi chamada

.globl apin # ascii p inteiro [apin] (reg $a0 numero). Funcao que converte um char em int

	apin:
	sb $t1, 0($a0) #adiciono o numero 
	addi $t0, $zero, '0' # Passa o valor ascii de '0' para $t0
	sub $v0, $a0, $t0 # Subtrai do char o valor ascii de '0', assim, por exemplo, se for passado '3', sera feito '3' - '0', ou seja, 51 - 48 = 3, e retorna isso em $v0
	jr $ra # Volta para o lugar onde a funcao foi chamada

	char_nulo:
	
	jr $ra # Volta para o lugar onde a funcao foi chamada

.globl checar_comando # checar_comando (reg $a0 string). Funcao que checa se a string do buffer eh igual a algum comando predefinido

	checar_comando:
	jal mmio_dividir_token # Chama a funcao de divisao de token para dividir o comando do seu argumento

	move $s0, $v0 # Armazena em $s0 o token da funcao, o nome
	move $s1, $v1 # Armazena em $s1 os argumentos da funcao

	#Vou chamar a strcmp agora
	move $a0, $s0


		
