# Raport - 17.12.2026

## Cel spotkania
Implementacja funkcji, triggerów oraz ról w bazie danych PostgreSQL.

## Kroki
1. Rozszerzono schemat z 10.12 o funkcje pomocnicze i biznesowe.
2. Dodano triggery: aktualizacja stanu magazynu przy `movements`, walidacja dat/statusów zamówień, automatyczne ustawianie timestampów, ochrona historii `movements` przed edycją/usuwaniem.
3. Zdefiniowano role PostgreSQL: `app_user`, `app_moderator`, `app_admin` oraz nadano uprawnienia GRANT.
4. Przygotowano skrypt `roles.sql`, `functions_triggers.sql` i `test_logic.sql`.
5. Zaktualizowano `create_db.sql`, aby uwzględniał nowe skrypty.

## Wynik końcowy
Baza posiada logikę po stronie PostgreSQL (funkcje/triggery) oraz zdefiniowany model ról i uprawnień.

## Załączniki
- `schema.sql` - schemat z constraintami.
- `seed.sql` - dane testowe.
- `functions_triggers.sql` - funkcje i triggery.
- `roles.sql` - role i uprawnienia.
- `create_db.sql` - pełne tworzenie bazy.
- `test_logic.sql` - testy logiki.