\c conference_db

-- Количество докладов у каждого человека, отсортированное по этому же количеству и фамилии
-- 2 варианта: включая людей без докладов и нет

-- Включая
SELECT 
    Participant.Name, 
    Participant.Surname, 
    SUM(CASE WHEN Report_Participant.Report_ID IS NULL THEN 0 ELSE 1 END) 
        AS Reports_Count 
FROM Participant
    LEFT JOIN Report_Participant ON Report_Participant.Participant_ID = Participant.ID
GROUP BY Participant.Name, Participant.Surname
ORDER BY Reports_Count DESC, Surname;

-- Не включая
SELECT Participant.Name, Participant.Surname, COUNT(*) AS Reports_Count 
FROM Report_Participant
    JOIN Participant ON Report_Participant.Participant_ID = Participant.ID
GROUP BY Participant.Name, Participant.Surname
ORDER BY Reports_Count DESC, Surname;

-- Количество планарных докладов на каждую из тем, включая темы, на которые докладов нет

SELECT Report_Theme.Theme, SUM(CASE WHEN Report.ID IS NULL THEN 0 ELSE 1 END) AS Count
FROM Report_Theme 
    LEFT JOIN Report ON Report.Report_Theme_ID = Report_Theme.ID
GROUP BY Report_Theme.Theme
ORDER BY Count DESC;

-- Люди, которые будут рассказывать доклады в секциях со 2 по 4

SELECT Participant.Name, Participant.Surname
FROM Report_Participant
    JOIN Participant ON Report_Participant.Participant_ID = Participant.ID
    JOIN Report ON Report_Participant.Report_ID = Report.ID
WHERE Report.Report_Theme_ID IN (
    SELECT ID
    FROM Report_Theme
    WHERE Section BETWEEN 2 AND 4
)
GROUP BY Participant.Name, Participant.Surname
ORDER BY Participant.Name, Participant.Surname;

-- Количество людей с каждым доменом почты

SELECT SPLIT_PART(Email, '@', 2) AS Domain, COUNT(*) AS Count
FROM Participant
GROUP BY Domain
HAVING SPLIT_PART(Email, '@', 2) IS NOT NULL;

-- Доклады по теме Ecology

SELECT Type, Title, Start_Time, End_Time
FROM get_reports_by_theme('Ecology');

-- Доклады, которые рассказывает 2 и более человек

SELECT Report.Title, Report.Start_Time, Report.End_Time
FROM (
    SELECT Report_ID, COUNT(*) AS Count
    FROM Report_Participant
    GROUP BY Report_ID
    HAVING COUNT(*) >= 2
) AS Temp
    JOIN Report ON Temp.Report_ID = Report.ID;

-- Мероприятия, на которые не записаны люди из Moskva-Hotel

SELECT Culture_Event.Title, Culture_Event.Start_Time, Culture_Event.End_Time
FROM (
    SELECT ID AS Culture_Event_ID
    FROM Culture_Event
    WHERE ID NOT IN (
        SELECT Culture_Event_ID
        FROM Culture_Event_Participant
        WHERE Participant_ID IN (
            SELECT Participant.ID
            FROM Participant
            WHERE Participant.Hotel_Room_ID IN (
                SELECT Hotel_Room.ID
                FROM Hotel_Room
                WHERE Hotel_ID IN (
                    SELECT Hotel.ID
                    FROM Hotel
                    WHERE Hotel.Name = 'Moskva-Hotel'
                )
            )
        )
    )
    GROUP BY Culture_Event_ID
) AS Temp
    JOIN Culture_Event ON Temp.Culture_Event_ID = Culture_Event.ID;

-- Вообще ВСЕ мероприятия, которые закончатся до 18.00 23 числа

SELECT Title, Start_Time, End_Time
FROM Report
WHERE End_Time < '2024-12-23 18:00:00'
UNION ALL
SELECT Title, Start_Time, End_Time
FROM Culture_Event
WHERE End_Time < '2024-12-23 18:00:00';

SELECT * FROM Public_Reports;

SELECT * FROM Plenary_Reports;

SELECT * FROM Poster_Reports;   

SELECT * FROM Section;