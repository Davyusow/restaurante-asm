.eqv MMIO_RCV_CTRL 0xFFFF0000
.eqv MMIO_TX_CTRL  0xFFFF0008

.data
banner_str:           .asciiz "resta-shell>> "
invalid_cmd_str:      .asciiz "Comando invalido\n"
cardapio_add_ok_str:  .asciiz "Item adicionado com sucesso\n"
cardapio_add_exists:  .asciiz "Falha: numero de item ja cadastrado\n"
cardapio_code_inv:    .asciiz "Falha: codigo de item invalido\n"
cardapio_rm_ok_str:   .asciiz "Item removido com sucesso\n"
cardapio_rm_miss:     .asciiz "Codigo informado nao possui item cadastrado no cardapio\n"
mesa_init_ok_str:     .asciiz "Atendimento iniciado com sucesso\n"
mesa_ocupada_str:     .asciiz "Falha: mesa ocupada\n"
mesa_inexist_str:     .asciiz "Falha: mesa inexistente\n"
mesa_nao_ini_str:     .asciiz "Falha: mesa nao iniciou atendimento\n"
mesa_item_nao_str:    .asciiz "Falha: item nao cadastrado no cardapio\n"
mesa_item_inv_str:    .asciiz "Falha: codigo do item invalido\n"
mesa_item_rm_str:     .asciiz "Falha: item nao consta na conta\n"
mesa_pago_ok_str:     .asciiz "Pagamento realizado com sucesso\n"
mesa_fecha_ok_str:    .asciiz "Mesa fechada com sucesso\n"
mesa_saldo_pref:      .asciiz "Falha: saldo devedor ainda nao quitado. Valor restante: "
real_prefix:          .asciiz "R$ "

cmd_formatar_str:     .asciiz "formatar"
cmd_cardapio_str:     .asciiz "cardapio_format"
cmd_cardapio_ad_str:  .asciiz "cardapio_ad"
cmd_cardapio_rm_str:  .asciiz "cardapio_rm"
cmd_cardapio_ls_str:  .asciiz "cardapio_list"
cmd_mesa_str:         .asciiz "mesa_format"
cmd_mesa_init_str:    .asciiz "mesa_iniciar"
cmd_mesa_add_str:     .asciiz "mesa_ad_item"
cmd_mesa_rm_str:      .asciiz "mesa_rm_item"
cmd_mesa_parc_str:    .asciiz "mesa_parcial"
cmd_mesa_pag_str:     .asciiz "mesa_pagar"
cmd_mesa_fech_str:    .asciiz "mesa_fechar"
cmd_salvar_str:       .asciiz "salvar"
cmd_recarregar_str:   .asciiz "recarregar"

input_buf:            .space 128
save_file_name:       .asciiz "restaurante.dat"

.align 2
cardapio_base:        .space 2160

.align 2
mesas_base:           .space 3360

.text
.globl main
.globl mmio_print_money
.globl mmio_write_char
.globl mmio_print_string
.globl mmio_print_int
.globl mmio_read_line
.globl ascii_to_int
.globl copy_limited
.globl next_token

main:
        jal     formatar
        jal     load_data_silent

main_loop:
        la      $a0, banner_str
        jal     mmio_print_string

        la      $a0, input_buf
        li      $a1, 128
        jal     mmio_read_line

        la      $a0, input_buf
        lb      $t0, 0($a0)
        beq     $t0, $zero, main_loop

        jal     dispatch_command
        j       main_loop

dispatch_command:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        sw      $s1, 4($sp)
        sw      $s2, 0($sp)

        move    $s0, $a0
        jal     next_token
        move    $s1, $v0
        move    $s2, $v1

        move    $a0, $s1
        la      $a1, cmd_formatar_str
        jal     strcmp
        beq     $v0, $zero, cmd_do_formatar

        move    $a0, $s1
        la      $a1, cmd_cardapio_str
        jal     strcmp
        beq     $v0, $zero, cmd_do_cardapio_format

        move    $a0, $s1
        la      $a1, cmd_cardapio_ad_str
        jal     strcmp
        beq     $v0, $zero, cmd_do_cardapio_ad

        move    $a0, $s1
        la      $a1, cmd_cardapio_rm_str
        jal     strcmp
        beq     $v0, $zero, cmd_do_cardapio_rm

        move    $a0, $s1
        la      $a1, cmd_cardapio_ls_str
        jal     strcmp
        beq     $v0, $zero, cmd_do_cardapio_list

        move    $a0, $s1
        la      $a1, cmd_mesa_str
        jal     strcmp
        beq     $v0, $zero, cmd_do_mesa_format

        move    $a0, $s1
        la      $a1, cmd_mesa_init_str
        jal     strcmp
        beq     $v0, $zero, cmd_do_mesa_init

        move    $a0, $s1
        la      $a1, cmd_mesa_add_str
        jal     strcmp
        beq     $v0, $zero, cmd_do_mesa_add

        move    $a0, $s1
        la      $a1, cmd_mesa_rm_str
        jal     strcmp
        beq     $v0, $zero, cmd_do_mesa_rm

        move    $a0, $s1
        la      $a1, cmd_mesa_parc_str
        jal     strcmp
        beq     $v0, $zero, cmd_do_mesa_parcial

        move    $a0, $s1
        la      $a1, cmd_mesa_pag_str
        jal     strcmp
        beq     $v0, $zero, cmd_do_mesa_pagar

        move    $a0, $s1
        la      $a1, cmd_mesa_fech_str
        jal     strcmp
        beq     $v0, $zero, cmd_do_mesa_fechar

        move    $a0, $s1
        la      $a1, cmd_salvar_str
        jal     strcmp
        beq     $v0, $zero, cmd_do_salvar

        move    $a0, $s1
        la      $a1, cmd_recarregar_str
        jal     strcmp
        beq     $v0, $zero, cmd_do_recarregar

        la      $a0, invalid_cmd_str
        jal     mmio_print_string
        j       dispatch_end

