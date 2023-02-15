--- Задача 1. Вывести все модели самолетов, которые улетают в Уфу
SELECT
    distinct(a.model)
FROM
    aircrafts a
    LEFT OUTER JOIN flights f ON a.aircraft_code = f.aircraft_code
    AND f.arrival_airport = 'UFA';

--- Задача 2. Вывести среднее количество людей на рейсах из Санкт-Петербурга в Москву
SELECT
    AVG(a.c)
FROM
    (
        SELECT
            COUNT(tf.ticket_no) c
        FROM
            flights f
            LEFT OUTER JOIN ticket_flights tf ON f.flight_id = tf.flight_id
        WHERE
            f.departure_airport IN (
                SELECT
                    a.airport_code
                FROM
                    airports a
                WHERE
                    a.city = 'Санкт-Петербург'
            )
            AND f.arrival_airport IN (
                SELECT
                    a.airport_code
                FROM
                    airports a
                WHERE
                    a.city = 'Москва'
            )
        GROUP BY
            f.flight_id
    ) a;

--- Задача 3. Найти модель самолета с максимальным количеством сидений (учитывается что таких моделей может быть несколько)
WITH model_seatc AS (
    SELECT
        COUNT(*) c,
        a.model m
    FROM
        aircrafts a
        LEFT OUTER JOIN seats s ON a.aircraft_code = s.aircraft_code
    GROUP BY
        a.model
)
SELECT
    model_seatc.c "Количество мест",
    model_seatc.m "Модель самолета"
FROM
    model_seatc
WHERE
    model_seatc.c = (
        SELECT
            MAX(model_seatc.c)
        FROM
            model_seatc
    );

--- Задача 4. Вывести рейсы число мест в которых больше чем проданных на них билетов
WITH cs AS (
    SELECT
        a.aircraft_code ac,
        COUNT(*) sc
    FROM
        aircrafts a
        LEFT OUTER JOIN seats s ON a.aircraft_code = s.aircraft_code
    GROUP BY
        a.aircraft_code
),
fta AS (
    SELECT
        f.flight_no fn,
        COUNT(*) tc,
        f.aircraft_code ac
    FROM
        flights f
        LEFT OUTER JOIN ticket_flights tf ON f.flight_id = tf.flight_id
    GROUP BY
        f.flight_no,
        f.aircraft_code
)
SELECT
    fta.fn flight_no,
    fta.tc tickets_count,
    cs.sc seats_count
FROM
    fta
    LEFT OUTER JOIN cs ON fta.ac = cs.ac
WHERE
    fta.tc < cs.sc;

--- Задача 5. Вывести общую сумму потраченные на билеты каждым пассажиром
SELECT
    t.passenger_name,
    SUM(b.total_amount) AS total_spent
FROM
    tickets t
    LEFT OUTER JOIN bookings b ON t.book_ref = b.book_ref
GROUP BY
    t.passenger_name;

--- Задача 6. На каких местах сидел пассажир летающий чаще всего?
SELECT
    t.passenger_name,
    bp.seat_no
FROM
    (
        SELECT
            t.passenger_id pasid,
            COUNT(tf.flight_id) fc
        FROM
            tickets t
            LEFT OUTER JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
        GROUP BY
            t.passenger_id
        ORDER BY
            fc DESC
        LIMIT
            1
    ) AS pasid_fc
    LEFT OUTER JOIN tickets t ON pasid_fc.pasid = t.passenger_id
    LEFT OUTER JOIN boarding_passes bp ON t.ticket_no = bp.ticket_no;

--- Задача 7. Выведите таблицу самолетов отсортированных по убыванию количества мест с дополнительным атрибутом,
--- в котором самолёты пронумерованы по частоте полётов.
SELECT
    a.*,
    pf.fc flight_count,
    ps.sc seats_count
FROM
    aircrafts a
    LEFT OUTER JOIN (
        SELECT
            a1.aircraft_code acode,
            count(f.flight_id) fc
        FROM
            aircrafts a1
            LEFT OUTER JOIN flights f ON a1.aircraft_code = f.aircraft_code
        GROUP BY
            a1.aircraft_code
    ) pf ON pf.acode = a.aircraft_code
    LEFT OUTER JOIN (
        SELECT
            s.aircraft_code acode,
            count(s.seat_no) sc
        FROM
            seats s
        GROUP BY
            s.aircraft_code
    ) ps ON ps.acode = a.aircraft_code
ORDER BY
    ps.sc DESC;