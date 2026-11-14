# Mecanicas de comodin usando syscall 42 (Radar 5% y Ataque 3x3 1 en 7)

.text
.globl intentar_comodin_radar
.globl intentar_comodin_area
.globl ejecutar_comodin

# intentar_comodin_radar($a0=tablero_enemigo, $a1=tablero_ataque)
intentar_comodin_radar:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   
    move $s1, $a1                   

    li   $v0, 42                    
    li   $a0, 0
    li   $a1, 100
    syscall
    li   $t0, 5
    bge  $a0, $t0, icr_no_activado

    li   $v0, 42                    
    li   $a0, 0
    li   $a1, CELDAS_TABLERO
    syscall
    move $s2, $a0
    li   $s3, 0

icr_buscar_loop:
    li   $t0, CELDAS_TABLERO
    bge  $s3, $t0, icr_no_activado

    add  $t1, $s2, $s3
    andi $t1, $t1, 255              

    add  $t2, $s0, $t1
    lbu  $t3, 0($t2)
    li   $t4, CELDA_BARCO
    bne  $t3, $t4, icr_siguiente

    beqz $s1, icr_encontrado
    add  $t2, $s1, $t1
    lbu  $t3, 0($t2)
    bnez $t3, icr_siguiente

icr_encontrado:
    andi $s2, $t1, 15               
    srl  $s3, $t1, 4                
    move $s0, $t1                   

    move $a0, $s2
    move $a1, $s3
    li   $a2, COLOR_BARCO
    jal  dibujar_celda

    li   $v0, 4
    la   $a0, msg_radar_on
    syscall
    move $a0, $s2
    move $a1, $s3
    jal  imprimir_coordenadas
    li   $v0, 4
    la   $a0, msg_radar_fin
    syscall

    li   $v0, 1
    move $v1, $s0
    j    icr_epilogo

icr_siguiente:
    addi $s3, $s3, 1
    j    icr_buscar_loop

icr_no_activado:
    li   $v0, 0
    li   $v1, -1

icr_epilogo:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20
    jr   $ra


# intentar_comodin_area($a0=X, $a1=Y, $a2=tablero_enemigo, $a3=tablero_ataque)
intentar_comodin_area:
    addi $sp, $sp, -32
    sw   $ra, 28($sp)
    sw   $s6, 24($sp)
    sw   $s5, 20($sp)
    sw   $s4, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   
    move $s1, $a1                   
    move $s2, $a2                   
    move $s3, $a3                   

    li   $v0, 42                    
    li   $a0, 0
    li   $a1, 7
    syscall
    bnez $a0, ica_no_activado

    li   $s4, 0                     
    li   $s5, -1                    

ica_loop_dy:
    li   $t0, 1
    bgt  $s5, $t0, ica_fin_area

    add  $t1, $s1, $s5              
    bltz $t1, ica_next_dy
    li   $t2, Y_ATK_MAX
    bgt  $t1, $t2, ica_next_dy

    li   $s6, -1                    

ica_loop_dx:
    li   $t0, 1
    bgt  $s6, $t0, ica_next_dy

    add  $t3, $s0, $s6              
    bltz $t3, ica_next_dx
    li   $t2, 15
    bgt  $t3, $t2, ica_next_dx

    add  $t1, $s1, $s5
    sll  $t4, $t1, 4
    add  $t4, $t4, $t3              

    add  $t5, $s2, $t4
    lbu  $t6, 0($t5)

    li   $t7, CELDA_HUNDIDO
    beq  $t6, $t7, ica_next_dx

    li   $t7, CELDA_BARCO
    beq  $t6, $t7, ica_nuevo_hit
    li   $t7, CELDA_IMPACTO
    beq  $t6, $t7, ica_ya_hit

    li   $t7, CELDA_FALLO
    sb   $t7, 0($t5)
    beqz $s3, ica_draw_miss
    add  $t8, $s3, $t4
    sb   $t7, 0($t8)
ica_draw_miss:
    move $a0, $t3
    move $a1, $t1
    li   $a2, COLOR_FALLO
    jal  dibujar_celda
    j    ica_next_dx

ica_nuevo_hit:
    addi $s4, $s4, 1
ica_ya_hit:
    li   $t7, CELDA_IMPACTO
    sb   $t7, 0($t5)
    beqz $s3, ica_draw_hit
    add  $t8, $s3, $t4
    sb   $t7, 0($t8)

ica_draw_hit:
    # GUARDAMOS X e Y ANTES de dibujar, porque dibujar_celda sobrescribe $t1
    move $t8, $t3                   
    move $t9, $t1                   
    
    move $a0, $t3
    move $a1, $t1
    li   $a2, COLOR_IMPACTO
    jal  dibujar_celda

    # Verificar si este impacto hundio el barco usando los registros seguros
    move $a0, $t8
    move $a1, $t9
    move $a2, $s2
    jal  verificar_hundimiento
    beqz $v0, ica_next_dx           

    # Si se hundio, pintar TODO el barco de gris
    move $a0, $t8
    move $a1, $t9
    move $a2, $s2
    move $a3, $s3
    jal  marcar_hundido

ica_next_dx:
    addi $s6, $s6, 1
    j    ica_loop_dx

ica_next_dy:
    addi $s5, $s5, 1
    j    ica_loop_dy

ica_fin_area:
    li   $v0, 4
    la   $a0, msg_area_on
    syscall
    move $a0, $s0
    move $a1, $s1
    jal  imprimir_coordenadas
    li   $v0, 4
    la   $a0, msg_area_hits
    syscall
    li   $v0, 1
    move $a0, $s4
    syscall
    li   $v0, 4
    la   $a0, msg_nl
    syscall

    li   $v0, 1
    move $v1, $s4
    j    ica_epilogo

ica_no_activado:
    li   $v0, 0
    li   $v1, 0

ica_epilogo:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $s4, 16($sp)
    lw   $s5, 20($sp)
    lw   $s6, 24($sp)
    lw   $ra, 28($sp)
    addi $sp, $sp, 32
    jr   $ra


# ejecutar_comodin($a0=modo, $a1=X, $a2=Y)
ejecutar_comodin:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    beqz $a0, ec_radar
    move $a0, $a1
    move $a1, $a2
    la   $a2, tablero_enemigo
    la   $a3, tablero_ataque
    jal  intentar_comodin_area
    j    ec_fin

ec_radar:
    la   $a0, tablero_enemigo
    la   $a1, tablero_ataque
    jal  intentar_comodin_radar

ec_fin:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra