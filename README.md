# BattleShip (Batalla Naval) — MIPS R2000 (MARS 4.5)

Proyecto estructurado bajo arquitectura **Modelo–Vista–Controlador (MVC)** en carpetas modulares ([ver guía MVC completa](ARQUITECTURA_MVC.md)), con el módulo del **Integrante 2 (Controles, Colocación Manual y Comodines)** dividido en mini-archivos independientes listos para trabajar en equipo.

## 1. Estructura del Proyecto

- [`main.asm`](main.asm) — Orquestador principal (único `.asm` en raíz; incluye todos los submódulos MVC).
- [`config/constantes.asm`](config/constantes.asm) — Paleta RGB, dimensiones `16x32`, límites y teclas ASCII (`.eqv`).
- **`modelo/`** — Estado lógico y reglas de negocio:
  - [`modelo/tableros.asm`](modelo/tableros.asm) — `tablero_defensa`, `tablero_ataque`, `tablero_enemigo` (`256` bytes c/u).
  - [`modelo/flota.asm`](modelo/flota.asm) — Longitudes `(5, 4, 3, 2)` y nombres de barcos.
  - [`modelo/tableros_ops.asm`](modelo/tableros_ops.asm) — `limpiar_matriz_256`, `inicializar_demo_tableros`, `contar_barcos_restantes`.
  - [`modelo/validacion_flota.asm`](modelo/validacion_flota.asm) — `validar_posicion_barco` (límites y colisiones).
- **`vista/`** — Buffer de video y salida visual/consola:
  - [`vista/display_buffer.asm`](vista/display_buffer.asm) — `display_buffer: .space 2048` en `0x10010000` (primera directiva en `.data`).
  - [`vista/mensajes.asm`](vista/mensajes.asm) — Mensajes de consola (`.asciiz`).
  - [`vista/render_tablero.asm`](vista/render_tablero.asm) — `dibujar_celda`, `dibujar_tablero_base`, `dibujar_preview_barco`, `limpiar_pantalla_agua`, `imprimir_coordenadas`.
- **`controlador/`** — Captura de entrada, cursor, colocación y comodines:
  - [`controlador/teclado.asm`](controlador/teclado.asm) — `leer_tecla` (`syscall 12` + alternativa MMIO documentada).
  - [`controlador/cursor.asm`](controlador/cursor.asm) — `mover_cursor` y `mover_cursor_ataque`.
  - [`controlador/colocacion_flota.asm`](controlador/colocacion_flota.asm) — `colocar_flota_manual`.
  - [`controlador/comodines.asm`](controlador/comodines.asm) — `intentar_comodin_radar`, `intentar_comodin_area`, `ejecutar_comodin`.
  - [`controlador/combate_demo.asm`](controlador/combate_demo.asm) — `procesar_disparo_simple` y `ejecutar_demo_ataque`.

## 2. Configuración Obligatoria en MARS 4.5
Abrir `main.asm` y configurar `Tools -> Bitmap Display -> Connect to MIPS`:
- **Unit Width / Height in Pixels:** `16`
- **Display Width / Height in Pixels:** `256 x 512` (cuadrícula `16 x 32`)
- **Base address for display:** `0x10010000 (static data)`

## 3. Controles
- `W`/`w`, `S`/`s`, `A`/`a`, `D`/`d`: Mover cursor
- `R`/`r`: Rotar orientación (`0 = Horizontal`, `1 = Vertical`) al colocar flota
- `E`/`e` o `Enter`: Confirmar colocación o disparo

## 4. Ejecución
Desde MARS GUI abrir [`main.asm`](main.asm), ensamblar y ejecutar, o desde terminal:
```bash
mars-mips main.asm
```
O con MARS CLI:
```bash
java -jar /usr/share/java/mars-mips/Mars.jar sm main.asm
```
