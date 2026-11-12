# ==============================================================================
# PROYECTO: BattleShip (Batalla Naval) - Arquitectura MIPS R2000 (MARS 4.5)
# MODULO:   Integrante 2 - Controles, Colocacion Manual de Barcos y Comodines
# ==============================================================================
# CONFIGURACION OBLIGATORIA DEL BITMAP DISPLAY EN MARS 4.5:
#   - Unit Width in Pixels:    16
#   - Unit Height in Pixels:   16
#   - Display Width in Pixels: 256   (256 / 16 = 16 columnas: X de 0 a 15)
#   - Display Height in Pixels:512   (512 / 16 = 32 filas:    Y de 0 a 31)
#   - Base address for display:0x10010000 (static data)
#
# DIVISION LOGICA DEL TABLERO (16 x 32):
#   - Mitad Superior (Y in [0, 15],  X in [0, 15]): Tablero de Ataque / Objetivos
#   - Mitad Inferior (Y in [16, 31], X in [0, 15]): Tablero de Defensa (Flota propia)
#
# FORMULA DE DIRECCIONAMIENTO EN MEMORIA DE VIDEO:
#   Dir(X, Y) = Base(0x10010000) + (Y * 16 + X) * 4
#             = Base + ((Y << 4) + X) << 2
# ==============================================================================

.data
# ------------------------------------------------------------------------------
# 1. BUFFER VISUAL DEL BITMAP DISPLAY (PRIMERA DIRECTIVA OBLIGATORIA EN .data)
#    Inicia exactamente en 0x10010000. Ocupa 16 * 32 * 4 = 2048 bytes
#    (0x10010000 hasta 0x100107FF). Ninguna variable debe ir antes.
# ------------------------------------------------------------------------------
.globl display_buffer
display_buffer:     .space 2048

# ------------------------------------------------------------------------------
# 2. MATRICES LOGICAS EN MEMORIA (SEPARADAS DEL BUFFER VISUAL)
#    Cada matriz almacena 16 x 16 = 256 casillas (1 byte por casilla).
#    Codificacion de estado por casilla:
#      0 = Agua / Desconocido
#      1 = Barco colocado intacto
#      2 = Impacto (tocado)
#      3 = Fallo (agua disparada)
# ------------------------------------------------------------------------------
.align 2                            # Garantiza alineacion de palabra (0x10010800)
.globl tablero_defensa
tablero_defensa:    .space 256      # Defensa del jugador (pantalla Y = 16..31)
.globl tablero_ataque
tablero_ataque:     .space 256      # Registro de ataque del jugador (Y = 0..15)
.globl tablero_enemigo
tablero_enemigo:    .space 256      # Flota enemiga de prueba autonoma (Y = 0..15)

# ------------------------------------------------------------------------------
# 3. TABLAS DE CONFIGURACION DE FLOTA (ALINEADAS A PALABRA)
# ------------------------------------------------------------------------------
.align 2
longitudes_flota:   .word 5, 4, 3, 2
nombres_flota:      .word str_portaaviones, str_acorazado, str_submarino, str_fragata

# ------------------------------------------------------------------------------
# 4. CADENAS DE CONSOLA (AL FINAL DE .data PARA EVITAR DESALINEAR .word)
# ------------------------------------------------------------------------------
str_portaaviones:   .asciiz "Portaaviones (5)"
str_acorazado:      .asciiz "Acorazado (4)"
str_submarino:      .asciiz "Submarino (3)"
str_fragata:        .asciiz "Fragata (2)"

msg_banner:         .asciiz "=== BATTLESHIP MIPS - MODULO INTEGRANTE 2 ===\nBitmap Display: 16x16 unit, 256x512 px, Base 0x10010000\n"
msg_fase_def:       .asciiz "\n--- FASE 1: COLOCACION MANUAL DE FLOTA (Zona inferior Y=16..31) ---\nControles: W/A/S/D mover | R rotar | E o Enter confirmar\n"
msg_colocando:      .asciiz "\nColocando: "
msg_pos:            .asciiz " | Pos=("
msg_coma:           .asciiz ","
msg_orient_h:       .asciiz ") | Orient=Horizontal | Tecla> "
msg_orient_v:       .asciiz ") | Orient=Vertical   | Tecla> "
msg_ok_barco:       .asciiz "\n[OK] Barco colocado correctamente.\n"
msg_err_limites:    .asciiz "\n[ERROR] Posicion invalida: el barco excede los limites del tablero (16x16 inferior).\n"
msg_err_colision:   .asciiz "\n[ERROR] Colision detectada: ya hay otro barco en esas casillas.\n"
msg_flota_lista:    .asciiz "\n[LISTO] Los 4 barcos han sido desplegados en el tablero de defensa.\n"

msg_fase_atk:       .asciiz "\n--- FASE 2: DEMO DE CURSOR DE ATAQUE Y COMODINES (Zona superior Y=0..15) ---\n"
msg_atk_prompt:     .asciiz "\n[ATAQUE] Cursor=("
msg_atk_tecla:      .asciiz ") | W/A/S/D mover | E/Enter disparar> "
msg_radar_on:       .asciiz "\n[COMODIN RADAR 5%] Barco enemigo detectado temporalmente en ("
msg_radar_fin:      .asciiz ") para este turno!\n"
msg_area_on:        .asciiz "\n[COMODIN AREA 3x3 (1/7)] Bombardeo en area centrado en ("
msg_area_hits:      .asciiz ") -> Nuevos impactos: "
msg_tiro_hit:       .asciiz "\n[DISPARO] IMPACTO en ("
msg_tiro_miss:      .asciiz "\n[DISPARO] Agua / Fallo en ("
msg_tiro_dup:       .asciiz "\n[AVISO] Casilla ya atacada anteriormente en ("
msg_cierre_par:     .asciiz ")\n"
msg_victoria:       .asciiz "\n=== DEMO COMPLETADA: Toda la flota enemiga de prueba fue hundida! ===\n"
msg_nl:             .asciiz "\n"

# ==============================================================================
# CONSTANTES SIMBOLICAS (.eqv) - NO OCUPAN ESPACIO EN RAM
# ==============================================================================
.eqv COLOR_AGUA     0x000000FF      # Azul
.eqv COLOR_BARCO    0x00808080      # Gris
.eqv COLOR_IMPACTO  0x00FF0000      # Rojo
.eqv COLOR_FALLO    0x00FFFFFF      # Blanco
.eqv COLOR_CURSOR   0x00FFFF00      # Amarillo

.eqv ANCHO_GRID     16              # Columnas X: 0..15
.eqv ALTO_TOTAL     32              # Filas pantalla Y: 0..31
.eqv Y_DEF_MIN      16              # Inicio tablero defensa
.eqv Y_DEF_MAX      31              # Fin tablero defensa
.eqv Y_ATK_MIN      0               # Inicio tablero ataque
.eqv Y_ATK_MAX      15              # Fin tablero ataque
.eqv LIMITES_ATAQUE 0x000F000F      # (x_max=15 << 16) | (y_min=0 << 8) | y_max=15

.text
.globl main
.globl dibujar_celda
.globl leer_tecla
.globl mover_cursor
.globl mover_cursor_ataque
.globl validar_posicion_barco
.globl colocar_flota_manual
.globl intentar_comodin_radar
.globl intentar_comodin_area
.globl ejecutar_comodin

