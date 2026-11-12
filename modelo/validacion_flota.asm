# Validacion de limites y colisiones para colocacion de barcos

.text
.globl validar_posicion_barco

# validar_posicion_barco($a0=X, $a1=Y, $a2=longitud, $a3=orientacion)
# Verifica que el barco quepa en [0..15] x [16..31] y no choque en tablero_defensa
# Retorna: $v0 = 1 si es valida, 0 si es invalida; $v1 = codigo (0=OK, 1=Limites, 2=Colision)
validar_posicion_barco:
    bltz $a0, vpb_err_limites       # X >= 0
    li   $t0, 15
    bgt  $a0, $t0, vpb_err_limites  # X <= 15
    li   $t0, Y_DEF_MIN             # 16
    blt  $a1, $t0, vpb_err_limites  # Y >= 16
    li   $t0, Y_DEF_MAX             # 31
    bgt  $a1, $t0, vpb_err_limites  # Y <= 31
    blez $a2, vpb_err_limites       # longitud > 0

    beqz $a3, vpb_check_horiz       # 0 = Horizontal
    li   $t0, ORIENT_VERT           # 1 = Vertical
    beq  $a3, $t0, vpb_check_vert
    j    vpb_err_limites

vpb_check_horiz:
    add  $t0, $a0, $a2              # X + longitud <= 16
    li   $t1, 16
    bgt  $t0, $t1, vpb_err_limites
    j    vpb_check_colision

vpb_check_vert:
    add  $t0, $a1, $a2              # Y + longitud <= 32
    li   $t1, 32
    bgt  $t0, $t1, vpb_err_limites

vpb_check_colision:
    la   $t0, tablero_defensa       # Matriz logica 16x16 de 1 byte por casilla
    addi $t1, $a1, -16              # Y_local = Y - 16 (0..15)
    move $t2, $a0                   # X actual
    li   $t3, 0                     # indice de segmento i = 0..L-1

vpb_loop_celdas:
    bge  $t3, $a2, vpb_valido

    sll  $t4, $t1, 4                # Y_local * 16
    add  $t4, $t4, $t2              # indice = (Y_local * 16) + X
    add  $t4, $t0, $t4              # direccion en tablero_defensa
    lbu  $t5, 0($t4)                # leer estado de la casilla
    bnez $t5, vpb_err_colision      # si != 0, hay colision

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
