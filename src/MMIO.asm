#Implementação inicial do MMIO (Memory-mapped Input/Output)

.text
# $t0 = Iterador do endereço
# $t1 = Receiver Control; endereço = 0xFFFF0000
# $t2 = Receiver Data = 0xFFFF0004
# $t3 = Transmitter Control = 0xFFFF0008
#  	Transmitter Data = 0xFFFF000c

li $t0, 0xFFFF0000

espera_Receiver_disponivel: # (0xFFFF0000, último byte == _0). Enquanto o último byte desse registrador for diferente de zero, ou seja não houver tecla digitada, volte no loop e esteja sempre disponível para receber, abordagem polling   
	lw $t1, ($t0) # Recebe o valor do Receiver Control
	beq $t1, $zero, espera_Receiver_disponivel # Se zero, continua esperando
	
lw $t2, 4($t0) # Recebe o byte transferido (caracter) do Receiver Data, que possui endereço 0xFFFF0004, vizinho ao Receiver Control

espera_Transmitter_disponivel: # (0xFFFF0008, ultimo byte == _0) Enquanto o ultimo byte for zero, ou seja, não estiver disponivel, tente novamente, até estar
	lw $t3, 8($t0) # Recebe o valor do Transmitter Control
	beq $t3, $zero, espera_Transmitter_disponivel # Se zero continua esperando
	
sw $t2, 12($t0)
j espera_Receiver_disponivel
