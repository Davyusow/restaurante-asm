.data
    
    # Caminho do arquivo de backup
    backup_file: .asciiz "backup.txt"
    
    # Mensagens de status
    msg_salvando:    .asciiz "Salvando dados em backup.txt...\n"
    msg_carregando:  .asciiz "Carregando dados de backup.txt...\n"
    msg_formatando:  .asciiz "Formatando dados em memória...\n"
    msg_sucesso:     .asciiz "Operação concluída com sucesso!\n"
    msg_erro_arquivo:.asciiz "Erro ao acessar arquivo de backup.\n"
    msg_erro_leitura:.asciiz "Erro ao ler arquivo de backup.\n"
    msg_nao_encontrado: .asciiz "Arquivo de backup não encontrado. Iniciando com dados vazios.\n"

.text
    .globl salvar_persistencia
    .globl carregar_persistencia
    .globl formatar_persistencia


# salva os dados de cardapio e mesas em um arquivo backup.txt
# Retorna: $v0 = 0 (sucesso), 1 (erro)
salvar_persistencia:
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)

    # Mensagem de início
    la $a0, msg_salvando
    li $v0, 4
    syscall

    # Abrir arquivo para escrita
    la $a0, backup_file
    li $a1, 1                  # Modo: write
    li $a2, 0
    li $v0, 13                 # open file syscall
    syscall
    
    move $s0, $v0              # guarda o file descriptor
    bgez $s0, arquivo_aberto   # se abriu ok
    
    # Erro ao abrir arquivo
    la $a0, msg_erro_arquivo
    li $v0, 4
    syscall
    li $v0, 1
    j salvar_fim

arquivo_aberto:
    # Salvar cardapio (800 bytes)
    # $a0 = file descriptor, $a1 = buffer, $a2 = length
    move $a0, $s0
    la $a1, cardapio
    li $a2, 800
    li $v0, 15                 # write file syscall
    syscall
    
    bgez $v0, cardapio_salvo   # escrita ok
    
    # Erro ao salvar cardapio
    la $a0, msg_erro_arquivo
    li $v0, 4
    syscall
    li $v0, 1
    j fechar_arquivo

cardapio_salvo:
    # Salvar mesas (3360 bytes)
    move $a0, $s0
    la $a1, arr_mesas
    li $a2, 3360
    li $v0, 15                 # write file syscall
    syscall
    
    bgez $v0, mesas_salvas     # escrita ok
    
    # Erro ao salvar mesas
    la $a0, msg_erro_arquivo
    li $v0, 4
    syscall
    li $v0, 1
    j fechar_arquivo

mesas_salvas:
    # Mensagem de sucesso
    la $a0, msg_sucesso
    li $v0, 4
    syscall
    li $v0, 0

fechar_arquivo:
    # Fechar arquivo
    move $a0, $s0
    li $v0, 16                 # close file syscall
    syscall

salvar_fim:
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    addiu $sp, $sp, 24
    jr $ra

# Carrega os dados de cardapio e mesas do arquivo backup.txt
# Retorna: $v0 = 0 (sucesso), 1 (erro)
carregar_persistencia:
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)

    # Mensagem de início
    la $a0, msg_carregando
    li $v0, 4
    syscall

    # Abrir arquivo para leitura
    la $a0, backup_file
    li $a1, 0                  # Modo: read
    li $a2, 0
    li $v0, 13                 # open file syscall
    syscall
    
    move $s0, $v0              # guarda o file descriptor
    bgez $s0, arquivo_leitura_ok # se abriu ok
    
    # Arquivo não encontrado - usar dados vazios
    la $a0, msg_nao_encontrado
    li $v0, 4
    syscall
    
    # Formatar os dados em memória
    jal formatar_persistencia
    
    li $v0, 0
    j carregar_fim

arquivo_leitura_ok:
    # Carregar cardapio (800 bytes)
    move $a0, $s0
    la $a1, cardapio
    li $a2, 800
    li $v0, 14                 # read file syscall
    syscall
    
    blez $v0, carregar_sucesso # Se leu 0 ou menos, arquivo está vazio/corrompido
    
    # Carregar mesas (3360 bytes)
    move $a0, $s0
    la $a1, arr_mesas
    li $a2, 3360
    li $v0, 14                 # read file syscall
    syscall
    
    blez $v0, fechar_arquivo_leitura # se falhou, encerra
    
carregar_sucesso:
    # Mensagem de sucesso
    la $a0, msg_sucesso
    li $v0, 4
    syscall
    li $v0, 0

fechar_arquivo_leitura:
    # Fechar arquivo
    move $a0, $s0
    li $v0, 16                 # close file syscall
    syscall

carregar_fim:
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    addiu $sp, $sp, 24
    jr $ra


# Formata (zera) todos os dados em memória
# Apaga todas as mesas e cardápios, deixando tudo vazio.
# NÃO salva automaticamente no arquivo externo.
formatar_persistencia:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    # Mensagem de início
    la $a0, msg_formatando
    li $v0, 4
    syscall

    # Formatar cardapio (800 bytes) - usando byte a byte para evitar alinhamento
    la $t0, cardapio
    li $t1, 0
    li $t2, 800

loop_formatar_cardapio:
    beq $t1, $t2, formatar_mesas_inicio
    sb $zero, 0($t0) #zera byte
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j loop_formatar_cardapio

formatar_mesas_inicio:
    # Formatar mesas (3360 bytes) - usando byte a byte para evitar alinhamento
    la $t0, arr_mesas
    li $t1, 0
    li $t2, 3360

loop_formatar_mesas:
    beq $t1, $t2, formatar_fim
    sb $zero, 0($t0) #zera byte
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j loop_formatar_mesas

formatar_fim:
    # Mensagem de sucesso
    la $a0, msg_sucesso
    li $v0, 4
    syscall

    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addiu $sp, $sp, 8
    jr $ra
