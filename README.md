# BattleShip (Batalla Naval) — MIPS R2000 (MARS 4.5)

## 1. Estructura del Proyecto

- [`main.asm`](main.asm) — Archivo principal que enlaza e inicia todo el programa.
- [`config/constantes.asm`](config/constantes.asm) — Constantes de colores, dimensiones, límites y teclas ASCII.
- **`modelo/`** — Tableros lógicos y validaciones:
  - [`modelo/tableros.asm`](modelo/tableros.asm) — `tablero_defensa`, `tablero_ataque`, `tablero_enemigo` (`256` bytes c/u).
  - [`modelo/flota.asm`](modelo/flota.asm) — Longitudes `(5, 4, 3, 2)` y nombres de los 4 barcos.
  - [`modelo/tableros_ops.asm`](modelo/tableros_ops.asm) — Limpieza de matrices, carga inicial de flota enemiga y conteo de casillas restantes.
  - [`modelo/validacion_flota.asm`](modelo/validacion_flota.asm) — `validar_posicion_barco` (límites y colisiones).
- **`vista/`** — Buffer de video y salida por consola:
  - [`vista/display_buffer.asm`](vista/display_buffer.asm) — `display_buffer: .space 2048` en `0x10010000` (primera directiva en `.data`).
  - [`vista/mensajes.asm`](vista/mensajes.asm) — Cadenas de texto en consola.
  - [`vista/render_tablero.asm`](vista/render_tablero.asm) — `dibujar_celda`, `dibujar_tablero_base`, `dibujar_preview_barco`, `limpiar_pantalla_agua`, `imprimir_coordenadas`.
- **`controlador/`** — Controles, colocación de flota y comodines:
  - [`controlador/teclado.asm`](controlador/teclado.asm) — `leer_tecla` (`syscall 12`).
  - [`controlador/cursor.asm`](controlador/cursor.asm) — `mover_cursor` y `mover_cursor_ataque`.
  - [`controlador/colocacion_flota.asm`](controlador/colocacion_flota.asm) — `colocar_flota_manual`.
  - [`controlador/comodines.asm`](controlador/comodines.asm) — `intentar_comodin_radar`, `intentar_comodin_area`, `ejecutar_comodin`.
  - [`controlador/combate_demo.asm`](controlador/combate_demo.asm) — `procesar_disparo_simple` y `ejecutar_demo_ataque`.

## 2. Cómo ejecutar en MARS 4.5

1. Abre [`main.asm`](main.asm) en MARS y presiona **F3** para ensamblar.
2. **Antes de darle a Run (F5)**, abre `Tools -> Bitmap Display`, configura:
   - **Unit Width / Height in Pixels:** `16`
   - **Display Width / Height in Pixels:** `256 x 512`
   - **Base address for display:** `0x10010000 (static data)`
   y pulsa **"Connect to MIPS"**.
3. Presiona **F5** y haz clic en la pestaña **Run I/O** para enviar las teclas.

## 3. Controles
- `W` / `A` / `S` / `D`: Mover cursor
- `R`: Rotar orientación (`Horizontal` / `Vertical`) durante la colocación
- `E` o `Enter`: Confirmar colocación o disparo
