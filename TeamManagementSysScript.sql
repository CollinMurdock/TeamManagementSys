--=================================================Header
--Title: Basketball Team Management System Database Script
--Team Members: Collin Murdock, Tim Romer, Nishil Shah
--Last edited: 4/25/2019
--=================================================

--=================================================Create Database

USE master
IF EXISTS(select * from sys.databases where name='murdoccr')
DROP DATABASE murdoccr

CREATE DATABASE murdoccr
GO
USE murdoccr
GO

--================================================Create Tables
CREATE TABLE Players(
	playerID	INT	PRIMARY KEY IDENTITY,
	[name]		varchar(50) NOT NULL,
	position	CHAR(1)	NOT NULL,
	dob			DATE	NOT NULL,
	height		INT		NOT NULL,
	weight		INT		NOT NULL
)

CREATE TABLE Contracts(
	contractID		INT	PRIMARY KEY	IDENTITY,
	playerID		INT FOREIGN KEY REFERENCES Players(playerID),
	year			INT NOT NULL,
	salary			INT NOT NULL,
	bonus			INT	NOT NULL
)

CREATE TABLE Injuries(
	injuryID		INT		PRIMARY KEY	IDENTITY,
	playerID		INT		FOREIGN KEY REFERENCES Players(playerID),
	injuryDescription	VARCHAR(80)	NOT NULL,
	dateInjured		DATE			NOT NULL,
	returnDate	DATE
)


CREATE TABLE PlayerStats(
	playerID	INT FOREIGN KEY REFERENCES Players(playerID),
	season		INT	NOT NULL,
	gamesPlayed	INT	NOT NULL,
	points		INT	NOT NULL,
	assists		INT	NOT NULL,
	rebounds	INT	NOT NULL,
	steals		INT	NOT NULL,
	blocks		INT NOT NULL,
	turnovers	INT NOT NULL
)


GO


--===================================================================Create Procedures

CREATE PROCEDURE spGetAllPlayers

AS
	SET NOCOUNT ON

	SELECT * FROM Players	p
	ORDER BY p.name
GO



CREATE PROCEDURE spDeletePlayer
	@id		INT

AS
	SET NOCOUNT ON
	
	DELETE 
	FROM Injuries 
	WHERE playerID = @id

	DELETE 
	FROM PlayerStats 
	WHERE playerID = @id

	DELETE 
	FROM Contracts 
	WHERE playerID = @id

	DELETE p
	FROM Players p
	WHERE p.playerID = @id

GO

CREATE PROCEDURE spGetPlayerStats
	@id		INT

AS
	SET NOCOUNT ON

	SELECT * 
	FROM PlayerStats ps 
	WHERE ps.playerID = @id

GO


CREATE PROCEDURE spAddContractYear
	@year	INT,
	@salary	INT,
	@bonus	INT,
	@id		INT
AS
	SET NOCOUNT ON

	INSERT INTO Contracts(playerID, year, salary, bonus)
	VALUES(@id, @year, @salary, @bonus)	
	
GO

CREATE PROCEDURE spGetPlayerContract
	@id		INT
AS
	SET NOCOUNT ON

	SELECT *
	FROM Contracts
	WHERE playerID = @id
GO


CREATE PROCEDURE spAddInjury
	@injuryDesc				VARCHAR(80),
	@dateInjured			DATE,
	@returnDate	DATE,
	@id						INT

AS
	SET NOCOUNT ON

	INSERT INTO Injuries(playerID, injuryDescription, dateInjured, returnDate)
	VALUES(@id, @injuryDesc, @dateInjured, @returnDate)

GO

CREATE PROCEDURE spGetPlayerInjuries
	@id		INT
AS
	SET NOCOUNT ON

	SELECT * 
	FROM Injuries 
	WHERE playerID = @id
GO

CREATE PROCEDURE spGetCurrentInjuries
AS
	SET NOCOUNT ON
	
	SELECT i.dateInjured, i.injuryDescription, i.injuryID, i.playerID, i.returnDate, p.name
	FROM Injuries i, Players p
	WHERE returnDate > GETDATE() AND p.playerID = i.playerID

