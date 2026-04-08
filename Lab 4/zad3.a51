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

org 0100H                       ; Ustawienie adresu początku kompilacji na 0x0100
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x              ; Definicja makra wysyłającego komendę 'x'
           LOCAL loop           ; Lokalna etykieta dla pętli opóźnienia
loop: MOV  DPTR,#LCDstatus      ; Załaduj wskaźnik statusem LCD
      MOVX A,@DPTR              ; Odczytaj status LCD
      JB   ACC.7,loop           ; Czekaj w pętli, jeśli najstarszy bit to 1 (LCD zajęty)
      MOV  DPTR,#LCDcontrol     ; Załaduj wskaźnik adresem komend
      MOV  A, x                 ; Pobierz komendę do akumulatora
      MOVX @DPTR,A              ; Wyślij komendę do LCD
      ENDM                      ; Koniec makra
	  
// macro do wypisania znaku ASCII na LCD
LCDcharWR MACRO                 ; Definicja makra wypisującego znak
      LOCAL tutu                ; Lokalna etykieta
      PUSH ACC                  ; Odłóż znak ASCII ze wskaźnika A na stos (zabezpieczenie)
tutu: MOV  DPTR,#LCDstatus      ; Załaduj wskaźnik statusem
      MOVX A,@DPTR              ; Odczytaj status
      JB   ACC.7,tutu           ; Czekaj na gotowość LCD
      MOV  DPTR,#LCDdataWR      ; Załaduj wskaźnik adresem danych
      POP  ACC                  ; Przywróć znak ASCII ze stosu do A
      MOVX @DPTR,A              ; Wyślij znak ASCII do LCD
      ENDM                      ; Koniec makra
	  
// macro do inicjalizacji wyswietlacza
init_LCD MACRO                  ; Definicja makra inicjalizującego
         LCDcntrlWR #INITDISP   ; Wyślij komendę inicjalizacji
         LCDcntrlWR #CLEAR      ; Wyślij komendę czyszczenia
         LCDcntrlWR #LCDON      ; Wyślij komendę włączenia LCD
         ENDM                   ; Koniec makra

// funkcja opóznienia
	delay:	mov r1, #0FFH       ; Załaduj rejestr R1 (zewnętrzna pętla)
	dwa:	mov r2, #0FFH       ; Załaduj rejestr R2 (wewnętrzna pętla)
    trzy:	djnz r2, trzy       ; Zmniejszaj R2 aż do zera
			djnz r1, dwa        ; Zmniejszaj R1 aż do zera
			ret                 ; Wróć z podprogramu opóźnienia
			
// funkcja wypisania znaku
putcharLCD:	LCDcharWR           ; Wywołaj makro wypisujące znak z A
			ret                 ; Wróć z podprogramu

// --- TABLICE PRZEKODOWAŃ ---

keyascii_lower:	mov dptr, #80EBH ; Adres w XRAM dla 1. klawisza
			mov a, #"a"         ; Znak małego 'a'
			movx @dptr, a       ; Zapisz 'a' w XRAM
			mov dptr, #8077H    ; (Zasada zapisu analogiczna dla całego bloku niżej...)
			mov a, #"b"
			movx @dptr, a
			mov dptr, #807BH
			mov a, #"c"
			movx @dptr, a
			mov dptr, #807DH
			mov a, #"d"
			movx @dptr, a
			mov dptr, #80B7H
			mov a, #"e"
			movx @dptr, a
			mov dptr, #80BBH
			mov a, #"f"
			movx @dptr, a
			mov dptr, #80BDH
			mov a, #"g"
			movx @dptr, a
			mov dptr, #80D7H
			mov a, #"h"
			movx @dptr, a
			mov dptr, #80DBH
			mov a, #"i"
			movx @dptr, a
			mov dptr, #80DDH
			mov a, #"j"
			movx @dptr, a
			mov dptr, #807EH
			mov a, #"k"
			movx @dptr, a
			mov dptr, #80BEH
			mov a, #"l"
			movx @dptr, a
			mov dptr, #80DEH
			mov a, #"m"
			movx @dptr, a
			mov dptr, #80EEH    ; Klawisz 'D'
			mov a, #"D"
			movx @dptr, a
			mov dptr, #80E7H    ; Klawisz '*'
			mov a, #"*"
			movx @dptr, a
			mov dptr, #80EDH    ; Klawisz '#'
			mov a, #"#"
			movx @dptr, a
			ret                 ; Wróć po załadowaniu małych liter