# ==============================================================================
# PUNTO DE ENTRADA AUTONOMO (MAIN) PARA PRUEBAS INDEPENDIENTES EN MARS 4.5
# Permite verificar:
#   1) Dibujo del tablero 16x32 en Bitmap Display (0x10010000)
#   2) Colocacion manual de los 4 barcos con preview amarillo y validaciones
#   3) Movimiento de cursor en zona de ataque y activacion de ambos comodines
# ==============================================================================
main:
    # Imprimir encabezado inicial en consola
    li   $v0, 4
    la   $a0, msg_banner
    syscall

    # Inicializar el tablero de prueba enemigo y limpiar matrices de jugador
    jal  inicializar_demo_tableros

    # Pintar toda la pantalla (16x32) de Azul (Agua)
    jal  limpiar_pantalla_agua

    # --------------------------------------------------------------------------
    # FASE 1: Colocacion manual de los 4 barcos en la mitad inferior (Y=16..31)
    # --------------------------------------------------------------------------
    jal  colocar_flota_manual

    # --------------------------------------------------------------------------
    # FASE 2: Ciclo de ataque autonomo para probar cursor + radar + area 3x3
    # --------------------------------------------------------------------------
    li   $v0, 4
    la   $a0, msg_fase_atk
    syscall

    li   $s0, 0                     # $s0 = cursor X inicial en ataque (0..15)
    li   $s1, 0                     # $s1 = cursor Y inicial en ataque (0..15)

bucle_demo_ataque:
    # 1. Al inicio del turno intentar comodin Radar (5% de probabilidad)
    la   $a0, tablero_enemigo       # $a0 = matriz de barcos enemigos
    la   $a1, tablero_ataque        # $a1 = matriz de disparos ya realizados
    jal  intentar_comodin_radar
    move $s2, $v1                   # $s2 = indice revelado (-1 si no se activo)

    # 2. Permitir mover cursor de ataque (W/A/S/D) y confirmar (E/Enter)
    move $a0, $s0                   # $a0 = X actual del cursor
    move $a1, $s1                   # $a1 = Y actual del cursor
    la   $a2, tablero_ataque        # $a2 = matriz visual de ataques previos
    move $a3, $s2                   # $a3 = indice temporal de radar (-1 o 0..255)
    jal  mover_cursor_ataque
    move $s0, $v0                   # Actualizar X seleccionada
    move $s1, $v1                   # Actualizar Y seleccionada

    # 3. Al confirmar disparo, intentar comodin Ataque 3x3 (probabilidad 1 en 7)
    move $a0, $s0                   # $a0 = X centro del disparo
    move $a1, $s1                   # $a1 = Y centro del disparo
    la   $a2, tablero_enemigo       # $a2 = matriz enemiga
    la   $a3, tablero_ataque        # $a3 = matriz de ataque
    jal  intentar_comodin_area
    bnez $v0, fin_turno_ataque      # Si $v0 == 1, el ataque 3x3 ya resolvio el turno

    # 4. Si no salio comodin 3x3, procesar disparo normal de 1 sola casilla
    move $a0, $s0
    move $a1, $s1
    la   $a2, tablero_enemigo
    la   $a3, tablero_ataque
    jal  procesar_disparo_simple

fin_turno_ataque:
    # Redibujar tablero superior sin el destello temporal del radar (radar_idx = -1)
    la   $a0, tablero_ataque
    li   $a1, 0                     # Offset Y en pantalla = 0 (zona superior)
    li   $a2, -1                    # Desactivar revelacion temporal del turno
    jal  dibujar_tablero_base

    # Verificar si quedan casillas de barco enemigo sin impactar
    la   $a0, tablero_enemigo
    jal  contar_barcos_restantes
    bgtz $v0, bucle_demo_ataque     # Si aun quedan casillas (> 0), otro turno

    # Fin exitoso de la demo autonoma
    li   $v0, 4
    la   $a0, msg_victoria
    syscall

    li   $v0, 10                    # Syscall 10: terminar ejecucion en MARS
    syscall


# ==============================================================================
# SUBRUTINA: dibujar_celda
# Descripcion:
#   Pinta un pixel logico (unidad de 16x16 px en Bitmap Display) en (X, Y)
#   calculando: Direccion = display_buffer + ((Y * 16) + X) * 4.
#   Incluye guarda de limites para evitar corromper variables tras display_buffer.
# Argumentos:
#   $a0 = Coordenada X (0..15)
#   $a1 = Coordenada Y (0..31 en pantalla completa)
#   $a2 = Color RGB de 32 bits (ej. 0x0000FF, 0x808080, 0xFF0000, 0xFFFFFF, 0xFFFF00)
# Retorno:
#   Ninguno. (Subrutina hoja: no modifica $ra ni $s0-$s7)
# ==============================================================================
dibujar_celda:
    # Validacion defensiva de limites: 0 <= X < 16 y 0 <= Y < 32
    bltz $a0, dc_fuera_rango        # Si X < 0, abortar escritura
    li   $t0, ANCHO_GRID            # $t0 = 16
    bge  $a0, $t0, dc_fuera_rango   # Si X >= 16, abortar escritura
    bltz $a1, dc_fuera_rango        # Si Y < 0, abortar escritura
    li   $t0, ALTO_TOTAL            # $t0 = 32
    bge  $a1, $t0, dc_fuera_rango   # Si Y >= 32, abortar escritura

    # Calculo de direccion: Base + ((Y * 16) + X) * 4
    sll  $t0, $a1, 4                # $t0 = Y * 16 (desplazar 4 bits a la izquierda)
    add  $t0, $t0, $a0              # $t0 = (Y * 16) + X (indice lineal 0..511)
    sll  $t0, $t0, 2                # $t0 = ((Y * 16) + X) * 4 (offset en bytes)
    la   $t1, display_buffer        # $t1 = direccion base 0x10010000
    add  $t1, $t1, $t0              # $t1 = Base + offset exacto en bytes
    sw   $a2, 0($t1)                # Escribir palabra de color en el Bitmap Display

dc_fuera_rango:
    jr   $ra                        # Retornar al invocador


# ==============================================================================
# SUBRUTINA: leer_tecla
# Descripcion:
#   Captura una tecla de control desde MARS usando syscall 12 (ReadChar).
#   Normaliza minusculas ('a'..'z') a mayusculas ('A'..'Z') e ignora cualquier
#   caracter residual o no valido (ej. '\r'=13, espacios, letras fuera de control)
#   repitiendo la lectura hasta recibir una tecla valida.
#   NOTA SOBRE MMIO ALTERNATIVO:
#     Si el equipo decide usar Keyboard MMIO (0xFFFF0000/0xFFFF0004), basta
#     reemplazar la secuencia de syscall 12 por el bucle de polling:
#       lui  $t8, 0xFFFF
#     wait_mmio:
#       lw   $t9, 0($t8)          # Leer Receiver Control (bit 0 = Ready)
#       andi $t9, $t9, 1
#       beqz $t9, wait_mmio
#       lw   $v0, 4($t8)          # Leer Receiver Data (ASCII) y limpiar Ready
# Argumentos:
#   Ninguno.
# Retorno:
#   $v0 = Codigo ASCII valido:
#         'W'(87), 'S'(83), 'A'(65), 'D'(68), 'R'(82), 'E'(69) o Enter(10).
# ==============================================================================
leer_tecla:
lt_bucle:
    li   $v0, 12                    # Syscall 12: leer un caracter ASCII desde consola
    syscall                         # Caracter leido queda en $v0

    # Aceptar Enter ('\n' = ASCII 10) directamente como confirmacion
    li   $t0, 10
    beq  $v0, $t0, lt_valida

    # Si es minuscula ASCII ('a'=97 .. 'z'=122), convertir a mayuscula (-32)
    li   $t0, 97                    # 'a'
    blt  $v0, $t0, lt_verificar_ctrl
    li   $t0, 122                   # 'z'
    bgt  $v0, $t0, lt_bucle         # Mayor a 'z': caracter invalido, ignorar
    addi $v0, $v0, -32              # Convertir a mayuscula ('A'..'Z')

