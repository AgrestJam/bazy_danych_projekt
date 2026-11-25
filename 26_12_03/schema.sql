-- Współdzielony Magazyn Elektroniki - schemat PostgreSQL
-- Etap: 26.11.2026

BEGIN;

CREATE TABLE users (
    id              INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name            TEXT NOT NULL UNIQUE,
    username        TEXT NOT NULL,
    password_hash   TEXT NOT NULL,
    role            TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'moderator', 'user')),
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    failed_logins   INTEGER NOT NULL DEFAULT 0 CHECK (failed_logins >= 0),
    locked_until    TIMESTAMPTZ NULL,
    CONSTRAINT users_username_unique UNIQUE (username)
);

CREATE UNIQUE INDEX users_username_lower_uidx ON users (LOWER(username));

CREATE TABLE components (
    id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        TEXT NOT NULL,
    part_number TEXT NULL UNIQUE,
    description TEXT NULL,
    min_qty     INTEGER NOT NULL DEFAULT 0 CHECK (min_qty >= 0)
);

CREATE TABLE stock (
    id           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    component_id INTEGER NOT NULL REFERENCES components(id) ON DELETE RESTRICT,
    owner_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    holder_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    location     TEXT NOT NULL DEFAULT '',
    qty          INTEGER NOT NULL CHECK (qty >= 0),
    CONSTRAINT stock_unique_position UNIQUE (component_id, owner_id, holder_id, location)
);

CREATE TABLE movements (
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ts             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    kind           TEXT NOT NULL CHECK (kind IN ('receive', 'transfer', 'change_owner', 'consume')),
    component_id   INTEGER NOT NULL REFERENCES components(id) ON DELETE RESTRICT,
    owner_id       INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    to_owner_id    INTEGER NULL REFERENCES users(id) ON DELETE RESTRICT,
    from_holder_id INTEGER NULL REFERENCES users(id) ON DELETE RESTRICT,
    to_holder_id   INTEGER NULL REFERENCES users(id) ON DELETE RESTRICT,
    from_location  TEXT NULL,
    to_location    TEXT NULL,
    qty            INTEGER NOT NULL CHECK (qty > 0),
    note           TEXT NULL,
    user_id        INTEGER NULL REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE order_items (
    id           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    component_id INTEGER NOT NULL REFERENCES components(id) ON DELETE RESTRICT,
    qty          INTEGER NOT NULL CHECK (qty > 0),
    unit_cost    NUMERIC(10,2) NULL CHECK (unit_cost >= 0),
    supplier     TEXT NULL,
    note         TEXT NULL,
    status       TEXT NOT NULL DEFAULT 'cart' CHECK (status IN ('cart', 'ordered', 'received')),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by   INTEGER NULL REFERENCES users(id) ON DELETE SET NULL,
    ordered_at   TIMESTAMPTZ NULL,
    received_at  TIMESTAMPTZ NULL
);

COMMIT;