cmd_do_formatar:
        jal     formatar
        j       dispatch_end

cmd_do_cardapio_format:
        jal     cardapio_format
        j       dispatch_end

cmd_do_cardapio_ad:
        move    $a0, $s2
        jal     cardapio_ad_cmd
        j       dispatch_end

cmd_do_cardapio_rm:
        move    $a0, $s2
        jal     cardapio_rm_cmd
        j       dispatch_end

cmd_do_cardapio_list:
        jal     cardapio_list_cmd
        j       dispatch_end

cmd_do_mesa_format:
        jal     mesa_format
        j       dispatch_end

cmd_do_mesa_init:
        move    $a0, $s2
        jal     mesa_iniciar_cmd
        j       dispatch_end

cmd_do_mesa_add:
        move    $a0, $s2
        jal     mesa_ad_item_cmd
        j       dispatch_end

cmd_do_mesa_rm:
        move    $a0, $s2
        jal     mesa_rm_item_cmd
        j       dispatch_end

cmd_do_mesa_parcial:
        move    $a0, $s2
        jal     mesa_parcial_cmd
        j       dispatch_end

cmd_do_mesa_pagar:
        move    $a0, $s2
        jal     mesa_pagar_cmd
        j       dispatch_end

cmd_do_mesa_fechar:
        move    $a0, $s2
        jal     mesa_fechar_cmd
        j       dispatch_end

cmd_do_salvar:
        jal     save_data
        j       dispatch_end

cmd_do_recarregar:
        jal     load_data_silent
        j       dispatch_end

dispatch_end:
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        lw      $s1, 4($sp)
        lw      $s2, 0($sp)
        addiu   $sp, $sp, 16
        jr      $ra

next_token:
        beq     $a0, $zero, next_token_none
        move    $t0, $a0
next_token_loop:
        lb      $t1, 0($t0)
        beq     $t1, $zero, next_token_end
        li      $t2, 45
        beq     $t1, $t2, next_token_split
        addiu   $t0, $t0, 1
        j       next_token_loop

next_token_split:
        sb      $zero, 0($t0)
        addiu   $v1, $t0, 1
        move    $v0, $a0
        jr      $ra

next_token_end:
        move    $v0, $a0
        move    $v1, $zero
        jr      $ra

next_token_none:
        move    $v0, $zero
        move    $v1, $zero
        jr      $ra

ascii_to_int:
        move    $t0, $a0
        li      $v0, 0
        lb      $t1, 0($t0)
        beq     $t1, $zero, ascii_to_int_fail

ascii_to_int_loop:
        lb      $t1, 0($t0)
        beq     $t1, $zero, ascii_to_int_ok
        li      $t2, 48
        slt     $t3, $t1, $t2
        bne     $t3, $zero, ascii_to_int_fail
        li      $t2, 57
        slt     $t3, $t2, $t1
        bne     $t3, $zero, ascii_to_int_fail

        addiu   $t1, $t1, -48
        li      $t2, 10
        mul     $v0, $v0, $t2
        addu    $v0, $v0, $t1
        addiu   $t0, $t0, 1
        j       ascii_to_int_loop

ascii_to_int_ok:
        jr      $ra

ascii_to_int_fail:
        li      $v0, -1
        jr      $ra

copy_limited:
        addiu   $sp, $sp, -8
        sw      $ra, 4($sp)
        sw      $s0, 0($sp)

        move    $s0, $a2
        beq     $s0, $zero, copy_limited_end
        addiu   $s0, $s0, -1

copy_limited_loop:
        beq     $s0, $zero, copy_limited_done
        lb      $t0, 0($a1)
        beq     $t0, $zero, copy_limited_done
        sb      $t0, 0($a0)
        addiu   $a0, $a0, 1
        addiu   $a1, $a1, 1
        addiu   $s0, $s0, -1
        j       copy_limited_loop

copy_limited_done:
        sb      $zero, 0($a0)