lt_verificar_ctrl:
    li   $t0, 87                    # 'W'
    beq  $v0, $t0, lt_valida
    li   $t0, 83                    # 'S'
    beq  $v0, $t0, lt_valida
    li   $t0, 65                    # 'A'
    beq  $v0, $t0, lt_valida
    li   $t0, 68                    # 'D'
    beq  $v0, $t0, lt_valida
    li   $t0, 82                    # 'R'
    beq  $v0, $t0, lt_valida
    li   $t0, 69                    # 'E'
    beq  $v0, $t0, lt_valida

    # Cualquier otro caracter (ej. '\r'=13, espacio=32, etc.) se descarta
    j    lt_bucle

lt_valida:
    jr   $ra                        # Retornar tecla valida en $v0


# ==============================================================================
# SUBRUTINA: mover_cursor
# Descripcion:
#   Subrutina reutilizable para desplazar un cursor (X, Y) un paso segun WASD,
#   garantizando que nunca salga de los limites especificados en $a3.
#   Soporta tanto mayusculas como minusculas en ASCII.
# Argumentos:
#   $a0 = X actual
#   $a1 = Y actual
#   $a2 = Tecla ASCII ('W'/'w', 'S'/'s', 'A'/'a', 'D'/'d')
#   $a3 = Limites empaquetados: (x_max << 16) | (y_min << 8) | y_max
#         (x_min siempre es 0). Ej. Ataque = 0x000F000F (x_max=15, y=0..15)
# Retorno:
#   $v0 = Nueva coordenada X (clamped dentro de [0, x_max])
#   $v1 = Nueva coordenada Y (clamped dentro de [y_min, y_max])
# ==============================================================================
mover_cursor:
    # Desempaquetar limites desde $a3
    andi $t0, $a3, 0xFF             # $t0 = y_max (bits 0..7)
    srl  $t1, $a3, 8
    andi $t1, $t1, 0xFF             # $t1 = y_min (bits 8..15)
    srl  $t2, $a3, 16
    andi $t2, $t2, 0xFF             # $t2 = x_max (bits 16..23)

    # Inicializar retorno con posicion actual por defecto
    move $v0, $a0                   # $v0 = X
    move $v1, $a1                   # $v1 = Y

    # Normalizar tecla en $t3 a mayuscula si viene en minuscula ('a'..'z')
    move $t3, $a2
    li   $t4, 97
    blt  $t3, $t4, mc_evaluar
    li   $t4, 122
    bgt  $t3, $t4, mc_evaluar
    addi $t3, $t3, -32              # $t3 = tecla en mayuscula

mc_evaluar:
    li   $t4, 87                    # 'W': arriba (Y - 1) si Y > y_min
    beq  $t3, $t4, mc_arriba
    li   $t4, 83                    # 'S': abajo  (Y + 1) si Y < y_max
    beq  $t3, $t4, mc_abajo
    li   $t4, 65                    # 'A': izq.   (X - 1) si X > 0
    beq  $t3, $t4, mc_izquierda
    li   $t4, 68                    # 'D': der.   (X + 1) si X < x_max
    beq  $t3, $t4, mc_derecha
    j    mc_fin                     # Otra tecla: posicion sin cambios

mc_arriba:
    ble  $v1, $t1, mc_fin           # Si Y <= y_min, no subir mas
    addi $v1, $v1, -1               # Y = Y - 1
    j    mc_fin

mc_abajo:
    bge  $v1, $t0, mc_fin           # Si Y >= y_max, no bajar mas
    addi $v1, $v1, 1                # Y = Y + 1
    j    mc_fin

mc_izquierda:
    blez $v0, mc_fin                # Si X <= 0, no ir mas a la izquierda
    addi $v0, $v0, -1               # X = X - 1
    j    mc_fin

mc_derecha:
    bge  $v0, $t2, mc_fin           # Si X >= x_max, no ir mas a la derecha
    addi $v0, $v0, 1                # X = X + 1

mc_fin:
    jr   $ra                        # Retornar ($v0=new_X, $v1=new_Y)


# ==============================================================================
# SUBRUTINA: mover_cursor_ataque
# Descripcion:
#   Bucle interactivo de seleccion de objetivo en la mitad superior (Y=0..15).
#   Redibuja el tablero de ataque y superpone el cursor amarillo (0xFFFF00) en
#   tiempo real en cada pulsacion WASD hasta que el jugador confirme con E o Enter.
# Argumentos:
#   $a0 = X inicial del cursor (0..15)
#   $a1 = Y inicial del cursor (0..15)
#   $a2 = Direccion base de la matriz tablero_ataque (256 bytes)
#   $a3 = Indice lineal (0..255) revelado por comodin radar, o -1 si inactivo
# Retorno:
#   $v0 = X objetivo confirmada (0..15)
#   $v1 = Y objetivo confirmada (0..15)
# ==============================================================================
mover_cursor_ataque:
    # Prologo: preservar $ra y $s0-$s3 en la pila (20 bytes)
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   # $s0 = X actual
    move $s1, $a1                   # $s1 = Y actual
    move $s2, $a2                   # $s2 = base tablero_ataque
    move $s3, $a3                   # $s3 = radar_idx (-1 o 0..255)

    # Asegurar coordenadas iniciales dentro de [0, 15] x [0, 15]
    bltz $s0, mca_clamp_x0
    li   $t0, 15
    ble  $s0, $t0, mca_check_y
    li   $s0, 15
    j    mca_check_y
mca_clamp_x0:
    li   $s0, 0

mca_check_y:
    bltz $s1, mca_clamp_y0
    li   $t0, 15
    ble  $s1, $t0, mca_bucle
    li   $s1, 15
    j    mca_bucle
mca_clamp_y0:
    li   $s1, 0

