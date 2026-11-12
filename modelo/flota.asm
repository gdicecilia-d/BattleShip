# Configuracion de los 4 barcos de la flota (longitudes y nombres)

.data
.align 2                            # Alineacion obligatoria antes de .word
.globl longitudes_flota
longitudes_flota:   .word 5, 4, 3, 2

.globl nombres_flota
nombres_flota:      .word str_portaaviones, str_acorazado, str_submarino, str_fragata
