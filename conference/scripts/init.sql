CREATE DATABASE conference_db;
\c conference_db;

-- Tables and constraints

CREATE TABLE Participant (
    ID SERIAL NOT NULL,
    Name VARCHAR(20) NOT NULL,
    Surname VARCHAR(20),
    Phone VARCHAR(15),
    EMail VARCHAR(30),
    Workplace_ID INTEGER,
    Country_ID INTEGER,
    Hotel_Room_ID INTEGER,
    Are_Reports_Public BOOLEAN,

    CONSTRAINT Participant_PK PRIMARY KEY (ID)
);

CREATE TABLE Workplace (
    ID SERIAL NOT NULL,
    Name VARCHAR(50),
    Address VARCHAR(50),

    CONSTRAINT Workplace_PK PRIMARY KEY (ID)
);

CREATE TABLE Country (
    ID SERIAL NOT NULL,
    Name VARCHAR(20) NOT NULL,

    CONSTRAINT Country_PK PRIMARY KEY (ID)
);

CREATE TABLE Hotel_Room (
    ID SERIAL NOT NULL,
    Room_Number VARCHAR(10) NOT NULL,
    Hotel_ID INTEGER NOT NULL,

    CONSTRAINT Hotel_Room_PK PRIMARY KEY (ID)
);

CREATE TABLE Hotel (
    ID SERIAL NOT NULL,
    Name VARCHAR(30) NOT NULL,
    Address VARCHAR(50) NOT NULL,

    CONSTRAINT Hotel_PK PRIMARY KEY (ID)
);

CREATE TABLE Report (
    ID SERIAL NOT NULL,
    Type VARCHAR(15) NOT NULL CHECK (Type = 'plenary' OR Type = 'poster'),
    Title VARCHAR(30) NOT NULL,
    Report_Theme_ID INTEGER NOT NULL,
    Start_Time TIMESTAMP NOT NULL,
    End_Time TIMESTAMP NOT NULL,

    CONSTRAINT Report_PK PRIMARY KEY (ID)
);

CREATE TABLE Culture_Event (
    ID SERIAL NOT NULL,
    Title VARCHAR(30) NOT NULL,
    Start_Time TIMESTAMP NOT NULL,
    End_Time TIMESTAMP NOT NULL,
    Hotel_ID INTEGER,

    CONSTRAINT Culture_Event_PK PRIMARY KEY (ID)
);

CREATE TABLE Report_Theme (
    ID SERIAL NOT NULL,
    Theme VARCHAR(30) NOT NULL,
    Section INTEGER NOT NULL,

    CONSTRAINT Report_Theme_PK PRIMARY KEY (ID)
);

CREATE TABLE Report_Participant (
    Report_ID INTEGER NOT NULL,
    Participant_ID INTEGER NOT NULL,

    CONSTRAINT Report_Participant_PK PRIMARY KEY (Report_ID, Participant_ID)
);

CREATE TABLE Culture_Event_Participant (
    Culture_Event_ID INTEGER NOT NULL,
    Participant_ID INTEGER NOT NULL,

    CONSTRAINT Culture_Event_Participant_PK PRIMARY KEY (Culture_Event_ID, Participant_ID)
);

ALTER TABLE 
    Participant 
    ADD CONSTRAINT FK_Participant_Workplace FOREIGN KEY (Workplace_ID) REFERENCES Workplace (ID),
    ADD CONSTRAINT FK_Participant_Country FOREIGN KEY (Country_ID) REFERENCES Country (ID),
    ADD CONSTRAINT FK_Participant_Hotel_Room FOREIGN KEY (Hotel_Room_ID) REFERENCES Hotel_Room (ID) ON DELETE CASCADE;

ALTER TABLE
    Hotel_Room
    ADD
        CONSTRAINT FK_Hotel_Room_Hotel FOREIGN KEY (Hotel_ID) REFERENCES Hotel (ID);

ALTER TABLE 
    Culture_Event
    ADD
        CONSTRAINT FK_Culture_Event_Hotel FOREIGN KEY (Hotel_ID) REFERENCES Hotel (ID);

