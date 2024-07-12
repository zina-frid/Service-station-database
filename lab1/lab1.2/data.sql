INSERT INTO vehicle (vehicle_type, car_number, model, manufacture_year, color, engine_capacity, transmission)
VALUES 
('Хэтчбек', 'B456CO', 'Nissan Tiida', '2010', 'черный', 1.6, 'Автоматическая'),
('Седан', 'M777OX', 'LADA (ВАЗ) Priora', '2008', 'фиолетовый', 1.6, 'Механическая'),
('Внедорожник', 'E666KX', 'Porsche Cayenne', '2019', 'белый', 3.0, 'Автоматическая'),
('Купе', 'A111AA', 'Lamborghini Murcielago', '2008', 'красный', 6.5, 'Полуавтоматическая'),
('Пикап', 'P825OM', 'Toyota Tundra', '2019', 'голубой', 5.7, 'Автоматическая');

	
SELECT * FROM vehicle;

INSERT INTO specialization (specialization)
VALUES 
('Кузовной ремонт'),
('Электрика'),
('Автоматика'),
('Замена расходных материалов'),
('Ремонт двигателя'),
('Ремонт ходовой части');

SELECT * FROM specialization;


INSERT INTO request_cost (final_cost, spare_parts_cost, consumable_cost, others_cost, man_hours_cost)
VALUES
(6000, 3500, 0, 1500, 1000),
(5000, 3000, 0, 500, 1500),
(37000, 20000, 8000, 4000, 5000),
(76000, 60000, 10000, 0, 6000),
(5000, 0, 3000, 1000, 1000),
(7000, 0, 5000, 1000, 1000);

SELECT * FROM request_cost;

INSERT INTO service_station (address)
VALUES
('ул. Ленина, 15'),
('пр-кт Маршала Жукова, 43');

SELECT * FROM service_station;


INSERT INTO master (master_name, service_station_id, specialization_id)
VALUES
('Никита', 1, 6),
('Вадим', 1, 4),
('Евгений', 2, 3),
('Константин', 2, 2),
('Дмитрий', 2, 5);

SELECT * FROM master;

INSERT INTO work_type (maintenance, specialization_id)
VALUES
('Аварийное', 6),
('Аварийное', 2),
('Плановое', 3),
('Аварийное', 5),
('Плановое', 4);

SELECT * FROM work_type;

INSERT INTO duration (request_date, completion_date)
VALUES
('2022-03-22', '2022-03-28'),
('2022-03-25', '2022-03-30'),
('2022-03-27', '2022-04-03'),
('2022-03-28', '2022-04-15'),
('2022-04-01', '2022-04-07'),
('2022-04-05', '2022-04-10');

SELECT * FROM duration;


INSERT INTO request (vehicle_id, duration_id, work_type_id, status, master_id, service_station_id, cost_id)
VALUES
(1, 1, 1, 'Завершено', 1, 1, 1),
(2, 2, 2, 'Завершено', 4, 2, 2),
(3, 3, 3, 'Готово', 3, 2, 3),
(4, 4, 4, 'Ожидает', 5, 2, 4),
(5, 5, 5, 'Поступило', 2, 1, 5),
(1, 6, 5, 'Поступило', 2, 1, 6);

SELECT * FROM request;

