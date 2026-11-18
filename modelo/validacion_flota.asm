# Validacion de limites y colisiones para colocacion de barcos
# Regla clasica de Battleship: los barcos NO pueden tocarse (ni siquiera en diagonal)

.text
.globl validar_posicion_barco

# validar_posicion_barco($a0=X, $a1=Y, $a2=longitud, $a3=orientacion, $t9=tablero_base)
# Retorna: $v0 = 1 (valido) / 0 (invalido)
#          $v1 = 0 (ok) / 1 (limites) / 2 (colision)
validar_posicion_barco:
    # Borde izquierdo y derecho (X=0 y X=15 son arena)
    blez $a0, vpb_err_limites
    li   $t0, 15
    bge  $a0, $t0, vpb_err_limites

    # Bordes superior e inferior (Y=16 y Y=31 son arena)
    li   $t0, Y_DEF_MIN
    ble  $a1, $t0, vpb_err_limites
    li   $t0, Y_DEF_MAX
    bge  $a1, $t0, vpb_err_limites

    blez $a2, vpb_err_limites

    beqz $a3, vpb_check_horiz
    li   $t0, ORIENT_VERT
    beq  $a3, $t0, vpb_check_vert
    j    vpb_err_limites

vpb_check_horiz:
    add  $t0, $a0, $a2
    li   $t1, 15
    bgt  $t0, $t1, vpb_err_limites
    j    vpb_check_colision

vpb_check_vert:
    add  $t0, $a1, $a2
    li   $t1, 31
    bgt  $t0, $t1, vpb_err_limites

# Verificacion de colision con regla de no-contacto:
# para cada celda del barco se revisa el vecindario 3x3 completo.
# $t1 = Y_local de la celda actual del barco
# $t2 = X de la celda actual del barco
# $t3 = contador de celdas del barco
# $t9 = base del tablero (se preserva intacto)
vpb_check_colision:
    addi $t1, $a1, -16              # Y_local inicial
    move $t2, $a0                   # X inicial
    li   $t3, 0                     # Contador

vpb_loop_celdas:
    bge  $t3, $a2, vpb_valido

    # Revisar vecindario 3x3 alrededor de (Y_local=$t1, X=$t2)
    li   $t6, -1                    # dy = -1
vpb_loop_dy:
    li   $t5, 1
    bgt  $t6, $t5, vpb_next_cell    # dy > 1 -> siguiente celda del barco

    add  $t5, $t1, $t6              # ny = Y_local + dy
    bltz $t5, vpb_next_dy
    li   $t4, 15
    bgt  $t5, $t4, vpb_next_dy

    li   $t4, -1                    # dx = -1
vpb_loop_dx:
    li   $t8, 1
    bgt  $t4, $t8, vpb_next_dy      # dx > 1 -> siguiente dy

    add  $t7, $t2, $t4              # nx = X + dx
    bltz $t7, vpb_skip_dx
    li   $t8, 15
    bgt  $t7, $t8, vpb_skip_dx

    sll  $t8, $t5, 4                # ny * 16
    add  $t8, $t8, $t7              # + nx
    add  $t8, $t9, $t8              # + base
    lbu  $t8, 0($t8)
    bnez $t8, vpb_err_colision      # cualquier celda ocupada -> colision

vpb_skip_dx:
    addi $t4, $t4, 1
    j    vpb_loop_dx

vpb_next_dy:
    addi $t6, $t6, 1
    j    vpb_loop_dy

vpb_next_cell:
    beqz $a3, vpb_step_h
    addi $t1, $t1, 1                # vertical: avanzar Y_local
    j    vpb_next_iter
vpb_step_h:
    addi $t2, $t2, 1                # horizontal: avanzar X
vpb_next_iter:
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