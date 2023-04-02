-- Создать новую базу данных с именем wal_db
CREATE DATABASE wal_db;

-- Создать таблицу orders с колонками:
-- id: уникальный идентификатор заказа (целое число, первичный ключ, автоинкремент)
-- customer_name: имя клиента (varchar(255))
-- order_date: дата размещения заказа (date)
-- total_amount: общая сумма заказа (numeric)
CREATE TABLE orders (
    id serial primary key,
    customer_name varchar(255),
    order_date date,
    total_amount numeric(16, 2)
);

-- Вставить в таблицу orders несколько примеров данных
INSERT INTO orders (customer_name, order_date, total_amount)
VALUES 
    ('ivan', '02-02-2022'::date, 1010.55),
    ('petr', '03-03-2022'::date, 999.99),
    ('nastya', '04-04-2022'::date, 949.49);


-- Узнать сколько байт занимают сгенерированные журнальные записи
SELECT pg_current_wal_insert_lsn();

-- Изменить некоторые из существующих записей в таблице orders
UPDATE orders SET total_amount = total_amount + 500 WHERE order_date > '01-03-2022'::date;

-- Удалить несколько записей из таблицы orders
DELETE FROM orders WHERE customer_name = 'nastya';