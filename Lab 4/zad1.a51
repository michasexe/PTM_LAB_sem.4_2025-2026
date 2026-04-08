ljmp start                      ; Skok bezwarunkowy do etykiety 'start' (początek programu głównego)

P5 equ 0F8H                     ; Zdefiniowanie adresu portu P5 (sterowanie wierszami klawiatury)
P7 equ 0DBH                     ; Zdefiniowanie adresu portu P7 (odczyt kolumn klawiatury)
	
LCDstatus  equ 0FF2EH           ; Zdefiniowanie adresu do odczytu flagi gotowości wyświetlacza LCD
LCDcontrol equ 0FF2CH           ; Zdefiniowanie adresu do wysyłania komend sterujących do LCD
LCDdataWR  equ 0FF2DH           ; Zdefiniowanie adresu do wysyłania danych (znaków ASCII) do LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME     0x80          // Makro: komenda powrotu kursora na początek pierwszej linii
#define  INITDISP 0x38          // Makro: komenda inicjalizacji LCD w trybie 8-bitowym
#define  HOM2     0xc0          // Makro: komenda przejścia kursora na początek drugiej linii
#define  LCDON    0x0e          // Makro: komenda włączenia LCD, wyłączenia kursora i jego migania
#define  CLEAR    0x01          // Makro: komenda wyczyszczenia całego ekranu LCD

// linie klawiatury - sterowanie na port P5
#define LINE_1		0x7f        // Makro: maska dla 1. wiersza klawiatury (0111 1111)
#define LINE_2		0xbf        // Makro: maska dla 2. wiersza klawiatury (1011 1111)
#define	LINE_3		0xdf        // Makro: maska dla 3. wiersza klawiatury (1101 1111)
#define LINE_4		0xef        // Makro: maska dla 4. wiersza klawiatury (1110 1111)
#define ALL_LINES	0x0f        // Makro: maska dla wszystkich wierszy (0000 1111)

org 0100H                       ; Ustawienie licznika programu na adres 0100H (od tego miejsca kompilowany jest kod)
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x              ; Definicja makra wysyłającego komendę do LCD, przyjmuje parametr 'x'
           LOCAL loop           ; Deklaracja lokalnej etykiety 'loop', aby uniknąć konfliktów nazw
loop: MOV  DPTR,#LCDstatus      ; Załadowanie do rejestru DPTR adresu statusu LCD
      MOVX A,@DPTR              ; Odczytanie statusu LCD do akumulatora (A)
      JB   ACC.7,loop           ; Skok do 'loop' jeśli 7. bit w A jest ustawiony (LCD jest zajęte)
      MOV  DPTR,#LCDcontrol     ; Załadowanie do DPTR adresu rejestru kontrolnego LCD
      MOV  A, x                 ; Skopiowanie komendy (parametru 'x') do akumulatora
      MOVX @DPTR,A              ; Wysłanie komendy z akumulatora do sprzętu (do LCD)
      ENDM                      ; Koniec definicji makra
	  
// macro do wypisania znaku ASCII na LCD, znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO                 ; Definicja makra wypisującego znak na LCD
      LOCAL tutu                ; Deklaracja lokalnej etykiety 'tutu'
      PUSH ACC                  ; Odłożenie akumulatora (znaku ASCII) na stos, aby go nie stracić
tutu: MOV  DPTR,#LCDstatus      ; Załadowanie do rejestru DPTR adresu statusu LCD
      MOVX A,@DPTR              ; Odczytanie statusu LCD do akumulatora
      JB   ACC.7,tutu           ; Skok do 'tutu' jeśli LCD jest zajęte (Busy Flag = 1)
      MOV  DPTR,#LCDdataWR      ; Załadowanie do DPTR adresu rejestru danych LCD
      POP  ACC                  ; Zdjęcie zapisanego wcześniej znaku ze stosu z powrotem do A
      MOVX @DPTR,A              ; Wysłanie znaku z akumulatora do LCD
      ENDM                      ; Koniec definicji makra
	  
