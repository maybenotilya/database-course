\c pet_db 

---------------------------------------------------------------
-- Все оценки по выполненным заказам, исполнителями которых являлись студенты.
-- (используйте IN (SELECT...))
---------------------------------------------------------------
SELECT Mark
FROM Order1
WHERE Employee_ID IN (
    SELECT Employee_ID
    FROM Employee
    WHERE Spec = 'student'
) AND Mark > 0;

/*
 mark
------
    5
    5
    3
    5
    4
    4
    4
    4
    4
    4
    5
(11 rows)
*/

---------------------------------------------------------------
--  Фамилии исполнителей, не получивших еще ни одного заказа.
--  Последовательность отладки:
--      - id исполнителей, у которых нет заказов,
--          (используйте NOT IN (SELECT...))
--      - фамилии этих исполнителей.
--          (присоедините еще одну таблицу)
---------------------------------------------------------------

CREATE TEMP TABLE Employee_ID_Without_Orders AS 
SELECT Employee_ID
FROM Employee
GROUP BY Employee_ID
HAVING Employee_ID NOT IN (
    SELECT DISTINCT Employee_ID
    FROM Order1
);

SELECT Last_Name
FROM Person
    JOIN Employee ON Person.Person_ID = Employee.Person_ID
WHERE Employee.Employee_ID IN (SELECT * FROM Employee_ID_Without_Orders);

/*
 last_name
-----------
 Zotov
(1 row)
*/

---------------------------------------------------------------
-- Список заказов (вид услуги, время, фамилия исполнителя, кличка питомца, фамилия владельца).
-- (используйте псевдонимы, см. в презентации раздел 2.3. Сложные соединения таблиц)
---------------------------------------------------------------


SELECT 
    s.Name,
    ord.Time_Order AS Time,
    p_emp.Last_Name AS Employee_Last_Name,
    p.Nick,
    p_own.Last_Name AS Owner_Last_Name
FROM Order1 ord
    JOIN Service s ON s.Service_ID = ord.Service_ID
    JOIN Pet p ON p.Pet_ID = ord.Pet_ID
    JOIN Employee e ON e.Employee_ID = ord.Employee_ID
    JOIN Person p_emp ON p_emp.Person_ID = e.Person_ID
    JOIN Owner own ON own.Owner_ID = ord.Owner_ID
    JOIN Person p_own ON p_own.Person_ID = own.Person_ID;


/*
  name   |        time         | employee_last_name |   nick   | owner_last_name
---------+---------------------+--------------------+----------+-----------------
 Walking | 2023-09-11 08:00:00 | Vorobiev           | Bobik    | Petrov
 Combing | 2023-09-11 09:00:00 | Orlov              | Musia    | Petrov
 Combing | 2023-09-11 09:00:00 | Orlov              | Katok    | Petrov
 Walking | 2023-09-11 00:00:00 | Vorobiev           | Bobik    | Petrov
 Walking | 2023-09-16 11:00:00 | Vorobiev           | Bobik    | Petrov
 Walking | 2023-09-17 17:00:00 | Vorobiev           | Bobik    | Petrov
 Combing | 2023-09-17 18:00:00 | Orlov              | Musia    | Petrov
 Walking | 2023-09-17 18:00:00 | Vorobiev           | Partizan | Vasiliev
 Walking | 2023-09-17 10:00:00 | Vorobiev           | Apelsin  | Vasiliev
 Walking | 2023-09-18 17:00:00 | Vorobiev           | Partizan | Vasiliev
 Walking | 2023-09-18 18:00:00 | Vorobiev           | Apelsin  | Vasiliev
 Walking | 2023-09-18 12:00:00 | Vorobiev           | Partizan | Vasiliev
 Walking | 2023-09-18 14:00:00 | Vorobiev           | Apelsin  | Vasiliev
 Walking | 2023-09-19 10:00:00 | Vorobiev           | Daniel   | Galkina
 Combing | 2023-09-19 18:00:00 | Orlov              | Daniel   | Galkina
 Walking | 2023-09-20 10:00:00 | Vorobiev           | Daniel   | Galkina
 Walking | 2023-09-20 11:00:00 | Vorobiev           | Daniel   | Galkina
 Walking | 2023-09-22 10:00:00 | Vorobiev           | Daniel   | Galkina
 Walking | 2023-09-23 10:00:00 | Vorobiev           | Daniel   | Galkina
 Milking | 2023-09-30 11:00:00 | Ivanov             | Model    | Sokolov
 Milking | 2023-10-01 11:00:00 | Ivanov             | Model    | Sokolov
 Milking | 2023-10-02 11:00:00 | Ivanov             | Model    | Sokolov
 Combing | 2023-10-03 16:00:00 | Orlov              | Markiz   | Ivanov
(23 rows)
*/

---------------------------------------------------------------
-- Общий список комментариев, имеющихся в базе.
-- (Хватит захламлять базу, посмотрите, что вы пишите в комментариях!).
-- (используйте UNION)
-- (комментарии есть в трех таблицах)
---------------------------------------------------------------

CREATE TEMP TABLE Comment_Temp AS
SELECT Comments
FROM Order1
UNION ALL
SELECT Description
FROM Owner
UNION ALL
SELECT Pet.Description
FROM Pet;

SELECT Comments
FROM Comment_Temp
WHERE Comments <> '';

/*
       comments
----------------------
 That cat is crazy!
 Comming late
 good boy
 from the ArtsAcademy
 mean
 crazy guy
 very big
 wild
(8 rows)
*/

---------------------------------------------------------------
-- Имена и фамилии сотрудников, хотя бы раз получивших четверку за выполнение заказа.
-- (используйте EXISTS)
---------------------------------------------------------------


SELECT Last_Name, First_Name
FROM Person
WHERE EXISTS(
    SELECT Person_ID
    FROM Order1
        JOIN Employee ON Employee.Employee_ID = Order1.Employee_ID
    WHERE Employee.Person_ID = Person.Person_ID
        AND Order1.Mark = 4
);

/*
 last_name | first_name
-----------+------------
 Orlov     | Oleg
 Vorobiev  | Vova
(2 rows)
*/

---------------------------------------------------------------
-- Перепишите предыдущий запрос в каком-либо ином синтаксисе, без EXISTS.
---------------------------------------------------------------

SELECT Last_Name, First_Name
FROM Person
    JOIN Employee ON Employee.Person_ID = Person.Person_ID
    JOIN (
        SELECT Employee_ID, COUNT(Mark)
        FROM Order1
        WHERE Mark = 4
        GROUP BY Employee_ID
        HAVING COUNT(Mark) > 0
    ) temp ON temp.Employee_ID = Employee.Employee_ID;

/*
 last_name | first_name
-----------+------------
 Orlov     | Oleg
 Vorobiev  | Vova
(2 rows)
*/