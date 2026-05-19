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
// DEFINICJE TEKSTÓW LCD (Uporządkowane na oddzielnych stronach)
// =========================================================

// --- BAZA (Prefiks 20H) ---
org 2077H 
 db "C1",00
org 207BH 
 db "Cis1",00
org 207DH 
 db "D1",00
org 207EH 
 db "Dis1",00
org 20B7H 
 db "E1",00
org 20BBH 
 db "F1",00
org 20BDH 
 db "Fis1",00
org 20BEH 
 db "G1",00
org 20D7H 
 db "Gis1",00
org 20DBH 
 db "A1",00
org 20DDH 
 db "B1",00
org 20DEH 
 db "H1",00
org 20E7H 
 db "C2",00
org 20EBH 
 db "Cis2",00
org 20EDH 
 db "D2",00
org 20EEH 
 db "Dis2",00

// --- TERCJA (+4 półtony) (Prefiks 30H) ---
org 3077H 
 db "E1",00
org 307BH 
 db "F1",00
org 307DH 
 db "Fis1",00
org 307EH 
 db "G1",00
org 30B7H 
 db "Gis1",00
org 30BBH 
 db "A1",00
org 30BDH 
 db "B1",00
org 30BEH 
 db "H1",00
org 30D7H 
 db "C2",00
org 30DBH 
 db "Cis2",00
org 30DDH 
 db "D2",00
org 30DEH 
 db "Dis2",00
org 30E7H 
 db "E2",00
org 30EBH 
 db "F2",00
org 30EDH 
 db "Fis2",00
org 30EEH 
 db "G2",00

// --- KWINTA (+7 półtonów) (Prefiks 40H) ---
org 4077H 
 db "G1",00
org 407BH 
 db "Gis1",00
org 407DH 
 db "A1",00
org 407EH 
 db "B1",00
org 40B7H 
 db "H1",00
org 40BBH 
 db "C2",00
org 40BDH 
 db "Cis2",00
org 40BEH 
 db "D2",00
org 40D7H 
 db "Dis2",00
org 40DBH 
 db "E2",00
org 40DDH 
 db "F2",00
org 40DEH 
 db "Fis2",00
org 40E7H 
 db "G2",00
org 40EBH 
 db "Gis2",00
org 40EDH 
 db "A2",00
org 40EEH 
 db "B2",00

// --- OKTAWA (+12 półtonów) (Prefiks 50H) ---
org 5077H 
 db "C2",00
org 507BH 
 db "Cis2",00
org 507DH 
 db "D2",00
org 507EH 
 db "Dis2",00
org 50B7H 
 db "E2",00
org 50BBH 
 db "F2",00
org 50BDH 
 db "Fis2",00
org 50BEH 
 db "G2",00
org 50D7H 
 db "Gis2",00
org 50DBH 
 db "A2",00
org 50DDH 
 db "B2",00
org 50DEH 
 db "H2",00
org 50E7H 
 db "C3",00
org 50EBH 
 db "Cis3",00
org 50EDH 
 db "D3",00
org 50EEH 
 db "Dis3",00

// =========================================================
// PROGRAM GŁÓWNY I PROCEDURY
// =========================================================
org 0100H

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


// --- TABELE DZWIEKOW XRAM ---

