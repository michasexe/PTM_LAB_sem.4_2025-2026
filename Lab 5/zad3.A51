ljmp start

P5 equ 0F8H
P7 equ 0DBH
	
LCDstatus  equ 0FF2EH       ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH       ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF2DH       ; adres do podania kodu ASCII na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME     0x80     // put cursor to second line  
#define  INITDISP 0x38     // LCD init (8-bit mode)  
#define  HOM2     0xc0     // put cursor to second line  
#define  LCDON    0x0e     // LCD nn, cursor off, blinking off
#define  CLEAR    0x01     // LCD display clear

// linie klawiatury - sterowanie na port P5
#define LINE_1		0x7f	// 0111 1111
#define LINE_2		0xbf	// 1011 1111
#define	LINE_3		0xdf	// 1101 1111
#define LINE_4		0xef	// 1110 1111
#define ALL_LINES	0x0f	// 0000 1111

ORG 000BH     				; obsluga przerwania
	MOV TH0, #3CH 			; przeladowanie
	MOV TL0, #0B0H 			; stalej timera na 50ms
	DEC R0        			; korekta licznika
	RETI          			; powrót z przerwania

org 0100H
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x          
           LOCAL loop       
loop: MOV  DPTR,#LCDstatus  
      MOVX A,@DPTR          
      JB   ACC.7,loop       
      MOV  DPTR,#LCDcontrol 
      MOV  A, x             
      MOVX @DPTR,A          
      ENDM
	  
// macro do wypisania znaku ASCII na LCD
LCDcharWR MACRO
      LOCAL tutu            
      PUSH ACC              
tutu: MOV  DPTR,#LCDstatus  
      MOVX A,@DPTR          
      JB   ACC.7,tutu       
      MOV  DPTR,#LCDdataWR  
      POP  ACC              
      MOVX @DPTR,A          
      ENDM
	  
// macro do inicjalizacji wyswietlacza 
init_LCD MACRO
         LCDcntrlWR #INITDISP 
         LCDcntrlWR #CLEAR    
         LCDcntrlWR #LCDON    
         ENDM
		 
// funkcja wypisania liczby dla potrzeb zegara
putdigitLCD:	mov b, #10
				div ab				
				add a, #30H			
				acall putcharLCD
				mov a, b			
				add a, #30H			
				acall putcharLCD
				ret

// funkcaj wypisywania znaku na LCD
putcharLCD:	LCDcharWR
			ret

delay:		mov r1, #0FFH
dwa:		mov r2, #0FFH
trzy:		djnz r2, trzy
			djnz r1, dwa
			ret

// tablica przekodowania klawisze - ASCII w XRAM
keyascii_num:	
			mov dptr, #80EBH
			mov a, #0
			movx @dptr, a
			mov dptr, #8077H
			mov a, #1
			movx @dptr, a
			mov dptr, #807BH
			mov a, #2
			movx @dptr, a
			mov dptr, #807DH
			mov a, #3
			movx @dptr, a
			mov dptr, #80B7H
			mov a, #4
			movx @dptr, a
			mov dptr, #80BBH
			mov a, #5
			movx @dptr, a
			mov dptr, #80BDH
			mov a, #6
			movx @dptr, a
			mov dptr, #80D7H
			mov a, #7
			movx @dptr, a
			mov dptr, #80DBH
			mov a, #8
			movx @dptr, a
			mov dptr, #80DDH
			mov a, #9
			movx @dptr, a
			mov dptr, #807EH
			mov a, #"A"
			movx @dptr, a
			mov dptr, #80BEH
			mov a, #"B"
			movx @dptr, a
			mov dptr, #80DEH
			mov a, #"C"
			movx @dptr, a
			mov dptr, #80EEH
			mov a, #"D"
			movx @dptr, a
			mov dptr, #80E7H
			mov a, #"*"
			movx @dptr, a
			mov dptr, #80EDH
			mov a, #"#"
			movx @dptr, a
			ret
		 
// wyznaczanie biezacej wartosci zegara i jego wyswietlanie na LCD
ZEGAR:		INC R7
			MOV A, R7
			CLR C
			SUBB A, #60
			JZ MINUTY
			JMP EKRAN
MINUTY:		MOV R7, #00H
			INC R6
			MOV A, R6
			CLR C
			SUBB A, #60
			JZ GODZINY
			JMP EKRAN
GODZINY:	MOV R6, #00H
			INC R5
			MOV A, R5
			CLR C
			SUBB A, #24
			JNZ EKRAN
			MOV R5, #00H