mca_bucle:
    # 1. Redibujar tablero de ataque desde memoria logica (+ posible radar gris)
    move $a0, $s2
    li   $a1, 0                     # Mitad superior: Y pantalla = Y_local + 0
    move $a2, $s3                   # Mantener visible la pista del radar este turno
    jal  dibujar_tablero_base

    # 2. Superponer cursor amarillo en (X, Y)
    move $a0, $s0
    move $a1, $s1
    li   $a2, COLOR_CURSOR
    jal  dibujar_celda

    # 3. Mostrar estado del cursor en consola
    li   $v0, 4                     # Servicio 4: imprimir cadena
    la   $a0, msg_atk_prompt
    syscall
    move $a0, $s0                   # $a0 = X actual del cursor
    move $a1, $s1                   # $a1 = Y actual del cursor
    jal  imprimir_coordenadas       # Imprimir "X,Y" en consola
    li   $v0, 4
    la   $a0, msg_atk_tecla
    syscall

    # 4. Capturar tecla del jugador
    jal  leer_tecla

    # Confirmar disparo con 'E'(69) o Enter(10)
    li   $t0, 69
    beq  $v0, $t0, mca_confirmar
    li   $t0, 10
    beq  $v0, $t0, mca_confirmar

    # Ignorar 'R'(82) durante fase de ataque
    li   $t0, 82
    beq  $v0, $t0, mca_bucle

    # Mover cursor restringido a X in [0,15], Y in [0,15]
    move $a0, $s0
    move $a1, $s1
    move $a2, $v0                   # Tecla W/A/S/D
    li   $a3, LIMITES_ATAQUE        # x_max=15, y_min=0, y_max=15
    jal  mover_cursor
    move $s0, $v0                   # Actualizar X
    move $s1, $v1                   # Actualizar Y
    j    mca_bucle

mca_confirmar:
    move $v0, $s0                   # Retornar X seleccionada
    move $v1, $s1                   # Retornar Y seleccionada

    # Epilogo: restaurar registros guardados y liberar pila
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20
    jr   $ra


# ==============================================================================
# SUBRUTINA: validar_posicion_barco
# Descripcion:
#   Verifica que un barco de longitud L en posicion inicial (X, Y) y orientacion
#   O quepa integramente en la zona de defensa (X in [0,15], Y in [16,31]) y que
#   ninguna de sus casillas colisione con barcos ya guardados en tablero_defensa.
# Argumentos:
#   $a0 = X inicial (0..15)
#   $a1 = Y inicial en pantalla (16..31)
#   $a2 = Longitud del barco (2..5)
#   $a3 = Orientacion (0 = Horizontal, 1 = Vertical)
# Retorno:
#   $v0 = 1 si la posicion es valida; 0 si es invalida
#   $v1 = Codigo de diagnostico: 0 = Valido, 1 = Fuera de limites, 2 = Colision
# ==============================================================================
validar_posicion_barco:
    # Verificar coordenada base X in [0, 15], Y in [16, 31], longitud > 0
    bltz $a0, vpb_err_limites
    li   $t0, 15
    bgt  $a0, $t0, vpb_err_limites
    li   $t0, Y_DEF_MIN             # 16
    blt  $a1, $t0, vpb_err_limites
    li   $t0, Y_DEF_MAX             # 31
    bgt  $a1, $t0, vpb_err_limites
    blez $a2, vpb_err_limites

    # Validar limite final segun orientacion
    beqz $a3, vpb_check_horiz       # 0 = Horizontal
    li   $t0, 1
    beq  $a3, $t0, vpb_check_vert   # 1 = Vertical
    j    vpb_err_limites            # Orientacion invalida

vpb_check_horiz:
    add  $t0, $a0, $a2              # $t0 = X + longitud
    li   $t1, 16
    bgt  $t0, $t1, vpb_err_limites  # Debe cumplir X + longitud <= 16
    j    vpb_check_colision

vpb_check_vert:
    add  $t0, $a1, $a2              # $t0 = Y + longitud
    li   $t1, 32
    bgt  $t0, $t1, vpb_err_limites  # Debe cumplir Y + longitud <= 32

vpb_check_colision:
    # Recorrer las L casillas del barco en tablero_defensa (Y_local = Y - 16)
    la   $t0, tablero_defensa       # $t0 = base de matriz logica de defensa (16x16)
    addi $t1, $a1, -16              # $t1 = Y_local inicial (0..15)
    move $t2, $a0                   # $t2 = X actual
    li   $t3, 0                     # $t3 = contador de segmento i = 0..L-1

vpb_loop_celdas:
    bge  $t3, $a2, vpb_valido       # Si se verificaron todas las casillas -> valido

    # Calcular desplazamiento en matriz byte 16x16: offset = (Y_local * 16) + X
    sll  $t4, $t1, 4                # $t4 = Y_local << 4 (Y_local * 16)
    add  $t4, $t4, $t2              # $t4 = indice 0..255
    add  $t4, $t0, $t4              # $t4 = direccion exacta en tablero_defensa
    lbu  $t5, 0($t4)                # Leer estado de la casilla
    bnez $t5, vpb_err_colision      # Si != 0, ya existe otro barco ahi

    # Avanzar a la siguiente casilla segun orientacion
    beqz $a3, vpb_step_h
    addi $t1, $t1, 1                # Vertical: Y_local++
    j    vpb_next
vpb_step_h:
    addi $t2, $t2, 1                # Horizontal: X++
vpb_next:
    addi $t3, $t3, 1                # i++
    j    vpb_loop_celdas

vpb_valido:
    li   $v0, 1
    li   $v1, 0
    jr   $ra

vpb_err_limites:
    li   $v0, 0
    li   $v1, 1
    jr   $ra

vpb_err_colision:
    li   $v0, 0
    li   $v1, 2
    jr   $ra


# ==============================================================================
# SUBRUTINA: colocar_flota_manual
# Descripcion:
#   Gestiona el despliegue secuencial de los 4 barcos del jugador en el tablero
#   de defensa (mitad inferior Y=16..31):
#     1. Portaaviones (5), 2. Acorazado (4), 3. Submarino (3), 4. Fragata (2).
#   Dibuja en tiempo real el sombreado amarillo (0xFFFF00) sobre el tablero de
#   defensa, permite mover (WASD) y rotar (R) evitando salir de los bordes, y al
#   confirmar (E/Enter) valida posicion/colision y guarda el barco en Gris.
# Argumentos:
#   Ninguno (opera sobre la matriz global tablero_defensa).
# Retorno:
#   Ninguno. (Al terminar, tablero_defensa contiene los 4 barcos colocados).
# ==============================================================================
colocar_flota_manual:
    # Prologo: preservar $ra y $s0-$s6 en la pila (32 bytes)
    addi $sp, $sp, -32
    sw   $ra, 28($sp)
    sw   $s6, 24($sp)
    sw   $s5, 20($sp)
    sw   $s4, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    # Limpiar tablero_defensa antes de iniciar colocacion
    la   $s0, tablero_defensa
    move $a0, $s0
    jal  limpiar_matriz_256

    li   $v0, 4
    la   $a0, msg_fase_def
    syscall

    li   $s1, 0                     # $s1 = indice del barco actual (0..3)

