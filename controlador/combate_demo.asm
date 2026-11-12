# Ciclo de ataque por turnos y resolucion de disparos

.text
.globl ejecutar_demo_ataque
.globl procesar_disparo_simple

# ejecutar_demo_ataque()
# Bucle principal de ataque hasta hundir toda la flota enemiga
# Preserva $ra y $s0-$s2 en la pila
ejecutar_demo_ataque:
    addi $sp, $sp, -16
    sw   $ra, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    li   $v0, 4
    la   $a0, msg_fase_atk
    syscall

    li   $s0, 0                     # Cursor X inicial
    li   $s1, 0                     # Cursor Y inicial

eda_bucle:
    la   $a0, tablero_enemigo
    la   $a1, tablero_ataque
    jal  intentar_comodin_radar
    move $s2, $v1                   # Guardar indice revelado (-1 si inactivo)

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
    li   $a2, -1                    # Ocultar pista temporal del radar al cerrar turno
    jal  dibujar_tablero_base

    la   $a0, tablero_enemigo
    jal  contar_barcos_restantes
    bgtz $v0, eda_bucle

    li   $v0, 4
    la   $a0, msg_victoria
    syscall

    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $ra, 12($sp)
    addi $sp, $sp, 16
    jr   $ra


# procesar_disparo_simple($a0=X, $a1=Y, $a2=tablero_enemigo, $a3=tablero_ataque)
# Ejecuta un disparo de una sola casilla y actualiza matriz y pantalla
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

    sll  $t0, $s1, 4
    add  $t0, $t0, $s0              # idx = (Y * 16) + X

    add  $t1, $s3, $t0
    lbu  $t2, 0($t1)
    bnez $t2, pds_duplicado

    add  $t3, $s2, $t0
    lbu  $t4, 0($t3)
    li   $t5, CELDA_BARCO
    beq  $t4, $t5, pds_impacto

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
    j    pds_coord

pds_duplicado:
    li   $v0, 4
    la   $a0, msg_tiro_dup
    syscall

pds_coord:
    move $a0, $s0
    move $a1, $s1
    jal  imprimir_coordenadas
    li   $v0, 4
    la   $a0, msg_cierre_par
    syscall

    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20
    jr   $ra
