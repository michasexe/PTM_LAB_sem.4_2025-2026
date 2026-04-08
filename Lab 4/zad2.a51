ljmp start                      ; Skok bezwarunkowy do etykiety 'start' (początek programu)

P5 equ 0F8H                     ; Adres portu P5 (używany do aktywacji wierszy klawiatury)
P7 equ 0DBH                     ; Adres portu P7 (używany do odczytu stanu kolumn klawiatury)
	
LCDstatus  equ 0FF2EH           ; Adres pamięci przypisany do odczytu statusu wyświetlacza LCD (Busy Flag)
LCDcontrol equ 0FF2CH           ; Adres pamięci przypisany do wysyłania komend sterujących LCD
LCDdataWR  equ 0FF2DH           ; Adres pamięci przypisany do wysyłania danych (znaków ASCII) na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME     0x80          // Komenda: powrót kursora na początek 1. linii
#define  INITDISP 0x38          // Komenda: inicjalizacja LCD, interfejs 8-bitowy, 2 linie, znak 5x7
#define  HOM2     0xc0          // Komenda: przejście kursora na początek 2. linii
#define  LCDON    0x0e          // Komenda: włącz wyświetlacz, włącz kursor, wyłącz miganie
#define  CLEAR    0x01          // Komenda: wyczyść cały ekran

// linie klawiatury - sterowanie na port P5
#define LINE_1		0x7f        // Maska aktywująca 1. wiersz klawiatury (0111 1111)
#define LINE_2		0xbf        // Maska aktywująca 2. wiersz klawiatury (1011 1111)
#define	LINE_3		0xdf        // Maska aktywująca 3. wiersz klawiatury (1101 1111)
#define LINE_4		0xef        // Maska aktywująca 4. wiersz klawiatury (1110 1111)
#define ALL_LINES	0x0f        // Maska dla wszystkich wierszy (0000 1111)

org 0100H                       ; Ustawienie początkowego adresu kompilacji programu na 0x0100
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x              ; Definicja makra wysyłającego komendę, przyjmuje argument 'x'
           LOCAL loop           ; Deklaracja lokalnej etykiety, by zapobiec błędom kompilacji przy wielokrotnym użyciu
loop: MOV  DPTR,#LCDstatus      ; Załaduj wskaźnik DPTR adresem statusu LCD
      MOVX A,@DPTR              ; Odczytaj status LCD do akumulatora (A)
      JB   ACC.7,loop           ; Jeśli najstarszy bit (Busy Flag) to 1, LCD jest zajęty - czekaj w pętli
      MOV  DPTR,#LCDcontrol     ; Zmień adres w DPTR na rejestr kontrolny LCD
      MOV  A, x                 ; Skopiuj przekazaną komendę 'x' do akumulatora
      MOVX @DPTR,A              ; Wyślij komendę z akumulatora do LCD
      ENDM                      ; Koniec makra
	  
// macro do wypisania znaku ASCII na LCD, znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO                 ; Definicja makra wypisującego znak
      LOCAL tutu                ; Lokalna etykieta
      PUSH ACC                  ; Zabezpiecz znak ASCII, odkładając go na stos
tutu: MOV  DPTR,#LCDstatus      ; Załaduj DPTR adresem statusu
      MOVX A,@DPTR              ; Odczytaj status
      JB   ACC.7,tutu           ; Czekaj, aż LCD będzie gotowy na przyjęcie danych
      MOV  DPTR,#LCDdataWR      ; Zmień adres w DPTR na rejestr danych
      POP  ACC                  ; Zdejmij zapamiętany znak ASCII ze stosu do akumulatora
      MOVX @DPTR,A              ; Wyślij znak do wyświetlacza
      ENDM                      ; Koniec makra
	  
// macro do inicjalizacji wyswietlacza – bez parametrów
init_LCD MACRO                  ; Definicja makra inicjalizującego
         LCDcntrlWR #INITDISP   ; Wyślij komendę inicjalizacji
         LCDcntrlWR #CLEAR      ; Wyślij komendę czyszczenia ekranu
         LCDcntrlWR #LCDON      ; Wyślij komendę włączenia LCD i kursora
         ENDM                   ; Koniec makra

