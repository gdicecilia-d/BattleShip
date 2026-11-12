# ==============================================================================
# VISTA (RENDERIZADO): render_tablero.asm
# Descripcion:
#   Subrutinas graficas y de consola que traducen el estado del Modelo a pixeles
#   en display_buffer (0x10010000) o texto en Run I/O. Nunca alteran las
#   matrices logicas del Modelo.
# ==============================================================================

.text
.globl dibujar_celda
.globl dibujar_tablero_base
.globl dibujar_preview_barco
.globl limpiar_pantalla_agua
.globl imprimir_coordenadas

# ------------------------------------------------------------------------------
# SUBRUTINA: dibujar_celda (Hoja)
#   Calcula: Dir(X, Y) = display_buffer + ((Y * 16) + X) * 4
# Argumentos:
#   $a0 = X (0..15)
#   $a1 = Y (0..31 en pantalla completa)
#   $a2 = Color RGB de 32 bits
# Retorno: Ninguno. (No modifica $ra ni $s0-$s7)
# ------------------------------------------------------------------------------
dibujar_celda:
    bltz $a0, dc_fuera_rango        # Guarda: X < 0 -> abortar
    li   $t0, ANCHO_GRID            # $t0 = 16
    bge  $a0, $t0, dc_fuera_rango   # Guarda: X >= 16 -> abortar
    bltz $a1, dc_fuera_rango        # Guarda: Y < 0 -> abortar
    li   $t0, ALTO_TOTAL            # $t0 = 32
    bge  $a1, $t0, dc_fuera_rango   # Guarda: Y >= 32 -> abortar

    sll  $t0, $a1, 4                # $t0 = Y * 16 (desplazar 4 bits izquierda)
    add  $t0, $t0, $a0              # $t0 = (Y * 16) + X (indice 0..511)
    sll  $t0, $t0, 2                # $t0 = ((Y * 16) + X) * 4 (offset en bytes)
    la   $t1, display_buffer        # $t1 = base 0x10010000
    add  $t1, $t1, $t0              # $t1 = direccion final de palabra
    sw   $a2, 0($t1)                # Pintar pixel en el Bitmap Display

dc_fuera_rango:
    jr   $ra


# ------------------------------------------------------------------------------
# SUBRUTINA: dibujar_tablero_base
#   Redibuja una mitad de 16x16 desde su matriz logica (Agua/Barco/Impacto/Fallo)
#   y superpone opcionalmente la casilla temporal de radar (Gris).
# Argumentos:
#   $a0 = Direccion base de la matriz logica (256 bytes)
#   $a1 = Offset Y en pantalla (0 para Ataque, 16 para Defensa)
#   $a2 = Indice lineal (0..255) revelado por radar, o -1 si inactivo
# Retorno: Ninguno. (Preserva $ra y $s0-$s3 en $sp)
# ------------------------------------------------------------------------------
dibujar_tablero_base:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   # $s0 = base matriz logica
    move $s1, $a1                   # $s1 = y_offset pantalla
    move $s2, $a2                   # $s2 = radar_idx
    li   $s3, 0                     # $s3 = idx lineal (0..255)

dtb_loop:
    li   $t0, CELDAS_TABLERO        # 256
    bge  $s3, $t0, dtb_fin

    add  $t1, $s0, $s3
    lbu  $t2, 0($t1)                # Leer byte logico de la casilla

    li   $a2, COLOR_AGUA            # 0 = Agua (Azul)
    beqz $t2, dtb_check_radar
    li   $t3, CELDA_BARCO           # 1 = Barco (Gris)
    beq  $t2, $t3, dtb_es_barco
    li   $t3, CELDA_IMPACTO         # 2 = Impacto (Rojo)
    beq  $t2, $t3, dtb_es_impacto
    li   $a2, COLOR_FALLO           # 3 = Fallo (Blanco)
    j    dtb_pintar

dtb_es_barco:
    li   $a2, COLOR_BARCO
    j    dtb_pintar

dtb_es_impacto:
    li   $a2, COLOR_IMPACTO
    j    dtb_pintar

dtb_check_radar:
    bne  $s3, $s2, dtb_pintar       # Si idx == radar_idx y aun no disparada -> Gris
    li   $a2, COLOR_BARCO

dtb_pintar:
    andi $a0, $s3, 15               # X = idx & 15
    srl  $t0, $s3, 4                # Y_local = idx >> 4
    add  $a1, $t0, $s1              # Y_pantalla = Y_local + y_offset
    jal  dibujar_celda

    addi $s3, $s3, 1
    j    dtb_loop

dtb_fin:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20
    jr   $ra


# ------------------------------------------------------------------------------
# SUBRUTINA: dibujar_preview_barco
#   Dibuja en Amarillo (0xFFFF00) la silueta tentativa del barco actual.
# Argumentos:
#   $a0 = X, $a1 = Y (16..31), $a2 = longitud, $a3 = orientacion (0=H, 1=V)
# Retorno: Ninguno. (Preserva $ra y $s0-$s4 en $sp)
# ------------------------------------------------------------------------------
dibujar_preview_barco:
    addi $sp, $sp, -24
    sw   $ra, 20($sp)
    sw   $s4, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   # X
    move $s1, $a1                   # Y
    move $s2, $a2                   # longitud
    move $s3, $a3                   # orientacion
    li   $s4, 0                     # i = 0

dpb_loop:
    bge  $s4, $s2, dpb_fin
    move $a0, $s0
    move $a1, $s1
    li   $a2, COLOR_CURSOR          # Amarillo (0xFFFF00)
    jal  dibujar_celda

    beqz $s3, dpb_step_h
    addi $s1, $s1, 1                # Vertical: Y++
    j    dpb_next
dpb_step_h:
    addi $s0, $s0, 1                # Horizontal: X++
dpb_next:
    addi $s4, $s4, 1
    j    dpb_loop

dpb_fin:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $s4, 16($sp)
    lw   $ra, 20($sp)
    addi $sp, $sp, 24
    jr   $ra


# ------------------------------------------------------------------------------
# SUBRUTINA: limpiar_pantalla_agua (Hoja)
#   Pinta las 512 celdas (16 x 32) de display_buffer en Azul (0x0000FF).
# ------------------------------------------------------------------------------
limpiar_pantalla_agua:
    la   $t0, display_buffer
    li   $t1, CELDAS_PANTALLA       # 512 palabras
    li   $t2, COLOR_AGUA
lpa_loop:
    beqz $t1, lpa_fin
    sw   $t2, 0($t0)
    addi $t0, $t0, 4
    addi $t1, $t1, -1
    j    lpa_loop
lpa_fin:
    jr   $ra


# ------------------------------------------------------------------------------
# SUBRUTINA: imprimir_coordenadas (Hoja)
#   Imprime "X,Y" en consola via syscall 1 y syscall 4.
# Argumentos: $a0 = X, $a1 = Y
# ------------------------------------------------------------------------------
imprimir_coordenadas:
    move $t0, $a0
    move $t1, $a1

    li   $v0, 1
    move $a0, $t0
    syscall
    li   $v0, 4
    la   $a0, msg_coma
    syscall
    li   $v0, 1
    move $a0, $t1
    syscall

    jr   $ra