copy_limited_end:
        lw      $ra, 4($sp)
        lw      $s0, 0($sp)
        addiu   $sp, $sp, 8
        jr      $ra

cardapio_ad_cmd:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        sw      $s1, 4($sp)
        sw      $s2, 0($sp)

        move    $s0, $a0
        beq     $s0, $zero, cardapio_ad_invalid

        move    $a0, $s0
        jal     next_token
        move    $s1, $v1
        beq     $v0, $zero, cardapio_ad_invalid

        move    $a0, $v0
        jal     ascii_to_int
        bltz    $v0, cardapio_ad_code_invalid
        move    $s2, $v0

        slti    $t1, $s2, 1
        bne     $t1, $zero, cardapio_ad_code_invalid
        slti    $t1, $s2, 21
        beq     $t1, $zero, cardapio_ad_code_invalid

        move    $a0, $s1
        jal     next_token
        move    $s1, $v1
        beq     $v0, $zero, cardapio_ad_invalid
        beq     $s1, $zero, cardapio_ad_invalid

        move    $a0, $v0
        jal     ascii_to_int
        bltz    $v0, cardapio_ad_invalid
        move    $t2, $v0

        addiu   $t0, $s2, -1
        li      $t1, 108
        mul     $t0, $t0, $t1
        la      $t1, cardapio_base
        addu    $t1, $t1, $t0

        lw      $t3, 0($t1)
        bne     $t3, $zero, cardapio_ad_exists

        sw      $s2, 0($t1)
        sw      $t2, 4($t1)
        addiu   $a0, $t1, 8
        move    $a1, $s1
        li      $a2, 100
        jal     copy_limited

        la      $a0, cardapio_add_ok_str
        jal     mmio_print_string
        j       cardapio_ad_end

cardapio_ad_exists:
        la      $a0, cardapio_add_exists
        jal     mmio_print_string
        j       cardapio_ad_end

cardapio_ad_code_invalid:
        la      $a0, cardapio_code_inv
        jal     mmio_print_string
        j       cardapio_ad_end

cardapio_ad_invalid:
        la      $a0, invalid_cmd_str
        jal     mmio_print_string

cardapio_ad_end:
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        lw      $s1, 4($sp)
        lw      $s2, 0($sp)
        addiu   $sp, $sp, 16
        jr      $ra

cardapio_rm_cmd:
        addiu   $sp, $sp, -12
        sw      $ra, 8($sp)
        sw      $s0, 4($sp)
        sw      $s1, 0($sp)

        move    $s0, $a0
        beq     $s0, $zero, cardapio_rm_invalid

        move    $a0, $s0
        jal     next_token
        beq     $v0, $zero, cardapio_rm_invalid

        move    $a0, $v0
        jal     ascii_to_int
        bltz    $v0, cardapio_rm_code_invalid
        move    $s1, $v0

        slti    $t1, $s1, 1
        bne     $t1, $zero, cardapio_rm_code_invalid
        slti    $t1, $s1, 21
        beq     $t1, $zero, cardapio_rm_code_invalid

        addiu   $t0, $s1, -1
        li      $t1, 108
        mul     $t0, $t0, $t1
        la      $t1, cardapio_base
        addu    $t1, $t1, $t0

        lw      $t2, 0($t1)
        beq     $t2, $zero, cardapio_rm_missing

        move    $a0, $t1
        li      $a1, 108
        jal     memset_zero

        la      $a0, cardapio_rm_ok_str
        jal     mmio_print_string
        j       cardapio_rm_end

cardapio_rm_missing:
        la      $a0, cardapio_rm_miss
        jal     mmio_print_string
        j       cardapio_rm_end

cardapio_rm_code_invalid:
        la      $a0, cardapio_code_inv
        jal     mmio_print_string
        j       cardapio_rm_end

cardapio_rm_invalid:
        la      $a0, invalid_cmd_str
        jal     mmio_print_string

cardapio_rm_end:
        lw      $ra, 8($sp)
        lw      $s0, 4($sp)
        lw      $s1, 0($sp)
        addiu   $sp, $sp, 12
        jr      $ra

cardapio_list_cmd:
        addiu   $sp, $sp, -12
        sw      $ra, 8($sp)
        sw      $s0, 4($sp)
        sw      $s1, 0($sp)

        li      $s0, 0
        la      $s1, cardapio_base

cardapio_list_loop:
        li      $t3, 20
        beq     $s0, $t3, cardapio_list_end
        lw      $t0, 0($s1)
        beq     $t0, $zero, cardapio_list_next

        move    $a0, $t0
        jal     mmio_print_int
        li      $a0, 32
        jal     mmio_write_char

        lw      $t1, 4($s1)
        move    $a0, $t1
        jal     mmio_print_money
        li      $a0, 32
        jal     mmio_write_char

        addiu   $a0, $s1, 8
        jal     mmio_print_string
        li      $a0, 10
        jal     mmio_write_char