keyascii_upper:	mov dptr, #80EBH ; Adres dla 1. klawisza
			mov a, #"A"         ; Znak dużego 'A'
			movx @dptr, a       ; Zapisz w XRAM
			mov dptr, #8077H    ; (Zasada zapisu analogiczna dla całego bloku niżej...)
			mov a, #"B"
			movx @dptr, a
			mov dptr, #807BH
			mov a, #"C"
			movx @dptr, a
			mov dptr, #807DH
			mov a, #"D"
			movx @dptr, a
			mov dptr, #80B7H
			mov a, #"E"
			movx @dptr, a
			mov dptr, #80BBH
			mov a, #"F"
			movx @dptr, a
			mov dptr, #80BDH
			mov a, #"G"
			movx @dptr, a
			mov dptr, #80D7H
			mov a, #"H"
			movx @dptr, a
			mov dptr, #80DBH
			mov a, #"I"
			movx @dptr, a
			mov dptr, #80DDH
			mov a, #"J"
			movx @dptr, a
			mov dptr, #807EH
			mov a, #"K"
			movx @dptr, a
			mov dptr, #80BEH
			mov a, #"L"
			movx @dptr, a
			mov dptr, #80DEH
			mov a, #"M"
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
			ret                 ; Wróć po załadowaniu dużych liter

keyascii_num:	mov dptr, #80EBH ; Adres dla 1. klawisza
			mov a, #"0"         ; Znak cyfry '0'
			movx @dptr, a       ; Zapisz w XRAM
			mov dptr, #8077H    ; (Zasada zapisu analogiczna dla całego bloku niżej...)
			mov a, #"1"
			movx @dptr, a
			mov dptr, #807BH
			mov a, #"2"
			movx @dptr, a
			mov dptr, #807DH
			mov a, #"3"
			movx @dptr, a
			mov dptr, #80B7H
			mov a, #"4"
			movx @dptr, a
			mov dptr, #80BBH
			mov a, #"5"
			movx @dptr, a
			mov dptr, #80BDH
			mov a, #"6"
			movx @dptr, a
			mov dptr, #80D7H
			mov a, #"7"
			movx @dptr, a
			mov dptr, #80DBH
			mov a, #"8"
			movx @dptr, a
			mov dptr, #80DDH
			mov a, #"9"
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
			ret                 ; Wróć po załadowaniu cyfr
 
