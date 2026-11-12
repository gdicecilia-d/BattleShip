# BattleShip (Batalla Naval) - MIPS R2000 (MARS 4.5)
# Bitmap Display: Unit 16x16 px, Display 256x512 px, Base 0x10010000

# Constantes globales (.eqv)
.include "config/constantes.asm"

# Segmento .data (display_buffer debe ir primero en 0x10010000)
.include "vista/display_buffer.asm"
.include "modelo/tableros.asm"
.include "modelo/flota.asm"
.include "vista/mensajes.asm"

# Segmento .text (main al inicio en 0x00400000)
.text
.globl main
main:
    li   $v0, 4
    la   $a0, msg_banner
    syscall

    # Inicializar tableros logicos y limpiar pantalla en azul
    jal  inicializar_demo_tableros
    jal  limpiar_pantalla_agua

    # Fase 1: colocacion manual de los 4 barcos en la zona inferior (Y=16..31)
    jal  colocar_flota_manual

    # Fase 2: seleccion de objetivo en zona superior (Y=0..15) y comodines
    jal  ejecutar_demo_ataque

    li   $v0, 10                    # Terminar ejecucion
    syscall

# Submodulos del proyecto
.include "vista/render_tablero.asm"
.include "modelo/tableros_ops.asm"
.include "modelo/validacion_flota.asm"
.include "controlador/teclado.asm"
.include "controlador/cursor.asm"
.include "controlador/colocacion_flota.asm"
.include "controlador/comodines.asm"
.include "controlador/combate_demo.asm"
