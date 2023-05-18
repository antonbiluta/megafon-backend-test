CREATE TABLE servers (
  srv_id NUMBER PRIMARY KEY,
  srv_name VARCHAR2(255) NOT NULL
);

CREATE TABLE server_hdd (
  hdd_id NUMBER PRIMARY KEY,
  srv_id NUMBER NOT NULL,
  hdd_name VARCHAR2(255) NOT NULL,
  hdd_capacity NUMBER NOT NULL,
  CONSTRAINT fk_srv_id FOREIGN KEY (srv_id) REFERENCES servers(srv_id)
);

CREATE TABLE hdd_monitoring (
  hdd_id NUMBER NOT NULL,
  used_space NUMBER NOT NULL,
  formatted_space NUMBER NOT NULL,
  monitoring_date DATE NOT NULL,
  CONSTRAINT fk_hdd_id FOREIGN KEY (hdd_id) REFERENCES server_hdd(hdd_id)
);

INSERT INTO servers (srv_id, srv_name) VALUES (1, 'Server 1');
INSERT INTO servers (srv_id, srv_name) VALUES (2, 'Server 2');
INSERT INTO servers (srv_id, srv_name) VALUES (3, 'Server 3');

INSERT INTO server_hdd (hdd_id, srv_id, hdd_name, hdd_capacity) VALUES (1, 1, 'HDD 1', 60000);
INSERT INTO server_hdd (hdd_id, srv_id, hdd_name, hdd_capacity) VALUES (2, 1, 'HDD 2', 80000);
INSERT INTO server_hdd (hdd_id, srv_id, hdd_name, hdd_capacity) VALUES (3, 2, 'HDD 3', 120000);
INSERT INTO server_hdd (hdd_id, srv_id, hdd_name, hdd_capacity) VALUES (4, 3, 'HDD 4', 150000);

INSERT INTO hdd_monitoring (hdd_id, used_space, formatted_space, monitoring_date) VALUES (1, 30000, 55000, TO_DATE('2023-05-01', 'YYYY-MM-DD'));
INSERT INTO hdd_monitoring (hdd_id, used_space, formatted_space, monitoring_date) VALUES (2, 40000, 75000, TO_DATE('2023-05-01', 'YYYY-MM-DD'));
INSERT INTO hdd_monitoring (hdd_id, used_space, formatted_space, monitoring_date) VALUES (3, 60000, 110000, TO_DATE('2023-05-01', 'YYYY-MM-DD'));
INSERT INTO hdd_monitoring (hdd_id, used_space, formatted_space, monitoring_date) VALUES (4, 90000, 130000, TO_DATE('2023-05-01', 'YYYY-MM-DD'));
UPDATE hdd_monitoring SET used_space = 35000, formatted_space = 55000, monitoring_date = TO_DATE('2023-05-10', 'YYYY-MM-DD') WHERE hdd_id = 1;



-- a
SELECT s.srv_id, s.srv_name, SUM(sh.hdd_capacity) AS total_capacity
FROM servers s
JOIN server_hdd sh ON s.srv_id = sh.srv_id
GROUP BY s.srv_id, s.srv_name
HAVING SUM(sh.hdd_capacity) BETWEEN 110000 AND 130000;

-- b
DELETE FROM server_hdd
WHERE ROWID NOT IN (
  SELECT MIN(ROWID)
  FROM server_hdd
  GROUP BY hdd_id, srv_id, hdd_name, hdd_capacity
);

-- c
CREATE UNIQUE INDEX idx_unique_server_hdd ON server_hdd(hdd_id, srv_id, hdd_name, hdd_capacity);

-- d
SELECT 
  s.srv_name, 
  sh.hdd_name, 
  sh.hdd_capacity,
  LAG(hm.used_space) OVER (PARTITION BY hm.hdd_id ORDER BY hm.monitoring_date) AS prev_used_space,
  hm.used_space,
  hm.monitoring_date
FROM 
  servers s
  JOIN server_hdd sh ON s.srv_id = sh.srv_id
  JOIN hdd_monitoring hm ON sh.hdd_id = hm.hdd_id
  JOIN (
    SELECT hdd_id, MAX(hdd_capacity) AS max_capacity
    FROM server_hdd
    GROUP BY srv_id
  ) msh ON sh.hdd_id = msh.hdd_id AND sh.hdd_capacity = msh.max_capacity
WHERE 
  ROW_NUMBER() OVER (PARTITION BY hm.hdd_id ORDER BY hm.monitoring_date DESC) <= 10;

