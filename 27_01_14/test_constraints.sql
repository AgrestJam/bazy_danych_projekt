-- Testy ograniczeń (PostgreSQL)
-- Oczekiwane: bloki "POWINNO PRZEJSC" wykonują się poprawnie,
-- bloki "POWINNO NIE PRZEJSC" kończą się błędem naruszenia constraintu.

BEGIN;

-- POWINNO PRZEJSC: poprawny użytkownik
INSERT INTO users (name, username, password_hash, role)
VALUES ('Test User', 'test.user', 'hash_test_123', 'user');

-- POWINNO PRZEJSC: poprawny komponent
INSERT INTO components (name, part_number, description, min_qty)
VALUES ('Kondensator 10uF', 'CAP-10UF', 'Elektrolityczny', 5);

ROLLBACK;

-- Poniższe uruchamiaj pojedynczo, aby zobaczyć błąd:

-- POWINNO NIE PRZEJSC: zły format username
-- INSERT INTO users (name, username, password_hash, role)
-- VALUES ('Bad User', 'Bad User!', 'hash_bad_123', 'user');

-- POWINNO NIE PRZEJSC: qty <= 0
-- INSERT INTO movements (kind, component_id, owner_id, to_holder_id, to_location, qty)
-- VALUES ('receive', 1, 1, 1, 'pokoj 101', 0);

-- POWINNO NIE PRZEJSC: status received bez received_at
-- INSERT INTO order_items (component_id, qty, status, created_by, ordered_at, received_at)
-- VALUES (1, 1, 'received', 1, NOW(), NULL);

-- POWINNO NIE PRZEJSC: transfer bez to_holder_id/to_location
-- INSERT INTO movements (kind, component_id, owner_id, from_holder_id, qty)
-- VALUES ('transfer', 1, 1, 1, 1);
