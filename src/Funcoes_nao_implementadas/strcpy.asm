# =========================================================================
# Função: Strcpy
# Descrição: Copia uma string — incluindo o caractere NULL (‘\0’) — apontado pela source diretamente para o bloco de memória apontado pelo destination.
# Arqgumentos: 
#	$a0 - Destination (endereço de memória do destino)
#	$a1 - Source (endereço de memória da origem)
# Retorno:
#	$v0 - (o endereço do destino (destination)
# =========================================================================
.text
.globl strcpy
	
	strcpy: #Para utilizar essa função obrigatóriamente deve ser passado como parâmetro nos registradores a0 e a1 o ENDEREÇO, por meio da função "la" (LOAD ADDRESS)
		addu $t0, $zero, $a0 #Armazenando o inicio do array destino em t0
		addu $t1, $zero, $a1 #Armazenando o inicio do array origem em t1
	
		while:	#t1 != 0, iterando até o fim da string que termina com \0, a verificação ocorrerá no beq 		
		
			lb $t2, ($t1) #Pego apenas uma letra (no caso 1 char tem 8 bytes) e passo para t2 	
			sb $t2, ($t0) #Armazeno o valor do indice (letra) atual no endereço de t0 (indice do array destino) 
			beq $t2, $zero, fim  #loop quando chegar no fim da string (\0)

			addi $t0, $t0, 1 #Andando uma letra (indice) do array origem (4 bytes)
			addi $t1, $t1, 1 #Andando uma letra (indice) do array destino (4 bytes)
			j while #Volta para o inicio do loop
		fim:
		addu $v0, $zero, $a0 #Armazenando o endereço de memória do destino (parâmetro destination) no registrador de retorno da função
		jr $ra #Volta para o lugar onde a função foi chamada
	
