# Inteligencia Artificial de la CPU (Integrante 3)

.data
cpu_estado:      .word 0  # 0 = Buscando, 1 = Cazando
cpu_ultimo_x:    .word -1
cpu_ultimo_y:    .word -1
cpu_dir_intento: .word 0  # 0=Arriba, 1=Abajo, 2=Izq, 3=Der

.text
.globl colocar_flota_cpu
.globl turno_cpu

colocar_flota_cpu:
    addi $sp, $sp, -12
    sw   $ra, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    la   $a0, tablero_enemigo
    jal  limpiar_matriz_256

    li   $s0, 0                     # Índice de barco (0..3)

cfc_loop_barcos:
    li   $t0, 4
    bge  $s0, $t0, cfc_fin

    sll  $t0, $s0, 2
    la   $t1, longitudes_flota
    add  $t1, $t1, $t0
    lw   $s1, 0($t1)                # Longitud actual

cfc_reintentar:
    li   $v0, 42
    li   $a0, 0
    li   $a1, 14
    syscall
    addi $t2, $a0, 1                # X en $t2

    li   $v0, 42
    li   $a0, 0
    li   $a1, 14
    syscall
    addi $t3, $a0, 1                # Y en $t3

    li   $v0, 42
    li   $a0, 0
    li   $a1, 2
    syscall
    move $t4, $a0                   # Orientación en $t4

    beqz $t4, cfc_val_h
    add  $t5, $t3, $s1
    li   $t6, 15
    bgt  $t5, $t6, cfc_reintentar
    j    cfc_ver_colision

cfc_val_h:
    add  $t5, $t2, $s1
    li   $t6, 15
    bgt  $t5, $t6, cfc_reintentar

cfc_ver_colision:
    li   $t5, 0
    la   $t6, tablero_enemigo
cfc_col_loop:
    bge  $t5, $s1, cfc_col_ok
    beqz $t4, cfc_col_h
    add  $t7, $t3, $t5
    sll  $t7, $t7, 4
    add  $t7, $t7, $t2
    j    cfc_col_check
cfc_col_h:
    sll  $t7, $t3, 4
    add  $t7, $t7, $t2
    add  $t7, $t7, $t5
cfc_col_check:
    add  $t7, $t6, $t7
    lbu  $t8, 0($t7)
    bnez $t8, cfc_reintentar
    addi $t5, $t5, 1
    j    cfc_col_loop

cfc_col_ok:
    li   $t5, 0
cfc_place_loop:
    bge  $t5, $s1, cfc_next_barco
    beqz $t4, cfc_place_h
    add  $t7, $t3, $t5
    sll  $t7, $t7, 4
    add  $t7, $t7, $t2
    j    cfc_place_do
cfc_place_h:
    sll  $t7, $t3, 4
    add  $t7, $t7, $t2
    add  $t7, $t7, $t5
cfc_place_do:
    add  $t7, $t6, $t7
    li   $t8, CELDA_BARCO
    sb   $t8, 0($t7)
    addi $t5, $t5, 1
    j    cfc_place_loop

cfc_next_barco:
    addi $s0, $s0, 1
    j    cfc_loop_barcos

cfc_fin:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $ra, 8($sp)
    addi $sp, $sp, 12
    jr   $ra

turno_cpu:
    addi $sp, $sp, -16
    sw   $ra, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    la   $s0, tablero_defensa       # Tablero del jugador

    lw   $t0, cpu_estado
    bnez $t0, cpu_cazar             # Si está cazando, ir a lógica de caza

cpu_buscar_rand:
    li   $v0, 42
    li   $a0, 1
    li   $a1, 14
    syscall
    move $s1, $a0                   # X

    li   $v0, 42
    li   $a0, 1
    li   $a1, 14
    syscall
    move $s2, $a0                   # Y
    
    sll  $t1, $s2, 4
    add  $t1, $t1, $s1
    add  $t2, $s0, $t1
    lbu  $t3, 0($t2)
    li   $t4, CELDA_IMPACTO
    beq  $t3, $t4, cpu_buscar_rand
    li   $t4, CELDA_FALLO
    beq  $t3, $t4, cpu_buscar_rand
    li   $t4, CELDA_HUNDIDO
    beq  $t3, $t4, cpu_buscar_rand

    j    cpu_ejecutar_disparo

