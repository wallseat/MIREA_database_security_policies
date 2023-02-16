--- Создадим базу данных versions_db
CREATE DATABASE versions_db;

--- Создадим таблицу users
CREATE TABLE users (
    id serial PRIMARY KEY,
    username varchar(255) NOT NULL,
    email varchar(255) NOT NULL,
    version integer NOT NULL DEFAULT 1
);

--- Создадим триггер, который будет автоматически увеливать версию строки при любом обновлении
CREATE OR REPLACE FUNCTION update_version() RETURNS TRIGGER AS 
$$
BEGIN
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_version_trigger
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_version();

--- Вставим в таблицу «users» строку с различными данными, а затем обновим.
INSERT INTO users (username, email) VALUES ('user1', 'user1@temp.ru');
INSERT INTO users (username, email) VALUES ('user2', 'user2@temp.ru');

UPDATE users SET email = 'user1@temp1.ru' WHERE username = 'user1';

SELECT * FROM users;

--- Выведем информацию о версиях строк, узнав сколько версий строк сейчас находится в таблице
SELECT '(0,'||lp||')' AS ctid, 
    t_xmin as xmin,
    t_xmax as xmax, 
    CASE WHEN (t_infomask & 256) > 0  THEN 't' END AS xmin_c,
    CASE WHEN (t_infomask & 512) > 0  THEN 't' END AS xmin_a,
    CASE WHEN (t_infomask & 1024) > 0 THEN 't' END AS xmax_c,
    CASE WHEN (t_infomask & 2048) > 0 THEN 't' END AS xmax_a
FROM heap_page_items(get_raw_page('users',0))
ORDER BY lp;

--- Опустошим таблицу при помощи TRUNCATE;
TRUNCATE users;

--- Начнем транзакцию и вставим новую строку, узнаем номер текущей транзакции
BEGIN;
INSERT INTO users(username, email) VALUES ('user1', 'user1@tmp.ru') RETURNING *, ctid, xmin, xmax;

--- Создадим точку сохранения и добавим новую строку;
SAVEPOINT savepoint1;
INSERT INTO users(username, email) VALUES ('user2', 'user2@tmp.ru') RETURNING *, ctid, xmin, xmax;

--- Откатимся к точке сохранения и добавим новую строку
ROLLBACK TO savepoint1;
INSERT INTO users(username, email) VALUES ('user3', 'user3@tmp.ru') RETURNING *, ctid, xmin, xmax;

COMMIT;

--- Выведем информацию о версиях строк
SELECT '(0,'||lp||')' AS ctid, 
    t_xmin as xmin,
    t_xmax as xmax, 
    CASE WHEN (t_infomask & 256) > 0  THEN 't' END AS xmin_c,
    CASE WHEN (t_infomask & 512) > 0  THEN 't' END AS xmin_a,
    CASE WHEN (t_infomask & 1024) > 0 THEN 't' END AS xmax_c,
    CASE WHEN (t_infomask & 2048) > 0 THEN 't' END AS xmax_a
FROM heap_page_items(get_raw_page('users',0))
ORDER BY lp;

