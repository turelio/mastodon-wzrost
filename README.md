##
Repozytorium zawiera skrypty, surowe dane oraz zagregowane zbiory stworzone na potrzeby badania dynamiki wzrostu platformy społecznościowej Mastodon.
## Wymagania
- R 4.3.0 i pakiet tidyverse
- Python 3.11+
## Struktura repozytorium
1. dane/
	- 182 pliki CSV zawierające dzienny zrzut danych z serwisu FediList od 11 listopada 2022 do 11 maja 2023 roku
2. korekta/
	- informacja o ręcznych korektach w zbiorze danych wraz z oryginalnymi plikami
3. rafinacja/
	- nowe zbiory utworzone przez skrypty na podstawie danych wejściowych
	- zbiór all-mastodon.csv musi zostać wygenerowany ręcznie (przez bonus.r) ze względu na ograniczenia wielkości pliku na githubie
4. skrypty Python
	- instancje.py: tworzenie zbioru instancji i informacji o istnieniu serwera na każdy dzień
	- instancje-analiza.py: analiza zbioru 'dane-dzien-instancje.py' i zagregowane badanie ciągłości serwerów oraz zmian w wielkości w czasie
5. skrypty R
	- agregacja-dzien-grupy.r: tworzenie zagregowanego dziennego zestawu z podziałem na grupy wielkości
	- agregacja-dzien-total.r: analogicznie, bez podziału na grupy
	- bonus.r: sklejenie wszystkich danych o Mastodonie w jeden plik, z dodaną informacją o wielkości instancji
	- miesiące.r: uśrednione wskaźniki miesięczne
	- main.r: wizualizacja, tworzenie wykresów na podstawie danych
## Dodatkowe materiały
- [Arkusz Google Sheets z dodatkowymi wizualizacjami wykorzystanymi w opisie wyników badania](https://docs.google.com/spreadsheets/d/10SSCiP-tG6iM-8yaexBSkqkgo0nIPTXGBGBgGCUkO6k/edit?usp=sharing)
