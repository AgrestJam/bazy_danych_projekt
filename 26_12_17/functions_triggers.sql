-- Funkcje i triggery - PostgreSQL

-- Blokada edycji/usuwania historii operacji
CREATE OR REPLACE FUNCTION prevent_movements_mutation()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Tabela movements jest niemodyfikowalna (audit log)';
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_movements_no_update ON movements;
CREATE TRIGGER trg_movements_no_update
BEFORE UPDATE OR DELETE ON movements
FOR EACH ROW EXECUTE FUNCTION prevent_movements_mutation();

-- Ustawianie dat dla order_items na podstawie statusu
CREATE OR REPLACE FUNCTION set_order_timestamps()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'cart' THEN
        NEW.ordered_at := NULL;
        NEW.received_at := NULL;
    ELSIF NEW.status = 'ordered' THEN
        IF NEW.ordered_at IS NULL THEN NEW.ordered_at := NOW(); END IF;
        NEW.received_at := NULL;
    ELSIF NEW.status = 'received' THEN
        IF NEW.ordered_at IS NULL THEN NEW.ordered_at := NOW(); END IF;
        IF NEW.received_at IS NULL THEN NEW.received_at := NOW(); END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_order_timestamps ON order_items;
CREATE TRIGGER trg_order_timestamps
BEFORE INSERT OR UPDATE OF status ON order_items
FOR EACH ROW EXECUTE FUNCTION set_order_timestamps();

-- Funkcja pomocnicza: aktualizacja/utworzenie pozycji w stock
CREATE OR REPLACE FUNCTION apply_stock_delta(
    p_component_id INT, p_owner_id INT, p_holder_id INT, p_location TEXT, p_delta INT
) RETURNS VOID AS $$
DECLARE
    v_id INT;
    v_qty INT;
BEGIN
    SELECT id, qty INTO v_id, v_qty
    FROM stock
    WHERE component_id = p_component_id AND owner_id = p_owner_id
      AND holder_id = p_holder_id AND location = COALESCE(p_location, '')
    FOR UPDATE;

    IF v_id IS NULL THEN
        IF p_delta < 0 THEN
            RAISE EXCEPTION 'Brak pozycji w stock do zmniejszenia';
        END IF;
        INSERT INTO stock(component_id, owner_id, holder_id, location, qty)
        VALUES (p_component_id, p_owner_id, p_holder_id, COALESCE(p_location,''), p_delta);
    ELSE
        IF v_qty + p_delta < 0 THEN
            RAISE EXCEPTION 'Niewystarczająca ilość w stock';
        END IF;
        UPDATE stock SET qty = v_qty + p_delta WHERE id = v_id;
        DELETE FROM stock WHERE id = v_id AND qty = 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Aplikowanie ruchu magazynowego do stock
CREATE OR REPLACE FUNCTION apply_movement()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.kind = 'receive' THEN
        PERFORM apply_stock_delta(NEW.component_id, NEW.owner_id, NEW.to_holder_id, NEW.to_location, NEW.qty);
    ELSIF NEW.kind = 'transfer' THEN
        PERFORM apply_stock_delta(NEW.component_id, NEW.owner_id, NEW.from_holder_id, NEW.from_location, -NEW.qty);
        PERFORM apply_stock_delta(NEW.component_id, NEW.owner_id, NEW.to_holder_id, NEW.to_location, NEW.qty);
    ELSIF NEW.kind = 'change_owner' THEN
        -- zmiana właściciela: zdejmij od starego ownera u from_holder, dodaj nowemu ownerowi u to_holder (lub from_holder)
        PERFORM apply_stock_delta(NEW.component_id, NEW.owner_id, COALESCE(NEW.from_holder_id, NEW.to_holder_id), COALESCE(NEW.from_location, NEW.to_location), -NEW.qty);
        PERFORM apply_stock_delta(NEW.component_id, NEW.to_owner_id, COALESCE(NEW.to_holder_id, NEW.from_holder_id), COALESCE(NEW.to_location, NEW.from_location), NEW.qty);
    ELSIF NEW.kind = 'consume' THEN
        PERFORM apply_stock_delta(NEW.component_id, NEW.owner_id, NEW.from_holder_id, NEW.from_location, -NEW.qty);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_apply_movement ON movements;
CREATE TRIGGER trg_apply_movement
AFTER INSERT ON movements
FOR EACH ROW EXECUTE FUNCTION apply_movement();

-- Funkcja raportowa: niski stan
CREATE OR REPLACE FUNCTION low_stock()
RETURNS TABLE(component_id INT, component_name TEXT, total_qty BIGINT, min_qty INT) AS $$
    SELECT c.id, c.name, COALESCE(SUM(s.qty),0) AS total_qty, c.min_qty
    FROM components c
    LEFT JOIN stock s ON s.component_id = c.id
    GROUP BY c.id, c.name, c.min_qty
    HAVING COALESCE(SUM(s.qty),0) < c.min_qty
    ORDER BY c.id;
$$ LANGUAGE sql;
