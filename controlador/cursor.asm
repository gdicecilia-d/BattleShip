# Subrutinas de movimiento del cursor en tablero de defensa y ataque

.text
.globl mover_cursor
.globl mover_cursor_ataque

# mover_cursor($a0=X, $a1=Y, $a2=tecla, $a3=limites) -> ($v0=new_X, $v1=new_Y)
# Limites empaquetados en $a3: (x_max << 16) | (y_min << 8) | y_max
mover_cursor:
    andi $t0, $a3, 0xFF             # y_max
    srl  $t1, $a3, 8
    andi $t1, $t1, 0xFF             # y_min
    srl  $t2, $a3, 16
    andi $t2, $t2, 0xFF             # x_max

    move $v0, $a0
    move $v1, $a1

    # Normalizar tecla a mayuscula si es minuscula ('a'..'z')
    move $t3, $a2
    li   $t4, 97
    blt  $t3, $t4, mc_evaluar
    li   $t4, 122
    bgt  $t3, $t4, mc_evaluar
    addi $t3, $t3, -32

mc_evaluar:
    li   $t4, TECLA_W               # Arriba (Y - 1)
    beq  $t3, $t4, mc_arriba
    li   $t4, TECLA_S               # Abajo  (Y + 1)
    beq  $t3, $t4, mc_abajo
    li   $t4, TECLA_A               # Izquierda (X - 1)
    beq  $t3, $t4, mc_izquierda
    li   $t4, TECLA_D               # Derecha   (X + 1)
    beq  $t3, $t4, mc_derecha
    j    mc_fin

mc_arriba:
    ble  $v1, $t1, mc_fin
    addi $v1, $v1, -1
    j    mc_fin

mc_abajo:
    bge  $v1, $t0, mc_fin
    addi $v1, $v1, 1
    j    mc_fin

mc_izquierda:
    li   $t4, 1                     # NUEVO: X_min = 1 (no puede ser 0)
    ble  $v0, $t4, mc_fin
    addi $v0, $v0, -1
    j    mc_fin

mc_derecha:
    bge  $v0, $t2, mc_fin
    addi $v0, $v0, 1

mc_fin:
    jr   $ra


# mover_cursor_ataque($a0=X_ini, $a1=Y_ini, $a2=tablero_ataque, $a3=radar_idx)
# Bucle interactivo de seleccion de objetivo en la mitad superior (Y=0..15)
# Retorna: $v0 = X confirmada, $v1 = Y confirmada. Preserva $ra y $s0-$s3
mover_cursor_ataque:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   # X actual
    move $s1, $a1                   # Y actual
    move $s2, $a2                   # Base tablero_ataque
    move $s3, $a3                   # Indice de radar (-1 si inactivo)

    # Asegurar coordenadas iniciales en [1..14] x [1..14]
    li   $t0, 1
    blt  $s0, $t0, mca_clamp_x0
    li   $t0, 14
    ble  $s0, $t0, mca_check_y
    li   $s0, 14
    j    mca_check_y
mca_clamp_x0:
    li   $s0, 1

mca_check_y:
    li   $t0, 1
    blt  $s1, $t0, mca_clamp_y0
    li   $t0, 14
    ble  $s1, $t0, mca_bucle
    li   $s1, 14
    j    mca_bucle
mca_clamp_y0:
    li   $s1, 1

mca_bucle:
    move $a0, $s2
    li   $a1, Y_ATK_MIN             # Offset Y = 0
    move $a2, $s3
    jal  dibujar_tablero_base

    move $a0, $s0
    move $a1, $s1
    li   $a2, COLOR_CURSOR_1        # Pintar cursor blanco humo en (X, Y)
    jal  dibujar_celda

    li   $v0, 4
    la   $a0, msg_atk_prompt
    syscall
    move $a0, $s0
    move $a1, $s1
    jal  imprimir_coordenadas
    li   $v0, 4
    la   $a0, msg_atk_tecla
    syscall

    jal  leer_tecla

    li   $t0, TECLA_E
    beq  $v0, $t0, mca_confirmar
    li   $t0, TECLA_ENTER
    beq  $v0, $t0, mca_confirmar
    li   $t0, TECLA_R               # Ignorar rotacion en fase de ataque
    beq  $v0, $t0, mca_bucle

    move $a0, $s0
    move $a1, $s1
    move $a2, $v0
    li   $a3, LIMITES_ATAQUE
    jal  mover_cursor
    move $s0, $v0
    move $s1, $v1
    j    mca_bucle

mca_confirmar:
    move $v0, $s0
    move $v1, $s1

    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20
    jr   $ra