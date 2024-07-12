-- Сделайте выборку всех данных из каждой таблицы

CREATE OR REPLACE VIEW vehicle_v1 AS SELECT * FROM vehicle;
SELECT * FROM vehicle_v1;

CREATE OR REPLACE VIEW service_station_v1 AS SELECT * FROM service_station;
SELECT * FROM service_station_v1;

CREATE OR REPLACE VIEW master_v1 AS SELECT * FROM master;
SELECT * FROM master_v1;

CREATE OR REPLACE VIEW specialization_v1 AS SELECT * FROM specialization;
SELECT * FROM specialization_v1;

CREATE OR REPLACE VIEW work_type_v1 AS SELECT * FROM work_type;
SELECT * FROM work_type_v1;

CREATE OR REPLACE VIEW request_cost_v1 AS SELECT * FROM request_cost;
SELECT * FROM request_cost_v1;

CREATE OR REPLACE VIEW spare_parts_v1 AS SELECT * FROM spare_parts;
SELECT * FROM spare_parts_v1;

CREATE OR REPLACE VIEW consumables_v1 AS SELECT * FROM consumables;
SELECT * FROM consumables_v1;

CREATE OR REPLACE VIEW duration_v1 AS SELECT * FROM duration;
SELECT * FROM duration_v1;

CREATE OR REPLACE VIEW request_v1 AS SELECT * FROM request;
SELECT * FROM request_v1;

CREATE OR REPLACE VIEW parts_for_request_v1 AS SELECT * FROM parts_for_request;
SELECT * FROM parts_for_request_v1;

CREATE OR REPLACE VIEW cons_for_request_v1 AS SELECT * FROM cons_for_request;
SELECT * FROM cons_for_request_v1;


-- Сделайте выборку данных из одной таблицы при нескольких условиях, с использованием логических операций, LIKE, BETWEEN, IN (не менее 3-х разных примеров)

CREATE OR REPLACE VIEW vehicle_like AS SELECT * FROM vehicle
WHERE model LIKE 'Nissan%'; 

SELECT * FROM vehicle_like;


CREATE OR REPLACE VIEW vehicle_between AS SELECT * FROM vehicle
WHERE engine_capacity BETWEEN 5.0 AND 5.5;

SELECT * FROM vehicle_between;


CREATE OR REPLACE VIEW vehicle_in AS SELECT * FROM vehicle
WHERE vehicle_type IN ('Купе', 'Фургон');

SELECT * FROM vehicle_in;


-- Создайте в запросе вычисляемое поле
CREATE OR REPLACE VIEW duration_days AS
SELECT *, (completion_date - request_date) AS days FROM duration;

SELECT * FROM duration_days;


-- Сделайте выборку всех данных с сортировкой по нескольким полям

CREATE OR REPLACE VIEW request_order AS
SELECT * FROM request ORDER BY vehicle_id, status;

SELECT * FROM request_order;


-- Создайте запрос, вычисляющий несколько совокупных характеристик таблиц
CREATE OR REPLACE VIEW avg AS
SELECT AVG(part_amount), MAX(part_amount), MIN(part_amount) FROM parts_for_request;

SELECT * FROM avg;


-- Сделайте выборку данных из связанных таблиц (не менее двух примеров)

CREATE OR REPLACE VIEW join_m_sst AS
SELECT m.master_id, m.service_station_id, ss.address
FROM master m INNER JOIN service_station ss on m.service_station_id = ss.service_station_id;

SELECT * FROM join_m_sst;


CREATE OR REPLACE VIEW join_m_wt AS
SELECT wt.work_type_id, wt.specialization_id, m.master_id,  wt.maintenance
FROM work_type wt INNER JOIN master m on m.specialization_id = wt.specialization_id;

SELECT * FROM join_m_wt;


-- Создайте запрос, рассчитывающий совокупную характеристику с использованием группировки, наложите ограничение на результат группировки

CREATE OR REPLACE VIEW count AS
SELECT specialization_id, COUNT(work_type_id) FROM work_type GROUP BY specialization_id HAVING specialization_id > 20;

SELECT * FROM count;


-- Придумайте и реализуйте пример использования вложенного запроса

CREATE OR REPLACE VIEW nested AS
SELECT * FROM request r WHERE r.cost_id = (SELECT c.cost_id FROM request_cost c WHERE c.final_cost IN (20500));

SELECT * FROM nested;


-- С помощью оператора `INSERT` добавьте в каждую таблицу по одной записи

INSERT INTO vehicle (vehicle_type, car_number, model, manufacture_year, color, engine_capacity, transmission)
VALUES ('Хэтчбек', 'B456CO', 'Nissan Tiida', '2010', 'черный', 1.6, 'Автоматическая');

INSERT INTO specialization (specialization)
VALUES ('Кузовной ремонт');

INSERT INTO duration (request_date, completion_date)
VALUES ('2022-03-22', '2022-03-28');

INSERT INTO request_cost (final_cost, spare_parts_cost, consumable_cost, others_cost, man_hours_cost)
VALUES (6000, 3500, 0, 1500, 1000);

INSERT INTO service_station (address)
VALUES ('ул. Ленина, 15');

INSERT INTO master (master_name, service_station_id, specialization_id)
VALUES ('Никита', 31, 101);

INSERT INTO work_type (maintenance, specialization_id)
VALUES ('Аварийное', 101);

INSERT INTO request (vehicle_id, duration_id, work_type_id, status, master_id, service_station_id, cost_id)
VALUES (301, 501, 101, 'Завершено', 181, 31, 101);

INSERT INTO spare_parts (part_name, part_in_stock)
VALUES ('Болт №5', true);

INSERT INTO parts_for_request (request_id, part_id, part_amount)
VALUES (501, 401, 4), (501, 8, 5);

INSERT INTO consumables (cons_name, cons_in_stock)
VALUES  ('Краска №5', true);

INSERT INTO cons_for_request (request_id, cons_id, cons_amount)
VALUES (21, 401, 1);


-- С помощью оператора `UPDATE` измените значения нескольких полей у всех записей, отвечающих заданному условию

SELECT * FROM vehicle WHERE vehicle_type IN ('Фургон');

UPDATE vehicle SET engine_capacity = 5.0 WHERE vehicle_type IN ('Фургон');


-- С помощью оператора `DELETE` удалите запись, имеющую максимальное (минимальное) значение некоторой совокупной характеристики

DELETE FROM vehicle WHERE vehicle_id = (SELECT MAX(vehicle_id) FROM vehicle);


-- С помощью оператора `DELETE` удалите записи в главной таблице, на которые не ссылается подчиненная таблица (используя вложенный запрос)

DELETE FROM vehicle WHERE vehicle_id NOT IN (SELECT vehicle_id FROM request);









