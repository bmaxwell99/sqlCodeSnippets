/*
Final Database Code
*/

USE CoffeeShop
-- Store procedure that creates a new position
GO

CREATE PROCEDURE  rm_uspPopulatePosition
@PosName varchar (50),
@PosDesc varchar (60),
@PosTypeName varchar (50)

AS

DECLARE @Pos_TypeID INT

SET @Pos_TypeID = (SELECT PositionTypeID
                    FROM tblPositionType
                    WHERE PositionTypeName = @PosTypeName)


BEGIN TRAN R1
INSERT INTO tblPosition (PositionName, PositionDesc, PositionTypeID)
VALUES(@PosName, @PosDesc, @Pos_TypeID)
COMMIT TRAN R1
GO

EXEC rm_uspPopulatePosition
@PosName = 'Janitor',
@PosDesc = 'cleans/fixes store and equipment',
@PosTypeName = 'Maintence'
-------------------------------------------------------------------------------------------------------

--STORE PROCEDURE that creates a new  EmpPosition 
GO

CREATE PROCEDURE rm_uspPopulateEmpPosition
@PosName varchar (50),
@EmpPosBegDate Date,
@EmpPosEndDate Date,
@Salary numeric(18,0),
@EmFname varchar (60),
@EmLname varchar (60),
@EmpDate Date

AS

DECLARE @Pos_ID INT, @E_ID INT

SET @Pos_ID = (SELECT PositionID
               FROM tblPosition
               WHERE PositionName = @PosName)
               


SET @E_ID = (SELECT EmployeeID
            FROM tblEmployee
            WHERE EmpFname = @EmFname
            AND EmpLname = @EmLname
            AND EmpDOB = @EmpDate)

BEGIN TRAN R2
INSERT INTO tblEmpPosition (PositionID, EmpPosBeginDate, EmpPosEndDate, Salary,EmployeeID)
VALUES(@Pos_ID, @EmpPosBegDate, @EmpPosEndDate, @Salary, @E_ID)
COMMIT TRAN R2
GO

EXEC rm_uspPopulateEmpPosition
@PosName ='Janitor',
@EmpPosBegDate ='2010-08-03',
@EmpPosEndDate = '2016-06-23',
@Salary ='17000',
@EmFname ='Noriko',
@EmLname ='Luzier',
@EmpDate  ='1975-05-20'
---------------------------------------------------------------

/*
Business rule that enforces every member that participates in the eventtypename 'poetry slam' to be
older than 18
*/

-- member working at an eventtypename 'poetry slam' have to be 18 years or older 
GO
CREATE FUNCTION  rm_fnMemberOlderThan18()

RETURNS INT 
AS

BEGIN
    DECLARE @Ret INT = 0 

    IF EXISTS( SELECT *
                FROM tblMember M 
                JOIN tblLineUp LU ON M.MemberID = LU.MemberID
                JOIN tblEvent E ON LU.EventID = E.EventID
                JOIN tblEventType ET ON E.EventTypeID = ET.EventTypeID
                WHERE EventTypeName = 'Poetry Slam'
                AND MemberBirth <= GetDate()- (365.25 *18))
                
BEGIN
    SET @Ret = 1
END

RETURN @Ret
END

GO
ALTER TABLE tblMember WITH NOCHECK
ADD CONSTRAINT CK_MemberOlderThan18
CHECK(dbo.rm_fnMemberOlderThan18()=0)

------------------------------------------------------------------------------
-- computed column that determines
--OrderTotal = what was the total spent on this purchase? 

GO
CREATE FUNCTION rm_fnOrderTotal(@PK INT)

RETURNS numeric(18,0)
AS

BEGIN
    DECLARE @Ret numeric(18,0) = (
        SELECT SUM(OLI.OrderLineTotal )
        FROM tblOrder O
        JOIN tblOrderLineItem OLI ON O.OrderID = OLI.OrderID
        WHERE O.OrderID = @PK)

    RETURN @Ret
END

GO
ALTER TABLE tblOrder
ADD CustomerTotalSpent AS (dbo.rm_fnOrderTotalForCustomer(OrderID))


-->which employee was hired after March 5, 2010 is paid the most, but whose positiontype
-->the company spends less than 100,000 

SELECT top 1 E.EmployeeID, E.EmpFName, E.EmpLName,P.PositionName, EP.Salary 
FROM tblPosition P
JOIN tblEmpPosition EP ON P.PositionID = EP.PositionID
JOIN tblPositionType PT on P.PositionTypeID = PT.PositionTypeID
JOIN tblEmployee E ON EP.EmployeeID = E.EmployeeID
JOIN tblEmpShift ES ON EP.EmpPositionID = ES.EmpPositionID
JOIN tblStore S ON ES.StoreID = S.StoreID
WHERE S.StoreName LIKE 'Aroma%'
AND EP.EmpPosBeginDate > '2010-05-05'

AND PT.PositionTypeName IN

(SELECT Pt.PositionTypeName
FROM tblEmployee E
JOIN tblEmpPosition EP ON E.EmployeeID = EP.EmployeeID
JOIN tblPosition P ON EP.PositionID = P.PositionID
JOIN tblPositionType PT on P.PositionTypeID = PT.PositionTypeID
JOIN tblEmpShift ES ON EP.EmpPositionID = ES.EmpPositionID
JOIN tblStore S ON ES.StoreID = S.StoreID
WHERE S.StoreName LIKE 'Aroma%'
GROUP BY Pt.PositionTypeName, EP.Salary
HAVING SUM(EP.Salary) <= 100000)

GROUP BY E.EmployeeID, E.EmpFName, E.EmpLName,P.PositionName,EP.Salary
Order by EP.Salary desc