cfm_loop_barcos:
    li   $t0, 4
    bge  $s1, $t0, cfm_flota_ok     # Si ya se colocaron los 4 barcos, finalizar

    # Cargar longitud y puntero al nombre del barco actual desde las tablas
    sll  $t0, $s1, 2                # $t0 = ship_idx * 4 (offset en palabras)
    la   $t1, longitudes_flota
    add  $t1, $t1, $t0
    lw   $s2, 0($t1)                # $s2 = longitud del barco actual (5, 4, 3 o 2)

    la   $t1, nombres_flota
    add  $t1, $t1, $t0
    lw   $s6, 0($t1)                # $s6 = direccion del nombre del barco

    # Posicion y orientacion inicial para cada nuevo barco
    li   $s3, 0                     # $s3 = X actual (0..15)
    li   $s4, Y_DEF_MIN             # $s4 = Y actual en pantalla (16..31)
    li   $s5, 0                     # $s5 = orientacion (0 = Horizontal, 1 = Vertical)

cfm_loop_preview:
    # 1. Redibujar tablero de defensa logico (Agua azul / Barcos ya fijos en gris)
    move $a0, $s0                   # tablero_defensa
    li   $a1, Y_DEF_MIN             # Offset Y = 16
    li   $a2, -1                    # Sin mascara de radar
    jal  dibujar_tablero_base

    # 2. Superponer silueta tentativa del barco actual en Amarillo (0xFFFF00)
    move $a0, $s3                   # X
    move $a1, $s4                   # Y
    move $a2, $s2                   # longitud
    move $a3, $s5                   # orientacion
    jal  dibujar_preview_barco

    # 3. Imprimir estado actual al jugador en consola
    li   $v0, 4
    la   $a0, msg_colocando
    syscall
    li   $v0, 4
    move $a0, $s6
    syscall
    li   $v0, 4
    la   $a0, msg_pos
    syscall
    move $a0, $s3                   # $a0 = X actual del barco
    move $a1, $s4                   # $a1 = Y actual del barco
    jal  imprimir_coordenadas       # Imprimir "X,Y" en consola
    beqz $s5, cfm_print_h
    li   $v0, 4
    la   $a0, msg_orient_v
    syscall
    j    cfm_leer
cfm_print_h:
    li   $v0, 4
    la   $a0, msg_orient_h
    syscall

cfm_leer:
    # 4. Capturar tecla del usuario
    jal  leer_tecla

    # Caso A: Rotar ('R' = 82)
    li   $t0, 82
    beq  $v0, $t0, cfm_rotar

    # Caso B: Confirmar colocacion ('E' = 69 o Enter = 10)
    li   $t0, 69
    beq  $v0, $t0, cfm_confirmar
    li   $t0, 10
    beq  $v0, $t0, cfm_confirmar

    # Caso C: Mover cursor con WASD manteniendo silueta dentro del 16x16 inferior
    beqz $s5, cfm_limites_h
    # Limites en Vertical: x_max = 15, y_min = 16, y_max = 32 - longitud
    li   $t1, 15                    # x_max
    li   $t2, 32
    sub  $t2, $t2, $s2              # y_max = 32 - longitud
    j    cfm_empaquetar_lim
cfm_limites_h:
    # Limites en Horizontal: x_max = 16 - longitud, y_min = 16, y_max = 31
    li   $t1, 16
    sub  $t1, $t1, $s2              # x_max = 16 - longitud
    li   $t2, Y_DEF_MAX             # y_max = 31

cfm_empaquetar_lim:
    sll  $a3, $t1, 16               # (x_max << 16)
    li   $t3, Y_DEF_MIN             # y_min = 16
    sll  $t3, $t3, 8                # (y_min << 8)
    or   $a3, $a3, $t3
    or   $a3, $a3, $t2              # | y_max

    move $a0, $s3                   # X actual
    move $a1, $s4                   # Y actual
    move $a2, $v0                   # tecla WASD
    jal  mover_cursor
    move $s3, $v0                   # Actualizar X
    move $s4, $v1                   # Actualizar Y
    j    cfm_loop_preview

cfm_rotar:
    xori $s5, $s5, 1                # Alternar orientacion 0 <-> 1
    # Ajustar coordenadas si la nueva orientacion hiciese sobresalir al barco
    beqz $s5, cfm_clamp_rot_h
    # Nueva orientacion = Vertical: asegurar Y <= 32 - longitud
    li   $t0, 32
    sub  $t0, $t0, $s2              # $t0 = max_y
    ble  $s4, $t0, cfm_loop_preview
    move $s4, $t0                   # Ajustar Y hacia arriba para caber
    j    cfm_loop_preview
cfm_clamp_rot_h:
    # Nueva orientacion = Horizontal: asegurar X <= 16 - longitud
    li   $t0, 16
    sub  $t0, $t0, $s2              # $t0 = max_x
    ble  $s3, $t0, cfm_loop_preview
    move $s3, $t0                   # Ajustar X hacia la izquierda para caber
    j    cfm_loop_preview

cfm_confirmar:
    # Validar limites y superposicion contra tablero_defensa
    move $a0, $s3                   # X
    move $a1, $s4                   # Y
    move $a2, $s2                   # longitud
    move $a3, $s5                   # orientacion
    jal  validar_posicion_barco
    bnez $v0, cfm_guardar_barco     # Si $v0 == 1, posicion valida

    # Posicion invalida: mostrar aviso segun $v1 y permanecer en el mismo barco
    li   $t0, 1
    beq  $v1, $t0, cfm_msg_lim
    li   $v0, 4
    la   $a0, msg_err_colision
    syscall
    j    cfm_loop_preview
cfm_msg_lim:
    li   $v0, 4
    la   $a0, msg_err_limites
    syscall
    j    cfm_loop_preview

cfm_guardar_barco:
    # Guardar las L casillas en tablero_defensa (valor = 1) y pintarlas en Gris
    li   $t0, 0                     # i = 0
    move $t1, $s3                   # cx = X
    addi $t2, $s4, -16              # cy_local = Y - 16
cfm_write_loop:
    bge  $t0, $s2, cfm_barco_guardado

    # Escribir 1 en tablero_defensa[(cy_local * 16) + cx]
    sll  $t3, $t2, 4                # cy_local * 16
    add  $t3, $t3, $t1              # indice 0..255
    add  $t3, $s0, $t3              # direccion exacta en tablero_defensa
    li   $t4, 1
    sb   $t4, 0($t3)                # Marcar casilla como ocupada por barco (1)

    # Siguiente segmento segun orientacion
    beqz $s5, cfm_w_h
    addi $t2, $t2, 1                # Vertical: cy_local++
    j    cfm_w_next
cfm_w_h:
    addi $t1, $t1, 1                # Horizontal: cx++
cfm_w_next:
    addi $t0, $t0, 1                # i++
    j    cfm_write_loop

cfm_barco_guardado:
    li   $v0, 4
    la   $a0, msg_ok_barco
    syscall

    addi $s1, $s1, 1                # Pasar al siguiente barco (0 -> 1 -> 2 -> 3)
    j    cfm_loop_barcos

cfm_flota_ok:
    # Redibujar tablero de defensa limpio (todos los barcos en Gris, sin amarillo)
    move $a0, $s0
    li   $a1, Y_DEF_MIN
    li   $a2, -1
    jal  dibujar_tablero_base

    li   $v0, 4
    la   $a0, msg_flota_lista
    syscall

    # Epilogo: restaurar registros guardados y retornar
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $s4, 16($sp)
    lw   $s5, 20($sp)
    lw   $s6, 24($sp)
    lw   $ra, 28($sp)
    addi $sp, $sp, 32
    jr   $ra