cardapio_list_next:
        addiu   $s0, $s0, 1
        addiu   $s1, $s1, 108
        j       cardapio_list_loop

cardapio_list_end:
        lw      $ra, 8($sp)
        lw      $s0, 4($sp)
        lw      $s1, 0($sp)
        addiu   $sp, $sp, 12
        jr      $ra

cardapio_ptr_from_code:
        slti    $t1, $a0, 1
        bne     $t1, $zero, cardapio_ptr_invalid
        slti    $t1, $a0, 21
        beq     $t1, $zero, cardapio_ptr_invalid

        addiu   $t0, $a0, -1
        li      $t1, 108
        mul     $t0, $t0, $t1
        la      $v0, cardapio_base
        addu    $v0, $v0, $t0
        jr      $ra

cardapio_ptr_invalid:
        move    $v0, $zero
        jr      $ra

mesa_ptr_from_code:
        slti    $t1, $a0, 1
        bne     $t1, $zero, mesa_ptr_invalid
        slti    $t1, $a0, 16
        beq     $t1, $zero, mesa_ptr_invalid

        addiu   $t0, $a0, -1
        li      $t1, 224
        mul     $t0, $t0, $t1
        la      $v0, mesas_base
        addu    $v0, $v0, $t0
        jr      $ra

mesa_ptr_invalid:
        move    $v0, $zero
        jr      $ra

mesa_iniciar_cmd:
        addiu   $sp, $sp, -20
        sw      $ra, 16($sp)
        sw      $s0, 12($sp)
        sw      $s1, 8($sp)
        sw      $s2, 4($sp)
        sw      $s3, 0($sp)

        move    $s0, $a0
        beq     $s0, $zero, mesa_iniciar_invalid

        move    $a0, $s0
        jal     next_token
        move    $s1, $v1
        beq     $v0, $zero, mesa_iniciar_invalid

        move    $a0, $v0
        jal     ascii_to_int
        bltz    $v0, mesa_iniciar_inexist
        move    $s2, $v0

        move    $a0, $s1
        jal     next_token
        move    $s3, $v1
        beq     $v0, $zero, mesa_iniciar_invalid
        beq     $s3, $zero, mesa_iniciar_invalid
        move    $s1, $v0

        move    $a0, $s2
        jal     mesa_ptr_from_code
        beq     $v0, $zero, mesa_iniciar_inexist
        move    $s0, $v0

        lb      $t1, 4($s0)
        bne     $t1, $zero, mesa_iniciar_ocupada

        move    $a0, $s0
        li      $a1, 224
        jal     memset_zero

        sw      $s2, 0($s0)
        li      $t1, 1
        sb      $t1, 4($s0)

        addiu   $a0, $s0, 28
        move    $a1, $s1
        li      $a2, 12
        jal     copy_limited

        addiu   $a0, $s0, 8
        move    $a1, $s3
        li      $a2, 20
        jal     copy_limited

        la      $a0, mesa_init_ok_str
        jal     mmio_print_string
        j       mesa_iniciar_end

mesa_iniciar_ocupada:
        la      $a0, mesa_ocupada_str
        jal     mmio_print_string
        j       mesa_iniciar_end

mesa_iniciar_inexist:
        la      $a0, mesa_inexist_str
        jal     mmio_print_string
        j       mesa_iniciar_end

mesa_iniciar_invalid:
        la      $a0, invalid_cmd_str
        jal     mmio_print_string

mesa_iniciar_end:
        lw      $ra, 16($sp)
        lw      $s0, 12($sp)
        lw      $s1, 8($sp)
        lw      $s2, 4($sp)
        lw      $s3, 0($sp)
        addiu   $sp, $sp, 20
        jr      $ra

mesa_ad_item_cmd:
        addiu   $sp, $sp, -24
        sw      $ra, 20($sp)
        sw      $s0, 16($sp)
        sw      $s1, 12($sp)
        sw      $s2, 8($sp)
        sw      $s3, 4($sp)
        sw      $s4, 0($sp)

        move    $s0, $a0
        beq     $s0, $zero, mesa_ad_invalid

        move    $a0, $s0
        jal     next_token
        move    $s1, $v1
        beq     $v0, $zero, mesa_ad_invalid

        move    $a0, $v0
        jal     ascii_to_int
        bltz    $v0, mesa_ad_inexist
        move    $s2, $v0

        move    $a0, $s1
        jal     next_token
        beq     $v0, $zero, mesa_ad_invalid
        move    $a0, $v0
        jal     ascii_to_int
        bltz    $v0, mesa_ad_item_invalid
        move    $s3, $v0

        slti    $t1, $s3, 1
        bne     $t1, $zero, mesa_ad_item_invalid
        slti    $t1, $s3, 21
        beq     $t1, $zero, mesa_ad_item_invalid

        move    $a0, $s2
        jal     mesa_ptr_from_code
        beq     $v0, $zero, mesa_ad_inexist
        move    $s4, $v0

        lb      $t0, 4($s4)
        beq     $t0, $zero, mesa_ad_nao_ini

        move    $a0, $s3
        jal     cardapio_ptr_from_code
        beq     $v0, $zero, mesa_ad_item_invalid
        move    $t1, $v0

        lw      $t2, 0($t1)
        beq     $t2, $zero, mesa_ad_item_nao
        lw      $t3, 4($t1)

        addiu   $t4, $s4, 40
        li      $t5, 0

