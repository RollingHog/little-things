CREATE TABLE default_excluded AS FROM read_json('e_hand_edit.jsonl');

-- -- summary for all factions
-- SELECT 
--     -- faction,
--     bad_digit,
--     COUNT(*) as count
-- FROM default_excluded,
-- UNNEST(default_bad_ids) AS bad_digit
-- -- faction,
-- GROUP BY bad_digit
-- ORDER BY count DESC;

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

-- percents for each faction with decoded digits
WITH all_data AS (
    SELECT 
        faction,
        UNNEST(default_bad_ids) AS digit
    FROM default_excluded
)
SELECT 
    a.faction,
    dn.name as digit_name,
    -- a.digit,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY a.faction), 2) as percentage_in_field
FROM all_data a
JOIN bad_digit_names dn ON a.digit = dn.digit
GROUP BY a.faction, dn.name, a.digit
ORDER BY a.faction, count DESC;
