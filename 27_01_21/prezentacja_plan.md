# Plan prezentacji projektu (ok. 7 min)

## 1. Problem i cel (0:00-0:45)
- Współdzielony magazyn elektroniki dla studentów.
- Problemy: rozproszenie części, pożyczki bez kontroli, brak historii, wspólne zakupy.
- Rozwiązanie: baza PostgreSQL z owner/holder, movement log, order items.

## 2. Model danych i relacje (0:45-2:00)
- 5 tabel: `users`, `components`, `stock`, `movements`, `order_items`.
- Kluczowa idea: `owner_id` vs `holder_id`.
- Relacje 1:N, klucze obce, `ON DELETE RESTRICT/SET NULL`.
- Pokaż fragment `schema.sql`.

## 3. Constrainty i jakość danych (2:00-3:15)
- CHECK dla qty/cost/role/status/kind.
- Warunki spójności dla `movements` i `order_items`.
- Pokaż `test_constraints.sql` - przykład odrzuconego insertu.

## 4. Logika: funkcje, triggery, role (3:15-5:00)
- Trigger `apply_movement` aktualizuje `stock`.
- `movements` jako niemodyfikowalny audit log.
- `set_order_timestamps` dla statusów zamówień.
- Role: `app_user`, `app_moderator`, `app_admin`.
- Pokaż `functions_triggers.sql` i `roles.sql`.

## 5. Demo działania (5:00-6:30)
- Uruchomienie: `psql -U postgres -f create_db.sql`.
- `demo_select.sql`: stan magazynu, historia operacji, lista zakupowa.
- `test_logic.sql`: transfer/receive i raport `low_stock()`.

## 6. Podsumowanie (6:30-7:00)
- Co działa: spójny model, integralność, logika magazynowa, role.
- Możliwe rozszerzenia: RLS, widoki, aplikacja frontend/API.