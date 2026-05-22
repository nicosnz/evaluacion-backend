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

    reservation_time TIMESTAMP NOT NULL,

    status VARCHAR(30) NOT NULL,

    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    CONSTRAINT chk_reservation_status
        CHECK (
            status IN (
                'pending',
                'confirmed',
                'cancelled',
                'completed'
            )
        ),

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

CREATE INDEX idx_reservation_time
ON content.reservation(reservation_time);

CREATE INDEX idx_reservation_status
ON content.reservation(status);

CREATE INDEX idx_tabletype_restaurant
ON content.table_type(restaurant_id);

CREATE INDEX idx_menuitem_menu
ON content.menu_item(menu_id);

CREATE INDEX idx_guest_reservation
ON content.reservation_guest(reservation_id);




-- INSERT INTO content.restaurant (
--     id,
--     name,
--     description,
--     address,
--     created_at,
--     updated_at
-- )
-- VALUES
-- (
--     '11111111-1111-1111-1111-111111111111',
--     'Mesa Larga',
--     'Experiencia gastronómica de degustación premium',
--     'Av. Gourmet 123, Santa Cruz',
--     NOW(),
--     NOW()
-- );



-- INSERT INTO content.menu (
--     id,
--     restaurant_id,
--     name,
--     description,
--     courses_count,
--     active_from,
--     active_to,
--     created_at,
--     updated_at
-- )
-- VALUES
-- (
--     '22222222-2222-2222-2222-222222222222',
--     '11111111-1111-1111-1111-111111111111',
--     'Otoño 2026',
--     'Menú degustación inspirado en ingredientes de temporada',
--     8,
--     '2026-05-01',
--     '2026-07-31',
--     NOW(),
--     NOW()
-- );



-- INSERT INTO content.menu_item (
--     id,
--     menu_id,
--     name,
--     description,
--     course_number,
--     ingredients,
--     price,
--     created_at,
--     updated_at
-- )
-- VALUES
-- (
--     '33333333-3333-3333-3333-333333333333',
--     '22222222-2222-2222-2222-222222222222',
--     'Amuse Bouche',
--     'Bocado de bienvenida',
--     1,
--     'trigo, mantequilla',
--     100.0,
--     NOW(),
--     NOW()
-- ),
-- (
--     '44444444-4444-4444-4444-444444444444',
--     '22222222-2222-2222-2222-222222222222',
--     'Entrada fría',
--     'Ensalada fresca de temporada',
--     2,
--     'vegetales frescos',
--     100.0,

--     NOW(),
--     NOW()
-- ),
-- (
--     '55555555-5555-5555-5555-555555555555',
--     '22222222-2222-2222-2222-222222222222',
--     'Sopa ligera',
--     'Crema de verduras',
--     3,
--     'calabaza, zanahoria',
--     100.0,

--     NOW(),
--     NOW()
-- ),
-- (
--     '66666666-6666-6666-6666-666666666666',
--     '22222222-2222-2222-2222-222222222222',
--     'Pescado',
--     'Filete con reducción cítrica',
--     4,
--     'pescado blanco',
--     100.0,

--     NOW(),
--     NOW()
-- ),
-- (
--     '77777777-7777-7777-7777-777777777777',
--     '22222222-2222-2222-2222-222222222222',
--     'Intermedio',
--     'Granizado de limón',
--     5,
--     'limón, hierbas',
--     100.0,

--     NOW(),
--     NOW()
-- ),
-- (
--     '88888888-8888-8888-8888-888888888888',
--     '22222222-2222-2222-2222-222222222222',
--     'Carne principal',
--     'Corte premium con salsa oscura',
--     6,
--     'res, vino tinto',
--     100.0,

--     NOW(),
--     NOW()
-- ),
-- (
--     '99999999-9999-9999-9999-999999999999',
--     '22222222-2222-2222-2222-222222222222',
--     'Pre-postre',
--     'Frutas frescas maceradas',
--     7,
--     'frutas tropicales',
--     100.0,

--     NOW(),
--     NOW()
-- ),
-- (
--     'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
--     '22222222-2222-2222-2222-222222222222',
--     'Postre',
--     'Mousse de chocolate del chef',
--     8,
--     'chocolate, cacao',
--     100.0,

--     NOW(),
--     NOW()
-- );



-- INSERT INTO content.table_type (
--     id,
--     restaurant_id,
--     name,
--     type,
--     capacity,
--     description,
--     price,
--     created_at,
--     updated_at
-- )
-- VALUES
-- (
--     'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
--     '11111111-1111-1111-1111-111111111111',
--     'Mesa íntima',
--     'private',
--     2,
--     'Experiencia privada para parejas',
--     350.00,
--     NOW(),
--     NOW()
-- ),
-- (
--     'cccccccc-cccc-cccc-cccc-cccccccccccc',
--     '11111111-1111-1111-1111-111111111111',
--     'Mesa compartida',
--     'shared',
--     4,
--     'Experiencia social compartida',
--     220.00,
--     NOW(),
--     NOW()
-- );


-- INSERT INTO content.reservation (
--     id,
--     restaurant_id,
--     table_type_id,
--     reservation_time,
--     status,
--     created_at,
--     updated_at
-- )
-- VALUES
-- (
--     'dddddddd-dddd-dddd-dddd-dddddddddddd',
--     '11111111-1111-1111-1111-111111111111',
--     'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
--     '2026-06-10 19:00:00',
--     'confirmed',
--     NOW(),
--     NOW()
-- ),
-- (
--     'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
--     '11111111-1111-1111-1111-111111111111',
--     'cccccccc-cccc-cccc-cccc-cccccccccccc',
--     '2026-06-11 20:00:00',
--     'pending',
--     NOW(),
--     NOW()
-- );



