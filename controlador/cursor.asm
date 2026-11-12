# ==============================================================================
# CONTROLADOR (NAVEGACION): cursor.asm
# Descripcion:
#   Subrutinas reutilizables de movimiento del cursor por teclado (WASD) para
#   la zona de defensa (Y=16..31) y la zona de ataque (Y=0..15).
# ==============================================================================

.text
.globl mover_cursor
.globl mover_cursor_ataque

# ------------------------------------------------------------------------------
# SUBRUTINA: mover_cursor (Hoja)
#   Desplaza (X, Y) un paso segun WASD dentro de [0, x_max] x [y_min, y_max].
# Argumentos:
#   $a0 = X actual
#   $a1 = Y actual
#   $a2 = Tecla ASCII ('W'/'w', 'S'/'s', 'A'/'a', 'D'/'d')
#   $a3 = Limites empaquetados: (x_max << 16) | (y_min << 8) | y_max
# Retorno:
#   $v0 = Nueva coordenada X
#   $v1 = Nueva coordenada Y
# ------------------------------------------------------------------------------
mover_cursor:
    andi $t0, $a3, 0xFF             # $t0 = y_max
    srl  $t1, $a3, 8
    andi $t1, $t1, 0xFF             # $t1 = y_min
    srl  $t2, $a3, 16
    andi $t2, $t2, 0xFF             # $t2 = x_max

    move $v0, $a0
    move $v1, $a1

    # Normalizar tecla en $t3 si viene en minuscula ('a'..'z')
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
    li   $t4, TECLA_A               # Izq.   (X - 1)
    beq  $t3, $t4, mc_izquierda
    li   $t4, TECLA_D               # Der.   (X + 1)
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
    blez $v0, mc_fin
    addi $v0, $v0, -1
    j    mc_fin

mc_derecha:
    bge  $v0, $t2, mc_fin
    addi $v0, $v0, 1

mc_fin:
    jr   $ra


# ------------------------------------------------------------------------------
# SUBRUTINA: mover_cursor_ataque
#   Bucle interactivo de apuntado en el tablero superior (Y=0..15). Redibuja
#   tablero_ataque + cursor amarillo (0xFFFF00) hasta confirmar con E o Enter.
# Argumentos:
#   $a0 = X inicial (0..15)
#   $a1 = Y inicial (0..15)
#   $a2 = Direccion base de tablero_ataque (256 bytes)
#   $a3 = Indice lineal de radar temporal (0..255), o -1 si inactivo
# Retorno:
#   $v0 = X confirmada (0..15)
#   $v1 = Y confirmada (0..15)
# ------------------------------------------------------------------------------
mover_cursor_ataque:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   # $s0 = X
    move $s1, $a1                   # $s1 = Y
    move $s2, $a2                   # $s2 = base tablero_ataque
    move $s3, $a3                   # $s3 = radar_idx

    # Garantizar posicion inicial dentro de [0..15] x [0..15]
    bltz $s0, mca_clamp_x0
    li   $t0, 15
    ble  $s0, $t0, mca_check_y
    li   $s0, 15
    j    mca_check_y
mca_clamp_x0:
    li   $s0, 0

mca_check_y:
    bltz $s1, mca_clamp_y0
    li   $t0, 15
    ble  $s1, $t0, mca_bucle
    li   $s1, 15
    j    mca_bucle
mca_clamp_y0:
    li   $s1, 0

mca_bucle:
    # Redibujar Vista superior desde el Modelo (+ posible pista del radar)
    move $a0, $s2
    li   $a1, Y_ATK_MIN             # Offset Y = 0
    move $a2, $s3
    jal  dibujar_tablero_base

    # Superponer cursor amarillo
    move $a0, $s0
    move $a1, $s1
    li   $a2, COLOR_CURSOR
    jal  dibujar_celda

    # Mostrar prompt en consola
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
    li   $t0, TECLA_R               # Ignorar R durante fase de ataque
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
