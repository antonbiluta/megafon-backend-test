CREATE TABLE servers (
    srv_id SERIAL PRIMARY KEY,
    srv_name VARCHAR(255) NOT NULL
);

CREATE TABLE server_hdd (
    hdd_id SERIAL PRIMARY KEY,
    srv_id INTEGER NOT NULL,
    hdd_name VARCHAR(255) NOT NULL,
    hdd_capacity BIGINT NOT NULL,
    FOREIGN KEY (srv_id) REFERENCES servers(srv_id)
);

CREATE TABLE hdd_monitoring (
    hdd_id INTEGER NOT NULL,
    used_space BIGINT NOT NULL,
    formatted_space BIGINT NOT NULL,
    monitoring_date DATE NOT NULL,
    FOREIGN KEY (hdd_id) REFERENCES server_hdd(hdd_id)
);

INSERT INTO servers (srv_name) VALUES ('Server 1'), ('Server 2'), ('Server 3');

INSERT INTO server_hdd (srv_id, hdd_name, hdd_capacity) 
VALUES 
  (1, 'HDD 1', 60000),
  (1, 'HDD 2', 80000),
  (2, 'HDD 3', 120000),
  (3, 'HDD 4', 150000);

INSERT INTO hdd_monitoring (hdd_id, used_space, formatted_space, monitoring_date) 
VALUES 
  (1, 30000, 55000, '2023-05-01'),
  (1, 35000, 55000, '2023-05-10'),
  (2, 40000, 75000, '2023-05-01'),
  (2, 50000, 75000, '2023-05-10'),
  (3, 60000, 110000, '2023-05-01'),
  (3, 80000, 110000, '2023-05-10'),
  (4, 90000, 130000, '2023-05-01'),
  (4, 100000, 130000, '2023-05-10');

-- a
SELECT s.srv_name 
FROM servers s
JOIN server_hdd sh ON s.srv_id = sh.srv_id
GROUP BY s.srv_name
HAVING SUM(sh.hdd_capacity) BETWEEN 110000 AND 130000;

-- b
DELETE FROM server_hdd 
WHERE hdd_id IN (
  SELECT hdd_id 
  FROM (
    SELECT hdd_id, 
           ROW_NUMBER() OVER (PARTITION BY srv_id, hdd_name, hdd_capacity ORDER BY hdd_id) AS rn
    FROM server_hdd
  ) t 
  WHERE t.rn > 1
);

-- c
CREATE UNIQUE INDEX idx_server_hdd_unique ON server_hdd(srv_id, hdd_name, hdd_capacity);

-- d
SELECT 
  "Имя сервера", 
  "Имя диска", 
  "Общая емкость диска", 
  "Предыдущая занятая емкость", 
  "Текущая занятая емкость диска", 
  "Дата мониторинга"
FROM (
  SELECT 
    s.srv_name AS "Имя сервера", 
    sh.hdd_name AS "Имя диска", 
    sh.hdd_capacity AS "Общая емкость диска", 
    LAG(hm.used_space) OVER (PARTITION BY hm.hdd_id ORDER BY hm.monitoring_date) AS "Предыдущая занятая емкость",
    hm.used_space AS "Текущая занятая емкость диска",
    TO_CHAR(hm.monitoring_date, 'DD.MM.YYYY') AS "Дата мониторинга",
    ROW_NUMBER() OVER (PARTITION BY hm.hdd_id ORDER BY hm.monitoring_date DESC) AS rn
  FROM 
    servers s
    JOIN server_hdd sh ON s.srv_id = sh.srv_id
    JOIN hdd_monitoring hm ON sh.hdd_id = hm.hdd_id
    JOIN (
      SELECT srv_id, MAX(hdd_capacity) AS max_capacity
      FROM server_hdd
      GROUP BY srv_id
    ) msh ON sh.srv_id = msh.srv_id AND sh.hdd_capacity = msh.max_capacity
) t
WHERE 
  rn <= 10;
