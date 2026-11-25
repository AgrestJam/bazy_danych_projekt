BEGIN;

INSERT INTO users (id, name, username, password_hash, role, active, failed_logins, locked_until) VALUES
(1, 'Ala Kowalska', 'ala', 'hash_ala', 'admin', TRUE, 0, NULL),
(2, 'Bartek Nowak', 'bartek', 'hash_bartek', 'moderator', TRUE, 0, NULL),
(3, 'Celina Wisniewska', 'celina', 'hash_celina', 'user', TRUE, 0, NULL),
(4, 'Dawid Zielinski', 'dawid', 'hash_dawid', 'user', TRUE, 1, NULL);
SELECT setval(pg_get_serial_sequence('users','id'), (SELECT MAX(id) FROM users));

INSERT INTO components (id, name, part_number, description, min_qty) VALUES
(1, 'Rezystor 10k 1/4W', 'RES-10K-025', 'Rezystor THT 5%', 100),
(2, 'Kondensator 100nF', 'CAP-100NF', 'Ceramiczny 50V', 50),
(3, 'ESP32 DevKit', 'ESP32-DEVKITC', 'Modul WiFi+BT', 2),
(4, 'Dioda LED 5mm czerwona', 'LED-RED-5MM', '20mA', 30),
(5, 'Czujnik DHT22', 'DHT22', 'Temperatura i wilgotnosc', 2);
SELECT setval(pg_get_serial_sequence('components','id'), (SELECT MAX(id) FROM components));

INSERT INTO stock (id, component_id, owner_id, holder_id, location, qty) VALUES
(1, 1, 1, 1, 'pokoj 101, szuflada A', 200),
(2, 1, 1, 3, 'pokoj 103, pudełko pożyczone', 20),
(3, 2, 2, 2, 'pokoj 102, organizer', 80),
(4, 3, 3, 3, 'pokoj 103, biurko', 1),
(5, 4, 1, 4, 'pokoj 104, warsztat', 50),
(6, 5, 2, 3, 'pokoj 103, pudełko projektowe', 1);
SELECT setval(pg_get_serial_sequence('stock','id'), (SELECT MAX(id) FROM stock));

INSERT INTO movements (id, ts, kind, component_id, owner_id, to_owner_id, from_holder_id, to_holder_id, from_location, to_location, qty, note, user_id) VALUES
(1, '2026-11-20 10:00:00+01', 'receive', 1, 1, NULL, NULL, 1, NULL, 'pokoj 101, szuflada A', 200, 'Zakup poczatkowy', 1),
(2, '2026-11-20 11:00:00+01', 'receive', 2, 2, NULL, NULL, 2, NULL, 'pokoj 102, organizer', 80, 'Zakup poczatkowy', 2),
(3, '2026-11-21 09:30:00+01', 'receive', 3, 3, NULL, NULL, 3, NULL, 'pokoj 103, biurko', 1, 'Prywatny modul', 3),
(4, '2026-11-22 14:15:00+01', 'transfer', 1, 1, NULL, 1, 3, 'pokoj 101, szuflada A', 'pokoj 103, pudełko pożyczone', 20, 'Pozyczka na projekt', 1),
(5, '2026-11-23 16:00:00+01', 'receive', 4, 1, NULL, NULL, 4, NULL, 'pokoj 104, warsztat', 50, 'Wspolny zakup', 1),
(6, '2026-11-24 18:20:00+01', 'transfer', 5, 2, NULL, 2, 3, 'pokoj 102, organizer', 'pokoj 103, pudełko projektowe', 1, 'Pozyczka czujnika', 2);
SELECT setval(pg_get_serial_sequence('movements','id'), (SELECT MAX(id) FROM movements));

INSERT INTO order_items (id, component_id, qty, unit_cost, supplier, note, status, created_at, created_by, ordered_at, received_at) VALUES
(1, 1, 100, 0.05, 'Botland', 'Uzupelnienie rezystorow', 'ordered', '2026-11-19 12:00:00+01', 1, '2026-11-19 13:00:00+01', NULL),
(2, 3, 2, 39.9, 'Botland', 'Na warsztaty IoT', 'cart', '2026-11-25 09:00:00+01', 3, NULL, NULL),
(3, 5, 1, 29.99, 'AliExpress', 'Czujnik zapasowy', 'received', '2026-11-18 08:00:00+01', 2, '2026-11-18 09:00:00+01', '2026-11-24 17:00:00+01');
SELECT setval(pg_get_serial_sequence('order_items','id'), (SELECT MAX(id) FROM order_items));

COMMIT;
