-- Создать базу данных с именем vacuum_db.
CREATE DATABASE vacuum_db;


-- Создать таблицу users, отключив параметр авто-очистки со следующими полями:
-- id: уникальный идентификатор пользователя (integer, primary key, auto-increment).
-- username: имя пользователя (varchar(255)).
-- email: электронный адрес пользователя (varchar(255)).
-- category: категория (char(3))
CREATE TABLE users (
    id serial primary key,
    username varchar(255),
    email varchar(255),
    category char(3)
) WITH (autovacuum_enabled = off);

-- Написать скрипт заполняющий таблицу users 1000000 рандомными записями,
-- в поле category всегда должна находиться запись ‘FOO’.
INSERT INTO users (username, email, category)
    SELECT gen_random_uuid() as username, gen_random_uuid() as email, 'FOO'::char(3) AS category 
    FROM generate_series(1,1000000);

-- Используя оператор Explain выведите из таблицы users все записи которые в поле category имеют значение ‘FOO’;
EXPLAIN SELECT * FROM users WHERE category = 'FOO';

