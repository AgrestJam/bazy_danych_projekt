# Raport - 19.11.2026

## Cel spotkania
Przeprowadzenie pracy koncepcyjnej nad projektem bazy danych: wybór problemu, zdefiniowanie zakresu, zaprojektowanie wstępnej struktury tabel, relacji, typów danych, ograniczeń oraz ról.

## Kroki
1. Utworzono grupę projektową i wybrano temat: **Współdzielony Magazyn Elektroniki**.
2. Zidentyfikowano problem: rozproszenie prywatnych komponentów elektronicznych wśród studentów, brak śledzenia własności/pożyczeń oraz trudności w organizacji wspólnych zakupów.
3. Zaprojektowano wstępny model danych składający się z 5 tabel: `users`, `components`, `stock`, `movements`, `order_items`.
4. Określono kolumny, typy danych i wstępne ograniczenia (`PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, `CHECK`, wartości domyślne).
5. Zdefiniowano relacje 1:N między tabelami, w tym podwójne/wielokrotne relacje `users` do `stock` i `movements`.
6. Zaplanowano role bazodanowe: `app_user`, `app_moderator`, `app_admin` wraz z zakresem uprawnień.

## Wynik końcowy
Powstał dokument koncepcyjny opisujący cel systemu, strukturę bazy danych, relacje, ograniczenia i role. Dokument stanowi podstawę do dalszych etapów implementacji.

## Załączniki
- `koncepcja.md` - pełna koncepcja projektu bazy danych.
