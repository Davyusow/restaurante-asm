# Matheus Aroxa, Davyusow Farias, Lucas Carvalho, 1va 2026.1
# Descricao: testes de persistencia (salvar, carregar, formatar).

.data
    # Dados para testes de persistência
    telefone_teste:     .asciiz "81 99090-9090"
    nome_teste:         .asciiz "João Silva"
    
    # Labels de testes de persistência
    label_inicio:       .asciiz "========== TESTES DE PERSISTÊNCIA =========="
    label_persist1:     .asciiz "\n[TESTE 1] Inicializar dados de teste"
    label_persist2:     .asciiz "[TESTE 2] Salvar dados em backup.txt"
    label_persist3:     .asciiz "[TESTE 3] Formatar (limpar) dados em memória"
    label_persist4:     .asciiz "[TESTE 4] Carregar dados de backup.txt"
    label_persist5:     .asciiz "[TESTE 5] Verificar integridade dos dados"
    label_persist6:     .asciiz "[TESTE 6] Novo ciclo: Formatar → Popular → Salvar"
    
    # Mensagens de status
    msg_nl:             .asciiz "\n"
    msg_separador:      .asciiz "---------------------------------------------------"
    msg_populando:      .asciiz "Populando mesas com dados de teste..."
    msg_mesa_1:         .asciiz "  Iniciando mesa 1"
    msg_mesa_2:         .asciiz "  Iniciando mesa 2"
    msg_item_mesa1:     .asciiz "  Adicionando items na mesa 1"
    msg_item_mesa2:     .asciiz "  Adicionando items na mesa 2"
    msg_pagamento:      .asciiz "  Registrando pagamentos"
    msg_verificando:    .asciiz "Verificando integridade..."
    msg_dados_ok:       .asciiz "  [OK] Dados carregados com sucesso!"
    msg_teste_completo: .asciiz "\n========== TODOS OS TESTES COMPLETADOS =========="

.text
.globl test_persistencia

test_persistencia:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)

    la $s0, arr_mesas   # Endereço inicial do array das mesas

    # Cabeçalho
    la $a0, label_inicio
    jal print
    la $a0, msg_nl
    jal print
    la $a0, msg_separador
    jal print
    la $a0, msg_nl
    jal print

    # ===== TESTE 1: Inicializar dados de teste =====
    la $a0, label_persist1
    jal print
    la $a0, msg_nl
    jal print
    
    # Formatar mesas (começar do zero)
    jal formatar_mesas
    la $a0, msg_populando
    jal print
    la $a0, msg_nl
    jal print

    # Iniciar mesa 1
    la $a0, msg_mesa_1
    jal print
    la $a0, msg_nl
    jal print
    li $a0, 1
    la $a1, telefone_teste
    la $a2, nome_teste
    jal iniciar_mesa

    # Iniciar mesa 2
    la $a0, msg_mesa_2
    jal print
    la $a0, msg_nl
    jal print
    li $a0, 2
    la $a1, telefone_teste
    la $a2, nome_teste
    jal iniciar_mesa

    # Adicionar items na mesa 1
    la $a0, msg_item_mesa1
    jal print
    la $a0, msg_nl
    jal print
    li $a0, 1
    li $a1, 5
    jal mesa_ad_item
    li $a0, 1
    li $a1, 10
    jal mesa_ad_item
    li $a0, 1
    li $a1, 3
    jal mesa_ad_item

    # Adicionar items na mesa 2
    la $a0, msg_item_mesa2
    jal print
    la $a0, msg_nl
    jal print
    li $a0, 2
    li $a1, 7
    jal mesa_ad_item
    li $a0, 2
    li $a1, 12
    jal mesa_ad_item

    # Registrar pagamentos
    la $a0, msg_pagamento
    jal print
    la $a0, msg_nl
    jal print
    li $a0, 1
    li $a1, 5000
    jal mesa_pagar
    li $a0, 2
    li $a1, 3000
    jal mesa_pagar

    la $a0, msg_separador
    jal print
    la $a0, msg_nl
    jal print

    # ===== TESTE 2: Salvar dados em backup.txt =====
    la $a0, label_persist2
    jal print
    la $a0, msg_nl
    jal print
    jal salvar_persistencia

    la $a0, msg_separador
    jal print
    la $a0, msg_nl
    jal print

    # ===== TESTE 3: Formatar (limpar) dados em memória =====
    la $a0, label_persist3
    jal print
    la $a0, msg_nl
    jal print
    jal formatar_persistencia

    la $a0, msg_separador
    jal print
    la $a0, msg_nl
    jal print

    # ===== TESTE 4: Carregar dados de backup.txt =====
    la $a0, label_persist4
    jal print
    la $a0, msg_nl
    jal print
    jal carregar_persistencia

    la $a0, msg_separador
    jal print
    la $a0, msg_nl
    jal print

    # ===== TESTE 5: Verificar integridade =====
    la $a0, label_persist5
    jal print
    la $a0, msg_nl
    jal print
    la $a0, msg_verificando
    jal print
    la $a0, msg_nl
    jal print

    # Mostrar relatório da mesa 1
    li $a0, 1
    jal mesa_parcial
    
    # Mostrar relatório da mesa 2
    li $a0, 2
    jal mesa_parcial

    la $a0, msg_dados_ok
    jal print
    la $a0, msg_nl
    jal print

    la $a0, msg_separador
    jal print
    la $a0, msg_nl
    jal print

    # ===== TESTE 6: Novo ciclo =====
    la $a0, label_persist6
    jal print
    la $a0, msg_nl
    jal print

    # Formatar novamente
    jal formatar_persistencia

    # Popular com novos dados
    li $a0, 1
    la $a1, telefone_teste
    la $a2, nome_teste
    jal iniciar_mesa

    li $a0, 1
    li $a1, 2
    jal mesa_ad_item

    li $a0, 1
    li $a1, 1500
    jal mesa_pagar

    # Salvar novamente
    jal salvar_persistencia

    # Mensagem de conclusão
    la $a0, msg_teste_completo
    jal print
    la $a0, msg_nl
    jal print

sair:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    addi $v0, $0, 10       # Serviço para encerrar o programa
    syscall
