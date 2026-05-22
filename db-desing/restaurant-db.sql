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
    v_count INT := 10; -- Número de mesas a crear
    v_hours INT[] := ARRAY[18, 19, 20, 21];
    v_mins INT[] := ARRAY[0, 30];
    -- Tipos permitidos por tu constraint
    v_allowed_types TEXT[] := ARRAY['shared', 'private', 'vip', 'outdoor', 'bar'];
    v_selected_type TEXT;
BEGIN
    -- 1. Insertar el restaurante
    INSERT INTO content.restaurant (id, name, description, address, created_at, updated_at)
    VALUES (v_restaurant_id, 'Restaurante Gran Variedad', 'Nuestra mejor selección de mesas', 'Calle Falsa 123', NOW(), NOW());

    -- 2. Insertar 10 tipos de mesa (distribuidas en los tipos permitidos)
    FOR i IN 1..v_count LOOP
        v_table_id := gen_random_uuid();
        v_table_ids := v_table_ids || v_table_id;
        v_selected_type := v_allowed_types[((i-1) % 5) + 1];
        
        INSERT INTO content.table_type (id, restaurant_id, name, type, capacity, description, price, created_at, updated_at)
        VALUES (v_table_id, v_restaurant_id, 'Mesa ' || i || ' (' || v_selected_type || ')', v_selected_type, (random()*10 + 1)::int, 'Descripción de la mesa ' || i, (random()*100 + 10)::numeric(10,2), NOW(), NOW());
    END LOOP;

    -- 3. Insertar un menú
    INSERT INTO content.menu (id, restaurant_id, name, description, courses_count, active_from, active_to, created_at, updated_at)
    VALUES (v_menu_id, v_restaurant_id, 'Menú Gourmet', 'Degustación 10 tiempos', 10, CURRENT_DATE, CURRENT_DATE + 60, NOW(), NOW());
    
    INSERT INTO content.menu_item (id, menu_id, name, description, course_number, ingredients, price, created_at, updated_at)
    VALUES (gen_random_uuid(), v_menu_id, 'Plato Principal', 'Especialidad', 1, 'Ingredientes secretos', 45.00, NOW(), NOW());

    -- 4. Generar 400 reservas distribuidas entre las 10 mesas
    FOR i IN 1..400 LOOP
        v_reservation_id := gen_random_uuid();
        -- Seleccionar una mesa de nuestro array de 10 mesas
        v_table_id := v_table_ids[((i-1) % 10) + 1];
        
        -- Lógica: Hora entre 18:00 y 21:00 en intervalos de 30 min
        v_start_time := (CURRENT_DATE + ( (i / 40) || ' days')::interval) + 
                        (v_hours[(random()*3 + 1)::int] || ':' || v_mins[(random()*1 + 1)::int])::interval;
        
        INSERT INTO content.reservation (id, restaurant_id, table_type_id, starts_at, ends_at, status, created_at, updated_at)
        VALUES (v_reservation_id, v_restaurant_id, v_table_id, v_start_time, v_start_time + interval '30 minutes', 
                (ARRAY['pending', 'confirmed', 'cancelled', 'completed'])[(random()*3 + 1)::int], NOW(), NOW());
        
        -- Insertar el invitado
        INSERT INTO content.reservation_guest (id, reservation_id, full_name, email, phone, created_at, updated_at)
        VALUES (gen_random_uuid(), v_reservation_id, 'Invitado ' || i, 'invitado' || i || '@ejemplo.com', '555-' || (1000 + i), NOW(), NOW());
    END LOOP;
END $$;