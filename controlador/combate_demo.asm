# Ciclo de ataque por turnos y resolucion de disparos

.text
.globl ejecutar_demo_ataque
.globl procesar_disparo_simple
.globl verificar_hundimiento
.globl marcar_hundido

# ejecutar_demo_ataque()
ejecutar_demo_ataque:
    addi $sp, $sp, -16
    sw   $ra, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    li   $v0, 4
    la   $a0, msg_fase_atk
    syscall

    li   $s0, 1
    li   $s1, 1

eda_bucle:
    la   $a0, tablero_enemigo
    la   $a1, tablero_ataque
    jal  intentar_comodin_radar
    move $s2, $v1

    move $a0, $s0
    move $a1, $s1
    la   $a2, tablero_ataque
    move $a3, $s2
    jal  mover_cursor_ataque
    move $s0, $v0
    move $s1, $v1

    move $a0, $s0
    move $a1, $s1
    la   $a2, tablero_enemigo
    la   $a3, tablero_ataque
    jal  intentar_comodin_area
    bnez $v0, eda_fin_turno

    move $a0, $s0
    move $a1, $s1
    la   $a2, tablero_enemigo
    la   $a3, tablero_ataque
    jal  procesar_disparo_simple

eda_fin_turno:
    la   $a0, tablero_ataque
    li   $a1, Y_ATK_MIN
    li   $a2, -1
    jal  dibujar_tablero_base

    la   $a0, tablero_enemigo
    jal  contar_barcos_restantes
    bgtz $v0, eda_bucle

    li   $v0, 4
    la   $a0, msg_victoria
    syscall

    li   $v0, 4
    la   $a0, msg_pausa_fin
    syscall
    jal  leer_tecla

    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $ra, 12($sp)
    addi $sp, $sp, 16
    jr   $ra


# procesar_disparo_simple($a0=X, $a1=Y, $a2=tablero_enemigo, $a3=tablero_ataque)
# Retorna: $v1 = 0 (fallo/duplicado/borde), 1 (impacto simple), 2 (impacto que hundio)
procesar_disparo_simple:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3

    li   $v1, 0                     # Por defecto: fallo

    # Validar bordes
    blez $s0, pds_borde_error
    li   $t0, 15
    bge  $s0, $t0, pds_borde_error
    blez $s1, pds_borde_error
    beq  $s1, $t0, pds_borde_error

    sll  $t0, $s1, 4
    add  $t0, $t0, $s0              # idx = (Y * 16) + X

    add  $t1, $s3, $t0
    lbu  $t2, 0($t1)
    bnez $t2, pds_duplicado

    add  $t3, $s2, $t0
    lbu  $t4, 0($t3)
    li   $t5, CELDA_BARCO
    beq  $t4, $t5, pds_impacto
    li   $t5, CELDA_HUNDIDO
    beq  $t4, $t5, pds_duplicado    # Ya estaba hundido, tratar como duplicado

    # Fallo (Agua)
    li   $t5, CELDA_FALLO
    sb   $t5, 0($t1)
    sb   $t5, 0($t3)
    move $a0, $s0
    move $a1, $s1
    li   $a2, COLOR_FALLO
    jal  dibujar_celda

    li   $v0, 4
    la   $a0, msg_tiro_miss
    syscall
    li   $v1, 0
    j    pds_coord

pds_impacto:
    li   $t5, CELDA_IMPACTO
    sb   $t5, 0($t1)
    sb   $t5, 0($t3)
    move $a0, $s0
    move $a1, $s1
    li   $a2, COLOR_IMPACTO
    jal  dibujar_celda

    li   $v0, 4
    la   $a0, msg_tiro_hit
    syscall

    # Verificar Hundimiento
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal  verificar_hundimiento
    beqz $v0, pds_hit_simple

    # Hundido
    li   $v0, 4
    la   $a0, msg_hundido
    syscall
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    move $a3, $s3
    jal  marcar_hundido
    li   $v1, 2
    j    pds_coord

pds_hit_simple:
    li   $v1, 1

pds_coord:
    move $a0, $s0
    move $a1, $s1
    jal  imprimir_coordenadas
    li   $v0, 4
    la   $a0, msg_cierre_par
    syscall

pds_fin:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20
    jr   $ra

