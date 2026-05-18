ljmp start

P5 equ 0F8H
P7 equ 0DBH

LCDstatus  equ 0FF2EH       
LCDcontrol equ 0FF2CH       
LCDdataWR  equ 0FF2DH       

#define  HOME     0x80     
#define  INITDISP 0x38     
#define  HOM2     0xc0     
#define  LCDON    0x0e     
#define  CLEAR    0x01     
	
#define LINE_1		0x7f	
#define LINE_2		0xbf	
#define	LINE_3		0xdf	
#define LINE_4		0xef	

ORG 000BH     
	CPL P3.2	
	PUSH ACC	
	MOV A, R6	
	MOV TH0, A 	
	MOV A, R7
	MOV TL0, A
	POP ACC      	
	RETI          

org 0477H
	jeden:	db "C1",00
org 057BH
	dwa:	db "Cis1",00
org 047DH
	trzy:	db "D1",00
org 067EH
	AA:	db "Dis1",00
org 04B7H
	cztery:	db "E1",00
org 05BBH
	piec:	db "F1",00
org 04BDH
	szesc:	db "Fis1",00
org 05BEH
	 BB:	db "G1",00
org 04D7H
	siedem:	db "Gis1",00
org 05DBH
	osiem:	db "A1",00
org 04DDH
	dziewiec: db "B1",00
org 05DEH
	CC:	db "H1",00
org 04E7H
	gwiazda: db "C2",00
org 05EBH
	zero:	db "Cis2",00
org 04EDH
	plotek:	db "D2",00
org 06EEH
	DD:	db "Dis2",00

org 0100H

// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x          ; x � parametr wywolania macra � bajt sterujacy
           LOCAL loop       ; LOCAL oznacza ze etykieta loop moze sie powt�rzyc w programie
loop: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,loop       ; testowanie najstarszego bitu akumulatora
                            ; � wskazuje gotowosc LCD
      MOV  DPTR,#LCDcontrol ; DPTR zaladowany adresem do podania bajtu sterujacego
      MOV  A, x             ; do akumulatora trafia argument wywolania macra�bajt sterujacy
      MOVX @DPTR,A          ; bajt sterujacy podany do LCD � zadana akcja widoczna na LCD
      ENDM
	  
// macro do wypisania znaku ASCII na LCD, znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO
      LOCAL tutu            ; LOCAL oznacza ze etykieta tutu moze sie powt�rzyc w programie
      PUSH ACC              ; odlozenie biezacej zawartosci akumulatora na stos
tutu: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,tutu       ; testowanie najstarszego bitu akumulatora
                            ; � wskazuje gotowosc LCD
      MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
      POP  ACC              ; w akumulatorze ponownie kod ASCII znaku na LCD
      MOVX @DPTR,A          ; kod ASCII podany do LCD � znak widoczny na LCD
      ENDM
	  
// macro do inicjalizacji wyswietlacza � bez parametr�w
init_LCD MACRO
         LCDcntrlWR #INITDISP ; wywolanie macra LCDcntrlWR � inicjalizacja LCD
         LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR � czyszczenie LCD
         LCDcntrlWR #LCDON    ; wywolanie macra LCDcntrlWR � konfiguracja kursora
         ENDM

	 delay:	mov r1, #0FFH
	zwei:	mov r2, #0FFH
    drei:	djnz r2, drei
			djnz r1, zwei
			ret

		 
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

// === TABELE DZWIEKOW ===

// Tablica dla brzmienia PODSTAWOWEGO (z program1)
keymuz_baza:		
			// Ladowanie TL0
			mov dptr, #8077H
			mov a, #89H
			movx @dptr, a
