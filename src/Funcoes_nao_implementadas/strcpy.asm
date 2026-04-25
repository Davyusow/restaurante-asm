.data
	origem:  .asciiz "Hello World"
	destino: .byte 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', '\0' 

.text
	main:
	la $a0, destino	##a0 é o inicio do array do destination (destino)
	la $a1, origem	##a1 é o inicio do array de source (origem)
	
	strcopy: ##Para utilizar essa função obrigatóriamente deve ser passado como parâmetro nos registradores a0 e a1 o ENDEREÇO, por meio da função "la" (LOAD ADDRESS)
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
		jr $ra #Volta para o lugar onde a função foi chamada
	
