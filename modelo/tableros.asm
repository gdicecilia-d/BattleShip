# Matrices logicas de 16x16 casillas (256 bytes c/u, 1 byte por celda)
# Valores: 0=Agua, 1=Barco intacto, 2=Impacto, 3=Fallo

.data
.align 2                            # Alineacion de palabra (inicia en 0x10010800)
.globl tablero_defensa
tablero_defensa:    .space 256      # Tablero inferior (Y_pantalla 16..31)

.globl tablero_ataque
tablero_ataque:     .space 256      # Tablero superior visible (Y_pantalla 0..15)

.globl tablero_enemigo
tablero_enemigo:    .space 256      # Posicion real de la flota enemiga (Y_pantalla 0..15)