mesa_ad_loop:
        li      $t6, 20
        beq     $t5, $t6, mesa_ad_invalid
        lw      $t7, 0($t4)
        beq     $t7, $s3, mesa_ad_found
        beq     $t7, $zero, mesa_ad_empty
        addiu   $t4, $t4, 8
        addiu   $t5, $t5, 1
        j       mesa_ad_loop

mesa_ad_found:
        lw      $t8, 4($t4)
        addiu   $t8, $t8, 1
        sw      $t8, 4($t4)
        j       mesa_ad_update

mesa_ad_empty:
        sw      $s3, 0($t4)
        li      $t8, 1
        sw      $t8, 4($t4)

mesa_ad_update:
        lw      $t9, 204($s4)
        addu    $t9, $t9, $t3
        sw      $t9, 204($s4)

        la      $a0, cardapio_add_ok_str
        jal     mmio_print_string
        j       mesa_ad_end

mesa_ad_item_nao:
        la      $a0, mesa_item_nao_str
        jal     mmio_print_string
        j       mesa_ad_end

mesa_ad_item_invalid:
        la      $a0, mesa_item_inv_str
        jal     mmio_print_string
        j       mesa_ad_end

mesa_ad_nao_ini:
        la      $a0, mesa_nao_ini_str
        jal     mmio_print_string
        j       mesa_ad_end

mesa_ad_inexist:
        la      $a0, mesa_inexist_str
        jal     mmio_print_string
        j       mesa_ad_end

mesa_ad_invalid:
        la      $a0, invalid_cmd_str
        jal     mmio_print_string

mesa_ad_end:
        lw      $ra, 20($sp)
        lw      $s0, 16($sp)
        lw      $s1, 12($sp)
        lw      $s2, 8($sp)
        lw      $s3, 4($sp)
        lw      $s4, 0($sp)
        addiu   $sp, $sp, 24
        jr      $ra

mesa_rm_item_cmd:
        addiu   $sp, $sp, -24
        sw      $ra, 20($sp)
        sw      $s0, 16($sp)
        sw      $s1, 12($sp)
        sw      $s2, 8($sp)
        sw      $s3, 4($sp)
        sw      $s4, 0($sp)

        move    $s0, $a0
        beq     $s0, $zero, mesa_rm_invalid

        move    $a0, $s0
        jal     next_token
        move    $s1, $v1
        beq     $v0, $zero, mesa_rm_invalid

        move    $a0, $v0
        jal     ascii_to_int
        bltz    $v0, mesa_rm_inexist
        move    $s2, $v0

        move    $a0, $s1
        jal     next_token
        beq     $v0, $zero, mesa_rm_invalid
        move    $a0, $v0
        jal     ascii_to_int
        bltz    $v0, mesa_rm_item_invalid
        move    $s3, $v0

        slti    $t1, $s3, 1
        bne     $t1, $zero, mesa_rm_item_invalid
        slti    $t1, $s3, 21
        beq     $t1, $zero, mesa_rm_item_invalid

        move    $a0, $s2
        jal     mesa_ptr_from_code
        beq     $v0, $zero, mesa_rm_inexist
        move    $s4, $v0

        lb      $t0, 4($s4)
        beq     $t0, $zero, mesa_rm_nao_ini

        move    $a0, $s3
        jal     cardapio_ptr_from_code
        move    $t1, $v0
        beq     $t1, $zero, mesa_rm_item_invalid
        lw      $t2, 4($t1)

        addiu   $t3, $s4, 40
        li      $t4, 0

mesa_rm_loop:
        li      $t5, 20
        beq     $t4, $t5, mesa_rm_item_nao
        lw      $t6, 0($t3)
        beq     $t6, $s3, mesa_rm_found
        addiu   $t3, $t3, 8
        addiu   $t4, $t4, 1
        j       mesa_rm_loop

mesa_rm_found:
        lw      $t7, 4($t3)
        addiu   $t7, $t7, -1
        bgtz    $t7, mesa_rm_dec
        sw      $zero, 0($t3)
        sw      $zero, 4($t3)
        j       mesa_rm_update

mesa_rm_dec:
        sw      $t7, 4($t3)

mesa_rm_update:
        lw      $t8, 204($s4)
        slt     $t9, $t8, $t2
        bne     $t9, $zero, mesa_rm_zero
        subu    $t8, $t8, $t2
        sw      $t8, 204($s4)
        j       mesa_rm_ok

mesa_rm_zero:
        sw      $zero, 204($s4)

