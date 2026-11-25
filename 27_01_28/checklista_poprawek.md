# Checklista poprawek (28.01.2027)

## Sprawdzenie kompletności
- [ ] Raport tygodniowy zawiera cel, kroki, wynik, załączniki.
- [ ] Schemat PostgreSQL tworzy się bez błędów (`create_db.sql`).
- [ ] Dane seed ładują się poprawnie.
- [ ] Constrainty odrzucają niepoprawne dane (`test_constraints.sql`).
- [ ] Triggery/funkcje działają (`test_logic.sql`).
- [ ] Role mają odpowiednie GRANT-y (`roles.sql`).
- [ ] Dokumentacja końcowa zgodna z aktualnym schematem.

## Potencjalne poprawki
- [ ] Doprecyzować RLS/polityki wierszowe dla `app_user`.
- [ ] Dodać widoki raportowe (np. aktualny stan, kto komu pożyczył).
- [ ] Ujednolicić nazewnictwo i formaty dat w dokumentacji.
- [ ] Dodać diagram ERD do dokumentacji/prezentacji.
- [ ] Rozszerzyć dane seed o więcej przypadków brzegowych.