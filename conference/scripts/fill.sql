\c conference_db

INSERT INTO Workplace (Name, Address)
VALUES 
    ('Yandex', 'Russia, Big Prospect 12'),
    ('VK', 'Russia, Small Ulitsa 10'),
    ('OpenAI', 'USA, New-York'),
    ('Facebook', 'USA, Washington DC'),
    ('SpbU', 'Russia, Rektorskiy Proezd'),
    ('JaneStreet', 'France Somewhere'),
    ('IBM', 'Canada Somewhere');

INSERT INTO Country (Name)
VALUES
    ('Russia'),
    ('USA'),
    ('France'),
    ('Canada');

INSERT INTO Hotel (Name, Address)
VALUES
    ('Moskva-Hotel', 'Krasnaya Ploschad'),
    ('Saint-Petersburg-Hotel', 'Dvortsovaya Ploschad');


INSERT INTO Hotel_Room (Room_Number, Hotel_ID)
VALUES 
    (100, 1),
    (200, 2),
    (300, 1),
    (400, 2),
    (500, 1),
    (600, 2),
    (700, 1),
    (800, 2),
    (900, 1),
    (1000, 2);

CALL add_participant('Ilya', 'Syresenkov', '88005553535', 'ilya.syresenkov@gmail.com', 1, 1, 1, true);
CALL add_participant('John', 'Krutoi', '81234567890', 'asfjka@gmail.com', 2, 2, 2, true);
CALL add_participant('Kirill', 'Smirnov', '82345678901', 'fasfas@gmail.com', 3, 3, 3, true);
CALL add_participant('Nikita', 'Morozov', '83456789012', 'hgdhhdf@gmail.com', 4, 4, 4, true);
CALL add_participant('Chichi', 'Chanchan', '84567890123', 'bhfdhfdhfd@gmail.com', 5, 1, 5, true);
CALL add_participant('Mr', 'Worldwide', '87890123456', 'worldwide@aaa.com', 3, NULL, 6, true);
CALL add_participant('Krutoi', 'Perec', '87640942840', 'hjfdgjdgfjhhdgf@gmail.com', 6, 2, 7, true);
CALL add_participant('Aaaa', 'Aaaaaaaa', NULL, 'jhgdhdfh@gmail.com', 1, 3, 8, true);
CALL add_participant('Bbb', 'Bbbbbbb', NULL, 'jhgdjhgdfjg@gmail.com', 2, 4, 9, true);
CALL add_participant('Ccc', 'Ccccccc', '82155345343', 'jgdjgd@gmail.com', 3, 1, 10, false);
CALL add_participant('Ddd', 'Dddddddd', '88567585759', NULL, 4, NULL, NULL, false);
CALL add_participant('Eee', 'Eeeeeeee', '88538573587', 'gshfdsdghh@gmail.com', 5, 1, NULL, false);
CALL add_participant('Fff', 'Ffffffff', '86525687329', 'hfdhjdfjhdf@gmail.com', 6, 2, NULL, false);
CALL add_participant('Ggg', 'Ggggggg', '85672525585', 'w4rhgfdhd@gmail.com', 3, 3, NULL, false);

INSERT INTO Report_Theme (Theme, Section)
VALUES 
    ('Ecology', 1),
    ('Math', 2),
    ('Geodesy', 3),
    ('Computer Science', 4),
    ('Not interesting theme', 5);

CALL add_report('Docker Report', 'plenary', 4, '2024-12-23 10:00:00', '2024-12-23 11:00:00', 1);
CALL add_report('Big Ecology Talk', 'plenary', 1, '2024-12-23 10:00:00', '2024-12-23 11:00:00', 2);
CALL add_report('Big Ecology Stand', 'poster', 1, '2024-12-23 10:00:00', '2024-12-23 18:00:00', 3);
CALL add_report('Second Big Ecology Talk', 'plenary', 1, '2024-12-23 11:30:00', '2024-12-23 12:30:00', 4);
CALL add_report('Non public math stand', 'poster', 2, '2024-12-23 10:00:00', '2024-12-23 18:00:00', 5);
CALL add_report('Non public geodesy talk', 'plenary', 3, '2024-12-23 10:00:00', '2024-12-23 11:00:00', 10);
CALL add_report('Non public diffuri talk', 'plenary', 2, '2024-12-23 10:00:00', '2024-12-23 11:00:00', 11);

INSERT INTO Report_Participant
VALUES 
    (1, 6),
    (1, 3),
    (2, 4),
    (4, 2),
    (4, 14) ;

INSERT INTO Culture_Event (Title, Start_Time, End_Time, Hotel_ID)
VALUES 
    ('Party at Moskva', '2024-12-23 20:00:00', '2024-12-24 03:00:00', 1),
    ('Party at Saint Petersburg', '2024-12-23 20:00:00', '2024-12-24 03:00:00', 2),
    ('Big big lunch', '2024-12-23 14:00:00', '2024-12-23 16:00:00', NULL);

INSERT INTO Culture_Event_Participant
SELECT 1, Participant.ID
FROM Participant
    JOIN Hotel_Room ON Participant.Hotel_Room_ID = Hotel_Room.ID
WHERE Hotel_Room.Hotel_ID = 1;

INSERT INTO Culture_Event_Participant
SELECT 2, Participant.ID
FROM Participant
    JOIN Hotel_Room ON Participant.Hotel_Room_ID = Hotel_Room.ID
WHERE Hotel_Room.Hotel_ID = 2;

INSERT INTO Culture_Event_Participant
SELECT 3, Participant.ID
FROM Participant;