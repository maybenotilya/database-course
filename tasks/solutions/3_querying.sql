\c pet_db 

---------------------------------------------------------------
-- 1.  Данные на Партизана.
---------------------------------------------------------------

SELECT *
FROM Pet
WHERE Nick = 'Partizan';

/*
 pet_id |   nick   |  breed  | age | description | pet_type_id | owner_id
--------+----------+---------+-----+-------------+-------------+----------
      5 | Partizan | Siamese |   5 | very big    |           2 |        2
(1 row)
*/

---------------------------------------------------------------
-- 2.  Клички и породы всех питомцев с сортировкой по возрасту.
---------------------------------------------------------------

SELECT Nick, Breed, Age
FROM Pet 
ORDER BY Age;

/*
   nick   |  breed  | age
----------+---------+-----
 Markiz   | poodle  |   1
 Katok    |         |   2
 Bobik    | unknown |   3
 Model    |         |   5
 Apelsin  | poodle  |   5
 Partizan | Siamese |   5
 Las      | Siamese |   7
 Zombi    | unknown |   7
 Musia    |         |  12
 Daniel   | spaniel |  14
(10 rows)
*/

---------------------------------------------------------------
-- 3.  Питомцы, имеющие хоть какое-нибудь описание.
---------------------------------------------------------------

SELECT Nick, Description
FROM Pet
WHERE Description IS NOT NULL and Description <> '';

/*
   nick   | description
----------+-------------
 Katok    | crazy guy
 Partizan | very big
 Zombi    | wild
(4 rows)
*/

---------------------------------------------------------------
-- 4.  Средний возраст пуделей.
---------------------------------------------------------------

SELECT AVG(AGE)
FROM Pet
WHERE Breed = 'poodle';

/*
        avg
--------------------
 3.0000000000000000
(1 row)
*/


---------------------------------------------------------------
-- 5.  Количество владельцев. 
---------------------------------------------------------------

SELECT COUNT(DISTINCT Owner_ID)
FROM Pet;

/*
 count
-------
     6
(1 row)
*/


---------------------------------------------------------------
-- 6. Сколько имеется питомцев каждой породы.
---------------------------------------------------------------

SELECT Breed, COUNT(*)
FROM Pet
GROUP BY Breed
ORDER BY COUNT(*);

/*
  breed  | count
---------+-------
 spaniel |     1
 poodle  |     2
 Siamese |     2
 unknown |     2
         |     3
(5 rows)
*/


---------------------------------------------------------------
-- 7. Сколько имеется питомцев каждой породы 
--    (если только один - не показывать эту породу). 
---------------------------------------------------------------

SELECT Breed, COUNT(*) as Breed_Count
FROM Pet
GROUP BY Breed
HAVING COUNT(*) > 1
ORDER BY COUNT(*);

/*
  breed  | breed_count
---------+-------------
 poodle  |           2
 Siamese |           2
 unknown |           2
         |           3
(4 rows)
*/


---------------------------------------------------------------
-- 8. Животные от 5 до 10 лет
---------------------------------------------------------------

SELECT *
FROM Pet
WHERE Age BETWEEN 5 and 10
ORDER BY Age;

/*
 pet_id |   nick   |  breed  | age | description | pet_type_id | owner_id
--------+----------+---------+-----+-------------+-------------+----------
      4 | Apelsin  | poodle  |   5 |             |           1 |        2
      5 | Partizan | Siamese |   5 | very big    |           2 |        2
      7 | Model    |         |   5 |             |           3 |        4
      9 | Zombi    | unknown |   7 | wild        |           2 |        6
     10 | Las      | Siamese |   7 |             |           2 |        6
(5 rows)
*/


---------------------------------------------------------------
-- 9. Люди, чье имя состоит хотя бы из 5 букв
---------------------------------------------------------------

SELECT Last_Name, First_Name, Phone
FROM Person
WHERE First_Name LIKE '_____%';

/*
 last_name | first_name |    phone
-----------+------------+--------------
 Ivanov    | Vania      | +79123456789
 Petrov    | Petia      | +79234567890
 Vasiliev  | Vasia      | +7345678901
 Galkina   | Galia      | +7567890123
 Sokolova  | Sveta      | 234-56-78
 Zotov     | Misha      | 111-56-22
(6 rows)
*/


---------------------------------------------------------------
-- 10. Животные, которые являются или пуделями, или спаниелями
---------------------------------------------------------------

SELECT Nick, Breed 
FROM Pet
WHERE Breed in ('poodle', 'spaniel');

/*
  nick   |  breed
---------+---------
 Apelsin | poodle
 Daniel  | spaniel
 Markiz  | poodle
(3 rows)
*/




















