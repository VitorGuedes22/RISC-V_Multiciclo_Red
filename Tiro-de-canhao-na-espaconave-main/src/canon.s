.data

.include "./Sprites/ship.data"
.include "./Sprites/ship_background.data"
.include "./Sprites/explosion.data"
.include "./Sprites/explosion_background.data" 

V0: .word 300
GRAVIDADE: .float 9.8
PONTACANHAO: .float 765.0
TEMPO: .float 24.0
# PULA: .string "\n"
MIN_ANGLE: .float 0.1
MAX_ANGLE: .float 1.5
DEGREES_STEP: .float 0.1
VELOCITY_STEP: .float 1.0
START_DEGREE: .float 0.1
SHIP_POS: .word 0, 0
SHIP_OLD_POS: .word 0, 0
EXPLOSION_POS: .word 0, 0
SHIP_PACE: .word 0, 0

.text
SETUP:
    # fs0 = current angle
    # fs1 = min angle
    # fs2 = max angle
    # fs3 = angulo selecionado
    # fs4 = angulo do ultimo tiro
    # fs5 = tempo do tiro

    # s0 = tamanho canhão
    # s1 = largura canhão
    # s3 = posx da bala
    # s4 = posy da bala
    # s5 = velocidade atual
    # s6 = velocidade no momento do tiro
    # s7 = x0 no momento do tiro
    # s8 = y0 no momento do tiro

    la t0, START_DEGREE
    flw fs0, 0(t0)

    la t0, MIN_ANGLE
    flw fs1, 0(t0)

    la t0, MAX_ANGLE
    flw fs2, 0(t0)

    li s0, 15
    li s1, 60
    li s3, -1
    li s4, 1

    li a0, 1
    li a1, 229
    mv a2, s0
    mv a3, s1
    li a4, 0
    li a5, 255
    fmv.s fa0, fs0

    jal ra, DRAW_RECTANGLE

    li a0, 157
    li a1, 117
    call RANDOM

    la t0, SHIP_POS	# Carrega o endereço da posição da nave em t0
	sw a0, 0(t0)		# Guarda o x gerado pelo random no endereço
	sw a1, 4(t0)		# Guarda o y gerado pelo random no endereço
	
	la a0, ship		# Carrega o endereço da sprite da nave em a0
	lw a1, 0(t0)		# Carrega o x em a1
	lw a2, 4(t0)		# Carrega o y em a2
	li a3, 0		# a3 = Frame
	call PRINT		# Renderiza no frame 0
	li a3, 1
	call PRINT		# Renderiza no frame 1

GAME_LOOP:

KEYPOLL:
	li t0, 0xFF200000 # t0 = endereço de controle do teclado
	lw t1, 0(t0) # t1 = conteudo de t0
	andi t2, t1, 1 # Mascara o primeiro bit (verifica sem tem tecla)
	beqz t2, END_KEYPOLL # Se não tem tecla, então continua o jogo
	lw t1, 4(t0) # t1 = conteudo da tecla 
	
CONTINUE: 
	li t0, 'w' # tecla de incrementar angulo
	beq t0, t1, SOBE_ANGULO
	
	li t0, 's' # tecla de decrementar angulo
	beq t0,t1, DESCE_ANGULO
	
	li t0, 'q' # tecla de incrementar velocidade
	beq t0, t1, SOBE_VELOCIDADE
	
	li t0, 'a' # tecla de decrementar velocidade
	beq t0, t1, DESCE_VELOCIDADE

    li t0, ' '
	beq t0, t1, TIRO

    j REDRAW_CANON

TIRO:
    li t0, -1
    beq s3, t0, C

    li t0, 0xFF000000

    add t0, t0, s3

    li t1, 320
    mul t1, s4, t1 # t0 = y * 320
    add t0, t0, t1 # t0 = bitmap + y * 320

    li t1, 0
    sb t1, 0(t0)

C:  li a7, 1
    mv a0, s3
    ecall    
    
    li a7, 11
    li a0, ' '
    ecall    
    
    li a7, 1
    mv a0, s4
    ecall    
    
    li a7, 11
    li a0, '\n'
    ecall

    # li t0, 320
    # bge s3, t0, MOVE_NAVE

    # blt s4, zero, MOVE_NAVE

    # li t0, 240
    # bge s4, t0, MOVE_NAVE

    fmv.s fs4, fs3
    mv s6, s5

    # Calcular cosseno
    li a0, 7
    fmv.s fa0, fs0
    jal ra, COS

    fcvt.s.w ft0, s1
    fmul.s ft0, ft0, fa0 # ft0 = x0 = cos(ang) * tamanho
    fcvt.w.s s7, ft0 # s7 é a ponta x do canhao
    mv s3, s7

    # Calcular seno
    li a0, 7
    fmv.s fa0, fs0
    jal ra, SIN

    fcvt.s.w ft0, s1
    fmul.s ft0, ft0, fa0 # ft0 = y0 = sin(ang) * tamanho
    fcvt.w.s s8, ft0
    mv s4, s8

    li a7, 30
    ecall

    fcvt.s.wu ft0, a0
    li t0, 1000
    fcvt.s.w ft1, t0
    fdiv.s fs5, ft0, ft1 # tempo do tiro em segundos

    j END_KEYPOLL

