\c pet_db

---------------------------------------------------------------
-- Напишите оператор, добавляющий пометку (s) в начало комментария по каждому заказу, 
-- исполнитель которого -- студент. Выполните этот оператор.
---------------------------------------------------------------

UPDATE order1
SET comments = CONCAT('(s)', comments)
WHERE comments <> ''
AND employee_id IN (
    SELECT employee_id
    FROM employee
    WHERE spec = 'student'
);

SELECT spec, comments
FROM order1, employee
WHERE order1.employee_id = employee.employee_id;

/*
UPDATE 1
    spec     |      comments
-------------+--------------------
 student     |
 hairdresser |
 hairdresser | That cat is crazy!
 student     |
 student     |
 hairdresser |
 student     |
 student     |
 student     |
 student     |
 student     |
 student     |
 student     |
 hairdresser |
 student     |
 student     |
 student     |
 student     |
 boss        |
 boss        |
 boss        |
 hairdresser |
 student     | (s)Comming late
(23 rows)
*/

---------------------------------------------------------------
-- Напишите оператор, удаляющий все заказы по combing-у,
-- которые еще не выполнены (Мы приостанавливаем оказание этой услугу из-за не продления лицензии).
---------------------------------------------------------------

DELETE 
FROM order1
WHERE is_done = 0 
AND service_id in (
    SELECT service_id
    FROM service
    WHERE name = 'Combing'
);

/*
DELETE 2
*/

---------------------------------------------------------------
-- Напишите оператор, добавляющий в таблицу PERSON новое физическое лицо 
-- с сохранением последовательной нумерации записей (используйте вложенный select с max(…) + 1).      
---------------------------------------------------------------

INSERT INTO person(person_id, last_name, first_name, phone, address)
VALUES (
    (SELECT MAX(person_id) + 1 FROM person),
    'Mellstroy',
    'Schavel',
    '+88005553535',
    'Brazil, Nhauhuj'
);

SELECT *
FROM person
WHERE person_id in (
    SELECT MAX(person_id)
    FROM person
);

/*
 person_id | last_name | first_name |    phone     |     address
-----------+-----------+------------+--------------+-----------------
        11 | Mellstroy | Schavel    | +88005553535 | Brazil, Nhauhuj
(1 row)
*/

---------------------------------------------------------------
-- Создайте в базе новую таблицу для хранения данных о документах физ.лиц (вид и номер документа).
-- При создании связи от нее к таблице PERSON укажите свойства каскадности редактирования и удаления.
---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Document (
    Document_ID SERIAL,
    person_id INT NOT NULL,
    Document_Type VARCHAR(25) NOT NULL,
    Document_Number VARCHAR(25) NOT NULL,
    CONSTRAINT Document_PK PRIMARY KEY (Document_ID)
);

ALTER TABLE
    Document
    ADD
        CONSTRAINT FK_Document_Person FOREIGN KEY (person_id) REFERENCES person (person_id)
            ON UPDATE CASCADE 
            ON DELETE CASCADE
    ;

---------------------------------------------------------------
-- Добавьте в нее пару документов для только что созданного нового физ.лица. 
---------------------------------------------------------------

INSERT INTO Document (person_id, Document_Type, Document_Number)
VALUES ((SELECT MAX(person_id) FROM person), 'Passport', '85738538'),
       ((SELECT MAX(person_id) FROM person), 'VoditelskiePrava', '58454785');

---------------------------------------------------------------
-- Проверка каскадности на изменение person_id
---------------------------------------------------------------

UPDATE person
SET person_id = 52
WHERE last_name = 'Mellstroy';

SELECT *
FROM person
WHERE person_id = 52;

SELECT last_name, Document_Type, Document_Number
FROM person 
    JOIN Document ON person.person_id = Document.person_id
WHERe last_name = 'Mellstroy';

/*
UPDATE 1

 person_id | last_name | first_name |    phone     |     address
-----------+-----------+------------+--------------+-----------------
        52 | Mellstroy | Schavel    | +88005553535 | Brazil, Nhauhuj
(1 row)

 last_name |  document_type   | document_number
-----------+------------------+-----------------
 Mellstroy | Passport         | 85738538
 Mellstroy | VoditelskiePrava | 58454785
(2 rows)
*/

---------------------------------------------------------------
-- Проверка каскадности на удаление
---------------------------------------------------------------

DELETE
FROM person
WHERE last_name = 'Mellstroy';

SELECT * FROM Document;

/*
DELETE 1
 document_id | person_id | document_type | document_number
-------------+-----------+---------------+-----------------
(0 rows)
*/