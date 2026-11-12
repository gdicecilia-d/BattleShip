# ==============================================================================
# VISTA (BUFFER DE VIDEO): display_buffer.asm
# Descripcion:
#   PRIMERA DIRECTIVA OBLIGATORIA DEL SEGMENTO .data (direccion 0x10010000).
#   Reserva exactamente 16 x 32 x 4 = 2048 bytes (0x10010000 hasta 0x100107FF)
#   para el Bitmap Display de MARS 4.5 (Unit 16x16, Display 256x512).
#   REGLA CRITICA: Ninguna otra variable puede incluirse antes de este archivo.
# ==============================================================================

.data
.globl display_buffer
display_buffer:     .space 2048
