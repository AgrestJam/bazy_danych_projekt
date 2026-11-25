"""Generuje dane seed.sql dla projektu Współdzielony Magazyn Elektroniki.

Uruchomienie:
    python generate_seed.py
Wynik:
    seed.sql
"""

from pathlib import Path

USERS = [
    (1, "Ala Kowalska", "ala", "hash_ala", "admin", True, 0, None),
    (2, "Bartek Nowak", "bartek", "hash_bartek", "moderator", True, 0, None),
    (3, "Celina Wisniewska", "celina", "hash_celina", "user", True, 0, None),
    (4, "Dawid Zielinski", "dawid", "hash_dawid", "user", True, 1, None),
]

COMPONENTS = [
    (1, "Rezystor 10k 1/4W", "RES-10K-025", "Rezystor THT 5%", 100),
    (2, "Kondensator 100nF", "CAP-100NF", "Ceramiczny 50V", 50),
    (3, "ESP32 DevKit", "ESP32-DEVKITC", "Modul WiFi+BT", 2),
    (4, "Dioda LED 5mm czerwona", "LED-RED-5MM", "20mA", 30),
    (5, "Czujnik DHT22", "DHT22", "Temperatura i wilgotnosc", 2),
]

STOCK = [
    (1, 1, 1, 1, "pokoj 101, szuflada A", 200),
    (2, 1, 1, 3, "pokoj 103, pudełko pożyczone", 20),
    (3, 2, 2, 2, "pokoj 102, organizer", 80),
    (4, 3, 3, 3, "pokoj 103, biurko", 1),
    (5, 4, 1, 4, "pokoj 104, warsztat", 50),
    (6, 5, 2, 3, "pokoj 103, pudełko projektowe", 1),
]

MOVEMENTS = [
    (1, "2026-11-20 10:00:00+01", "receive", 1, 1, None, None, 1, None, "pokoj 101, szuflada A", 200, "Zakup poczatkowy", 1),
    (2, "2026-11-20 11:00:00+01", "receive", 2, 2, None, None, 2, None, "pokoj 102, organizer", 80, "Zakup poczatkowy", 2),
    (3, "2026-11-21 09:30:00+01", "receive", 3, 3, None, None, 3, None, "pokoj 103, biurko", 1, "Prywatny modul", 3),
    (4, "2026-11-22 14:15:00+01", "transfer", 1, 1, None, 1, 3, "pokoj 101, szuflada A", "pokoj 103, pudełko pożyczone", 20, "Pozyczka na projekt", 1),
    (5, "2026-11-23 16:00:00+01", "receive", 4, 1, None, None, 4, None, "pokoj 104, warsztat", 50, "Wspolny zakup", 1),
    (6, "2026-11-24 18:20:00+01", "transfer", 5, 2, None, 2, 3, "pokoj 102, organizer", "pokoj 103, pudełko projektowe", 1, "Pozyczka czujnika", 2),
]

ORDER_ITEMS = [
    (1, 1, 100, 0.05, "Botland", "Uzupelnienie rezystorow", "ordered", "2026-11-19 12:00:00+01", 1, "2026-11-19 13:00:00+01", None),
    (2, 3, 2, 39.90, "Botland", "Na warsztaty IoT", "cart", "2026-11-25 09:00:00+01", 3, None, None),
    (3, 5, 1, 29.99, "AliExpress", "Czujnik zapasowy", "received", "2026-11-18 08:00:00+01", 2, "2026-11-18 09:00:00+01", "2026-11-24 17:00:00+01"),
]


def sql_str(value):
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, (int, float)):
        return str(value)
    return "'" + str(value).replace("'", "''") + "'"


def insert(table, cols, rows):
    col_list = ", ".join(cols)
    values = []
    for row in rows:
        values.append("(" + ", ".join(sql_str(v) for v in row) + ")")
    return f"INSERT INTO {table} ({col_list}) VALUES\n" + ",\n".join(values) + ";\n"


def main():
    out = ["BEGIN;\n\n"]
    out.append(insert("users", ["id", "name", "username", "password_hash", "role", "active", "failed_logins", "locked_until"], USERS))
    out.append("SELECT setval(pg_get_serial_sequence('users','id'), (SELECT MAX(id) FROM users));\n\n")
    out.append(insert("components", ["id", "name", "part_number", "description", "min_qty"], COMPONENTS))
    out.append("SELECT setval(pg_get_serial_sequence('components','id'), (SELECT MAX(id) FROM components));\n\n")
    out.append(insert("stock", ["id", "component_id", "owner_id", "holder_id", "location", "qty"], STOCK))
    out.append("SELECT setval(pg_get_serial_sequence('stock','id'), (SELECT MAX(id) FROM stock));\n\n")
    out.append(insert("movements", ["id", "ts", "kind", "component_id", "owner_id", "to_owner_id", "from_holder_id", "to_holder_id", "from_location", "to_location", "qty", "note", "user_id"], MOVEMENTS))
    out.append("SELECT setval(pg_get_serial_sequence('movements','id'), (SELECT MAX(id) FROM movements));\n\n")
    out.append(insert("order_items", ["id", "component_id", "qty", "unit_cost", "supplier", "note", "status", "created_at", "created_by", "ordered_at", "received_at"], ORDER_ITEMS))
    out.append("SELECT setval(pg_get_serial_sequence('order_items','id'), (SELECT MAX(id) FROM order_items));\n\n")
    out.append("COMMIT;\n")
    Path("seed.sql").write_text("".join(out), encoding="utf-8")
    print("Wygenerowano seed.sql")


if __name__ == "__main__":
    main()
