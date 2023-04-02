CREATE DATABASE practice2;

-- Создадим таблицы аккаунтов и транзацкий
CREATE TABLE accounts (
    id serial PRIMARY KEY,
    name varchar(255) NOT NULL,
    balance money NOT NULL
);

CREATE TABLE transactions (
    id serial PRIMARY KEY,
    account_id integer NOT NULL REFERENCES accounts(id),
    amount money NOT NULL
);


--

-- Создадим временную роль для тестирования
CREATE ROLE test_role;
GRANT ALL ON ALL TABLES IN SCHEMA "public" TO test_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA "public" TO test_role;

SET ROLE test_role;

-- Создадим незавершенную транзакцию
SELECT setval('accounts_id_seq', 1, false);

BEGIN;
INSERT INTO accounts (name, balance) VALUES ('test', 1000);
INSERT INTO transactions (account_id, amount) VALUES (1, 100);

-- Проверим, что транзакция в процессе (результат должен быть не пустым)
SELECT txid_current_if_assigned();

-- В новом окне подключимся к БД и выполним запрос из под пользователя postgres
BEGIN;
SELECT * FROM accounts;
SELECT * FROM transactions;
COMMIT;

--

-- Создадим транзакцию для выборки данных из таблицы accounts с уровнем изоляции READ COMMITTED
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM accounts;

-- В другой сессии изменяем данные в таблице accounts
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
INSERT INTO accounts (id, name, balance) VALUES (4, 'test', 1000);
COMMIT;

-- В первой сессии видим изменения
SELECT * FROM accounts;

--

--- Добавим запись в таблицу accounts
INSERT INTO accounts (id, name, balance) VALUES (100, 'test', 1000);

--- Откроем транзакцию с уровнем REPETABLE READ
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

--- В другой сессии удалим строку и таблицы accounts
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
DELETE FROM accounts WHERE id = 100;
COMMIT;

--- В первой сессии выведем таблицу accounts
SELECT * FROM accounts;

-- Данных не будет

--- Снова добавим запись в таблицу accounts
INSERT INTO accounts (id, name, balance) VALUES (100, 'test', 1000);

--- Откроем транзакцию с уровнем REPETABLE READ и сделаем SELECT который не затрагивает ни одну из таблиц
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT 1;

--- В другой сессии удалим строку и таблицы accounts
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
DELETE FROM accounts WHERE id = 100;
COMMIT;

--- В первой сессии выведем таблицу accounts
SELECT * FROM accounts;

-- Данные будут

--

--- Создадим функции для перевода денег с одного счета на другой
CREATE OR REPLACE FUNCTION transfer_money(
    p_from_acc int,
    p_to_acc int,
    p_amount money
) 
RETURNS void AS $$ 
BEGIN
    UPDATE
        accounts
    SET
        balance = balance - p_amount
    WHERE
        id = p_from_acc;

    UPDATE
        accounts
    SET
        balance = balance + p_amount
    WHERE
        id = p_to_acc;

    INSERT INTO
        transactions (account_id, amount)
    VALUES
        (p_from_acc, -1 * p_amount),
        (p_to_acc, p_amount);
END;
$$ LANGUAGE plpgsql;

--- Создадим два аккаунта
INSERT INTO
    accounts (id, name, balance)
VALUES
    (10, 'Alice', 100),
    (11, 'Bob', 50);

--- Переведем 10 долларов с аккаунта Алисы на аккаунт Боба двумя паралельными транзакиями с уровнем изоляции SERIALIZABLE.
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT transfer_money(10, 11, money(80)); -- 80 + 80 > 100

--- Попытаемся применить изменения в обеих транзакциях
COMMIT;

--

--- Дропнем таблицу в транзакции
BEGIN;
DROP TABLE accounts CASCADE;

--- Убедимся, что таблица была удалена
SELECT table_name FROM information_schema.tables
WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
AND table_schema IN('public', 'myschema');

--- Откатим транзакцию
ROLLBACK;

--- Убедимся, что таблица не была удалена
SELECT * FROM accounts;