// 1. DZWIEK BAZOWY (Prefiks LCD: 20H)
keymuz_baza:		
			mov dptr, #8077H
			mov a, #89H
			movx @dptr, a
			mov dptr, #8177H
			mov a, #0F8H
			movx @dptr, a
			mov dptr, #8277H
			mov a, #20H
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #0F4H
			movx @dptr, a
			mov dptr, #817BH
			mov a, #0F8H
			movx @dptr, a
			mov dptr, #827BH
			mov a, #20H
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #5AH
			movx @dptr, a
			mov dptr, #817DH
			mov a, #0F9H
			movx @dptr, a
			mov dptr, #827DH
			mov a, #20H
			movx @dptr, a

			mov dptr, #807EH
			mov a, #0B9H
			movx @dptr, a
			mov dptr, #817EH
			mov a, #0F9H
			movx @dptr, a
			mov dptr, #827EH
			mov a, #20H
			movx @dptr, a

			mov dptr, #80B7H
			mov a, #13H
			movx @dptr, a
			mov dptr, #81B7H
			mov a, #0FAH
			movx @dptr, a
			mov dptr, #82B7H
			mov a, #20H
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #68H
			movx @dptr, a
			mov dptr, #81BBH
			mov a, #0FAH
			movx @dptr, a
			mov dptr, #82BBH
			mov a, #20H
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #0B9H
			movx @dptr, a
			mov dptr, #81BDH
			mov a, #0FAH
			movx @dptr, a
			mov dptr, #82BDH
			mov a, #20H
			movx @dptr, a

			mov dptr, #80BEH
			mov a, #04H
			movx @dptr, a
			mov dptr, #81BEH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #82BEH
			mov a, #20H
			movx @dptr, a

			mov dptr, #80D7H
			mov a, #4CH
			movx @dptr, a
			mov dptr, #81D7H
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #82D7H
			mov a, #20H
			movx @dptr, a

			mov dptr, #80DBH
			mov a, #90H
			movx @dptr, a
			mov dptr, #81DBH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #82DBH
			mov a, #20H
			movx @dptr, a

			mov dptr, #80DDH
			mov a, #0CFH
			movx @dptr, a
			mov dptr, #81DDH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #82DDH
			mov a, #20H
			movx @dptr, a

			mov dptr, #80DEH
			mov a, #0CH
			movx @dptr, a
			mov dptr, #81DEH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82DEH
			mov a, #20H
			movx @dptr, a

			mov dptr, #80E7H
			mov a, #45H
			movx @dptr, a
			mov dptr, #81E7H
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82E7H
			mov a, #20H
			movx @dptr, a

			mov dptr, #80EBH
			mov a, #7AH
			movx @dptr, a
			mov dptr, #81EBH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82EBH
			mov a, #20H
			movx @dptr, a
			
			mov dptr, #80EDH
			mov a, #0ADH
			movx @dptr, a
			mov dptr, #81EDH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82EDH
			mov a, #20H
			movx @dptr, a

			mov dptr, #80EEH
			mov a, #0DDH
			movx @dptr, a
			mov dptr, #81EEH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82EEH
			mov a, #20H
			movx @dptr, a
			ret

// 2. TERCJA (Prefiks LCD: 30H)
keymuz_tercja:		
			mov dptr, #8077H
			mov a, #13H
			movx @dptr, a
			mov dptr, #8177H
			mov a, #0FAH
			movx @dptr, a
			mov dptr, #8277H
			mov a, #30H
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #68H
			movx @dptr, a
			mov dptr, #817BH
			mov a, #0FAH
			movx @dptr, a
			mov dptr, #827BH
			mov a, #30H
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #0B9H
			movx @dptr, a
			mov dptr, #817DH
			mov a, #0FAH
			movx @dptr, a
			mov dptr, #827DH
			mov a, #30H
			movx @dptr, a

			mov dptr, #807EH
			mov a, #04H
			movx @dptr, a
			mov dptr, #817EH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #827EH
			mov a, #30H
			movx @dptr, a

			mov dptr, #80B7H
			mov a, #4CH
			movx @dptr, a
			mov dptr, #81B7H
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #82B7H
			mov a, #30H
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #90H
			movx @dptr, a
			mov dptr, #81BBH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #82BBH
			mov a, #30H
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #0CFH
			movx @dptr, a
			mov dptr, #81BDH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #82BDH
			mov a, #30H
			movx @dptr, a

			mov dptr, #80BEH
			mov a, #0CH
			movx @dptr, a
			mov dptr, #81BEH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82BEH
			mov a, #30H
			movx @dptr, a

			mov dptr, #80D7H
			mov a, #45H
			movx @dptr, a
			mov dptr, #81D7H
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82D7H
			mov a, #30H
			movx @dptr, a

			mov dptr, #80DBH
			mov a, #7AH
			movx @dptr, a
			mov dptr, #81DBH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82DBH
			mov a, #30H
			movx @dptr, a

			mov dptr, #80DDH
			mov a, #0ADH
			movx @dptr, a
			mov dptr, #81DDH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82DDH
			mov a, #30H
			movx @dptr, a

			mov dptr, #80DEH
			mov a, #0DDH
			movx @dptr, a
			mov dptr, #81DEH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82DEH
			mov a, #30H
			movx @dptr, a

			mov dptr, #80E7H
			mov a, #0AH
			movx @dptr, a
			mov dptr, #81E7H
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82E7H
			mov a, #30H
			movx @dptr, a

			mov dptr, #80EBH
			mov a, #34H
			movx @dptr, a
			mov dptr, #81EBH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82EBH
			mov a, #30H
			movx @dptr, a
			
			mov dptr, #80EDH
			mov a, #5DH
			movx @dptr, a
			mov dptr, #81EDH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82EDH
			mov a, #30H
			movx @dptr, a

			mov dptr, #80EEH
			mov a, #82H
			movx @dptr, a
			mov dptr, #81EEH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82EEH
			mov a, #30H
			movx @dptr, a
			ret