# ==============================================================================
# SUBRUTINA: intentar_comodin_radar
# Descripcion:
#   Comodin de inicio de turno (5% de probabilidad). Genera un entero aleatorio
#   en [0, 99] mediante syscall 42 ($a1 = 100). Si $a0 < 5, busca en la matriz
#   enemiga una casilla con barco no impactado (valor == 1) a partir de un indice
#   inicial aleatorio (recorrido circular modulo 256) y la revela temporalmente
#   en Gris (0x808080) en el tablero superior, notificando por consola.
# Argumentos:
#   $a0 = Direccion base de tablero_enemigo (16x16 bytes)
#   $a1 = Direccion base de tablero_ataque (16x16 bytes, opcional; 0 si no aplica)
# Retorno:
#   $v0 = 1 si se activo y revelo una casilla; 0 si no se activo o no hay barcos
#   $v1 = Indice lineal (Y * 16 + X) de la casilla revelada (0..255), o -1 si $v0=0
# ==============================================================================
intentar_comodin_radar:
    # Prologo: preservar $ra y $s0-$s3 (20 bytes)
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   # $s0 = base tablero_enemigo
    move $s1, $a1                   # $s1 = base tablero_ataque

    # Tirada de probabilidad del 5%: random en [0, 99]
    li   $v0, 42
    li   $a0, 0                     # ID del generador PRNG
    li   $a1, 100                   # Limite superior exclusivo -> [0, 99]
    syscall                         # Resultado queda en $a0
    li   $t0, 5
    bge  $a0, $t0, icr_no_activado  # Si $a0 >= 5 (95% casos), no activa radar

    # Elegir punto de partida aleatorio [0, 255] para no revelar siempre el mismo
    li   $v0, 42
    li   $a0, 0
    li   $a1, 256
    syscall
    move $s2, $a0                   # $s2 = start_idx (0..255)
    li   $s3, 0                     # $s3 = k = 0..255

icr_buscar_loop:
    li   $t0, 256
    bge  $s3, $t0, icr_no_activado  # Si recorrio las 256 casillas sin exito -> 0

    add  $t1, $s2, $s3
    andi $t1, $t1, 255              # $t1 = idx = (start + k) % 256

    # Verificar que tablero_enemigo[idx] == 1 (barco no impactado)
    add  $t2, $s0, $t1
    lbu  $t3, 0($t2)
    li   $t4, 1
    bne  $t3, $t4, icr_siguiente

    # Si se paso tablero_ataque ($s1 != 0), confirmar que tablero_ataque[idx] == 0
    beqz $s1, icr_encontrado
    add  $t2, $s1, $t1
    lbu  $t3, 0($t2)
    bnez $t3, icr_siguiente

icr_encontrado:
    # Descomponer indice lineal en coordenadas (X, Y): X = idx & 15, Y = idx >> 4
    andi $s2, $t1, 15               # $s2 = X (0..15)
    srl  $s3, $t1, 4                # $s3 = Y (0..15)
    move $s0, $t1                   # Guardar idx en $s0 para retorno $v1

    # Pintar revelacion temporal en el Bitmap Display superior (Gris 0x808080)
    move $a0, $s2
    move $a1, $s3
    li   $a2, COLOR_BARCO
    jal  dibujar_celda

    # Notificar coordenada detectada por consola
    li   $v0, 4
    la   $a0, msg_radar_on
    syscall
    move $a0, $s2                   # $a0 = X revelada
    move $a1, $s3                   # $a1 = Y revelada
    jal  imprimir_coordenadas       # Imprimir "X,Y" en consola
    li   $v0, 4
    la   $a0, msg_radar_fin
    syscall

    li   $v0, 1                     # Retorno: radar activado
    move $v1, $s0                   # Retorno: idx = Y * 16 + X
    j    icr_epilogo

icr_siguiente:
    addi $s3, $s3, 1                # Avanzar al siguiente desplazamiento k
    j    icr_buscar_loop

icr_no_activado:
    li   $v0, 0
    li   $v1, -1

icr_epilogo:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20
    jr   $ra


# ==============================================================================
# SUBRUTINA: intentar_comodin_area
# Descripcion:
#   Comodin al confirmar disparo (probabilidad 1 en 7). Genera un entero en
#   [0, 6] con syscall 42 ($a1 = 7). Si $a0 == 0, expande el disparo a una
#   cuadricula 3x3 centrada en (X, Y), validando los limites [0, 15] x [0, 15]
#   del tablero de ataque y pintando impactos (Rojo) o fallos (Blanco).
# Argumentos:
#   $a0 = X centro del disparo (0..15)
#   $a1 = Y centro del disparo (0..15)
#   $a2 = Direccion base de tablero_enemigo (16x16 bytes)
#   $a3 = Direccion base de tablero_ataque (16x16 bytes)
# Retorno:
#   $v0 = 1 si se activo el ataque en area 3x3; 0 si no se activo
#   $v1 = Cantidad de nuevos impactos registrados en el area (0 si $v0 == 0)
# ==============================================================================
intentar_comodin_area:
    # Prologo: preservar $ra y $s0-$s6 en la pila (32 bytes)
    addi $sp, $sp, -32
    sw   $ra, 28($sp)
    sw   $s6, 24($sp)
    sw   $s5, 20($sp)
    sw   $s4, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   # $s0 = X centro
    move $s1, $a1                   # $s1 = Y centro
    move $s2, $a2                   # $s2 = base tablero_enemigo
    move $s3, $a3                   # $s3 = base tablero_ataque

    # Tirada de probabilidad 1 en 7: random en [0, 6]
    li   $v0, 42
    li   $a0, 0                     # ID del generador PRNG
    li   $a1, 7                     # Limite superior exclusivo -> [0, 6]
    syscall
    bnez $a0, ica_no_activado       # Si $a0 != 0 (6/7), no se activa

    li   $s4, 0                     # $s4 = contador de nuevos impactos
    li   $s5, -1                    # $s5 = dy (-1, 0, +1)

ica_loop_dy:
    li   $t0, 1
    bgt  $s5, $t0, ica_fin_area     # Terminar tras dy = +1

    add  $t1, $s1, $s5              # $t1 = ny = Y + dy
    bltz $t1, ica_next_dy           # Validar ny >= 0
    li   $t2, Y_ATK_MAX             # 15
    bgt  $t1, $t2, ica_next_dy      # Validar ny <= 15

    li   $s6, -1                    # $s6 = dx (-1, 0, +1)

ica_loop_dx:
    li   $t0, 1
    bgt  $s6, $t0, ica_next_dy      # Terminar fila tras dx = +1

    add  $t3, $s0, $s6              # $t3 = nx = X + dx
    bltz $t3, ica_next_dx           # Validar nx >= 0
    li   $t2, 15
    bgt  $t3, $t2, ica_next_dx      # Validar nx <= 15

    # Calcular indice en matrices 16x16: idx = (ny << 4) + nx
    add  $t1, $s1, $s5              # Recalcular ny en $t1
    sll  $t4, $t1, 4
    add  $t4, $t4, $t3              # $t4 = idx (0..255)

    # Consultar tablero_enemigo[idx]
    add  $t5, $s2, $t4
    lbu  $t6, 0($t5)

    li   $t7, 1
    beq  $t6, $t7, ica_nuevo_hit    # 1 = barco intacto -> nuevo impacto
    li   $t7, 2
    beq  $t6, $t7, ica_ya_hit       # 2 = ya impactado -> mantener rojo

    # Agua (0) o fallo previo (3) -> marcar como fallo (3) y pintar Blanco
    li   $t7, 3
    sb   $t7, 0($t5)                # tablero_enemigo[idx] = 3
    beqz $s3, ica_draw_miss
    add  $t8, $s3, $t4
    sb   $t7, 0($t8)                # tablero_ataque[idx] = 3
