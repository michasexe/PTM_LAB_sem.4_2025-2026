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

// linie klawiatury - sterowanie na port P5 (skorygowano na standardowe 4 linie)
#define LINE_1      0x7f    // 0111 1111
#define LINE_2      0xbf    // 1011 1111
#define LINE_3      0xdf    // 1101 1111
#define LINE_4      0xef    // 1110 1111
#define ALL_LINES   0x0f    // 0000 1111

ORG 000BH     				; obsluga przerwania
	MOV TH0, #3CH 			; przeladowanie
	MOV TL0, #0B0H 			; stalej timera na 50ms
	DEC R0        			; korekta licznika
	RETI          			; powrót z przerwania

org 0100H
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x          ; x – parametr wywolania macra – bajt sterujacy
           LOCAL loop       ; LOCAL oznacza ze etykieta loop moze sie powtórzyc w programie
loop: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,loop       ; testowanie najstarszego bitu akumulatora
                            ; – wskazuje gotowosc LCD
      MOV  DPTR,#LCDcontrol ; DPTR zaladowany adresem do podania bajtu sterujacego
      MOV  A, x             ; do akumulatora trafia argument wywolania macra–bajt sterujacy
      MOVX @DPTR,A          ; bajt sterujacy podany do LCD – zadana akcja widoczna na LCD
      ENDM
	  
// macro do wypisania znaku ASCII na LCD, znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO
      LOCAL tutu            ; LOCAL oznacza ze etykieta tutu moze sie powtórzyc w programie
      PUSH ACC              ; odlozenie biezacej zawartosci akumulatora na stos
tutu: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,tutu       ; testowanie najstarszego bitu akumulatora
                            ; – wskazuje gotowosc LCD
      MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
      POP  ACC              ; w akumulatorze ponownie kod ASCII znaku na LCD
      MOVX @DPTR,A          ; kod ASCII podany do LCD – znak widoczny na LCD
      ENDM
	  
// macro do inicjalizacji wyswietlacza – bez parametrów
init_LCD MACRO
         LCDcntrlWR #INITDISP ; wywolanie macra LCDcntrlWR – inicjalizacja LCD
         LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR – czyszczenie LCD
         LCDcntrlWR #LCDON    ; wywolanie macra LCDcntrlWR – konfiguracja kursora
         ENDM
		 
// funkcja wypisania liczby dla potrzeb zegara
putdigitLCD:	mov b, #10
				div ab				; uzyskanie cyfry dziesiatek
				add a, #30H			; konwersja cyfry na kod ASCII
				acall putcharLCD
				mov a, b			; ladowanie cyfry jednosci
				add a, #30H			; konwersja na LCD
				acall putcharLCD
				ret

// funkcaj wypisywania znaku na LCD
putcharLCD:	LCDcharWR
			ret

; ==========================================================
; PROCEDURY KLAWIATURY MATRYCOWEJ I USTAWIANIA CZASU
; ==========================================================
DELAY_KBD:
        MOV R2, #40
DK1:    MOV R3, #250
DK2:    DJNZ R3, DK2
        DJNZ R2, DK1
        RET

GET_KEY:
WAIT_PRESS:
        MOV P5, #ALL_LINES
        MOV A, P7
        CPL A
        ANL A, #0FH
        JZ WAIT_PRESS
        ACALL DELAY_KBD
        MOV P5, #ALL_LINES
        MOV A, P7
        CPL A
        ANL A, #0FH
        JZ WAIT_PRESS

        MOV P5, #LINE_1
        MOV A, P7
        CPL A
        ANL A, #0FH
        JNZ ROW_1

        MOV P5, #LINE_2
        MOV A, P7
        CPL A
        ANL A, #0FH
        JNZ ROW_2

        MOV P5, #LINE_3
        MOV A, P7
        CPL A
        ANL A, #0FH
        JNZ ROW_3

        MOV P5, #LINE_4
        MOV A, P7
        CPL A
        ANL A, #0FH
        JNZ ROW_4
        SJMP WAIT_PRESS

