USE CoffeeShop


--> Shannon Gatta Section

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


---> Roy Mosby section

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

--> Brian Luu Section

USE CoffeeShop
/* Business Rule: All drinks have discount percentages of only 40 percent or less. */
GO
CREATE FUNCTION fn_LessFortyDisc()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
	IF EXISTS (SELECT *
		FROM tblDiscountType DT
        JOIN tblDiscount D ON DT.DiscTypeID = D.DiscTypeID
        JOIN tblOrderLineItem OLI ON D.DiscountID = OLI.DiscountID
        JOIN tblProduct P ON OLI.ProductID = P.ProductID
        JOIN tblProductType PT ON P.ProductTypeID = PT.ProductTypeID
		WHERE PT.ProductTypeName = 'drink'
        AND DT.DiscTypeName = 'percent'
        AND D.DiscValue >= 1 
		AND D.DiscValue <= 40)
		BEGIN
			SET @Ret = 1
		END
	RETURN @Ret
END
GO

ALTER TABLE tblDiscount
ADD CONSTRAINT CK_DiscountValue
CHECK (dbo.fn_LessFortyDisc() = 0)

/* Computed Column:  PurchLineItemTotal = PurchLineQuantity * Cost */

GO
CREATE FUNCTION fn_PurchLineItemTotal(@PK INT)
RETURNS INT
AS
BEGIN
DECLARE @Ret Int = (
        SELECT (PurchLineQuantity * Cost)
            FROM tblPurchLineItem PLI
            JOIN tblPurchase P ON PLI.PurchaseID = P.PurchaseID
            JOIN tblVendor V ON P.VendorID = V.VendorID
            WHERE PLI. PurchLineItemID = @PK)
RETURN @Ret
END

GO

ALTER TABLE tblPurchLineItem
ADD PurchLineItem AS (dbo.fn_PurchLineItemTotal(PurchLineItemID))

-- Stored Procedure 1: Add Purchase

GO
CREATE PROCEDURE uspAddAPurchase
@PurchaseTotal Numeric,
@PurchaseDateTime datetime,
@VendorName varchar(50),
@ContactFname varchar(50),
@ContactLname varchar(50),
@ContactPhone varchar(50),
@ContactEmail varchar(50),
@VendorState varchar(50),
@VendorCity varchar(50),
@VendorZip varchar(50),
@VendorAddress varchar(50)

AS
DECLARE @V_ID INT

SET @V_ID = (SELECT VendorID
FROM tblVendor
WHERE VendorName = @VendorName
AND ContactFname = @ContactFname
AND ContactLname = @ContactLname
AND ContactPhone = @ContactPhone
AND ContactEmail = @ContactEmail
AND VendorState = @VendorState
AND VendorCity = @VendorCity
AND VendorZip = @VendorZip
AND VendorAddress = @VendorAddress
)

BEGIN TRAN G1
INSERT INTO tblPurchase(PurchaseTotal, PurchaseDateTime, VendorID)
VALUES (@PurchaseTotal, @PurchaseDateTime, @V_ID)
COMMIT TRAN G1

GO

EXEC uspAddAPurchase
@PurchaseTotal = 100,
@PurchaseDateTime = '2019-05-05',
@VendorName = 'Lake Fibre',
@ContactFname = 'Reid',
@ContactLname = 'Benjamen',
@ContactPhone = '425-987-6845',
@ContactEmail = 'Reid.Benjamen591@lqlakefibre.com',
@VendorState = 'Washington',
@VendorCity = 'Bellevue',
@VendorZip = '98004',
@VendorAddress = '18942 S Fauntleroy Ridge Place'

-- Stored Procedure 2: Add Discount

GO
CREATE PROCEDURE uspAddADiscount
@DiscName varchar(50),
@DiscDesc varchar(300),
@DiscValue varchar(50),
@DiscTypeName varchar(50)

AS
DECLARE @DT_ID INT

SET @DT_ID = (SELECT DiscTypeID
FROM tblDiscountType
WHERE DiscTypeName = @DiscTypeName
)

BEGIN TRAN G2
INSERT INTO tblDiscount(DiscName, DiscDesc, DiscValue, DiscTypeID)
VALUES (@DiscName, @DiscDesc, @DiscValue, @DT_ID)
COMMIT TRAN G2

GO