ica_draw_miss:
    move $a0, $t3                   # nx
    move $a1, $t1                   # ny
    li   $a2, COLOR_FALLO           # Blanco (0xFFFFFF)
    jal  dibujar_celda
    j    ica_next_dx

ica_nuevo_hit:
    addi $s4, $s4, 1                # Incrementar contador de nuevos impactos
ica_ya_hit:
    li   $t7, 2
    sb   $t7, 0($t5)                # tablero_enemigo[idx] = 2 (impacto)
    beqz $s3, ica_draw_hit
    add  $t8, $s3, $t4
    sb   $t7, 0($t8)                # tablero_ataque[idx] = 2 (impacto)
ica_draw_hit:
    move $a0, $t3                   # nx
    move $a1, $t1                   # ny
    li   $a2, COLOR_IMPACTO         # Rojo (0xFF0000)
    jal  dibujar_celda

ica_next_dx:
    addi $s6, $s6, 1
    j    ica_loop_dx

ica_next_dy:
    addi $s5, $s5, 1
    j    ica_loop_dy

ica_fin_area:
    # Imprimir reporte de comodin 3x3 en consola
    li   $v0, 4
    la   $a0, msg_area_on
    syscall
    move $a0, $s0                   # $a0 = X centro
    move $a1, $s1                   # $a1 = Y centro
    jal  imprimir_coordenadas       # Imprimir "X,Y" en consola
    li   $v0, 4
    la   $a0, msg_area_hits
    syscall
    li   $v0, 1
    move $a0, $s4
    syscall
    li   $v0, 4
    la   $a0, msg_nl
    syscall

    li   $v0, 1                     # Retorno: comodin 3x3 activado
    move $v1, $s4                   # Retorno: cantidad de nuevos impactos
    j    ica_epilogo

ica_no_activado:
    li   $v0, 0
    li   $v1, 0

ica_epilogo:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $s4, 16($sp)
    lw   $s5, 20($sp)
    lw   $s6, 24($sp)
    lw   $ra, 28($sp)
    addi $sp, $sp, 32
    jr   $ra


# ==============================================================================
# SUBRUTINA: ejecutar_comodin
# Descripcion:
#   Despachador unificado de comodines para facilitar la integracion modular.
#   Delega en intentar_comodin_radar (modo 0) o intentar_comodin_area (modo 1)
#   usando las matrices globales tablero_enemigo y tablero_ataque.
# Argumentos:
#   $a0 = Modo (0 = Radar al inicio de turno, 1 = Ataque 3x3 al disparar)
#   $a1 = X objetivo (requerido solo si $a0 == 1)
#   $a2 = Y objetivo (requerido solo si $a0 == 1)
# Retorno:
#   $v0, $v1 = Mismos valores de retorno que la subrutina delegada.
# ==============================================================================
ejecutar_comodin:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    beqz $a0, ec_radar
    # Modo 1: Ataque 3x3 en ($a1=X, $a2=Y)
    move $a0, $a1
    move $a1, $a2
    la   $a2, tablero_enemigo
    la   $a3, tablero_ataque
    jal  intentar_comodin_area
    j    ec_fin

ec_radar:
    # Modo 0: Radar de inicio de turno
    la   $a0, tablero_enemigo
    la   $a1, tablero_ataque
    jal  intentar_comodin_radar

ec_fin:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


# ==============================================================================
# SUBRUTINAS AUXILIARES INTERNAS (SOPORTE VISUAL Y DEMO AUTONOMA)
# ==============================================================================

# ------------------------------------------------------------------------------
# dibujar_tablero_base($a0 = addr_matriz, $a1 = y_offset_pantalla, $a2 = radar_idx)
#   Redibuja una mitad de 16x16 desde su matriz logica (Agua/Barco/Impacto/Fallo)
#   y si radar_idx >= 0, muestra temporalmente esa casilla como Barco (Gris).
# ------------------------------------------------------------------------------
dibujar_tablero_base:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   # Base de la matriz logica (256 bytes)
    move $s1, $a1                   # Offset Y en pantalla (0 o 16)
    move $s2, $a2                   # Indice temporal de radar (-1 si inactivo)
    li   $s3, 0                     # $s3 = idx lineal (0..255)

dtb_loop:
    li   $t0, 256
    bge  $s3, $t0, dtb_fin

    # Leer valor logico de la casilla
    add  $t1, $s0, $s3
    lbu  $t2, 0($t1)

    # Mapear estado logico -> color RGB
    li   $a2, COLOR_AGUA            # Por defecto 0 = Agua (Azul)
    beqz $t2, dtb_check_radar
    li   $t3, 1
    beq  $t2, $t3, dtb_es_barco
    li   $t3, 2
    beq  $t2, $t3, dtb_es_impacto
    li   $a2, COLOR_FALLO           # 3 = Fallo (Blanco)
    j    dtb_pintar

dtb_es_barco:
    li   $a2, COLOR_BARCO           # 1 = Barco (Gris)
    j    dtb_pintar

dtb_es_impacto:
    li   $a2, COLOR_IMPACTO         # 2 = Impacto (Rojo)
    j    dtb_pintar

dtb_check_radar:
    # Si radar activo en esta casilla aun sin disparar, mostrarla en Gris
    bne  $s3, $s2, dtb_pintar
    li   $a2, COLOR_BARCO

dtb_pintar:
    andi $a0, $s3, 15               # X = idx & 15
    srl  $t0, $s3, 4                # Y_local = idx >> 4
    add  $a1, $t0, $s1              # Y_pantalla = Y_local + y_offset
    jal  dibujar_celda

    addi $s3, $s3, 1
    j    dtb_loop

dtb_fin:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20
    jr   $ra


# ------------------------------------------------------------------------------
# dibujar_preview_barco($a0=X, $a1=Y, $a2=longitud, $a3=orientacion)
#   Dibuja en Amarillo (0xFFFF00) la silueta tentativa de un barco.
# ------------------------------------------------------------------------------
dibujar_preview_barco:
    addi $sp, $sp, -24
    sw   $ra, 20($sp)
    sw   $s4, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   # X
    move $s1, $a1                   # Y
    move $s2, $a2                   # longitud
    move $s3, $a3                   # orientacion (0=H, 1=V)
    li   $s4, 0                     # i = 0

dpb_loop:
    bge  $s4, $s2, dpb_fin
    move $a0, $s0
    move $a1, $s1
    li   $a2, COLOR_CURSOR          # Amarillo (0xFFFF00)
    jal  dibujar_celda

    beqz $s3, dpb_step_h
    addi $s1, $s1, 1                # Vertical: Y++
    j    dpb_next
dpb_step_h:
    addi $s0, $s0, 1                # Horizontal: X++
