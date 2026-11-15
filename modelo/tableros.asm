# Matrices logicas de 16x16 casillas (256 bytes c/u, 1 byte por celda)
# Valores: 0=Agua, 1=Barco intacto, 2=Impacto, 3=Fallo, 4=Hundido

.data
.align 2                            # Alineacion de palabra (inicia en 0x10010800)
.globl tablero_defensa
tablero_defensa:    .space 256      # Flota del J1 (o defensa en PvCPU)

.globl tablero_ataque
tablero_ataque:     .space 256      # Disparos de J1 contra J2/CPU

.globl tablero_enemigo
tablero_enemigo:    .space 256      # Flota del J2 (o CPU)

.globl tablero_ataque_j2
tablero_ataque_j2:  .space 256      # Disparos de J2 contra J1 (solo PvP)