// funkcja opóznienia
	delay:	mov r1, #0FFH       ; Załaduj zewnętrzny licznik pętli (255) do R1
	dwa:	mov r2, #0FFH       ; Załaduj wewnętrzny licznik pętli (255) do R2
    trzy:	djnz r2, trzy       ; Zmniejszaj R2 aż osiągnie 0 (wewnętrzna pętla)
			djnz r1, dwa        ; Zmniejszaj R1 aż osiągnie 0 (zewnętrzna pętla)
			ret                 ; Wróć z podprogramu opóźnienia
			
// funkcja wypisania znaku
putcharLCD:	LCDcharWR           ; Użyj makra do wypisania znaku, który jest w akumulatorze
			ret                 ; Wróć z podprogramu

// tablica przekodowania klawisze - ASCII w XRAM
keyascii:	mov dptr, #80EBH    ; Ustaw adres dla 1. klawisza
			mov a, #"0"         ; Przygotuj znak '0'
			movx @dptr, a       ; Zapisz znak w pamięci XRAM
			
			mov dptr, #8077H    ; Adres 2. klawisza
			mov a, #"1"         ; Znak '1'
			movx @dptr, a       ; Zapisz
			
			mov dptr, #807BH    ; Adres 3. klawisza
			mov a, #"2"         ; Znak '2'
			movx @dptr, a       ; Zapisz
			
			mov dptr, #807DH    ; Adres 4. klawisza
			mov a, #"3"         ; Znak '3'
			movx @dptr, a       ; Zapisz
			
			mov dptr, #80B7H    ; I tak dalej dla wszystkich cyfr...
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
			
			mov dptr, #807EH    ; Znak 'A'
			mov a, #"A"
			movx @dptr, a
			
			mov dptr, #80BEH    ; Znak 'B'
			mov a, #"B"
			movx @dptr, a
			
			mov dptr, #80DEH    ; Znak 'C'
			mov a, #"C"
			movx @dptr, a
			
			mov dptr, #80EEH    ; Znak 'D'
			mov a, #"D"
			movx @dptr, a
			
			mov dptr, #80E7H    ; Znak '*'
			mov a, #"*"
			movx @dptr, a
			
			mov dptr, #80EDH    ; Znak '#'
			mov a, #"#"
			movx @dptr, a
			
			ret                 ; Koniec inicjalizacji tablicy przekodowań
 
