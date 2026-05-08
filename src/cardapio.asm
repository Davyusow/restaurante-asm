.data
    .globl cardapio
    cardapio: .space 800 #cada item tem 40 bytes
    msg_invalido: .asciiz "Falha: codigo de item invalido"
    msg_ocupado: .asciiz "Falha: numero de item ja cadastrado"
    msg_vazio: .asciiz "Codigo informado nao possui item cadastrado no cardapio"
    msg_add_ok: .asciiz "Item adicionado com sucesso"
    msg_rm_ok: .asciiz "Item removido com sucesso"
.text
    .globl formatar_cardapio
    formatar_cardapio:
        la $t0, cardapio #carrega o endereco do cardapio
        li $t1, 0 #inicializa o ponteiro em zero
        li $t2, 200 #inicializa t2 com valor final do loop
    loop_formatar:
        beq $t1, $t2, fim_formatar #verifica se chegou ao fim do cardapio
        sw $zero, 0($t0) #inicializa o cardapio com zeros palavra a palavra
        addi $t0, $t0, 4 #atualiza a posicao da memoria do cardapio a ser escrita
        addi $t1, $t1, 1 #atualiza o ponteiro

        j loop_formatar
    fim_formatar:
        jr $ra
    .globl adicionar_item_cardapio
    adicionar_item_cardapio:
        li $t0, 1
        blt $a0, $t0, erro_invalido #verifica se a posição é menor que 1
        li $t0, 20
        bgt $a0, $t0, erro_invalido #verifica se a posição é maior que 20

        addi $t1, $a0, -1 #calcula a posição do array pra inserir o item

        li $t2, 40 
        mul $t1, $t1, $t2 # calcula o offset do array (tamanho do item)

        la $t0, cardapio
        add $t3, $t0, $t1 #posicao do cardapio com offset

        lw $t4, 0($t3)
        bnez $t4, erro_ocupado #verifica se os primeiros bytes são 0

        sw $a0, 0($t3) #persiste o id do item
        sw $a1, 4($t3) #persiste o preco do item

        addi $sp, $sp, -4
        sw $ra, 0($sp) #salva o ra para voltar posteriomente
        
        addi $a0, $t3, 8      #endereco de destino da string a ser copiada
        move $a1, $a2         #move a descricao para $a1 (requisito de strcopy)
        jal strcpy            #persiste descricao no cardapio  

        lw $ra, 0($sp)
        addi $sp, $sp, 4
        la $a0, msg_add_ok
        jal print
        jr $ra #retorna para o programa principal
    .globl remover_item_cardapio
    remover_item_cardapio:
        li $t0, 1
        blt $a0, $t0, erro_invalido # verifica se a posição é menor que 1
        li $t0, 20
        bgt $a0, $t0, erro_invalido # verifica se a posição é maior que 20

        addi $t1, $a0, -1 # calcula o índice do array 
        li $t2, 40 
        mul $t1, $t1, $t2 #calcula o offset

        la $t0, cardapio
        add $t3, $t0, $t1 #endereco no cardapio com offset

        lw $t4, 0($t3)
        beq $t4, $zero, erro_vazio #verifica se existe um item na posicao

        sw $zero, 0($t3) # apaga o id
        sw $zero, 4($t3) # apaga o Preço
        
        sb $zero, 8($t3) # apaga a descricao com \0

        la $a0, msg_rm_ok
        jal print
        jr $ra # retorna para o programa principal

    erro_invalido:
        la $a0, msg_invalido #imprime string
        jal print
        jr $ra
    erro_ocupado:
        la $a0, msg_ocupado #imprime string
        jal print
        jr $ra
    erro_vazio:
        la $a0, msg_vazio #imprime string
        jal print
        jr $ra
    .globl listar_cardapio
    listar_cardapio:
        la $t0, cardapio        # posicao do cardapio
        li $t1, 0               # contator de iteracoes do loop
        li $t2, 20              # limite superior do loop

    loop_listar:
        beq $t1, $t2, fim_listar #verifica se deve continuar

        lw $t3, 0($t0)
        beq $t3, $zero, proximo_item #se comecar com zero entao a posicao está vázio e nao há nada a imprimir

        move $a0, $t3
        jal mmio_print_int
        li $a0, 32
        jal mmio_write_char

        lw $a0, 4($t0)
        jal mmio_print_money
        li $a0, 32
        jal mmio_write_char

        addi $a0, $t0, 8
        jal mmio_print_string
        li $a0, 10
        jal mmio_write_char

    proximo_item:
        addi $t0, $t0, 40       # ajusta o offset para o proximo item
        addi $t1, $t1, 1        # ajusta o contador
        j loop_listar           

    fim_listar:
        jr $ra