# Koncepcja Projektu Bazy Danych – Współdzielony Magazyn Elektroniki

## 1. Ogólny pomysł i rozwiązywany problem

Projektowana baza danych stanowi rdzeń systemu zarządzania **współdzielonym magazynem komponentów elektronicznych dla grupy studentów** (np. mieszkańców akademika, wspólnego mieszkania lub koła naukowego).

### Jaki problem rozwiązuje baza danych?
* **Rozproszenie sprzętu po pokojach:** Studenci posiadają prywatne zapasy elektroniki (rezystory, mikrokontrolery, czujniki, przewody), które są przechowywane w różnych pokojach, pudełkach lub wpięte w płytki stykowe. Baza pozwala szybko sprawdzić, czy dana część znajduje się w zasobach grupy, kto jest jej właścicielem oraz u kogo i gdzie fizycznie leży.
* **Śledzenie własności i zwrotów:** Rozdzielenie pojęcia **właściciela** (`owner_id`) od **aktualnego posiadacza** (`holder_id`) eliminuje problem gubienia pożyczonego sprzętu – system zawsze pamięta, do kogo element ma wrócić.
* **Rozliczalność i historia operacji:** Niemodyfikowalny dziennik zdarzeń rejestruje każde przyjęcie, pożyczenie, przekazanie własności oraz zużycie/spalenie części. W przypadku uszkodzenia elementu wiadomo, kto za to odpowiada i na podstawie aktualnej ceny rynkowej można się rozliczyć.
* **Organizacja wspólnych zakupów:** Moduł listy zakupowej pozwala zbierać zapotrzebowanie całej grupy w jednym koszyku, aby dzielić koszty przesyłki ze sklepów elektronicznych.

---

## 2. Tabele, kolumny, typy danych oraz wstępne warunki (Constraints)

Baza danych składa się z **5 powiązanych tabel**.

### 1. Tabela `users` (Użytkownicy systemu)

| Kolumna | Typ danych | Ograniczenia | Opis |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY`, auto-inkrementacja | Unikalny identyfikator użytkownika. |
| `name` | `TEXT` | `NOT NULL`, `UNIQUE` | Wyświetlane imię lub pseudonim studenta. |
| `username` | `TEXT` | `NOT NULL`, `UNIQUE` (bez względu na wielkość liter) | Login do systemu. |
| `password_hash` | `TEXT` | `NOT NULL` | Zahaszowane hasło użytkownika. |
| `role` | `TEXT` | `NOT NULL`, domyślnie `'user'`, `CHECK IN ('admin','moderator','user')` | Rola określająca poziom uprawnień. |
| `active` | `BOOLEAN` | `NOT NULL`, domyślnie `TRUE` | Czy konto jest aktywne. |
| `failed_logins` | `INTEGER` | `NOT NULL`, domyślnie `0`, `CHECK (failed_logins >= 0)` | Licznik nieudanych prób logowania. |
| `locked_until` | `TIMESTAMPTZ` | `NULL` | Data i czas wygaśnięcia tymczasowej blokady konta. |

### 2. Tabela `components` (Katalog części elektronicznych)

| Kolumna | Typ danych | Ograniczenia | Opis |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY`, auto-inkrementacja | Unikalny identyfikator typu części. |
| `name` | `TEXT` | `NOT NULL` | Nazwa elementu. |
| `part_number` | `TEXT` | `UNIQUE`, `NULL` | Oznaczenie katalogowe / kod producenta. |
| `description` | `TEXT` | `NULL` | Dodatkowy opis techniczny. |
| `min_qty` | `INTEGER` | `NOT NULL`, domyślnie `0`, `CHECK (min_qty >= 0)` | Minimalny pożądany zapas w grupie. |

### 3. Tabela `stock` (Bieżący stan magazynowy)

