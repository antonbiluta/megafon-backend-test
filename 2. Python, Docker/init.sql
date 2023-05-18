CREATE TABLE IF NOT EXISTS test (
    id SERIAL PRIMARY KEY,
    data TEXT NOT NULL,
    date TIMESTAMP NOT NULL
);

-- CREATE OR REPLACE FUNCTION clean_data()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     IF (SELECT COUNT(*) FROM test) >= 30 THEN
--         DELETE FROM test;
--     END IF;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- CREATE TRIGGER clean_data_trigger
-- AFTER INSERT ON test
-- FOR EACH ROW EXECUTE PROCEDURE clean_data();