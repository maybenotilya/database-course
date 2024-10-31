\c pet_db 

---------------------------------------------------------------
-- Создание таблиц
---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Vaccination_Type (
    Vaccination_Type_ID SERIAL,
    Name VARCHAR(50) NOT NULL,
    CONSTRAINT Vaccination_Type_PK PRIMARY KEY (Vaccination_Type_ID)
);

CREATE TABLE IF NOT EXISTS Vaccination (
    Vaccination_ID SERIAL,
    Pet_ID INTEGER NOT NULL,
    Vaccination_Type_ID INTEGER NOT NULL,
    Vaccination_Date DATE NOT NULL,
    Document_Scan BYTEA,
    CONSTRAINT Vaccination_PK PRIMARY KEY (Vaccination_ID),
    CONSTRAINT FK_Vaccination_Pet FOREIGN KEY (Pet_ID) REFERENCES Pet (Pet_ID),
    CONSTRAINT FK_Vaccination_Type FOREIGN KEY (Vaccination_Type_ID) REFERENCES Vaccination_Type (Vaccination_Type_ID)
);

---------------------------------------------------------------
-- Заполнение таблиц
---------------------------------------------------------------

INSERT INTO
    Vaccination_Type (name)
VALUES
    ('KAB'),
    ('KOKAB'),
    ('Rabipur'),
    ('Biokan');

INSERT INTO
    Vaccination (Pet_ID, Vaccination_Type_ID, Vaccination_Date, Document_Scan)
VALUES
    (1, 2, '1991-01-01', 'scan'),
    (2, 1, '1992-02-02', NULL),
    (3, 4, '1993-03-03', 'qwerty'),
    (4, 3, '1994-04-04', NULL);

---------------------------------------------------------------
-- Проверка
---------------------------------------------------------------

SELECT * FROM Vaccination_Type;

SELECT * FROM Vaccination;