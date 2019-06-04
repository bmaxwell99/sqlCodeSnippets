USE CoffeeShop

--Stored Procedure 1
--Add an event
GO
CREATE PROCEDURE uspScheduleEvent
@DATE Date,
@EVENTTYPE varchar(50),
@TIME TIME,
@EVENT VARCHAR(50),
@STORE varchar(50),
@STOREZIP varchar(50)
AS
DECLARE @ET_ID INT
DECLARE @S_ID INT

SET @ET_ID = (SELECT EventTypeID
FROM tblEventType
WHERE EventTypeName = @EVENTTYPE
)

SET @S_ID = (SELECT STOREID
FROM tblStore 
WHERE StoreName = @STORE
AND StoreZip = @STOREZIP)

BEGIN TRAN G1
INSERT INTO tblEVENT(EventName,EVENTTIME,EventDate, EventTypeID, StoreID)
VALUES (@EVENT, @TIME, @DATE, @ET_ID, @S_ID)
COMMIT TRAN G1
GO

EXECUTE uspScheduleEvent
@DATE ='June 03 2019',
@EVENTTYPE = 'Standup Comedy',
@STORE = 'AROMA MOCHA',
@STOREZIP = '98102',
@TIME ='20:00',
@EVENT = 'ComedyJam Night'


--Stored Procedure 2
--Add member to an event
GO
CREATE PROCEDURE uspAddLineupForEvent
@DATE Date,
@TIME TIME,
@EVENT VARCHAR(50),
@FNAME VARCHAR(50),
@LNAME VARCHAR(50),
@BIRTH DATE
AS
DECLARE @E_ID INT
DECLARE @M_ID INT

SET @E_ID = (SELECT EventID
FROM tblEvent
WHERE EVENTNAME = @EVENT
AND EventDate = @DATE
AND EVENTTIME = @TIME
)

SET @M_ID = (SELECT MEMBERID
FROM tblMEMBER
WHERE MEMFNAME = @FNAME
AND MEMLNAME = @LNAME
AND MemberBirth = @BIRTH)


BEGIN TRAN G2
INSERT INTO tblLineUp(EventID, MemberID)
VALUES (@E_ID, @M_ID)
COMMIT TRAN G2
GO

EXECUTE uspAddLineupForEvent
@DATE = '2019-06-15',
@TIME = '16:00:00.0000000',
@EVENT = 'Poetry: A Concept',
@FNAME = 'Alexis',
@LNAME = 'Zeiss',
@BIRTH = '1978-11-27'


--Computed Column
--The total number of events a member has performed in
GO
CREATE FUNCTION fn_CalcTotalEventsMemberHasPerformed(@PK INT)
RETURNS INT
AS
BEGIN
DECLARE @Ret INT =
(SELECT COUNT(E.EventID)
FROM tblEvent E
JOIN tblLineUp L ON E.EventID = L.EventID
JOIN tblMember M ON L.MemberID = M.MEMBERID
WHERE M.MEMBERID = @PK)

RETURN @Ret
END
GO

ALTER TABLE tblMEMBER
ADD TOTALEVENTSPERFORMED AS (dbo.fn_CalcTotalEventsMemberHasPerformed(MEMBERID))
GO
	
-- Subquery
-- Which performers will perform Live Music at Aroma Mocha more than 3 times
-- before June 30,2019 that will also perform Standup Comedy at the ComedyJam 
-- Night on June 21st, 2019?
SELECT DISTINCT(M.MEMBERID), MEMFNAME, MEMLNAME
FROM tblMember M
JOIN tblLineUp L ON M.MEMBERID = L.MEMBERID
JOIN TBLEVENT E ON L.EventID = E.EventID
JOIN tblEventType ET ON E.EventTypeID = ET.EventTypeID
JOIN tblStore S ON E.StoreID = S.StoreID
WHERE ET.EventTypeName = 'LIVE MUSIC'
AND S.StoreName = 'AROMA MOCHA'
AND E.EVENTDATE < 'June 30,2019'
AND M.MEMBERID IN
	(SELECT M.MEMBERID
FROM tblMember M
JOIN tblLineUp L ON M.MEMBERID = L.MEMBERID
JOIN TBLEVENT E ON L.EventID = E.EventID
JOIN tblEventType ET ON E.EventTypeID = ET.EventTypeID
JOIN tblStore S ON E.StoreID = S.StoreID
WHERE ET.EventTypeName = 'STANDUP COMEDY'
AND E.EVENTNAME = 'COMEDYJAM NIGHT'
AND E.EVENTDATE = 'June 21,2019'
)
--Answer: Alexis Zeiss and Gus Sciarini

--Business Rule
--A member cannot perform at an intstance of an event more than once.

--Demo of Business Rule
GO
CREATE FUNCTION FN_PerformAtOneEventOnly()
RETURNS INT
AS
BEGIN
DECLARE @Ret INT = 0
IF EXISTS (SELECT *
FROM tblLineUp L 
GROUP BY L.MemberID
HAVING COUNT(L.MEMBERID) > 1

)
BEGIN
SET @Ret = 1
END

RETURN @Ret
END
GO

ALTER TABLE tblLineup WITH NOCHECK
ADD CONSTRAINT CK_OneMemberPerEvent
CHECK (dbo.FN_PerformAtOneEventOnly() = 0)

--Try to test it. This member is already registered for Poetry: A Concept, so an error will appear.
EXECUTE uspAddLineupForEvent
@DATE = '2019-06-15',
@TIME = '16:00:00.0000000',
@EVENT = 'Poetry: A Concept',
@FNAME = 'Alexis',
@LNAME = 'Zeiss',
@BIRTH = '1978-11-27'