SOBE_VELOCIDADE:
    li t0, 255
    blt t0, s5, END_KEYPOLL

    addi s5, s5, 1

    li a7, 1
    mv a0, s5
    ecall

    li a7, 11
    li a0, '\n'
    ecall

    j END_KEYPOLL
    
DESCE_VELOCIDADE:
    bge zero, s5, END_KEYPOLL

    addi s5, s5, -1

    li a7, 1
    mv a0, s5
    ecall

    li a7, 11
    li a0, '\n'
    ecall
    
	j END_KEYPOLL

SOBE_ANGULO:
    flt.s t0, fs2, fs0
    bne t0, zero, END_KEYPOLL

    # ========= Remover canhão =========

    li a0, 1
    li a1, 229
    mv a2, s0
    mv a3, s1
    li a4, 0
    li a5, 0
    fmv.s fa0, fs0

    jal ra, DRAW_RECTANGLE

    # ===================================

    la t0, DEGREES_STEP
    flw ft0, 0(t0)
    fadd.s fs0, fs0, ft0

    j REDRAW_CANON

DESCE_ANGULO:
    fle.s t0, fs0, fs1
    bne t0, zero, END_KEYPOLL

    # ========= Remover canhão =========

    li a0, 1
    li a1, 229
    mv a2, s0
    mv a3, s1
    li a4, 0
    li a5, 0
    fmv.s fa0, fs0

    jal ra, DRAW_RECTANGLE

    # ===================================

    la t0, DEGREES_STEP
    flw ft0, 0(t0)
    fsub.s fs0, fs0, ft0

REDRAW_CANON:
    # ========= Desenhar canhão =========

    li a0, 1
    li a1, 229
    mv a2, s0
    mv a3, s1
    li a4, 0
    li a5, 255
    fmv.s fa0, fs0

    jal ra, DRAW_RECTANGLE

    # ===================================

END_KEYPOLL:

BULLET_MOVEMENT:
    li t0, 320
    bge s3, t0, END_BULLET_MOVEMENT

    blt s4, zero, END_BULLET_MOVEMENT
    li t0, 240
    bge s4, t0, END_BULLET_MOVEMENT
    
    li t0, 0xFF000000

    add t0, t0, s3

    li t1, 320
    mul t1, s4, t1 # t0 = y * 320
    add t0, t0, t1 # t0 = bitmap + y * 320

    li t1, 0
    sb t1, 0(t0)
    # sb t1, 1(t0)
    # sb t1, 2(t0)
    # sb t1, 3(t0)
    # sb t1, 4(t0)

    # fs4 = angulo do ultimo tiro
    # fs5 = tempo do tiro

    # s3 = posx da bala
    # s4 = posy da bala
    # s6 = velocidade no momento do tiro
    # s7 = x0 no momento do tiro
    # s8 = y0 no momento do tiro

    # Encontrar novos valores s3 e s4

    # Calcular cosseno
    li a0, 7
    fmv.s fa0, fs4
    jal ra, COS

    fmv.s fa2, fa0

    fcvt.s.w fa0, s7
    fcvt.s.w fa1, s6

    li a7, 30
    ecall

    fcvt.s.wu ft0, a0
    li t0, 1000
    fcvt.s.w ft1, t0
    fdiv.s ft0, ft0, ft1

    fsub.s fa3, ft0, fs5 # Tempo desde o primeiro frame
    jal ra, BULLET_POS_X
    fcvt.w.s s3, fa0

    # fa0 = posicao y inicial
    # fa1 = velocidade inicial
    # fa2 = cosseno do angulo
    # fa3 = tempo

    # Calcular seno
    li a0, 7
    fmv.s fa0, fs4
    jal ra, COS

    fmv.s fa2, fa0

    fcvt.s.w fa0, s8
    fcvt.s.w fa1, s6

    li a7, 30
    ecall

    fcvt.s.wu ft0, a0
    li t0, 1000
    fcvt.s.w ft1, t0
    fdiv.s ft0, ft0, ft1

    fsub.s fa3, ft0, fs5 # Tempo desde o primeiro frame
    jal ra, BULLET_POS_Y
    fcvt.w.s s4, fa0
    li t0, 229
    sub s4, t0, s4

    # Fim

    la t0, SHIP_POS
    lw t1, 0(t0)
    lw t2, 4(t0)
    addi t1, t1, 1
    addi t2, t2, 1

    # li a7, 1
    # mv a0, s3
    # ecall

    # li a7, 11
    # li a0, ' '
    # ecall

    # li a7, 1
    # mv a0, s4
    # ecall

    # li a7, 11
    # li a0, '\n'
    # ecall

    # li a7, 1
    # mv a0, t1
    # ecall

    # li a7, 11
    # li a0, ' '
    # ecall

    # li a7, 1
    # mv a0, t2
    # ecall

    # li a7, 11
    # li a0, '\n'
    # ecall
    
    mv a0, s3
    mv a1, s4
    mv a2, t1
    mv a3, t2
    call VERIFY_COLLISION

    # li a7, 1
    # ecall
    # mv t0, a0

    # li a7, 11
    # li a0, '\n'
    # ecall
    # mv a0, t0

    beq a0, zero, JUMP

    la t0, SHIP_POS
    lw a0, 0(t0)
    lw a1, 4(t0)
    call ACERTOU_NAVE

