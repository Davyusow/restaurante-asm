.data
	strA:	.asciiz "carro"
	strB:	.asciiz "laje"

.text

test_utils:
	# Mostra strA
	la 		$a0, strA
	jal 	print

	# Mostra strB
	la 		$a0, strB
	jal 	print

	# Teste 1: carro vs laje (esperado: negativo)
	la 		$a0, strA
	la 		$a1, strB
	jal 	strcmp
	move 	$a0, $v0
	jal 	print_int	# Mostra o resultado numérico

	# Teste 2: carro vs carro (esperado: 0)
	la      $a0, strA
    la      $a1, strA
    jal     strcmp
    move    $a0, $v0
    jal     print_int 	# Mostra o resultado numérico
    j 		exit

exit:
    li      $v0, 10
    syscall