// macro do inicjalizacji wyswietlacza – bez parametrów
init_LCD MACRO                  ; Definicja makra inicjującego LCD
         LCDcntrlWR #INITDISP   ; Wywołanie makra sterującego: inicjalizacja 8-bitowa
         LCDcntrlWR #CLEAR      ; Wywołanie makra sterującego: czyszczenie ekranu
         LCDcntrlWR #LCDON      ; Wywołanie makra sterującego: włączenie ekranu
         ENDM                   ; Koniec definicji makra

// funkcja opóznienia
	delay:	mov r1, #0FFH       ; Załadowanie do rejestru R1 wartości 255 (zewnętrzna pętla)
	dwa:	mov r2, #0FFH       ; Załadowanie do rejestru R2 wartości 255 (wewnętrzna pętla)
    trzy:	djnz r2, trzy       ; Zmniejsz R2 o 1 i skocz do 'trzy' jeśli nie jest równe 0
			djnz r1, dwa        ; Zmniejsz R1 o 1 i skocz do 'dwa' jeśli nie jest równe 0
			ret                 ; Powrót z podprogramu opóźnienia
			
// funkcja wypisania znaku
putcharLCD:	LCDcharWR           ; Wywołanie makra wyświetlającego znak z akumulatora na LCD
			ret                 ; Powrót z podprogramu

// TABLICA PRZEKODOWAŃ: MAŁE LITERY
keyascii_lower:	mov dptr, #80EBH ; Ustawienie adresu dla pierwszego klawisza (0x80EB w XRAM)
			mov a, #"a"         ; Załadowanie kodu ASCII litery 'a' do A
			movx @dptr, a       ; Zapisanie 'a' w pamięci pod adresem pierwszego klawisza
			
			mov dptr, #8077H    ; Ustawienie adresu dla drugiego klawisza
			mov a, #"b"         ; Załadowanie litery 'b'
			movx @dptr, a       ; Zapis w XRAM
			
			mov dptr, #807BH    ; Adres klawisza 3
			mov a, #"c"         ; Znak 'c'
			movx @dptr, a       ; Zapis w XRAM
			
			mov dptr, #807DH    ; Adres klawisza 4
			mov a, #"d"         ; Znak 'd'
			movx @dptr, a       ; Zapis w XRAM
			
			mov dptr, #80B7H    ; Adres klawisza 5
			mov a, #"e"         ; Znak 'e'
			movx @dptr, a       ; Zapis w XRAM
			
			mov dptr, #80BBH    ; Adres klawisza 6
			mov a, #"f"         ; Znak 'f'
			movx @dptr, a       ; Zapis w XRAM
			
			mov dptr, #80BDH    ; Adres klawisza 7
			mov a, #"g"         ; Znak 'g'
			movx @dptr, a       ; Zapis w XRAM
			
			mov dptr, #80D7H    ; Adres klawisza 8
			mov a, #"h"         ; Znak 'h'
			movx @dptr, a       ; Zapis w XRAM
			
			mov dptr, #80DBH    ; Adres klawisza 9
			mov a, #"i"         ; Znak 'i'
			movx @dptr, a       ; Zapis w XRAM
			
			mov dptr, #80DDH    ; Adres klawisza 10
			mov a, #"j"         ; Znak 'j'
			movx @dptr, a       ; Zapis w XRAM
			
			mov dptr, #807EH    ; Adres klawisza 11
			mov a, #"k"         ; Znak 'k'
			movx @dptr, a       ; Zapis w XRAM
			
			mov dptr, #80BEH    ; Adres klawisza 12
			mov a, #"l"         ; Znak 'l'
			movx @dptr, a       ; Zapis w XRAM
			
			mov dptr, #80DEH    ; Adres klawisza 13
			mov a, #"m"         ; Znak 'm'
			movx @dptr, a       ; Zapis w XRAM
			
			mov dptr, #80EEH    ; Adres klawisza 'D'
			mov a, #"D"         ; Klawisz funkcyjny 'D' (pozostaje sobą w tablicy, obsługa jest gdzie indziej)
			movx @dptr, a       ; Zapis w XRAM
			
			mov dptr, #80E7H    ; Adres klawisza '*'
			mov a, #"*"         ; Klawisz funkcyjny '*'
			movx @dptr, a       ; Zapis w XRAM
			
			mov dptr, #80EDH    ; Adres klawisza '#'
			mov a, #"#"         ; Klawisz funkcyjny '#'
			movx @dptr, a       ; Zapis w XRAM
			
			ret                 ; Powrót z podprogramu inicjującego małe litery

