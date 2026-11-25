-- Utworzenie bazy danych PostgreSQL
-- Uruchom jako superuser (np. postgres): psql -U postgres -f create_db.sql

DROP DATABASE IF EXISTS magazyn_elektroniki;
CREATE DATABASE magazyn_elektroniki;

\connect magazyn_elektroniki

\i schema.sql
\i seed.sql