keymuz:		
			mov dptr, #8077H
			mov a, #89H
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #0F4H
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #5AH
			movx @dptr, a

			mov dptr, #807EH
			mov a, #0B9H
			movx @dptr, a

			mov dptr, #80B7H
			mov a, #13H
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #68H
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #0B9H
			movx @dptr, a

			mov dptr, #80BEH
			mov a, #04H
			movx @dptr, a

			mov dptr, #80D7H
			mov a, #4CH
			movx @dptr, a

			mov dptr, #80DBH
			mov a, #90H
			movx @dptr, a

			mov dptr, #80DDH
			mov a, #0CFH
			movx @dptr, a

			mov dptr, #80DEH
			mov a, #0CH
			movx @dptr, a

			mov dptr, #80E7H
			mov a, #45H
			movx @dptr, a

			mov dptr, #80EBH
			mov a, #7AH
			movx @dptr, a
			
			mov dptr, #80EDH
			mov a, #0ADH
			movx @dptr, a

			mov dptr, #80EEH
			mov a, #0DDH
			movx @dptr, a
			
			mov dptr, #8177H
			mov a, #0F8H
			movx @dptr, a
			
			mov dptr, #817BH
			mov a, #0F8H
			movx @dptr, a
			
			mov dptr, #817DH
			mov a, #0F9H
			movx @dptr, a

			mov dptr, #817EH
			mov a, #0F9H
			movx @dptr, a

			mov dptr, #81B7H
			mov a, #0FAH
			movx @dptr, a
			
			mov dptr, #81BBH
			mov a, #0FAH
			movx @dptr, a
			
			mov dptr, #81BDH
			mov a, #0FAH
			movx @dptr, a

			mov dptr, #81BEH
			mov a, #0FBH
			movx @dptr, a

			mov dptr, #81D7H
			mov a, #0FBH
			movx @dptr, a

			mov dptr, #81DBH
			mov a, #0FBH
			movx @dptr, a

			mov dptr, #81DDH
			mov a, #0FBH
			movx @dptr, a

			mov dptr, #81DEH
			mov a, #0FCH
			movx @dptr, a

			mov dptr, #81E7H
			mov a, #0FCH
			movx @dptr, a

			mov dptr, #81EBH
			mov a, #0FCH
			movx @dptr, a
			
			mov dptr, #81EDH
			mov a, #0FCH
			movx @dptr, a

			mov dptr, #81EEH
			mov a, #0FCH
			movx @dptr, a

			// prefiksy do adres�w nazw dzwiekow
			mov dptr, #8277H
			mov a, #04H
			movx @dptr, a
			
			mov dptr, #827BH
			mov a, #05H
			movx @dptr, a
			
			mov dptr, #827DH
			mov a, #04H
			movx @dptr, a

			mov dptr, #827EH
			mov a, #06H
			movx @dptr, a

			mov dptr, #82B7H
			mov a, #04H
			movx @dptr, a
			
			mov dptr, #82BBH
			mov a, #05H
			movx @dptr, a
			
			mov dptr, #82BDH
			mov a, #04H
			movx @dptr, a

			mov dptr, #82BEH
			mov a, #05H
			movx @dptr, a

			mov dptr, #82D7H
			mov a, #04H
			movx @dptr, a

			mov dptr, #82DBH
			mov a, #05H
			movx @dptr, a

			mov dptr, #82DDH
			mov a, #04H
			movx @dptr, a

			mov dptr, #82DEH
			mov a, #05H
			movx @dptr, a

			mov dptr, #82E7H
			mov a, #04H
			movx @dptr, a

			mov dptr, #82EBH
			mov a, #05H
			movx @dptr, a
			
			mov dptr, #82EDH
			mov a, #04H
			movx @dptr, a

			mov dptr, #82EEH
			mov a, #06H
			movx @dptr, a
								ret

// Tablica dla brzmienia OKTAWY (z program2)
keymuz_oktawa:		
			// Ladowanie TL0 (krotsze czasy z program2)
			mov dptr, #8077H
			mov a, #44H
			movx @dptr, a
keymuz:		
			mov dptr, #8077H
			mov a, #44H
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #7AH
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #0ADH
			movx @dptr, a

			mov dptr, #807EH
			mov a, #0DDH
			movx @dptr, a

			mov dptr, #80B7H
			mov a, #0AH
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #34H
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #5CH
			movx @dptr, a

			mov dptr, #80BEH
			mov a, #82H
			movx @dptr, a

			mov dptr, #80D7H
			mov a, #0A6H
			movx @dptr, a

			mov dptr, #80DBH
			mov a, #0C8H
			movx @dptr, a

			mov dptr, #80DDH
			mov a, #0E8H
			movx @dptr, a

			mov dptr, #80DEH
			mov a, #06H
			movx @dptr, a

			mov dptr, #80E7H
			mov a, #23H
			movx @dptr, a

			mov dptr, #80EBH
			mov a, #3DH
			movx @dptr, a
			
			mov dptr, #80EDH
			mov a, #57H
			movx @dptr, a

			mov dptr, #80EEH
			mov a, #6FH
			movx @dptr, a
			       //TH0
			mov dptr, #8177H
			mov a, #0FCH
			movx @dptr, a
			
			mov dptr, #817BH
			mov a, #0FCH
			movx @dptr, a
			
			mov dptr, #817DH
			mov a, #0FCH
			movx @dptr, a

			mov dptr, #817EH
			mov a, #0FCH
			movx @dptr, a

			mov dptr, #81B7H
			mov a, #0FDH
			movx @dptr, a
			
			mov dptr, #81BBH
			mov a, #0FDH
			movx @dptr, a
			
			mov dptr, #81BDH
			mov a, #0FDH
			movx @dptr, a

			mov dptr, #81BEH
			mov a, #0FDH
			movx @dptr, a

			mov dptr, #81D7H
			mov a, #0FDH
			movx @dptr, a

			mov dptr, #81DBH
			mov a, #0FDH
			movx @dptr, a

			mov dptr, #81DDH
			mov a, #0FDH
			movx @dptr, a

			mov dptr, #81DEH
			mov a, #0FEH
			movx @dptr, a

			mov dptr, #81E7H
			mov a, #0FEH
			movx @dptr, a

			mov dptr, #81EBH
			mov a, #0FEH
			movx @dptr, a
			
			mov dptr, #81EDH
			mov a, #0FEH
			movx @dptr, a

			mov dptr, #81EEH
			mov a, #0FEH
			movx @dptr, a

			// prefiksy do adresów nazw dzwiekow
			mov dptr, #8277H
			mov a, #04H
			movx @dptr, a
			
			mov dptr, #827BH
			mov a, #05H
			movx @dptr, a
			
			mov dptr, #827DH
			mov a, #04H
			movx @dptr, a

			mov dptr, #827EH
			mov a, #06H
			movx @dptr, a

			mov dptr, #82B7H
			mov a, #04H
			movx @dptr, a
			
			mov dptr, #82BBH
			mov a, #05H
			movx @dptr, a
			
			mov dptr, #82BDH
			mov a, #04H
			movx @dptr, a

			mov dptr, #82BEH
			mov a, #05H
			movx @dptr, a

			mov dptr, #82D7H
			mov a, #04H
			movx @dptr, a

			mov dptr, #82DBH
			mov a, #05H
			movx @dptr, a

			mov dptr, #82DDH
			mov a, #04H
			movx @dptr, a

			mov dptr, #82DEH
			mov a, #05H
			movx @dptr, a

			mov dptr, #82E7H
			mov a, #04H
			movx @dptr, a

			mov dptr, #82EBH
			mov a, #05H
			movx @dptr, a
			
			mov dptr, #82EDH
			mov a, #04H
			movx @dptr, a

			mov dptr, #82EEH
			mov a, #06H
			movx @dptr, a
								ret

