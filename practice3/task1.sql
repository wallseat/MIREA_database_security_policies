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

-- Выполните команду ANALYZE;
ANALYZE users;

-- Используя оператор Explain выведите из таблицы users все записи которые в поле category имеют значение ‘FOO’;
EXPLAIN SELECT * FROM users WHERE category = 'FOO';

-- Временно уменьшите значение maintenance_work_mem 
-- чтоб оно стало равно 1MB (не забудьте выполнить функцию pg_reload_conf())
SET maintenance_work_mem to '1MB';
SELECT pg_reload_conf();

-- Измените значение поля category на ‘BPP’
UPDATE users SET category = 'BPP';

-- Запустите очистку VACUUM VERBOSE. Заодно через небольшое время
-- в другом сеансе обратитесь к pg_stat_progress_vacuum.
VACUUM VERBOSE;
-- в другом сеансе
SELECT * FROM pg_stat_progress_vacuum; 

-- Верните значение maintenance_work_mem к исходному значению.
SET maintenance_work_mem to '64MB';
SELECT pg_reload_conf();