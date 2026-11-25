# Dokumentacja końcowa - Współdzielony Magazyn Elektroniki (PostgreSQL)

## 1. Cel projektu
Baza danych wspiera grupę studentów we współdzieleniu komponentów elektronicznych. Rozwiązuje problemy: rozproszenia sprzętu, braku kontroli pożyczeń/własności, braku historii operacji oraz chaotycznych wspólnych zakupów.

## 2. Zakres i etapy
- **19.11**: koncepcja, tabele, relacje, typy, role.
- **26.11**: skrypty schematu PostgreSQL i generator danych.
- **03.12**: utworzenie bazy, relacje, proste SELECT-y.
- **10.12**: dodatkowe constrainty, poprawione dane/seed.
- **17.12**: funkcje, triggery, role/uprawnienia.
- **14.01**: dokumentacja końcowa.
- **21.01**: prezentacja projektu.
- **28.01**: termin rezerwowy na poprawy.

## 3. Model danych

### Tabele
- `users` - użytkownicy, role, status konta, blokada logowania.
- `components` - katalog części, part number, minimalny zapas.
- `stock` - bieżący stan: komponent, właściciel, posiadacz, lokalizacja, ilość.
- `movements` - niemodyfikowalny dziennik operacji magazynowych.
- `order_items` - lista zakupowa/koszyk ze statusem i datami.

### Relacje (1:N)
- `components -> stock/movements/order_items`
- `users -> stock` przez `owner_id`, `holder_id`
- `users -> movements` przez `owner_id`, `to_owner_id`, `from_holder_id`, `to_holder_id`, `user_id`
- `users -> order_items` przez `created_by`

## 4. Ograniczenia integralności
- Klucze główne/obce, `NOT NULL`, `UNIQUE`.
- CHECK: nieujemne ilości/progi/ceny, dodatnie ilości ruchów, dozwolone role/statusy/typy operacji.
- Walidacje formatów: username, niepuste nazwy, limity długości.
- Spójność domenowa: `movements` wymaga odpowiednich pól dla `receive/transfer/change_owner/consume`; `order_items` wymaga spójnych dat dla `cart/ordered/received`.
- `ON DELETE RESTRICT` dla krytycznych powiązań, `ON DELETE SET NULL` dla pól audytowych.

## 5. Logika w bazie (funkcje/triggery)
- `prevent_movements_mutation` - blokuje UPDATE/DELETE na `movements`.
- `set_order_timestamps` - ustawia `ordered_at/received_at` zgodnie ze statusem.
- `apply_stock_delta` - bezpiecznie aktualizuje stan magazynu.
- `apply_movement` - trigger AFTER INSERT na `movements`; aktualizuje `stock` dla receive/transfer/change_owner/consume.
- `low_stock()` - raport komponentów poniżej `min_qty`.

## 6. Role i uprawnienia
- `app_user`: odczyt danych, dodawanie komponentów/ruchów/zamówień, ograniczona aktualizacja stock/order_items.
- `app_moderator`: uprawnienia `app_user` + zarządzanie `components`, `stock`, `order_items`.
- `app_admin`: pełne uprawnienia do tabel i sekwencji.

Uwaga: pełne RLS/ograniczenia na poziomie wierszy wg `owner_id/holder_id` można rozszerzyć w kolejnym etapie; obecnie zaimplementowano role i GRANT-y.

## 7. Uruchomienie (PostgreSQL)
Wymagania: PostgreSQL + klient `psql`.

```bash
psql -U postgres -f create_db.sql
```

`create_db.sql` tworzy bazę `magazyn_elektroniki`, ładuje `schema.sql`, `functions_triggers.sql`, `seed.sql`, `roles.sql`.

## 8. Demonstracja
- `demo_select.sql` - podstawowe SELECT-y z JOIN-ami pokazujące relacje i dane.
- `test_constraints.sql` - przykłady poprawnych/błędnych danych dla constraintów.
- `test_logic.sql` - testy triggerów/funkcji, w tym aktualizacja stock i blokada modyfikacji movements.

## 9. Struktura dostarczania
Każdy folder datowany to gotowa paczka tygodniowa z raportem i artefaktami danego etapu, zgodnie z wymaganiami.