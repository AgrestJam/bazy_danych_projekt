-- Testy funkcji/triggerów

-- 1. Receive tworzy/zwieksza stock
BEGIN;
INSERT INTO movements (kind, component_id, owner_id, to_holder_id, to_location, qty, note, user_id)
VALUES ('receive', 2, 2, 2, 'pokoj 102, organizer', 10, 'Test receive', 2);
SELECT * FROM stock WHERE component_id=2 AND owner_id=2 AND holder_id=2 AND location='pokoj 102, organizer';
ROLLBACK;

-- 2. Transfer przemieszcza ilosc
BEGIN;
INSERT INTO movements (kind, component_id, owner_id, from_holder_id, to_holder_id, from_location, to_location, qty, note, user_id)
VALUES ('transfer', 1, 1, 1, 4, 'pokoj 101, szuflada A', 'pokoj 104, warsztat', 5, 'Test transfer', 1);
SELECT * FROM stock WHERE component_id=1 AND owner_id=1 ORDER BY holder_id;
ROLLBACK;

-- 3. Movements niemodyfikowalne
-- UPDATE movements SET note='x' WHERE id=1; -- powinno rzucić wyjątek

-- 4. Niski stan
SELECT * FROM low_stock();