ALTER TABLE 
    Report
    ADD
        CONSTRAINT FK_Report_Report_Theme FOREIGN KEY (Report_Theme_ID) REFERENCES Report_Theme (ID);

ALTER TABLE 
    Report_Participant
    ADD CONSTRAINT FK_Report_Participant_Participant FOREIGN KEY (Participant_ID) REFERENCES Participant (ID),
    ADD CONSTRAINT FK_Report_Participant_Report FOREIGN KEY (Report_ID) REFERENCES Report (ID);

ALTER TABLE 
    Culture_Event_Participant
    ADD CONSTRAINT FK_Culture_Event_Participant_Culture_Event FOREIGN KEY (Culture_Event_ID) REFERENCES Culture_Event (ID),
    ADD CONSTRAINT FK_Culture_Event_Participant_Participant FOREIGN KEY (Participant_ID) REFERENCES Participant (ID);

-- Indices

CREATE INDEX Participant_Surname_Index ON Participant (Surname);

CREATE INDEX Report_Start_Time_Index ON Report (Start_Time);
CREATE INDEX Report_End_Time_Index ON Report (End_Time);

CREATE INDEX Culture_Event_Start_Time_Index ON Culture_Event (Start_Time);
CREATE INDEX Culture_Event_End_Time_Index ON Culture_Event (End_Time);

-- Procedures

CREATE OR REPLACE PROCEDURE add_participant (
    Name VARCHAR(20),
    Surname VARCHAR(20),
    Phone VARCHAR(15),
    EMail VARCHAR(30),
    Workplace_ID INTEGER,
    Country_ID INTEGER,
    Hotel_Room_ID INTEGER,
    Are_Reports_Public BOOLEAN
)
LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO Participant (
        Name,
        Surname,
        Phone,
        EMail,
        Workplace_ID,
        Country_ID,
        Hotel_Room_ID,
        Are_Reports_Public
    )
    VALUES (
        Name,
        Surname,
        Phone,
        EMail,
        Workplace_ID,
        Country_ID,
        Hotel_Room_ID,
        Are_Reports_Public
    );
END;
$$;


CREATE OR REPLACE PROCEDURE add_report (
    Title VARCHAR(30),
    Type VARCHAR(15),
    Report_Theme_ID INTEGER,
    Start_Time TIMESTAMP,
    End_Time TIMESTAMP,
    Author_ID INTEGER
)
LANGUAGE plpgsql
AS
$$
DECLARE Report_ID INTEGER;
BEGIN
    INSERT INTO Report (Type, Title, Report_Theme_ID, Start_Time, End_Time)
    VALUES (
        Type,
        Title,
        Report_Theme_ID,
        Start_Time,
        End_Time
    )
    RETURNING ID INTO Report_ID;

    INSERT INTO Report_Participant (Report_ID, Participant_ID)
    VALUES (Report_ID, Author_ID);

    COMMIT;
END;
$$;

CREATE OR REPLACE FUNCTION get_reports_by_theme(Query_Theme VARCHAR(30))
RETURNS TABLE (
    Type VARCHAR(15),
    Title VARCHAR(30),
    Start_Time TIMESTAMP,
    End_Time TIMESTAMP
)
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        SELECT Report.Type, Report.Title, Report.Start_Time, Report.End_Time
        FROM Report
            JOIN Report_Theme ON Report.Report_Theme_ID = Report_Theme.ID
        WHERE Report_Theme.Theme = Query_Theme;
END;
$$;

-- Triggers

CREATE OR REPLACE FUNCTION check_report_and_participant_exists()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS
$$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM Report CROSS JOIN Participant
        WHERE Report.ID = NEW.Report_ID AND Participant.ID = NEW.Participant_ID 
    ) THEN RAISE EXCEPTION 'Вы пытаетесь добавить участника и/или доклад, которых нет в базе';
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER Tr_report_participant_consistancy 
BEFORE INSERT
ON Report_Participant
FOR EACH ROW
EXECUTE FUNCTION check_report_and_participant_exists();