ROW_1:  CJNE A, #01H, R1_2
        MOV R4, #1
        SJMP WAIT_REL
R1_2:   CJNE A, #02H, R1_3
        MOV R4, #2
        SJMP WAIT_REL
R1_3:   MOV R4, #3
        SJMP WAIT_REL

ROW_2:  CJNE A, #01H, R2_2
        MOV R4, #4
        SJMP WAIT_REL
R2_2:   CJNE A, #02H, R2_3
        MOV R4, #5
        SJMP WAIT_REL
R2_3:   MOV R4, #6
        SJMP WAIT_REL

ROW_3:  CJNE A, #01H, R3_2
        MOV R4, #7
        SJMP WAIT_REL
R3_2:   CJNE A, #02H, R3_3
        MOV R4, #8
        SJMP WAIT_REL
R3_3:   MOV R4, #9
        SJMP WAIT_REL

ROW_4:  CJNE A, #01H, R4_2
        MOV R4, #11         ; '*'
        SJMP WAIT_REL
R4_2:   CJNE A, #02H, R4_3
        MOV R4, #0          ; '0'
        SJMP WAIT_REL
R4_3:   MOV R4, #10         ; '#'

WAIT_REL:
        MOV P5, #ALL_LINES
        MOV A, P7
        CPL A
        ANL A, #0FH
        JNZ WAIT_REL
        MOV A, R4
        RET

POBIERZ_CYFRE:
        ACALL GET_KEY
        CJNE A, #10, CHK_STAR
        SJMP POBIERZ_CYFRE  ; ignoruj #
CHK_STAR:
        CJNE A, #11, GOT_DIGIT
        SJMP POBIERZ_CYFRE  ; ignoruj *
GOT_DIGIT:
        RET

USTAW_CZAS:
USTAW_H:
        LCDcntrlWR #CLEAR
        ; Pobranie 1 cyfry (dziesiatki godzin)
        ACALL POBIERZ_CYFRE
        MOV B, A          
        ADD A, #30H
        ACALL putcharLCD
        MOV A, B
        MOV R2, A
        ; Pobranie 2 cyfry (jednosci godzin)
        ACALL POBIERZ_CYFRE
        MOV B, A          
        ADD A, #30H
        ACALL putcharLCD
        MOV A, B
        MOV R3, A
CZEKAJ_ZATW_H:
        ACALL GET_KEY
        CJNE A, #10, CZEKAJ_ZATW_H ; Czekaj na #
        
        ; Obliczenie wartosci (R2 * 10 + R3)
        MOV A, R2
        MOV B, #10
        MUL AB
        ADD A, R3
        MOV R5, A          
        
        ; Kontrola zakresu (<= 23)
        CLR C
        SUBB A, #24
        JNC USTAW_H        ; Jesli za duza wartosc, powtórz

USTAW_M:
        LCDcntrlWR #CLEAR
        MOV A, R5
        ACALL putdigitLCD
        MOV A, #":"
        ACALL putcharLCD

        ; Pobranie 1 cyfry (dziesiatki minut)
        ACALL POBIERZ_CYFRE
        MOV B, A          
        ADD A, #30H
        ACALL putcharLCD
        MOV A, B
        MOV R2, A
        ; Pobranie 2 cyfry (jednosci minut)
        ACALL POBIERZ_CYFRE
        MOV B, A          
        ADD A, #30H
        ACALL putcharLCD
        MOV A, B
        MOV R3, A
CZEKAJ_ZATW_M:
        ACALL GET_KEY
        CJNE A, #10, CZEKAJ_ZATW_M ; Czekaj na #

        ; Obliczenie wartosci (R2 * 10 + R3)
        MOV A, R2
        MOV B, #10
        MUL AB
        ADD A, R3
        MOV R6, A          

        ; Kontrola zakresu (<= 59)
        CLR C
        SUBB A, #60
        JNC USTAW_M        ; Jesli za duza wartosc, powtórz

        LCDcntrlWR #CLEAR
        RET
