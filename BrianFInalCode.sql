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