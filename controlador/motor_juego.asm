# Motor de Juego Principal, Turnos y Condiciones de Fin

.data
msg_menu:       .asciiz "\nSeleccione modo: 1. PvP | 2. PvCPU\n> "
msg_turno_j1:   .asciiz "\n--- TURNO JUGADOR 1 ---\n"
msg_turno_j2:   .asciiz "\n--- TURNO JUGADOR 2 ---\n"
msg_turno_cpu:  .asciiz "\n--- TURNO DE LA CPU ---\n"
msg_pvp_fallo:  .asciiz "\nFallo. Te quedan intentos: "
msg_game_over:  .asciiz "\nGAME OVER - ¡Toda la flota ha sido destruida!\n"
msg_gana_j1:    .asciiz "\n¡GANA JUGADOR 1!\n"
msg_gana_j2:    .asciiz "\n¡GANA JUGADOR 2!\n"
msg_gana_cpu:   .asciiz "\n¡CPU GANA!\n"
msg_puntos1:    .asciiz "Puntos J1: "
msg_puntos_j2:  .asciiz " | Puntos J2: "
msg_puntos_cpu: .asciiz " | Puntos CPU: "
msg_pasa_turno: .asciiz "\nPresiona cualquier tecla para continuar...\n"

.text
.globl jugar_battleship

jugar_battleship:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    jal  resetear_puntos

    li   $v0, 4
    la   $a0, msg_menu
    syscall
    li   $v0, 5
    syscall
    sw   $v0, modo_juego

    jal  limpiar_todos_tableros
    jal  limpiar_pantalla_agua

    la   $a0, tablero_defensa
    jal  colocar_flota_manual

    lw   $t0, modo_juego
    li   $t1, 1
    beq  $t0, $t1, jb_setup_pvp
    jal  colocar_flota_cpu
    j    jb_loop_principal

jb_setup_pvp:
    li   $v0, 4
    la   $a0, msg_turno_j2
    syscall
    la   $a0, tablero_enemigo
    jal  colocar_flota_manual
    li   $v0, 4
    la   $a0, msg_pasa_turno
    syscall
    jal  leer_tecla

jb_loop_principal:
    lw   $t0, juego_terminado
    bnez $t0, jb_fin_partida

    lw   $t1, turno_actual
    li   $t2, 1
    beq  $t1, $t2, jb_turno_j1
    j    jb_turno_j2_o_cpu

jb_turno_j1:
    li   $v0, 4
    la   $a0, msg_turno_j1
    syscall

    la   $a0, tablero_defensa
    li   $a1, Y_DEF_MIN
    li   $a2, -1
    jal  dibujar_tablero_base

    la   $a0, tablero_ataque
    li   $a1, Y_ATK_MIN
    li   $a2, -1
    jal  dibujar_tablero_base

    la   $a0, tablero_enemigo
    la   $a1, tablero_ataque
    li   $s0, 1
    jal  resolver_turno_humano
    j    jb_check_win

jb_turno_j2_o_cpu:
    lw   $t0, modo_juego
    li   $t1, 1
    beq  $t0, $t1, jb_turno_j2_pvp

    # --- Turno CPU ---
    li   $v0, 4
    la   $a0, msg_turno_cpu
    syscall
    jal  turno_cpu
    move $s0, $v0
    beqz $s0, jb_cpu_fallo
    li   $a0, 2
    li   $a1, 1
    jal  sumar_puntos
    j    jb_cpu_eval_fin

jb_cpu_fallo:
    li   $t0, 1
    sw   $t0, turno_actual

jb_cpu_eval_fin:
    la   $a0, tablero_ataque
    li   $a1, Y_ATK_MIN
    li   $a2, -1
    jal  dibujar_tablero_base

    la   $a0, tablero_defensa
    li   $a1, Y_DEF_MIN
    li   $a2, -1
    jal  dibujar_tablero_base

    li   $a0, 1
    li   $a1, 1
    li   $a2, COLOR_CURSOR_1
    jal  dibujar_celda

    li   $v0, 4
    la   $a0, msg_pausa_fin
    syscall
    jal  leer_tecla
    j    jb_check_win

jb_turno_j2_pvp:
    li   $v0, 4
    la   $a0, msg_turno_j2
    syscall

    la   $a0, tablero_enemigo
    li   $a1, Y_DEF_MIN
    li   $a2, -1
    jal  dibujar_tablero_base

    la   $a0, tablero_ataque_j2
    li   $a1, Y_ATK_MIN
    li   $a2, -1
    jal  dibujar_tablero_base

    li   $v0, 4
    la   $a0, msg_pasa_turno
    syscall
    jal  leer_tecla

    la   $a0, tablero_defensa
    la   $a1, tablero_ataque_j2
    li   $s0, 2
    jal  resolver_turno_humano
    j    jb_check_win

