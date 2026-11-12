# ==============================================================================
# PROYECTO: BattleShip (Batalla Naval) - Arquitectura MVC en MIPS R2000 (MARS 4.5)
# PUNTO DE ENTRADA: main.asm
# ==============================================================================
# CONFIGURACION OBLIGATORIA DEL BITMAP DISPLAY EN MARS 4.5:
#   - Unit Width / Height in Pixels: 16
#   - Display Width / Height:        256 x 512 px (16 columnas x 32 filas)
#   - Base address for display:      0x10010000 (static data)
#
# ORDEN CRITICO DE ENSAMBLADO (.include):
#   1) config/constantes.asm   -> constantes simbolicas (.eqv)
#   2) vista/display_buffer.asm-> PRIMERA directiva en .data (0x10010000)
#   3) modelo/*.asm (.data)    -> matrices logicas y flota (despues de 2048 B)
#   4) vista/mensajes.asm      -> cadenas de texto (.asciiz)
#   5) main: en .text          -> primera instruccion ejecutable en 0x00400000
#   6) submodulos MVC (.text)  -> Vista, Modelo y Controlador desacoplados
# ==============================================================================

# 1. Configuracion Global (.eqv)
.include "config/constantes.asm"

# 2. Segmento .data (RESPETAR ESTE ORDEN: display_buffer SIEMPRE PRIMERO)
.include "vista/display_buffer.asm"
.include "modelo/tableros.asm"
.include "modelo/flota.asm"
.include "vista/mensajes.asm"

# 3. Segmento .text (main al inicio para ejecutar con o sin 'Start at main')
.text
.globl main
main:
    li   $v0, 4
    la   $a0, msg_banner
    syscall

    # Modelo: inicializar tablero enemigo demo y limpiar matrices de jugador
    jal  inicializar_demo_tableros

    # Vista: pintar toda la pantalla 16x32 en Azul (Agua)
    jal  limpiar_pantalla_agua

    # Controlador (Integrante 2): colocacion manual de los 4 barcos (Y=16..31)
    jal  colocar_flota_manual

    # Controlador (Demo Integrante 2 / Hook Integrante 3): ataque y comodines
    jal  ejecutar_demo_ataque

    li   $v0, 10                    # Fin de programa
    syscall

# 4. Modulos MVC (.text)
.include "vista/render_tablero.asm"
.include "modelo/tableros_ops.asm"
.include "modelo/validacion_flota.asm"
.include "controlador/teclado.asm"
.include "controlador/cursor.asm"
.include "controlador/colocacion_flota.asm"
.include "controlador/comodines.asm"
.include "controlador/combate_demo.asm"