EXEC uspAddADiscount
@DiscName = 'Drink Discount',
@DiscDesc  = 'All drinks are 25% off',
@DiscValue = '25',
@DiscTypeName = 'Percent'

-- Subquery
-- which employees served a customer from 'Seattle' a 'To Go' order before 05-05-2019 
-- and a 'For Here' order for a customer from 'Bellevue' after '06-01-2019'

SELECT E.EmpFname, E.EmpLname, E.EmployeeID
FROM tblEmployee E
JOIN tblEmpPosition EP ON E.EmployeeID = EP.EmployeeID
JOIN tblEmpShift ES ON EP.EmpPositionID = ES.EmpPositionID
JOIN tblOrderLineItem OLI ON ES.EmpShiftID = OLI.EmpShiftID
JOIN tblOrder O ON OLI.OrderID = O.OrderID
JOIN tblCustomer C ON O.CustomerID = C.CustomerID
JOIN tblOrderType OT ON O.OrderTypeID = OT.OrderTypeID
WHERE C.CustomerState = 'Washington'
AND C.CustomerCity = 'Seattle'
AND OT.OrderTypeName = 'To Go'
AND O.OrderDateTime < '2019-05-05'
AND E.EmployeeID IN (SELECT E.EmployeeID
    FROM tblEmployee E
    JOIN tblEmpPosition EP ON E.EmployeeID = EP.EmployeeID
    JOIN tblEmpShift ES ON EP.EmpPositionID = ES.EmpPositionID
    JOIN tblOrderLineItem OLI ON ES.EmpShiftID = OLI.EmpShiftID
    JOIN tblOrder O ON OLI.OrderID = O.OrderID
    JOIN tblCustomer C ON O.CustomerID = C.customerID
    JOIN tblOrderType OT ON O.OrderTypeID = OT.OrderTypeID
    WHERE C.CustomerState = 'Washington'
    AND C.CustomerCity = 'Bellevue'
    AND OT.OrderTypeName = 'For Here'
    AND O.OrderDateTime > '2019-06-01')


	--> Brian Maxwell

	--> stored procedure one
create procedure usp_addOrder
@Cust_Fname varchar(60),
@Cust_Lname varchar(60),
@CustDOB date,
@OrderDateTime datetime,
@OrderTypeName varchar(50)
as

declare @C_ID int
declare @OT_ID int

set @C_ID = (select customerid
			from tblCustomer C
			where C.CustomerFname = @Cust_Fname
			and C.CustomerLname = @Cust_Lname
			and c.DateOfBirth = @CustDOB)

set @OT_ID = (select orderTypeID
			from tblOrderType OT
			where OT.OrderTypeName = @OrderTypeName)


Begin tran m2
insert into tblOrder(CustomerID, OrderTypeID, OrderDateTime)
values(@C_ID, @OT_ID, @OrderDateTime)
commit tran m2


exec usp_addOrder
@Cust_Fname = 'Brian',
@Cust_Lname = 'Maxwell',
@CustDOB ='July 18, 1990',
@OrderDateTime ='June 6, 2019',
@OrderTypeName ='For Here'

go
--> stored procedure two
create procedure usp_addProduct
@ProductName varchar(50),
@ProductDesc varchar(300),
@Price numeric,
@ProductTypeName varchar(50),
@ShelfLifeInDays int

as
declare @PT_ID int

set @PT_ID = (select producttypeID
				from tblProductType
				where ProductTypeName = @ProductTypeName)

begin tran m5
insert into tblProduct(ProductName, ProductDesc, Price, ProductTypeID, ShelfLifeInDays)
values(@ProductName, @ProductDesc, @Price, @PT_ID, @ShelfLifeInDays)
commit tran m5


exec usp_addProduct
@ProductName = 'Oat and Nut Muffin',
@ProductDesc = 'High in fiber!' ,
@Price = 1.99,
@ProductTypeName = 'Food',
@ShelfLifeInDays = 2

exec usp_addProduct
@ProductName = 'GreenTea Kombucha 12oz',
@ProductDesc = 'low alchohol content' ,
@Price = 4.99,
@ProductTypeName = 'Drink',
@ShelfLifeInDays = 365

