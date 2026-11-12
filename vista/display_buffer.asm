# Buffer de video del Bitmap Display (primera directiva obligatoria en .data)
# Inicia en 0x10010000 y ocupa 16 * 32 * 4 = 2048 bytes (hasta 0x100107FF)

.data
.globl display_buffer
display_buffer:     .space 2048
