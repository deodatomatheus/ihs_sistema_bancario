;Cada cadastro deverá conter os seguintes campos:

;Nome do proprietário (até 20 caracteres + /0) 21 bytes	, base + 0
;CPF	(11 digitos + /0) 12 bytes 						, base + 21
;Código da agência	2bytes  							, base + 33
;Número da conta	2bytes  							, base + 35
;total 37 bytes

org 0x7e00
jmp 0x0000:start

;------AREA DE STRINGS MENU
	informacoes_menu db '---->>> ESCOLHA UMA DAS OPCOES <<<----', 13, 10, 0
	cadastrar_conta db  '1 - CADASTRAR CONTA', 13, 10, 0
	buscar_conta db '2 - BUSCAR CONTA', 13, 10, 0
	editar_conta db '3 - EDITAR CONTA', 13, 10, 0 
	deletar_conta db '4 - DELETAR CONTA', 13, 10, 0
	listar_agencias db '5 - LISTAR AGENCIAS', 13, 10, 0
	listar_contas_de_uma_agencia db '6 - LISTAR CONTAS', 13, 10, 0
	comando_invalido db '!!COMANDO INVALIDO!!', 13, 10, 0

;-------AREA DE STRINGS CADASTRO
	informacoes_cadastro db '--->>> Digite os dados a seguir <<<---', 13, 10, 0
	digitar_nome db 'Nome do proprietario (max 20 char):', 13, 10, 0
	digitar_cpf db 'Digite o CPF:', 13, 10, 0
	digitar_cod_agencia db 'Codigo da agencia', 13, 10, 0
	digitar_num_conta db 'Numero da conta',  13, 10, 0
	banco_cheio db 'O banco de dados esta cheio', 13, 10, 0
;-------BANCO DE DADOS
	dados times 370 db 0 ;banco de dados suficiente para 10 pessoas
	numero dw 0
	ger_dados times 10 db 0	
							;gerencia o espaco de dados, funciona como um mapa de posicoes alocadas ou nao
							;SE MUDAR O TAMNAHO PRECISA MUDAR TAMBEM EM 'alocar' E EM 'cadastro'							
							;usado no loop da funcao busca
	aux dw 0				;usado em cadastro para guardar o valor do lugar que foi alocado
	aux2 dw 0
;------- BUSCA
	digitar_cpf_busca db 'Digite o CPF para buscar', 13, 10, 0
	conta_nao_encontrada db 'Conta nao encontrada', 13, 10, 0
	conta_busca dw 0
	aux_busca dw 0
	aux_busca_ger dw 0
	aux_busca_dados dw 0
;------- LISTAR CONTAS
	func_listar_contas db 'Digite uma agencia:', 13, 10, 0
;------- EDITAR
	func_editar db 'Editando a conta', 13, 10, 0
	aux_editar dw 0
;------- LISTAR AGENCIAS
	func_listar_agencias db 'Agencias cadastradas', 13, 10, 0
	aux_agencias times 20 db 0
	aux_ag_ger db 0
	flag_aux_agencias db 0
;------- DELETE
	conta_apagada db 'Conta apagada', 13, 10, 0
;------- tostring
	aux_to_string times 7 db 0
;-------ShowACC
	S_CORTA_PAG db '-----------------------------', 13, 10, 0
	S_NOME 		db 'NOME:    ', 0
	S_AGENCIA 	db 'AGENCIA: ', 0
	S_CONTA 	db 'CONTA:   ', 0
	S_CPF 		db 'CPF:     ', 0
;-----------------------------------------------------------------------------------------------------------


