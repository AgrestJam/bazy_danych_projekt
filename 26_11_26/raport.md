# Raport - 26.11.2026

## Cel spotkania
Rozszerzenie koncepcji z 19.11 o przygotowanie skryptów tworzących strukturę danych oraz skryptów generujących dane do tabel.

## Kroki
1. Przejrzano koncepcję z 19.11 i potwierdzono strukturę 5 tabel: `users`, `components`, `stock`, `movements`, `order_items`.
2. Przygotowano skrypt SQL `schema.sql` definiujący tabele, typy danych, klucze główne/obce oraz podstawowe ograniczenia.
3. Przygotowano skrypt Python `generate_seed.py` do generowania danych testowych zgodnych z ograniczeniami.
4. Uruchomiono generator i wygenerowano plik `seed.sql` z danymi INSERT dla wszystkich tabel.
5. Zweryfikowano spójność danych: klucze obce, unikalność, wartości nieujemne/dodatnie, poprawne statusy i typy operacji.

## Wynik końcowy
Powstał zestaw skryptów umożliwiający utworzenie struktury bazy i wypełnienie jej przykładowymi danymi. Folder zawiera również koncepcję z poprzedniego etapu.

## Załączniki
- `koncepcja.md` - koncepcja z 19.11.
- `schema.sql` - skrypt struktury bazy danych.
- `generate_seed.py` - skrypt generujący dane.
- `seed.sql` - wygenerowane dane do tabel.