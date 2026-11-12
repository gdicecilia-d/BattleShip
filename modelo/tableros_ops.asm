# Operaciones sobre matrices logicas de 256 bytes (16x16)

.text
.globl limpiar_matriz_256
.globl inicializar_demo_tableros
.globl contar_barcos_restantes

# limpiar_matriz_256($a0=base_matriz)
# Inicializa en cero los 256 bytes de la matriz indicada
limpiar_matriz_256:
    li   $t0, CELDAS_TABLERO
lm_loop:
    beqz $t0, lm_fin
    sb   $zero, 0($a0)
    addi $a0, $a0, 1
    addi $t0, $t0, -1
    j    lm_loop
lm_fin:
    jr   $ra


# inicializar_demo_tableros()
# Limpia las matrices y carga la flota enemiga inicial en tablero_enemigo
# Preserva $ra en la pila
inicializar_demo_tableros:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    la   $a0, tablero_defensa
    jal  limpiar_matriz_256
    la   $a0, tablero_ataque
    jal  limpiar_matriz_256
    la   $a0, tablero_enemigo
    jal  limpiar_matriz_256

    la   $t0, tablero_enemigo
    li   $t1, CELDA_BARCO

    # Portaaviones (5) horizontal en (1..5, 1)
    sb   $t1, 17($t0)
    sb   $t1, 18($t0)
    sb   $t1, 19($t0)
    sb   $t1, 20($t0)
    sb   $t1, 21($t0)

    # Acorazado (4) vertical en (10, 3..6)
    sb   $t1, 58($t0)
    sb   $t1, 74($t0)
    sb   $t1, 90($t0)
    sb   $t1, 106($t0)

    # Submarino (3) horizontal en (4..6, 9)
    sb   $t1, 148($t0)
    sb   $t1, 149($t0)
    sb   $t1, 150($t0)

    # Fragata (2) vertical en (13, 12..13)
    sb   $t1, 205($t0)
    sb   $t1, 221($t0)

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


# contar_barcos_restantes($a0=base_matriz) -> $v0 = casillas con estado 1
contar_barcos_restantes:
    li   $v0, 0
    li   $t0, CELDAS_TABLERO
    li   $t1, CELDA_BARCO
cbr_loop:
    beqz $t0, cbr_fin
    lbu  $t2, 0($a0)
    bne  $t2, $t1, cbr_next
    addi $v0, $v0, 1
cbr_next:
    addi $a0, $a0, 1
    addi $t0, $t0, -1
    j    cbr_loop
cbr_fin:
    jr   $ra
