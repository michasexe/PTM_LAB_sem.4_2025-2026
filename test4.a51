ljmp start

P5          equ 0F8H
P7          equ 0DBH
LCDstatus   equ 0FF2EH      ; adres do odczytu gotowosci LCD
LCDcontrol  equ 0FF2CH      ; adres do podania bajtu sterujacego LCD
LCDdataWR   equ 0FF2DH      ; adres do podania kodu ASCII na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define HOME        0x80    // put cursor to second line
#define INITDISP    0x38    // LCD init (8-bit mode)
#define HOM2        0xc0    // put cursor to second line
#define LCDON       0x0e    // LCD nn, cursor off, blinking off
#define CLEAR       0x01    // LCD display clear

// linie klawiatury - sterowanie na port P5
#define LINE_1      0x7f    // 0111 1111
#define LINE_2      0xbf    // 1011 1111
#define LINE_3      0xdf    // 1101 1111
#define LINE_4      0xef    // 1110 1111
#define ALL_LINES   0x0f    // 0000 1111

    ORG 000BH               ; obsluga przerwania
    MOV TH0, #3CH           ; przeladowanie
    MOV TL0, #0B0H          ; stalej timera na 50ms
    DEC R0                  ; korekta licznika
    RETI                    ; powrót z przerwania

    org 0100H

// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x          
    LOCAL loop              
loop: 
    MOV DPTR, #LCDstatus    
    MOVX A, @DPTR           
    JB ACC.7, loop          
    MOV DPTR, #LCDcontrol   
    MOV A, x                
    MOVX @DPTR, A           
ENDM

// macro do wypisania znaku ASCII na LCD
LCDcharWR MACRO
    LOCAL tutu              
    PUSH ACC                
tutu: 
    MOV DPTR, #LCDstatus    
    MOVX A, @DPTR           
    JB ACC.7, tutu          
    MOV DPTR, #LCDdataWR    
    POP ACC                 
    MOVX @DPTR, A           
ENDM

// macro do inicjalizacji wyswietlacza
init_LCD MACRO
    LCDcntrlWR #INITDISP    
    LCDcntrlWR #CLEAR       
    LCDcntrlWR #LCDON       
ENDM

delay: 
    mov r1, #0FFH
dwa: 
    mov r2, #0FFH
trzy: 
    djnz r2, trzy
    djnz r1, dwa
    ret

// funkcja wypisania liczby dla potrzeb zegara
putdigitLCD: 
    mov b, #10
    div ab                  
    add a, #30H             
    acall putcharLCD
    mov a, b                
    add a, #30H             
    acall putcharLCD
    ret

// funkcaj wypisywania znaku na LCD
putcharLCD: 
    LCDcharWR
    ret

// tablica przekodowania klawisze - ASCII w XRAM
keyascii_num: 
    mov dptr, #80EBH \ mov a, #0 \ movx @dptr, a
    mov dptr, #8077H \ mov a, #1 \ movx @dptr, a
    mov dptr, #807BH \ mov a, #2 \ movx @dptr, a
    mov dptr, #807DH \ mov a, #3 \ movx @dptr, a
    mov dptr, #80B7H \ mov a, #4 \ movx @dptr, a
    mov dptr, #80BBH \ mov a, #5 \ movx @dptr, a
    mov dptr, #80BDH \ mov a, #6 \ movx @dptr, a
    mov dptr, #80D7H \ mov a, #7 \ movx @dptr, a
    mov dptr, #80DBH \ mov a, #8 \ movx @dptr, a
    mov dptr, #80DDH \ mov a, #9 \ movx @dptr, a
    mov dptr, #807EH \ mov a, #"A" \ movx @dptr, a
    mov dptr, #80BEH \ mov a, #"B" \ movx @dptr, a
    mov dptr, #80DEH \ mov a, #"C" \ movx @dptr, a
    mov dptr, #80EEH \ mov a, #"D" \ movx @dptr, a
    mov dptr, #80E7H \ mov a, #"*" \ movx @dptr, a
    mov dptr, #80EDH \ mov a, #"#" \ movx @dptr, a
    ret

// wyznaczanie biezacej wartosci zegara i jego wyswietlanie na LCD
ZEGAR: 
    INC R7                  
    MOV A, R7               
    CLR C
    SUBB A, #60             
    JZ MINUTY
    
    LCDcntrlWR #HOME        
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
    LCDcntrlWR #HOM2
    mov a, r4               
    add a, #30H
    acall putcharLCD
    mov a, r3               
    add a, #30H
    acall putcharLCD
    JMP FINAL

MINUTY: 
    MOV R7, #00H            
    INC R6                  
    MOV A, R6               
    CLR C
    SUBB A, #60             
    JZ GODZINY
    
    LCDcntrlWR #HOME        
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
    LCDcntrlWR #HOM2
    mov a, r4               
    add a, #30H
    acall putcharLCD
    mov a, r3               
    add a, #30H
    acall putcharLCD
    JMP FINAL