JUMP:
    li t0, 320
    bge s3, t0, END_BULLET_MOVEMENT

    blt s4, zero, END_BULLET_MOVEMENT
    li t0, 240
    bge s4, t0, END_BULLET_MOVEMENT

    li t0, 0xFF000000

    add t0, t0, s3

    li t1, 320
    mul t1, s4, t1 # t0 = y * 320
    add t0, t0, t1 # t0 = bitmap + y * 320

    li t1, 255
    sb t1, 0(t0)
    # sb t1, 1(t0)
    # sb t1, 2(t0)
    # sb t1, 3(t0)
    # sb t1, 4(t0)

    # Adiciona velocidade 
    
    # Pinta de amarelo
END_BULLET_MOVEMENT:

    li a7, 32
    li a0, 10
    ecall

    j GAME_LOOP


MOVE_NAVE:
    addi sp, sp, -20
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)
    sw a3, 16(sp)

    li a7, 11
    li a0, 'D'
    ecall
    
    li a7, 11
    li a0, '\n'
    ecall

    li a7, 1
    mv a0, s3
    ecall

    li a7, 11
    li a0, ' '
    ecall

    li a7, 1
    mv a0, s4
    ecall

    li a7, 11
    li a0, '\n'
    ecall

    la t0, SHIP_POS

    lw a0, 0(t0)
    lw a1, 4(t0)

    la t0, SHIP_PACE

    lw a2, 0(t0)
    lw a3, 4(t0)

    call ERROU_NAVE

    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw a2, 12(sp)
    lw a3, 16(sp)
    addi sp, sp, 20

    j END_BULLET_MOVEMENT

# ================== BULLET_POS_X ========================

# x(t) = x0 + v0x * t

# fa0 = posicao x inicial
# fa1 = velocidade inicial
# fa2 = cosseno do angulo
# fa3 = tempo decorrido

# Retorna a posicao x esperada da bala de acordo com o tempo

BULLET_POS_X: 
	addi sp, sp, -4
	sw ra, 0(sp)

    fmul.s ft0, fa1, fa2 # ft0 = Vx0 = V0 * cos(ang)
	fmul.s ft0, ft0, fa3 # ft0 = Vx0 * tempo

	fadd.s fa0, fa0, ft0 # ft0 = Vx0 * tempo + x0

	lw ra, 0(sp)
	addi sp, sp, 4
	
	ret

# ================================================

# ================== BULLET_POS_Y ==================

# y(t) = y0 + v0x * t - (g / 2) * tˆ2

# fa0 = posicao y inicial
# fa1 = velocidade inicial
# fa2 = cosseno do angulo
# fa3 = tempo

# Retorna a posicao y esperada da bala de acordo com o tempo

BULLET_POS_Y: 
	addi sp, sp, -4
	sw ra, 0(sp)

    # Calcular v0x
	fmul.s ft0, fa1, fa2 # ft0 = v0x = v0 * cos(ang)
    fmul.s ft0, ft0, fa3 # ft0 = v0x * t
    fadd.s ft0, ft0, fa0 # ft0 = (v0x * t) + y0

    la t0, GRAVIDADE
    flw ft1, 0(t0)

    li t0, 2
    fcvt.s.w ft2, t0
    fdiv.s ft1, ft1, ft2 # ft1 = g / 2

    fmul.s ft2, fa3, fa3 # ft2 = t^2

    fmul.s ft1, ft1, ft2 # ft1 = (g/2) * t^2

    fsub.s fa0, ft0, ft1 # ft0 = y0 + v0x * t - (g / 2) * tˆ2
	
	lw ra, 0(sp)
	addi sp, sp, 4
	
	ret