go
--> business rule to prevent expired food from being sold
create function fn_SellNoSpoiledFood()
returns int
as
begin

	declare @ret int = 0

	if exists(select *
				from tblProduct P
				join tblOrderLineItem OLI on P.ProductID = OLI.productID
				join tblOrder O on OLI.OrderID = O.OrderID
				join tblPurchLineItem PLI on P.ProductID = PLI.ProductID
				join tblPurchase PO on PLI.PurchaseID= PO.PurchaseID
				where DATEDIFF(day, PO.PurchaseDateTime, O.OrderDateTime) > P.ShelfLifeInDays)

	begin
	set @ret = 1
	end

return @ret
end
go

alter table tblOrderLineItem
add Constraint ck_dontsellthis
check (dbo.fn_SellNoSpoiledFood() = 0)

go

--> computed column to calc orderlinetotal dependent on discount type
create function fn_OrderLineTotal(@PK Int)
returns numeric
as
begin
	declare @ret int 

				--> checks if there is no discount associated with the lineitem
				if not exists
							(select *
							from tblOrderLineItem OLI
							join tblDiscount D on Oli.DiscountID = d.DiscountID
							where oli.OrderLineItemID = @PK)

				--> calculates the return column
				begin 
				set @ret = (select (Oli.OrderLineQuantity * P.Price )
							from tblOrderLineItem OLI
							join tblProduct P on OLI.ProductID = P.ProductID
							where Oli.OrderLineItemID = @PK)
				end	
									
				--> checks if the discount associated with the lineitem is percent
				if exists(	select *
							from tblOrderLineItem OLI
							join tblDiscount D on Oli.DiscountID = d.DiscountID
							join tblDiscountType DT on D.DiscTypeID = DT.DiscTypeID
							where oli.OrderLineItemID = @PK
							and DT.DiscTypeName = 'Percent')

				--> then multiplies by the discount value
				begin 
				set @ret = (select (Oli.OrderLineQuantity * P.Price * D.DiscValue)
							from tblOrderLineItem OLI
							join tblProduct P on OLI.ProductID = P.ProductID
							join tblDiscount D on OLI.DiscountID = D.DiscountID
							where Oli.OrderLineItemID = @PK)
				end	

				--> checks if the discount associated with the lineitem is flat
				if exists(	select *
							from tblOrderLineItem OLI
							join tblDiscount D on Oli.DiscountID = d.DiscountID
							join tblDiscountType DT on D.DiscTypeID = DT.DiscTypeID
							where oli.OrderLineItemID = @PK
							and DT.DiscTypeName = 'flat')

				--> then substracts the discount value
				begin 
				set @ret = (select (Oli.OrderLineQuantity * P.Price - D.DiscValue)
							from tblOrderLineItem OLI
							join tblProduct P on OLI.ProductID = P.ProductID
							join tblDiscount D on OLI.DiscountID = D.DiscountID
							where Oli.OrderLineItemID = @PK)
				end	

				--> checks if the discount associated with the lineitem is comped
				if exists(	select *
							from tblOrderLineItem OLI
							join tblDiscount D on Oli.DiscountID = d.DiscountID
							join tblDiscountType DT on D.DiscTypeID = DT.DiscTypeID
							where oli.OrderLineItemID = @PK
							and DT.DiscTypeName = 'comped')

				--> then returns zero
				begin 
				set @ret = 0
				end	
return @ret
end
go

alter table tblOrderlineItem
add OrderLineItemTotal as (dbo.fn_OrderLineTotal(OrderLineItemID))
go

--> query that asks what product has the highest gross profit and which employee sold the most of it
select top 1 EmpFName, EmpLName, ProductName, GrossProfit
from tblOrderLineItem OLI
join tblProduct P on OLI.ProductID = P.ProductID
join tblEmpShift ES on OLI.EmpShiftID = ES.EmpShiftID
join tblEmpPosition EP on ES.EmpPositionID = EP.EmpPositionID
join tblEmployee E on EP.EmployeeID = E.EmployeeID
join				(
					select P.ProductID, sum((OLI.OrderLineItemTotal  / OLI.OrderLineQuantity) - PLI.Cost) as GrossProfit
					from tblOrderLineItem OLI
					join tblProduct P on OLI.ProductID = P.ProductID
					join tblPurchLineItem PLI on P.ProductID = PLI.ProductID 
					group by P.ProductID
					) as subquery on P.ProductID = subquery.productID

order by GrossProfit asc