| Kolumna | Typ danych | Ograniczenia | Opis |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY`, auto-inkrementacja | Unikalny identyfikator pozycji magazynowej. |
| `component_id` | `INTEGER` | `FK -> components.id`, `NOT NULL` | Rodzaj komponentu. |
| `owner_id` | `INTEGER` | `FK -> users.id`, `NOT NULL` | Właściciel części. |
| `holder_id` | `INTEGER` | `FK -> users.id`, `NOT NULL` | Aktualny posiadacz części. |
| `location` | `TEXT` | `NOT NULL`, domyślnie `''` | Opis miejsca przechowywania. |
| `qty` | `INTEGER` | `NOT NULL`, `CHECK (qty >= 0)` | Liczba sztuk. |
| — | — | `UNIQUE(component_id, owner_id, holder_id, location)` | Brak duplikatów identycznych pozycji. |

### 4. Tabela `movements` (Dziennik operacji magazynowych)

| Kolumna | Typ danych | Ograniczenia | Opis |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY`, auto-inkrementacja | Numer operacji. |
| `ts` | `TIMESTAMPTZ` | `NOT NULL`, domyślnie `NOW()` | Data i godzina operacji. |
| `kind` | `TEXT` | `NOT NULL`, `CHECK IN ('receive','transfer','change_owner','consume')` | Typ operacji. |
| `component_id` | `INTEGER` | `FK -> components.id`, `NOT NULL` | Komponent objęty operacją. |
| `owner_id` | `INTEGER` | `FK -> users.id`, `NOT NULL` | Właściciel w momencie operacji. |
| `to_owner_id` | `INTEGER` | `FK -> users.id`, `NULL` | Nowy właściciel. |
| `from_holder_id` | `INTEGER` | `FK -> users.id`, `NULL` | Osoba oddająca/zużywająca. |
| `to_holder_id` | `INTEGER` | `FK -> users.id`, `NULL` | Osoba odbierająca. |
| `from_location` | `TEXT` | `NULL` | Poprzednia lokalizacja. |
| `to_location` | `TEXT` | `NULL` | Docelowa lokalizacja. |
| `qty` | `INTEGER` | `NOT NULL`, `CHECK (qty > 0)` | Liczba sztuk. |
| `note` | `TEXT` | `NULL` | Komentarz. |
| `user_id` | `INTEGER` | `FK -> users.id`, `NULL` | Użytkownik rejestrujący wpis. |

### 5. Tabela `order_items` (Lista zakupowa / koszyk)

| Kolumna | Typ danych | Ograniczenia | Opis |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY`, auto-inkrementacja | Identyfikator pozycji zamówienia. |
| `component_id` | `INTEGER` | `FK -> components.id`, `NOT NULL` | Zamawiany komponent. |
| `qty` | `INTEGER` | `NOT NULL`, `CHECK (qty > 0)` | Liczba sztuk. |
| `unit_cost` | `NUMERIC(10,2)` | `CHECK (unit_cost >= 0)`, `NULL` | Orientacyjna cena jednostkowa. |
| `supplier` | `TEXT` | `NULL` | Sklep/dostawca. |
| `note` | `TEXT` | `NULL` | Uwagi. |
| `status` | `TEXT` | `NOT NULL`, domyślnie `'cart'`, `CHECK IN ('cart','ordered','received')` | Etap realizacji. |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL`, domyślnie `NOW()` | Data dodania. |
| `created_by` | `INTEGER` | `FK -> users.id`, `NULL` | Autor pozycji. |
| `ordered_at` | `TIMESTAMPTZ` | `NULL` | Data zamówienia. |
| `received_at` | `TIMESTAMPTZ` | `NULL` | Data odebrania. |

---

## 3. Relacje pomiędzy tabelami

Wszystkie powiązania mają charakter **jeden-do-wielu (1:N)**:

1. `components (1) -> stock (N)` - jeden typ komponentu w wielu pozycjach magazynowych.
2. `components (1) -> movements (N)` - jeden typ komponentu w wielu operacjach.
3. `components (1) -> order_items (N)` - jeden typ komponentu w wielu pozycjach zakupowych.
4. `users (1) -> stock (N)` przez `owner_id` i `holder_id` - właściciel i posiadacz.
5. `users (1) -> movements (N)` przez `owner_id`, `to_owner_id`, `from_holder_id`, `to_holder_id`, `user_id`.
6. `users (1) -> order_items (N)` przez `created_by`.

Planowane zasady usuwania: `ON DELETE RESTRICT` dla danych operacyjnych/magazynowych powiązanych z komponentami i użytkownikami krytycznymi; `ON DELETE SET NULL` dla pól audytowych jak `movements.user_id`, `order_items.created_by` tam, gdzie zachowanie historii jest ważniejsze niż powiązanie z kontem.

---

## 4. Planowane role i uprawnienia

1. **`app_user` (Student):**
   - Odczyt: `components`, `stock`, `movements`, `order_items`.
   - Modyfikacja: dodawanie komponentów; zarządzanie `stock` dla własnych lub aktualnie posiadanych elementów; dodawanie wpisów `movements`; zarządzanie własnymi pozycjami `order_items`.
   - Ograniczenia: brak dostępu do haseł innych użytkowników, brak edycji/usuwania `movements`.

2. **`app_moderator` (Moderator):**
   - Wszystkie uprawnienia `app_user`.
   - Dodatkowo: zarządzanie całym `stock`, porządkowanie `components`, zarządzanie statusem `order_items`.
   - Ograniczenia: brak edycji/usuwania historii `movements`.

3. **`app_admin` (Administrator):**
   - Pełne uprawnienia do wszystkich tabel i struktur.
   - Zarządzanie kontami `users`, rolami, blokadami i awaryjna korekta danych.
