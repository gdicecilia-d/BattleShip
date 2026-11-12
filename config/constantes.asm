# ==============================================================================
# CONFIGURACION GLOBAL: constantes.asm
# Descripcion:
#   Define constantes simbolicas (.eqv) compartidas por Modelo, Vista y
#   Controlador. No genera bytes en memoria RAM (.data ni .text).
# ==============================================================================

# --- Paleta de Colores RGB de 32 bits (0x00RRGGBB) ---
.eqv COLOR_AGUA     0x000000FF      # Azul: casilla sin disparar / agua
.eqv COLOR_BARCO    0x00808080      # Gris: barco propio o revelacion de radar
.eqv COLOR_IMPACTO  0x00FF0000      # Rojo: impacto acertado
.eqv COLOR_FALLO    0x00FFFFFF      # Blanco: disparo fallido (agua)
.eqv COLOR_CURSOR   0x00FFFF00      # Amarillo: cursor y preview de colocacion

# --- Dimensiones de la Cuadricula en Bitmap Display (16x16 px en 256x512 px) ---
.eqv ANCHO_GRID     16              # Columnas X validas: 0..15
.eqv ALTO_TOTAL     32              # Filas pantalla Y validas: 0..31
.eqv CELDAS_TABLERO 256             # 16 x 16 casillas por mitad de tablero
.eqv CELDAS_PANTALLA 512            # 16 x 32 pixeles logicos en pantalla

# --- Limites de Zonas del Tablero ---
.eqv Y_ATK_MIN      0               # Mitad superior: Ataque Y = 0..15
.eqv Y_ATK_MAX      15
.eqv Y_DEF_MIN      16              # Mitad inferior: Defensa Y = 16..31
.eqv Y_DEF_MAX      31
.eqv LIMITES_ATAQUE 0x000F000F      # Empaquetado: (x_max=15<<16)|(y_min=0<<8)|y_max=15

# --- Estados Logicos de las Matrices (1 byte por casilla) ---
.eqv CELDA_AGUA     0               # Agua o casilla desconocida
.eqv CELDA_BARCO    1               # Barco intacto (sin impactar)
.eqv CELDA_IMPACTO  2               # Barco impactado
.eqv CELDA_FALLO    3               # Disparo fallido en agua

# --- Orientaciones de Barco ---
.eqv ORIENT_HORIZ   0               # Horizontal (crece en +X)
.eqv ORIENT_VERT    1               # Vertical   (crece en +Y)

# --- Codigos ASCII de Teclas de Control ---
.eqv TECLA_ENTER    10              # '\n'
.eqv TECLA_E        69              # 'E'
.eqv TECLA_R        82              # 'R'
.eqv TECLA_W        87              # 'W'
.eqv TECLA_S        83              # 'S'
.eqv TECLA_A        65              # 'A'
.eqv TECLA_D        68              # 'D'
