# ==============================================================================
# MODELO (DATOS DE FLOTA): flota.asm
# Descripcion:
#   Define la composicion oficial de los 4 barcos de la flota y enlaza sus
#   nombres descriptivos para la fase de colocacion manual.
# ==============================================================================

.data
.align 2                            # Alineacion obligatoria antes de directivas .word
.globl longitudes_flota
longitudes_flota:   .word 5, 4, 3, 2

.globl nombres_flota
nombres_flota:      .word str_portaaviones, str_acorazado, str_submarino, str_fragata
