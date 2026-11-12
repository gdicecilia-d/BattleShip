# BattleShip (Batalla Naval) — MIPS R2000 (MARS 4.5)

## Módulo Implementado: Integrante 2
**Controles, Colocación Manual de Barcos y Comodín** ([modulo_integrante2.asm](modulo_integrante2.asm))

### 1. Configuración Obligatoria en MARS 4.5
Antes de ejecutar (`Tools -> Bitmap Display -> Connect to MIPS`):
- **Unit Width in Pixels:** `16`
- **Unit Height in Pixels:** `16`
- **Display Width in Pixels:** `256` (16 columnas: $X \in [0, 15]$)
- **Display Height in Pixels:** `512` (32 filas: $Y \in [0, 31]$)
- **Base address for display:** `0x10010000 (static data)`

### 2. Distribución de Memoria (`.data`)
| Rango de Dirección | Etiqueta (`.globl`) | Tamaño | Propósito |
| :--- | :--- | :--- | :--- |
| `0x10010000 – 0x100107FF` | `display_buffer` | 2048 bytes | Buffer RGB de pantalla ($16 \times 32 \times 4$). Primera directiva obligatoria. |
| `0x10010800 – 0x100108FF` | `tablero_defensa` | 256 bytes | Matriz lógica $16 \times 16$ de defensa del jugador ($Y_{pantalla} \in [16, 31]$). |
| `0x10010900 – 0x100109FF` | `tablero_ataque` | 256 bytes | Matriz lógica $16 \times 16$ de disparos realizados ($Y_{pantalla} \in [0, 15]$). |
| `0x10010A00 – 0x10010AFF` | `tablero_enemigo` | 256 bytes | Matriz lógica $16 \times 16$ enemiga para pruebas autónomas de comodines. |

> **Nota para el merge con Integrantes 1 y 3:** `display_buffer: .space 2048` debe permanecer siempre como la primera reserva en `.data` (`0x10010000`).

**Codificación de estado en matrices lógicas (1 byte/casilla):** `0` = Agua, `1` = Barco intacto, `2` = Impacto, `3` = Fallo.

**Paleta de colores en `display_buffer`:**
- Agua: `0x000000FF` (Azul)
- Barco colocado / Revelación temporal radar: `0x00808080` (Gris)
- Impacto: `0x00FF0000` (Rojo)
- Fallo: `0x00FFFFFF` (Blanco)
- Cursor / Sombreado previo: `0x00FFFF00` (Amarillo)

### 3. Controles
- `W` / `w`: Arriba ($Y - 1$)
- `S` / `s`: Abajo ($Y + 1$)
- `A` / `a`: Izquierda ($X - 1$)
- `D` / `d`: Derecha ($X + 1$)
- `R` / `r`: Rotar orientación (`0 = Horizontal`, `1 = Vertical`) durante colocación
- `E` / `e` o `Enter` (`\n`): Confirmar colocación o disparo

### 4. Contrato ABI de Subrutinas Globales (`.globl`)

| Etiqueta | Entrada (`$a0–$a3`) | Retorno (`$v0–$v1`) | Descripción |
| :--- | :--- | :--- | :--- |
| `dibujar_celda` | `$a0=X`, `$a1=Y`, `$a2=color` | — | Pinta celda en `Base + ((Y*16)+X)*4` con guarda de rango `[0..15]x[0..31]`. |
| `leer_tecla` | — | `$v0` = ASCII válido | Captura `syscall 12`, normaliza minúsculas y descarta residuales. |
| `mover_cursor` | `$a0=X`, `$a1=Y`, `$a2=tecla`, `$a3=(x_max<<16)\|(y_min<<8)\|y_max` | `$v0=new_X`, `$v1=new_Y` | Desplazamiento WASD reutilizable con restricción de límites. |
| `mover_cursor_ataque` | `$a0=X_ini`, `$a1=Y_ini`, `$a2=tablero_ataque`, `$a3=radar_idx (-1 o 0..255)` | `$v0=X_sel`, `$v1=Y_sel` | Bucle interactivo de apuntado en mitad superior ($Y \in [0, 15]$). |
| `validar_posicion_barco` | `$a0=X`, `$a1=Y`, `$a2=long`, `$a3=orient (0/1)` | `$v0=1/0`, `$v1=cod (0=OK,1=Lim,2=Col)` | Verifica límites $16 \times 16$ inferior y colisiones en `tablero_defensa`. |
| `colocar_flota_manual` | — | — | Despliega Portaaviones(5), Acorazado(4), Submarino(3) y Fragata(2) con preview amarillo. |
| `intentar_comodin_radar` | `$a0=tablero_enemigo`, `$a1=tablero_ataque` | `$v0=1/0`, `$v1=idx (-1 si 0)` | 5% (`syscall 42`, `$a1=100`, `$a0<5`): revela 1 casilla enemiga intacta. |
| `intentar_comodin_area` | `$a0=X`, `$a1=Y`, `$a2=tablero_enemigo`, `$a3=tablero_ataque` | `$v0=1/0`, `$v1=nuevos_hits` | 1/7 (`syscall 42`, `$a1=7`, `$a0==0`): ataque $3 \times 3$ con chequeo de bordes `[0..15]`. |
| `ejecutar_comodin` | `$a0=modo (0=Radar,1=Area)`, `$a1=X`, `$a2=Y` | `$v0, $v1` | Despachador unificado usando matrices globales. |

### 5. Ejecución en Consola (MARS CLI)
```bash
mars-mips modulo_integrante2.asm
```
O mediante JAR directamente:
```bash
java -jar /usr/share/java/mars-mips/Mars.jar sm modulo_integrante2.asm
```
