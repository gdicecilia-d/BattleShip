# Sistema de Puntuación, Turnos y Estado Global (Integrante 3)

.data
.globl puntos_j1
.globl puntos_j2
.globl turno_actual      # 1 = Jugador 1, 2 = Jugador 2 / CPU
.globl modo_juego        # 1 = PvP, 2 = PvCPU
.globl fallos_pvp        # Contador de fallos en PvP (máx 3)
.globl juego_terminado   # 0 = Falso, 1 = Verdadero

puntos_j1:      .word 0
puntos_j2:      .word 0
turno_actual:   .word 1
modo_juego:     .word 2  # Por defecto PvCPU
fallos_pvp:     .word 0
juego_terminado:.word 0

.text
.globl sumar_puntos
.globl resetear_puntos

# sumar_puntos($a0 = jugador (1 o 2), $a1 = puntos_a_sumar)
sumar_puntos:
    li   $t0, 1
    beq  $a0, $t0, sp_j1
    la   $t1, puntos_j2
    lw   $t2, 0($t1)
    add  $t2, $t2, $a1
    sw   $t2, 0($t1)
    jr   $ra
sp_j1:
    la   $t1, puntos_j1
    lw   $t2, 0($t1)
    add  $t2, $t2, $a1
    sw   $t2, 0($t1)
    jr   $ra

# resetear_puntos()
resetear_puntos:
    sw   $zero, puntos_j1
    sw   $zero, puntos_j2
    sw   $zero, fallos_pvp
    sw   $zero, juego_terminado
    li   $t0, 1
    sw   $t0, turno_actual
    jr   $ra