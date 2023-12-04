.data

.include "./Sprites/ship.data"
.include "./Sprites/ship_background.data"
.include "./Sprites/explosion.data"
.include "./Sprites/explosion_background.data"

POSICAO_NAVE: .word 0, 0
POSICAO_NAVE_ANT: .word 0, 0
POSICAO_EXPLOSAO: .word 0, 0
PASSO: .word 6, 6

.text
	
	li a0, 317		# Limite do x do intervalo do numero random
	li a1, 237		# Limite do y do intervalo do numero random
	call RANDOM		# Vai pra RANDOM
	 
	la s1, POSICAO_NAVE	# Carrega o endereço da posição da nave em s1
	sw a0, 0(s1)		# Guarda o x gerado pelo random no endereço
	sw a1, 4(s1)		# Guarda o y gerado pelo random no endereço
	
	la a0, ship		# Carrega o endereço da sprite da nave em a0
	lw a1, 0(s1)		# Carrega o x em a1
	lw a2, 4(s1)		# Carrega o y em a2
	li a3, 0		# a3 = Frame
	call PRINT		# Renderiza no frame 0
	li a3, 1
	call PRINT		# Renderiza no frame 1
	
MAIN:	call KEYPOLL		# Chama o teclado por pooling
	
	xori s0, s0, 1		# Muda o frame
	
	la a0, ship_background	# Carrega o fundo em a0
	lw a1, 8(s1)		# Carrega o x do fundo em a1
	lw a2, 12(s1)		# Carrega o y do fundo em a2
	mv a3, s0		# Coloca o frame em a3
	call PRINT		# Renderiza
	
	
	la a0, ship		# Carrega o endereço da sprite da nave em a0
	lw a1, 0(s1)		# Carrega o x em a1
	lw a2, 4(s1)		# Carrega o y em a2
	mv a3, s0		# a3 = Frame
	call PRINT		# Renderiza
	
	
	li t0, 0xFF200604	# Carrega o endereço do frame em t0
	sw s0, 0(t0)		# Guarda o frame
	j MAIN			# Volta pro loop
	
	li a7, 10		# Fim
	ecall


KEYPOLL:
	addi sp, sp, -4			# Aloca uma word na pilha
	sw ra, 0(sp)			# Guarda o return adress na pilha

	li t0, 0xFF200000		# t0 = endereço de controle do teclado
	lw t1, 0(t0)			# t1 = conteudo de t0
	andi t2, t1, 1			# Mascara o primeiro bit
	beqz t2, SAI			# Se t2 é zero, sai
	lw t1, 4(t0)			# t1 = conteudo da word depois de t0
	
	li t0, ' '			# t0 = ' '
	lw a0, 0(s1)			# a0 = x da nave
	lw a1, 4(s1)			# a1 = y da nave
	beq t1, t0, ACERTOU_BOLA	# Se a tecla pressionada foi o espaço => ACERTOU_BOLA
	
	li t0, 'w'			# t0 = 'w'
	lw a0, 0(s1)			# Carrega o x atual da nave em a0
	lw a1, 4(s1)			# Carrega o y atual da nave em a1
	la s2, PASSO			# s2 = endereço do passo da nave
	lw a2, 0(s2)			# a2 = passo do x
	lw a3, 4(s2)			# a3 = passo do y
	beq t1, t0, ERROU_BOLA		# Se a tecla pressionada foi 'w' => ERROU_BOLA
	
SAI:	lw ra, 0(sp)
	addi sp, sp, 4	
	ret			# Retorna



#################################################
#	Caso a bola de canhão 			#
#	acerte a nave				#
#						#
#	a0 = posição x atual			#
#	a1 = posição y atual			#
#################################################

