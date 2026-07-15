CREATE TABLE default_excluded AS FROM read_json('e_hand_edit.jsonl');

SELECT happy_things FROM default_excluded WHERE happy_things NOT NULL;
SELECT improve_things FROM default_excluded WHERE improve_things NOT NULL;
SELECT bad_things FROM default_excluded WHERE bad_things NOT NULL;



-- SELECT faction, COUNT(faction) FROM default_excluded WHERE contains(default_bad_ids,1) GROUP BY faction;
