# Koncepcja Projektu Bazy Danych – Współdzielony Magazyn Elektroniki (Etap 1 – 19.11)

## 1. Ogólny pomysł i rozwiązywany problem

Projektowana baza danych stanowi rdzeń systemu zarządzania **współdzielonym magazynem komponentów elektronicznych dla grupy studentów** (np. mieszkańców akademika, wspólnego mieszkania lub koła naukowego).

### Jaki problem rozwiązuje baza danych?
* **Rozproszenie sprzętu po pokojach:** Studenci posiadają prywatne zapasy elektroniki (rezystory, mikrokontrolery, czujniki, przewody), które są przechowywane w różnych pokojach, pudełkach lub wpięte w płytki stykowe. Baza pozwoli szybko sprawdzić, czy dana część znajduje się w zasobach grupy, kto jest jej właścicielem oraz u kogo i gdzie fizycznie leży – dzięki czemu można zapytać o pożyczkę zamiast kupować nowy element.
* **Śledzenie własności i zwrotów:** Rozdzielenie pojęcia **właściciela** (`owner_id`) od **aktualnego posiadacza** (`holder_id`) eliminuje problem gubienia pożyczonego sprzętu – system zawsze pamięta, do kogo element ma wrócić.
* **Rozliczalność i historia operacji:** Niemodyfikowalny dziennik zdarzeń rejestruje każde przyjęcie, pożyczenie, przekazanie własności oraz zużycie/spalenie części. W przypadku uszkodzenia elementu wiadomo, kto za to odpowiada i na podstawie aktualnej ceny rynkowej można się rozliczyć.
* **Organizacja wspólnych zakupów:** Moduł listy zakupowej pozwala zbierać zapotrzebowanie całej grupy w jednym koszyku, aby dzielić koszty przesyłki ze sklepów elektronicznych.

---

## 2. Tabele, kolumny, typy danych oraz wstępne warunki (Constraints)

Baza danych będzie składać się z **5 powiązanych tabel**.

### 1. Tabela `users` (Użytkownicy systemu)
Przechowuje dane studentów korzystających z systemu. Każda osoba w grupie musi posiadać własne konto.

| Kolumna | Planowany typ danych | Wstępne warunki i ograniczenia (Constraints) | Opis |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | Klucz główny (`PRIMARY KEY`), auto-inkrementacja | Unikalny identyfikator użytkownika. |
| `name` | `TEXT` | Wymagane (`NOT NULL`), unikalne (`UNIQUE`) | Wyświetlane imię lub pseudonim studenta. |
| `username` | `TEXT` | Wymagane (`NOT NULL`), unikalne bez względu na wielkość liter | Login do systemu. |
| `password_hash` | `TEXT` | Wymagane (`NOT NULL`) | Zahaszowane hasło użytkownika. |
| `role` | `TEXT` | Wymagane (`NOT NULL`), domyślnie `'user'`, wartości ze zbioru `('admin', 'moderator', 'user')` | Rola określająca poziom uprawnień. |
| `active` | `BOOLEAN` | Wymagane (`NOT NULL`), domyślnie `TRUE` | Informacja, czy konto jest aktywne. |
| `failed_logins` | `INTEGER` | Wymagane (`NOT NULL`), domyślnie `0`, wartość nieujemna (`>= 0`) | Licznik nieudanych prób logowania. |
| `locked_until` | `TIMESTAMPTZ` | Opcjonalne (`NULL`) | Data i czas wygaśnięcia tymczasowej blokady konta. |

---

### 2. Tabela `components` (Katalog części elektronicznych)
Globalny słownik definicji elementów elektronicznych dostępnych w bazie.

| Kolumna | Planowany typ danych | Wstępne warunki i ograniczenia (Constraints) | Opis |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | Klucz główny (`PRIMARY KEY`), auto-inkrementacja | Unikalny identyfikator typu części. |
| `name` | `TEXT` | Wymagane (`NOT NULL`) | Nazwa elementu (np. *„Rezystor 10k”*, *„ESP32”*). |
| `part_number` | `TEXT` | Unikalne (`UNIQUE`), opcjonalne (`NULL`) | Oznaczenie katalogowe / kod producenta. |
| `description` | `TEXT` | Opcjonalne (`NULL`) | Dodatkowy opis techniczny (np. obudowa, napięcie). |
| `min_qty` | `INTEGER` | Wymagane (`NOT NULL`), domyślnie `0`, wartość nieujemna (`>= 0`) | Minimalny pożądany zapas w grupie (próg ostrzegawczy). |

---

### 3. Tabela `stock` (Bieżący stan magazynowy)
Przechowuje informację o tym, ile sztuk danej części znajduje się w konkretnym miejscu, kto jest jej właścicielem oraz kto ją aktualnie przetrzymuje.

