-- task 1
CREATE OR REPLACE VIEW view1 AS
    SELECT r.request_id, v.vehicle_id, v.model,
        SUM(COALESCE (pfr.part_amount, 0)) AS full_part_amount,
        SUM(COALESCE (cfr.cons_amount, 0)) AS full_cons_amount,
        rc.spare_parts_cost AS full_parts_cost,
        rc.consumable_cost AS full_cons_cost
FROM vehicle v
JOIN request r ON v.vehicle_id = r.vehicle_id
JOIN request_cost rc ON r.cost_id = rc.cost_id
FULL JOIN parts_for_request pfr ON r.request_id = pfr.request_id
FULL JOIN cons_for_request cfr on r.request_id = cfr.request_id
GROUP BY  r.request_id, v.vehicle_id, v.vehicle_id, rc.spare_parts_cost,
      rc.consumable_cost
ORDER BY request_id;

SELECT * FROM view1;

CREATE OR REPLACE VIEW amount_for_vehicle AS
    SELECT model,
           SUM(full_part_amount) AS full_part_amount,
           SUM(full_cons_amount) AS full_cons_amount,
           SUM(full_parts_cost) AS full_parts_cost,
           SUM(full_cons_cost) AS full_cons_cost
FROM (SELECT * FROM view1) as "v1*"
GROUP BY model
ORDER BY model;

SELECT * FROM amount_for_vehicle;


-- task 2
CREATE OR REPLACE VIEW top_ten AS
SELECT m.master_name, s.specialization, ss.address,
       COUNT(r.master_id) AS work_num, SUM(rc.final_cost)
FROM master m
JOIN specialization s ON m.specialization_id = s.specialization_id
JOIN service_station ss ON m.service_station_id = ss.service_station_id
JOIN request r ON m.master_id = r.master_id
JOIN request_cost rc on r.cost_id = rc.cost_id
JOIN duration d on r.duration_id = d.duration_id WHERE d.request_date >= '2022-01-01' AND r.status = 'Завершено'
GROUP BY m.master_name, s.specialization, ss.address
ORDER BY work_num DESC
LIMIT 10;

SELECT * FROM top_ten;


-- task 3
CREATE OR REPLACE FUNCTION change_status() RETURNS TRIGGER AS $$
DECLARE
    stat request_status;
    id integer;
BEGIN
    stat = CAST(NEW.status as request_status);
    id = CAST(NEW.duration_id as integer);
    if (stat = 'Завершено') then UPDATE duration SET completion_date = current_date WHERE duration_id = id; end if;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER change_status AFTER INSERT OR UPDATE OF status ON request
    FOR EACH ROW EXECUTE FUNCTION change_status();


-- Запрос
UPDATE request SET status = 'Завершено' WHERE request_id = 2 OR request_id = 3;
UPDATE request SET status = 'Готово' WHERE request_id = 9;