# turno humano
# $a0 = tablero enemigo, $a1 = tablero de ataque, $s0 = jugador (1 o 2)
resolver_turno_humano:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s1, $a0
    move $s2, $a1

    # Comodin Radar
    move $a0, $s1
    move $a1, $s2
    jal  intentar_comodin_radar
    move $s3, $v1

    # Mover cursor
    li   $a0, 1
    li   $a1, 1
    move $a2, $s2
    move $a3, $s3
    jal  mover_cursor_ataque
    move $t8, $v0
    move $t9, $v1

    # Comodin Area 3x3
    move $a0, $t8
    move $a1, $t9
    move $a2, $s1
    move $a3, $s2
    jal  intentar_comodin_area
    bnez $v0, rth_comodin_area

    # Disparo normal
    move $a0, $t8
    move $a1, $t9
    move $a2, $s1
    move $a3, $s2
    jal  procesar_disparo_simple
    move $t7, $v1                   # 0=fallo, 1=impacto, 2=hundido

    beq  $t7, 2, rth_hundido
    beq  $t7, 1, rth_hit
    j    rth_fallo

rth_comodin_area:
    # El comodín de área ya impactó; verificar si hundió algún barco
    j    rth_fin_turno

rth_hundido:
    move $a0, $s0
    li   $a1, 6                     # 1 por impacto + 5 por hundido
    jal  sumar_puntos
    sw   $zero, fallos_pvp          # Resetear contador de fallos
    j    rth_fin_turno

rth_hit:
    move $a0, $s0
    li   $a1, 1
    jal  sumar_puntos
    sw   $zero, fallos_pvp          # Resetear contador de fallos
    j    rth_fin_turno

rth_fallo:
    # Fallo en PvP (3 intentos)
    lw   $t0, modo_juego
    li   $t1, 1
    bne  $t0, $t1, rth_cambio_turno_directo

    lw   $t0, fallos_pvp
    addi $t0, $t0, 1
    sw   $t0, fallos_pvp
    li   $t1, 3
    bge  $t0, $t1, rth_reset_y_cambio

    li   $v0, 4
    la   $a0, msg_pvp_fallo
    syscall
    li   $v0, 1
    li   $t1, 3
    sub  $a0, $t1, $t0
    syscall
    j    rth_fin_turno

rth_reset_y_cambio:
    sw   $zero, fallos_pvp
    j    rth_cambio_turno_directo

rth_cambio_turno_directo:
    sw   $zero, fallos_pvp          # Resetear al cambiar turno
    li   $t0, 1
    beq  $s0, $t0, rth_set_turno_2
    li   $t0, 1
    sw   $t0, turno_actual
    j    rth_fin_turno
rth_set_turno_2:
    li   $t0, 2
    sw   $t0, turno_actual
    j    rth_fin_turno

rth_fin_turno:
    move $a0, $s2
    li   $a1, Y_ATK_MIN
    li   $a2, -1
    jal  dibujar_tablero_base

rth_fin:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20
    jr   $ra

jb_check_win:
    lw   $t0, turno_actual
    li   $t1, 1
    beq  $t0, $t1, jb_check_enemigo
    la   $a0, tablero_defensa
    j    jb_hacer_conteo
jb_check_enemigo:
    la   $a0, tablero_enemigo

jb_hacer_conteo:
    jal  contar_barcos_restantes
    bgtz $v0, jb_loop_principal

    li   $t0, 1
    sw   $t0, juego_terminado

jb_fin_partida:
    li   $v0, 4
    la   $a0, msg_game_over
    syscall

    lw   $t0, turno_actual
    li   $t1, 1
    beq  $t0, $t1, jb_gana_j1_msg
    lw   $t0, modo_juego
    li   $t1, 1
    beq  $t0, $t1, jb_gana_j2_msg
    li   $v0, 4
    la   $a0, msg_gana_cpu
    syscall
    j    jb_mostrar_puntos

jb_gana_j1_msg:
    li   $v0, 4
    la   $a0, msg_gana_j1
    syscall
    j    jb_mostrar_puntos

jb_gana_j2_msg:
    li   $v0, 4
    la   $a0, msg_gana_j2
    syscall

jb_mostrar_puntos:
    li   $v0, 4
    la   $a0, msg_puntos1
    syscall
    li   $v0, 1
    lw   $a0, puntos_j1
    syscall

    # Mensaje dinámico para J2 o CPU
    lw   $t0, modo_juego
    li   $t1, 1
    beq  $t0, $t1, jb_mostrar_puntos_j2
    li   $v0, 4
    la   $a0, msg_puntos_cpu
    syscall
    j    jb_mostrar_puntos_val

jb_mostrar_puntos_j2:
    li   $v0, 4
    la   $a0, msg_puntos_j2
    syscall

jb_mostrar_puntos_val:
    li   $v0, 1
    lw   $a0, puntos_j2
    syscall

    li   $v0, 4
    la   $a0, msg_nl
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
