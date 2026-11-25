-- Role i uprawnienia PostgreSQL

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user') THEN
        CREATE ROLE app_user NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_moderator') THEN
        CREATE ROLE app_moderator NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_admin') THEN
        CREATE ROLE app_admin NOLOGIN;
    END IF;
END $$;

GRANT USAGE ON SCHEMA public TO app_user, app_moderator, app_admin;

-- app_user: odczyt i ograniczona modyfikacja
GRANT SELECT ON components, stock, movements, order_items TO app_user;
GRANT INSERT ON components, movements, order_items TO app_user;
GRANT INSERT, UPDATE ON stock TO app_user;
GRANT UPDATE (qty, unit_cost, supplier, note, status) ON order_items TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- app_moderator: rozszerzone zarządzanie
GRANT app_user TO app_moderator;
GRANT INSERT, UPDATE, DELETE ON components, stock, order_items TO app_moderator;

-- app_admin: pełne uprawnienia
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO app_admin;
