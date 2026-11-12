# ==============================================================================
# MODELO (REGLAS DE NEGOCIO): validacion_flota.asm
# Descripcion:
#   Valida reglas de posicionamiento de barcos sobre la matriz logica
#   tablero_defensa sin depender de funciones graficas ni de consola.
# ==============================================================================

.text
.globl validar_posicion_barco

# ------------------------------------------------------------------------------
# SUBRUTINA: validar_posicion_barco (Hoja)
#   Verifica limites [0..15] x [16..31] segun orientacion y superposicion en
#   tablero_defensa (offset = (Y_local << 4) + X, donde Y_local = Y - 16).
# Argumentos:
#   $a0 = X inicial (0..15)
#   $a1 = Y inicial en pantalla (16..31)
#   $a2 = Longitud del barco (2..5)
#   $a3 = Orientacion (0 = Horizontal, 1 = Vertical)
# Retorno:
#   $v0 = 1 si es valida; 0 si es invalida
#   $v1 = Codigo: 0 = OK, 1 = Fuera de limites, 2 = Colision con otro barco
# ------------------------------------------------------------------------------
validar_posicion_barco:
    bltz $a0, vpb_err_limites       # X < 0
    li   $t0, 15
    bgt  $a0, $t0, vpb_err_limites  # X > 15
    li   $t0, Y_DEF_MIN             # 16
    blt  $a1, $t0, vpb_err_limites  # Y < 16
    li   $t0, Y_DEF_MAX             # 31
    bgt  $a1, $t0, vpb_err_limites  # Y > 31
    blez $a2, vpb_err_limites       # longitud <= 0

    beqz $a3, vpb_check_horiz       # 0 = Horizontal
    li   $t0, ORIENT_VERT           # 1 = Vertical
    beq  $a3, $t0, vpb_check_vert
    j    vpb_err_limites            # Orientacion invalida

vpb_check_horiz:
    add  $t0, $a0, $a2              # X + longitud
    li   $t1, 16
    bgt  $t0, $t1, vpb_err_limites  # Debe cumplir X + longitud <= 16
    j    vpb_check_colision

vpb_check_vert:
    add  $t0, $a1, $a2              # Y + longitud
    li   $t1, 32
    bgt  $t0, $t1, vpb_err_limites  # Debe cumplir Y + longitud <= 32

vpb_check_colision:
    la   $t0, tablero_defensa       # Base matriz byte 16x16
    addi $t1, $a1, -16              # Y_local = Y - 16 (0..15)
    move $t2, $a0                   # X actual
    li   $t3, 0                     # Segmento i = 0..L-1

vpb_loop_celdas:
    bge  $t3, $a2, vpb_valido

    sll  $t4, $t1, 4                # Y_local * 16
    add  $t4, $t4, $t2              # indice = (Y_local * 16) + X
    add  $t4, $t0, $t4              # direccion exacta en tablero_defensa
    lbu  $t5, 0($t4)                # leer estado (0=agua, 1=ocupada)
    bnez $t5, vpb_err_colision      # si != 0 -> colision

    beqz $a3, vpb_step_h
    addi $t1, $t1, 1                # Vertical: Y_local++
    j    vpb_next
vpb_step_h:
    addi $t2, $t2, 1                # Horizontal: X++
vpb_next:
    addi $t3, $t3, 1
    j    vpb_loop_celdas

vpb_valido:
    li   $v0, 1
    li   $v1, 0
    jr   $ra

vpb_err_limites:
    li   $v0, 0
    li   $v1, 1
    jr   $ra

vpb_err_colision:
    li   $v0, 0
    li   $v1, 2
    jr   $ra