// Podobnie mozesz dodac 'keymuz_tercja' i 'keymuz_kwinta' ladujac wlasciwe przeliczniki
 
// === PROGRAM GLOWNY ===
start:  	acall keymuz_baza
			MOV R3, #00H	; R3 przechowuje aktualny stan (0 = baza, 1 = oktawa, itd.)
			MOV TMOD, #01H 
			MOV IE, #82H  
			
graj:		MOV r4, #00H  
 			CLR TR0      
		
// --- SPRAWDZANIE PRZYCISKOW ZMIANY BRZMIENIA NA PORCIE P3 ---
check_mode_1:
			JB P3.3, check_mode_2	; Jesli P3.3 puszczony, idz dalej
			CJNE R3, #00H, load_baza ; Jesli wcisniety, ale juz jestesmy w trybie 0, zignoruj
			SJMP key_1
load_baza:	MOV R3, #00H			; Ustaw znacznik na tryb bazowy
			ACALL keymuz_baza		; Zaladuj nowe wartosci do XRAM
			SJMP key_1

check_mode_2:
			JB P3.4, key_1			; Jesli P3.4 puszczony, przejdz do grania
			CJNE R3, #01H, load_okt
			SJMP key_1
load_okt:	MOV R3, #01H			; Ustaw znacznik na tryb oktawy
			ACALL keymuz_oktawa
			SJMP key_1

// --- OBSLUGA KLAWIATURY (jak w Zadaniu 2) ---
key_1:		mov r0, #LINE_1
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0	
			jz key_2
			mov a, r2
			clr c
			subb a, r4	
			jz key_1
			mov a, r2
			mov r4,a	
			
			// Odczyt z XRAM i start dzwieku
			mov dph, #81h	
			mov dpl, a
			movx a,@dptr
			mov R6, a
			mov TH0, a
			mov a, r2
			mov dph, #80h	
			mov dpl, a
			movx a,@dptr
			mov R7, a
			mov TL0, a
			setb TR0	

			// Wyswietlanie na LCD
			mov a, r4
			mov dph, #82h
			mov dpl, a
			movx a, @dptr
			mov dph, a
			mov a, r4
			mov dpl, a
			clr a
			movc a, @a+dptr
			push dph
			push dpl
			LCDcntrlWR #CLEAR
			LCDcntrlWR #HOME
			pop dpl
			pop dph
			acall putstrLCD
			jmp key_1
			
key_2:		mov r0, #LINE_2
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_3
			mov a, r2
			clr c
			subb a, r4
			jz key_2
			mov a, r2
			mov r4, a
			mov a, r2
			mov dph, #81h
			mov dpl, a
			movx a,@dptr
			mov R6, a
			mov TH0, a
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov R7, a
			mov TL0, a
			setb TR0
			jmp key_2
			
key_3:		mov r0, #LINE_3
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_4
			mov a, r2
			clr c
			subb a, r4
			jz key_3
			mov a, r2
			mov r4,a
			mov dph, #81h
			mov dpl, a
			movx a,@dptr
			mov R6, a
			mov TH0, a
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov R7, a
			mov TL0, a
			setb TR0
			jmp key_3
			
key_4:		mov r0, #LINE_4
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz dalej
			mov a, r2
			clr c
			subb a, r4
			jz key_4
			mov a, r2
			mov r4,a
			mov dph, #81h
			mov dpl, a
			movx a,@dptr
			mov R6, a
			mov TH0, a
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov R7, a
			mov TL0, a
			setb TR0
			jmp key_4	
			
dalej:		jmp graj    
 
    nop
    jmp $
    end start