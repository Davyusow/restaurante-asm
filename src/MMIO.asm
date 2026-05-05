#Implementação inicial do MMIO (Memory-mapped Input/Output)

.data
buffer: .space 51

.text
# OBS: Todos os registradores do tipo $t_ utilizados recebem o valor na memória, não o endereço


# $t0 = valor do \n em ascii

# $s0 = Iterador do endereço, tem como valor o próprio endereço do Receiver Control
# $t1 = Receiver Control; endereço = 0xFFFF0000
# $t2 = Receiver Data = 0xFFFF0004
# $t3 = Transmitter Control = 0xFFFF0008
#  	Transmitter Data = 0xFFFF000c

# Endereços do buffer
# $s1 = endereço base do buffer de String
# $t4 = indice do array do buffer de String


li $s0, 0xFFFF0000 # Recebe o endereço do Receiver Control, que sera usado como base para acessar os outros registradores
la $s1, buffer # Endereço base do array do Buffer
add $t4, $s1, $zero # Armazena o indice zero do array buffer
addi $t0, $zero, '\n'


espera_Receiver_disponivel: # (0xFFFF0000, último bit == _0). Enquanto o último bit desse registrador for diferente de zero, ou seja não houver tecla digitada, volte no loop e esteja sempre disponível para receber, abordagem polling   
	lw $t1, ($s0) # Recebe o valor do Receiver Control
	beq $t1, $zero, espera_Receiver_disponivel # Se zero, continua esperando
	
lw $t2, 4($s0) # Recebe o byte transferido (caracter) do Receiver Data, que possui endereço 0xFFFF0004, vizinho ao Receiver Control

	 

# Checagem do limite do buffer para não dar overflow
# $t5 = Quantidade de caracteres já escritos
# $t6 = Quantidade máxima de caracteres

sub $t5, $t4, $s1 # Subtrai do endereço atual o valor do endereço inicial, assim, se por exemplo, eu estiver no indice 30 do Array, seria tipo: 1030 (endereço atual) - 1000 (endereço base), ou seja, já escrevi 30 caracteres, e armazeno isso em $t5
li $t6, 50 # Defino que o tamanho máximo é 50

beq $t5, $t6, enter_funcao # Caso tenha escrito já 50 caracteres, não armazeno mais, para não dar overflow, e parto para o enter_funcao

sb $t2, 0($t4) # Armazena no buffer
addi $t4, $t4, 1 # Itero o valor do array e desloco (como se fosse um Buffer[i++])

j espera_Receiver_disponivel

enter_funcao:
sb $zero, 1($t4) #Adiciono um /0 no fim da string para não haver erro algum

# Aqui deve-se fazer vários if's aninhados checando se o valor da string (buffer) é igual ao valor de algum comando já predefinido
