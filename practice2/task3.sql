--- Создадим таблицу «t» с полями: id, name (с параметром filfactor = 75%).
CREATE TABLE t (
    id INT,
    name VARCHAR(2000)
) WITH (FILLFACTOR = 75);

--- Создадим индекс над полем t(name).
CREATE INDEX t_name_idx ON t (name);

--- Создадим представление, которое будет включать в себя информацию о версиях строк
CREATE VIEW t_v AS
SELECT '(0,'||lp||')' AS ctid,
       CASE lp_flags
         WHEN 0 THEN 'unused'
         WHEN 1 THEN 'normal'
         WHEN 2 THEN 'redirect to '||lp_off
         WHEN 3 THEN 'dead'
       END AS state,
       t_xmin || CASE
         WHEN (t_infomask & 256) > 0 THEN ' (c)'
         WHEN (t_infomask & 512) > 0 THEN ' (a)'
         ELSE ''
       END AS xmin,
       t_xmax || CASE
         WHEN (t_infomask & 1024) > 0 THEN ' (c)'
         WHEN (t_infomask & 2048) > 0 THEN ' (a)'
         ELSE ''
       END AS xmax,
       CASE WHEN (t_infomask2 & 16384) > 0 THEN 't' END AS hhu,
       CASE WHEN (t_infomask2 & 32768) > 0 THEN 't' END AS hot,
       t_ctid
FROM heap_page_items(get_raw_page('t',0))
ORDER BY lp;

--- Спроецируем ситуацию в таблице «t», при которой произойдет внутри страничная очистка без участия HOT-обновлений
INSERT INTO t (id, name) VALUES (1, '1111111111111111111111111111');

--- После воспроизведем ситуацию, но уже с HOT-обновлением.
UPDATE t SET id=2 WHERE id=1;

--- Посмотрим, что получилось.
SELECT * FROM t_v;