mesa_rm_ok:
        la      $a0, cardapio_rm_ok_str
        jal     mmio_print_string
        j       mesa_rm_end

mesa_rm_item_nao:
        la      $a0, mesa_item_rm_str
        jal     mmio_print_string
        j       mesa_rm_end

mesa_rm_item_invalid:
        la      $a0, mesa_item_inv_str
        jal     mmio_print_string
        j       mesa_rm_end

mesa_rm_nao_ini:
        la      $a0, mesa_nao_ini_str
        jal     mmio_print_string
        j       mesa_rm_end

mesa_rm_inexist:
        la      $a0, mesa_inexist_str
        jal     mmio_print_string
        j       mesa_rm_end

mesa_rm_invalid:
        la      $a0, invalid_cmd_str
        jal     mmio_print_string

mesa_rm_end:
        lw      $ra, 20($sp)
        lw      $s0, 16($sp)
        lw      $s1, 12($sp)
        lw      $s2, 8($sp)
        lw      $s3, 4($sp)
        lw      $s4, 0($sp)
        addiu   $sp, $sp, 24
        jr      $ra

mesa_parcial_cmd:
        addiu   $sp, $sp, -20
        sw      $ra, 16($sp)
        sw      $s0, 12($sp)
        sw      $s1, 8($sp)
        sw      $s2, 4($sp)
        sw      $s3, 0($sp)

        move    $s0, $a0
        beq     $s0, $zero, mesa_parcial_invalid

        move    $a0, $s0
        jal     next_token
        beq     $v0, $zero, mesa_parcial_invalid

        move    $a0, $v0
        jal     ascii_to_int
        bltz    $v0, mesa_parcial_inexist
        move    $s1, $v0

        move    $a0, $s1
        jal     mesa_ptr_from_code
        beq     $v0, $zero, mesa_parcial_inexist
        move    $s2, $v0

        lb      $t0, 4($s2)
        beq     $t0, $zero, mesa_parcial_nao_ini

        addiu   $s3, $s2, 40
        li      $t1, 0

mesa_parcial_loop:
        li      $t2, 20
        beq     $t1, $t2, mesa_parcial_totais
        lw      $t3, 0($s3)
        beq     $t3, $zero, mesa_parcial_next

        # Exibe ID do Item
        move    $a0, $t3
        jal     mmio_print_int
        
        # Espaço
        li      $a0, 32
        jal     mmio_write_char

        # Exibe Quantidade
        lw      $t4, 4($s3)
        move    $a0, $t4
        jal     mmio_print_int
        
        # Quebra de linha
        li      $a0, 10
        jal     mmio_write_char

mesa_parcial_next:
        addiu   $s3, $s3, 8
        addiu   $t1, $t1, 1
        j       mesa_parcial_loop

mesa_parcial_totais:
        lw      $t6, 200($s2)
        lw      $t8, 204($s2)
        addu    $t5, $t6, $t8

mesa_parcial_print:
        move    $a0, $t5
        jal     mmio_print_money
        li      $a0, 10
        jal     mmio_write_char
        move    $a0, $t6
        jal     mmio_print_money
        li      $a0, 10
        jal     mmio_write_char
        move    $a0, $t8
        jal     mmio_print_money
        li      $a0, 10
        jal     mmio_write_char
        j       mesa_parcial_end

mesa_parcial_nao_ini:
        la      $a0, mesa_nao_ini_str
        jal     mmio_print_string
        j       mesa_parcial_end

mesa_parcial_inexist:
        la      $a0, mesa_inexist_str
        jal     mmio_print_string
        j       mesa_parcial_end

mesa_parcial_invalid:
        la      $a0, invalid_cmd_str
        jal     mmio_print_string

mesa_parcial_end:
        lw      $ra, 16($sp)
        lw      $s0, 12($sp)
        lw      $s1, 8($sp)
        lw      $s2, 4($sp)
        lw      $s3, 0($sp)
        addiu   $sp, $sp, 20
        jr      $ra

mesa_pagar_cmd:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        sw      $s1, 4($sp)
        sw      $s2, 0($sp)

        move    $s0, $a0
        beq     $s0, $zero, mesa_pagar_invalid

        move    $a0, $s0
        jal     next_token
        move    $s1, $v1
        beq     $v0, $zero, mesa_pagar_invalid

        move    $a0, $v0
        jal     ascii_to_int
        bltz    $v0, mesa_pagar_inexist
        move    $s2, $v0

        move    $a0, $s1
        jal     next_token
        beq     $v0, $zero, mesa_pagar_invalid
        move    $a0, $v0
        jal     ascii_to_int
        bltz    $v0, mesa_pagar_invalid
        move    $t0, $v0

        move    $a0, $s2
        jal     mesa_ptr_from_code
        beq     $v0, $zero, mesa_pagar_inexist
        move    $t1, $v0

        lb      $t2, 4($t1)
        beq     $t2, $zero, mesa_pagar_nao_ini

        lw      $t3, 200($t1)
        addu    $t3, $t3, $t0
        sw      $t3, 200($t1)

        la      $a0, mesa_pago_ok_str
        jal     mmio_print_string
        j       mesa_pagar_end

