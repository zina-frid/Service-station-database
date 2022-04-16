import psycopg2
from psycopg2 import Error
import argparse
import configparser
import datetime
import calendar
import random
import pandas as pd

request_cost, service_station, master, request = (), (), (), ()
unique_nums, unique_spec, unique_addr = (), (), ()
unique_part, unique_cons, unique_p_f_r, unique_c_f_r = (), (), (), ()

digits = '0123456789'
letters_for_number = 'АВЕКМНОРСТУХ'
letters = 'abcdefghijklmnopqrstuvwxyz'

config = configparser.ConfigParser()
config.read('config.ini', encoding='utf-8')

colors = open("colors.txt", encoding="utf8").readlines()
cars = pd.DataFrame(pd.read_csv("cars.csv"))
names = open("names.txt", encoding="utf8").readlines()
address = open("address.txt", encoding="utf8").readlines()
cons_list = open("consumables.txt", encoding="utf8").readlines()

try:
    # Подключение к существующей базе данных
    connection = psycopg2.connect(
        dbname=config.get("postgres", "dbname"),
        user=config.get("postgres", "user"),
        password=config.get("postgres", "password"))

    # Курсор для выполнения операций с базой данных
    cursor = connection.cursor()


    def generate_data(data_args):
        if data_args.truncate is not None and int(data_args.truncate) == 1:
            truncate_db()

        else:
            if data_args.vec is not None:
                generate_vehicle(data_args.vec)

            if data_args.sst is not None:
                generate_service_station(data_args.sst)

            if data_args.spec is not None:
                generate_specialization(data_args.spec)

            if data_args.master is not None:
                generate_master(data_args.master)

            if data_args.wt is not None:
                generate_work_type(data_args.wt)

            if data_args.cost is not None:
                generate_request_cost(data_args.cost)

            if data_args.part is not None:
                generate_spare_parts(data_args.part)

            if data_args.cons is not None:
                generate_consumables(data_args.cons)

            if data_args.req is not None:
                generate_duration(data_args.req)
                generate_request(data_args.req)

                generate_parts_for_request(data_args.req)
                generate_cons_for_request(data_args.req)


    def truncate_db():
        cursor.execute("TRUNCATE TABLE vehicle RESTART IDENTITY CASCADE;"
                       "TRUNCATE TABLE specialization RESTART IDENTITY CASCADE;"
                       "TRUNCATE TABLE request_cost RESTART IDENTITY CASCADE;"
                       "TRUNCATE TABLE service_station RESTART IDENTITY CASCADE;"
                       "TRUNCATE TABLE master RESTART IDENTITY CASCADE;"
                       "TRUNCATE TABLE work_type RESTART IDENTITY CASCADE;"
                       "TRUNCATE TABLE duration RESTART IDENTITY CASCADE;"
                       "TRUNCATE TABLE request RESTART IDENTITY CASCADE;"
                       "TRUNCATE TABLE spare_parts RESTART IDENTITY CASCADE;"
                       "TRUNCATE TABLE parts_for_request RESTART IDENTITY CASCADE;"
                       "TRUNCATE TABLE consumables RESTART IDENTITY CASCADE;"
                       "TRUNCATE TABLE cons_for_request RESTART IDENTITY CASCADE;")


    def generate_vehicle(n):
        global unique_nums
        cursor.execute('SELECT car_number FROM vehicle')
        unique_nums = cursor.fetchall()
        model, number, temp = [], [], []

        for i in range(int(n)):
            rand = random.randint(0, len(cars) - 1)
            model.append(cars.model[rand])
            num = rnd_number()
            while not unique(num, "num") or num in number:
                num = rnd_number()
            number.append(num)

            temp.append(tuple((cars.vehicle_type[rand], number[i], model[i].rstrip(model[i][-1]),
                               random.randint(cars.year[rand], 2022), random.choice(colors).replace('\n', ''),
                               cars.engine_capacity[rand], cars.transmission[rand],)))

        generated_vehicle = tuple(temp)
        query = "INSERT INTO vehicle (vehicle_type, car_number, model, manufacture_year, color, engine_capacity, transmission) VALUES (%s, %s, %s, %s, %s, %s, %s)"
        cursor.executemany(query, generated_vehicle)


    def generate_service_station(n):
        global unique_addr
        cursor.execute('SELECT address FROM service_station')
        unique_addr = cursor.fetchall()
        serst, temp = [], []

        for i in range(int(n)):
            addr = rnd_address()
            while not unique(addr, "addr") or addr in serst:
                addr = rnd_address()
            serst.append(addr)
            temp.append(tuple((serst[i],)))

        generated_address = tuple(temp)
        query = "INSERT INTO service_station (address) VALUES (%s)"
        cursor.executemany(query, generated_address)


    def generate_specialization(n):
        global unique_spec
        cursor.execute('SELECT specialization FROM specialization')
        unique_spec = cursor.fetchall()
        spec, temp = [], []

        for i in range(int(n)):
            one_spec = "Специальзация " + rnd_seq()
            while not unique(one_spec, "spec") or one_spec in spec:
                one_spec = "Специальзация " + rnd_seq()
            spec.append(one_spec)
            temp.append(tuple((spec[i],)))

        generated_spec = tuple(temp)
        query = "INSERT INTO specialization (specialization) VALUES (%s)"
        cursor.executemany(query, generated_spec)
        check_master()


    def check_master():
        global master, service_station
        cursor.execute('SELECT specialization_id FROM specialization')
        specialization = cursor.fetchall()
        cursor.execute('SELECT master_id, service_station_id, specialization_id FROM master')
        master = cursor.fetchall()
        cursor.execute('SELECT service_station_id FROM service_station')
        service_station = cursor.fetchall()

        flag = False
        temp = []

        for spec in specialization:
            if len(master) > 0:
                for row in master:
                    if row[2] == spec[0]:
                        flag = True
                if not flag:
                    temp.append(
                        tuple((random.choice(names).replace('\n', ''), random.choice(service_station)[0], spec[0],)))
            else:
                temp.append(
                    tuple((random.choice(names).replace('\n', ''), random.choice(service_station)[0], spec[0],)))
            flag = False

        add_master = tuple(temp)
        query = "INSERT INTO master (master_name, service_station_id, specialization_id) VALUES (%s, %s, %s)"
        cursor.executemany(query, add_master)


    def generate_master(n):
        global master, service_station
        cursor.execute('SELECT service_station_id FROM service_station')
        service_station = cursor.fetchall()
        cursor.execute('SELECT specialization_id FROM specialization')
        specialization = cursor.fetchall()

        temp = []

        for i in range(int(n)):
            temp.append(tuple((random.choice(names).replace('\n', ''), random.choice(service_station)[0],
                               random.choice(specialization)[0],)))

        generated_master = tuple(temp)
        query = "INSERT INTO master (master_name, service_station_id, specialization_id) VALUES (%s, %s, %s)"
        cursor.executemany(query, generated_master)


    def generate_request_cost(n):
        final, sp_cost, cons_cost, others, mh_cost = [], [], [], [], []
        temp = []

        for i in range(int(n)):
            f, sp, con, other, mh = gen_cost()
            final.append(str(f))
            sp_cost.append(str(sp))
            cons_cost.append(str(con))
            others.append(str(other))
            mh_cost.append(str(mh))
            temp.append(tuple((final[i], sp_cost[i], cons_cost[i], others[i], mh_cost[i],)))

        generated_cost = tuple(temp)
        query = "INSERT INTO request_cost (final_cost, spare_parts_cost, consumable_cost, others_cost, man_hours_cost) VALUES (%s, %s, %s, %s, %s)"
        cursor.executemany(query, generated_cost)


    def generate_work_type(n):
        cursor.execute('SELECT specialization_id FROM specialization')
        specialization = cursor.fetchall()

        maintenance = ['Плановое', 'Аварийное']
        temp = []

        for i in range(int(n)):
            temp.append(tuple((random.choice(maintenance), random.choice(specialization)[0],)))

        generated_work_types = tuple(temp)
        query = "INSERT INTO work_type (maintenance, specialization_id) VALUES (%s, %s)"
        cursor.executemany(query, generated_work_types)


    def generate_duration(n):
        date_from, date_to = [], []
        temp = []

        for i in range(int(n)):
            d_f, d_t = gen_dates(random.randint(3, 15))
            date_from.append(d_f)
            date_to.append(d_t)
            temp.append(tuple((date_from[i], date_to[i],)))

        generated_duration = tuple(temp)
        query = "INSERT INTO duration (request_date, completion_date) VALUES (%s, %s)"
        cursor.executemany(query, generated_duration)


    def generate_request(n):
        global request, master, service_station, request_cost
        cursor.execute('SELECT vehicle_id FROM vehicle')
        vehicle = cursor.fetchall()
        cursor.execute('SELECT * FROM duration')
        duration = cursor.fetchall()
        cursor.execute('SELECT work_type_id, specialization_id FROM work_type')
        work_type = cursor.fetchall()
        cursor.execute('SELECT master_id, service_station_id, specialization_id FROM master')
        master = cursor.fetchall()
        cursor.execute('SELECT service_station_id FROM service_station')
        service_station = cursor.fetchall()
        cursor.execute('SELECT cost_id, spare_parts_cost, consumable_cost FROM request_cost')
        request_cost = cursor.fetchall()
        cursor.execute('SELECT * FROM request')
        request = cursor.fetchall()

        ind = len(request)
        dur, work_t, stut, mast, serst, cost = [], [], [], [], [], []
        temp = []

        for i in range(int(n)):
            d = duration[ind]
            dur.append(d[0])
            wt = random.choice(work_type)
            work_t.append(wt[0])
            m, ss = get_master_ss(wt[1])
            mast.append(m)
            serst.append(ss)
            stut.append(get_status(d))
            temp.append(tuple((random.choice(vehicle)[0], dur[i], work_t[i], stut[i], mast[i], serst[i],
                               random.choice(request_cost)[0],)))
            ind += 1

        generated_request = tuple(temp)
        query = "INSERT INTO request (vehicle_id, duration_id, work_type_id, status, master_id, service_station_id, cost_id) VALUES (%s, %s, %s, %s, %s, %s, %s)"
        cursor.executemany(query, generated_request)


    def generate_spare_parts(n):
        global unique_part
        cursor.execute('SELECT part_name FROM spare_parts')
        unique_part = cursor.fetchall()

        parts, temp = [], []

        for i in range(int(n)):
            part = random.choice(('Запчасть ', 'Деталь ')) + rnd_seq()
            while not unique(part, "part") or part in parts:
                part = random.choice(('Запчасть ', 'Деталь ')) + rnd_seq()
            parts.append(part)
            temp.append(tuple((parts[i], random.choice(('true', 'false')))))

        generated_spare_parts = tuple(temp)
        query = "INSERT INTO spare_parts (part_name, part_in_stock) VALUES (%s, %s)"
        cursor.executemany(query, generated_spare_parts)


    def generate_consumables(n):
        global unique_cons
        cursor.execute('SELECT cons_name FROM consumables')
        unique_cons = cursor.fetchall()

        consum, temp = [], []

        for i in range(int(n)):
            cons = random.choice(cons_list).replace('\n', ' ') + rnd_seq()
            while not unique(cons, "part") or cons in consum:
                cons = random.choice(cons_list).replace('\n', ' ') + rnd_seq()
            consum.append(cons)
            temp.append(tuple((consum[i], random.choice(('true', 'false')))))

        generated_consumables = tuple(temp)
        query = "INSERT INTO consumables (cons_name, cons_in_stock) VALUES (%s, %s)"
        cursor.executemany(query, generated_consumables)


    def generate_parts_for_request(n):
        global request, request_cost, unique_p_f_r
        cursor.execute('SELECT request_id, cost_id FROM request')
        request = cursor.fetchall()
        cursor.execute('SELECT part_id FROM spare_parts')
        spare_parts = cursor.fetchall()
        cursor.execute('SELECT cost_id, spare_parts_cost, consumable_cost FROM request_cost')
        request_cost = cursor.fetchall()
        cursor.execute('SELECT request_id, part_id FROM parts_for_request')
        unique_p_f_r = cursor.fetchall()

        nn = int(n)
        req = get_req(1, nn, len(request))
        array_p_f_r, temp = [], []

        for r in req:
            amount = random.randint(1, 3)
            for j in range(amount):
                p_f_r = random.choice(spare_parts)[0]
                while not unique((r[0], p_f_r), "pfr") or (r[0], p_f_r) in array_p_f_r:
                    p_f_r = random.choice(spare_parts)[0]
                array_p_f_r.append((r[0], p_f_r))
                temp.append(tuple((r[0],  p_f_r, str(random.randint(1, 16)),)))

        generated_parts_for_request = tuple(temp)
        query = "INSERT INTO parts_for_request (request_id, part_id, part_amount) VALUES(%s, %s, %s)"
        cursor.executemany(query, generated_parts_for_request)


    def generate_cons_for_request(n):
        global request, request_cost, unique_c_f_r
        cursor.execute('SELECT request_id, cost_id FROM request')
        request = cursor.fetchall()
        cursor.execute('SELECT cons_id FROM consumables')
        consumables = cursor.fetchall()
        cursor.execute('SELECT cost_id, spare_parts_cost, consumable_cost FROM request_cost')
        request_cost = cursor.fetchall()
        cursor.execute('SELECT request_id, cons_id FROM cons_for_request')
        unique_c_f_r = cursor.fetchall()

        nn = int(n)
        req = get_req(2, nn, len(request))
        array_c_f_r, temp = [], []

        for r in req:
            amount = random.randint(1, 3)
            for j in range(amount):
                c_f_r = random.choice(consumables)[0]
                while not unique((r[0], c_f_r), "cfr") or (r[0], c_f_r) in array_c_f_r:
                    c_f_r = random.choice(consumables)[0]
                array_c_f_r.append((r[0], c_f_r))
                temp.append(tuple((r[0], c_f_r, str(random.randint(1, 16)),)))

        generated_cons_for_request = tuple(temp)
        query = "INSERT INTO cons_for_request (request_id, cons_id, cons_amount) VALUES(%s, %s, %s)"
        cursor.executemany(query, generated_cons_for_request)


    def rnd_number():
        string = ''
        string += random.choice(letters_for_number)
        for i in range(3):
            string += random.choice(digits)
        for i in range(2):
            string += random.choice(letters_for_number)
        return string


    def rnd_seq():
        string = ''
        for j in range(random.randint(2, 6)):
            string += random.choice(digits)
        for j in range(random.randint(2, 6)):
            string += random.choice(letters)
        return string


    def rnd_address():
        string = ''
        string += random.choice(address).replace('\n', '') + ", "
        r = random.choice(digits)
        while r == '0':
            r = random.choice(digits)
        string += r
        string += random.choice(digits)
        return string


    def gen_dates(dur):
        month1 = random.randint(3, 4)
        d_in_m = calendar.monthrange(2022, month1)[1]
        day1 = random.randint(1, d_in_m)
        day2 = day1 + dur
        month2 = month1
        if day2 > d_in_m:
            month2 += 1
            day2 -= d_in_m
        date1 = datetime.date(2022, month1, day1).isoformat()
        date2 = datetime.date(2022, month2, day2).isoformat()

        return date1, date2


    def gen_cost():
        y = random.randint(0, 1)
        sp = random.randint(1, 70) * 1000 * y
        yy = random.randint(0, 1)
        con = random.randint(1, 100) * 100 * yy
        other = random.randint(0, 30) * 100
        mh = random.randint(5, 200) * 100
        f = sp + con + other + mh
        return f, sp, con, other, mh


    def get_master_ss(ident):
        available = []
        for row in master:
            if row[2] == ident:
                available.append(row)
        rnd = random.choice(available)
        return rnd[0], rnd[1]


    def get_status(dur):
        today = datetime.date.today()
        f, t = str(dur[1]), str(dur[2])
        dat_f = datetime.date(int(f[0:4]), int(f[5:7]), int(f[8:]))
        dat_t = datetime.date(int(t[0:4]), int(t[5:7]), int(t[8:]))

        if today >= dat_t:
            return random.choice(('Завершено', 'Готово'))
        else:
            if today > dat_f:
                return random.choice(('Поступило', 'В работе', 'В работе', 'Ожидает'))
            else:
                return 'Поступило'


    def get_req(ind, n, end_ind):
        req_ = []
        for row in request[end_ind - n:]:
            i_cost = row[1]
            for c_row in request_cost:
                if c_row[0] == i_cost:
                    if c_row[ind] != 0:
                        req_.append(row)
        return req_


    def unique(element, string):
        if string == "num":
            array = [row[0] for row in unique_nums]
            if element in array:
                return False
            else:
                return True
        elif string == "spec":
            array = [row[0] for row in unique_spec]
            if element in array:
                return False
            else:
                return True
        elif string == "addr":
            array = [row[0] for row in unique_addr]
            if element in array:
                return False
            else:
                return True
        elif string == "part":
            array = [row[0] for row in unique_part]
            if element in array:
                return False
            else:
                return True
        elif string == "cons":
            array = [row[0] for row in unique_cons]
            if element in array:
                return False
            else:
                return True
        elif string == "pfr":
            array = [(row[0], row[1]) for row in unique_p_f_r]
            if element in array:
                return False
            else:
                return True
        elif string == "cfr":
            array = [(row[0], row[1]) for row in unique_c_f_r]
            if element in array:
                return False
            else:
                return True
        else:
            return False


    if __name__ == '__main__':
        args = argparse.ArgumentParser(description="Details of data generation")
        args.add_argument('--vec', action="store", dest="vec")
        args.add_argument('--sst', action="store", dest="sst")
        args.add_argument('--spec', action="store", dest="spec")
        args.add_argument('--master', action="store", dest="master")
        args.add_argument('--wt', action="store", dest="wt")
        args.add_argument('--cost', action="store", dest="cost")
        args.add_argument('--part', action="store", dest="part")
        args.add_argument('--cons', action="store", dest="cons")
        args.add_argument('--req', action="store", dest="req")
        args.add_argument('--truncate', action="store", dest="truncate")

        arguments = args.parse_args()
        generate_data(arguments)


except (Exception, Error) as error:
    print("Ошибка при работе с PostgreSQL", error)
finally:
    if connection:
        connection.commit()
        cursor.close()
        connection.close()
        print("Соединение с PostgreSQL закрыто")
