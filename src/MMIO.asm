
.data
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

str_cmd_mesa_rm_item: .asciiz "mesa_rm_item"
cmd_mesa_rm_item_sucesso: .asciiz "Item removido com sucesso"
cmd_mesa_rm_item_inexistente_mesa: .asciiz "Falha: mesa inexistente"
cmd_mesa_rm_item_desocupada: .asciiz "Falha: mesa nao iniciou atendimento"
cmd_mesa_rm_item_inexistente_item: .asciiz "Falha: item nao consta na conta"
cmd_mesa_rm_item_invalido_item: .asciiz "Falha: codigo do item invalido"


str_cmd_mesa_format: .asciiz "mesa_format"
cmd_mesa_format_sucesso: .asciiz "Mesa formatada com sucesso"

str_cmd_mesa_parcial: .asciiz "mesa_parcial"


str_cmd_mesa_pagar: .asciiz "mesa_pagar"


str_cmd_mesa_fechar: .asciiz "mesa_fechar"


str_cmd_salvar: .asciiz "salvar"


str_cmd_recarregar: .asciiz "recarregar"


str_cmd_formatar: .asciiz "formatar"



str_cmd_invalido: .asciiz "Comando invalido\n"

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


	espera_Transmitter_disponivel_2: # Enquanto o ultimo bit do Transmitter Control for zero, ou seja, nao estiver disponivel para escrever, tente novamente, ate estar
		lw $t3, 8($s0) # Recebe o VALOR do Transmitter Control
		beq $t3, $zero, espera_Transmitter_disponivel_2 # Se estiver ocupado continua esperando

	lb $t2, ($t4) # Escrevo em $t2 um caractere da string a ser impressa
	beq $t2, $zero, fim_impressao # Se o caractere for \0, ou seja, o fim da string, termina a impressao
	
	sw $t2, 12($s0) # Armazena em Transmitter Data esse caractere
	addi $t4, $t4, 1 # Desloco o indice para o proximo caractere da string
	j espera_Transmitter_disponivel_2 # Volta para o loop de impressao, para imprimir o proximo caractere

	fim_impressao:
		jr $ra # Volta para o lugar onde a funcao foi chamada

.globl mmio_dividir_token # mmio_dividir_token (reg $a0 string). Funcao que divide a string do buffer em tokens, usando o caractere "-" como delimitador, adicionando \0 no final de cada token

mmio_dividir_token:

	beq $a0, $zero, string_nula # Se o endereco da string for zero, ou seja, nao houver string, termina a funcao
	add $t4, $a0, $zero # Armazena em $t4 o indice zero do array da string a ser dividida
	
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
	move $t2, $a0 # $t2 sera o iterador do array, assim recebe o ENDERECO do indice 0
	addi $t0, $zero, '0' # Passa o valor ascii de '0' para $t0
	move $v0, $zero # Limpo qualquer lixo que possa estar em $v0

	apin_loop:
	lb $t1, 0($t2) # $t1 recebe VALOR do indice $t2 da string numerica do array 

	beq $t1, $zero, char_nulo # Caso seja o fim da string (\0) finaliza a funcao apin. Nao dara problema pois ascii '0' != 0

	sub $t1, $t1, $t0 # Subtrai do char o valor ascii de '0', assim, por exemplo, se for passado '3', sera feito '3' - '0', ou seja, 51 - 48 = 3, e retorna isso em $v0

	mul $v0, $v0, 10 # Vou receber o caractere transformado anteriormente e multiplicar por 10 para estar de acordo com as casas decimais. Ou seja, se recebi agora 1, e tinha recebido antes 2, logo sei que é o número 21, assim multiplicarei o 2 por 10
	add $v0, $v0, $t1 # Somo as casas para ficar em uma unica string binaria (um unico numero) 

	addi $t2, $t2, 1 # Itero para percorrer o array numerico (como se fosse um A[i++])

	j apin_loop

	char_nulo:
	
	jr $ra # Volta para o lugar onde a funcao foi chamada

