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

// funkcja opóznienia
	delay:	mov r0, #03H
	one:	mov r1, #0FFH
	dwa:	mov r2, #0FFH
    trzy:	djnz r2, trzy
			djnz r1, dwa
			djnz r0, one
			ret
			
// funkcja wypisania znaku
putcharLCD:	LCDcharWR
			ret

// tablica przekodowania klawisze - ASCII w XRAM
male_litery:	mov dptr, #80EBH
			mov a, #"a"
			movx @dptr, a
			
			mov dptr, #8077H
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

duze_litery:	mov dptr, #80EBH
			mov a, #"A"
			movx @dptr, a
			
			mov dptr, #8077H
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
			
			ret

cyfry_litery:	mov dptr, #80EBH
			mov a, #"0"
			movx @dptr, a
			
			mov dptr, #8077H
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
			
			ret
 
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

// funkcja opóznienia
	delay:	mov r0, #03H
	one:	mov r1, #0FFH
	dwa:	mov r2, #0FFH
    trzy:	djnz r2, trzy
			djnz r1, dwa
			djnz r0, one
			ret

// funkcja wypisania znaku
putcharLCD:	LCDcharWR
			ret

// tablica przekodowania klawisze - ASCII w XRAM
male_litery:	mov dptr, #80EBH    ; Adres klawisza przypisanego do litery 'a' w zewn. RAM
			mov a, #"a"     ; Kod ASCII małej litery 'a' do akumulatora
			movx @dptr, a   ; Zapisanie litery 'a' do pamięci zewn. pod wybranym adresem

			mov dptr, #8077H ; Dalej wpisywanie do kolejnych adresów wartości ascii..
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

duze_litery:	mov dptr, #80EBH
			mov a, #"A"
			movx @dptr, a

			mov dptr, #8077H
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

			ret

cyfry_litery:	mov dptr, #80EBH
			mov a, #"0"
			movx @dptr, a

			mov dptr, #8077H
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

			ret

