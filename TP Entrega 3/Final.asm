include macros2.asm
include number.asm
.MODEL  LARGE 
.386
.STACK 200h 
.CODE 
MAIN:


	 MOV AX,@DATA  ;inicializa el segmento de datos
	 MOV DS,AX 
	 MOV ES,AX 
	 FNINIT 

	 FILD @_2 
	 FSTP @_a 
	 FILD @_1 
	 FSTP @_b 
	 FILD @_b 
	 FILD @_a 
	 FXCH 
	 FADD 
	 FSTP @aux_1 
	 FILD @aux_1 
	 FSTP @_c 
	 DisplayFloat @_c,2 