cadastro:
	call setVideoMode ;apagar o menu

	call alocar
	mov word[aux], cx
	mov si, dx;??????????/ oq isso faz?
	re_cadastro:	
	mov cx, [aux]									
	cmp cx, 10 									;TAMANHO DO BANCO DE DADOS
	jle .valido
		mov si, banco_cheio
		call printStr
		call getchar
		jmp .done
	.valido:
		mov si, informacoes_cadastro
		call printStr

		;-------------------------------LEITURA NOME-------------------------------------------
		mov si, digitar_nome
		call printStr	

		call seta_base

		mov bx, 20 	;tamanho maximo do NOME
		call gets 	;pega uma string de tamanho bx + \0
		mov bx, 20	
		mov [aux2], bx
			
		call completa_com_0	;poe cl - bl * 0 na area apontada por di		

		;--------------------------LEITURA CPF-------------------------------------------------
		mov si, digitar_cpf	
		call printStr
			
		call seta_base
		
		add di, 21				;setando a posicao correta na estrutura

		mov bx, 11 				;tamanho do CPF
		call gets 				;pega uma string de tamanho bx + \0	
		
		 
		mov bx, 11				;setando a posicao correta da estrutura
		mov [aux2], bx
		call completa_com_0 	;poe cl - bl * 0 na area apontada por di
		;------------------------------LIUTURA CODIGO DA CONTA----------------------------------
		; pegando os valores como 'inteiro' pra ser mais facil de procurar
		mov si, digitar_cod_agencia
		call printStr	
		call getinteger; ler numero de 2 bytes ***O RESULTADO FICA EM AX, CUIDADO COM ESSA PORRA, QUASE QUE ME MATO POR ISSO**
						;porem, tambem fica numa variavel chamada 'numero'
		
		call seta_base

		add di, 33		;setando a posicao correta na estrutura


		mov ax, [numero] 	;valor lido em getinteger

		stosw 
		 
		;------------------------------LIUTURA NUMERO DA CONTA----------------------------------
		; pegando os valores como 'inteiro' pra ser mais facil de procurar
		mov si, digitar_num_conta
		call printStr

		call getinteger; ler numero de 2 bytes ***O RESULTADO FICA EM AX, CUIDADO COM ESSA PORRA, QUASE QUE ME MATO POR ISSO**
						;porem, tambem fica numa variavel chamada 'numero'
		
		call seta_base
		add di, 35		;setando a posicao correta na estrutura

		mov ax, [numero]	;valor lido em getinteger	
		stosw 
		;	------------------------DEBUG-----------------------
		;printa os dados dos usuarios	
	.done:
ret
  
busca:
	call setVideoMode  ;limpar a tela
	;------------------------------LEITURA DO CONTA PARA BUSCA---------------------------------
	mov si, digitar_num_conta
	call printStr

	call getinteger
	mov ax, [numero]
	mov word[conta_busca], ax
	
	;call debugMEM2
	
	;----------------------------BUSCA---------------------------------------- [WIP]
	;CHECANDO A INTEGRIDADE DO CAMPO
	mov si, ger_dados
	mov word[aux_busca_ger], si

	mov cx, 0

	.parser:
		mov word[aux_busca], cx
		mov si, word[aux_busca_ger]
		lodsb
		mov word[aux_busca_ger] ,si

		cmp al, 1
		jne .espaco_n_alocado
			mov si, dados			 	
			mov cx, word[aux_busca]
			mov ax, 37
			mul cx
			add si, ax			
			add si, 35
			lodsw			
			cmp ax, word[conta_busca]
			jne .conta_diferente
			sub si, 37
			call showAcc
			.conta_diferente:		
		.espaco_n_alocado:
	
	mov cx, [aux_busca]
	inc cx
	cmp cx, 10	
	jne .parser


	call getchar	
ret

editar:
	call setVideoMode  ;limpar a tela
	;------------------------------LEITURA DO CONTA PARA BUSCA---------------------------------
	mov si, digitar_num_conta
	call printStr

	call getinteger
	mov ax, [numero]
	mov word[conta_busca], ax
	
	;call debugMEM2
	
	;----------------------------BUSCA---------------------------------------- [WIP]
	;CHECANDO A INTEGRIDADE DO CAMPO
	mov si, ger_dados
	mov word[aux_busca_ger], si

	mov cx, 0

	.parser:
		mov word[aux_busca], cx
		mov si, word[aux_busca_ger]
		lodsb
		mov word[aux_busca_ger] ,si

		cmp al, 1
		jne .espaco_n_alocado
			mov [aux], cx ;Guarda a posicao que deve ser mudada
			mov si, dados			 	
			mov cx, word[aux_busca]
			mov ax, 37
			mul cx
			add si, ax			
			add si, 35
			lodsw			
			cmp ax, word[conta_busca]
			jne .conta_diferente
			sub si, 37
			mov word[aux_editar], si
			mov si, func_editar
			call printStr
			mov si, word[aux_editar]
			call showAcc
			call re_cadastro
			.conta_diferente:		
		.espaco_n_alocado:
	
	mov cx, [aux_busca]
	inc cx
	cmp cx, 10	
	jne .parser

	call getchar	

