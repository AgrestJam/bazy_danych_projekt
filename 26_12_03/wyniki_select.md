# Wyniki zapytań SELECT

Poniżej przykładowe wyniki dla danych z `seed.sql`.

## 1. Użytkownicy

| id | name | username | role | active |
|---:|---|---|---|:---:|
| 1 | Ala Kowalska | ala | admin | t |
| 2 | Bartek Nowak | bartek | moderator | t |
| 3 | Celina Wisniewska | celina | user | t |
| 4 | Dawid Zielinski | dawid | user | t |

## 2. Komponenty

| id | name | part_number | min_qty |
|---:|---|---|---:|
| 1 | Rezystor 10k 1/4W | RES-10K-025 | 100 |
| 2 | Kondensator 100nF | CAP-100NF | 50 |
| 3 | ESP32 DevKit | ESP32-DEVKITC | 2 |
| 4 | Dioda LED 5mm czerwona | LED-RED-5MM | 30 |
| 5 | Czujnik DHT22 | DHT22 | 2 |

## 3. Stan magazynowy (relacje)

| id | component | owner | holder | location | qty |
|---:|---|---|---|---|---:|
| 1 | Rezystor 10k 1/4W | Ala Kowalska | Ala Kowalska | pokoj 101, szuflada A | 200 |
| 2 | Rezystor 10k 1/4W | Ala Kowalska | Celina Wisniewska | pokoj 103, pudełko pożyczone | 20 |
| 3 | Kondensator 100nF | Bartek Nowak | Bartek Nowak | pokoj 102, organizer | 80 |
| 4 | ESP32 DevKit | Celina Wisniewska | Celina Wisniewska | pokoj 103, biurko | 1 |
| 5 | Dioda LED 5mm czerwona | Ala Kowalska | Dawid Zielinski | pokoj 104, warsztat | 50 |
| 6 | Czujnik DHT22 | Bartek Nowak | Celina Wisniewska | pokoj 103, pudełko projektowe | 1 |

## 4. Historia operacji (relacje)

Pokazuje typ operacji, komponent, właściciela, przekazującego/odbierającego oraz komentarz. Widoczne są operacje `receive` i `transfer`, co potwierdza relacje między `movements`, `components` i `users`.

## 5. Lista zakupowa

| id | component | qty | unit_cost | supplier | status | created_by |
|---:|---|---:|---:|---|---|---|
| 1 | Rezystor 10k 1/4W | 100 | 0.05 | Botland | ordered | Ala Kowalska |
| 2 | ESP32 DevKit | 2 | 39.90 | Botland | cart | Celina Wisniewska |
| 3 | Czujnik DHT22 | 1 | 29.99 | AliExpress | received | Bartek Nowak |
