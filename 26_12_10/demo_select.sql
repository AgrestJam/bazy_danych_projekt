-- Proste SELECT-y demonstrujące działanie bazy

-- 1. Lista użytkowników
SELECT id, name, username, role, active FROM users ORDER BY id;

-- 2. Katalog komponentów
SELECT id, name, part_number, min_qty FROM components ORDER BY id;

-- 3. Stan magazynowy z relacjami do komponentów i użytkowników
SELECT
    s.id,
    c.name AS component,
    o.name AS owner,
    h.name AS holder,
    s.location,
    s.qty
FROM stock s
JOIN components c ON c.id = s.component_id
JOIN users o ON o.id = s.owner_id
JOIN users h ON h.id = s.holder_id
ORDER BY s.id;

-- 4. Historia operacji z relacjami
SELECT
    m.id,
    m.ts,
    m.kind,
    c.name AS component,
    owner.name AS owner,
    from_h.name AS from_holder,
    to_h.name AS to_holder,
    m.qty,
    m.note
FROM movements m
JOIN components c ON c.id = m.component_id
JOIN users owner ON owner.id = m.owner_id
LEFT JOIN users from_h ON from_h.id = m.from_holder_id
LEFT JOIN users to_h ON to_h.id = m.to_holder_id
ORDER BY m.ts, m.id;

-- 5. Lista zakupowa
SELECT
    oi.id,
    c.name AS component,
    oi.qty,
    oi.unit_cost,
    oi.supplier,
    oi.status,
    u.name AS created_by
FROM order_items oi
JOIN components c ON c.id = oi.component_id
LEFT JOIN users u ON u.id = oi.created_by
ORDER BY oi.id;
