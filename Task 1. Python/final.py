import json
import psycopg2

class DB():
    def __init__(self):
        self.conn = psycopg2.connect('dbname=postgres user=postgres password=Pass host=localhost')
        self.cur = self.conn.cursor()
        self.format = input('Please enter the format for the result files (xml or json): ')

    def insert_json(self):
        path_rooms = input('Please enter the path where file \'rooms.json\' is located: ');
        path_students = input('Please enter the path where file \'students.json\' is located: ');

        with open(path_rooms) as rooms_file:

            self.cur.execute(""" CREATE TABLE IF NOT EXISTS rooms (id int NOT NULL,
                        name VARCHAR,
                        CONSTRAINT rooms_id PRIMARY KEY (id))""")

            data = json.load(rooms_file)

            query_sql = """ insert into rooms
                        select * from json_populate_recordset(NULL::rooms, %s) """
            self.cur.execute(query_sql, (json.dumps(data),))
            self.conn.commit()

        with open(path_students) as students_file:

            self.cur.execute(""" CREATE TABLE IF NOT EXISTS students (birthday TIMESTAMP,
                        id int NOT NULL,
                        "name" VARCHAR,
                        room int NOT NULL,
                        sex VARCHAR,
                        CONSTRAINT students_id PRIMARY KEY (id),
                        CONSTRAINT rooms_id FOREIGN KEY (room) REFERENCES rooms(id),
                        CONSTRAINT sex_check CHECK (sex = 'F' OR sex = 'M'));""")

            data = json.load(students_file)

            query_sql = """ insert into students
                        select * from json_populate_recordset(NULL::students, %s) """
            self.cur.execute(query_sql, (json.dumps(data),))
            self.conn.commit()


    def query_1(self):
        query_sql = """
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
                            ORDER BY r.name ASC
                            """
        self.cur.execute(query_sql)
        data = self.cur.fetchall()

        if self.format.lower() == 'json':
            with open('C:\\Users\\master\\Downloads\\query_1.json', 'w') as query_1:
                json.dump(data, query_1)

        elif self.format.lower() == 'xml':
            with open('C:\\Users\\master\\Downloads\\query_1.xml', 'w') as query_1:
                query_1.write(str(data))
        else:
            print('You have entered the wrong format: ')


    def query_2(self):
        query_sql = """
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
                            """
        self.cur.execute(query_sql)
        data = self.cur.fetchall()

        if self.format.lower() == 'json':
            with open('C:\\Users\\master\\Downloads\\query_2.json', 'w') as query_2:
                query_2.write(json.dumps(data, indent=4, sort_keys=True, default=str))

        elif self.format.lower() == 'xml':
            with open('C:\\Users\\master\\Downloads\\query_2.xml', 'w') as query_2:
                query_2.write(str(data))
        else:
            print('You have entered the wrong format: ')


    def query_3(self):
        query_sql = """
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
                            FETCH FIRST 5 ROWS WITH TIES
                            """
        self.cur.execute(query_sql)
        data = self.cur.fetchall()

        if self.format.lower() == 'json':
            with open('C:\\Users\\master\\Downloads\\query_3.json', 'w') as query_3:
                query_3.write(json.dumps(data, indent=4, sort_keys=True, default=str))

        elif self.format.lower() == 'xml':
            with open('C:\\Users\\master\\Downloads\\query_3.xml', 'w') as query_3:
                query_3.write(str(data))
        else:
            print('You have entered the wrong format: ')


    def query_4(self):
        query_sql = """
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
                            """
        self.cur.execute(query_sql)
        data = self.cur.fetchall()

        if self.format.lower() == 'json':
            with open('C:\\Users\\master\\Downloads\\query_4.json', 'w') as query_4:
                query_4.write(json.dumps(data, indent=4, sort_keys=True, default=str))

        elif self.format.lower() == 'xml':
            with open('C:\\Users\\master\\Downloads\\query_4.xml', 'w') as query_4:
                query_4.write(str(data))
        else:
            print('You have entered the wrong format: ')

        self.conn.close()


db = DB()
db.insert_json()
db.query_1()
db.query_2()
db.query_3()
db.query_4()