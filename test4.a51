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

// =========================================================
// TABLICE NAPISOW (Przesuniete w gore pamieci zeby zrobic miejsce na kod)
// =========================================================

// --- BAZA (Prefiksy 24, 25, 26) ---
org 2477H
	b_jeden:	db "C1",00
org 257BH
	b_dwa:		db "Cis1",00
org 247DH
	b_trzy:		db "D1",00
org 267EH
	b_AA:		db "Dis1",00
org 24B7H
	b_cztery:	db "E1",00
org 25BBH
	b_piec:		db "F1",00
org 24BDH
	b_szesc:	db "Fis1",00
org 25BEH
	b_BB:		db "G1",00
org 24D7H
	b_siedem:	db "Gis1",00
org 25DBH
	b_osiem:	db "A1",00
org 24DDH
	b_dziewiec: db "B1",00
org 25DEH
	b_CC:		db "H1",00
org 24E7H
	b_gwiazda: 	db "C2",00
org 25EBH
	b_zero:		db "Cis2",00
org 24EDH
	b_plotek:	db "D2",00
org 26EEH
	b_DD:		db "Dis2",00

// --- TERCJA (Prefiksy 27, 28, 29) ---
org 2777H
	t_jeden:	db "E1",00
org 287BH
	t_dwa:		db "F1",00
org 277DH
	t_trzy:		db "Fis1",00
org 297EH
	t_AA:		db "G1",00
org 27B7H
	t_cztery:	db "Gis1",00
org 28BBH
	t_piec:		db "A1",00
org 27BDH
	t_szesc:	db "B1",00
org 28BEH
	t_BB:		db "H1",00
org 27D7H
	t_siedem:	db "C2",00
org 28DBH
	t_osiem:	db "Cis2",00
org 27DDH
	t_dziewiec: db "D2",00
org 28DEH
	t_CC:		db "Dis2",00
org 27E7H
	t_gwiazda: 	db "E2",00
org 28EBH
	t_zero:		db "F2",00
org 27EDH
	t_plotek:	db "Fis2",00
org 29EEH
	t_DD:		db "G2",00

// --- KWINTA (Prefiksy 2A, 2B, 2C) ---
org 2A77H
	k_jeden:	db "G1",00
org 2B7BH
	k_dwa:		db "Gis1",00
org 2A7DH
	k_trzy:		db "A1",00
org 2C7EH
	k_AA:		db "B1",00
org 2AB7H
	k_cztery:	db "H1",00
org 2BBBH
	k_piec:		db "C2",00
org 2ABDH
	k_szesc:	db "Cis2",00
org 2BBEH
	k_BB:		db "D2",00
org 2AD7H
	k_siedem:	db "Dis2",00
org 2BDBH
	k_osiem:	db "E2",00
org 2ADDH
	k_dziewiec: db "F2",00
org 2BDEH
	k_CC:		db "Fis2",00
org 2AE7H
	k_gwiazda: 	db "G2",00
org 2BEBH
	k_zero:		db "Gis2",00
org 2AEDH
	k_plotek:	db "A2",00
org 2CEEH
	k_DD:		db "B2",00

// --- OKTAWA (Prefiksy 2D, 2E, 2F) ---
org 2D77H
	o_jeden:	db "C2",00
org 2E7BH
	o_dwa:		db "Cis2",00
org 2D7DH
	o_trzy:		db "D2",00
org 2F7EH
	o_AA:		db "Dis2",00
org 2DB7H
	o_cztery:	db "E2",00
org 2EBBH
	o_piec:		db "F2",00
org 2DBDH
	o_szesc:	db "Fis2",00
org 2EBEH
	o_BB:		db "G2",00
org 2DD7H
	o_siedem:	db "Gis2",00
org 2EDBH
	o_osiem:	db "A2",00
org 2DDDH
	o_dziewiec: db "B2",00
org 2EDEH
	o_CC:		db "H2",00
org 2DE7H
	o_gwiazda: 	db "C3",00
org 2EEBH
	o_zero:		db "Cis3",00
org 2DEDH
	o_plotek:	db "D3",00
org 2FEEH
	o_DD:		db "Dis3",00


// =========================================================
org 0100H
// =========================================================