// program glówny
    start:  init_LCD            ; Wywołanie makra inicjującego ekran LCD
	
			acall keyascii      ; Wpisanie znaków ASCII do pamięci XRAM (stworzenie LUT)

			mov r7, #10h        ; R7 to licznik znaków w wierszu. Ustawienie na 16 (szesnastkowo 10h)
			mov r6, #01h        ; R6 to flaga bieżącej linii LCD. 01h = pierwsza linia, 00h = druga linia

	check_chars:	mov a, r7   ; Kopiuj ilość pozostałych miejsc do akumulatora
			jz  check_line      ; Jeśli wyczerpano miejsce (A=0), skocz do logiki zmiany linii
			jmp key_1           ; W przeciwnym razie przeskocz bezpośrednio do skanowania klawiatury
            
	check_line:	mov a, r6       ; Kopiuj flagę linii do akumulatora
			jnz set_line2       ; Jeśli to pierwsza linia (A nie jest zerem), skocz ustawić kursor na 2. linię
            
	set_line1:	LCDcntrlWR #CLEAR ; Byliśmy w 2. linii, więc wyczyść cały ekran
			LCDcntrlWR #HOME    ; Ustaw kursor na początku 1. linii
			mov r7, #10h        ; Zresetuj licznik znaków do 16
			mov r6, #01h        ; Zaktualizuj flagę - znów jesteśmy w 1. linii
			jmp key_1           ; Przejdź do skanowania klawiatury
            
	set_line2:	LCDcntrlWR #HOM2  ; Ustaw kursor na początku 2. linii
			mov r6, #00h        ; Zaktualizuj flagę na 0 (oznacza 2. linię)
			mov r7, #10h        ; Zresetuj licznik znaków do 16 dla nowej linii
	
	key_1:	mov r0, #LINE_1     ; Załaduj do R0 maskę 1. wiersza klawiatury
			mov	a, r0           ; Kopiuj maskę do akumulatora
			mov	P5, a           ; Wystaw maskę na P5, aktywując odczyt pierwszego wiersza
			mov a, P7           ; Odczytaj stany kolumn z portu P7
			anl a, r0           ; Zamaskuj wynik z wybranym wierszem
			mov r2, a           ; Zapisz odczytany kod w R2
			clr c               ; Wyczyść flagę C przed odejmowaniem
			subb a, r0          ; Porównaj z maską. Jeśli równe 0, nic nie wciśnięto.
			jz key_2            ; Nic nie wciśnięto - przejdź do skanowania 2. wiersza
			mov a, r2           ; Wciśnięto przycisk! Przywróć kod do A
			mov dph, #80h       ; Ustaw starszą część wskaźnika adresu RAM (0x80)
			mov dpl, a          ; Ustaw młodszą część na odczytany kod (tworzy adres np. 0x80EB)
			movx a,@dptr        ; Pobierz z pamięci odpowiedni znak ASCII
			mov P1, a           ; (Opcjonalnie) wyrzuć kod znaku na P1
			acall putcharLCD    ; Wypisz ten znak na ekranie LCD
			acall delay         ; Opóźnienie eliminujące drgania styków klawisza
			dec r7              ; Odlicz 1 znak z bieżącej linii
			
	key_2:	mov r0, #LINE_2     ; Załaduj maskę 2. wiersza
			mov	a, r0           ; Skopiuj do A
			mov	P5, a           ; Aktywuj 2. wiersz
			mov a, P7           ; Odczytaj kolumny
			anl a, r0           ; Maskuj
			mov r2, a           ; Zapisz kod do R2
			clr c               ; Czyszczenie C
			subb a, r0          ; Sprawdź czy naciśnięto
			jz key_3            ; Brak naciśnięcia -> skok do 3. wiersza
			mov a, r2           ; Przywróć kod
			mov dph, #80h       ; Adres XRAM wysoki bajt
			mov dpl, a          ; Adres XRAM niski bajt
			movx a,@dptr        ; Pobierz ASCII z pamięci
			mov P1, a           ; Wyślij na P1
			acall putcharLCD    ; Pokaż na LCD
			acall delay         ; Odczekaj chwilę
			dec r7              ; Zmniejsz dostępną ilość miejsc o 1
			
	key_3:	mov r0, #LINE_3     ; Załaduj maskę 3. wiersza
			mov	a, r0           ; Kopiuj do A
			mov	P5, a           ; Aktywuj 3. wiersz
			mov a, P7           ; Odczytaj P7
			anl a, r0           ; Maskowanie
			mov r2, a           ; Zapisz do R2
			clr c               ; Wyzeruj przeniesienie
			subb a, r0          ; Sprawdzanie
			jz key_4            ; Brak wciśnięcia -> idź do 4. wiersza
			mov a, r2           ; Wciśnięto klawisz
			mov dph, #80h       ; Adresacja
			mov dpl, a          ; ...
			movx a,@dptr        ; Odczyt znaku
			mov P1, a           ; P1
			acall putcharLCD    ; Wypisanie
			acall delay         ; Opóźnienie debouncingowe
			dec r7              ; Aktualizacja licznika znaków
			
	key_4:	mov r0, #LINE_4     ; Załaduj maskę 4. wiersza
			mov	a, r0           ; Skopiuj
			mov	P5, a           ; Aktywuj
			mov a, P7           ; Odczyt
			anl a, r0           ; Maskowanie
			mov r2, a           ; Zapamiętanie kodu
			clr c               ; Czyszczenie
			subb a, r0          ; Testowanie wciśnięcia
			jz jump_help        ; Brak wciśnięcia -> skok pomocniczy
			mov a, r2           ; Odtworzenie kodu w A
			mov dph, #80h       ; Ustalanie adresu
			mov dpl, a          ; (W tym zadaniu 4. linia działa tak jak reszta, nie ma zmiany układów)
			movx a,@dptr        ; Pobranie ASCII
			mov P1, a           ; P1
			acall putcharLCD    ; Wyświetlenie na ekranie
			acall delay         ; Czekanie
			
			dec r7              ; Zmniejszenie dostępnego miejsca
			ljmp check_chars    ; Długi skok z powrotem na początek, aby zaktualizować LCD i kontynuować
            
	jump_help: 	ljmp check_chars ; Skok omijający (użyty dlatego, że instrukcja JZ ma krótki zasięg i bezpośrednio nie doskoczyłaby na początek)
          
 
    nop                         ; Pusta instrukcja (brak akcji)
    nop                         ; Pusta instrukcja
    nop                         ; Pusta instrukcja
    jmp $                       ; Zapętlenie się programu w nieskończoność (koniec wykonywalnego kodu)
    end start                   ; Znacznik końca dla kompilatora