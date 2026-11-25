# Raport - 03.12.2026

## Cel spotkania
Utworzenie bazy danych w PostgreSQL: tabele, kolumny, relacje oraz demonstracja działania za pomocą prostych zapytań SELECT.

## Kroki
1. Wykorzystano schemat PostgreSQL z etapu 26.11 (`schema.sql`).
2. Utworzono skrypt `create_db.sql` do utworzenia bazy i uruchomienia schematu/danych.
3. Przygotowano skrypt `demo_select.sql` z prostymi zapytaniami SELECT pokazującymi tabele, relacje i dane.
4. Wykonano zapytania demonstracyjne: lista komponentów na stanie z właścicielem/posiadaczem, historia operacji z nazwami użytkowników i komponentów, lista zakupowa.
5. Zapisano oczekiwane/uzyskane wyniki w `wyniki_select.md`.

## Wynik końcowy
Komplet skryptów do utworzenia bazy PostgreSQL i demonstracji jej działania. SELECT-y pokazują relacje między `users`, `components`, `stock`, `movements`, `order_items`.

## Załączniki
- `schema.sql` - struktura bazy.
- `seed.sql` - dane testowe.
- `create_db.sql` - utworzenie bazy i załadowanie.
- `demo_select.sql` - zapytania demonstracyjne.
- `wyniki_select.md` - wyniki zapytań.