EKRAN:		LCDcntrlWR #HOME
			MOV A, R5
			ACALL putdigitLCD
			MOV A, #":"
			ACALL putcharLCD
			MOV A, R6
			ACALL putdigitLCD
			MOV A, #":"
			ACALL putcharLCD
			MOV A, R7
			ACALL putdigitLCD
			
			; SPRWADZENIE CZASU BUDZENIA
			MOV A, R5
			CJNE A, 30H, ALARM_OFF ; 30H - godziny budzika
			MOV A, R6
			CJNE A, 31H, ALARM_OFF ; 31H - minuty budzika
			CLR P6.0               ; Wlacz brzeczyk na P6.0
			JMP WYSWIETL_WPROWADZANIE
ALARM_OFF:	SETB P6.0              ; Wylacz brzeczyk
			
WYSWIETL_WPROWADZANIE:
			LCDcntrlWR #HOM2
			mov a, r4
			acall putdigitLCD
			mov a, r3
			acall putdigitLCD
FINAL:		RET

ostatniedwie:
			mov a, r3
			mov r4, a
			movx a, @dptr
			mov r3, a
			acall delay
			ljmp key_1

        ; program glówny
START:	init_LCD
		MOV TMOD, #01H 			
		MOV TH0, #3CH 			
		MOV TL0, #0B0H 			
		; USUNIETO SETB TR0 - timer czeka na wpisanie czasu
		MOV IE, #82H  			
		MOV R5, #00H			
		MOV R6, #00H
		MOV R7, #0FFH
		MOV 30H, #99H           ; Inicjalizacja komorki godzin budzika na 99 (bezpieczna)
		MOV 31H, #99H           ; Inicjalizacja komorki minut budzika na 99
		SETB P6.0               ; Domyslne wylaczenie budzika (aktywny niska)
		ACALL ZEGAR				
		MOV A, #0FH
		MOV P1, A    			
		MOV R0, #20 			
		acall keyascii_num
		mov r3, #0
		mov r4, #0

CZEKAM: 
		key_1:	mov r1, #LINE_1
			mov	a, r1
			mov	P5, a
			mov a, P7
			anl a, r1
			mov r2, a
			clr c
			subb a, r1
			jz key_2
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a, @dptr
			clr c
			subb a, #"A"
			jnz  ostatniedwie
			MOV TH0, #3CH 			
			MOV TL0, #0B0H 			
			SETB TR0      			; Awaryjny start klawiszem A

	key_2:	mov r1, #LINE_2
			mov	a, r1
			mov	P5, a
			mov a, P7
			anl a, r1
			mov r2, a
			clr c
			subb a, r1
			jz key_3
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a, @dptr
			clr c
			subb a, #"B"
			jnz  jumpostatniedwie
			clr TR0
			
	key_3:	mov r1, #LINE_3
			mov	a, r1
			mov	P5, a
			mov a, P7
			anl a, r1
			mov r2, a
			clr c
			subb a, r1
			jz key_4
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a, @dptr
			clr c
			subb a, #"C"
			jnz  jumpostatniedwie
			ljmp START
			
	key_4:	mov r1, #LINE_4
			mov	a, r1
			mov	P5, a
			mov a, P7
			anl a, r1
			mov r2, a
			clr c
			subb a, r1
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a, @dptr
			clr c
			subb a, #"#"
			jz USTAWIENIE_GODZIN_BUDZIKA   ; Znak # - zatwierdza godziny
			movx a, @dptr
			subb a, #"*"
			jz USTAWIENIE_MINUT_BUDZIKA    ; Znak * - zatwierdza minuty i odpala czas
			movx a, @dptr
			jz jumpostatniedwie
		
		MOV A, R0   			
		JNZ CZEKAM   			
		MOV R0, #20				
		ACALL ZEGAR				
		MOV A, P1  				
		CPL A       			
		MOV P1, A    			
		JMP CZEKAM    			
		NOP
		NOP
		NOP
		JMP $

	USTAWIENIE_GODZIN_BUDZIKA:
		mov a, r4
		mov b, #10
		mul ab
		add a, r3
		mov b, #24
		div ab
		mov 30H, b              ; Zapisz godziny budzika do RAM 30H
		mov r3, #0              ; Wyzeruj bufor jednosci
		mov r4, #0              ; Wyzeruj bufor dziesiatek
		ljmp key_1
		
	USTAWIENIE_MINUT_BUDZIKA:
		mov a, r4
		mov b, #10
		mul ab
		add a, r3
		mov b, #60
		div ab
		mov 31H, b              ; Zapisz minuty budzika do RAM 31H
		mov r3, #0              ; Wyzeruj bufor jednosci
		mov r4, #0              ; Wyzeruj bufor dziesiatek
		SETB TR0                ; Po wpisaniu budzika START TIMER!
		ljmp key_1
		
	jumpostatniedwie:
		ljmp ostatniedwie

END START
