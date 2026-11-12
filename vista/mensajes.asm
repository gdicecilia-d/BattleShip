# ==============================================================================
# VISTA (CADENAS DE CONSOLA): mensajes.asm
# Descripcion:
#   Centraliza todos los textos impresos por syscall 4 para mantener separada
#   la capa de presentacion textual de la logica del Modelo y Controlador.
# ==============================================================================

.data
str_portaaviones:   .asciiz "Portaaviones (5)"
str_acorazado:      .asciiz "Acorazado (4)"
str_submarino:      .asciiz "Submarino (3)"
str_fragata:        .asciiz "Fragata (2)"

msg_banner:         .asciiz "=== BATTLESHIP MIPS - ARQUITECTURA MVC ===\nBitmap Display: 16x16 unit, 256x512 px, Base 0x10010000\n"
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
