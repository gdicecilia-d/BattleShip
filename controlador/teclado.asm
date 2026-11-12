# ==============================================================================
# CONTROLADOR (ENTRADA): teclado.asm
# Descripcion:
#   Captura teclas de control en MARS 4.5 (syscall 12), normaliza minusculas
#   a mayusculas y filtra caracteres residuales o no reconocidos.
# ==============================================================================

.text
.globl leer_tecla

# ------------------------------------------------------------------------------
# SUBRUTINA: leer_tecla (Hoja)
#   Lee un caracter ASCII por syscall 12. Acepta W/w, S/s, A/a, D/d, R/r, E/e
#   y Enter ('\n'=10). Cualquier otro caracter (ej. '\r'=13, espacio) se ignora.
#
#   ALTERNATIVA MMIO (0xFFFF0000 / 0xFFFF0004):
#     Para usar Keyboard and Display MMIO Simulator, reemplazar syscall 12 por:
#       lui  $t8, 0xFFFF
#     wait_mmio:
#       lw   $t9, 0($t8)          # Bit 0 = Receiver Ready
#       andi $t9, $t9, 1
#       beqz $t9, wait_mmio
#       lw   $v0, 4($t8)          # Leer tecla ASCII y limpiar bandera Ready
#
# Argumentos: Ninguno.
# Retorno:    $v0 = Codigo ASCII valido ('W','S','A','D','R','E' o 10).
# ------------------------------------------------------------------------------
leer_tecla:
lt_bucle:
    li   $v0, 12                    # Syscall 12: leer caracter desde Run I/O
    syscall

    li   $t0, TECLA_ENTER           # 10 ('\n')
    beq  $v0, $t0, lt_valida

    # Normalizar 'a'..'z' (97..122) a 'A'..'Z' (-32)
    li   $t0, 97
    blt  $v0, $t0, lt_verificar_ctrl
    li   $t0, 122
    bgt  $v0, $t0, lt_bucle
    addi $v0, $v0, -32

lt_verificar_ctrl:
    li   $t0, TECLA_W
    beq  $v0, $t0, lt_valida
    li   $t0, TECLA_S
    beq  $v0, $t0, lt_valida
    li   $t0, TECLA_A
    beq  $v0, $t0, lt_valida
    li   $t0, TECLA_D
    beq  $v0, $t0, lt_valida
    li   $t0, TECLA_R
    beq  $v0, $t0, lt_valida
    li   $t0, TECLA_E
    beq  $v0, $t0, lt_valida

    j    lt_bucle                   # Descartar caracter residual/invalido

lt_valida:
    jr   $ra
