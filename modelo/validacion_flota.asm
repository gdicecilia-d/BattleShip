# Validacion de limites y colisiones para colocacion de barcos

.text
.globl validar_posicion_barco

# validar_posicion_barco($a0=X, $a1=Y, $a2=longitud, $a3=orientacion)
validar_posicion_barco:
    # Borde izquierdo y derecho (X=0 y X=15 son arena) 
    blez $a0, vpb_err_limites       # X <= 0 -> error
    li   $t0, 15
    bge  $a0, $t0, vpb_err_limites  # X >= 15 -> error

    # Bordes superior e inferior (Y=16 y Y=31 son arena) 
    li   $t0, Y_DEF_MIN             # 16
    ble  $a1, $t0, vpb_err_limites  # Y <= 16 -> error
    li   $t0, Y_DEF_MAX             # 31
    bge  $a1, $t0, vpb_err_limites  # Y >= 31 -> error

    blez $a2, vpb_err_limites       # longitud > 0

    beqz $a3, vpb_check_horiz       
    li   $t0, ORIENT_VERT           
    beq  $a3, $t0, vpb_check_vert
    j    vpb_err_limites


vpb_check_horiz:
    add  $t0, $a0, $a2              # X + longitud
    li   $t1, 15                    
    bgt  $t0, $t1, vpb_err_limites  
    j    vpb_check_colision

vpb_check_vert:
    add  $t0, $a1, $a2              # Y + longitud
    li   $t1, 31                    
    bgt  $t0, $t1, vpb_err_limites  

vpb_check_colision:
    la   $t0, tablero_defensa       
    addi $t1, $a1, -16              
    move $t2, $a0                   
    li   $t3, 0                     

vpb_loop_celdas:
    bge  $t3, $a2, vpb_valido

    sll  $t4, $t1, 4                
    add  $t4, $t4, $t2              
    add  $t4, $t0, $t4              
    lbu  $t5, 0($t4)                
    bnez $t5, vpb_err_colision      

    beqz $a3, vpb_step_h
    addi $t1, $t1, 1                
    j    vpb_next
vpb_step_h:
    addi $t2, $t2, 1                
vpb_next:
    addi $t3, $t3, 1
    j    vpb_loop_celdas

vpb_valido:
    li   $v0, 1
    li   $v1, 0
    jr   $ra

vpb_err_limites:
    li   $v0, 0
    li   $v1, 1
    jr   $ra

vpb_err_colision:
    li   $v0, 0
    li   $v1, 2
    jr   $ra