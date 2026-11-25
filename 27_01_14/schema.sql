-- Współdzielony Magazyn Elektroniki - schemat PostgreSQL
-- Etap: 10.12.2026 - dodane warunki/constraints

BEGIN;

CREATE TABLE users (
    id              INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name            TEXT NOT NULL,
    username        TEXT NOT NULL,
    password_hash   TEXT NOT NULL,
    role            TEXT NOT NULL DEFAULT 'user',
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    failed_logins   INTEGER NOT NULL DEFAULT 0,
    locked_until    TIMESTAMPTZ NULL,

    CONSTRAINT users_name_not_blank CHECK (BTRIM(name) <> ''),
    CONSTRAINT users_username_not_blank CHECK (BTRIM(username) <> ''),
    CONSTRAINT users_username_format CHECK (username ~ '^[a-z0-9_.-]{3,32}$'),
    CONSTRAINT users_password_hash_len CHECK (char_length(password_hash) >= 8),
    CONSTRAINT users_role_check CHECK (role IN ('admin', 'moderator', 'user')),
    CONSTRAINT users_failed_logins_check CHECK (failed_logins >= 0),
    CONSTRAINT users_name_unique UNIQUE (name),
    CONSTRAINT users_username_unique UNIQUE (username)
);

CREATE UNIQUE INDEX users_username_lower_uidx ON users (LOWER(username));

CREATE TABLE components (
    id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        TEXT NOT NULL,
    part_number TEXT NULL,
    description TEXT NULL,
    min_qty     INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT components_name_not_blank CHECK (BTRIM(name) <> ''),
    CONSTRAINT components_part_number_not_blank CHECK (part_number IS NULL OR BTRIM(part_number) <> ''),
    CONSTRAINT components_description_len CHECK (description IS NULL OR char_length(description) <= 500),
    CONSTRAINT components_min_qty_check CHECK (min_qty >= 0),
    CONSTRAINT components_part_number_unique UNIQUE (part_number)
);

CREATE TABLE stock (
    id           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    component_id INTEGER NOT NULL REFERENCES components(id) ON DELETE RESTRICT,
    owner_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    holder_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    location     TEXT NOT NULL DEFAULT '',
    qty          INTEGER NOT NULL,

    CONSTRAINT stock_qty_check CHECK (qty >= 0),
    CONSTRAINT stock_location_len CHECK (char_length(location) <= 200),
    CONSTRAINT stock_unique_position UNIQUE (component_id, owner_id, holder_id, location)
);

CREATE TABLE movements (
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ts             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    kind           TEXT NOT NULL,
    component_id   INTEGER NOT NULL REFERENCES components(id) ON DELETE RESTRICT,
    owner_id       INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    to_owner_id    INTEGER NULL REFERENCES users(id) ON DELETE RESTRICT,
    from_holder_id INTEGER NULL REFERENCES users(id) ON DELETE RESTRICT,
    to_holder_id   INTEGER NULL REFERENCES users(id) ON DELETE RESTRICT,
    from_location  TEXT NULL,
    to_location    TEXT NULL,
    qty            INTEGER NOT NULL,
    note           TEXT NULL,
    user_id        INTEGER NULL REFERENCES users(id) ON DELETE SET NULL,

    CONSTRAINT movements_kind_check CHECK (kind IN ('receive', 'transfer', 'change_owner', 'consume')),
    CONSTRAINT movements_qty_check CHECK (qty > 0),
    CONSTRAINT movements_note_len CHECK (note IS NULL OR char_length(note) <= 500),
    CONSTRAINT movements_location_len CHECK (
        (from_location IS NULL OR char_length(from_location) <= 200) AND
        (to_location IS NULL OR char_length(to_location) <= 200)
    ),
    CONSTRAINT movements_receive_check CHECK (
        kind <> 'receive' OR (to_holder_id IS NOT NULL AND to_location IS NOT NULL)
    ),
    CONSTRAINT movements_transfer_check CHECK (
        kind <> 'transfer' OR (from_holder_id IS NOT NULL AND to_holder_id IS NOT NULL AND to_location IS NOT NULL)
    ),
    CONSTRAINT movements_change_owner_check CHECK (
        kind <> 'change_owner' OR (to_owner_id IS NOT NULL)
    ),
    CONSTRAINT movements_consume_check CHECK (
        kind <> 'consume' OR (from_holder_id IS NOT NULL)
    )
);

CREATE TABLE order_items (
    id           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    component_id INTEGER NOT NULL REFERENCES components(id) ON DELETE RESTRICT,
    qty          INTEGER NOT NULL,
    unit_cost    NUMERIC(10,2) NULL,
    supplier     TEXT NULL,
    note         TEXT NULL,
    status       TEXT NOT NULL DEFAULT 'cart',
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by   INTEGER NULL REFERENCES users(id) ON DELETE SET NULL,
    ordered_at   TIMESTAMPTZ NULL,
    received_at  TIMESTAMPTZ NULL,

    CONSTRAINT order_items_qty_check CHECK (qty > 0),
    CONSTRAINT order_items_unit_cost_check CHECK (unit_cost IS NULL OR unit_cost >= 0),
    CONSTRAINT order_items_supplier_len CHECK (supplier IS NULL OR char_length(supplier) <= 100),
    CONSTRAINT order_items_note_len CHECK (note IS NULL OR char_length(note) <= 500),
    CONSTRAINT order_items_status_check CHECK (status IN ('cart', 'ordered', 'received')),
    CONSTRAINT order_items_dates_check CHECK (
        (status = 'cart' AND ordered_at IS NULL AND received_at IS NULL) OR
        (status = 'ordered' AND ordered_at IS NOT NULL AND received_at IS NULL) OR
        (status = 'received' AND ordered_at IS NOT NULL AND received_at IS NOT NULL AND received_at >= ordered_at)
    )
);

COMMIT;
