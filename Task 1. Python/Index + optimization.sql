SET search_path TO public;


-- Table Rooms
CREATE TABLE rooms (id int NOT NULL,
"name" VARCHAR,
CONSTRAINT rooms_id PRIMARY KEY (id));

\COPY rooms_json FROM 'C:\Users\master\Downloads\rooms_single_string.json';

INSERT
	INTO
	rooms (id,
	name)
SELECT
	p.*
FROM
	rooms_json
CROSS JOIN LATERAL json_populate_recordset(NULL::rooms, doc) AS p
ON
	CONFLICT (id) DO
UPDATE
SET
	name = excluded.name;


-- Table Students
CREATE TABLE students (birthday TIMESTAMP,
id int NOT NULL,
"name" VARCHAR,
room int NOT NULL,
sex VARCHAR,
CONSTRAINT students_id PRIMARY KEY (id),
CONSTRAINT rooms_id FOREIGN KEY (room) REFERENCES rooms(id),
CONSTRAINT sex_check CHECK (sex = 'F' OR sex = 'M'));

CREATE UNLOGGED TABLE students_json (doc json);

\COPY students_json FROM 'C:\Users\master\Downloads\students_single_string.json';

INSERT
	INTO
	students (birthday,
	id,
	name,
	room,
	sex)
SELECT
	p.*
FROM
	students_json
CROSS JOIN LATERAL json_populate_recordset(NULL::students, doc) AS p
ON
	CONFLICT (id) DO
UPDATE
SET
	birthday = excluded.birthday,
	name = excluded.name,
	room = excluded.room,
	sex = excluded.sex;


-- Cписок комнат и количество студентов в каждой из них
SELECT
	r.name AS room_name,
	count(s.id) AS num_of_students
FROM
	rooms r
LEFT JOIN students s 
ON
	r.id = s.room
GROUP BY
	r.name
ORDER BY r.name ASC;


-- Top 5 комнат, где самый маленький средний возраст студентов
SELECT
	room,
	AVG(AGE(current_date, birthday)) AS age
FROM
	rooms r
LEFT JOIN students s 
ON
	r.id = s.room
GROUP BY
	room
ORDER BY
	age ASC 
FETCH FIRST 5 ROWS WITH TIES ;


-- Top 5 комнат с самой большой разницей в возрасте студентов
SELECT
	r.name,
	AGE(MAX(birthday), MIN(birthday)) AS age_dif
FROM
	rooms r
LEFT JOIN students s 
ON
	r.id = s.room
GROUP BY
	r.name
ORDER BY
	age_dif DESC 
FETCH FIRST 5 ROWS WITH TIES;

-- Список комнат где живут разнополые студенты
-- before indices GroupAggregate (cost=901.25..988.75 rows=333 width=9)
SELECT
	r.name
FROM
	rooms r
LEFT JOIN students s 
ON
	r.id = s.room
GROUP BY
	r.name
HAVING
	COUNT(DISTINCT sex) > 1;
-- after indices GroupAggregate (cost=0.56..1059.54 rows=333 width=9)


ANALYZE students;
ANALYZE rooms;


CREATE INDEX primary_id ON rooms USING btree(id);
CREATE INDEX foreign_id ON students USING btree(room);
CREATE INDEX order_name ON rooms USING btree(name);


DROP INDEX primary_id;
DROP INDEX foreign_id;
DROP INDEX order_name;


SET enable_seqscan = ON;
SET enable_seqscan = OFF;


COPY(
SELECT
	json_agg(row_to_json(t)) :: TEXT
FROM
	(
	SELECT
		r.name
	FROM
		rooms r
	LEFT JOIN students s 
	ON
		r.id = s.room
	GROUP BY
		r.name
	HAVING
		COUNT(DISTINCT sex) > 1
) t) TO 'C:\Users\master\Downloads\new.json';



