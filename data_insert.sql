--============================================================Header
--Author: Tim Romer
--Date: 4/17/19
--Description: Bulk inserts data into the Team Management System database

--============================================================Players
BULK INSERT Players
FROM 'data/player_info.txt'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'
)

--============================================================PlayerStats
--Just fix with playerID field
BULK INSERT PlayerStats
FROM 'data/player_stats.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'
)

--===========================================================Injuries
INSERT INTO dbo.Injuries (playerID, injuryDescription, dateInjured, returnDate)
VALUES	('19', 'ACL TORN', '1/1/2019', '8/5/2019'),
		('16', 'Pulled Hamstring', '12/8/2018', '1/15/2019'),
		('12', 'Broken Nose', '2/5/2019', '3/1/2019'),
		('9', 'Needs Rest', '4/1/2019', '4/5/2019'),
		('5', 'Broken Thumb', '11/14/2019', '1/6/2019'),
		('15', 'Shin Splints', '12/15/2019', '1/2/2019')

--===========================================================Contracts
BULK INSERT Contracts
FROM 'data/player_contract.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'
)