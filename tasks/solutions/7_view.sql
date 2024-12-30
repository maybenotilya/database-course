\c pet_db 

---------------------------------------------------------------
-- Создайте представление Собаки со следующими атрибутами:
-- Кличка, порода, возраст, фамилия и имя хозяина.
-- Используя это представление, получите список пуделей: кличка, фамилия хозяина.
---------------------------------------------------------------

CREATE VIEW dogs AS
    SELECT nick, breed, age, last_name, first_name
    FROM pet
        INNER JOIN owner ON owner.owner_id = pet.owner_id
        INNER JOIN person ON person.person_id = owner.owner_id
        INNER JOIN pet_type ON pet.pet_type_id = pet_type.pet_type_id
    WHERE pet_type.name = 'DOG';

SELECT nick, last_name
FROM dogs
WHERE breed = 'poodle';

/*
  nick   | last_name
---------+-----------
 Apelsin | petrov
 Markiz  | Galkina
*/

---------------------------------------------------------------
-- Создайте представление Рейтинг сотрудников: фамилия, имя, количество выполненных заказов,
-- средний балл (по оценке).
-- Используя это представление, выведите рейтинг с сортировкой по убыванию балла.
---------------------------------------------------------------

CREATE VIEW employee_rating AS
SELECT last_name, first_name, COUNT(*) AS orders_count, AVG(mark) AS avg_mark
FROM order1
    INNER JOIN employee on employee.employee_id = order1.employee_id
    INNER JOIN person ON person.person_id = employee.person_id
WHERE order1.is_done = 1
GROUP BY last_name, first_name;

SELECT *
FROM employee_Rating
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

CREATE VIEW customers AS
SELECT DISTINCT last_name, first_name, phone, address
FROM person
    INNER JOIN owner ON owner.person_id = person.person_id
    INNER JOIN order1 ON order1.owner_id = owner.owner_id;

SELECT * FROM customers;


/*
 last_name | first_name |    phone     |       address
-----------+------------+--------------+----------------------
 Sokolov   | S.         | +7678901234  | Srednii pr VO, 27-1
 Ivanov    | Vano       | +7789012345  | Malyi pr VO, 33-2
 Vasiliev  | Vasia      | +7345678901  | Nevskii pr, 9-11
 petrov    | petia      | +79234567890 | Sadovaia ul, 17\2-23
 Galkina   | Galia      | +7567890123  | 10 linia VO, 35-26
(5 rows)
*/

/*
Уберем у кого нибудь адрес
*/

UPDATE person
SET address = ''
WHERE last_name = 'Sokolov';

SELECT * FROM customers;


/*
 last_name | first_name |    phone     |       address
-----------+------------+--------------+----------------------
 Sokolov   | S.         | +7678901234  |
 Ivanov    | Vano       | +7789012345  | Malyi pr VO, 33-2
 Vasiliev  | Vasia      | +7345678901  | Nevskii pr, 9-11
 Petrov    | Petia      | +79234567890 | Sadovaia ul, 17\2-23
 Galkina   | Galia      | +7567890123  | 10 linia VO, 35-26
(5 rows)
*/

/*
В psql нельзя писать update на view, состоящие из более чем одной таблицы, 
поэтому напишем update через exists
*/

UPDATE person
SET address = '?'
WHERE EXISTS (
    SELECT *
    FROM customers
    WHERE customers.last_name = person.last_name
        AND customers.first_name = person.first_name
        AND customers.phone = person.phone
        AND person.address = ''
        AND customers.address = ''
);

SELECT * FROM customers;

/*
 last_name | first_name |    phone     |       address
-----------+------------+--------------+----------------------
 Sokolov   | S.         | +7678901234  | ?
 Ivanov    | Vano       | +7789012345  | Malyi pr VO, 33-2
 Vasiliev  | Vasia      | +7345678901  | Nevskii pr, 9-11
 Petrov    | Petia      | +79234567890 | Sadovaia ul, 17\2-23
 Galkina   | Galia      | +7567890123  | 10 linia VO, 35-26
(5 rows)
*/

SELECT * FROM person;

/*
 person_id | last_name | first_name |    phone     |         address
-----------+-----------+------------+--------------+--------------------------
         1 | Ivanov    | Vania      | +79123456789 | Srednii pr VO, 34-2
         2 | Petrov    | Petia      | +79234567890 | Sadovaia ul, 17\2-23
         3 | Vasiliev  | Vasia      | +7345678901  | Nevskii pr, 9-11
         4 | Orlov     | Oleg       | +7456789012  | 5 linia VO, 45-8
         5 | Galkina   | Galia      | +7567890123  | 10 linia VO, 35-26
         7 | Vorobiev  | Vova       | 123-45-67    | Universitetskaia nab, 17
         8 | Ivanov    | Vano       | +7789012345  | Malyi pr VO, 33-2
         9 | Sokolova  | Sveta      | 234-56-78    |
        10 | Zotov     | Misha      | 111-56-22    |
         6 | Sokolov   | S.         | +7678901234  | ?
(10 rows)
*/