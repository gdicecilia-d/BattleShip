# Constantes simbolicas (.eqv) compartidas por todo el proyecto

# Paleta de colores RGB (32 bits)
.eqv COLOR_AGUA     0x000000FF      # Azul
.eqv COLOR_BARCO    0x00808080      # Gris
.eqv COLOR_IMPACTO  0x00FF0000      # Rojo
.eqv COLOR_FALLO    0x00FFFFFF      # Blanco
.eqv COLOR_CURSOR   0x00FFFF00      # Amarillo

# Dimensiones de cuadricula (16x16 px por unidad en 256x512 px)
.eqv ANCHO_GRID      16             # X: 0..15
.eqv ALTO_TOTAL      32             # Y: 0..31
.eqv CELDAS_TABLERO  256            # 16 x 16 casillas por mitad
.eqv CELDAS_PANTALLA 512            # 16 x 32 casillas totales

# Limites de tablero de ataque (superior) y defensa (inferior)
.eqv Y_ATK_MIN      0
.eqv Y_ATK_MAX      15
.eqv Y_DEF_MIN      16
.eqv Y_DEF_MAX      31
.eqv LIMITES_ATAQUE 0x000F000F      # (x_max=15 << 16) | (y_min=0 << 8) | y_max=15

# Estados logicos por casilla (1 byte)
.eqv CELDA_AGUA     0
.eqv CELDA_BARCO    1
.eqv CELDA_IMPACTO  2
.eqv CELDA_FALLO    3

# Orientaciones de barco
.eqv ORIENT_HORIZ   0
.eqv ORIENT_VERT    1

# Codigos ASCII de teclado
.eqv TECLA_ENTER    10
.eqv TECLA_E        69
.eqv TECLA_R        82
.eqv TECLA_W        87
.eqv TECLA_S        83
.eqv TECLA_A        65
.eqv TECLA_D        68