# ==================================================

# =================== Função FATORIAL ===================

# a0 = numero

FATORIAL:
    beq a0, zero, FATORIAL_ZERO

    mv t0, a0
    li t1, 1

FATORIAL_LOOP:
    beq t0, t1, FATORIAL_END

    addi t0, t0, -1
    mul a0, a0, t0

    j FATORIAL_LOOP

FATORIAL_ZERO:
    li a0, 1

FATORIAL_END:
    jalr zero, ra, 0 # ret

# =======================================================

# ===================== Função POW =====================

# fa0 = base
# a0 = expoente

POW:
    li t0, 0

    li t1, 1
    fcvt.s.w ft0, t1

POW_LOOP:
    beq t0, a0, POW_END
    fmul.s ft0, ft0, fa0
    addi t0, t0, 1

    j POW_LOOP

POW_END:
    fmv.s fa0, ft0
    jalr zero, ra, 0 # ret

# ======================================================

# ===================== Função SIN =====================

# Calcula o seno de um angulo

# fa0 = angulo
# a0 = precisao (numeros da serie de taylor)

SIN:
    addi sp, sp, -36
	sw ra, 32(sp)
	sw a0, 28(sp)
	fsw fa0, 24(sp)
    sw s0, 20(sp)
	sw s1, 16(sp)
    sw s2, 12(sp)
    sw s3, 8(sp)
	fsw fs0, 4(sp)
	fsw fs1, 0(sp)

    mv s0, zero
    li s1, 1
    li s2, 1
    mv s3, a0

    fcvt.s.w fs0, zero
    fmv.s fs1, fa0

SIN_LOOP:
    beq s0, s3, SIN_END

    fmv.s fa0, fs1
    mv a0, s2
    jal ra, POW

    mv a0, s2
    jal ra, FATORIAL

    fcvt.s.w ft0, a0
    fdiv.s ft0, fa0, ft0

    beq s1, zero, SUB_SIN_LOOP
    fadd.s fs0, fs0, ft0
    addi s1, s1, -1

    j AFTER_SIN_LOOP

SUB_SIN_LOOP:
    addi s1, s1, 1
    fsub.s fs0, fs0, ft0

AFTER_SIN_LOOP:
    addi s2, s2, 2
    addi s0, s0, 1

    j SIN_LOOP

SIN_END:
    fmv.s fa0, fs0
    
	lw ra, 32(sp)
    lw s0, 20(sp)
	lw s1, 16(sp)
    lw s2, 12(sp)
    lw s3, 8(sp)
	flw fs0, 4(sp)
	flw fs1, 0(sp)

    addi sp, sp, 36

    jalr zero, ra, 0 # ret

# ======================================================

# ===================== Função COS =====================

# Calcula o cosseno de um angulo

# fa0 = angulo
# a0 = precisao (numeros da serie de taylor)

COS:
    addi sp, sp, -36
	sw ra, 32(sp)
	sw a0, 28(sp)
	fsw fa0, 24(sp)
    sw s0, 20(sp)
	sw s1, 16(sp)
    sw s2, 12(sp)
    sw s3, 8(sp)
	fsw fs0, 4(sp)
	fsw fs1, 0(sp)

    mv s0, zero
    li s1, 1
    li s2, 0
    mv s3, a0

    fcvt.s.w fs0, zero
    fmv.s fs1, fa0

COS_LOOP:
    beq s0, s3, COS_END

    fmv.s fa0, fs1
    mv a0, s2
    jal ra, POW

    mv a0, s2
    jal ra, FATORIAL

    fcvt.s.w ft0, a0
    fdiv.s ft0, fa0, ft0

    beq s1, zero, SUB_COS_LOOP
    fadd.s fs0, fs0, ft0
    addi s1, s1, -1

    j AFTER_COS_LOOP

SUB_COS_LOOP:
    addi s1, s1, 1
    fsub.s fs0, fs0, ft0

AFTER_COS_LOOP:
    addi s2, s2, 2
    addi s0, s0, 1

    j COS_LOOP

COS_END:
    fmv.s fa0, fs0
    
	lw ra, 32(sp)
    lw s0, 20(sp)
	lw s1, 16(sp)
    lw s2, 12(sp)
    lw s3, 8(sp)
	flw fs0, 4(sp)
	flw fs1, 0(sp)

    addi sp, sp, 36

    jalr zero, ra, 0 # ret

# ======================================================

# =================== Função PLACE_IN_BITMAP ===================

