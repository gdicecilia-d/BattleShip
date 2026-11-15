# Constantes simbolicas (.equ) compartidas por todo el proyecto

# Paleta de colores RGB (32 bits) 
.equ COLOR_AGUA_1   0x0087CEEB      # Azul Cielo Claro (Olas)
.equ COLOR_AGUA_2   0x0000BFFF      # Azul Profundo Claro (Olas)
.equ COLOR_ARENA    0x00E6C280      # Arena de Playa (Bordes)
.equ COLOR_BARCO    0x008B4513      # Marrón Caoba (Barcos)
.equ COLOR_IMPACTO  0x00000000      # Negro (Impacto)
.equ COLOR_FALLO    0x00003399      # Azul Marino (Fallo en el agua)
.equ COLOR_HUNDIDO  0x00808080      # Gris (Barco hundido)
.equ COLOR_CURSOR_1 0x00F5F5F5      # Blanco Humo (Cursor)
.equ COLOR_CURSOR_2 0x00D3D3D3      # Gris Claro (Cursor alterno)

# Dimensiones de cuadricula (16x16 px por unidad en 256x512 px)
.equ ANCHO_GRID      16             # X: 0..15
.equ ALTO_TOTAL      32             # Y: 0..31
.equ CELDAS_TABLERO  256            # 16 x 16 casillas por mitad
.equ CELDAS_PANTALLA 512            # 16 x 32 casillas totales

# Limites de tablero
.equ Y_ATK_MIN      0
.equ Y_ATK_MAX      15
.equ Y_DEF_MIN      16
.equ Y_DEF_MAX      31

# Límites del cursor de ataque: X de 1 a 14, Y de 1 a 14
.equ LIMITES_ATAQUE 0x000E010E      

# Estados logicos por casilla (1 byte)
.equ CELDA_AGUA     0
.equ CELDA_BARCO    1
.equ CELDA_IMPACTO  2
.equ CELDA_FALLO    3
.equ CELDA_HUNDIDO  4               # Barco Hundido

# Orientaciones de barco
.equ ORIENT_HORIZ   0
.equ ORIENT_VERT    1

# Codigos ASCII de teclado
.equ TECLA_ENTER    10
.equ TECLA_E        69
.equ TECLA_R        82
.equ TECLA_W        87
.equ TECLA_S        83
.equ TECLA_A        65
.equ TECLA_D        68