# ==============================================================================
# MODELO (DATOS): tableros.asm
# Descripcion:
#   Matrices logicas separadas del display_buffer visual. Cada matriz ocupa
#   16 x 16 = 256 bytes (1 byte por celda): 0=Agua, 1=Barco, 2=Impacto, 3=Fallo.
# ==============================================================================

.data
.align 2                            # Garantiza inicio en frontera de palabra (0x10010800)
.globl tablero_defensa
tablero_defensa:    .space 256      # Flota propia (mapeada a Y_pantalla 16..31)

.globl tablero_ataque
tablero_ataque:     .space 256      # Disparos visibles del jugador (Y_pantalla 0..15)

.globl tablero_enemigo
tablero_enemigo:    .space 256      # Flota enemiga (Integrante 1 la genera / demo la llena)