// --- MAKRA LCD ---
LCDcntrlWR MACRO x
           LOCAL loop
loop: MOV  DPTR,#LCDstatus 
      MOVX A,@DPTR         
      JB   ACC.7,loop      
      MOV  DPTR,#LCDcontrol 
      MOV  A, x             
      MOVX @DPTR,A          
      ENDM
	  
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
	  
init_LCD MACRO
         LCDcntrlWR #INITDISP 
         LCDcntrlWR #CLEAR    
         LCDcntrlWR #LCDON    
         ENDM

delay:	mov r1, #0FFH
zwei:	mov r2, #0FFH
drei:	djnz r2, drei
		djnz r1, zwei
		ret

putdigitLCD:	mov b, #10
				div ab				
				add a, #30H			
				acall putcharLCD
				mov a, b			
				add a, #30H			
				acall putcharLCD
				ret

putcharLCD:	LCDcharWR
			ret

putstrLCD: clr a
		movc a, @a+dptr
		jz koniec
		push dph
		push dpl
		acall putcharLCD
		pop dpl
		pop dph
		inc dptr
		sjmp putstrLCD
koniec: ret


// =========================================================
// TABLICE KONFIGURACYJNE KEYMUZ
// =========================================================

// ----------- BAZA -----------
keymuz_baza:		
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
			
			// TH0
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

			// Prefiksy LCD (teraz zaczynaja sie od 24)
			mov dptr, #8277H
			mov a, #24H
			movx @dptr, a
			mov dptr, #827BH
			mov a, #25H
			movx @dptr, a
			mov dptr, #827DH
			mov a, #24H
			movx @dptr, a
			mov dptr, #827EH
			mov a, #26H
			movx @dptr, a
			mov dptr, #82B7H
			mov a, #24H
			movx @dptr, a
			mov dptr, #82BBH
			mov a, #25H
			movx @dptr, a
			mov dptr, #82BDH
			mov a, #24H
			movx @dptr, a
			mov dptr, #82BEH
			mov a, #25H
			movx @dptr, a
			mov dptr, #82D7H
			mov a, #24H
			movx @dptr, a
			mov dptr, #82DBH
			mov a, #25H
			movx @dptr, a
			mov dptr, #82DDH
			mov a, #24H
			movx @dptr, a
			mov dptr, #82DEH
			mov a, #25H
			movx @dptr, a
			mov dptr, #82E7H
			mov a, #24H
			movx @dptr, a
			mov dptr, #82EBH
			mov a, #25H
			movx @dptr, a
			mov dptr, #82EDH
			mov a, #24H
			movx @dptr, a
			mov dptr, #82EEH
			mov a, #26H
			movx @dptr, a
			ret

