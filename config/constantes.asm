# Constantes simbolicas (.eqv) compartidas por todo el proyecto

# Paleta de colores RGB (32 bits) 
.eqv COLOR_AGUA_1   0x0087CEEB      # Azul Cielo Claro (Olas)
.eqv COLOR_AGUA_2   0x0000BFFF      # Azul Profundo Claro (Olas)
.eqv COLOR_ARENA    0x00E6C280      # Arena de Playa (Bordes)
.eqv COLOR_BARCO    0x008B4513      # Marrón Caoba (Barcos)
.eqv COLOR_IMPACTO  0x00000000      # Negro (Impacto)
.eqv COLOR_FALLO    0x00003399      # Azul Marino (Fallo en el agua)
.eqv COLOR_HUNDIDO  0x00808080      # Gris (Barco hundido)
.eqv COLOR_CURSOR_1 0x00F5F5F5      # Blanco Humo (Cursor)
.eqv COLOR_CURSOR_2 0x00D3D3D3      # Gris Claro (Cursor alterno)

# Dimensiones de cuadricula (16x16 px por unidad en 256x512 px)
.eqv ANCHO_GRID      16             # X: 0..15
.eqv ALTO_TOTAL      32             # Y: 0..31
.eqv CELDAS_TABLERO  256            # 16 x 16 casillas por mitad
.eqv CELDAS_PANTALLA 512            # 16 x 32 casillas totales

# Limites de tablero
.eqv Y_ATK_MIN      0
.eqv Y_ATK_MAX      15
.eqv Y_DEF_MIN      16
.eqv Y_DEF_MAX      31

# Límites del cursor de ataque: X de 1 a 14, Y de 1 a 14
.eqv LIMITES_ATAQUE 0x000E010E      

# Estados logicos por casilla (1 byte)
.eqv CELDA_AGUA     0
.eqv CELDA_BARCO    1
.eqv CELDA_IMPACTO  2
.eqv CELDA_FALLO    3
.eqv CELDA_HUNDIDO  4               # Barco Hundido

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