ACERTOU_BOLA:
	addi sp, sp, -12		# Aloca 3 words na pilha
	sw ra, 8(sp)			# Guarda o endereço de retorno na pilha
	sw a1, 4(sp)			# Guarda o y na pilha
	sw a0, 0(sp)			# Guarda o x na pilha
	
	la a0, ship_background		# Carrega o endereço do sprite para "tampar" a nave
	lw a1, 0(s1)			# Carrega o x
	lw a2, 4(s1)			# Carrega o y
	li a3, 0			# Frame = 0
	call PRINT			# "Tampa" a nave no frame 0
	li a3, 1			# Frame = 1
	call PRINT			# "Tampa" a nave no frame 1
	
	la a0, explosion		# Carrega o endereço do sprite da explosão
	lw a1, 0(s1)			# Carrega o x
	lw a2, 4(s1)			# Carrega o y
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
L4:	la s4, POSICAO_EXPLOSAO		# Carrega o endereço da posição da explosão
	sw a1, 0(s4)			# Salva o x calculado
	sw a2, 4(s4) 			# Salva o y calculado
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
	
	la a0, explosion_background		# Carrega o endereço da sprite que "tampa" a explosão
	lw a1, 0(s4)			# Carrega o x da explosão
	lw a2, 4(s4)			# Carrega o y da explosão
	li a3, 0			# Frame = 0	
	call PRINT			# Tampa a explosão no frame 0
	li a3, 1			# Frame = 1
	call PRINT			# Tampa a explosão no frame 1
	
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

ERROU_BOLA:
	addi sp, sp, -4			# Aloca espaço na pilha
	sw ra, 0(sp)			# Guarda o endereço de retorno na pilha
	
	sw a0, 8(s1)			# Guarda o x atual na posição antiga da nave
	sw a1, 12(s1)			# Guarda o y atual na posição antiga da nave
	
	li t0, 50			# t0 = limite do x para não ter conflito com o canhão quando for renderizar
	bgt a0, t0, BD 			# Se não tá em conflito no x, segue normal
	li t0, 190			# t0 = limite do y para não ter conflito com o canhão quando for renderizar
	ble a1, t0, BD			# Se não tá em conflito no y, segue normal
	li a0, 51			# a0 = 51, coordenada x
	li a1, 190			# a1 = 190, coordenada y
	li a2, 6			# a2 = 6, muda o passo de x pra direita
	li a3, -6			# a3 = -6, muda o passo de y pra cima
	
BD:	li t0, 317			# t0 = 317
	bge a0, t0, BORDA_DIR		# Se a0 >= t0 => BORDA_DIR
	
BE:	ble a0, zero, BORDA_ESQ		# Se a0 <= 0 => BORDA_ESQ
	
BB:	li t0, 237			# t0 = 237
	bge a1, t0, BORDA_BAIXO		# Se a1 >= t0 => BORDA_BAIXO
	
BC:	ble a1, zero, BORDA_CIMA	# Se a1 <= 0 => BORDA_CIMA
	 
RET:	add a0, a0, a2			# x = x + passo de x
	add a1, a1, a3			# y = y + passo de y
	
	li t0, 317			# t0 = 317
	ble a0, t0, J1			# Se a0 <= t0 => J1
	mv a0, t0			# a0 = 317
J1:	bge a0, zero, J2		# Se a0 >= 0 => J2
 	mv a0, zero			# a0 = 0
J2:	li t0, 237			# t0 = 237
	ble a1, t0, J3			# Se a1 <= t0 => J3
	mv a1, t0			# a1 = 237
J3:	bge a1, zero, J4		# Se a1 >= 0 => J4
	mv a1, zero			# a1 = 0

J4:	sw a0, 0(s1)			# Guarda a posição atualizada do x da nave
	sw a1, 4(s1)			# Guarda a posição atualizada do y da nave
	sw a2, 0(s2)			# Guarda o passo de x novo
	sw a3, 4(s2)			# Guarda o passo de y novo
	
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
	li s3, 3				# s3 = 3 para verificar se é múltiplo

LOOPX:	li a7, 42				# Chamada para gerar número random no intervalo
	ecall
	
	rem t0, a0, s3				# t0 = a0 % s3
	bne t0, zero, LOOPX			# Se não é múltiplo de 3 volta pro loop
	
	mv t2, a0				# t2 = x random
	
	li a0, 1				# a0 = 1
	mv a1, t1				# a1 = y recebido
	
LOOPY:	li a7, 42				# Chamada para gerar número random no intervalo
	ecall
	
	rem t0, a0, s3				# t0 = a0 % s3
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