// 3. KWINTA (Prefiks LCD: 40H)
keymuz_kwinta:		
			mov dptr, #8077H
			mov a, #04H
			movx @dptr, a
			mov dptr, #8177H
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #8277H
			mov a, #40H
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #4CH
			movx @dptr, a
			mov dptr, #817BH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #827BH
			mov a, #40H
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #90H
			movx @dptr, a
			mov dptr, #817DH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #827DH
			mov a, #40H
			movx @dptr, a

			mov dptr, #807EH
			mov a, #0CFH
			movx @dptr, a
			mov dptr, #817EH
			mov a, #0FBH
			movx @dptr, a
			mov dptr, #827EH
			mov a, #40H
			movx @dptr, a

			mov dptr, #80B7H
			mov a, #0CH
			movx @dptr, a
			mov dptr, #81B7H
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82B7H
			mov a, #40H
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #45H
			movx @dptr, a
			mov dptr, #81BBH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82BBH
			mov a, #40H
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #7AH
			movx @dptr, a
			mov dptr, #81BDH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82BDH
			mov a, #40H
			movx @dptr, a

			mov dptr, #80BEH
			mov a, #0ADH
			movx @dptr, a
			mov dptr, #81BEH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82BEH
			mov a, #40H
			movx @dptr, a

			mov dptr, #80D7H
			mov a, #0DDH
			movx @dptr, a
			mov dptr, #81D7H
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #82D7H
			mov a, #40H
			movx @dptr, a

			mov dptr, #80DBH
			mov a, #0AH
			movx @dptr, a
			mov dptr, #81DBH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82DBH
			mov a, #40H
			movx @dptr, a

			mov dptr, #80DDH
			mov a, #34H
			movx @dptr, a
			mov dptr, #81DDH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82DDH
			mov a, #40H
			movx @dptr, a

			mov dptr, #80DEH
			mov a, #5DH
			movx @dptr, a
			mov dptr, #81DEH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82DEH
			mov a, #40H
			movx @dptr, a

			mov dptr, #80E7H
			mov a, #82H
			movx @dptr, a
			mov dptr, #81E7H
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82E7H
			mov a, #40H
			movx @dptr, a

			mov dptr, #80EBH
			mov a, #0A6H
			movx @dptr, a
			mov dptr, #81EBH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82EBH
			mov a, #40H
			movx @dptr, a
			
			mov dptr, #80EDH
			mov a, #0C8H
			movx @dptr, a
			mov dptr, #81EDH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82EDH
			mov a, #40H
			movx @dptr, a

			mov dptr, #80EEH
			mov a, #0E8H
			movx @dptr, a
			mov dptr, #81EEH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82EEH
			mov a, #40H
			movx @dptr, a
			ret