pds_borde_error:
    li   $v0, 4
    la   $a0, msg_err_borde
    syscall
    li   $v1, 0
    j    pds_fin

pds_duplicado:
    li   $v0, 4
    la   $a0, msg_tiro_dup
    syscall
    li   $v1, 0
    j    pds_fin


# verificar_hundimiento($a0=X, $a1=Y, $a2=tablero_enemigo) -> $v0 = 1 si hundido, 0 si no
verificar_hundimiento:
    # Busca a la IZQUIERDA
    move $t0, $a0
vh_loop_left:
    addi $t0, $t0, -1               
    bltz $t0, vh_check_right
    sll $t1, $a1, 4
    add $t1, $t1, $t0
    add $t2, $a2, $t1
    lbu $t3, 0($t2)
    li $t4, CELDA_BARCO
    beq $t3, $t4, vh_no_hundido
    li $t4, CELDA_IMPACTO
    beq $t3, $t4, vh_loop_left
    j vh_check_right

    # Busca a la DERECHA
vh_check_right:
    move $t0, $a0
vh_loop_right:
    addi $t0, $t0, 1
    li $t1, 15
    bgt $t0, $t1, vh_check_up
    sll $t1, $a1, 4
    add $t1, $t1, $t0
    add $t2, $a2, $t1
    lbu $t3, 0($t2)
    li $t4, CELDA_BARCO
    beq $t3, $t4, vh_no_hundido
    li $t4, CELDA_IMPACTO
    beq $t3, $t4, vh_loop_right
    j vh_check_up

    # Busca ARRIBA
vh_check_up:
    move $t0, $a1
vh_loop_up:
    addi $t0, $t0, -1               
    bltz $t0, vh_check_down
    sll $t1, $t0, 4
    add $t1, $t1, $a0
    add $t2, $a2, $t1
    lbu $t3, 0($t2)
    li $t4, CELDA_BARCO
    beq $t3, $t4, vh_no_hundido
    li $t4, CELDA_IMPACTO
    beq $t3, $t4, vh_loop_up
    j vh_check_down

    # Busca ABAJO
vh_check_down:
    move $t0, $a1
vh_loop_down:
    addi $t0, $t0, 1
    li $t1, 15
    bgt $t0, $t1, vh_si_hundido
    sll $t1, $t0, 4
    add $t1, $t1, $a0
    add $t2, $a2, $t1
    lbu $t3, 0($t2)
    li $t4, CELDA_BARCO
    beq $t3, $t4, vh_no_hundido
    li $t4, CELDA_IMPACTO
    beq $t3, $t4, vh_loop_down
    j vh_si_hundido

vh_si_hundido:
    li $v0, 1
    jr $ra
vh_no_hundido:
    li $v0, 0
    jr $ra


# marcar_hundido($a0=X, $a1=Y, $a2=tablero_enemigo, $a3=tablero_ataque)
marcar_hundido:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3

    bltz $s0, mh_fin
    li   $t0, 15
    bgt  $s0, $t0, mh_fin
    bltz $s1, mh_fin
    bgt  $s1, $t0, mh_fin

    sll  $t1, $s1, 4
    add  $t1, $t1, $s0
    add  $t2, $s2, $t1
    lbu  $t3, 0($t2)
    
    li   $t4, CELDA_IMPACTO
    bne  $t3, $t4, mh_fin

    li   $t4, CELDA_HUNDIDO
    sb   $t4, 0($t2)
    add  $t5, $s3, $t1
    sb   $t4, 0($t5)

    move $a0, $s0
    move $a1, $s1
    li   $a2, COLOR_HUNDIDO
    jal  dibujar_celda

    move $a0, $s0
    addi $a1, $s1, -1
    move $a2, $s2
    move $a3, $s3
    jal  marcar_hundido

    move $a0, $s0
    addi $a1, $s1, 1
    move $a2, $s2
    move $a3, $s3
    jal  marcar_hundido

    addi $a0, $s0, -1
    move $a1, $s1
    move $a2, $s2
    move $a3, $s3
    jal  marcar_hundido

    addi $a0, $s0, 1
    move $a1, $s1
    move $a2, $s2
    move $a3, $s3
    jal  marcar_hundido

mh_fin:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20
    jr   $ra