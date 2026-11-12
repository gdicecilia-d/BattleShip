# Captura y filtrado de teclas de control desde MARS

.text
.globl leer_tecla

# leer_tecla() -> $v0 = tecla ASCII valida ('W','S','A','D','R','E' o 10 Enter)
# Usa syscall 12 e ignora caracteres residuales o no validos
# Alternativa por polling MMIO (0xFFFF0000 / 0xFFFF0004):
#   lui $t8, 0xFFFF; esperar bit 0 en 0($t8) y leer dato en 4($t8)
leer_tecla:
lt_bucle:
    li   $v0, 12                    # Syscall 12: leer caracter ASCII
    syscall

    li   $t0, TECLA_ENTER           # Aceptar '\n' (10)
    beq  $v0, $t0, lt_valida

    # Convertir minusculas 'a'..'z' (97..122) a mayusculas
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

    j    lt_bucle                   # Ignorar cualquier otra tecla o residual

lt_valida:
    jr   $ra
