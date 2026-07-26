CREATE TABLE default_excluded AS FROM read_json('e_hand_edit.jsonl');

CREATE TABLE bad_digit_names (
    digit INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);
INSERT INTO bad_digit_names (digit, name) VALUES
      (1, 'Дорогая еда в кабаке'),
      (2, 'Долгое ожидание в мертвяке (при массовых смертях)'),
      (3, 'Детям не хватило контента'),
      (4, 'Плохо игралась политика'),
      (5, 'Не было денег'),
      (6, 'Непонятно у кого брать квесты'),
      (7, 'Не дошли стартовые деньги'),
      (8, 'Квкстовые предметы не доходили до тех до кого надо'),
      (9, 'Мало монстры или Боевикам не с кем воевать'),
      (10, 'Я не понял что делать');


CREATE TABLE improve_digit_names (
    digit INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);
INSERT INTO improve_digit_names (digit, name) VALUES
    (1, 'Азартные игры' ),
    (2, 'Арена для боёв один на один'),
    (3, 'Построение в начале игры с повтором основных правил'),
    (4, 'Больше квестов чисто для заработка, без привязки к фракции'),
    (5, 'Игровая возможность "закрыть" здание на замок (напр. чтобы живая стража сходила пообедать)'),
    (6, 'Проработка законов, возможно суд'),
    (7, 'Облегчить поиск квестодателей'),
    (8, '"Серийный" (сквозной, связанный) сюжет на несколько игр');

-- -- summary for all experiences
-- WITH all_data AS (
--     SELECT 
--         experience,
--         UNNEST(default_bad_ids) AS digit
--     FROM default_excluded
-- )
-- SELECT 
--     dn.name as digit_name,
--     COUNT(*) as count,
-- FROM all_data a
-- JOIN bad_digit_names dn ON a.digit = dn.digit
-- GROUP BY dn.name, a.digit
-- ORDER BY count DESC;

-- percents for each experience with decoded digits
WITH all_data AS (
    SELECT 
        experience,
        UNNEST(default_bad_ids) AS digit
    FROM default_excluded
)
SELECT 
    a.experience,
    dn.name as digit_name,
    -- a.digit,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY a.experience), 2) as percentage_in_field
FROM all_data a
JOIN bad_digit_names dn ON a.digit = dn.digit
GROUP BY a.experience, dn.name, a.digit
ORDER BY a.experience, count DESC;

-- select faction, bad_things from default_excluded where bad_things IS NOT NULL;
-- select faction, improve_things from default_excluded where improve_things IS NOT NULL;