mesa_pagar_nao_ini:
        la      $a0, mesa_nao_ini_str
        jal     mmio_print_string
        j       mesa_pagar_end

mesa_pagar_inexist:
        la      $a0, mesa_inexist_str
        jal     mmio_print_string
        j       mesa_pagar_end

mesa_pagar_invalid:
        la      $a0, invalid_cmd_str
        jal     mmio_print_string

mesa_pagar_end:
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        lw      $s1, 4($sp)
        lw      $s2, 0($sp)
        addiu   $sp, $sp, 16
        jr      $ra

mesa_fechar_cmd:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        sw      $s1, 4($sp)
        sw      $s2, 0($sp)

        move    $s0, $a0
        beq     $s0, $zero, mesa_fechar_invalid

        move    $a0, $s0
        jal     next_token
        beq     $v0, $zero, mesa_fechar_invalid

        move    $a0, $v0
        jal     ascii_to_int
        bltz    $v0, mesa_fechar_inexist
        move    $s1, $v0

        move    $a0, $s1
        jal     mesa_ptr_from_code
        beq     $v0, $zero, mesa_fechar_inexist
        move    $s2, $v0

        lb      $t0, 4($s2)
        beq     $t0, $zero, mesa_fechar_nao_ini

        lw      $t1, 204($s2)
        beq     $t1, $zero, mesa_fechar_ok
        move    $t4, $t1

        la      $a0, mesa_saldo_pref
        jal     mmio_print_string
        move    $a0, $t4
        jal     mmio_print_money
        li      $a0, 10
        jal     mmio_write_char
        j       mesa_fechar_end

mesa_fechar_ok:
        move    $a0, $s2
        li      $a1, 224
        jal     memset_zero
        la      $a0, mesa_fecha_ok_str
        jal     mmio_print_string
        j       mesa_fechar_end

mesa_fechar_nao_ini:
        la      $a0, mesa_nao_ini_str
        jal     mmio_print_string
        j       mesa_fechar_end

mesa_fechar_inexist:
        la      $a0, mesa_inexist_str
        jal     mmio_print_string
        j       mesa_fechar_end

mesa_fechar_invalid:
        la      $a0, invalid_cmd_str
        jal     mmio_print_string

mesa_fechar_end:
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        lw      $s1, 4($sp)
        lw      $s2, 0($sp)
        addiu   $sp, $sp, 16
        jr      $ra

formatar:
        addiu   $sp, $sp, -8
        sw      $ra, 4($sp)

        la      $a0, cardapio_base
        li      $a1, 2160
        jal     memset_zero

        la      $a0, mesas_base
        li      $a1, 3360
        jal     memset_zero

        lw      $ra, 4($sp)
        addiu   $sp, $sp, 8
        jr      $ra

cardapio_format:
        addiu   $sp, $sp, -8
        sw      $ra, 4($sp)

        la      $a0, cardapio_base
        li      $a1, 2160
        jal     memset_zero

        lw      $ra, 4($sp)
        addiu   $sp, $sp, 8
        jr      $ra

mesa_format:
        addiu   $sp, $sp, -8
        sw      $ra, 4($sp)

        la      $a0, mesas_base
        li      $a1, 3360
        jal     memset_zero

        lw      $ra, 4($sp)
        addiu   $sp, $sp, 8
        jr      $ra

save_data:
        addiu   $sp, $sp, -8
        sw      $ra, 4($sp)

        la      $a0, save_file_name
        li      $a1, 1
        li      $a2, 0
        li      $v0, 13
        syscall
        bltz    $v0, save_data_fail

        move    $t0, $v0

        move    $a0, $t0
        la      $a1, cardapio_base
        li      $a2, 2160
        li      $v0, 15
        syscall

        move    $a0, $t0
        la      $a1, mesas_base
        li      $a2, 3360
        li      $v0, 15
        syscall

        move    $a0, $t0
        li      $v0, 16
        syscall

        li      $v0, 0
        j       save_data_end

save_data_fail:
        li      $v0, -1

save_data_end:
        lw      $ra, 4($sp)
        addiu   $sp, $sp, 8
        jr      $ra

load_data_silent:
        addiu   $sp, $sp, -8
        sw      $ra, 4($sp)

        la      $a0, save_file_name
        li      $a1, 0
        li      $a2, 0
        li      $v0, 13
        syscall
        bltz    $v0, load_data_fail

        move    $t0, $v0

        move    $a0, $t0
        la      $a1, cardapio_base
        li      $a2, 2160
        li      $v0, 14
        syscall

        move    $a0, $t0
        la      $a1, mesas_base
        li      $a2, 3360
        li      $v0, 14
        syscall

        move    $a0, $t0
        li      $v0, 16
        syscall

        li      $v0, 0
        j       load_data_end