; ==========================================================

// wyznaczanie biezacej wartosci zegara i jego wyswietlanie na LCD
ZEGAR:		INC R7				; licznik sekund
			MOV A, R7			; obsluga sekund
			CLR C
			SUBB A, #60			; przepelnienie sekund
			JZ MINUTY
			LCDcntrlWR #HOME	; wyswietlenie calego zegara
			MOV A, R5			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R6			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R7			; sekundy
			ACALL putdigitLCD
			JMP FINAL
MINUTY:		MOV R7, #00H		; zerowanie sekund
			INC R6				; licznik minut
			MOV A, R6			; obsluga minut
			CLR C
			SUBB A, #60			; przepelnienie minut
			JZ GODZINY
			LCDcntrlWR #HOME	; wyswietlenie calego zegara
			MOV A, R5			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R6			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R7			; sekundy
			ACALL putdigitLCD
			JMP FINAL
GODZINY:	MOV R6, #00H		; zerowanie minut
			INC R5				; licznik godzin
			MOV A, R5
			CLR C
			SUBB A, #24			; przepelenienie godzin - doba
			JNZ EKRAN
			MOV R5, #00H		; zerowanie godzin
EKRAN:		LCDcntrlWR #HOME	; wyswietlenie calego zegara
			MOV A, R5			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R6			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R7			; sekundy
			ACALL putdigitLCD
FINAL:		RET

        ; program glówny
START:	init_LCD
        ACALL USTAW_CZAS        ; wprowadzanie godzin i minut przed startem zegara

		MOV TMOD, #01H 			; konfiguracja timera
		MOV TH0, #3CH 			; ladowanie
		MOV TL0, #0B0H 			; stalej timera na 50ms
		; TR0 jest wlaczone dopiero guzikiem z P3.0
		MOV IE, #82H  			; przerwania wlacz
		MOV R7, #0FFH           ; inicjalizacja sekund z FFH (ZEGAR zaraz zrobi inkrement na 00H)
		ACALL ZEGAR				; wyswietlenie zainicjowanego zegara
		MOV A, #0FH
		MOV P1, A    			; zapalenie diód
		MOV R0, #20 			; licznik odmierzen 20 x 50ms

CZEKAM: 
        ; --- START/STOP ZEGARA ---
        JB P3.0, SPR_STOP
        SETB TR0                ; P3.0 - START
SPR_STOP:
        JB P3.1, SPR_PLUS
        CLR TR0                 ; P3.1 - STOP

        ; --- REGULACJA GODZIN IN PLUS/MINUS ---
SPR_PLUS:
        JB P3.2, SPR_MINUS
        INC R5
        MOV A, R5
        CJNE A, #24, OMIJAJ_P
        MOV R5, #00H
OMIJAJ_P:
        ACALL EKRAN             ; Aktualizacja samego ekranu
CZEKAJ_P:
        JNB P3.2, CZEKAJ_P      ; Czekaj na puszczenie guzika

SPR_MINUS:
        JB P3.3, SPR_TIMER
        DEC R5
        MOV A, R5
        CJNE A, #0FFH, OMIJAJ_M
        MOV R5, #23
OMIJAJ_M:
        ACALL EKRAN             ; Aktualizacja samego ekranu
CZEKAJ_M:
        JNB P3.3, CZEKAJ_M      ; Czekaj na puszczenie guzika

SPR_TIMER:
        MOV A, R0   			; czekam, a timer
		JNZ CZEKAM   			; mierzy laczny czas 1s
		MOV R0, #20				; po zgloszeniu przerwania - ustawiam na nowo licznik odmierzen 20 x 50ms
		ACALL ZEGAR				; uruchomienie procedury oblugi i wyswietlenia zegara
		MOV A, P1  				; zmiana
		CPL A       			; swiecenia
		MOV P1, A    			; diód
		JMP CZEKAM    			; czekam na kolejna sekunde
		NOP
		NOP
		NOP
		JMP $
END START