| Kolumna | Planowany typ danych | Wstępne warunki i ograniczenia (Constraints) | Opis |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | Klucz główny (`PRIMARY KEY`), auto-inkrementacja | Unikalny identyfikator pozycji magazynowej. |
| `component_id` | `INTEGER` | Klucz obcy (`FOREIGN KEY` $\rightarrow$ `components.id`), wymagane (`NOT NULL`) | Wskazuje rodzaj komponentu. |
| `owner_id` | `INTEGER` | Klucz obcy (`FOREIGN KEY` $\rightarrow$ `users.id`), wymagane (`NOT NULL`) | Wskazuje właściciela części. |
| `holder_id` | `INTEGER` | Klucz obcy (`FOREIGN KEY` $\rightarrow$ `users.id`), wymagane (`NOT NULL`) | Wskazuje osobę, u której część aktualnie się znajduje. |
| `location` | `TEXT` | Wymagane (`NOT NULL`), domyślnie pusty ciąg `''` | Dowolny opis miejsca przechowywania (np. *„pokój 204, pudełko na biurku”*). |
| `qty` | `INTEGER` | Wymagane (`NOT NULL`), wartość nieujemna (`>= 0`) | Aktualna liczba sztuk w tej lokalizacji. |
| *Unikalność* | — | Złożony warunek `UNIQUE (component_id, owner_id, holder_id, location)` | Zapobiega dublowaniu wierszy dla identycznej kombinacji części, osób i miejsca. |

---

### 4. Tabela `movements` (Dziennik operacji magazynowych)
Historia wszystkich zdarzeń i przesunięć w magazynie (rejestr audytowy).

| Kolumna | Planowany typ danych | Wstępne warunki i ograniczenia (Constraints) | Opis |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | Klucz główny (`PRIMARY KEY`), auto-inkrementacja | Unikalny numer operacji. |
| `ts` | `TIMESTAMPTZ` | Wymagane (`NOT NULL`), domyślnie aktualny czas (`NOW()`) | Data i godzina wykonania operacji. |
| `kind` | `TEXT` | Wymagane (`NOT NULL`), wartości ze zbioru `('receive', 'transfer', 'change_owner', 'consume')` | Typ operacji (przyjęcie, przesunięcie/pożyczka, zmiana właściciela, zużycie/spalenie). |
| `component_id` | `INTEGER` | Klucz obcy (`FOREIGN KEY` $\rightarrow$ `components.id`), wymagane (`NOT NULL`) | Komponent objęty operacją. |
| `owner_id` | `INTEGER` | Klucz obcy (`FOREIGN KEY` $\rightarrow$ `users.id`), wymagane (`NOT NULL`) | Właściciel elementu w momencie operacji. |
| `to_owner_id` | `INTEGER` | Klucz obcy (`FOREIGN KEY` $\rightarrow$ `users.id`), opcjonalne (`NULL`) | Nowy właściciel (używane przy przekazaniu własności). |
| `from_holder_id` | `INTEGER` | Klucz obcy (`FOREIGN KEY` $\rightarrow$ `users.id`), opcjonalne (`NULL`) | Osoba oddająca lub zużywająca element. |
| `to_holder_id` | `INTEGER` | Klucz obcy (`FOREIGN KEY` $\rightarrow$ `users.id`), opcjonalne (`NULL`) | Osoba odbierająca element. |
| `from_location` | `TEXT` | Opcjonalne (`NULL`) | Poprzednia lokalizacja elementu. |
| `to_location` | `TEXT` | Opcjonalne (`NULL`) | Docelowa lokalizacja elementu. |
| `qty` | `INTEGER` | Wymagane (`NOT NULL`), wartość ściśle dodatnia (`> 0`) | Liczba sztuk biorących udział w operacji. |
| `note` | `TEXT` | Opcjonalne (`NULL`) | Dodatkowy komentarz (np. cel pożyczki lub przyczyna spalenia). |
| `user_id` | `INTEGER` | Klucz obcy (`FOREIGN KEY` $\rightarrow$ `users.id`), opcjonalne (`NULL`) | Użytkownik rejestrujący wpis w systemie. |

---

### 5. Tabela `order_items` (Wspólny koszyk i lista zakupowa)
Tabela obsługująca planowanie wspólnych zakupów oraz przechowująca orientacyjną cenę jednostkową zamawianych części.