// ----------- TERCJA (+4 poltony) -----------
keymuz_tercja:		
			mov dptr, #8077H
			mov a, #13H
			movx @dptr, a
			mov dptr, #807BH
			mov a, #68H
			movx @dptr, a
			mov dptr, #807DH
			mov a, #0B9H
			movx @dptr, a
			mov dptr, #807EH
			mov a, #04H
			movx @dptr, a
			mov dptr, #80B7H
			mov a, #4CH
			movx @dptr, a
			mov dptr, #80BBH
			mov a, #90H
			movx @dptr, a
			mov dptr, #80BDH
			mov a, #0CFH
			movx @dptr, a
			mov dptr, #80BEH
			mov a, #0CH
			movx @dptr, a
			mov dptr, #80D7H
			mov a, #45H
			movx @dptr, a
			mov dptr, #80DBH
			mov a, #7AH
			movx @dptr, a
			mov dptr, #80DDH
			mov a, #0ADH
			movx @dptr, a
			mov dptr, #80DEH
			mov a, #0DDH
			movx @dptr, a
			mov dptr, #80E7H
			mov a, #0AH
			movx @dptr, a
			mov dptr, #80EBH
			mov a, #34H
			movx @dptr, a
			mov dptr, #80EDH
			mov a, #5CH
			movx @dptr, a
			mov dptr, #80EEH
			mov a, #82H
			movx @dptr, a
			
			// TH0
			mov dptr, #8177H
			mov a, #0FAH
			movx @dptr, a
			mov dptr, #817BH
			mov a, #0FAH
			movx @dptr, a
			mov dptr, #817DH
			mov a, #0FAH
			movx @dptr, a
			mov dptr, #817EH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #81B7H
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #81BBH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #81BDH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #81BEH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #81D7H
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #81DBH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #81DDH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #81DEH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #81E7H
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #81EBH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #81EDH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #81EEH
			mov a, #0FDH
			movx @dptr, a

			// Prefiksy LCD 
			mov dptr, #8277H
			mov a, #27H
			movx @dptr, a
			mov dptr, #827BH
			mov a, #28H
			movx @dptr, a
			mov dptr, #827DH
			mov a, #27H
			movx @dptr, a
			mov dptr, #827EH
			mov a, #29H
			movx @dptr, a
			mov dptr, #82B7H
			mov a, #27H
			movx @dptr, a
			mov dptr, #82BBH
			mov a, #28H
			movx @dptr, a
			mov dptr, #82BDH
			mov a, #27H
			movx @dptr, a
			mov dptr, #82BEH
			mov a, #28H
			movx @dptr, a
			mov dptr, #82D7H
			mov a, #27H
			movx @dptr, a
			mov dptr, #82DBH
			mov a, #28H
			movx @dptr, a
			mov dptr, #82DDH
			mov a, #27H
			movx @dptr, a
			mov dptr, #82DEH
			mov a, #28H
			movx @dptr, a
			mov dptr, #82E7H
			mov a, #27H
			movx @dptr, a
			mov dptr, #82EBH
			mov a, #28H
			movx @dptr, a
			mov dptr, #82EDH
			mov a, #27H
			movx @dptr, a
			mov dptr, #82EEH
			mov a, #29H
			movx @dptr, a
			ret

// ----------- KWINTA (+7 poltonow) -----------
keymuz_kwinta:		
			mov dptr, #8077H
			mov a, #04H
			movx @dptr, a
			mov dptr, #807BH
			mov a, #4CH
			movx @dptr, a
			mov dptr, #807DH
			mov a, #90H
			movx @dptr, a
			mov dptr, #807EH
			mov a, #0CFH
			movx @dptr, a
			mov dptr, #80B7H
			mov a, #0CH
			movx @dptr, a
			mov dptr, #80BBH
			mov a, #45H
			movx @dptr, a
			mov dptr, #80BDH
			mov a, #7AH
			movx @dptr, a
			mov dptr, #80BEH
			mov a, #0ADH
			movx @dptr, a
			mov dptr, #80D7H
			mov a, #0DDH
			movx @dptr, a
			mov dptr, #80DBH
			mov a, #0AH
			movx @dptr, a
			mov dptr, #80DDH
			mov a, #34H
			movx @dptr, a
			mov dptr, #80DEH
			mov a, #5CH
			movx @dptr, a
			mov dptr, #80E7H
			mov a, #82H
			movx @dptr, a
			mov dptr, #80EBH
			mov a, #0A6H
			movx @dptr, a
			mov dptr, #80EDH
			mov a, #0C8H
			movx @dptr, a
			mov dptr, #80EEH
			mov a, #0E8H
			movx @dptr, a
			
			// TH0
			mov dptr, #8177H
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #817BH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #817DH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #817EH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #81B7H
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #81BBH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #81BDH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #81BEH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #81D7H
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #81DBH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #81DDH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #81DEH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #81E7H
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #81EBH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #81EDH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #81EEH
			mov a, #0FDH
			movx @dptr, a

			// Prefiksy LCD
			mov dptr, #8277H
			mov a, #2AH
			movx @dptr, a
			mov dptr, #827BH
			mov a, #2BH
			movx @dptr, a
			mov dptr, #827DH
			mov a, #2AH
			movx @dptr, a
			mov dptr, #827EH
			mov a, #2CH
			movx @dptr, a
			mov dptr, #82B7H
			mov a, #2AH
			movx @dptr, a
			mov dptr, #82BBH
			mov a, #2BH
			movx @dptr, a
			mov dptr, #82BDH
			mov a, #2AH
			movx @dptr, a
			mov dptr, #82BEH
			mov a, #2BH
			movx @dptr, a
			mov dptr, #82D7H
			mov a, #2AH
			movx @dptr, a
			mov dptr, #82DBH
			mov a, #2BH
			movx @dptr, a
			mov dptr, #82DDH
			mov a, #2AH
			movx @dptr, a
			mov dptr, #82DEH
			mov a, #2BH
			movx @dptr, a
			mov dptr, #82E7H
			mov a, #2AH
			movx @dptr, a
			mov dptr, #82EBH
			mov a, #2BH
			movx @dptr, a
			mov dptr, #82EDH
			mov a, #2AH
			movx @dptr, a
			mov dptr, #82EEH
			mov a, #2CH
			movx @dptr, a
			ret