-- INSERT INTO content.reservation_guest (
--     id,
--     reservation_id,
--     full_name,
--     email,
--     phone,
--     created_at,
--     updated_at
-- )
-- VALUES
-- (
--     'ffffffff-ffff-ffff-ffff-ffffffffffff',
--     'dddddddd-dddd-dddd-dddd-dddddddddddd',
--     'Juan Pérez',
--     'juan@mail.com',
--     '+59170000001',
--     NOW(),
--     NOW()
-- ),
-- (
--     '11111111-2222-3333-4444-555555555555',
--     'dddddddd-dddd-dddd-dddd-dddddddddddd',
--     'Ana López',
--     'ana@mail.com',
--     '+59170000002',
--     NOW(),
--     NOW()
-- ),
-- (
--     '22222222-3333-4444-5555-666666666666',
--     'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
--     'Carlos Rojas',
--     'carlos@mail.com',
--     '+59170000003',
--     NOW(),
--     NOW()
-- );
DO $$
DECLARE
    num_restaurants INT := 300;
    
    -- Diccionarios para datos realistas
    names_prefix TEXT[] := ARRAY['El Rincón', 'La Cava', 'Sabor', 'Casa', 'Sushi', 'Parrilla', 'Delicias', 'Veggie', 'Mar y Tierra', 'La Toscana'];
    names_suffix TEXT[] := ARRAY['Gourmet', 'del Sol', 'Auténtico', 'Italia', 'Zen', 'Argentina', 'del Mar', 'Vibes', 'Fusion', 'Clásico'];
    cities TEXT[] := ARRAY['Santa Cruz', 'La Paz', 'Cochabamba', 'Sucre', 'Tarija'];
    table_types TEXT[] := ARRAY['shared', 'private', 'vip', 'outdoor', 'bar'];
    
    -- Items de menú reales por tiempo (course_number)
    starters TEXT[] := ARRAY['Ensalada César', 'Carpaccio de Res', 'Sopa de Maní', 'Bruschetta de Tomate'];
    mains TEXT[] := ARRAY['Bife de Chorizo', 'Salmón a la Parrilla', 'Pasta Carbonara', 'Risotto de Setas', 'Pollo a la Brasa'];
    desserts TEXT[] := ARRAY['Tiramisú', 'Volcán de Chocolate', 'Cheesecake de Frutos Rojos', 'Helado Artesanal'];
    
    v_restaurant_id UUID;
    v_menu_id UUID;
    v_table_type_id UUID;
    v_reservation_id UUID;
    
    i INT; j INT; k INT;
BEGIN
    FOR i IN 1..num_restaurants LOOP
        v_restaurant_id := gen_random_uuid();
        
        -- 1. Restaurante
        INSERT INTO content.restaurant (id, name, description, address, created_at, updated_at)
        VALUES (v_restaurant_id, 
                names_prefix[1 + floor(random()*array_length(names_prefix, 1))] || ' ' || names_suffix[1 + floor(random()*array_length(names_suffix, 1))],
                'Un espacio gastronómico único en ' || cities[1 + floor(random()*array_length(cities, 1))],
                'Calle ' || (100 + i) || ', ' || cities[1 + floor(random()*array_length(cities, 1))],
                NOW() - (random() * interval '365 days'), NOW());

        -- 2. Tipos de mesa
        FOR j IN 1..3 LOOP
            v_table_type_id := gen_random_uuid();
            INSERT INTO content.table_type (id, restaurant_id, name, type, capacity, description, price, created_at, updated_at)
            VALUES (v_table_type_id, v_restaurant_id, 'Mesa ' || j, table_types[1 + floor(random()*array_length(table_types, 1))], 
                    floor(random()*6)+2, 'Ubicación privilegiada', (random()*150 + 20)::numeric(10,2), NOW(), NOW());
        END LOOP;

        -- 3. Menú y sus Items
        v_menu_id := gen_random_uuid();
        INSERT INTO content.menu (id, restaurant_id, name, description, courses_count, active_from, active_to, created_at, updated_at)
        VALUES (v_menu_id, v_restaurant_id, 'Menú Degustación ' || (2026), 'Selección de autor', 3, NOW()::date, (NOW() + interval '1 year')::date, NOW(), NOW());

        -- Insertar 3 platos por menú (Entrada, Plato fuerte, Postre)
        FOR k IN 1..3 LOOP
            INSERT INTO content.menu_item (id, menu_id, name, description, course_number, ingredients, price, created_at, updated_at)
            VALUES (gen_random_uuid(), v_menu_id, 
                    CASE k WHEN 1 THEN starters[1 + floor(random()*array_length(starters, 1))] 
                           WHEN 2 THEN mains[1 + floor(random()*array_length(mains, 1))] 
                           ELSE desserts[1 + floor(random()*array_length(desserts, 1))] END,
                    'Preparación artesanal de la casa', k, 'Ingredientes frescos de temporada', (random()*40 + 10)::numeric(10,2), NOW(), NOW());
        END LOOP;

        -- 4. Reservaciones (Aleatorias)
        IF random() > 0.6 THEN
            v_reservation_id := gen_random_uuid();
            INSERT INTO content.reservation (id, restaurant_id, table_type_id, reservation_time, status, created_at, updated_at)
            VALUES (v_reservation_id, v_restaurant_id, v_table_type_id, NOW() + (random() * interval '10 days'), 'confirmed', NOW(), NOW());
            
            INSERT INTO content.reservation_guest (id, reservation_id, full_name, email, phone, created_at, updated_at)
            VALUES (gen_random_uuid(), v_reservation_id, 'Cliente ' || i, 'usuario' || i || '@test.com', '7' || floor(random()*9999999), NOW(), NOW());
        END IF;
    END LOOP;
END $$;