dpb_next:
    addi $s4, $s4, 1
    j    dpb_loop

dpb_fin:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $s4, 16($sp)
    lw   $ra, 20($sp)
    addi $sp, $sp, 24
    jr   $ra


# ------------------------------------------------------------------------------
# limpiar_pantalla_agua()
#   Pinta las 512 celdas (16 x 32) del Bitmap Display en Azul (0x0000FF).
# ------------------------------------------------------------------------------
limpiar_pantalla_agua:
    la   $t0, display_buffer
    li   $t1, 512                   # 16 * 32 palabras
    li   $t2, COLOR_AGUA
lpa_loop:
    beqz $t1, lpa_fin
    sw   $t2, 0($t0)
    addi $t0, $t0, 4
    addi $t1, $t1, -1
    j    lpa_loop
lpa_fin:
    jr   $ra


# ------------------------------------------------------------------------------
# limpiar_matriz_256($a0 = direccion_base)
#   Llena con ceros una matriz logica de 256 bytes (16x16).
# ------------------------------------------------------------------------------
limpiar_matriz_256:
    li   $t0, 256
lm_loop:
    beqz $t0, lm_fin
    sb   $zero, 0($a0)
    addi $a0, $a0, 1
    addi $t0, $t0, -1
    j    lm_loop
lm_fin:
    jr   $ra


# ------------------------------------------------------------------------------
# inicializar_demo_tableros()
#   Limpia las tres matrices y coloca 4 barcos enemigos de prueba (14 casillas)
#   en tablero_enemigo para poder probar radar y disparos en la demo autonoma:
#     - Portaaviones (5) horizontal en (1, 1)  -> (1..5, 1)
#     - Acorazado    (4) vertical   en (10, 3) -> (10, 3..6)
#     - Submarino    (3) horizontal en (4, 9)  -> (4..6, 9)
#     - Fragata      (2) vertical   en (13,12) -> (13, 12..13)
# ------------------------------------------------------------------------------
inicializar_demo_tableros:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    la   $a0, tablero_defensa
    jal  limpiar_matriz_256
    la   $a0, tablero_ataque
    jal  limpiar_matriz_256
    la   $a0, tablero_enemigo
    jal  limpiar_matriz_256

    la   $t0, tablero_enemigo
    li   $t1, 1                     # 1 = casilla con barco enemigo intacto

    # Portaaviones (5) horizontal en Y=1, X=1..5 (indices 17..21)
    sb   $t1, 17($t0)
    sb   $t1, 18($t0)
    sb   $t1, 19($t0)
    sb   $t1, 20($t0)
    sb   $t1, 21($t0)

    # Acorazado (4) vertical en X=10, Y=3..6 (indices 58, 74, 90, 106)
    sb   $t1, 58($t0)
    sb   $t1, 74($t0)
    sb   $t1, 90($t0)
    sb   $t1, 106($t0)

    # Submarino (3) horizontal en Y=9, X=4..6 (indices 148, 149, 150)
    sb   $t1, 148($t0)
    sb   $t1, 149($t0)
    sb   $t1, 150($t0)

    # Fragata (2) vertical en X=13, Y=12..13 (indices 205, 221)
    sb   $t1, 205($t0)
    sb   $t1, 221($t0)

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


# ------------------------------------------------------------------------------
# procesar_disparo_simple($a0=X, $a1=Y, $a2=tablero_enemigo, $a3=tablero_ataque)
#   Ejecuta un disparo normal de 1 casilla cuando el comodin 3x3 no se activa.
# ------------------------------------------------------------------------------
procesar_disparo_simple:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s3, 12($sp)
    sw   $s2, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0                   # X
    move $s1, $a1                   # Y
    move $s2, $a2                   # tablero_enemigo
    move $s3, $a3                   # tablero_ataque

    sll  $t0, $s1, 4
    add  $t0, $t0, $s0              # idx = (Y << 4) + X

    add  $t1, $s3, $t0
    lbu  $t2, 0($t1)
    bnez $t2, pds_duplicado         # Si tablero_ataque[idx] != 0, ya se disparo aqui

    add  $t3, $s2, $t0
    lbu  $t4, 0($t3)
    li   $t5, 1
    beq  $t4, $t5, pds_impacto

    # Agua -> Fallo (3) y Blanco
    li   $t5, 3
    sb   $t5, 0($t1)                # tablero_ataque[idx] = 3
    sb   $t5, 0($t3)                # tablero_enemigo[idx] = 3
    move $a0, $s0
    move $a1, $s1
    li   $a2, COLOR_FALLO
    jal  dibujar_celda

    li   $v0, 4
    la   $a0, msg_tiro_miss
    syscall
    j    pds_imprimir_coord

pds_impacto:
    # Barco -> Impacto (2) y Rojo
    li   $t5, 2
    sb   $t5, 0($t1)                # tablero_ataque[idx] = 2
    sb   $t5, 0($t3)                # tablero_enemigo[idx] = 2
    move $a0, $s0
    move $a1, $s1
    li   $a2, COLOR_IMPACTO
    jal  dibujar_celda

    li   $v0, 4
    la   $a0, msg_tiro_hit
    syscall
    j    pds_imprimir_coord

pds_duplicado:
    li   $v0, 4
    la   $a0, msg_tiro_dup
    syscall

pds_imprimir_coord:
    move $a0, $s0                   # $a0 = X del disparo
    move $a1, $s1                   # $a1 = Y del disparo
    jal  imprimir_coordenadas       # Imprimir "X,Y"
    li   $v0, 4
    la   $a0, msg_cierre_par
    syscall

    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20
    jr   $ra


# ------------------------------------------------------------------------------
# imprimir_coordenadas($a0 = X, $a1 = Y)
#   Imprime "X,Y" en consola usando syscall 1 (entero) y syscall 4 (coma).
#   Subrutina hoja: preserva $ra y $s0-$s7; usa solo $t0-$t1, $v0, $a0.
# ------------------------------------------------------------------------------
imprimir_coordenadas:
    move $t0, $a0                   # Guardar X en $t0 (porque syscall 4 sobreescribe $a0)
    move $t1, $a1                   # Guardar Y en $t1

    li   $v0, 1                     # Syscall 1: imprimir entero X
    move $a0, $t0
    syscall

    li   $v0, 4                     # Syscall 4: imprimir separador ","
    la   $a0, msg_coma
    syscall

    li   $v0, 1                     # Syscall 1: imprimir entero Y
    move $a0, $t1
    syscall

    jr   $ra                        # Retornar al invocador


# ------------------------------------------------------------------------------
# contar_barcos_restantes($a0 = direccion_tablero_enemigo) -> $v0 = conteo
#   Cuenta cuantas casillas siguen en estado 1 (barco no impactado).
# ------------------------------------------------------------------------------
contar_barcos_restantes:
    li   $v0, 0
    li   $t0, 256
    li   $t1, 1
cbr_loop:
    beqz $t0, cbr_fin
    lbu  $t2, 0($a0)
    bne  $t2, $t1, cbr_next
    addi $v0, $v0, 1
cbr_next:
    addi $a0, $a0, 1
    addi $t0, $t0, -1
    j    cbr_loop
cbr_fin:
    jr   $ra
