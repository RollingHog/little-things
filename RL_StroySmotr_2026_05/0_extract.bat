@REM only extract data from CSV and remove default answers
duckdb -init a_ans_to_json.sql -no-stdin 
node c_parse_extracted.node.js