ret

deletar:
	call setVideoMode  ;limpar a tela
	;------------------------------LEITURA DO CONTA PARA BUSCA---------------------------------
	mov si, digitar_num_conta
	call printStr

	call getinteger
	mov ax, [numero]
	mov word[conta_busca], ax
	
	;call debugMEM2
	
	;----------------------------BUSCA---------------------------------------- [WIP]
	;CHECANDO A INTEGRIDADE DO CAMPO
	mov si, ger_dados
	mov word[aux_busca_ger], si

	mov cx, 0

	.parser:
		mov word[aux_busca], cx
		mov si, word[aux_busca_ger]
		lodsb
		mov word[aux_busca_ger] ,si

		cmp al, 1
		jne .espaco_n_alocado
			mov si, dados			 	
			mov cx, word[aux_busca]
			mov ax, 37
			mul cx
			add si, ax			
			add si, 35
			lodsw			
			cmp ax, word[conta_busca]
			jne .conta_diferente
			sub si, 37
			call deleta_conta
			.conta_diferente:		
		.espaco_n_alocado:
	
	mov cx, [aux_busca]
	inc cx
	cmp cx, 10	
	jne .parser

	mov si, conta_apagada
	call printStr
	call getchar
ret

listar_agencia:
	call setVideoMode ;resetar a tela
	mov si, func_listar_agencias
	call printStr

	;----------------------------LISTAR AGENCIAS--------------------------------
	;CHECANDO A INTEGRIDADE DO CAMPO
	mov si, ger_dados
	mov word[aux_busca_ger], si

	mov cx, 0

	.parser:
		mov word[aux_busca], cx
		mov si, word[aux_busca_ger]
		lodsb
		mov word[aux_busca_ger] ,si

		cmp al, 1
		jne .espaco_n_alocado
			mov si, dados			 	
			mov cx, word[aux_busca]
			mov ax, 37
			mul cx
			add si, ax
			call showAg					
		.espaco_n_alocado:
	
	mov cx, [aux_busca]
	inc cx
	cmp cx, 10	
	jne .parser
	

	call limpa_aux_agencias
	call getchar	
ret

listar_contas:

	call setVideoMode ;resetar a tela
	mov si, func_listar_contas
	call printStr

	call getinteger
	mov ax, [numero]
	mov word[conta_busca], ax

	;----------------------------LISTAR CONTAS--------------------------------
	;CHECANDO A INTEGRIDADE DO CAMPO
	mov si, ger_dados
	mov word[aux_busca_ger], si

	mov cx, 0

	.parser:
		mov word[aux_busca], cx
		mov si, word[aux_busca_ger]
		lodsb
		mov word[aux_busca_ger] ,si

		cmp al, 1
		jne .espaco_n_alocado
			mov si, dados			 	
			mov cx, word[aux_busca]
			mov ax, 37
			mul cx
			add si, ax			
			add si, 33
			lodsw			
			cmp ax, word[conta_busca]
			jne .conta_diferente
			sub si, 35
			call showAcc
			.conta_diferente:		
		.espaco_n_alocado:
	
	mov cx, [aux_busca]
	inc cx
	cmp cx, 10	
	jne .parser

	call getchar	
ret

seta_base:
	mov di, dados 	
	mov cx, word[aux]
	mov ax, 37
	mul cx
	add di, ax
ret

printMenu:
	mov si, informacoes_menu
	call printStr
	mov si, cadastrar_conta
	call printStr
	mov si, buscar_conta
	call printStr
	mov si, editar_conta
	call printStr
	mov si, deletar_conta
	call printStr
	mov si, listar_agencias
	call printStr
	mov si, listar_contas_de_uma_agencia
	call printStr

	opcao_leitura:
	call getchar

	cmp al, '1'			;while(opcao invalida)
	jl opcao_invalida  	;	scanf (opcao)
	cmp al, '6'			;
	jg opcao_invalida 	;return al
	jmp opcao_valida
	
	opcao_invalida:
	mov si, comando_invalido
	call printStr
	jmp opcao_leitura

	opcao_valida:
