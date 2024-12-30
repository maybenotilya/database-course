\c pet_db

---------------------------------------------------------------
-- Данные на Партизана (включая вид животного). Без JOIN
---------------------------------------------------------------

SELECT Pet.Nick as Nick, Pet_Type.Name as Type
FROM Pet, Pet_Type
WHERE Pet.Nick = 'Partizan' and Pet.Pet_Type_ID = Pet_Type.Pet_Type_ID;

/*
   nick   | type
----------+------
 Partizan | CAT
(1 row)
*/

---------------------------------------------------------------
-- Список всех собак с кличками, породой и возрастом. С JOIN
---------------------------------------------------------------

SELECT Nick, Breed, Age
FROM Pet LEFT JOIN Pet_Type 
ON Pet.Pet_Type_ID = Pet_Type.Pet_Type_ID
WHERE Pet_Type.Name = 'DOG';

/*
  nick   |  breed  | age
---------+---------+-----
 Bobik   | unknown |   3
 Apelsin | poodle  |   5
 Daniel  | spaniel |  14
 Markiz  | poodle  |   1
(4 rows)
*/

---------------------------------------------------------------
-- Средний возраст кошек. Без JOIN
---------------------------------------------------------------

SELECT AVG(Pet.Age)
FROM Pet, Pet_Type
WHERE Pet_Type.Pet_Type_ID = Pet.Pet_Type_ID AND Pet_Type.Name = 'CAT';

/*
        avg
--------------------
 6.6000000000000000
(1 row)
*/

---------------------------------------------------------------
-- Время и исполнители невыполненных заказов. С JOIN
---------------------------------------------------------------

SELECT Time_Order, Last_Name
FROM Order1
JOIN Employee ON Employee.Employee_ID = Order1.Employee_ID
JOIN Person ON Person.Person_ID = Employee.Person_ID
WHERE Is_Done = 0;

/*
     time_order      | last_name
---------------------+-----------
 2023-09-19 18:00:00 | Orlov
 2023-09-20 10:00:00 | Vorobiev
 2023-09-20 11:00:00 | Vorobiev
 2023-09-22 10:00:00 | Vorobiev
 2023-09-23 10:00:00 | Vorobiev
 2023-10-01 11:00:00 | Ivanov
 2023-10-02 11:00:00 | Ivanov
 2023-10-03 16:00:00 | Orlov
(8 rows)
*/

---------------------------------------------------------------
-- Список хозяев собак (имя, фамилия, телефон). Без JOIN
---------------------------------------------------------------

SELECT Person.First_Name, Person.Last_Name, Person.Phone
FROM Person, Owner, Pet, Pet_Type
WHERE Pet_Type.Name = 'DOG' 
AND Pet.Pet_Type_ID = Pet_Type.Pet_Type_ID 
AND Pet.Owner_ID = Owner.Owner_ID
AND Person.Person_ID = Owner.Person_ID;

/*
 first_name | last_name |    phone
------------+-----------+--------------
 Petia      | Petrov    | +79234567890
 Vasia      | Vasiliev  | +7345678901
 Galia      | Galkina   | +7567890123
 Vano       | Ivanov    | +7789012345
(4 rows)
*/

---------------------------------------------------------------
-- Все виды питомцев и клички представителей этих видов (внешнее соединение).
---------------------------------------------------------------

SELECT Name, Nick
FROM Pet RIGHT JOIN Pet_Type
ON Pet.Pet_Type_ID = Pet_Type.Pet_Type_ID;

/*
 name |   nick
------+----------
 DOG  | Bobik
 CAT  | Musia
 CAT  | Katok
 DOG  | Apelsin
 CAT  | Partizan
 DOG  | Daniel
 COW  | Model
 DOG  | Markiz
 CAT  | Zombi
 CAT  | Las
 FISH |
(11 rows)
*/

---------------------------------------------------------------
-- Сколько имеется котов, собак и т.д. в возрасте 1 год, 2 года, и т.д. С JOIN
---------------------------------------------------------------

SELECT Age, Name, COUNT(*)
FROM Pet JOIN Pet_Type
ON Pet.Pet_Type_ID = Pet_Type.Pet_Type_ID
GROUP BY Age, Name
ORDER BY Age, Name;

/*
 age | name | count
-----+------+-------
   1 | DOG  |     1
   2 | CAT  |     1
   3 | DOG  |     1
   5 | CAT  |     1
   5 | COW  |     1
   5 | DOG  |     1
   7 | CAT  |     2
  12 | CAT  |     1
  14 | DOG  |     1
(9 rows)
*/

---------------------------------------------------------------
--  Фамилии сотрудников, выполнивших более трех заказов. С JOIN
---------------------------------------------------------------

SELECT Last_Name, COUNT(*) as Count_Of_Orders
FROM Order1 
JOIN Employee ON Order1.Employee_ID = Employee.Employee_ID
JOIN Person ON Employee.Person_ID = Person.Person_ID
WHERE Is_Done = 1
GROUP BY Last_Name
HAVING COUNT(*) > 3;

/*
 last_name | count_of_orders
-----------+-----------------
 Vorobiev  |              11
(1 row)
*/

---------------------------------------------------------------
--  Имена и фамилии владельцев и клички животных, которым сделали прививки KAB или KOKAB
---------------------------------------------------------------

SELECT First_Name, Last_Name, Nick
FROM Pet
JOIN Owner ON Pet.Owner_ID = Owner.Owner_ID
JOIN Person ON Owner.Person_ID = Person.Person_ID
JOIN Vaccination ON Vaccination.Pet_ID = Pet.Pet_ID
JOIN Vaccination_Type ON Vaccination.Vaccination_Type_ID = Vaccination_Type.Vaccination_Type_ID
WHERE Vaccination_Type.Name IN ('KAB', 'KOKAB');

/*
 first_name | last_name | nick
------------+-----------+-------
 Petia      | Petrov    | Bobik
 Petia      | Petrov    | Musia
(2 rows)
*/