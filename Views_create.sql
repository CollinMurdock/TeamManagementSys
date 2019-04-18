--============================================================Header
--Author: Tim Romer
--Date: 4/18/19
--Description: Creating views for the Team Management System database

--=====================Create View with players name attached to the injury table
GO
CREATE VIEW vwInjuries AS
SELECT i.injuryID, p.name, i.injuryDescription, i.dateInjured, i.returnDate
FROM Injuries	i
JOIN Players	p ON p.playerID = i.playerID
GO

--=====================Create View with players name attached to the player stats table
GO
CREATE VIEW vwPlayerStats AS
SELECT p.name, ps.*
FROM PlayerStats	ps
JOIN Players	p	ON p.playerID = ps.playerID
GO