// 4. OKTAWA (Prefiks LCD: 50H)
keymuz_oktawa:		
			mov dptr, #8077H
			mov a, #45H
			movx @dptr, a
			mov dptr, #8177H
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #8277H
			mov a, #50H
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #7AH
			movx @dptr, a
			mov dptr, #817BH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #827BH
			mov a, #50H
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #0ADH
			movx @dptr, a
			mov dptr, #817DH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #827DH
			mov a, #50H
			movx @dptr, a

			mov dptr, #807EH
			mov a, #0DDH
			movx @dptr, a
			mov dptr, #817EH
			mov a, #0FCH
			movx @dptr, a
			mov dptr, #827EH
			mov a, #50H
			movx @dptr, a

			mov dptr, #80B7H
			mov a, #0AH
			movx @dptr, a
			mov dptr, #81B7H
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82B7H
			mov a, #50H
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #34H
			movx @dptr, a
			mov dptr, #81BBH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82BBH
			mov a, #50H
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #5DH
			movx @dptr, a
			mov dptr, #81BDH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82BDH
			mov a, #50H
			movx @dptr, a

			mov dptr, #80BEH
			mov a, #82H
			movx @dptr, a
			mov dptr, #81BEH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82BEH
			mov a, #50H
			movx @dptr, a

			mov dptr, #80D7H
			mov a, #0A6H
			movx @dptr, a
			mov dptr, #81D7H
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82D7H
			mov a, #50H
			movx @dptr, a

			mov dptr, #80DBH
			mov a, #0C8H
			movx @dptr, a
			mov dptr, #81DBH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82DBH
			mov a, #50H
			movx @dptr, a

			mov dptr, #80DDH
			mov a, #0E8H
			movx @dptr, a
			mov dptr, #81DDH
			mov a, #0FDH
			movx @dptr, a
			mov dptr, #82DDH
			mov a, #50H
			movx @dptr, a

			mov dptr, #80DEH
			mov a, #06H
			movx @dptr, a
			mov dptr, #81DEH
			mov a, #0FEH
			movx @dptr, a
			mov dptr, #82DEH
			mov a, #50H
			movx @dptr, a

			mov dptr, #80E7H
			mov a, #23H
			movx @dptr, a
			mov dptr, #81E7H
			mov a, #0FEH
			movx @dptr, a
			mov dptr, #82E7H
			mov a, #50H
			movx @dptr, a

			mov dptr, #80EBH
			mov a, #3DH
			movx @dptr, a
			mov dptr, #81EBH
			mov a, #0FEH
			movx @dptr, a
			mov dptr, #82EBH
			mov a, #50H
			movx @dptr, a
			
			mov dptr, #80EDH
			mov a, #57H
			movx @dptr, a
			mov dptr, #81EDH
			mov a, #0FEH
			movx @dptr, a
			mov dptr, #82EDH
			mov a, #50H
			movx @dptr, a

			mov dptr, #80EEH
			mov a, #6FH
			movx @dptr, a
			mov dptr, #81EEH
			mov a, #0FEH
			movx @dptr, a
			mov dptr, #82EEH
			mov a, #50H
			movx @dptr, a
			ret

// --- INICJALIZACJA I PĘTLA GŁÓWNA ---
start:  	init_LCD
			acall keymuz_baza
			MOV R3, #00H  	; Flaga obecnego trybu (0=baza, 1=tercja, 2=kwinta, 3=oktawa)
			MOV TMOD, #01H 
			MOV IE, #82H  
			
graj:		MOV r4, #00H  
 			CLR TR0      
		
// --- SKANOWANIE MODYFIKATORÓW (Przyciski na porcie P3) ---
			JNB P3.3, laduj_tercja ; Jeśli P3.3 zwarty, ładuj tercję
			JNB P3.4, laduj_kwinta ; Jeśli P3.4 zwarty, ładuj kwintę
			JNB P3.5, laduj_oktawa ; Jeśli P3.5 zwarty, ładuj oktawę
			
			; Jeśli żaden guzik funkcyjny nie jest wciśnięty:
			CJNE R3, #00H, wykonaj_baze ; Upewnij się, że załadowana jest baza
			SJMP key_1

wykonaj_baze:
			MOV R3, #00H
			ACALL keymuz_baza
			SJMP key_1

laduj_tercja:
			CJNE R3, #01H, wykonaj_tercje
			SJMP key_1
wykonaj_tercje:
			MOV R3, #01H
			ACALL keymuz_tercja
			SJMP key_1

laduj_kwinta:
			CJNE R3, #02H, wykonaj_kwinta
			SJMP key_1
wykonaj_kwinta:
			MOV R3, #02H
			ACALL keymuz_kwinta
			SJMP key_1

laduj_oktawa:
			CJNE R3, #03H, wykonaj_oktawe
			SJMP key_1
wykonaj_oktawe:
			MOV R3, #03H
			ACALL keymuz_oktawa
			SJMP key_1

// --- SKANOWANIE KLAWIATURY GŁÓWNEJ I ODTWARZANIE ---
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

dalej:		mov a, r4
			jz powrot
			LCDcntrlWR #CLEAR
powrot:		jmp graj    
 
    nop
    jmp $
    end start
