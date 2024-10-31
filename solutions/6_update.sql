\c pet_db

---------------------------------------------------------------
-- Напишите оператор, добавляющий пометку (s) в начало комментария по каждому заказу, 
-- исполнитель которого -- студент. Выполните этот оператор.
---------------------------------------------------------------

UPDATE Order1
SET Comments = CONCAT('(s) ', Comments)
WHERE Employee_ID IN (
    SELECT Employee_ID
    FROM Employee
    WHERE Spec = 'student'
)
AND Comments <> '';

SELECT Spec, Comments
FROM Order1
    JOIN Employee ON Employee.Employee_ID = Order1.Employee_ID;

/*
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
 student     | (s) Comming late
(23 rows)
*/

---------------------------------------------------------------
-- Напишите оператор, удаляющий все заказы по combing-у,
-- которые еще не выполнены (Мы приостанавливаем оказание этой услугу из-за не продления лицензии).
---------------------------------------------------------------

DELETE 
FROM Order1
WHERE Service_ID in (
    SELECT Service_ID
    FROM Service
    WHERE Name = 'Combing'
)
AND Is_Done = 0;

/*
DELETE 2
*/

---------------------------------------------------------------
-- Напишите оператор, добавляющий в таблицу PERSON новое физическое лицо 
-- с сохранением последовательной нумерации записей (используйте вложенный select с max(…) + 1).      
---------------------------------------------------------------

INSERT INTO Person(Person_ID, Last_Name, First_Name, Phone, Address)
VALUES (
    (SELECT MAX(Person_ID) + 1 FROM Person),
    'Hookovich',
    'Pudje',
    '+77777777777',
    'Centralniy Koridor'
);

SELECT *
FROM Person
WHERE Person_ID in (
    SELECT MAX(Person_ID)
    FROM Person
);

/*
 person_id | last_name | first_name |    phone     |      address
-----------+-----------+------------+--------------+--------------------
        11 | Pudje     | Hookovich  | +77777777777 | Centralniy Koridor
(1 row)
*/

---------------------------------------------------------------
-- Создайте в базе новую таблицу для хранения данных о документах физ.лиц (вид и номер документа).
-- При создании связи от нее к таблице PERSON укажите свойства каскадности редактирования и удаления.
---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Document (
    Document_ID SERIAL,
    Person_ID INT NOT NULL,
    Document_Type VARCHAR(25) NOT NULL,
    Document_Number VARCHAR(25) NOT NULL,
    CONSTRAINT Document_PK PRIMARY KEY (Document_ID),
    CONSTRAINT FK_Document_Person FOREIGN KEY (Person_ID) REFERENCES Person (Person_ID)
        ON UPDATE CASCADE 
        ON DELETE CASCADE
);

---------------------------------------------------------------
-- Добавьте в нее пару документов для только что созданного нового физ.лица. 
---------------------------------------------------------------

INSERT INTO Document (Person_ID, Document_Type, Document_Number)
VALUES ((SELECT MAX(Person_ID) FROM Person), 'Passport', '123456'),
       ((SELECT MAX(Person_ID) FROM Person), 'SNILS', '7891011'),
       ((SELECT MAX(Person_ID) FROM Person), 'MeatHookLicense', '12131415');

---------------------------------------------------------------
-- Проверка каскадности на изменение Person_ID
---------------------------------------------------------------

UPDATE Person
SET Person_ID = 12345
WHERE Last_Name = 'Hookovich';

SELECT Last_Name, Document_Type, Document_Number
FROM Person 
    JOIN Document ON Person.Person_ID = Document.Person_ID
WHERe Last_Name = 'Hookovich';

/*
 last_name |  document_type  | document_number
-----------+-----------------+-----------------
 Hookovich | Passport        | 123456
 Hookovich | SNILS           | 7891011
 Hookovich | MeatHookLicense | 12131415
(3 rows)
*/

---------------------------------------------------------------
-- Проверка каскадности на удаление
---------------------------------------------------------------

DELETE
FROM Person
WHERE Last_Name = 'Hookovich';

SELECT * FROM Document;

/*
 document_id | person_id | document_type | document_number
-------------+-----------+---------------+-----------------
(0 rows)
*/