| Kolumna | Typ danych | Wstępne warunki i ograniczenia (Constraints) | Opis |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | Klucz główny (`PRIMARY KEY`), auto-inkrementacja | Unikalny identyfikator pozycji zamówienia. |
| `component_id` | `INTEGER` | Klucz obcy (`FOREIGN KEY` $\rightarrow$ `components.id`), wymagane (`NOT NULL`) | Zamawiany komponent z katalogu. |
| `qty` | `INTEGER` | Wymagane (`NOT NULL`), wartość ściśle dodatnia (`> 0`) | Liczba sztuk do zakupu. |
| `unit_cost` | `NUMERIC(10, 2)` | Wartość nieujemna (`>= 0`), opcjonalne (`NULL`) | Orientacyjna cena jednostkowa w momencie zakupu. |
| `supplier` | `TEXT` | Opcjonalne (`NULL`) | Nazwa sklepu lub dostawcy (np. *„Botland”*, *„AliExpress”*). |
| `note` | `TEXT` | Opcjonalne (`NULL`) | Uwagi do zamówienia. |
| `status` | `TEXT` | Wymagane (`NOT NULL`), domyślnie `'cart'`, wartości ze zbioru `('cart', 'ordered', 'received')` | Etap realizacji zakupu (w koszyku, zamówione, odebrane). |
| `created_at` | `TIMESTAMPTZ` | Wymagane (`NOT NULL`), domyślnie aktualny czas (`NOW()`) | Data dodania pozycji do koszyka. |
| `created_by` | `INTEGER` | Klucz obcy (`FOREIGN KEY` $\rightarrow$ `users.id`), opcjonalne (`NULL`) | Osoba dodająca pozycję do listy zakupowej. |
| `ordered_at` | `TIMESTAMPTZ` | Opcjonalne (`NULL`) | Data złożenia zamówienia. |
| `received_at` | `TIMESTAMPTZ` | Opcjonalne (`NULL`) | Data odebrania przesyłki. |

---

## 3. Planowane relacje pomiędzy tabelami

Wszystkie powiązania w bazie danych mają charakter **jeden-do-wielu (1:N)**:

1. **`components` (1) $\rightarrow$ `stock` (N):** Jeden element z katalogu może występować w wielu rekordach stanu magazynowego (u różnych właścicieli i w różnych lokalizacjach).
2. **`components` (1) $\rightarrow$ `movements` (N):** Jeden typ komponentu może brać udział w wielu operacjach w historii magazynu.
3. **`components` (1) $\rightarrow$ `order_items` (N):** Ten sam element może być wielokrotnie dodawany do listy zakupowej.
4. **`users` (1) $\rightarrow$ `stock` (N) [podwójna relacja]:**
   * Relacja przez `owner_id`: jeden użytkownik może być właścicielem wielu pozycji w magazynie.
   * Relacja przez `holder_id`: jeden użytkownik może fizycznie przechowywać u siebie wiele pozycji (swoich lub pożyczonych od innych).
5. **`users` (1) $\rightarrow$ `movements` (N) [wielokrotna relacja]:** Tabela historii łączy się z użytkownikami poprzez pola `owner_id`, `to_owner_id`, `from_holder_id`, `to_holder_id` oraz `user_id` (osoba wykonująca wpis).
6. **`users` (1) $\rightarrow$ `order_items` (N):** Jeden użytkownik może zgłosić wiele pozycji do wspólnego koszyka zakupowego (`created_by`).

*(Dodatkowo planowane jest zabezpieczenie kluczy obcych mechanizmem `ON DELETE RESTRICT` dla części będących na stanie/w historii oraz `ON DELETE SET NULL` dla autora wpisu w logach i koszyku w razie usunięcia konta).*

---

## 4. Planowane role w bazie danych i ich uprawnienia

W bazie danych przewidziano podział na **3 role**, realizowany na poziomie silnika bazy danych (poprzez uprawnienia do tabel oraz polityki bezpieczeństwa wierszy):

1. **`app_user` (Zwykły użytkownik / Student):**
   * **Odczyt:** Może przeglądać cały katalog części (`components`), bieżący stan magazynowy wszystkich osób (`stock`), pełną historię operacji (`movements`) oraz wspólny koszyk (`order_items`). Dzięki temu każdy widzi, co kto posiada i u kogo leży dany element, aby móc zapytać o pożyczkę.
   * **Modyfikacja:** Może dodawać nowe części do katalogu, zarządzać w magazynie wyłącznie swoimi rzeczami (`owner_id`) lub rzeczami aktualnie pożyczonymi do siebie (`holder_id`), dopisywać własne operacje do logów oraz dodawać/edytować własne pozycje w koszyku zakupowym.
   * **Ograniczenia:** Nie ma dostępu do haseł innych użytkowników; nie może edytować ani usuwać wpisów w dzienniku `movements`.

2. **`app_moderator` (Moderator):**
   * Posiada wszystkie uprawnienia roli `app_user`.
   * **Dodatkowe uprawnienia:** Może przesuwać w magazynie (`stock`) rzeczy należące do dowolnych osób pomiędzy dowolnymi użytkownikami (np. porządkując stan po wspólnych warsztatach), usuwać duplikaty z katalogu `components` oraz zarządzać statusem całego koszyka zakupowego (`order_items`).
   * **Ograniczenia:** Nie może edytować ani usuwać historycznych wpisów w dzienniku operacji (`movements`), co gwarantuje niezmienność audytu.

3. **`app_admin` (Administrator):**
   * Pełne uprawnienia administracyjne do wszystkich tabel i struktur bazy danych.
   * Zarządza kontami użytkowników (`users` – zakładanie kont, nadawanie ról, dezaktywacja, zdejmowanie blokad logowania) oraz ma możliwość awaryjnej korekty wszystkich danych.