GO

CREATE PROCEDURE spAddPlayer
	@name		VARCHAR(50),
	@position	CHAR(1),
	@dob		DATE,
	@height		INT,
	@weight		INT

AS

	SET NOCOUNT ON

	INSERT INTO Players (name, position, dob, height, weight)
	VALUES	(@name, @position, @dob, @height, @weight)

GO

CREATE PROCEDURE spGetPlayerAverages
	@id	INT
AS
	SET NOCOUNT ON

	SELECT *
	FROM vwAvgPlayerStats	ps
	WHERE ps.playerID = @id

GO

CREATE PROCEDURE spAddGameStats
	@id			INT,
	@season		INT,
	@points		INT,
	@assists	INT,
	@rebounds	INT,
	@steals		INT,
	@blocks		INT,
	@turnovers	INT
AS
	SET NOCOUNT ON

	UPDATE PlayerStats
	SET		gamesPlayed = gamesPlayed + 1,
			points = points + @points,
			assists = assists + @assists,
			rebounds = rebounds + @rebounds,
			steals = steals + @steals,
			blocks = blocks + @blocks,
			turnovers = turnovers + @turnovers
	WHERE playerID = @id

GO

CREATE PROCEDURE spGetAllContracts
	
AS
	SET NOCOUNT ON
	
	SELECT 	[Name] = p.name,
			[Year] = (
				SELECT 	c.year,
						c.salary,
						c.bonus
				FROM Contracts c 
				WHERE p.playerID = c.playerID
				FOR JSON PATH
			)
	FROM Players p
	FOR JSON PATH, ROOT('Contracts')
	
GO



--=================================================================Creating Views

CREATE VIEW vwAvgPlayerStats AS
SELECT	playerID,
		season,
		gamesPlayed,
		[points] = CAST(points AS float) / gamesPlayed,
		[assists] = CAST(assists AS float) / gamesPlayed,
		[rebounds] = CAST(rebounds AS float) / gamesPlayed,
		[steals] = CAST(steals AS float) / gamesPlayed,
		[blocks] = CAST(blocks AS float) / gamesPlayed,
		[turnovers] = CAST(turnovers AS float) / gamesPlayed
FROM dbo.PlayerStats

GO

CREATE VIEW vwStatsWithNames AS
SELECT p.name, ps.*
FROM PlayerStats 	ps
JOIN Players 		p ON p.playerID = ps.playerID

GO

CREATE VIEW vwInjuriesWithNames AS
SELECT p.name, i.*
FROM Injuries 	i
JOIN Players 		p ON p.playerID = i.playerID

GO
--============================================================ Inserting Data
--Author: Tim Romer
--Date: 4/17/19
--Description: Bulk inserts data into the Team Management System database

--============================================================Players
-- BULK INSERT Players
-- FROM 'data/player_info.txt'
-- WITH (
-- 	FIRSTROW = 2,
-- 	FIELDTERMINATOR = ',',
-- 	ROWTERMINATOR = '\n'
-- )

SET IDENTITY_INSERT Players ON
INSERT INTO Players (playerID, name, position, dob, height, weight)
VALUES 	(1,'Jimmy Butler','F','9/14/1989',80,232),
		(2,'Tobias Harris','F','7/15/1992',81,235),
		(3,'Ben Simmons','G','7/20/1996',82,230),
		(4,'Boban Marjanovic','C','8/15/1988',87,290),
		(5,'T.J. McConnell','G','3/25/1992',74,190),
		(6,'Furkan Korkmaz','G','7/24/1997',79,190),
		(7,'Jonathon Simmons','F','9/14/1989',78,195),
		(8,'Joel Embiid','C','3/16/1994',84,250),
		(9,'Zhaire Smith','G','6/4/1999',76,199),
		(10,'J.J. Redick','G','6/24/1984',76,200),
		(11,'Mike Scott','F','7/16/1988',80,237),
		(12,'James Ennis','F','7/1/1990',79,210),
		(13,'Amir Johnson','C','5/1/1987',81,240),
		(14,'Jonah Bolden','F','1/2/1996',82,220),
		(15,'Shake Milton','G','9/26/1996',78,207),
		(16,'Haywood Highsmith','F','12/9/1996',79,220),
		(17,'Greg Monroe','C','6/4/1990',83,265)

