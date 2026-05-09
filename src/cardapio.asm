.data
    .align 4
    .globl cardapio
    cardapio: .space 800 #cada item tem 40 bytes
    msg_invalido: .asciiz "Posição inválida"
    msg_ocupado: .asciiz "Já existe um item nessa posição do cardápio"
    msg_vazio: .asciiz "Não existe um item nessa posição do cardápio"
    str_id:    .asciiz "ID: "
    str_desc:  .asciiz "Descrição: "
    str_preco: .asciiz "Preço: "
    str_nl:    .asciiz "\n"
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
        li $t0, 1 #limite inferior do id
        blt $a0, $t0, erro_invalido #verifica se a posição é menor que 1
        li $t0, 20 #limite superior do id
        bgt $a0, $t0, erro_invalido #verifica se a posição é maior que 20

        addi $t1, $a0, -1 #calcula a posição do array pra inserir o item

        li $t2, 40 #tamanho do item em bytes
        mul $t1, $t1, $t2 # calcula o offset do array (tamanho do item)

        la $t0, cardapio
        add $t3, $t0, $t1 #posicao do cardapio com offset

        lw $t4, 0($t3) #le o id atual da posicao
        bnez $t4, erro_ocupado #verifica se os primeiros bytes são 0

        sw $a0, 0($t3) #persiste o id do item
        sw $a1, 4($t3) #persiste o preco do item

        addi $sp, $sp, -4 #reserva espaco na pilha
        sw $ra, 0($sp) #salva o ra para voltar posteriomente
        
        addi $a0, $t3, 8      #endereco de destino da string a ser copiada
        move $a1, $a2         #move a descricao para $a1 (requisito de strcopy)
        jal strcpy            #persiste descricao no cardapio  

        lw $ra, 0($sp) #restaura o ra
        addi $sp, $sp, 4 #libera a pilha
        jr $ra #retorna para o programa principal
    .globl remover_item_cardapio
    remover_item_cardapio:
        li $t0, 1 #limite inferior do id
        blt $a0, $t0, erro_invalido # verifica se a posição é menor que 1
        li $t0, 20 #limite superior do id
        bgt $a0, $t0, erro_invalido # verifica se a posição é maior que 20

        addi $t1, $a0, -1 # calcula o índice do array 
        li $t2, 40 #tamanho do item em bytes
        mul $t1, $t1, $t2 #calcula o offset

        la $t0, cardapio
        add $t3, $t0, $t1 #endereco no cardapio com offset

        lw $t4, 0($t3) #le o id atual da posicao
        beq $t4, $zero, erro_vazio #verifica se existe um item na posicao

        sw $zero, 0($t3) # apaga o id
        sw $zero, 4($t3) # apaga o Preço
        
        sb $zero, 8($t3) # apaga a descricao com \0

        jr $ra # retorna para o programa principal

    erro_invalido:
        la $a0, msg_invalido #imprime string
        li $v0, 4
        syscall
        jr $ra
    erro_ocupado:
        la $a0, msg_ocupado #imprime string
        li $v0, 4
        syscall
        jr $ra
    erro_vazio:
        la $a0, msg_vazio #imprime string
        li $v0, 4
        syscall
        jr $ra
    .globl listar_cardapio
    listar_cardapio:
        la $t0, cardapio        # posicao do cardapio
        li $t1, 0               # contator de iteracoes do loop
        li $t2, 20              # limite superior do loop

    loop_listar:
        beq $t1, $t2, fim_listar #verifica se deve continuar

        lw $t3, 0($t0)          # carrega o id do item
        beq $t3, $zero, proximo_item #se comecar com zero entao a posicao está vázio e nao há nada a imprimir

        #label id
        la $a0, str_id
        li $v0, 4
        syscall

        move $a0, $t3           # move o valor para a0, (requisito do print)
        li $v0, 1               # print inteiro
        syscall

        #printa label descricao
        la $a0, str_desc
        li $v0, 4  
        syscall


        addi $a0, $t0, 8        # pega a string, já com o offset do cardapio e joga em a0 (requisito do print) 
        li $v0, 4
        syscall

        #printa label preco
        la $a0, str_preco
        li $v0, 4
        syscall

        lw $a0, 4($t0)          # pega o preco, já com offset do cardapio e joga em a0 (requisito do print)
        li $v0, 1
        syscall

        #printa quebra de linha para formatacao
        la $a0, str_nl
        li $v0, 4
        syscall

    proximo_item:
        addi $t0, $t0, 40       # ajusta o offset para o proximo item
        addi $t1, $t1, 1        # ajusta o contador
        j loop_listar           

    fim_listar:
        jr $ra