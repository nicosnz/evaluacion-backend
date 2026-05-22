CREATE SCHEMA IF NOT EXISTS content;

CREATE TABLE content.restaurant (
    id UUID PRIMARY KEY,

    name VARCHAR(120) NOT NULL,
    description TEXT,
    address VARCHAR(255) NOT NULL,

    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE content.table_type (
    id UUID PRIMARY KEY,

    restaurant_id UUID NOT NULL,

    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,

    capacity INT NOT NULL,
    description TEXT,

    price NUMERIC(10,2) NOT NULL,

    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    CONSTRAINT chk_table_capacity
        CHECK (capacity > 0),

    CONSTRAINT chk_table_price
        CHECK (price >= 0),
    CONSTRAINT chk_table_type
            CHECK (
                type IN (
                    'shared',
                    'private',
                    'vip',
                    'outdoor',
                    'bar'
                )
            ),
    CONSTRAINT fk_tabletype_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES content.restaurant(id)
        ON DELETE CASCADE
);

CREATE TABLE content.menu (
    id UUID PRIMARY KEY,

    restaurant_id UUID NOT NULL,

    name VARCHAR(120) NOT NULL,
    description TEXT,

    courses_count INT NOT NULL,

    active_from DATE NOT NULL,
    active_to DATE NOT NULL,

    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    CONSTRAINT chk_courses_count
        CHECK (courses_count > 0),

    CONSTRAINT chk_menu_dates
        CHECK (active_to >= active_from),

    CONSTRAINT fk_menu_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES content.restaurant(id)
        ON DELETE CASCADE
);

CREATE TABLE content.menu_item (
    id UUID PRIMARY KEY,

    menu_id UUID NOT NULL,

    name VARCHAR(120) NOT NULL,
    description TEXT,

    course_number INT NOT NULL,

    ingredients TEXT NOT NULL,

    price NUMERIC(10,2) NOT NULL,

    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    CONSTRAINT chk_course_number
        CHECK (course_number > 0),

    CONSTRAINT chk_menuitem_price
        CHECK (price >= 0),

    CONSTRAINT fk_menuitem_menu
        FOREIGN KEY (menu_id)
        REFERENCES content.menu(id)
        ON DELETE CASCADE
);

CREATE TABLE content.reservation (
    id UUID PRIMARY KEY,

    restaurant_id UUID NOT NULL,
    table_type_id UUID NOT NULL,

    starts_at TIMESTAMP NOT NULL,
    ends_at TIMESTAMP NOT NULL,

    status VARCHAR(30) NOT NULL,

    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    CONSTRAINT chk_reservation_dates
        CHECK (ends_at > starts_at),

    CONSTRAINT chk_reservation_status
        CHECK (
            status IN (
                'pending',
                'confirmed',
                'cancelled',
                'completed'
            )
        ),

    CONSTRAINT uq_table_reservation
        UNIQUE (table_type_id, starts_at),

    CONSTRAINT fk_reservation_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES content.restaurant(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reservation_tabletype
        FOREIGN KEY (table_type_id)
        REFERENCES content.table_type(id)
        ON DELETE RESTRICT
);

CREATE TABLE content.reservation_guest (
    id UUID PRIMARY KEY,

    reservation_id UUID NOT NULL,

    full_name VARCHAR(120) NOT NULL,

    email VARCHAR(255),

    phone VARCHAR(30),

    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    CONSTRAINT fk_guest_reservation
        FOREIGN KEY (reservation_id)
        REFERENCES content.reservation(id)
        ON DELETE CASCADE
);


CREATE INDEX idx_reservation_status
ON content.reservation(status);

CREATE INDEX idx_tabletype_restaurant
ON content.table_type(restaurant_id);

CREATE INDEX idx_menuitem_menu
ON content.menu_item(menu_id);

CREATE INDEX idx_guest_reservation
ON content.reservation_guest(reservation_id);





DO $$
DECLARE
    v_restaurant_id UUID := gen_random_uuid();
    v_menu_id UUID := gen_random_uuid();
    v_table_ids UUID[] := ARRAY[]::UUID[];
    v_table_id UUID;
    v_reservation_id UUID;
    v_start_time TIMESTAMP;
    i INT;
    j INT;
    v_mesa_idx INT;
    v_dia_offset INT;
    v_allowed_types TEXT[] := ARRAY['shared', 'private', 'vip', 'outdoor', 'bar'];
BEGIN
    -- 1. Insertar el restaurante
    INSERT INTO content.restaurant (id, name, description, address, created_at, updated_at)
    VALUES (v_restaurant_id, 'Restaurante Exclusivo', 'Gastronomía de alta calidad', 'Calle Central 100', NOW(), NOW());

    -- 2. Crear 10 mesas
    FOR i IN 1..10 LOOP
        v_table_id := gen_random_uuid();
        v_table_ids := v_table_ids || v_table_id;
        INSERT INTO content.table_type (id, restaurant_id, name, type, capacity, description, price, created_at, updated_at)
        VALUES (v_table_id, v_restaurant_id, 'Mesa ' || i, v_allowed_types[((i-1) % 5) + 1], 4, 'Mesa tipo ' || v_allowed_types[((i-1) % 5) + 1], 50.00, NOW(), NOW());
    END LOOP;

    -- 3. Generar reservas garantizando unicidad
    FOR v_dia_offset IN 0..60 LOOP
        FOR v_mesa_idx IN 1..10 LOOP
            FOR j IN 0..7 LOOP 
                
                -- Corregido: Suma de intervalos para evitar error de formato de tiempo
                v_start_time := (CURRENT_DATE + (v_dia_offset || ' days')::interval) + 
                                INTERVAL '18 hours' + 
                                ((j / 2) * INTERVAL '1 hour') + 
                                (CASE WHEN j % 2 != 0 THEN INTERVAL '30 minutes' ELSE INTERVAL '0 minutes' END);
                
                v_reservation_id := gen_random_uuid();
                
                INSERT INTO content.reservation (id, restaurant_id, table_type_id, starts_at, ends_at, status, created_at, updated_at)
                VALUES (v_reservation_id, v_restaurant_id, v_table_ids[v_mesa_idx], v_start_time, v_start_time + interval '30 minutes', 'confirmed', NOW(), NOW());
                
                INSERT INTO content.reservation_guest (id, reservation_id, full_name, email, phone, created_at, updated_at)
                VALUES (gen_random_uuid(), v_reservation_id, 'Cliente ' || v_dia_offset || '-' || j, 'cliente@ejemplo.com', '12345678', NOW(), NOW());
                
                -- Salir si alcanzamos 400 registros
                IF (SELECT count(*) FROM content.reservation) >= 400 THEN
                    RETURN; 
                END IF;
            END LOOP;
        END LOOP;
    END LOOP;

    -- 4. Insertar un menú
    INSERT INTO content.menu (id, restaurant_id, name, description, courses_count, active_from, active_to, created_at, updated_at)
    VALUES (v_menu_id, v_restaurant_id, 'Menú Degustación', 'Chef especial', 3, CURRENT_DATE, CURRENT_DATE + 30, NOW(), NOW());
END $$;