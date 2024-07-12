-- Запчасти
CREATE TABLE IF NOT EXISTS spare_parts 
(
	part_id SERIAL PRIMARY KEY,
	part_name TEXT UNIQUE NOT NULL,
	part_in_stock BOOLEAN NOT NULL
);

-- Запчасти в обращении
CREATE TABLE IF NOT EXISTS parts_for_request 
(
	request_id INTEGER REFERENCES request (request_id) NOT NULL,
	part_id INTEGER REFERENCES spare_parts (part_id) NOT NULL,
	part_amount INTEGER NOT NULL CHECK(part_amount > 0),
	PRIMARY KEY (request_id, part_id)
);

-- Расходные материалы
CREATE TABLE IF NOT EXISTS consumables 
(
	cons_id SERIAL PRIMARY KEY,
	cons_name TEXT UNIQUE NOT NULL,
	cons_in_stock BOOLEAN NOT NULL
);

-- Расходные материалы в обращении
CREATE TABLE IF NOT EXISTS cons_for_request 
(
	request_id INTEGER REFERENCES request (request_id) NOT NULL,
	cons_id INTEGER REFERENCES consumables (cons_id) NOT NULL,
	cons_amount INTEGER NOT NULL CHECK(cons_amount > 0),
	PRIMARY KEY (request_id, cons_id)
);



-- Заполнение данными
INSERT INTO spare_parts (part_name, part_in_stock)
VALUES 
('Запчасть 1', true),
('Запчасть 2', true),
('Запчасть 3', true),
('Запчасть 4', true),
('Запчасть 5', false),
('Запчасть 6', true),
('Запчасть 7', false);

SELECT * FROM spare_parts;

INSERT INTO parts_for_request (request_id, part_id, part_amount)
VALUES 
(1, 1, 4),
(1, 6, 8),
(2, 2, 3),
(3, 4, 2),
(4, 5, 8),
(4, 7, 10);


SELECT * FROM parts_for_request;


INSERT INTO consumables (cons_name, cons_in_stock)
VALUES 
('Масло 1', true),
('Масло 2', false),
('Тормозная жидкость', true),
('Антифриз 1', true),
('Смазка 1', false),
('Смазка 2', true),
('Фильтр 1', true),
('Фильтр 2', true),
('Масло 3', true);

SELECT * FROM consumables;


INSERT INTO cons_for_request (request_id, cons_id, cons_amount)
VALUES 
(3, 1, 1),
(3, 6, 1),
(4, 9, 2),
(4, 6, 2),
(5, 8, 2),
(5, 3, 1),
(6, 3, 1),
(6, 7, 2);

SELECT * FROM cons_for_request;
