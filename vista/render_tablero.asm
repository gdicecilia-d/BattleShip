# Subrutinas de dibujo en el Bitmap Display y salida en consola

.text
.globl dibujar_celda
.globl dibujar_tablero_base
.globl dibujar_preview_barco
.globl limpiar_pantalla_agua
.globl imprimir_coordenadas

# dibujar_celda($a0=X, $a1=Y, $a2=color)
# Pinta una celda en display_buffer calculando: Base + ((Y * 16) + X) * 4
# Subrutina hoja: no modifica $ra ni $s0-$s7
dibujar_celda:
    bltz $a0, dc_fuera_rango        # Verificar que 0 <= X < 16
    li   $t0, ANCHO_GRID
    bge  $a0, $t0, dc_fuera_rango
    bltz $a1, dc_fuera_rango        # Verificar que 0 <= Y < 32
    li   $t0, ALTO_TOTAL
    bge  $a1, $t0, dc_fuera_rango

    sll  $t0, $a1, 4                # $t0 = Y * 16
    add  $t0, $t0, $a0              # $t0 = (Y * 16) + X
    sll  $t0, $t0, 2                # $t0 = ((Y * 16) + X) * 4 (offset en bytes)
    la   $t1, display_buffer        # Base 0x10010000
    add  $t1, $t1, $t0              # Direccion final en memoria
    sw   $a2, 0($t1)                # Guardar color RGB de 32 bits

dc_fuera_rango:
    jr   $ra


# dibujar_tablero_base($a0=addr_matriz, $a1=y_offset, $a2=radar_idx)
# Redibuja una cuadricula de 16x16 desde su matriz logica y muestra
# temporalmente la celda radar_idx en gris si radar_idx >= 0
# Preserva $ra y $s0-$s3 en la pila
dibujar_tablero_base:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   # Base de matriz logica (256 bytes)
    move $s1, $a1                   # Offset Y en pantalla (0 o 16)
    move $s2, $a2                   # Indice temporal de radar (-1 si inactivo)
    li   $s3, 0                     # Indice lineal (0..255)

dtb_loop:
    li   $t0, CELDAS_TABLERO
    bge  $s3, $t0, dtb_fin

    add  $t1, $s0, $s3
    lbu  $t2, 0($t1)                # Estado logico de la casilla

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
    bne  $s3, $s2, dtb_pintar       # Si coincide con radar activo, pintar gris
    li   $a2, COLOR_BARCO

dtb_pintar:
    andi $a0, $s3, 15               # X = idx mod 16
    srl  $t0, $s3, 4                # Y_local = idx / 16
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


# dibujar_preview_barco($a0=X, $a1=Y, $a2=longitud, $a3=orientacion)
# Pinta en amarillo la silueta tentativa del barco durante la colocacion
# Preserva $ra y $s0-$s4 en la pila
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
    move $s3, $a3                   # orientacion (0=H, 1=V)
    li   $s4, 0                     # contador i = 0

dpb_loop:
    bge  $s4, $s2, dpb_fin
    move $a0, $s0
    move $a1, $s1
    li   $a2, COLOR_CURSOR          # Amarillo (0xFFFF00)
    jal  dibujar_celda

    beqz $s3, dpb_step_h
    addi $s1, $s1, 1                # Vertical: avanzar en Y
    j    dpb_next
dpb_step_h:
    addi $s0, $s0, 1                # Horizontal: avanzar en X
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


# limpiar_pantalla_agua()
# Rellena las 512 palabras de display_buffer con color azul (agua)
limpiar_pantalla_agua:
    la   $t0, display_buffer
    li   $t1, CELDAS_PANTALLA
    li   $t2, COLOR_AGUA
lpa_loop:
    beqz $t1, lpa_fin
    sw   $t2, 0($t0)
    addi $t0, $t0, 4
    addi $t1, $t1, -1
    j    lpa_loop
lpa_fin:
    jr   $ra


# imprimir_coordenadas($a0=X, $a1=Y)
# Imprime "X,Y" en consola usando syscall 1 y syscall 4
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