SET IDENTITY_INSERT Players OFF

--============================================================PlayerStats
--Just fix with playerID field
-- BULK INSERT PlayerStats
-- FROM 'data/player_stats.csv'
-- WITH (
-- 	FIRSTROW = 2,
-- 	FIELDTERMINATOR = ',',
-- 	ROWTERMINATOR = '\n'
-- )

INSERT INTO PlayerStats (playerID, season, gamesPlayed, points, assists, rebounds, steals, blocks, turnovers)
VALUES	(3,2019,79,1337,610,697,112,142.2,274),
		(10,2019,76,1372,206,186,32,45.6,101),
		(8,2019,64,1761,234,871,46,281.6,226),
		(1,2019,55,1002,220,290,99,66,81),
		(5,2019,76,483,258,174,79,68.4,91),
		(2,2019,27,492,79,213,11,29.7,42),
		(6,2019,48,279,52,107,29,9.6,25),
		(11,2019,27,211,22,102,9,16.2,17),
		(14,2019,44,207,40,165,17,211.2,36),
		(13,2019,51,201,60,147,16,96.9,45),
		(4,2019,22,180,32,113,5,57.2,22),
		(12,2019,18,95,14,65,3,36,11),
		(15,2019,20,87,18,35,8,46,6),
		(7,2019,15,83,33,26,11,6,12),
		(9,2019,6,40,10,13,2,8.4,6),
		(17,2019,3,41,7,13,1,0,1),
		(16,2019,5,9,2,5,1,0,1)


--===========================================================Injuries
INSERT INTO dbo.Injuries (playerID, injuryDescription, dateInjured, returnDate)
VALUES	(3, 'ACL TORN', '1/1/2019', '8/5/2019'),
		(16, 'Pulled Hamstring', '12/8/2018', '1/15/2019'),
		(12, 'Broken Nose', '2/5/2019', '3/1/2019'),
		(9, 'Needs Rest', '4/1/2019', '4/5/2019'),
		(5, 'Broken Thumb', '11/14/2019', '1/6/2019'),
		(15, 'Shin Splints', '12/15/2019', '1/2/2019'),
		(15, 'Strained Hamstring', '4/1/2019', '5/15/2019')

--===========================================================Contracts
-- BULK INSERT Contracts
-- FROM 'data/player_contract.csv'
-- WITH (
-- 	FIRSTROW = 2,
-- 	FIELDTERMINATOR = ',',
-- 	ROWTERMINATOR = '\n'
-- )

INSERT INTO Contracts (playerID, year, salary, bonus)
VALUES	(8,2019,25467250,130000),
		(8,2020,27270000,1394818),
		(8,2021,29290000,1298303),
		(8,2022,31310000,4801239),
		(8,2023,33330000,3424234),
		(1,2019,20445779,130000),
		(1,2020,19841627,215098),
		(2,2019,14800000,130000),
		(10,2019,12250000,130000),
		(4,2019,7000000,132132),
		(3,2019,6434520,39127589),
		(3,2020,8113930,32409839),
		(7,2019,6000000,25087028),
		(7,2020,5750000,29348),
		(11,2019,4320500,810471),
		(9,2019,2611800,89472),
		(9,2020,3058800,32056),
		(9,2021,3204600,423422),
		(9,2022,4915856,48350),
		(13,2019,2393887,23901),
		(6,2019,1740000,9528409),
		(14,2019,1690000,23489),
		(14,2020,1698450,14343),
		(14,2021,1766550,4142),
		(14,2022,1845000,54153),
		(12,2019,1621415,150982),
		(12,2020,1845301,325802),
		(5,2019,1600520,321802),
		(15,2019,0,0),
		(16,2019,0,0),
		(17,2019,0,0)
		
	GO
--Changes made on May 4, 2019

