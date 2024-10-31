\c pet_db 

---------------------------------------------------------------
-- Создайте представление Собаки со следующими атрибутами:
-- Кличка, порода, возраст, фамилия и имя хозяина.
-- Используя это представление, получите список пуделей: кличка, фамилия хозяина.
---------------------------------------------------------------
CREATE VIEW Dogs AS
    SELECT Nick, Breed, Age, Last_Name, First_Name
    FROM Pet
        JOIN Owner ON Owner.Owner_ID = Pet.Owner_ID
        JOIN Person ON Person.Person_ID = Owner.Owner_ID
        JOIN Pet_Type ON Pet.Pet_Type_ID = Pet_Type.Pet_Type_ID
    WHERE Pet_Type.Name = 'DOG';

SELECT Nick, Last_Name
FROM Dogs
WHERE Breed = 'poodle';

/*
  nick   | last_name
---------+-----------
 Apelsin | Petrov
 Markiz  | Galkina
*/

---------------------------------------------------------------
-- Создайте представление Рейтинг сотрудников: фамилия, имя, количество выполненных заказов,
-- средний балл (по оценке).
-- Используя это представление, выведите рейтинг с сортировкой по убыванию балла.
---------------------------------------------------------------

CREATE VIEW Employee_Rating AS
SELECT Last_Name, First_Name, COUNT(*) AS orders_count, AVG(Mark) AS avg_mark
FROM Order1
    JOIN Employee on Employee.Employee_ID = Order1.Employee_ID
    JOIN Person ON Person.Person_ID = Employee.Person_ID
WHERE Order1.Is_Done = 1
GROUP BY Last_Name, First_Name;

SELECT *
FROM Employee_Rating
ORDER BY avg_mark DESC;

/*
 last_name | first_name | orders_count |      avg_mark
-----------+------------+--------------+--------------------
 Ivanov    | Vania      |            1 | 5.0000000000000000
 Orlov     | Oleg       |            3 | 4.3333333333333333
 Vorobiev  | Vova       |           11 | 4.2727272727272727
(3 rows)
*/

---------------------------------------------------------------
-- Создайте представление Заказчики: 
-- Фамилия, имя, телефон, адрес. 
-- Используя это представление, напишите оператор, после выполнения которого у всех заказчиков без адреса в это поле добавится вопросительный знак.
---------------------------------------------------------------

CREATE VIEW Customers AS
SELECT DISTINCT Last_Name, First_Name, Phone, Address
FROM Person
    JOIN Owner ON Owner.Person_ID = Person.Person_ID
    JOIN Order1 ON Order1.Owner_ID = Owner.Owner_ID;

SELECT * FROM Customers;


/*
 last_name | first_name |    phone     |       address
-----------+------------+--------------+----------------------
 Sokolov   | S.         | +7678901234  | Srednii pr VO, 27-1
 Ivanov    | Vano       | +7789012345  | Malyi pr VO, 33-2
 Vasiliev  | Vasia      | +7345678901  | Nevskii pr, 9-11
 Petrov    | Petia      | +79234567890 | Sadovaia ul, 17\2-23
 Galkina   | Galia      | +7567890123  | 10 linia VO, 35-26
(5 rows)
*/

/*
Так как все с адресами, уберем какой-нибудь адрес
В PostgreSQL нельзя писать UPDATE на VIEW, состоящие из нескольких таблиц
ERROR:  cannot update view "customers"
DETAIL:  Views that do not select from a single table or view are not automatically updatable.
*/

UPDATE Person
SET Address = ''
WHERE Address = 'Nevskii pr, 9-11';

SELECT * FROM Customers;


/*
 last_name | first_name |    phone     |       address
-----------+------------+--------------+----------------------
 Vasiliev  | Vasia      | +7345678901  |
 Sokolov   | S.         | +7678901234  | Srednii pr VO, 27-1
 Ivanov    | Vano       | +7789012345  | Malyi pr VO, 33-2
 Petrov    | Petia      | +79234567890 | Sadovaia ul, 17\2-23
 Galkina   | Galia      | +7567890123  | 10 linia VO, 35-26
(5 rows)
*/

/*
Напишем UPDATE через EXISTS
*/

UPDATE Person
SET Address = '?'
WHERE EXISTS (
    SELECT *
    FROM Customers
    WHERE Customers.Last_Name = Person.Last_Name
        AND Customers.First_Name = Person.First_Name
        AND Customers.Phone = Person.Phone
        AND Customers.Address = Person.Address
        AND Customers.Address = ''
);

SELECT * FROM Customers;

/*
 last_name | first_name |    phone     |       address
-----------+------------+--------------+----------------------
 Vasiliev  | Vasia      | +7345678901  | ?
 Sokolov   | S.         | +7678901234  | Srednii pr VO, 27-1
 Ivanov    | Vano       | +7789012345  | Malyi pr VO, 33-2
 Petrov    | Petia      | +79234567890 | Sadovaia ul, 17\2-23
 Galkina   | Galia      | +7567890123  | 10 linia VO, 35-26
(5 rows)
*/

SELECT * FROM Person;

/*
 person_id | last_name | first_name |    phone     |         address
-----------+-----------+------------+--------------+--------------------------
         1 | Ivanov    | Vania      | +79123456789 | Srednii pr VO, 34-2
         2 | Petrov    | Petia      | +79234567890 | Sadovaia ul, 17\2-23
         4 | Orlov     | Oleg       | +7456789012  | 5 linia VO, 45-8
         5 | Galkina   | Galia      | +7567890123  | 10 linia VO, 35-26
         6 | Sokolov   | S.         | +7678901234  | Srednii pr VO, 27-1
         7 | Vorobiev  | Vova       | 123-45-67    | Universitetskaia nab, 17
         8 | Ivanov    | Vano       | +7789012345  | Malyi pr VO, 33-2
         9 | Sokolova  | Sveta      | 234-56-78    |
        10 | Zotov     | Misha      | 111-56-22    |
         3 | Vasiliev  | Vasia      | +7345678901  | ?
(10 rows)
*/

/*
Адреса у людей не из Customers остались пустыми
*/