# a0 = endereço bitmap
# a1 = pos x
# a2 = pos y
# a3 = image pixel x
# a4 = image pixel y

PLACE_IN_BITMAP:
    add a0, a0, a1

    li t0, 320
    mul t0, a2, t0

    add a0, a0, t0

    add a0, a0, a3

    li t0, 320
    mul t0, a4, t0

    sub a0, a0, t0

    jalr zero, ra, 0 # ret

# =========================================================

# ================== Função DRAW_RECTANGLE ==================

# a0 = posx
# a1 = posy
# a2 = width
# a3 = height
# a4 = frame
# a4 = cor
# fa0 = angulo

# s0 = posx salva
# s1 = posy salva
# s2 = width salva
# s3 = height salva
# s4 = frame salvo
# s5 = cor

# fs0 = angulo salvo
# fs1 = x atual
# fs2 = y atual
# fs3 = x step = sin(ang)
# fs4 = y step = cos(ang)
# fs5 = x limite

DRAW_RECTANGLE:
    addi sp, sp, -52
	sw ra, 48(sp)
	fsw fs5, 44(sp)
	fsw fs4, 40(sp)
    fsw fs3, 36(sp)
    fsw fs2, 32(sp)
    fsw fs1, 28(sp)
    fsw fs0, 24(sp)
    sw s5, 20(sp)
    sw s4, 16(sp)
    sw s3, 12(sp)
    sw s2, 8(sp)
	sw s1, 4(sp)
	sw s0, 0(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    mv s5, a5

    # Salvar ângulo
    fmv.s fs0, fa0

    # X e Y atuais = zero
    fcvt.s.w fs1, zero
    fmv.s fs2, fs1

    # Calcular cosseno
    li a0, 7
    fmv.s fa0, fs0
    jal ra, COS

    fmv.s fs4, fa0

    # Calcular seno
    li a0, 7
    fmv.s fa0, fs0
    jal ra, SIN

    fmv.s fs3, fa0

    fcvt.s.w ft0, s2
    fmul.s fs5, fs3, ft0

DRAW_RECTANGLE_LOOP:
    fabs.s ft0, fs1
    fabs.s ft1, fs5
    flt.s t0, ft0, ft1
    beq t0, zero, DRAW_RECTANGLE_LOOP_END

    # Transformar posx e posy em inteiros
    fcvt.w.s t0, fs1
    add t0, t0, s0
    fcvt.w.s t1, fs2
    add t1, t1, s1

    mv a0, s3
    mv a1, s4
    mv a2, t0
    mv a3, t1
    mv a4, s5
    fmv.s fa0, fs0

    jal ra, DRAW_LINE

    fadd.s fs1, fs1, fs3
    fadd.s fs2, fs2, fs4

    j DRAW_RECTANGLE_LOOP

DRAW_RECTANGLE_LOOP_END:
	lw ra, 48(sp)
	flw fs5, 44(sp)
	flw fs4, 40(sp)
    flw fs3, 36(sp)
    flw fs2, 32(sp)
    flw fs1, 28(sp)
    flw fs0, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
	lw s1, 4(sp)
	lw s0, 0(sp)

    addi sp, sp, 52

    jalr zero, ra, 0 # ret

# ========================================================

# =================== Função DRAW_LINE ===================

# Desenha uma linha baseado no ângulo

# a0 = tamanho linha
# a1 = frame (0 ou 1)
# a2 = pos x
# a3 = pos y
# a4 = cor
# fa0 = ângulo (radiano)

# s0 = endereço do bitmap display
# s1 = contador do x
# s2 = posx guardada
# s3 = posy guardada
# s4 = tamanho da linha guardado
# s5 = cor
# fs0 = angulo guardado
# fs1 = altura
# fs2 = largura
# fs3 = tamanho step y (altura / largura)
# fs4 = contador do y

DRAW_LINE:
    addi sp, sp, -48
	sw ra, 44(sp)
	fsw fs4, 40(sp)
    fsw fs3, 36(sp)
    fsw fs2, 32(sp)
    fsw fs1, 28(sp)
    fsw fs0, 24(sp)
    sw s5, 20(sp)
    sw s4, 16(sp)
    sw s3, 12(sp)
    sw s2, 8(sp)
	sw s1, 4(sp)
	sw s0, 0(sp)

    # Setup bitmap address based on frame
    li s0, 0xFF0
    add s0, s0, a1
    slli s0, s0, 20

    mv s1, zero
    mv s2, a2
    mv s3, a3
    mv s4, a0
    mv s5, a4

    # Salvar ângulo
    fmv.s fs0, fa0

    # Calcular seno
    li a0, 7
    # fmv.s fa0, fs0 # fa0 já é o ângulo
    jal ra, SIN

    fcvt.s.w ft0, s4 # tamanho linha
    fmul.s fs1, fa0, ft0 # sin(ang) * l = h

    # Calcular cosseno
    li a0, 7
    fmv.s fa0, fs0
    jal ra, COS

    fcvt.s.w ft0, s4 # tamanho linha
    fmul.s fs2, fa0, ft0 # cos(ang) * l = w

    # Step do y = h / w
    fdiv.s fs3, fs1, fs2

    fcvt.s.w fs4, zero

DRAW_LINE_LOOP:
    # Se o x atual for maior ou igual a largura
    fcvt.w.s t0, fs2
    bge s1, t0, DRAW_LINE_LOOP_FIM

    # Escrever pixel branco nos x e y encontrados

    mv a0, s0 # endereço bitmap
    mv a1, s2
    mv a2, s3
    mv a3, s1

    fcvt.w.s t0, fs4 # y em int
    mv a4, t0

    jal ra, PLACE_IN_BITMAP

    # Repetir n vezes
    mv t1, zero

    fcvt.w.s t2, fs3 # Tamanho do step y
    addi t2, t2, 1
DRAW:
    beq t1, t2, DRAW_END
    sb s5, 0(a0)

    addi a0, a0, -320
    addi t1, t1, 1

    j DRAW
DRAW_END:
    addi s1, s1, 1
    fadd.s fs4, fs4, fs3

    j DRAW_LINE_LOOP

DRAW_LINE_LOOP_FIM:
	lw ra, 44(sp)
	flw fs4, 40(sp)
    flw fs3, 36(sp)
    flw fs2, 32(sp)
    flw fs1, 28(sp)
    flw fs0, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
	lw s1, 4(sp)
	lw s0, 0(sp)

    addi sp, sp, 48

    jalr zero, ra, 0

# ====================================================

#################################################
#	Função para gerar uma 			#
#	posição (x,y) aleatória			#
#						#
#	a0 = limite de x			#
#	a1 = limite de y			#
#################################################

RANDOM:	addi sp, sp, -4				# Aloca espaço na pilha
	sw ra, 0(sp)				# Guarda o endereço de retorno na pilha
    
	mv t0, a0				# Coloca o x recebido em t0
	mv t1, a1				# Coloca o y recebido em t1
	li a0, 1				# a0 = 1
	mv a1, t0				# a1 = x recebido
	li t4, 3				# t4 = 3 para verificar se é múltiplo

LOOPX:	li a7, 42				# Chamada para gerar número random no intervalo
	ecall

    addi a0, a0, 160
	
	rem t0, a0, t4				# t0 = a0 % t4
	bne t0, zero, LOOPX			# Se não é múltiplo de 3 volta pro loop
	
	mv t2, a0				# t2 = x random
	
	li a0, 1				# a0 = 1
	mv a1, t1				# a1 = y recebido
	
LOOPY:	li a7, 42				# Chamada para gerar número random no intervalo
	ecall

    addi a0, a0, 120
	
	rem t0, a0, t4				# t0 = a0 % t4
	bne t0, zero, LOOPY			# Se não é múltiplo de 3 volta pro loop
	
	mv t3, a0				# t3 = y random
	
	li t1, 50				# t1 = limite do x para não ter conflito com o canhão quando for renderizar
	ble t2, t1, COND2 			# Se tá em conflito, verifica o y, se não tá, segue normal
	j PULA					# Segue normal
COND2:	li t1, 190				# Limite do y
	bge t3, t1, LOOPX 			# Se não tá de acordo, faz denovo

PULA:	mv a0, t2				# Coloca o x random gerado em a0
	mv a1, t3				# Coloca o y random gerado em a1
	lw ra, 0(sp)				# Recupera o valor do endereço de retorno
	addi sp, sp, 4				# Desaloca espaço na pilha
	ret					# Retorna


#################################################
#	a0 = endereço imagem			#
#	a1 = x					#
#	a2 = y					#
#	a3 = frame (0 ou 1)			#
#################################################
#	t0 = endereco do bitmap display		#
#	t1 = endereco da imagem			#
#	t2 = contador de linha			#
# 	t3 = contador de coluna			#
#	t4 = largura				#
#	t5 = altura				#
#################################################

PRINT:	li t0,0xFF0			# carrega 0xFF0 em t0
	add t0,t0,a3			# adiciona o frame ao FF0 (se o frame for 1 vira FF1, se for 0 fica FF0)
	slli t0,t0,20			# shift de 20 bits pra esquerda (0xFF0 vira 0xFF000000, 0xFF1 vira 0xFF100000)
	
	add t0,t0,a1			# adiciona x ao t0
	
	li t1,320			# t1 = 320
	mul t1,t1,a2			# t1 = 320 * y
	add t0,t0,t1			# adiciona t1 ao t0
	
	addi t1,a0,8			# t1 = a0 + 8
	
	mv t2,zero			# zera t2
	mv t3,zero			# zera t3
	
	lw t4,0(a0)			# carrega a largura em t4
	lw t5,4(a0)			# carrega a altura em t5
		
PRINT_LINHA:	
	lb t6,0(t1)			# carrega em t6 uma word (4 pixeis) da imagem
	sb t6,0(t0)			# imprime no bitmap a word (4 pixeis) da imagem
	
	addi t0,t0,1			# incrementa endereco do bitmap
	addi t1,t1,1			# incrementa endereco da imagem
	
	addi t3,t3,1			# incrementa contador de coluna
	blt t3,t4,PRINT_LINHA		# se contador da coluna < largura, continue imprimindo

	addi t0,t0,320			# t0 += 320
	sub t0,t0,t4			# t0 -= largura da imagem
	
	mv t3,zero			# zera t3 (contador de coluna)
	addi t2,t2,1			# incrementa contador de linha
	bgt t5,t2,PRINT_LINHA		# se altura > contador de linha, continue imprimindo
	
	ret				# retorna

#################################################
#	Caso a bola de canhão 			#
#	acerte a nave				#
#						#
#	a0 = posição x atual			#
#	a1 = posição y atual			#
#################################################

ACERTOU_NAVE:
	addi sp, sp, -12		# Aloca 3 words na pilha
	sw ra, 8(sp)			# Guarda o endereço de retorno na pilha
	sw a1, 4(sp)			# Guarda o y na pilha
	sw a0, 0(sp)			# Guarda o x na pilha
	
    la t0, SHIP_POS

	la a0, ship_background		# Carrega o endereço do sprite para "tampar" a nave
	lw a1, 0(t0)			# Carrega o x
	lw a2, 4(t0)			# Carrega o y
	li a3, 0			# Frame = 0
	call PRINT			# "Tampa" a nave no frame 0
	li a3, 1			# Frame = 1
	call PRINT			# "Tampa" a nave no frame 1
	
    la t0, SHIP_POS

	la a0, explosion		# Carrega o endereço do sprite da explosão
	lw a1, 0(t0)			# Carrega o x
	lw a2, 4(t0)			# Carrega o y
	addi a1, a1, -9			# Move a animação 9 pixeis pra esquerda
	addi a2, a2, -9			# Move a animação 9 pixeis pra cima
	li t0, 302			# t0 = 302, limite da direita
	ble a1, t0, L1			# Se a1 tá abaixo do limite => L1
	addi t2, a1, 18			# t2 = a1 + 18
	li t0, 319			# t0 = 319
	sub t2, t0, t2			# t2 = t0 - t2
	add a1, a1, t2			# Calcula quantos pixeis passou da borda de baixo
L1:	bge a1, zero, L2		# Se a1 >= 0 => L2
	mv a1, zero			# a1 = 0
L2:	li t0, 222			# t0 = 222, limite de baixo
	ble a2, t0, L3			# Se tá abaixo do limite => L3
	addi t2, a2, 18			# t2 = a2 + 18
	li t0, 239			# t0 = 239
	sub t2, t0, t2			# t2 = t0 - t2
	add a2, a2, t2			# Calcula quantos pixeis passou da borda de baixo
L3:	bge a2, zero, L4		# Se a2 >= 0 => L4
	mv a2, zero			# a2 = 0
L4:	la t0, EXPLOSION_POS		# Carrega o endereço da posição da explosão
	sw a1, 0(t0)			# Salva o x calculado
	sw a2, 4(t0) 			# Salva o y calculado
	li a3, 0			# Frame = 0
	call PRINT			# Renderiza no frame 0
	li a3, 1			# Frame = 1
	call PRINT			# Renderiza no frame 1
	
	li a0,40			# Nota = 40
	li a1,1500			# Duração = 1,5s
	li a2,126			# Efeito sonoro = 126
	li a3,127			# Volume = 127
	li a7,33			# Syscall = 33
	ecall				# Toca o som de explosão
	    
	li a0, 1000			# Tempo de timeout = 1s
	li a7, 32			# Syscall = 32
	ecall				# Chama o timeout
	
    la t0, EXPLOSION_POS

	la a0, explosion_background		# Carrega o endereço da sprite que "tampa" a explosão
	lw a1, 0(t0)			# Carrega o x da explosão
	lw a2, 4(t0)			# Carrega o y da explosão
	li a3, 0			# Frame = 0	
	call PRINT			# Tampa a explosão no frame 0
	li a3, 1			# Frame = 1
	call PRINT			# Tampa a explosão no frame 1

    li a0, 157
    li a1, 117
    call RANDOM

    la t0, SHIP_POS	    # Carrega o endereço da posição da nave em t0
	sw a0, 0(t0)		# Guarda o x gerado pelo random no endereço
	sw a1, 4(t0)		# Guarda o y gerado pelo random no endereço
	
    la a0, ship		# Carrega o endereço da sprite da nave em a0
	lw a1, 0(t0)		# Carrega o x em a1
	lw a2, 4(t0)		# Carrega o y em a2
	li a3, 0		# a3 = Frame
	call PRINT		# Renderiza no frame 0
	li a3, 1
	call PRINT		# Renderiza no frame 1

	lw a0, 0(sp)			# Recupera o x
	lw a1, 4(sp)			# Recupera o y
	lw ra, 8(sp)			# Recupera o ra
	addi sp, sp, 12			# Libera espaço na pilha
	ret				# Retorna
	
			
#################################################
#	Caso a bola de canhão 			#
#	não acertar a nave			#
#						#
#	a0 = posição x atual			#
#	a1 = posição y atual			#
# 	a2 = passo de x				#
# 	a3 = passo de y				#
#################################################

ERROU_NAVE:
	addi sp, sp, -4			# Aloca espaço na pilha
	sw ra, 0(sp)			# Guarda o endereço de retorno na pilha
	
    la t0, SHIP_OLD_POS

	sw a0, 0(t0)			# Guarda o x atual na posição antiga da nave
	sw a1, 4(t0)			# Guarda o y atual na posição antiga da nave
	
BD:	li t0, 317			# t0 = 317
	bge a0, t0, BORDA_DIR		# Se a0 >= t0 => BORDA_DIR
	
BE:	li t0, 160 
    ble a0, t0, BORDA_ESQ		# Se a0 <= 0 => BORDA_ESQ
	
BB:	li t0, 237			# t0 = 237
	bge a1, t0, BORDA_BAIXO		# Se a1 >= t0 => BORDA_BAIXO
	
BC:	ble a1, zero, BORDA_CIMA	# Se a1 <= 0 => BORDA_CIMA
	 
RET:	add a0, a0, a2			# x = x + passo de x
	add a1, a1, a3			# y = y + passo de y
	
	li t0, 317			# t0 = 317
	ble a0, t0, J1			# Se a0 <= t0 => J1
	mv a0, t0			# a0 = 317
J1:	li t0, 160
    bge a0, t0, J2		# Se a0 >= 0 => J2
 	mv a0, zero			# a0 = 0
J2:	li t0, 237			# t0 = 237
	ble a1, t0, J3			# Se a1 <= t0 => J3
	mv a1, t0			# a1 = 237
J3:	bge a1, zero, J4		# Se a1 >= 0 => J4
	mv a1, zero			# a1 = 0

J4:	la t0, SHIP_POS
    sw a0, 0(t0)			# Guarda a posição atualizada do x da nave
	sw a1, 4(t0)			# Guarda a posição atualizada do y da nave
	
    la t0, SHIP_PACE
    sw a2, 0(t0)			# Guarda o passo de x novo
	sw a3, 4(t0)			# Guarda o passo de y novo
	
	lw ra, 0(sp)			# Recupera o valor do endereço de retorno
	addi sp, sp, 4			# Desaloca espaço na pilha
	ret				# Retorna
	
BORDA_DIR:
	li a2, -6			# Passo de x = -6
	j BE 				# Retorna para a função

BORDA_ESQ:
	li a2, 6			# Passo de x = 6
	j BB				# Retorna para a função
	
BORDA_BAIXO:
	li a3, -6			# Passo de y = -6
	j BC				# Retorna para a função
BORDA_CIMA:
	li a3, 6			# Passo de y = 6
	j RET				# Retorna para a função

# =================== Função VERIFY_COLLISION ===================#

# Calcula a distância entre a bala e a nave e verifica se há colisão ou não

# d = ((x2-x1)^2 + (y2-y1)^2)^(1/2)

# a0 = x da bala
# a1 = y da bala
# a2 = x da nave
# a3 = y da nave

VERIFY_COLLISION:

    sub t0, a2, a0  
    mul t0, t0, t0  

    sub t1, a3, a1  
    mul t1, t1, t1  

    add t0, t0, t1  

    # li a7, 1
    # mv a0, t0
    # ecall

    # li a7, 11
    # li a0, '\n'
    # ecall

    slti a0, t0, 100    # Se a distância for menor ou igual a 3, há colisão

    ret