// TABLICA PRZEKODOWAŃ: DUŻE LITERY
keyascii_upper:	mov dptr, #80EBH ; Adres w XRAM
			mov a, #"A"         ; Duża litera 'A'
			movx @dptr, a       ; Zapis do pamięci
			
			mov dptr, #8077H    ; Kolejny adres klawisza
			mov a, #"B"         ; Litera 'B'
			movx @dptr, a       ; Zapis
			
			mov dptr, #807BH    ; ... i tak dalej dla reszty znaków ...
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
			
			mov dptr, #80EEH    ; Klawisze funkcyjne również są wpisywane
			mov a, #"D"
			movx @dptr, a
			
			mov dptr, #80E7H
			mov a, #"*"
			movx @dptr, a
			
			mov dptr, #80EDH
			mov a, #"#"
			movx @dptr, a
			
			ret                 ; Powrót z podprogramu inicjującego duże litery

// tablica przekodowania klawisze - ASCII w XRAM: CYFRY
keyascii_num:	mov dptr, #80EBH ; Adres w XRAM dla pierwszego przycisku
			mov a, #"0"         ; Cyfra '0'
			movx @dptr, a       ; Zapis pod dany adres
			
			mov dptr, #8077H    ; Drugi adres
			mov a, #"1"         ; Cyfra '1'
			movx @dptr, a       ; Zapis
			
			mov dptr, #807BH    ; ... i analogicznie dla pozostałych cyfr i liter A, B, C ...
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
			
			mov dptr, #80EEH    ; Funkcyjne bez zmian
			mov a, #"D"
			movx @dptr, a
			
			mov dptr, #80E7H
			mov a, #"*"
			movx @dptr, a
			
			mov dptr, #80EDH
			mov a, #"#"
			movx @dptr, a
			
			ret                 ; Powrót z podprogramu inicjującego cyfry
 