cpu_cazar:
    lw   $s1, cpu_ultimo_x
    lw   $s2, cpu_ultimo_y
    lw   $t0, cpu_dir_intento

    beqz $t0, c_d_up
    li   $t1, 1
    beq  $t0, $t1, c_d_down
    li   $t1, 2
    beq  $t0, $t1, c_d_left
    j    c_d_right

c_d_up:
    addi $s2, $s2, -1
    j    c_d_validar
c_d_down:
    addi $s2, $s2, 1
    j    c_d_validar
c_d_left:
    addi $s1, $s1, -1
    j    c_d_validar
c_d_right:
    addi $s1, $s1, 1

c_d_validar:
    bltz $s1, c_d_cambiar_dir
    bgt  $s1, 15, c_d_cambiar_dir
    bltz $s2, c_d_cambiar_dir
    bgt  $s2, 15, c_d_cambiar_dir

    sll  $t1, $s2, 4
    add  $t1, $t1, $s1
    add  $t2, $s0, $t1
    lbu  $t3, 0($t2)
    li   $t4, CELDA_IMPACTO
    beq  $t3, $t4, c_d_cambiar_dir
    li   $t4, CELDA_FALLO
    beq  $t3, $t4, c_d_cambiar_dir
    li   $t4, CELDA_HUNDIDO
    beq  $t3, $t4, c_d_cambiar_dir

    # --- CORRECCIÓN: Avanzar la dirección antes de disparar ---
    # Si falla, en su próximo turno probará la siguiente dirección
    lw   $t0, cpu_dir_intento
    addi $t0, $t0, 1
    sw   $t0, cpu_dir_intento
    # -----------------------------------------------------------

    j    cpu_ejecutar_disparo

c_d_cambiar_dir:
    lw   $t0, cpu_dir_intento
    addi $t0, $t0, 1
    sw   $t0, cpu_dir_intento
    li   $t1, 4
    bge  $t0, $t1, c_d_reset_estado
    j    cpu_cazar

c_d_reset_estado:
    sw   $zero, cpu_estado
    j    cpu_buscar_rand

cpu_ejecutar_disparo:
    sll  $t1, $s2, 4
    add  $t1, $t1, $s1
    add  $t2, $s0, $t1
    lbu  $t3, 0($t2)
    li   $t4, CELDA_BARCO
    beq  $t3, $t4, cpu_hit

    li   $t4, CELDA_FALLO
    sb   $t4, 0($t2)
    move $a0, $s1
    move $a1, $s2
    li   $a2, COLOR_FALLO
    jal  dibujar_celda

    li   $v0, 4
    la   $a0, msg_tiro_miss
    syscall
    move $a0, $s1
    move $a1, $s2
    jal  imprimir_coordenadas
    li   $v0, 4
    la   $a0, msg_cierre_par
    syscall
    
    li   $v0, 0
    j    cpu_fin

cpu_hit:
    li   $t4, CELDA_IMPACTO
    sb   $t4, 0($t2)
    move $a0, $s1
    move $a1, $s2
    li   $a2, COLOR_IMPACTO
    jal  dibujar_celda

    li   $v0, 4
    la   $a0, msg_tiro_hit
    syscall
    move $a0, $s1
    move $a1, $s2
    jal  imprimir_coordenadas
    li   $v0, 4
    la   $a0, msg_cierre_par
    syscall

    li   $t0, 1
    sw   $t0, cpu_estado
    sw   $s1, cpu_ultimo_x
    sw   $s2, cpu_ultimo_y
    sw   $zero, cpu_dir_intento

    move $a0, $s1
    move $a1, $s2
    move $a2, $s0
    jal  verificar_hundimiento
    beqz $v0, cpu_fin_hit

    sw   $zero, cpu_estado
    li   $v0, 4
    la   $a0, msg_hundido
    syscall
    move $a0, $s1
    move $a1, $s2
    move $a2, $s0
    la   $a3, tablero_ataque
    jal  marcar_hundido

cpu_fin_hit:
    li   $v0, 1
cpu_fin:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $ra, 12($sp)
    addi $sp, $sp, 16
    jr   $ra