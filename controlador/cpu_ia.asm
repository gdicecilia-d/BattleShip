# Inteligencia Artificial de la CPU 

.data
cpu_estado:      .word 0  # 0 = Buscando, 1 = Arriba, 2 = Abajo, 3 = Izq, 4 = Der
cpu_origen_x:    .word -1 # Coordenada X del primer impacto
cpu_origen_y:    .word -1 # Coordenada Y del primer impacto
cpu_ultimo_x:    .word -1 # Coordenada X del último impacto
cpu_ultimo_y:    .word -1 # Coordenada Y del último impacto

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
    beqz $t0, cpu_buscar_rand       # Si está en 0, buscar al azar

    # Lógica de caza
    lw   $s1, cpu_ultimo_x
    lw   $s2, cpu_ultimo_y
    lw   $t0, cpu_estado

    li   $t1, 1
    beq  $t0, $t1, c_d_up
    li   $t1, 2
    beq  $t0, $t1, c_d_down
    li   $t1, 3
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
    # Verificar límites (1 a 14)
    li   $t1, 1
    blt  $s1, $t1, c_d_siguiente_dir
    li   $t1, 14
    bgt  $s1, $t1, c_d_siguiente_dir
    li   $t1, 1
    blt  $s2, $t1, c_d_siguiente_dir
    li   $t1, 14
    bgt  $s2, $t1, c_d_siguiente_dir

    # Verificar si ya se disparó ahí
    sll  $t1, $s2, 4
    add  $t1, $t1, $s1
    add  $t2, $s0, $t1
    lbu  $t3, 0($t2)
    li   $t4, CELDA_IMPACTO
    beq  $t3, $t4, c_d_siguiente_dir
    li   $t4, CELDA_FALLO
    beq  $t3, $t4, c_d_siguiente_dir
    li   $t4, CELDA_HUNDIDO
    beq  $t3, $t4, c_d_siguiente_dir

    j    cpu_ejecutar_disparo

c_d_siguiente_dir:
    lw   $t0, cpu_estado
    addi $t0, $t0, 1
    sw   $t0, cpu_estado
    li   $t1, 5
    bge  $t0, $t1, c_d_reset_estado
    
    # Restaurar al origen
    lw   $t1, cpu_origen_x
    lw   $t2, cpu_origen_y
    sw   $t1, cpu_ultimo_x
    sw   $t2, cpu_ultimo_y
    
    j    turno_cpu   # Volver a intentar con la nueva dirección

c_d_reset_estado:
    sw   $zero, cpu_estado
    j    cpu_buscar_rand

cpu_buscar_rand:
    li   $v0, 42
    li   $a0, 1
    li   $a1, 15                    # Genera 1 a 14
    syscall
    move $s1, $a0                   # X

    li   $v0, 42
    li   $a0, 1
    li   $a1, 15                    # Genera 1 a 14
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

cpu_ejecutar_disparo:
    sll  $t1, $s2, 4
    add  $t1, $t1, $s1
    add  $t2, $s0, $t1
    lbu  $t3, 0($t2)
    li   $t4, CELDA_BARCO
    beq  $t3, $t4, cpu_hit

    # fallo
    li   $t4, CELDA_FALLO
    sb   $t4, 0($t2)
    move $a0, $s1
    addi $a1, $s2, 16               # +16 para tablero de defensa
    li   $a2, COLOR_FALLO
    jal  dibujar_celda

    li   $v0, 4
    la   $a0, msg_tiro_miss
    syscall
    move $a0, $s1
    addi $a1, $s2, 16
    jal  imprimir_coordenadas
    li   $v0, 4
    la   $a0, msg_cierre_par
    syscall
    
    lw   $t0, cpu_estado
    beqz $t0, cpu_miss_fin          # Si estaba buscando, sigue buscando

    # Estaba cazando, así que cambiamos de dirección y reseteamos al origen
    addi $t0, $t0, 1
    sw   $t0, cpu_estado
    li   $t1, 5
    bge  $t0, $t1, cpu_miss_reset

    lw   $t1, cpu_origen_x
    lw   $t2, cpu_origen_y
    sw   $t1, cpu_ultimo_x
    sw   $t2, cpu_ultimo_y
    j    cpu_miss_fin

cpu_miss_reset:
    sw   $zero, cpu_estado

cpu_miss_fin:
    li   $v0, 0
    j    cpu_fin

cpu_hit:
    # impacto
    li   $t4, CELDA_IMPACTO
    sb   $t4, 0($t2)
    move $a0, $s1
    addi $a1, $s2, 16
    li   $a2, COLOR_IMPACTO
    jal  dibujar_celda

    li   $v0, 4
    la   $a0, msg_tiro_hit
    syscall
    move $a0, $s1
    addi $a1, $s2, 16
    jal  imprimir_coordenadas
    li   $v0, 4
    la   $a0, msg_cierre_par
    syscall

    # Actualizar la posición actual
    sw   $s1, cpu_ultimo_x
    sw   $s2, cpu_ultimo_y

    # Si estábamos buscando, iniciamos caza
    lw   $t0, cpu_estado
    bnez $t0, cpu_hit_ya_cazando
    
    # Nuevo origen
    sw   $s1, cpu_origen_x
    sw   $s2, cpu_origen_y
    li   $t0, 1
    sw   $t0, cpu_estado

cpu_hit_ya_cazando:
    move $a0, $s1
    move $a1, $s2
    move $a2, $s0
    jal  verificar_hundimiento
    beqz $v0, cpu_fin_hit

    # Se hundió
    sw   $zero, cpu_estado
    li   $v0, 4
    la   $a0, msg_hundido
    syscall
    move $a0, $s1
    move $a1, $s2
    move $a2, $s0
    move $a3, $s0                   # Usar defensa para pintar el gris
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