// ----------- OKTAWA (+12 poltonow) -----------
keymuz_oktawa:		
			mov dptr, #8077H
			mov a, #45H
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
			mov a, #56H
			movx @dptr, a
			mov dptr, #80EEH
			mov a, #6EH
			movx @dptr, a
			
			// TH0
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

			// Prefiksy LCD
			mov dptr, #8277H
			mov a, #2DH
			movx @dptr, a
			mov dptr, #827BH
			mov a, #2EH
			movx @dptr, a
			mov dptr, #827DH
			mov a, #2DH
			movx @dptr, a
			mov dptr, #827EH
			mov a, #2FH
			movx @dptr, a
			mov dptr, #82B7H
			mov a, #2DH
			movx @dptr, a
			mov dptr, #82BBH
			mov a, #2EH
			movx @dptr, a
			mov dptr, #82BDH
			mov a, #2DH
			movx @dptr, a
			mov dptr, #82BEH
			mov a, #2EH
			movx @dptr, a
			mov dptr, #82D7H
			mov a, #2DH
			movx @dptr, a
			mov dptr, #82DBH
			mov a, #2EH
			movx @dptr, a
			mov dptr, #82DDH
			mov a, #2DH
			movx @dptr, a
			mov dptr, #82DEH
			mov a, #2EH
			movx @dptr, a
			mov dptr, #82E7H
			mov a, #2DH
			movx @dptr, a
			mov dptr, #82EBH
			mov a, #2EH
			movx @dptr, a
			mov dptr, #82EDH
			mov a, #2DH
			movx @dptr, a
			mov dptr, #82EEH
			mov a, #2FH
			movx @dptr, a
			ret

// =========================================================
// PROGRAM GŁOWNY
// =========================================================
    start:  	acall keymuz_baza
			MOV R3, #00H	; Stan obecny: 0=Baza, 1=Tercja, 2=Kwinta, 3=Oktawa
			MOV TMOD, #01H 
			MOV IE, #82H  
			
	graj:		MOV r4, #00H  
 			CLR TR0      

// --- OBSŁUGA PORTU P3 (Zmiana Transpozycji) ---
check_mode_1:
			JB P3.3, check_mode_2	
			CJNE R3, #00H, load_baza 
			SJMP key_1
load_baza:	MOV R3, #00H			
			ACALL keymuz_baza		
			SJMP key_1

check_mode_2:
			JB P3.4, check_mode_3	
			CJNE R3, #01H, load_tercja
			SJMP key_1
load_tercja:MOV R3, #01H			
			ACALL keymuz_tercja
			SJMP key_1

check_mode_3:
			JB P3.5, check_mode_4	
			CJNE R3, #02H, load_kwinta
			SJMP key_1
load_kwinta:MOV R3, #02H			
			ACALL keymuz_kwinta
			SJMP key_1

check_mode_4:
			JB P3.6, key_1			
			CJNE R3, #03H, load_oktawa
			SJMP key_1
load_oktawa:MOV R3, #03H			
			ACALL keymuz_oktawa
			SJMP key_1

// --- OBSLUGA KLAWIATURY I DZWIEKOW ---		
	key_1:	mov r0, #LINE_1
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
			
	key_2:	mov r0, #LINE_2
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
			jmp key_2
			
	key_3:	mov r0, #LINE_3
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
			jmp key_3
			
	key_4:	mov r0, #LINE_4
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
			jmp key_4	
			
	dalej:	mov a, r4
			jz powrot
			LCDcntrlWR #CLEAR
	powrot: jmp graj    
 
    nop
    nop
    nop
    jmp $
    end start
