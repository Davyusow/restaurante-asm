# =========================================================================
# Função: Strcpy
# Descrição: Copia uma string — incluindo o caractere NULL (‘\0’) — apontado pela source diretamente para o bloco de memória apontado pelo destination.
# Arqgumentos: 
#	$a0 - Destination (endereço de memória do destino)
#	$a1 - Source (endereço de memória da origem)
# Retorno:
#	$v0 - (o endereço do destino (destination)
# =========================================================================
.data
	origem:  .asciiz "Hello World"
	destino: .byte 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', '\0' 

.text
	main:
	la $a0, destino	#a0 ï¿½ o inicio do array do destination (destino)
	la $a1, origem	#a1 ï¿½ o inicio do array de source (origem)
	# PRINT ANTES (string atual do destino)
   	move $t3, $a0
  	li $v0, 4
  	move $a0, $t3
   	syscall

   	 # quebra de linha
  	 li $a0, 10
  	 li $v0, 11
  	 syscall

  	  # chama strcpy
 	 la $a0, destino
  	 la $a1, origem
   	 jal strcopy

  	 # PRINT DEPOIS
   	 la $a0, destino
  	 li $v0, 4
  	 syscall
	
	li $v0, 10
	syscall
	
	strcopy: #Para utilizar essa função obrigatóriamente deve ser passado como parâmetro nos registradores a0 e a1 o ENDEREÇO, por meio da função "la" (LOAD ADDRESS)
		addu $t0, $zero, $a0 #Armazenando o inicio do array destino em t0
		addu $t1, $zero, $a1 #Armazenando o inicio do array origem em t1
	
		while:	#t1 != 0, iterando atï¿½ o fim da string que termina com \0, a verificaï¿½ï¿½o ocorrerï¿½ no beq 		
		
			lb $t2, ($t1) #Pego apenas uma letra (no caso 1 char tem 1 byte) e passo para t2 	
			sb $t2, ($t0) #Armazeno o valor do indice (letra) atual no endereï¿½o de t0 (indice do array destino) 
			beq $t2, $zero, fim  #loop quando chegar no fim da string (\0)

			addi $t0, $t0, 1 #Andando uma letra (indice) do array origem (4 bytes)
			addi $t1, $t1, 1 #Andando uma letra (indice) do array destino (4 bytes)
			j while
		fim:
		addu $v0, $zero, $a0 #Armazenando o endereço de memória do destino (parâmetro destination) no registrador de retorno da função
		jr $ra #Volta para o lugar onde a função foi chamada
	