GODZINY: 
    MOV R6, #00H            
    INC R5                  
    MOV A, R5
    CLR C
    SUBB A, #24             
    JNZ EKRAN
    MOV R5, #00H            

EKRAN: 
    LCDcntrlWR #HOME        
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
    LCDcntrlWR #HOM2
    mov a, r4               
    add a, #30H
    acall putcharLCD
    mov a, r3               
    add a, #30H
    acall putcharLCD

FINAL: 
    RET

ostatniedwie: 
    mov a, r3
    mov r4, a
    movx a, @dptr
    mov r3, a
    acall delay
    ljmp key_1

; program glówny
START: 
    init_LCD
    MOV TMOD, #01H          
    MOV TH0, #3CH           
    MOV TL0, #0B0H          
    SETB TR0                
    MOV IE, #82H            
    MOV R5, #00H            
    MOV R6, #00H
    MOV R7, #0FFH
    ACALL ZEGAR             
    MOV A, #0FH
    MOV P1, A               
    MOV R0, #20             
    acall keyascii_num
    mov r3, #0
    mov r4, #0

CZEKAM:
key_1: 
    mov r1, #LINE_1
    mov a, r1
    mov P5, a
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
    jz KLAWISZ_A            
    ljmp ostatniedwie
KLAWISZ_A:
    MOV TH0, #3CH           
    MOV TL0, #0B0H          
    SETB TR0                

key_2: 
    mov r1, #LINE_2
    mov a, r1
    mov P5, a
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
    jz KLAWISZ_B            
    ljmp ostatniedwie
KLAWISZ_B:
    clr TR0

key_3: 
    mov r1, #LINE_3
    mov a, r1
    mov P5, a
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
    jz KLAWISZ_C            
    ljmp ostatniedwie
KLAWISZ_C:
    ljmp START

key_4: 
    mov r1, #LINE_4
    mov a, r1
    mov P5, a
    mov a, P7
    anl a, r1
    mov r2, a
    clr c
    subb a, r1
    jz sprawdz_timer        
    mov a, r2
    mov dph, #80h
    mov dpl, a
    movx a, @dptr
    clr c
    subb a, #"#"
    jz ustawgodzine
    movx a, @dptr
    clr c                   
    subb a, #"*"
    jz ustawminute
    movx a, @dptr
    jnz OMIN_OST_4          
    ljmp ostatniedwie
OMIN_OST_4:
    
sprawdz_timer:
    MOV A, R0               
    JZ ODLICZONO_1S         
    LJMP CZEKAM             
ODLICZONO_1S:
    MOV R0, #20             
    ACALL ZEGAR             
    MOV A, P1               
    CPL A                   
    MOV P1, A               
    LJMP CZEKAM             

ustawgodzine:
CZEKAJ_PUSZCZ_H:
    MOV A, R0               ; Obsluga timera w czasie czekania na puszczenie przycisku
    JNZ CZEKAJ_DALEJ_H
    MOV R0, #20             
    ACALL ZEGAR             
    MOV A, P1               
    CPL A                   
    MOV P1, A               
CZEKAJ_DALEJ_H:
    mov a, #LINE_4
    mov P5, a
    mov a, P7
    anl a, #LINE_4
    clr c
    subb a, #LINE_4
    jnz CZEKAJ_PUSZCZ_H     ; Wracaj do góry, dopóki klawisz jest wciśnięty

    ; Po puszczeniu klawisza:
    mov a, r4
    mov b, #10
    mul ab
    add a, r3               
    mov r2, a               
    clr c
    subb a, #24             
    jnc blad_h              
    mov a, r2               
    mov r5, a               
    mov r3, #0              
    mov r4, #0
    acall EKRAN             
blad_h:
    ljmp key_1

ustawminute:
CZEKAJ_PUSZCZ_M:
    MOV A, R0               ; Obsluga timera w czasie czekania na puszczenie przycisku
    JNZ CZEKAJ_DALEJ_M
    MOV R0, #20             
    ACALL ZEGAR             
    MOV A, P1               
    CPL A                   
    MOV P1, A               
CZEKAJ_DALEJ_M:
    mov a, #LINE_4
    mov P5, a
    mov a, P7
    anl a, #LINE_4
    clr c
    subb a, #LINE_4
    jnz CZEKAJ_PUSZCZ_M     ; Wracaj do góry, dopóki klawisz jest wciśnięty

    ; Po puszczeniu klawisza:
    mov a, r4
    mov b, #10
    mul ab
    add a, r3               
    mov r2, a               
    clr c
    subb a, #60             
    jnc blad_m              
    mov a, r2
    mov r6, a               
    mov r3, #0              
    mov r4, #0
    acall EKRAN             
blad_m:
    ljmp key_1

    END START
