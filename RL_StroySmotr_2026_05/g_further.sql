CREATE TABLE default_excluded AS FROM read_json('d_default_excluded.jsonl');

SELECT improve_things FROM default_excluded WHERE improve_things NOT NULL;
SELECT bad_things FROM default_excluded WHERE bad_things NOT NULL;
--  EXCLUDE (happy_things, time_mark) bad_things 

-- CREATE TEMPORARY TABLE standard_bad (
--     opt_id INTEGER,
--     opt_name VARCHAR
-- );
-- INSERT INTO standard_bad VALUES
--     (1, 'Дорогая еда в кабаке'),
--     (2, 'Долгое ожидание в мертвяке (при массовых смертях)'),
--     (3, 'Детям не хватило контента'),
--     (4, 'Плохо игралась политика'),
--     (5, 'Не было денег'),
--     (6, 'Непонятно у кого брать квесты'),
--     (7, 'Не дошли стартовые деньги'),
--     (8, 'Квкстовые предметы не доходили до тех до кого надо');

-- CREATE TEMPORARY TABLE standard_improve (
--     opt_id INTEGER,
--     opt_name VARCHAR
-- );
-- INSERT INTO standard_improve VALUES
--     (1, 'Азартные игры' ),
--     (2, 'Арена для боёв один на один'),
--     (3, 'Построение в начале игры с повтором основных правил'),
--     (4, 'Больше квестов чисто для заработка, без привязки к фракции'),
--     (5, 'Игровая возможность "закрыть" здание на замок (напр. чтобы живая стража сходила пообедать)'),
--     (6, 'Проработка законов, возможно суд'),
--     (7, 'Облегчить поиск квестодателей'),
--     (8, '"Серийный" (сквозной, связанный) сюжет на несколько игр');

-- CREATE TEMPORARY TABLE all_exploded AS
--     SELECT 
--         time_mark, 
--         experience_level, 
--         'bad_things' as question_type, 
--         (val) as answer
--     FROM raw_responses, UNNEST(SPLIT(bad_things, ',')) AS val

--     UNION ALL
--     SELECT 
--         time_mark, 
--         experience_level, 
--         'improve_things' as question_type, 
--         (val) as answer
--     FROM raw_responses, UNNEST(SPLIT(improve_things, ',')) AS val;

--

-- CREATE TEMPORARY TABLE all_answers_normalized AS
-- SELECT 
--     r.time_mark,
--     r.experience_level,
--     'improve_things' as question_type,
--     TRIM(t.val) as answer_text,
--     -- Подтягиваем ID из справочника
--     COALESCE(
--         (SELECT s.opt_id FROM standard_improve s WHERE TRIM(s.opt_name) = TRIM(t.val)),
--         0 -- Или NULL, если ответа нет в справочнике
--     ) as opt_id
-- FROM raw_responses r,
-- UNNEST(SPLIT(r.improve_things, ',')) AS t(val)
-- WHERE TRIM(t.val) != ''

-- UNION ALL

-- SELECT 
--     r.time_mark,
--     r.experience_level,
--     'bad_things' as question_type,
--     TRIM(t.val) as answer_text,
--     COALESCE(
--         (SELECT s.opt_id FROM standard_bad s WHERE TRIM(s.opt_name) = TRIM(t.val)),
--         0
--     ) as opt_id
-- FROM raw_responses r,
-- UNNEST(SPLIT(r.bad_things, ',')) AS t(val)
-- WHERE TRIM(t.val) != '';

-- SELECT * FROM all_answers_normalized;

-- SELECT time_mark, STRING_AGG(answer, '; ') FROM all_exploded GROUP BY time_mark, experience_level, question_type;

--  SELECT time_mark,faction,experience_level,bad_things,improve_things FROM raw_responses LIMIT 13;


-- 3. Разделение строки на отдельные ответы (Unpivot)
-- exploded_responses AS (
--   SELECT
--     time_mark,
--     experience_level,
--     option_name -- Убираем пробелы после запятых
--   FROM raw_responses,
--   UNNEST(SPLIT(bad_things, ',')) AS option_name
-- )
-- 2. Разворачиваем каждую колонку отдельно и добавляем метку типа вопроса
-- exploded_happy AS (
--   SELECT time_mark, experience_level, 'happy_things' as question_type, TRIM(val) as answer
--   FROM raw_responses, UNNEST(SPLIT(happy_things, ',')) AS val
-- ),
-- exploded_bad AS (
--   SELECT time_mark, experience_level, 'bad_things' as question_type, TRIM(val) as answer
--   FROM raw_responses, UNNEST(SPLIT(bad_things, ',')) AS val
-- ),
-- exploded_improve AS (
--   SELECT time_mark, experience_level, 'improve_things' as question_type, TRIM(val) as answer
--   FROM raw_responses, UNNEST(SPLIT(improve_things, ',')) AS val
-- ),
-- -- 3. Объединяем всё в одну кучу
-- all_answers AS (
--   SELECT * FROM exploded_happy
--   UNION ALL
--   SELECT * FROM exploded_bad
--   UNION ALL
--   SELECT * FROM exploded_improve
-- )