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
LCDcntrlWR MACRO x          ; x – parametr wywolania macra – bajt sterujacy
    LOCAL loop              ; LOCAL oznacza ze etykieta loop moze sie powtórzyc w programie
loop: 
    MOV DPTR, #LCDstatus    ; DPTR zaladowany adresem statusu
    MOVX A, @DPTR           ; pobranie bajtu z biezacym statusem LCD
    JB ACC.7, loop          ; testowanie najstarszego bitu akumulatora
                            ; – wskazuje gotowosc LCD
    MOV DPTR, #LCDcontrol   ; DPTR zaladowany adresem do podania bajtu sterujacego
    MOV A, x                ; do akumulatora trafia argument wywolania macra–bajt sterujacy
    MOVX @DPTR, A           ; bajt sterujacy podany do LCD – zadana akcja widoczna na LCD
ENDM

// macro do wypisania znaku ASCII na LCD, znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO
    LOCAL tutu              ; LOCAL oznacza ze etykieta tutu moze sie powtórzyc w programie
    PUSH ACC                ; odlozenie biezacej zawartosci akumulatora na stos
tutu: 
    MOV DPTR, #LCDstatus    ; DPTR zaladowany adresem statusu
    MOVX A, @DPTR           ; pobranie bajtu z biezacym statusem LCD
    JB ACC.7, tutu          ; testowanie najstarszego bitu akumulatora
                            ; – wskazuje gotowosc LCD
    MOV DPTR, #LCDdataWR    ; DPTR zaladowany adresem do podania bajtu sterujacego
    POP ACC                 ; w akumulatorze ponownie kod ASCII znaku na LCD
    MOVX @DPTR, A           ; kod ASCII podany do LCD – znak widoczny na LCD
ENDM

// macro do inicjalizacji wyswietlacza – bez parametrów
init_LCD MACRO
    LCDcntrlWR #INITDISP    ; wywolanie macra LCDcntrlWR – inicjalizacja LCD
    LCDcntrlWR #CLEAR       ; wywolanie macra LCDcntrlWR – czyszczenie LCD
    LCDcntrlWR #LCDON       ; wywolanie macra LCDcntrlWR – konfiguracja kursora
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
    div ab                  ; uzyskanie cyfry dziesiatek
    add a, #30H             ; konwersja cyfry na kod ASCII
    acall putcharLCD
    mov a, b                ; ladowanie cyfry jednosci
    add a, #30H             ; konwersja na LCD
    acall putcharLCD
    ret

// funkcaj wypisywania znaku na LCD
putcharLCD: 
    LCDcharWR
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
ZEGAR: 
    INC R7                  ; licznik sekund
    MOV A, R7               
    CLR C
    SUBB A, #60             
    JZ MINUTY
    
    LCDcntrlWR #HOME        
    MOV A, R5               ; godziny
    ACALL putdigitLCD
    MOV A, #":"             
    ACALL putcharLCD
    MOV A, R6               ; minuty
    ACALL putdigitLCD
    MOV A, #":"             
    ACALL putcharLCD
    MOV A, R7               ; sekundy
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
    jnz ostatniedwie
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
    jnz jumpostatniedwie
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
    jnz jumpostatniedwie
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
    jz sprawdz_timer        ; <--- BARDZO WAZNE: Bez tego skoku pętla była zablokowana!
    mov a, r2
    mov dph, #80h
    mov dpl, a
    movx a, @dptr
    clr c
    subb a, #"#"
    jz ustawgodzine
    movx a, @dptr
    clr c                   ; <--- Zabezpieczenie przed błędem odejmowania
    subb a, #"*"
    jz ustawminute
    movx a, @dptr
    jz jumpostatniedwie
    
sprawdz_timer:
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

ustawgodzine:
    mov a, r4
    mov b, #10
    mul ab
    add a, r3               
    mov r2, a               
    clr c
    subb a, #24             
    jnc blad_h              
    mov a, r2               
    mov r5, a               ; poprawna wartosc wgrywana do godzin
    mov r3, #0              
    mov r4, #0
    acall EKRAN             ; <--- Wymuszenie natychmiastowego odrysowania czasu na LCD
blad_h:
    ljmp key_1

ustawminute:
    mov a, r4
    mov b, #10
    mul ab
    add a, r3               
    mov r2, a               
    clr c
    subb a, #60             
    jnc blad_m              
    mov a, r2
    mov r6, a               ; poprawna wartosc wgrywana do minut
    mov r3, #0              
    mov r4, #0
    acall EKRAN             ; <--- Wymuszenie natychmiastowego odrysowania czasu na LCD
blad_m:
    ljmp key_1

jumpostatniedwie:
    ljmp ostatniedwie

    END START
