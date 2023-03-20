-- Узнать текущий размер файла данных таблицы users
-- при помощи функции: pg_size_pretty(pg_table_size('название таблицы'))
SELECT pg_size_pretty(pg_table_size('users'));

-- Удалите 90% случайных строк 
-- (Случайность важна, чтобы в каждой странице остались какие-нибудь не удаленные строки)
DELETE FROM users WHERE id IN (
    SELECT id FROM users TABLESAMPLE BERNOULLI (90)
);

-- Выполните очистку
VACUUM;

-- Ещё раз узнайте текущий размер файла данных таблицы users
-- и сравните его с первым пунктом. Объясните результат
SELECT pg_size_pretty(pg_table_size('users'));

-- Выполните полную очистку
VACUUM FULL;

-- Ещё раз узнайте текущий размер файла данных таблицы users 
-- и сравните его с результатом пункта 5. Объясните результат.
SELECT pg_size_pretty(pg_table_size('users'));