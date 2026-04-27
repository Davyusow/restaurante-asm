#Implementação inicial do MMIO (Memory-mapped Input/Output)

.text

# $t0 = Receiver Control; endereço = 0xFFFF0000
# $t1 = Receiver Data = 0xFFFF0004
# $t2 = Transmitter Control = 0xFFFF0008
# $t3 = Transmitter Data = 0xFFFF000c

espera_Receiver_disponivel: # (0xFFFF0000, último byte == _0). Enquanto o último byte desse registrador for diferente de zero, ou seja não houver tecla digitada, volte no loop e esteja sempre disponível para receber, abordagem polling   
	lw $t0, (0xFFFF0000) # Recebe o valor do Receiver Control
	beq $t0, $zero, espera_Receiver_disponivel # Se zero, continua esperando
	
lw $t1, 4(0xFFFF0000) # Recebe o byte transferido (caracter) do Receiver Data, que possui endereço 0xFFFF0004, vizinho ao Receiver Control

espera_Transmitter_disponivel: # (0xFFFF0008, ultimo byte == _0) Enquanto o ultimo byte for zero, ou seja, não estiver disponivel, tente novamente, até estar
	lw $t2, 8(0xFFFF0000) # Recebe o valor do Transmitter Control
	beq $t0, $zero, espera_Transmitter_disponivel # Se zero continua esperando
	
sw $t1, 12(0xFFFF0000)
j espera_Receiver_disponivel