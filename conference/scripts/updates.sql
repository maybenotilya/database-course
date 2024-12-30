\c conference_db

-- Удалить всех участников из США

CREATE TEMPORARY TABLE USA_Citizens
AS
SELECT Participant.ID
FROM Participant
WHERE Participant.Country_ID IN (
    SELECT ID
    FROM Country
    WHERE Name = 'USA'
);

DELETE FROM Culture_Event_Participant
WHERE Culture_Event_Participant.Participant_ID IN (
    SELECT ID
    FROM USA_Citizens
);

DELETE FROM Report_Participant
WHERE Report_Participant.Participant_ID IN (
    SELECT ID
    FROM USA_Citizens
);

DELETE FROM Participant
WHERE Participant.ID IN (
    SELECT ID
    FROM USA_Citizens
);

SELECT Country.Name
FROM Participant
    JOIN Country ON Participant.Country_ID = Country.ID;


-- Перенести мероприятия на час вперед для участников из Moskva-Hotel

CREATE TEMPORARY TABLE Moskva_Hotel_Participants
AS
SELECT Participant.ID
FROM Participant
    JOIN Hotel_Room ON Participant.Hotel_Room_ID = Hotel_Room.ID
    JOIN Hotel ON Hotel_Room.Hotel_ID = Hotel.ID
WHERE Hotel.Name = 'Moskva-Hotel';

UPDATE Report
SET Start_Time = Start_Time + INTERVAL '1 hour',
End_Time = End_Time + INTERVAL '1 hour'
WHERE EXISTS (
    SELECT 1
    FROM Report_Participant
    WHERE Report_Participant.Report_ID = Report.ID
    AND Report_Participant.Participant_ID IN (
        SELECT ID
        FROM Moskva_Hotel_Participants
    )
);

UPDATE Culture_Event
SET Start_Time = Start_Time + INTERVAL '1 hour',
End_Time = End_Time + INTERVAL '1 hour'
WHERE EXISTS (
    SELECT 1
    FROM Culture_Event_Participant
    WHERE Culture_Event_Participant.Culture_Event_ID = Culture_Event.ID
    AND Culture_Event_Participant.Participant_ID IN (
        SELECT ID
        FROM Moskva_Hotel_Participants
    )
);

SELECT Title, Start_Time, End_Time
FROM Report
UNION ALL
SELECT Title, Start_Time, End_Time
FROM Culture_Event;