# BattleShip (Batalla Naval) - MIPS R2000 (MARS 4.5)
# Bitmap Display: Unit 16x16 px, Display 256x512 px, Base 0x10010000

# 1. Constantes globales (puestas aquí para evitar el bug de MARS)
.eqv COLOR_AGUA_1   0x0087CEEB      
.eqv COLOR_AGUA_2   0x0000BFFF      
.eqv COLOR_ARENA    0x00E6C280      
.eqv COLOR_BARCO    0x008B4513      
.eqv COLOR_IMPACTO  0x00000000      
.eqv COLOR_FALLO    0x00003399      
.eqv COLOR_HUNDIDO  0x00808080      
.eqv COLOR_CURSOR_1 0x00F5F5F5      
.eqv COLOR_CURSOR_2 0x00D3D3D3      

.eqv ANCHO_GRID      16             
.eqv ALTO_TOTAL      32             
.eqv CELDAS_TABLERO  256            
.eqv CELDAS_PANTALLA 512            

.eqv Y_ATK_MIN      0
.eqv Y_ATK_MAX      15
.eqv Y_DEF_MIN      16
.eqv Y_DEF_MAX      31
.eqv LIMITES_ATAQUE 0x000E010E      

.eqv CELDA_AGUA     0
.eqv CELDA_BARCO    1
.eqv CELDA_IMPACTO  2
.eqv CELDA_FALLO    3
.eqv CELDA_HUNDIDO  4               

.eqv ORIENT_HORIZ   0
.eqv ORIENT_VERT    1

.eqv TECLA_ENTER    10
.eqv TECLA_E        69
.eqv TECLA_R        82
.eqv TECLA_W        87
.eqv TECLA_S        83
.eqv TECLA_A        65
.eqv TECLA_D        68

# 2. Punto de entrada (Main al inicio absoluto)
.text
.globl main
main:
    li   $v0, 4
    la   $a0, msg_banner
    syscall

    # El motor de juego maneja todo
    jal  jugar_battleship

    li   $v0, 10                    # Terminar ejecucion
    syscall

# 3. Submodulos del proyecto (incluidos DESPUÉS del main)
.include "vista/display_buffer.asm"
.include "modelo/tableros.asm"
.include "modelo/flota.asm"
.include "modelo/puntuacion.asm"
.include "vista/mensajes.asm"

.include "vista/render_tablero.asm"
.include "modelo/tableros_ops.asm"
.include "modelo/validacion_flota.asm"
.include "controlador/teclado.asm"
.include "controlador/cursor.asm"
.include "controlador/colocacion_flota.asm"
.include "controlador/comodines.asm"
.include "controlador/combate_demo.asm"
.include "controlador/cpu_ia.asm"
.include "controlador/motor_juego.asm"