ret

alocar: ;retorna a primeira posicao livre do ger_dados em cx
	mov si, ger_dados

	mov cx, 0
	jmp .teste
	.inicio:
		inc cx
		.teste:
		cmp cx, 10								;TAMANHO DO BANCO DE DADOS
		je .fim
		lodsb
		cmp al, 0
		jne .inicio	;se a posicao esta ocupada, olha a proxima	
		mov di, si
		dec di
		mov al, 1	;se a posicao ta livre, entao aloca
		stosb															
	.fim:

ret

printlen:
	mov bl, 10
	mov ax, cx
	div bl
	push ax	
	add al, 48
	call putchar
	pop ax
	mov al, ah
	add al, 48
	call putchar
	call endl
ret

getchar:
	mov ah, 0x00
	int 16h
ret

putchar:
	mov bh, 0
	mov bl, 0xf
	mov ah, 0x0e		; 
	int 10h			; interrupção de vídeo
ret

printStr:	
	lodsb
	cmp al, 0
	je endStr
	mov ah, 0xe
	mov bh, 0
	mov bl, 4
	int 10h
	jmp printStr
	endStr:	
ret

getinteger:
	xor ax, ax	
	mov [numero], ax	
	.inicio:			
		call getchar
		call putchar
		cmp al, 13
		je .end
		mov bx, 10
		mov ah, 0
		mov cx, ax
		sub cx, 48
		mov ax, [numero]
		mul bx 
		add ax, cx		
		mov [numero], ax
		jmp .inicio
	.end:
	call endl
	mov ax, [numero]
ret

setVideoMode:
	mov ah, 00h
	mov al, 0
	int 10h
ret

tostring:
	push di
	.loop1:
		cmp ax, 0
		je .endloop1
		xor dx, dx
		mov bx, 10
		   	 	div bx		; ax = 999, dx = 9
		   	 	xchg ax, dx	; swap ax, dx
		   	 	add ax, 48		; 9 + '0' = '9'
		   	 	stosb
		   	 	xchg ax, dx
		   	 	jmp .loop1
	.endloop1:
	;to string:
	pop si
	cmp si, di
	jne .done
	mov al, 48
	stosb
	.done:
	mov al, 0
	stosb
	call reverse
ret

reverse:
	mov di, si
	xor cx, cx		; zerar contador
	.loop1:
		lodsb
		cmp al, 0
		je .endloop1
		inc cl
		push ax
		jmp .loop1
	.endloop1:
	;reverse:
	.loop2:
		cmp cl, 0
		je .endloop2
		dec cl
		pop ax
		stosb
		jmp .loop2
	.endloop2:
ret

gets:
	xor cx, cx			; zerar contador
	
	.loop1:
		call getchar
		cmp al, 0x08	; backspace
		je .backspace
		cmp al, 0x0d	; return carriage
		je .done
		cmp cx, bx		; limite string
		je .loop1
		   	 
		stosb
		inc cx
		call putchar

	jmp .loop1
	
	.backspace:
		cmp cx, 0		; is empty?
		je .loop1
		dec di
		dec cx
		mov byte[di], 0
		call delchar
	jmp .loop1
	.done:
	mov al, 0
	stosb
	call endl
ret

endl:
	mov al, 10		; line feed
	call putchar
	mov al, 13		; carriage return
	call putchar
ret

delchar:
	mov al, 0x08
	call putchar
	mov al, ' '
	call putchar
	mov al, 0x08
	call putchar
ret

completa_com_0:
	mov al, 0
	.teste:
	cmp cx, [aux2]
	je .done
	stosb
	inc cx
	jmp .teste
	.done:
ret

