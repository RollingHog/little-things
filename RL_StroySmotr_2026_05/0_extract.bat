@REM only extract data from CSV and remove default answers
duckdb -init a_ans_to_json.sql -no-stdin 
node c_parse_extracted.node.js

duckdb -c "SELECT improve_things, bad_things FROM read_json('d_default_excluded.jsonl') WHERE improve_things NOT NULL OR bad_things NOT NULL" -no-stdin 