// program glówny
    start:  init_LCD            ; Wywołanie makra inicjującego ekran LCD
	
			acall keyascii_lower ; Na starcie ładujemy do XRAM układ klawiatury z małymi literami

			mov r7, #10h        ; Załadowanie do rejestru R7 wartości 16 (ilość znaków w linii)
			mov r6, #01h        ; Załadowanie do rejestru R6 wartości 1 (flaga oznaczająca 1. linię LCD)

	check_chars:	mov a, r7   ; Kopiowanie ilości pozostałych znaków do A
			jz  check_line      ; Jeśli A wynosi 0 (linia jest pełna), skocz do sprawdzania zmiany linii
			jmp key_1           ; Jeśli jest miejsce, idź do skanowania klawiatury (pierwszy wiersz)
	check_line:	mov a, r6       ; Skopiuj do A flagę obecnej linii
			jnz set_line2       ; Jeśli to pierwsza linia (flaga nie jest 0), przeskocz do ustawiania linii 2
	set_line1:	LCDcntrlWR #CLEAR ; Wywołaj czyszczenie ekranu (bo obie linie były już pełne)
			LCDcntrlWR #HOME    ; Ustaw kursor na domyślnej pierwszej pozycji
			mov r7, #10h        ; Zresetuj licznik znaków w linii do 16
			mov r6, #01h        ; Ustaw flagę linii z powrotem na 1 (pierwsza linia)
			jmp key_1           ; Przejdź do skanowania klawiatury
	set_line2:	LCDcntrlWR #HOM2  ; Ustaw kursor na początku drugiej linii
			mov r6, #00h        ; Ustaw flagę linii na 0 (druga linia)
			mov r7, #10h        ; Zresetuj licznik znaków dla nowej (drugiej) linii
	
	key_1:	mov r0, #LINE_1     ; Załaduj do R0 maskę pierwszego wiersza klawiatury
			mov	a, r0           ; Skopiuj maskę wiersza do akumulatora
			mov	P5, a           ; Wystaw maskę na port P5 (aktywacja pierwszego wiersza)
			mov a, P7           ; Odczytaj stan portu P7 (stany kolumn) do A
			anl a, r0           ; Logiczny AND (maskowanie) stanu portu P7 ze sprawdzanym wierszem
			mov r2, a           ; Zapisz wynik maskowania (kod klawisza) do rejestru R2
			clr c               ; Wyczyść flagę przeniesienia przed odejmowaniem
			subb a, r0          ; Odejmij od odczytu stan maski bazowej wiersza
			jz key_2            ; Jeśli wynik to 0, nic nie wciśnięto - skocz do skanowania 2. wiersza
			mov a, r2           ; Przywróć kod wciśniętego klawisza do A z R2
			mov dph, #80h       ; Ustaw starszy bajt wskaźnika DPTR na 0x80 (początek adresu XRAM)
			mov dpl, a          ; Ustaw młodszy bajt DPTR na kod wciśniętego klawisza (tworzy pełny adres)
			movx a,@dptr        ; Odczytaj z XRAM znak pod wyliczonym adresem do A
			mov P1, a           ; (Opcjonalnie) wyrzuć znak na port P1 (np. diody)
			acall putcharLCD    ; Wypisz znak z akumulatora na LCD
			acall delay         ; Odczekaj chwilę, eliminując drgania styków klawisza
			dec r7              ; Zmniejsz o 1 licznik pozostałych miejsc w bieżącej linii
			
	key_2:	mov r0, #LINE_2     ; Załaduj do R0 maskę drugiego wiersza
			mov	a, r0           ; Skopiuj maskę wiersza do akumulatora
			mov	P5, a           ; Aktywacja drugiego wiersza
			mov a, P7           ; Odczyt kolumn
			anl a, r0           ; Maskowanie
			mov r2, a           ; Zapisanie wyniku do R2
			clr c               ; Czyszczenie flagi C
			subb a, r0          ; Sprawdzenie czy coś wciśnięto
			jz key_3            ; Jeśli nie, skocz do sprawdzania 3. wiersza
			mov a, r2           ; Jeśli tak, pobierz zapamiętany kod
			mov dph, #80h       ; Ustaw starszy bajt adresu XRAM
			mov dpl, a          ; Ustaw młodszy bajt adresu na kod klawisza
			movx a,@dptr        ; Pobierz znak z XRAM
			mov P1, a           ; (Opcjonalnie) wyświetl na porcie P1
			acall putcharLCD    ; Wypisz znak na LCD
			acall delay         ; Opóźnienie na drgania styków
			dec r7              ; Zmniejsz licznik znaków w linii
			
	key_3:	mov r0, #LINE_3     ; Załaduj do R0 maskę trzeciego wiersza
			mov	a, r0           ; Kopiuj do A
			mov	P5, a           ; Aktywacja trzeciego wiersza na P5
			mov a, P7           ; Odczyt kolumn z P7
			anl a, r0           ; Maskowanie wyniku
			mov r2, a           ; Zapamiętaj kod w R2
			clr c               ; Wyczyść flagę przeniesienia
			subb a, r0          ; Sprawdź czy jest wciśnięty
			jz key_4            ; Jeśli nie, skocz do 4. wiersza
			mov a, r2           ; Jeśli tak, pobierz kod z R2
			mov dph, #80h       ; Adresacja XRAM - starszy bajt
			mov dpl, a          ; Adresacja XRAM - kod klawisza to młodszy bajt
			movx a,@dptr        ; Pobierz odpowiedni znak
			mov P1, a           ; Wyślij zdekodowany znak na P1
			acall putcharLCD    ; Wypisz znak
			acall delay         ; Odczekaj na drgania styków
			dec r7              ; Zmniejsz licznik miejsc w linii
			
	key_4:	mov r0, #LINE_4     ; Załaduj do R0 maskę czwartego wiersza
			mov	a, r0           ; Skopiuj do A
			mov	P5, a           ; Aktywuj czwarty wiersz
			mov a, P7           ; Odczyt klawiatury
			anl a, r0           ; Maskowanie
			mov r2, a           ; Zapamiętaj kod
			clr c               ; Czyszczenie C
			subb a, r0          ; Czy wciśnięto klawisz?
			jz jump_help        ; Jeśli nie, wykonaj skok pomocniczy (żeby nie przekroczyć zasięgu jz)
			mov a, r2           ; Przywróć kod wciśniętego klawisza do A
			clr c               ; Wyczyść flagę C przed sprawdzaniem klawiszy specjalnych
			subb a, #0E7h       ; Czy naciśnięty kod to 0xE7 (klawisz '*')?
			jz to_lower         ; Jeśli tak, skocz do podprogramu zmieniającego na małe litery
			clr c               ; Wyczyść flagę C
			mov a, r2           ; Pobierz ponownie kod klawisza
			subb a, #0EDh       ; Czy naciśnięty kod to 0xED (klawisz '#')?
			jz to_upper         ; Jeśli tak, skocz do zmiany na duże litery
			clr c               ; Wyczyść flagę C
			mov a, r2           ; Pobierz kod klawisza
			subb a, #0EEh       ; Czy to kod 0xEE (klawisz 'D')?
			jz to_num           ; Jeśli tak, skocz do zestawu cyfr
			clr c               ; Wyczyść flagę C (jeśli to żaden z powyższych, to zwykły znak z 4. linii)
			mov a, r2           ; Pobierz kod wciśniętego klawisza do A
	skip:                       ; Etykieta (tutaj opcjonalna, pozostałość strukturalna)
			mov dph, #80h       ; Adres XRAM starszy bajt
			mov dpl, a          ; Kod klawisza jako młodszy bajt adresu
			movx a,@dptr        ; Odczytaj z XRAM znak
			mov P1, a           ; Wyślij na P1
			acall putcharLCD    ; Wyświetl znak na ekranie
			acall delay         ; Odczekaj (debouncing)
			
			dec r7              ; Zmniejsz ilość dostępnych miejsc na LCD
			ljmp check_chars    ; Długi skok - wróć na początek pętli do sprawdzania długości linii i skanowania
            
	jump_help: 	ljmp check_chars ; Skok z powodu braku wciśnięcia w 4. linii (wymuszone ze względu na zasięg relatywny jz)

	to_lower:                   ; Etykieta wykonawcza dla zmiany układu
			acall keyascii_lower ; Wywołanie nadpisania XRAM tablicą małych liter
			ljmp check_chars    ; Powrót na początek głównej pętli
	to_upper:                   ; Etykieta zmiany na duże
			acall keyascii_upper ; Wywołanie nadpisania XRAM dużymi literami
			ljmp check_chars    ; Powrót na początek
	to_num:                     ; Etykieta zmiany na cyfry
			acall keyascii_num  ; Wywołanie nadpisania XRAM cyframi
			ljmp check_chars    ; Powrót na początek
          
 
    nop                         ; Pusta operacja (No Operation) - często jako wypełniacz
    nop                         ; Kolejny wypełniacz
    nop                         ; Kolejny wypełniacz
    jmp $                       ; Zatrzymanie programu - skok do tej samej linijki w nieskończoność (endless loop)
    end start                   ; Dyrektywa kompilatora oznaczająca fizyczny koniec kodu i punkt wejścia 'start'