.globl checar_comando # checar_comando (reg $a0 string). Funcao que checa se a string do buffer eh igual a algum comando predefinido

	checar_comando:

	addiu $sp, $sp, -4
	sw $ra, 0($sp)

	jal mmio_dividir_token # Chama a funcao de divisao de token para dividir o comando do seu argumento

	move $s0, $v0 # Armazena em $s0 o token da funcao, o nome
	move $s1, $v1 # Armazena em $s1 os argumentos da funcao

	#Vou chamar a strcmp agora
	move $a0, $s0 # Passa o token do comando para $a0
	
	la $a1, str_cmd_cardapio_ad # Passa a string do comando "cardapio_ad" para $a1
	jal strcmp
	beq $v0, $zero, cmd_cardapio_ad # Se a string for igual, execute o comando ### Essa funcao tem parametro numerico

	move $a0, $s0 # Passa o token do comando para $a0

	la $a1, str_cmd_cardapio_rm # Passa a string do comando "cardapio_rm" para $a1
	jal strcmp
	beq $v0, $zero, cmd_cardapio_rm # Se a string for igual, execute o comando

	move $a0, $s0 # Passa o token do comando para $a0 

	la $a1, str_cmd_cardapio_list # Passa a string do comando "cardapio_list" para $a1
	jal strcmp
	beq $v0, $zero, cmd_cardapio_list # Se a string for igual, execute o comando

	move $a0, $s0 # Passa o token do comando para $a0

	la $a1, str_cmd_cardapio_format # Passa a string do comando "cardapio_format" para $a1
	jal strcmp
	beq $v0, $zero, cmd_cardapio_format # Se a string for igual, execute o comando

	move $a0, $s0 # Passa o token do comando para $a0

	la $a1, str_cmd_mesa_iniciar # Passa a string do comando "mesa_iniciar" para $a1
	jal strcmp
	beq $v0, $zero, cmd_mesa_iniciar # Se a string for igual, execute o comando

	move $a0, $s0 # Passa o token do comando para $a0

	la $a1, str_cmd_mesa_ad_item # Passa a string do comando "mesa_ad_item" para $a1
	jal strcmp
	beq $v0, $zero, cmd_mesa_ad_item # Se a string for igual, execute o comando

	move $a0, $s0 # Passa o token do comando para $a0

	la $a1, str_cmd_mesa_rm_item # Passa a string do comando "mesa_rm_item" para $a1
	jal strcmp
	beq $v0, $zero, cmd_mesa_rm_item # Se a string for igual, execute o comando

	move $a0, $s0 # Passa o token do comando para $a0

	la $a1, str_cmd_mesa_format # Passa a string do comando "mesa_format" para $a1
	jal strcmp
	beq $v0, $zero, cmd_mesa_format # Se a string for igual, execute o comando

	move $a0, $s0 # Passa o token do comando para $a0

	la $a1, str_cmd_mesa_parcial # Passa a string do comando "mesa_parcial" para $a1
	jal strcmp
	beq $v0, $zero, cmd_mesa_parcial # Se a string for igual, execute o comando

	move $a0, $s0 # Passa o token do comando para $a0

	la $a1, str_cmd_mesa_pagar # Passa a string do comando "mesa_pagar" para $a1
	jal strcmp
	beq $v0, $zero, cmd_mesa_pagar # Se a string for igual, execute o comando

	move $a0, $s0 # Passa o token do comando para $a0

	la $a1, str_cmd_mesa_fechar # Passa a string do comando "mesa_fechar" para $a1
	jal strcmp
	beq $v0, $zero, cmd_mesa_fechar # Se a string for igual, execute o comando

	move $a0, $s0 # Passa o token do comando para $a0

	la $a1, str_cmd_salvar # Passa a string do comando "salvar" para $a1
	jal strcmp
	beq $v0, $zero, cmd_salvar # Se a string for igual, execute o comando

	move $a0, $s0 # Passa o token do comando para $a0

	la $a1, str_cmd_recarregar # Passa a string do comando "recarregar" para $a1
	jal strcmp
	beq $v0, $zero, cmd_recarregar # Se a string for igual, execute o comando

	move $a0, $s0 # Passa o token do comando para $a0

	la $a1, str_cmd_formatar # Passa a string do comando "formatar" para $a1
	jal strcmp
	beq $v0, $zero, cmd_formatar # Se a string for igual, execute o comando
	
	j cmd_invalido # Se chegou aqui, o comando eh invalido


	cmd_cardapio_ad: # 3 argumentoss <option1>-<option2>-<option3>
	move $a0, $s1 # Passo como argumento o resto, ou seja, os argumentos da funcao # Checar linha 213 para entender pq uso $s1 aqui
	jal mmio_dividir_token # Vai dividir os argumentos da funcao
	move $a0, $v0 # Passo como argumento em $a0 a primeira parte do token <option1>
	jal apin # Transformo esse token em inteiro
	
	move $t0, $v0 # Escreve em $t0 o primeiro argumento

	# A partir daqui o $v1 foi reescrito, assim esta <option2>-<option3>

	move $a0, $v1 # Repete o processo para separar o resto dos tokens
	jal mmio_dividir_token # Divide <option2> de <option3>
	move $a0, $v0 # Passo <option2> para $a0
	jal apin # Transformo esse token em inteiro
	move $t1, $v0 # Escreve em $t1 o segundo argumento

	move $a0, $v1 # Passo <option3> para $a0
	jal apin # Transformo esse token em inteiro
	move $t2, $v0 # Escreve em $t2 o terceiro argumento

	#Passagem dos argumentos para os devidos registradores
	move $a0, $t0
	move $a1, $t1
	move $a2, $t2
	
	#jal adicionar_item_cardapio #chamo a funcao
	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra

	cmd_cardapio_rm: # 1 argumento <option1>
	move $a0, $s1 # Passo como argumento o resto, ou seja, os argumentos da funcao # Checar linha 213 para entender pq uso $s1 aqui
	jal apin # Transformo esse token em inteiro
	move $t0, $v0 # Escreve em $t0 o argumento

	#Passagem dos argumentos para os devidos registradores
	move $a0, $t0

	#jal remover_item_cardapio
	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra


	cmd_cardapio_list: # Sem argumentos

	#jal listar_cardapio 
	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra

	cmd_cardapio_format: # Sem argumentos

	#jal formatar_cardapio
	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra

	cmd_mesa_iniciar: # 3 argumentos <option1>-<option2>-<option3>

	move $a0, $s1 # Passo como argumento o resto, ou seja, os argumentos da funcao # Checar linha 213 para entender pq uso $s1 aqui
	jal mmio_dividir_token # Vai dividir os argumentos da funcao
	move $a0, $v0 # Passo como argumento em $a0 a primeira parte do token <option1>
	jal apin # Transformo esse token em inteiro
	
	move $t0, $v0 # Escreve em $t0 o primeiro argumento

	# A partir daqui o $v1 foi reescrito, assim esta <option2>-<option3>

	move $a0, $v1 # Repete o processo para separar o resto dos tokens
	jal mmio_dividir_token # Divide <option2> de <option3>
	move $a0, $v0 # Passo <option2> para $a0
	jal apin # Transformo esse token em inteiro
	move $t1, $v0 # Escreve em $t1 o segundo argumento

	move $a0, $v1 # Passo <option3> para $a0
	jal apin # Transformo esse token em inteiro
	move $t2, $v0 # Escreve em $t2 o terceiro argumento

	#Passagem dos argumentos para os devidos registradores
	move $a0, $t0
	move $a1, $t1
	move $a2, $t2

	#jal iniciar_mesa
	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra


	cmd_mesa_ad_item: # 2 argumentos <option1>-<option2>

	move $a0, $s1 # Passo como argumento o resto, ou seja, os argumentos da funcao # Checar linha 213 para entender pq uso $s1 aqui
	jal mmio_dividir_token # Vai dividir os argumentos da funcao
	move $a0, $v0 # Passo como argumento em $a0 a primeira parte do token <option1>
	jal apin # Transformo esse token em inteiro
	move $t0, $v0 # Escreve em $t0 o primeiro argumento

	move $a0, $v1 # Passo como argumento em $a0 a segunda parte <option 2>
	jal apin # Transformo esse token em inteiro
	move $t1, $v0 # Escreve em $t1 o segundo argumento

	#Passagem dos argumentos para os devidos registradores
	move $a0, $t0
	move $a1, $t1

	#jal mesa_ad_item
	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra

	cmd_mesa_rm_item: # 2 argumentos <option1>-<option2>

	move $a0, $s1 # Passo como argumento o resto, ou seja, os argumentos da funcao # Checar linha 213 para entender pq uso $s1 aqui
	jal mmio_dividir_token # Vai dividir os argumentos da funcao
	move $a0, $v0 # Passo como argumento em $a0 a primeira parte do token <option1>
	jal apin # Transformo esse token em inteiro
	move $t0, $v0 # Escreve em $t0 o primeiro argumento

	move $a0, $v1 # Passo como argumento em $a0 a segunda parte <option 2>
	jal apin # Transformo esse token em inteiro
	move $t1, $v0 # Escreve em $t1 o segundo argumento

	#Passagem dos argumentos para os devidos registradores
	move $a0, $t0
	move $a1, $t1

	#jal mesa_rm_item
	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra

	cmd_mesa_format: # Sem argumentos

	#jal formatar_mesas
	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra

	cmd_mesa_parcial: # 1 argumento <option1>

	move $a0, $s1 # Passo como argumento o resto, ou seja, os argumentos da funcao # Checar linha 213 para entender pq uso $s1 aqui
	jal apin # Transformo esse token em inteiro
	move $t0, $v0 # Escreve em $t0 o argumento

	#Passagem dos argumentos para os devidos registradores
	move $a0, $t0

	#jal mesa_parcial
	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra

	cmd_mesa_pagar: # 2 argumentos <option1>-<option2> 

	move $a0, $s1 # Passo como argumento o resto, ou seja, os argumentos da funcao # Checar linha 213 para entender pq uso $s1 aqui
	jal mmio_dividir_token # Vai dividir os argumentos da funcao
	move $a0, $v0 # Passo como argumento em $a0 a primeira parte do token <option1>
	jal apin # Transformo esse token em inteiro
	move $t0, $v0 # Escreve em $t0 o primeiro argumento

	move $a0, $v1 # Passo como argumento em $a0 a segunda parte <option 2>
	jal apin # Transformo esse token em inteiro
	move $t1, $v0 # Escreve em $t1 o segundo argumento

	#Passagem dos argumentos para os devidos registradores
	move $a0, $t0
	move $a1, $t1

	#jal mesa_pagar
	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra

	cmd_mesa_fechar: # 1 argumento <option1>

	move $a0, $s1 # Passo como argumento o resto, ou seja, os argumentos da funcao # Checar linha 213 para entender pq uso $s1 aqui
	jal apin # Transformo esse token em inteiro
	move $t0, $v0 # Escreve em $t0 o argumento

	#Passagem dos argumentos para os devidos registradores
	move $a0, $t0

	#jal mesa_fechar
	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra

	cmd_salvar: # Sem argumentos

	#jal
	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra

	cmd_recarregar: # Sem argumentos

	#jal
	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra

	cmd_formatar: # Sem argumentos

	#jal
	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra


	cmd_invalido:
	la $a0, str_cmd_invalido
	jal mmio_imprimir_tela

	j checar_fim # Pulo para o fim da funcao onde a sp vai ser zerada e o endereco da main retornado para o $ra

	checar_fim:
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	jr $ra
		
