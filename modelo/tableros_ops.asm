# ==============================================================================
# MODELO (OPERACIONES DE ESTADO): tableros_ops.asm
# Descripcion:
#   Subrutinas puras sobre matrices logicas de 256 bytes (limpieza, conteo de
#   casillas vivas e inicializacion autonoma de flota enemiga de prueba).
# ==============================================================================

.text
.globl limpiar_matriz_256
.globl inicializar_demo_tableros
.globl contar_barcos_restantes

# ------------------------------------------------------------------------------
# SUBRUTINA: limpiar_matriz_256 (Hoja)
#   Llena con ceros (CELDA_AGUA) una matriz logica de 256 bytes.
# Argumentos: $a0 = Direccion base de la matriz (256 bytes)
# ------------------------------------------------------------------------------
limpiar_matriz_256:
    li   $t0, CELDAS_TABLERO        # 256 bytes
lm_loop:
    beqz $t0, lm_fin
    sb   $zero, 0($a0)
    addi $a0, $a0, 1
    addi $t0, $t0, -1
    j    lm_loop
lm_fin:
    jr   $ra


# ------------------------------------------------------------------------------
# SUBRUTINA: inicializar_demo_tableros
#   Limpia tablero_defensa, tablero_ataque y tablero_enemigo, y coloca 4 barcos
#   enemigos de prueba (14 casillas) para ejecutar la demo sin depender aun
#   del generador aleatorio de Integrante 1:
#     - Portaaviones (5) horizontal en (1..5, 1)
#     - Acorazado    (4) vertical   en (10, 3..6)
#     - Submarino    (3) horizontal en (4..6, 9)
#     - Fragata      (2) vertical   en (13, 12..13)
# ------------------------------------------------------------------------------
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
    li   $t1, CELDA_BARCO           # 1 = barco intacto

    # Portaaviones (5): Y=1, X=1..5 (indices 17..21)
    sb   $t1, 17($t0)
    sb   $t1, 18($t0)
    sb   $t1, 19($t0)
    sb   $t1, 20($t0)
    sb   $t1, 21($t0)

    # Acorazado (4): X=10, Y=3..6 (indices 58, 74, 90, 106)
    sb   $t1, 58($t0)
    sb   $t1, 74($t0)
    sb   $t1, 90($t0)
    sb   $t1, 106($t0)

    # Submarino (3): Y=9, X=4..6 (indices 148, 149, 150)
    sb   $t1, 148($t0)
    sb   $t1, 149($t0)
    sb   $t1, 150($t0)

    # Fragata (2): X=13, Y=12..13 (indices 205, 221)
    sb   $t1, 205($t0)
    sb   $t1, 221($t0)

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


# ------------------------------------------------------------------------------
# SUBRUTINA: contar_barcos_restantes (Hoja)
#   Cuenta cuantas casillas permanecen en estado CELDA_BARCO (1).
# Argumentos: $a0 = Direccion base de la matriz (256 bytes)
# Retorno:    $v0 = Cantidad de casillas intactas (0..256)
# ------------------------------------------------------------------------------
contar_barcos_restantes:
    li   $v0, 0
    li   $t0, CELDAS_TABLERO        # 256
    li   $t1, CELDA_BARCO           # 1
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
