# Subrutinas de dibujo en el Bitmap Display y salida en consola

.text
.globl dibujar_celda
.globl dibujar_tablero_base
.globl dibujar_preview_barco
.globl limpiar_pantalla_agua
.globl imprimir_coordenadas

# dibujar_celda($a0=X, $a1=Y, $a2=color)
dibujar_celda:
    bltz $a0, dc_fuera_rango
    li   $t0, ANCHO_GRID
    bge  $a0, $t0, dc_fuera_rango
    bltz $a1, dc_fuera_rango
    li   $t0, ALTO_TOTAL
    bge  $a1, $t0, dc_fuera_rango

    sll  $t0, $a1, 4                
    add  $t0, $t0, $a0              
    sll  $t0, $t0, 2                
    la   $t1, display_buffer        
    add  $t1, $t1, $t0              
    sw   $a2, 0($t1)                

dc_fuera_rango:
    jr   $ra

# dibujar_tablero_base($a0=addr_matriz, $a1=y_offset, $a2=radar_idx)
dibujar_tablero_base:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   
    move $s1, $a1                   
    move $s2, $a2                   
    li   $s3, 0                     

dtb_loop:
    li   $t0, CELDAS_TABLERO
    bge  $s3, $t0, dtb_fin

    andi $a0, $s3, 15               # X = idx mod 16
    srl  $t0, $s3, 4                # Y_local = idx / 16
    add  $a1, $t0, $s1              # Y_pantalla

    # lógica de los bordes de arena
    beqz $a0, dtb_pintar_arena       # Borde izquierdo (X=0)
    li   $t1, 15
    beq  $a0, $t1, dtb_pintar_arena  # Borde derecho (X=15)
    beq  $a1, $s1, dtb_pintar_arena  # Borde superior del tablero
    addi $t1, $s1, 15
    beq  $a1, $t1, dtb_pintar_arena  # Borde inferior del tablero

    # lógica de estados
    add  $t1, $s0, $s3
    lbu  $t2, 0($t1)                

    li   $t3, CELDA_BARCO           
    beq  $t2, $t3, dtb_es_barco
    li   $t3, CELDA_IMPACTO         
    beq  $t2, $t3, dtb_es_impacto
    li   $t3, CELDA_FALLO           
    beq  $t2, $t3, dtb_es_fallo
    li   $t3, CELDA_HUNDIDO         # NUEVO: Detectar Hundido
    beq  $t2, $t3, dtb_es_hundido

    bne  $s3, $s2, dtb_agua_olas
    
    li   $a2, COLOR_BARCO           # Radar
    j    dtb_pintar

dtb_agua_olas:
    add  $t4, $a0, $t0              
    andi $t4, $t4, 1                
    beqz $t4, dtb_agua_1
    li   $a2, COLOR_AGUA_2
    j    dtb_pintar
dtb_agua_1:
    li   $a2, COLOR_AGUA_1
    j    dtb_pintar

dtb_es_barco:
    li   $a2, COLOR_BARCO
    j    dtb_pintar
dtb_es_impacto:
    li   $a2, COLOR_IMPACTO
    j    dtb_pintar
dtb_es_fallo:
    li   $a2, COLOR_FALLO
    j    dtb_pintar
dtb_es_hundido:
    li   $a2, COLOR_HUNDIDO
    j    dtb_pintar

dtb_pintar_arena:
    li   $a2, COLOR_ARENA

dtb_pintar:
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
dibujar_preview_barco:
    addi $sp, $sp, -24
    sw   $ra, 20($sp)
    sw   $s4, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   
    move $s1, $a1                   
    move $s2, $a2                   
    move $s3, $a3                   
    li   $s4, 0                     

dpb_loop:
    bge  $s4, $s2, dpb_fin
    move $a0, $s0
    move $a1, $s1
    
    andi $t0, $s4, 1
    beqz $t0, dpb_cursor_1
    li   $a2, COLOR_CURSOR_2        
    j    dpb_draw
dpb_cursor_1:
    li   $a2, COLOR_CURSOR_1        

dpb_draw:
    jal  dibujar_celda
    beqz $s3, dpb_step_h
    addi $s1, $s1, 1                
    j    dpb_next
dpb_step_h:
    addi $s0, $s0, 1                
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
limpiar_pantalla_agua:
    la   $t0, display_buffer
    li   $t1, CELDAS_PANTALLA
    li   $t2, COLOR_AGUA_1          
lpa_loop:
    beqz $t1, lpa_fin
    sw   $t2, 0($t0)
    addi $t0, $t0, 4
    addi $t1, $t1, -1
    j    lpa_loop
lpa_fin:
    jr   $ra

# imprimir_coordenadas($a0=X, $a1=Y)
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