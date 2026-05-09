.data
    .globl comanda
    comanda: .space 160 #cada item da comanda tem 8 btyes
    msg_invalido: .asciiz "item inválido"
    str_id: .asciiz "ID: "
    str_quantidade: .asciiz "Quantidade: "
    str_nl:    .asciiz "\n"
    msg_nao_existe: .asciiz "Erro: O item solicitado não está cadastrado no cardápio.\n"
.text
    .globl formatar_comanda
    formatar_comanda:
        la $t0, comanda #carrega o endereco da comanda
        li $t1, 0 #inicializa o ponteiro em zero
        li $t2, 40 #inicializa t2 com valor final do loop
    loop_formatar:
        beq $t1, $t2, fim_formatar #verifica se chegou ao fim da comanda
        sw $zero, 0($t0) #inicializa a comanda com zeros palavra a palavra
        addi $t0, $t0, 4 #atualiza a posicao da memoria da comanda a ser escrita
        addi $t1, $t1, 1 #atualiza o ponteiro

        j loop_formatar
    fim_formatar:
        jr $ra
    .globl adicionar_item_comanda
    adicionar_item_comanda:
        li $t0, 1 #limite inferior do item
        blt $a0, $t0, erro_invalido #verifica se o item é menor que 1
        li $t0, 20 #limite superior do item
        bgt $a0, $t0, erro_invalido #verifica se o item é maior que 20

        addi $t1, $a0, -1 #calcula a posição do array pra inserir o item
        li $t2, 40 #offset do item cardapio
        mul $t1, $t1, $t2 #obtem o a posicao do item no cardapio

        la $t0, cardapio #obtem endereco do cardapio
        add $t0, $t0, $t1 #enredeco do item no cardapio com offset

        lw $t2, 0($t0) #carrega valor do item no cardapio
        beq $t2, $zero, erro_nao_existe #se o item não existe no cardapio

        addi $t1, $a0, -1 #calcula a posição do array pra inserir o item

        li $t2, 8 #tamanho do item na comanda
        mul $t1, $t1, $t2 # calcula o offset do array (tamanho do item)

        la $t0, comanda
        add $t3, $t0, $t1 #posicao da comanda com offset

        lw $t4, 0($t3) #le o id atual na comanda
        bnez $t4, item_ja_existe_na_comanda #verifica se o item ja existe na comanda

        sw $a0, 0($t3) #persiste o id do item
        li $t5, 1
        sw $t5, 4($t3) #define a quantidade como 1

        jr $ra
    erro_invalido:
        la $a0, msg_invalido #imprime string
        li $v0, 4
        syscall
        jr $ra
    erro_nao_existe:
        la $a0, msg_nao_existe #imprime string
        li $v0, 4
        syscall
        jr $ra
    item_ja_existe_na_comanda:
        lw $t5, 4($t3) #carrega a quantidade do pedido
        addi $t5, $t5, 1 #soma 1
        sw $t5, 4($t3)  #atualiza a quantidade
        jr $ra
    .globl listar_comanda
    listar_comanda:
        la $t0, comanda     # posicao da comanda
        li $t1, 0               # contator de iteracoes do loop
        li $t2, 20              # limite superior do loop

    loop_listar:
        beq $t1, $t2, fim_listar #verifica se deve continuar

        lw $t3, 0($t0)
        beq $t3, $zero, proximo_item #se comecar com zero entao a posicao está vázio e nao há nada a imprimir

        #label id
        la $a0, str_id
        li $v0, 4
        syscall

        move $a0, $t3           # move o valor para a0, (requisito do print)
        li $v0, 1               # print inteiro
        syscall

        #printa label quantidade
        la $a0, str_quantidade
        li $v0, 4
        syscall

        lw $a0, 4($t0)          # printa quantidade
        li $v0, 1
        syscall

        #printa quebra de linha para formatacao
        la $a0, str_nl
        li $v0, 4
        syscall

    proximo_item:
        addi $t0, $t0, 8       # ajusta o offset para o proximo item
        addi $t1, $t1, 1        # ajusta o contador
        j loop_listar           

    fim_listar:
        jr $ra