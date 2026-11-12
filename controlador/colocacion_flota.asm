# ==============================================================================
# CONTROLADOR (COLOCACION): colocacion_flota.asm
# Descripcion:
#   Orquesta el despliegue manual secuencial de los 4 barcos (5, 4, 3, 2) en
#   la zona de defensa (Y=16..31), conectando teclado/cursor (Controlador),
#   validacion de limites/colisiones (Modelo) y preview amarillo (Vista).
# ==============================================================================

.text
.globl colocar_flota_manual

# ------------------------------------------------------------------------------
# SUBRUTINA: colocar_flota_manual
# Argumentos: Ninguno (opera sobre tablero_defensa global).
# Retorno:    Ninguno. (Preserva $ra y $s0-$s6 en $sp).
# ------------------------------------------------------------------------------
colocar_flota_manual:
    addi $sp, $sp, -32
    sw   $ra, 28($sp)
    sw   $s6, 24($sp)
    sw   $s5, 20($sp)
    sw   $s4, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    la   $s0, tablero_defensa       # $s0 = base tablero_defensa
    move $a0, $s0
    jal  limpiar_matriz_256

    li   $v0, 4
    la   $a0, msg_fase_def
    syscall

    li   $s1, 0                     # $s1 = ship_idx (0..3)

cfm_loop_barcos:
    li   $t0, 4
    bge  $s1, $t0, cfm_flota_ok

    # Obtener longitud y nombre desde Modelo
    sll  $t0, $s1, 2
    la   $t1, longitudes_flota
    add  $t1, $t1, $t0
    lw   $s2, 0($t1)                # $s2 = longitud (5, 4, 3 o 2)

    la   $t1, nombres_flota
    add  $t1, $t1, $t0
    lw   $s6, 0($t1)                # $s6 = nombre del barco

    # Posicion inicial para el barco actual
    li   $s3, 0                     # $s3 = X (0..15)
    li   $s4, Y_DEF_MIN             # $s4 = Y (16..31)
    li   $s5, ORIENT_HORIZ          # $s5 = 0 Horizontal

cfm_loop_preview:
    # 1. Vista: redibujar tablero de defensa logico y superponer preview amarillo
    move $a0, $s0
    li   $a1, Y_DEF_MIN             # Offset Y = 16
    li   $a2, -1
    jal  dibujar_tablero_base

    move $a0, $s3
    move $a1, $s4
    move $a2, $s2
    move $a3, $s5
    jal  dibujar_preview_barco

    # 2. Vista: imprimir estado actual
    li   $v0, 4
    la   $a0, msg_colocando
    syscall
    li   $v0, 4
    move $a0, $s6
    syscall
    li   $v0, 4
    la   $a0, msg_pos
    syscall
    move $a0, $s3
    move $a1, $s4
    jal  imprimir_coordenadas
    beqz $s5, cfm_print_h
    li   $v0, 4
    la   $a0, msg_orient_v
    syscall
    j    cfm_leer
cfm_print_h:
    li   $v0, 4
    la   $a0, msg_orient_h
    syscall

cfm_leer:
    # 3. Controlador: leer tecla
    jal  leer_tecla

    li   $t0, TECLA_R
    beq  $v0, $t0, cfm_rotar
    li   $t0, TECLA_E
    beq  $v0, $t0, cfm_confirmar
    li   $t0, TECLA_ENTER
    beq  $v0, $t0, cfm_confirmar

    # Calcular limites dinamicos segun orientacion y longitud del barco
    beqz $s5, cfm_limites_h
    li   $t1, 15                    # Vertical: x_max = 15
    li   $t2, 32
    sub  $t2, $t2, $s2              # Vertical: y_max = 32 - longitud
    j    cfm_empaquetar_lim
cfm_limites_h:
    li   $t1, 16
    sub  $t1, $t1, $s2              # Horizontal: x_max = 16 - longitud
    li   $t2, Y_DEF_MAX             # Horizontal: y_max = 31

cfm_empaquetar_lim:
    sll  $a3, $t1, 16
    li   $t3, Y_DEF_MIN
    sll  $t3, $t3, 8
    or   $a3, $a3, $t3
    or   $a3, $a3, $t2

    move $a0, $s3
    move $a1, $s4
    move $a2, $v0
    jal  mover_cursor
    move $s3, $v0
    move $s4, $v1
    j    cfm_loop_preview

cfm_rotar:
    xori $s5, $s5, 1                # Alternar 0 <-> 1
    beqz $s5, cfm_clamp_rot_h
    li   $t0, 32
    sub  $t0, $t0, $s2              # Vertical: ajustar Y si Y > 32 - L
    ble  $s4, $t0, cfm_loop_preview
    move $s4, $t0
    j    cfm_loop_preview
cfm_clamp_rot_h:
    li   $t0, 16
    sub  $t0, $t0, $s2              # Horizontal: ajustar X si X > 16 - L
    ble  $s3, $t0, cfm_loop_preview
    move $s3, $t0
    j    cfm_loop_preview

cfm_confirmar:
    # 4. Modelo: validar posicion y colisiones
    move $a0, $s3
    move $a1, $s4
    move $a2, $s2
    move $a3, $s5
    jal  validar_posicion_barco
    bnez $v0, cfm_guardar_barco

    li   $t0, 1
    beq  $v1, $t0, cfm_msg_lim
    li   $v0, 4
    la   $a0, msg_err_colision
    syscall
    j    cfm_loop_preview
cfm_msg_lim:
    li   $v0, 4
    la   $a0, msg_err_limites
    syscall
    j    cfm_loop_preview

cfm_guardar_barco:
    # 5. Actualizar Modelo (tablero_defensa) con CELDA_BARCO (1)
    li   $t0, 0                     # i = 0
    move $t1, $s3                   # cx = X
    addi $t2, $s4, -16              # cy_local = Y - 16
cfm_write_loop:
    bge  $t0, $s2, cfm_barco_guardado

    sll  $t3, $t2, 4                # cy_local * 16
    add  $t3, $t3, $t1              # indice 0..255
    add  $t3, $s0, $t3              # direccion en tablero_defensa
    li   $t4, CELDA_BARCO
    sb   $t4, 0($t3)

    beqz $s5, cfm_w_h
    addi $t2, $t2, 1
    j    cfm_w_next
cfm_w_h:
    addi $t1, $t1, 1
cfm_w_next:
    addi $t0, $t0, 1
    j    cfm_write_loop

cfm_barco_guardado:
    li   $v0, 4
    la   $a0, msg_ok_barco
    syscall

    addi $s1, $s1, 1
    j    cfm_loop_barcos

cfm_flota_ok:
    # Redibujar defensa final en Gris (sin preview amarillo)
    move $a0, $s0
    li   $a1, Y_DEF_MIN
    li   $a2, -1
    jal  dibujar_tablero_base

    li   $v0, 4
    la   $a0, msg_flota_lista
    syscall

    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $s4, 16($sp)
    lw   $s5, 20($sp)
    lw   $s6, 24($sp)
    lw   $ra, 28($sp)
    addi $sp, $sp, 32
    jr   $ra