load_data_fail:
        li      $v0, -1

load_data_end:
        lw      $ra, 4($sp)
        addiu   $sp, $sp, 8
        jr      $ra

memset_zero:
        beq     $a1, $zero, memset_zero_end
        sb      $zero, 0($a0)
        addiu   $a0, $a0, 1
        addiu   $a1, $a1, -1
        j       memset_zero

memset_zero_end:
        jr      $ra

mmio_write_char:
        li      $t0, MMIO_TX_CTRL
mmio_write_wait:
        lw      $t1, 0($t0)
        beq     $t1, $zero, mmio_write_wait
        sw      $a0, 4($t0)
        jr      $ra

mmio_print_string:
        addiu   $sp, $sp, -8
        sw      $ra, 4($sp)
        sw      $s0, 0($sp)

        move    $s0, $a0

mmio_print_loop:
        lb      $t0, 0($s0)
        beq     $t0, $zero, mmio_print_end
        move    $a0, $t0
        jal     mmio_write_char
        addiu   $s0, $s0, 1
        j       mmio_print_loop

mmio_print_end:
        lw      $ra, 4($sp)
        lw      $s0, 0($sp)
        addiu   $sp, $sp, 8
        jr      $ra

mmio_print_int:
        addiu   $sp, $sp, -40
        sw      $ra, 36($sp)
        sw      $s0, 32($sp)
        sw      $s1, 28($sp)
        sw      $s2, 24($sp)

        move    $s0, $a0
        bne     $s0, $zero, mmio_print_int_loop
        li      $a0, 48
        jal     mmio_write_char
        j       mmio_print_int_end

mmio_print_int_loop:
        addiu   $s1, $sp, 0
        li      $s2, 0

mmio_print_div:
        li      $t0, 10
        divu    $s0, $t0
        mfhi    $t1
        mflo    $s0
        addiu   $t1, $t1, 48
        sb      $t1, 0($s1)
        addiu   $s1, $s1, 1
        addiu   $s2, $s2, 1
        bnez    $s0, mmio_print_div

        addiu   $s1, $s1, -1

mmio_print_rev:
        lb      $t2, 0($s1)
        move    $a0, $t2
        jal     mmio_write_char
        addiu   $s1, $s1, -1
        addiu   $s2, $s2, -1
        bgtz    $s2, mmio_print_rev

mmio_print_int_end:
        lw      $ra, 36($sp)
        lw      $s0, 32($sp)
        lw      $s1, 28($sp)
        lw      $s2, 24($sp)
        addiu   $sp, $sp, 40
        jr      $ra

mmio_print_money:
        addiu   $sp, $sp, -12
        sw      $ra, 8($sp)
        sw      $s0, 4($sp)
        sw      $s1, 0($sp)

        move    $s0, $a0
        la      $a0, real_prefix
        jal     mmio_print_string

        li      $t0, 100
        divu    $s0, $t0
        mflo    $s1
        mfhi    $t1

        move    $a0, $s1
        jal     mmio_print_int
        li      $a0, 44
        jal     mmio_write_char

        li      $t2, 10
        divu    $t1, $t2
        mflo    $t3 # dezena dos centavos
        mfhi    $t4 # unidade dos centavos
        addiu   $t3, $t3, 48
        move    $a0, $t3
        jal     mmio_write_char
        addiu   $t4, $t4, 48
        move    $a0, $t4
        jal     mmio_write_char

mmio_print_money_end:
        lw      $ra, 8($sp)
        lw      $s0, 4($sp)
        lw      $s1, 0($sp)
        addiu   $sp, $sp, 12
        jr      $ra

mmio_read_line:
        addiu   $sp, $sp, -16
        sw      $ra, 12($sp)
        sw      $s0, 8($sp)
        sw      $s1, 4($sp)
        sw      $s2, 0($sp)

        move    $s0, $a0
        move    $s2, $a0
        addiu   $s1, $a1, -1
        bltz    $s1, mmio_read_line_end

        li      $t2, MMIO_RCV_CTRL

mmio_read_loop:
        lw      $t0, 0($t2)
        beq     $t0, $zero, mmio_read_loop
        lw      $t0, 4($t2)

        li      $t1, 10
        beq     $t0, $t1, mmio_read_done
        li      $t1, 13
        beq     $t0, $t1, mmio_read_done

        beq     $s1, $zero, mmio_read_done

        sb      $t0, 0($s0)
        move    $a0, $t0
        jal     mmio_write_char

        addiu   $s0, $s0, 1
        addiu   $s1, $s1, -1
        j       mmio_read_loop

mmio_read_done:
        sb      $zero, 0($s0)
        li      $a0, 10
        jal     mmio_write_char
        subu    $v0, $s0, $s2

mmio_read_line_end:
        lw      $ra, 12($sp)
        lw      $s0, 8($sp)
        lw      $s1, 4($sp)
        lw      $s2, 0($sp)
        addiu   $sp, $sp, 16
        jr      $ra
