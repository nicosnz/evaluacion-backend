CREATE SCHEMA IF NOT EXISTS content;
CREATE TABLE content.restaurant (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    address TEXT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE content.table_type (
    id UUID PRIMARY KEY,
    restaurant_id UUID NOT NULL,
    name TEXT NOT NULL,
    capacity INT NOT NULL,
    description TEXT,

    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    CONSTRAINT fk_tabletype_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES content.restaurant(id)
        ON DELETE CASCADE
);

CREATE TABLE content.menu (
    id UUID PRIMARY KEY,
    restaurant_id UUID NOT NULL,

    name TEXT NOT NULL,
    description TEXT,
    courses_count INT, 
    active_from DATE,
    active_to DATE,

    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    CONSTRAINT fk_menu_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES content.restaurant(id)
        ON DELETE CASCADE
);

CREATE TABLE content.menu_item (
    id UUID PRIMARY KEY,
    menu_id UUID NOT NULL,

    name TEXT NOT NULL,
    description TEXT,
    course_number INT, 
    ingredients TEXT,

    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

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
    status TEXT NOT NULL, 

    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

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

    full_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,

    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,

    CONSTRAINT fk_guest_reservation
        FOREIGN KEY (reservation_id)
        REFERENCES content.reservation(id)
        ON DELETE CASCADE
);

-- CREATE INDEX idx_tabletype_restaurant ON content.table_type(restaurant_id);
-- CREATE INDEX idx_menuitem_restaurant ON content.menu_item(restaurant_id);
-- CREATE INDEX idx_reservation_restaurant ON content.reservation(restaurant_id);
-- CREATE INDEX idx_reservation_tabletype ON content.reservation(table_type_id);
-- CREATE INDEX idx_guest_reservation ON content.reservation_guest(reservation_id);

INSERT INTO content.restaurant (id, name, description, address, created_at, updated_at)
VALUES
('11111111-1111-1111-1111-111111111111', 'La Mesa 8', 'Experiencia gastronómica de degustación', 'Av. Gourmet 123', NOW(), NOW());

INSERT INTO content.menu (id, restaurant_id, name, description, courses_count, active_from, active_to, created_at, updated_at)
VALUES
('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111',
 'Otoño 2026',
 'Menú degustación inspirado en ingredientes de temporada',
 8,
 '2026-05-01',
 '2026-07-31',
 NOW(), NOW());

INSERT INTO content.menu_item (id, menu_id, name, description, course_number, ingredients, created_at, updated_at)
VALUES
('33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', 'Amuse Bouche', 'Bocado de bienvenida', 1, 'trigo, mantequilla', NOW(), NOW()),
('44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', 'Entrada fría', 'Ensalada fresca de temporada', 2, 'vegetales frescos', NOW(), NOW()),
('55555555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', 'Sopa ligera', 'Crema de verduras', 3, 'calabaza, zanahoria', NOW(), NOW()),
('66666666-6666-6666-6666-666666666666', '22222222-2222-2222-2222-222222222222', 'Pescado', 'Filete con reducción cítrica', 4, 'pescado blanco', NOW(), NOW()),
('77777777-7777-7777-7777-777777777777', '22222222-2222-2222-2222-222222222222', 'Intermedio', 'Granizado de limpieza de paladar', 5, 'limón, hierbas', NOW(), NOW()),
('88888888-8888-8888-8888-888888888888', '22222222-2222-2222-2222-222222222222', 'Carne principal', 'Corte premium con salsa oscura', 6, 'res, vino tinto', NOW(), NOW()),
('99999999-9999-9999-9999-999999999999', '22222222-2222-2222-2222-222222222222', 'Pre-postre', 'Transición dulce ligera', 7, 'frutas', NOW(), NOW()),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'Postre', 'Creación dulce del chef', 8, 'chocolate, cacao', NOW(), NOW());

INSERT INTO content.table_type (id, restaurant_id, name, capacity, description, created_at, updated_at)
VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'Mesa íntima', 2, 'Experiencia privada', NOW(), NOW()),
('cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', 'Mesa compartida', 4, 'Mesa social', NOW(), NOW());

INSERT INTO content.reservation (
    id,
    restaurant_id,
    table_type_id,
    reservation_time,
    status,
    created_at,
    updated_at
)
VALUES
('dddddddd-dddd-dddd-dddd-dddddddddddd',
 '11111111-1111-1111-1111-111111111111',
 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
 '2026-06-10 19:00:00',
 'confirmed',
 NOW(), NOW()),

('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
 '11111111-1111-1111-1111-111111111111',
 'cccccccc-cccc-cccc-cccc-cccccccccccc',
 '2026-06-11 20:00:00',
 'pending',
 NOW(), NOW());

 INSERT INTO content.reservation_guest (id, reservation_id, full_name, email, phone, created_at, updated_at)
VALUES
('ffffffff-ffff-ffff-ffff-ffffffffffff', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'Juan Pérez', 'juan@mail.com', '+59170000001', NOW(), NOW()),
('11111111-2222-3333-4444-555555555555', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'Ana López', 'ana@mail.com', '+59170000002', NOW(), NOW()),
('22222222-3333-4444-5555-666666666666', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Carlos Rojas', 'carlos@mail.com', '+59170000003', NOW(), NOW());