// --- PROGRAM GŁÓWNY ---
    start:  init_LCD            ; Inicjalizuj LCD
			acall keyascii_num  ; Załaduj domyślny zestaw znaków (cyfry) do pamięci RAM
			
			mov r7, #10h        ; R7 = 16 (licznik miejsc w bieżącej linii LCD)
			mov r6, #01h        ; R6 = 1 (flaga oznaczająca, że piszemy w 1. linii)

	check_chars:
			mov a, r7           ; Przenieś ilość pozostałych miejsc do A
			jz  check_line      ; Jeśli wyczerpano miejsce (A=0), skocz do obsługi zmiany linii
			jmp key_1           ; Jeśli jest miejsce, przejdź do skanowania 1. wiersza klawiatury

	check_line:	
			mov a, r6           ; Sprawdź flagę aktualnej linii
			jnz set_line2       ; Jeśli to pierwsza linia (A!=0), skocz ustawić 2. linię
	set_line1:	
			LCDcntrlWR #CLEAR   ; Jesteśmy po 2. linii, więc wyczyść cały ekran
			LCDcntrlWR #HOME    ; Przesuń kursor na sam początek (domyślnie)
			mov r7, #10h        ; Przywróć licznik znaków w linii na 16
			mov r6, #01h        ; Ustaw flagę z powrotem na 1. linię
			jmp key_1           ; Wróć do skanowania
	set_line2:	
			LCDcntrlWR #HOM2    ; Ustaw kursor na początku 2. linii
			mov r6, #00h        ; Ustaw flagę na 0 (druga linia)
			mov r7, #10h        ; Przywróć licznik znaków na 16
	
	key_1:	mov r0, #LINE_1     ; Załaduj maskę 1. wiersza do R0
			mov	a, r0           ; Przenieś do A
			mov	P5, a           ; Wystaw na P5, aktywując 1. wiersz
			mov a, P7           ; Odczytaj stany kolumn
			anl a, r0           ; Zamaskuj z wierszem
			mov r2, a           ; Zapamiętaj odczyt w R2
			clr c               ; Wyczyść przeniesienie
			subb a, r0          ; Sprawdź, czy coś naciśnięto
			jz key_2            ; Jeśli nie naciśnięto, skocz do 2. wiersza
			
	wait_rel_1:	mov a, P7       ; WCIŚNIĘTO KLAWISZ! Odczytaj ponownie port P7
			anl a, r0           ; Zamaskuj wynik z maską wiersza 1
			clr c               ; Wyczyść flagę przeniesienia
			subb a, r0          ; Porównaj z maską bazową (sprawdź czy guzik puścił)
			jnz wait_rel_1      ; Jeśli guzik NADAL jest wciśnięty, kręć się w pętli!
			
			mov a, r2           ; GUZIK PUSZCZONY! Przywróć zapamiętany w R2 kod klawisza
			mov dph, #80h       ; Ustaw starszy bajt adresu XRAM
			mov dpl, a          ; Ustaw młodszy bajt jako kod klawisza
			movx a,@dptr        ; Pobierz odpowiedni znak ASCII
			mov P1, a           ; Wystaw kod ASCII na diody (P1)
			acall putcharLCD    ; Wyświetl znak na LCD
			acall delay         ; Opóźnienie na wygaszenie drgań (debouncing)
			dec r7              ; Zmniejsz licznik pozostałego miejsca
			ljmp check_chars    ; Długi skok na sam początek pętli
			
	key_2:	mov r0, #LINE_2     ; Załaduj maskę 2. wiersza do R0
			mov	a, r0           ; (Reszta logiki identyczna jak w 1. wierszu...)
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_3            ; Brak wciśnięcia -> skok do wiersza 3
			
	wait_rel_2:	mov a, P7       ; Pętla oczekująca na puszczenie klawisza
			anl a, r0
			clr c
			subb a, r0
			jnz wait_rel_2      ; Czekaj aż podniesiesz palec
			
			mov a, r2           ; Wypisz znak
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			acall putcharLCD
			acall delay
			dec r7
			ljmp check_chars    ; Wróć na początek pętli głównej
			
	key_3:	mov r0, #LINE_3     ; Załaduj maskę 3. wiersza do R0
			mov	a, r0           ; (Reszta logiki identyczna...)
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_4            ; Brak wciśnięcia -> skok do wiersza 4
			
	wait_rel_3:	mov a, P7       ; Pętla oczekująca na puszczenie klawisza
			anl a, r0
			clr c
			subb a, r0
			jnz wait_rel_3      ; Czekaj na zwolnienie
			
			mov a, r2           ; Wypisz znak
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			acall putcharLCD
			acall delay
			dec r7
			ljmp check_chars    ; Wróć na początek
			
	key_4:	mov r0, #LINE_4     ; Załaduj maskę 4. wiersza do R0
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz jump_help        ; Brak wciśnięcia -> Skok na początek (przez jump_help)
			
	wait_rel_4:	mov a, P7       ; Pętla oczekująca na puszczenie klawisza z 4. wiersza
			anl a, r0
			clr c
			subb a, r0
			jnz wait_rel_4      ; Czekaj na zwolnienie klawisza funkcyjnego
			
			mov a, r2           ; Odtwórz zapamiętany kod
			clr c               ; Wyczyść flagę C
			subb a, #0E7h       ; Porównaj z kodem '*'
			jz to_lower         ; Jeśli to '*', skocz załadować małe litery
			clr c               ; Wyczyść flagę C
			mov a, r2           ; Ponownie weź kod
			subb a, #0EDh       ; Porównaj z kodem '#'
			jz to_upper         ; Jeśli to '#', skocz załadować duże litery
			clr c               ; Wyczyść flagę C
			mov a, r2           ; Ponownie weź kod
			subb a, #0EEh       ; Porównaj z kodem 'D'
			jz to_num           ; Jeśli to 'D', skocz załadować cyfry
			
			clr c               ; Jeśli to żaden funkcyjny (np. klawisz A z 4. wiersza)
			mov a, r2           ; Pobierz go ponownie
			mov dph, #80h       ; Ustaw adres
			mov dpl, a          ; ...
			movx a,@dptr        ; Pobierz znak z pamięci
			mov P1, a           ; Wystaw na P1
			acall putcharLCD    ; Wypisz
			acall delay         ; Opóźnienie
			
			dec r7              ; Zmniejsz ilość miejsc
			ljmp check_chars    ; Wróć na początek
            
	jump_help: 	ljmp check_chars ; Skok omijający problem z zasięgiem instrukcji 'jz'

	to_lower:
			acall keyascii_lower ; Załaduj nową tablicę XRAM (małe litery)
			ljmp check_chars    ; Wróć na początek
	to_upper:
			acall keyascii_upper ; Załaduj nową tablicę XRAM (duże litery)
			ljmp check_chars    ; Wróć na początek
	to_num:
			acall keyascii_num   ; Załaduj nową tablicę XRAM (cyfry)
			ljmp check_chars    ; Wróć na początek
          
    nop                         ; Pusta instrukcja
    nop                         ; Pusta instrukcja
    nop                         ; Pusta instrukcja
    jmp $                       ; Zapętlenie, fizyczny koniec pracy programu
    end start                   ; Znacznik zakończenia pliku asemblera dla kompilatora
