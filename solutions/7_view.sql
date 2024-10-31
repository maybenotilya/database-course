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