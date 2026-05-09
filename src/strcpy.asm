# Matheus Aroxa, Davyusow Farias, Lucas Carvalho, 1va 2026.1
# Descricao: copia de string.

# =========================================================================
# Fun��o: Strcpy
# Descri��o: Copia uma string � incluindo o caractere NULL (�\0�) � apontado pela source diretamente para o bloco de mem�ria apontado pelo destination.
# Arqgumentos: 
#	$a0 - Destination (endere�o de mem�ria do destino)
#	$a1 - Source (endere�o de mem�ria da origem)
# Retorno:
#	$v0 - (o endere�o do destino (destination)
# =========================================================================
.text
.globl strcpy
	
	strcpy: #Para utilizar essa fun��o obrigat�riamente deve ser passado como par�metro nos registradores a0 e a1 o ENDERE�O, por meio da fun��o "la" (LOAD ADDRESS)
		addu $t0, $zero, $a0 #Armazenando o inicio do array destino em t0
		addu $t1, $zero, $a1 #Armazenando o inicio do array origem em t1
	
		while:	#t1 != 0, iterando at� o fim da string que termina com \0, a verifica��o ocorrer� no beq 		
		
			lb $t2, ($t1) #Pego apenas uma letra (no caso 1 char tem 1 byte) e passo para t2 	
			sb $t2, ($t0) #Armazeno o valor do indice (letra) atual no endere�o de t0 (indice do array destino) 
			beq $t2, $zero, fim  #loop quando chegar no fim da string (\0)

			addi $t0, $t0, 1 #Andando uma letra (indice) do array origem (4 bytes)
			addi $t1, $t1, 1 #Andando uma letra (indice) do array destino (4 bytes)
			j while #Volta para o inicio do loop
		fim:
		addu $v0, $zero, $a0 #Armazenando o endere�o de mem�ria do destino (par�metro destination) no registrador de retorno da fun��o
		jr $ra #Volta para o lugar onde a fun��o foi chamada
	
