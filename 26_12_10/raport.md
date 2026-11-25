# Raport - 10.12.2026

## Cel spotkania
Dodanie warunków (constraints/checków) dla kolumn, wypełnienie tabel danymi oraz ewentualna poprawa skryptów generujących dane.

## Kroki
1. Przejrzano schemat z 03.12 i zidentyfikowano miejsca wymagające mocniejszych warunków domenowych.
2. Rozszerzono `schema.sql` o dodatkowe ograniczenia: niepuste nazwy/loginy, format username, długość haseł/tekstów, daty statusów zamówień, spójność pól dla typów `movements`.
3. Zaktualizowano `generate_seed.py`, aby generował dane zgodne z nowymi warunkami.
4. Wygenerowano nowy `seed.sql` i dodano `test_constraints.sql` z przykładami zapytań, które powinny przejść/nie przejść.
5. Wykonano sprawdzenie logiczne spójności danych i constraintów.

## Wynik końcowy
Schemat PostgreSQL ma rozszerzone warunki integralności. Dane seed są zgodne z ograniczeniami, a skrypt testowy dokumentuje walidację.

## Załączniki
- `schema.sql` - zaktualizowany schemat z constraintami.
- `generate_seed.py` - zaktualizowany generator.
- `seed.sql` - dane testowe.
- `test_constraints.sql` - testy ograniczeń.
- `demo_select.sql` - zapytania demonstracyjne.