// program glówny
    start:  init_LCD                ; Wywołanie makra rozpoczynającego działanie i czyszczącego ekran
                acall male_litery   ; Inicjalne załadowanie małych liter do pamięci (domyślny tryb klawiatury)

            mov r7, #16             ; Ustawienie licznika wolnych miejsc w linii LCD na 16 znaków
            mov r6, #01h            ; Ustawienie flagi aktualnego wiersza na 1 (01h = 1. linia LCD)

    sprawdz_znak:                   ; Etykieta pętli sprawdzającej miejsce w linii ekranu
        mov a, r7                   ; Pobranie liczby pozostałych wolnych znaków do akumulatora
        jz sprawdz_linie            ; Skok, jeśli a=0 (brak miejsca, linia pełna) do zmiany wiersza
        jmp key_1                   ; W przeciwnym razie skok do testowania pierwszej linii klawiatury


    sprawdz_linie:                  ; Etykieta weryfikująca w którym wierszu LCD się znajdujemy
        mov a, r6                   ; Pobranie flagi aktualnej linii do akumulatora
        jnz ustaw_linie2            ; Jeśli a != 0 (byliśmy w linii 1), skok do przestawienia na linię 2

    ustaw_linie1:                   ; Procedura przejścia na pierwszą linię (gdy ekran jest już pełny)
        LCDcntrlWR #CLEAR           ; Wyczyszczenie całego ekranu
        LCDcntrlWR #HOME            ; Ustawienie kursora na początku pierwszej linii
        mov r7, #16                 ; Zresetowanie licznika znaków z powrotem na 16
        mov r6, #01h                ; Zaktualizowanie flagi stanu: aktualnie 1. wiersz
        jmp key_1                   ; Powrót do sprawdzania klawiatury

    ustaw_linie2:                   ; Procedura przejścia na drugą linię
        LCDcntrlWR #HOM2            ; Ustawienie kursora na początku drugiej linii LCD
        mov r6, #00h                ; Zaktualizowanie flagi stanu: aktualnie 2. wiersz (wartość 00h)
        mov r7, #16                 ; Zresetowanie licznika znaków do 16 dla nowej linii
        ljmp sprawdz_znak           ; Skok długi do ponownego wykonania pętli



    key_1:  mov r0, #LINE_1         ; Załadowanie maski dla pierwszej linii klawiatury do R0
            mov a, r0               ; Przeniesienie maski do akumulatora
            mov P5, a               ; Ustawienie portu P5 (wysłanie sygnału do 1. wiersza klawiatury)
            mov a, P7               ; Odczytanie stanu z portu kolumn P7
            anl a, r0               ; Maska logiczna AND (wyizolowanie stanu wybranej linii)
            mov r2, a               ; Zapisanie odczytanego stanu portu do R2
            clr c                   ; Wyczyszczenie flagi przeniesienia (C)
            subb a, r0              ; Odjęcie maski - jeśli wynik 0, żaden klawisz w tej linii nie został wciśnięty
            jz key_2                ; Skok do testowania kolejnej linii klawiatury (key_2)
            mov a, r2               ; Odtworzenie stanu portu klawiatury do akumulatora
            mov dph, #80h           ; Ustawienie starszej części wskaźnika DPTR (adres XRAM)
            mov dpl, a              ; Ustawienie młodszej części wskaźnika na kod klawisza
            movx a,@dptr            ; Odczytanie konkretnego przypisanego znaku z pamięci zewn.
            mov P1, a               ; Kopia zapasowa odczytanego znaku na port P1
            acall putcharLCD        ; Wysłanie tego odczytanego znaku do LCD
            acall delay             ; Odczekanie (eliminacja drgań styków mechanicznych klawisza)
            dec r7                  ; Dekrementacja dostępnego miejsca (znaków) w aktualnej linii
            ljmp sprawdz_znak       ; Powrót na początek głównej pętli


    key_2:  mov r0, #LINE_2         ; Załadowanie maski dla drugiej linii klawiatury do R0
            mov a, r0
            mov P5, a
            mov a, P7
            anl a, r0
            mov r2, a
            clr c
            subb a, r0
            jz key_3
            mov a, r2
            mov dph, #80h
            mov dpl, a
            movx a,@dptr
            mov P1, a
            acall putcharLCD
            acall delay
            dec r7
            ljmp sprawdz_znak

    key_3:  mov r0, #LINE_3         ; Załadowanie maski dla trzeciej linii klawiatury
            mov a, r0
            mov P5, a
            mov a, P7
            anl a, r0
            mov r2, a
            clr c
            subb a, r0
            jz key_4
            mov a, r2
            mov dph, #80h
            mov dpl, a
            movx a,@dptr
            mov P1, a
            acall putcharLCD
            acall delay
            dec r7
            ljmp sprawdz_znak

    key_4:  mov r0, #LINE_4         ; Załadowanie maski dla czwartej linii klawiatury
            mov a, r0               ; Maska z R0 do A
            mov P5, a               ; Wysterowanie wiersza czwartego
            mov a, P7               ; Odczyt klawiszy wejściowych
            anl a, r0               ; Oczyszczenie nieistotnych bitów (AND)
            mov r2, a               ; Kopia zapasowa w R2
            clr c                   ; Zerowanie flagi przeniesienia (C)
            subb a, r0              ; Badanie wciśnięcia (czy wejście różni się od maski wiersza)
            jz jump_help            ; Skok posiłkowy (gdy nic nie wciśnięto) na początek programu
            mov a, r2               ; Wgranie odczytu z R2 do analizy specjalnej klawiszy funkcyjnych
            clr c                   ; Upewnienie się, że flaga C jest wyzerowana
            subb a, #0EEH           ; Czy wprowadzono klawisz "D"? (adres #0EEH)
            jz na_cyfry_litery      ; Jeśli wynik = 0 (to klawisz "D"), skok na zmianę trybu cyfr
            clr c                   ; Zerowanie C dla kolejnego warunku
            mov a, r2               ; Odtworzenie stanu z R2 do A
            clr c                   ; Kolejne zbędne, lecz bezpieczne czyszczenie flagi C
            subb a, #0E7H           ; Czy wciśnięto klawisz "*"? (adres #0E7H)
            jz na_male              ; Jeśli wynik = 0, skok do trybu małych liter
            clr c                   ; Zerowanie flagi C
            mov a, r2               ; Przywrócenie odczytanego stanu
            subb a, #0EDH           ; Czy wciśnięto klawisz "#"? (adres #0EDH)
            jz na_duze              ; Jeśli wynik = 0, skok do trybu wielkich liter
            clr c                   ; Zerowanie C dla normalnego wyświetlenia znaku
            mov a, r2               ; Przywrócenie pierwotnego odczytu (klawisz inny niż funkcyjny)
        mov dph, #80h               ; Część H wskaźnika tablicy znaków
            mov dpl, a              ; Część L wskaźnika (na podstawie klawisza)
            movx a,@dptr            ; Odczyt znaku dla niefunkcyjnego przycisku czwartej linii
            mov P1, a               ; Wyświetlenie kodu znaku na P1
            acall putcharLCD        ; Wpisanie na ekran
            acall delay             ; Opóźnienie na uspokojenie drgań
            dec r7                  ; Odjęcie jednego znaku od wolnych miejsc
            ljmp sprawdz_znak ; Skok główny na odświeżenie pętli


    jump_help: ljmp sprawdz_znak    ; Etykieta mostkująca dla skoków: wraca do głównej pętli

      na_male:                      ; Etykieta podprogramu obsługi klawisza "*"
        acall male_litery           ; Uruchomienie procedury nadpisywania mapowania RAM małymi literami
        ljmp sprawdz_znak           ; Powrót do odczytu z klawiatury
      na_duze:                      ; Etykieta podprogramu obsługi klawisza "#"
        acall duze_litery           ; Uruchomienie procedury nadpisywania mapowania wielkimi literami
        ljmp sprawdz_znak           ; Powrót do nasłuchiwania klawiszy
      na_cyfry_litery:              ; Etykieta podprogramu obsługi klawisza "D"
        acall cyfry_litery          ; Uruchomienie mapowania cyfr i znaków HEX
        ljmp sprawdz_znak           ; Powrót do działania głównej pętli
    nop
    nop
    nop
    jmp $
    end start

