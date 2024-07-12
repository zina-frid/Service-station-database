-- Перечисления для типа кузова и трансмиссии
create type body as enum ('Седан', 'Хэтчбек', 'Пикап', 'Микро', 'Кроссовер', 'Внедорожник', 'Кабриолет', 'Суперкар', 'Фургон', 'Купе', 'Грузовик', 'Минивен');
create type transmission_type as enum ('Механическая', 'Автоматическая', 'Полуавтоматическая');

-- Транспортное средство
CREATE TABLE IF NOT EXISTS vehicle
(
	vehicle_id SERIAL PRIMARY KEY,
	vehicle_type body NOT NULL,
	car_number CHAR(6) UNIQUE NOT NULL,
	model TEXT NOT NULL,
	manufacture_year CHAR(4) NOT NULL,
	color TEXT NOT NULL,
	engine_capacity NUMERIC(2, 1) NOT NULL,
	transmission transmission_type NOT NULL
);

-- Специализация
CREATE TABLE IF NOT EXISTS specialization
(
	specialization_id SERIAL PRIMARY KEY,
	specialization TEXT UNIQUE NOT NULL
);

-- Стоимость
CREATE TABLE IF NOT EXISTS request_cost
(
	cost_id SERIAL PRIMARY KEY,
	final_cost INTEGER NOT NULL,
	spare_parts_cost INTEGER DEFAULT 0,
	consumable_cost INTEGER DEFAULT 0,
	others_cost INTEGER DEFAULT 0,
	man_hours_cost INTEGER NOT NULL
);

-- Станция ТО
CREATE TABLE IF NOT EXISTS service_station
(
	service_station_id SERIAL PRIMARY KEY,
	address TEXT UNIQUE NOT NULL
);

-- Мастер
CREATE TABLE IF NOT EXISTS master
(
	master_id SERIAL PRIMARY KEY,
	master_name TEXT NOT NULL,
	service_station_id INTEGER REFERENCES service_station (service_station_id) NOT NULL,
	specialization_id INTEGER REFERENCES specialization (specialization_id) NOT NULL
);

-- Перечисление для типа ТО
create type maintenance_type as enum ('Плановое', 'Аварийное');

-- Тип работ
CREATE TABLE IF NOT EXISTS work_type
(
	work_type_id SERIAL PRIMARY KEY,
	maintenance maintenance_type NOT NULL,
	specialization_id INTEGER REFERENCES specialization (specialization_id) NOT NULL
);


-- Срок работ
CREATE TABLE IF NOT EXISTS duration
(
	duration_id SERIAL PRIMARY KEY,
	request_date DATE NOT NULL,
	completion_date DATE NOT NULL
);

-- Пречисление для статуса
create type request_status as enum ('Поступило', 'В работе', 'Ожидает', 'Готово', 'Завершено');

-- Обращение
CREATE TABLE IF NOT EXISTS request
(
	request_id SERIAL PRIMARY KEY,
	vehicle_id INTEGER REFERENCES vehicle (vehicle_id) NOT NULL,
	duration_id INTEGER REFERENCES duration (duration_id) NOT NULL,
	work_type_id INTEGER REFERENCES work_type (work_type_id) ON DELETE RESTRICT NOT NULL,
	status request_status NOT NULL,
	master_id INTEGER REFERENCES master (master_id) ON DELETE RESTRICT NOT NULL,		
	service_station_id INTEGER REFERENCES service_station (service_station_id) ON DELETE RESTRICT NOT NULL,
	cost_id INTEGER REFERENCES request_cost (cost_id) NOT NULL
); 