CREATE OR REPLACE FUNCTION check_culture_event_and_participant_exists()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS
$$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM Culture_Event CROSS JOIN Participant
        WHERE Culture_Event.ID = NEW.Culture_Event_ID AND Participant.ID = NEW.Participant_ID 
    ) THEN RAISE EXCEPTION 'Вы пытаетесь добавить участника и/или мероприятие, которых нет в базе';
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER Tr_culture_event_participant_consistancy
BEFORE INSERT
ON Culture_Event_Participant
FOR EACH ROW
EXECUTE FUNCTION check_culture_event_and_participant_exists();

CREATE OR REPLACE FUNCTION check_no_simultanious_reports()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
BEGIN
    IF NEW.Type = 'plenary' AND EXISTS (
        SELECT 1 
        FROM Report
        WHERE Type = 'plenary'
            AND Report_Theme_ID = NEW.Report_Theme_ID
            AND (Start_Time, End_Time) OVERLAPS (NEW.Start_Time, NEW.End_Time)
    ) THEN RAISE EXCEPTION 'Нельзя вести одновременно два пленарных доклада в одной секции';
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER Tr_no_simultanious_reports
BEFORE INSERT
ON Report
FOR EACH ROW
EXECUTE FUNCTION check_no_simultanious_reports();

-- Views

CREATE VIEW Public_Reports 
AS
SELECT
    Type,
    Title,
    Report_Theme_ID,
    Start_Time,
    End_Time
FROM Report
WHERE NOT EXISTS (
    SELECT 1
    FROM Report_Participant
        JOIN Participant ON Report_Participant.Participant_ID = Participant.ID
    WHERE Report_Participant.Report_ID = Report.ID
    AND NOT Participant.Are_Reports_Public
);

CREATE VIEW Plenary_Reports
AS
SELECT
    Title,
    Report_Theme_ID,
    Start_Time,
    End_Time
FROM Report
WHERE Type = 'plenary';

CREATE VIEW Poster_Reports
AS
SELECT
    Title,
    Report_Theme_ID,
    Start_Time,
    End_Time
FROM Report
WHERE Type = 'poster';

CREATE VIEW Section 
AS
SELECT 
    Report_Theme.Section AS Section, 
    MIN(Report.Start_Time) AS Open_Time, 
    MAX(Report.End_Time) AS Close_Time
FROM Report
    JOIN Report_Theme ON Report.Report_Theme_ID = Report_Theme.ID
GROUP BY Section
ORDER BY Section;

/*
-- Drops

-- Indexing

DROP INDEX Participant_Surname_Index;

DROP INDEX Report_Start_Time_Index;
DROP INDEX Report_End_Time_Index;

DROP INDEX Culture_Event_Start_Time_Index;
DROP INDEX Culture_Event_End_Time_Index;

-- Functions and procedures

DROP PROCEDURE add_participant;
DROP PROCEDURE add_report;
DROP FUNCTION get_reports_by_theme;

-- Triggers

DROP TRIGGER Tr_report_participant_consistancy ON Report_Participant;
DROP TRIGGER Tr_culture_event_participant_consistancy ON Culture_Event_Participant;
DROP TRIGGER Tr_no_simultanious_reports ON Report;

DROP FUNCTION check_report_and_participant_exists;
DROP FUNCTION check_culture_event_and_participant_exists;
DROP FUNCTION check_no_simultanious_reports;


-- Views

DROP VIEW Public_Reports;
DROP VIEW Plenary_Reports;
DROP VIEW Poster_Reports;
DROP VIEW Section;

-- Tables

DROP TABLE Report_Participant;
DROP TABLE Culture_Event_Participant;
DROP TABLE Participant;
DROP TABLE Workplace;
DROP TABLE Country;
DROP TABLE Hotel_Room;
DROP TABLE Culture_Event;
DROP TABLE Hotel;
DROP TABLE Report;
DROP TABLE Report_Theme;
*/