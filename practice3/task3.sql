-- Включите параметр автоочистки в таблице users  
ALTER TABLE users SET (
    autovacuum_enabled = true
);

-- Настройте автоочистку на запуск при изменении 10 % строк, 
-- время «сна» — одна секунда (autovacuum_vacuum_threshold = 0, 
-- autovacuum_vacuum_scale_factor = 0.1, autovacuum_naptime = '1s')
-- !Делаем в postgresql.conf файле

-- Заполните таблицу users до 1000000 записей.
INSERT INTO users (username, email, category)
SELECT gen_random_uuid() as username, gen_random_uuid() as email, 'FOO'::char(3) AS category 
    FROM generate_series(1,1000000);

-- Узнать текущий размер файла данных таблицы users
-- при помощи функции: pg_size_pretty(pg_table_size('название таблицы'))
SELECT pg_size_pretty(pg_table_size('users'));

-- При помощи pg_stat_all_tables узнайте сколько раз 
-- выполнялась автоочистка (autovacuum_count)
select schemaname,relname,last_autovacuum,autovacuum_count from pg_stat_all_tables where relname = 'users';

-- Напишите скрипт который двадцать раз с интервалом в несколько секунд изменяет по 5 % случайных строк. 
-- Каждое изменение выполняйте в отдельной транзакции.

DO
$BODY$
BEGIN
    FOR i IN 1..20 LOOP
        DELETE FROM users WHERE id IN (
            SELECT id FROM users TABLESAMPLE BERNOULLI (5)
        );
        COMMIT;
        PERFORM pg_sleep(3);
    END LOOP;
END
$BODY$
LANGUAGE plpgsql;

-- При помощи pg_stat_all_tables узнайте сколько
-- раз выполнялась автоочистка (autovacuum_count)
select schemaname,relname,last_autovacuum,autovacuum_count from pg_stat_all_tables where relname = 'users';

-- Сравнить размеры таблицы до и после обновлений
SELECT pg_size_pretty(pg_table_size('users'));