debugMEM:
	mov si, dados
	mov cx, 37
	mov [aux2], cx

	mov cx, 8
	mov [aux], cx

	.inicio:
		mov [aux], cx
		mov cx, [aux2]
		.interno:
			lodsb
			cmp al, 0
			jne .normal
			mov al, '-'
			.normal:
			call putchar
		loop .interno
		
		mov al, 13
		call putchar
		mov al, 10
		call putchar
		mov cx, [aux]
	loop .inicio
	call getchar; programa para, pra vc ver...
ret

debugMEM2:
	mov si, ger_dados
	mov cx, 10
	.inicio:
		lodsb
		cmp al, 0
		jne .normal
		mov al, '0'
		jmp .prox
		.normal:
		mov al, '1'		
		.prox:
		call putchar
	loop .inicio
	call getchar; programa para, pra vc ver...
ret

showAcc:                ;Mostra acc apontada por si
	pusha
	mov si, S_CORTA_PAG
	call printStr
	popa
	mov cx, 33
	
	.pularLinha:
		call endl
		
	.nome:
		pusha
		mov si, S_NOME
		call printStr
		popa
		jmp .continua
	.cpf:
		call endl
		pusha
		mov si, S_CPF
		call printStr
		popa
		jmp .continua
	.inicio:
		cmp cx, 12
	 	je .cpf
		
		.continua:
		lodsb
		cmp al, 0
		call putchar
		
	loop .inicio
	call endl

	pusha 
		mov si, S_AGENCIA
		call printStr
	popa

	lodsw
	push si
		mov di, aux_to_string
		call tostring
		mov si, aux_to_string
		call printStr
		call endl		
	pop si

	pusha 
		mov si, S_CONTA
		call printStr
	popa

	lodsw
	push si		
		mov di, aux_to_string
		call tostring
		mov si, aux_to_string
		call printStr
		call endl
	pop si
ret

showAg:                ;Mostra acc apontada por si
	add si,33
	lodsw
	mov dx,ax			;guarda valor a agencia em dx
	mov bl,0
	mov cx, 10
	mov si, aux_agencias
	.verificaSeTem:
		lodsw
		cmp ax,dx
		je nimprime
	loop .verificaSeTem

	mov ax,dx
	xor dx,dx

	mov dl,byte[aux_ag_ger] ; pega qtd de agencias mostradas até agr
	mov di,aux_agencias     ; aponta para o vetor que guarda quais agencias ja foram mostradas
	add di,dx               
	add di,dx				; pula uma word para cada agencia amazenada no vetor aux_agencias
	stosb
	add dl,1
	mov byte[aux_ag_ger], dl



	mov di, aux_to_string
	call tostring
	mov si, aux_to_string
	call printStr
	call endl
	

	nimprime:
ret

limpa_aux_agencias:
	xor dx,dx
	mov byte[aux_ag_ger], dl
	mov cx,10
	mov ax, 0
	mov di, aux_agencias
	repz stosw

ret

deleta_conta:
	mov si,ger_dados
	repz lodsb
	mov di,si
	mov al,0
	stosb 
ret	

start:
	xor ax, ax
	mov ds, ax
	mov es, ax

	mov ax, 0
	mov ds, ax
	mov di, 0x0080
	mov word[di],     interrupt
	mov word[di + 2], 0

	xor ax, ax
	mov ds, ax


	exibe_menu:
	call setVideoMode

	call printMenu ;opcao selecionada fica em al
	xor ah,ah
	int 20h ;substitui seletor por int dentro dela estão todas as funções principas do programa.
	
	jmp fim

fim:
	jmp exibe_menu
	jmp $

interrupt:

	;--cadastro
	cmp ax, '1'
	je .cadastro

	cmp ax, '2'
	je .busca

	cmp ax, '3'
	je .editar

	cmp ax, '4'
	je .deletar

	cmp ax, '5'
	je .listar_agencia

	cmp ax, '6'
	je .listar_contas
	

	.cadastro:
	call cadastro
	jmp .termina

	.busca:
	call busca
	jmp .termina

	.editar:
	call editar
	jmp .termina

	.deletar:
	call deletar
	jmp .termina

	.listar_agencia:
	call listar_agencia
	jmp .termina

	.listar_contas:
	call listar_contas
	jmp .termina

	.termina:

iret
