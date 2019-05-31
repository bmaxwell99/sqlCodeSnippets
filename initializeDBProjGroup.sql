CREATE DATABASE CoffeeShop
GO
USE CoffeeShop
GO

Create table [dbo].[tblCustomer](
[CustomerID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
[CustFname] [varchar](30) NOT NULL,
[CustLname] [varchar](30) NOT NULL,
[CustDOB] [date] NULL,
[CustPNumber] [varchar](10) Null,
[CustStreet] [varchar](30) Null,
[CustCity] [varchar](30) null,
[CustState] [varchar](30) null,
[CustZip] [varchar](30) null)

GO



select customerID , CustomerFname, CustomerLname, DateOfBirth ,Email, CustomerAddress, CustomerCity, CustomerState, CustomerZip   into CoffeeShop.dbo.tblCustomer from CUSTOMER_BUILD.dbo.tblCUSTOMER

GO
CREATE TABLE [dbo].[tblOrder](
	[OrderID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[OrderDate] [Date] NOT NULL,
	[CustomerID] [int] FOREIGN KEY REFERENCES tblCustomer (customerID) NOT NULL,
	[OrderTypeID] [int] FOREIGN KEY REFERENCES tblOrderType (OrderTypeID) NOT NULL)

GO

drop table tblOrder

CREATE TABLE [dbo].[tblOrderType](
	[OrderTypeID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[OrderTypeName] [varchar](50) Not Null,
	[OrderTypeDesc] [varchar](300) null)

GO


CREATE TABLE [dbo].[tblDiscountType](
	[DiscTypeID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[DiscTypeName] [varchar](50) Not Null,
	[DiscTypeDesc] [varchar](300) null)

GO

CREATE TABLE [dbo].[tblDiscount](
	[DiscountID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[DiscName] [varchar] (50) Not Null,
	[DiscDesc] [varchar] (300) null,
	[DiscValue] [numeric] Not Null,
	[DiscTypeID][int] FOREIGN KEY REFERENCES tblDiscountType (DiscTypeID) NOT NULL)
GO

CREATE TABLE [dbo].[tblOrderLineItem](
	[OrderLineItemID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[Quantity] [int] Not Null,
	[OrderID] [int] FOREIGN KEY REFERENCES tblOrder (orderID) NOT NULL,
	[DiscountID] [int] FOREIGN KEY REFERENCES tblDiscount (discountID) NOT NULL)

	go


insert into dbo.tblOrderType
values('For here' , 'in a mug/plate')

insert into dbo.tblOrderType
values('To Go', 'In a bag/to go Cup')


go 
CREATE TABLE [dbo].[tblVendor](
	[VendorID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[VendorName] [varchar] (60) not null,
	[ContactFName] [varchar](50) Null,
	[ContactLName] [varchar](50) null,
	[ContactPhone] [char] (8) not null,
	[ContactEmail] [varchar] (75) not null,
	[VendorState] [varchar] (25) not null,
	[VendorCity] [varchar] (75) not null,
	[VendorZip] [varchar] (25) not null,
	[VendorAddress] [varchar] (120) not null)

	CREATE TABLE [dbo].[tblPurchOrder](
	[PurchOrderID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[PurchOrderTotal] [numeric] Not Null,
	[PurchOrderDate] [date] not null,	
	[VendorID][int] FOREIGN KEY REFERENCES tblVendor (VendorID) NOT NULL)
GO

Create Table [dbo].[tblPurchLineItem](
[PurchLineItemID] [int] IDENTITY(1,1) Primary key not null,
[LineItemQuantity] [int] not null,
[Cost] [numeric] not null,
[PurchOrderID] [int] FOREIGN KEY REFERENCES tblPurchOrder(PurchOrderID) Not null)

CREATE TABLE [dbo].[tblProduct](
	[ProductID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[ProductName] [varchar](50) Not Null,
	[ProductDesc] [varchar](300) null,
	[Price] [numeric] not null,
	[ProductTypeID] [int] FOREIGN KEY REFERENCES tblProductType(ProductTypeID) not null)

	go
alter table tblorderlineitem
add ProductID int FOREIGN KEY REFERENCES tblProductType(ProductTypeID) not null

go

Create table [dbo].[tblMember](
[MemberID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
[MemFname] [varchar](30) NOT NULL,
[MemLname] [varchar](30) NOT NULL,
[MemEmail] [varchar](75) Null,
[MemPhone] [char] (8) null)

go

CREATE TABLE [dbo].[tblStore](
	[StoreID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[StoreName] [varchar] (60) not null,
	[StorePhone] [char] (8) not null,
	[StoreState] [varchar] (25) not null,
	[StoreCity] [varchar] (75) not null,
	[StoreZip] [varchar] (25) not null,
	[StoreAddress] [varchar] (120) not null,
	[Capacity] [int] not null)

	go

	CREATE TABLE [dbo].[tblEventType](
	[EventTypeID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[EventTypeName] [varchar](50) Not Null,
	[EventTypeDesc] [varchar](300) null)

	create table [dbo].[tblEvent](
	[EventID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[EventDate] [date] not null,
	[EventTypeID] [int] FOREIGN KEY REFERENCES tblEventType(EventTypeID) not null,
	[StoreID] [int] FOREIGN KEY REFERENCES tblStore(StoreID) not null)



	create table [dbo].[tblLineUp](
	[LineUpID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[LineUpName] [varchar] (50) not null,
	[EventID] [int] FOREIGN KEY REFERENCES tblEvent(EventID) not null,
	[MemberID] [int] FOREIGN KEY REFERENCES tblMember(MemberID) not null)

	go

	CREATE TABLE [dbo].[tblShift](
	[ShiftID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[ShiftName] [varchar](50) Not Null,
	[ShiftDesc] [varchar](300) null)

	CREATE TABLE [dbo].[tblPositionType](
	[PositionTypeID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[PositionTypeName] [varchar](50) Not Null,
	[PositionTypeDesc] [varchar](300) null)

	CREATE TABLE [dbo].[tblPosition](
	[PositionID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[PositionName] [varchar](50) Not Null,
	[PositionDesc] [varchar](300) null,
	[PositionTypeID] [int] FOREIGN KEY REFERENCES tblPositionType(PositionTypeID) not null)

	
select StaffID , StaffFName, StaffLName, StaffBirth ,StaffEmail, StaffAddress, StaffCity, StaffState, StaffZip into CoffeeShop.dbo.tblEmployee from UNIVERSITY.dbo.tblSTAFF where  StaffBirth > (getDate() - (365.25 * 50))

 go
insert into CoffeeShop.dbo.tblEmployee[EmpFName] select StaffFName 
	from UNIVERSITY.dbo.tblSTAFF
	where StaffBirth > (getDate() - (365.25 * 35)) 
	
select *
from tblEmployee

CREATE TABLE [dbo].[tblEmpPosition](
	[EmpPositionID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[EmpPosBeginDate] date Not Null,
	[EmpPosEndDate] date null,
	[PositionID] [int] FOREIGN KEY REFERENCES tblPosition(PositionID) not null,
	[Salary] [numeric] not null,
	[EmployeeID] [int] FOREIGN KEY REFERENCES tblEmployee(EmployeeID) not null)

	go
create table [dbo].[tblEmpShift](
	[EmpShiftID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[EmpPositionID] [int] FOREIGN KEY REFERENCES tblEmpPosition(EmpPositionID) not null,
	[ShiftID] [int] FOREIGN KEY REFERENCES tblShift(ShiftID) not null,
	[StoreID] [int] FOREIGN KEY REFERENCES tblStore(StoreID) not null,
	[ShiftBeginDateTime] datetime,
	[ShiftEndDateTime] datetime)

go

insert into tblDiscountType
Values('Percent', 'between 0 and 100'),('Flat' , 'must be less than the price')

insert into tblDiscountType
values('Comped', 'must be the entire price')

insert into tblproducttype
values('drink', 'anything you drink'),('food','anything you eat')


go
drop table tblVendor

go
CREATE TABLE [dbo].[tblVendor](
	[VendorID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[VendorName] [varchar] (125) not null,
	[ContactFName] [varchar](60) Null,
	[ContactLName] [varchar](60) null,
	[ContactPhone] [varchar] (15) not null,
	[ContactEmail] [varchar] (125) not null,
	[VendorState] [varchar] (25) not null,
	[VendorCity] [varchar] (75) not null,
	[VendorZip] [varchar] (25) not null,
	[VendorAddress] [varchar] (120) not null)

go
insert into tblVendor (VendorName, ContactFName, ContactLName, ContactPhone, ContactEmail, VendorState, VendorCity, VendorZip, VendorAddress)
select  B.BusinessName as VendorName, FN.FirstName as ContactFName, LN.LastName as ContactLName, PNumber as ContactPhone, B.Email as ContactEmail ,  VendorState, VendorCity, VendorZip,  VendorAddress
from CUSTOMER_BUILD.dbo.tblFIRST_NAME FN
join CUSTOMER_BUILD.dbo.Businesses B on FN.FirstNameID  = (b.BusinessID * floor(rand()*(5+1))+1)
join CUSTOMER_BUILD.dbo.tblLAST_NAME LN on (b.BusinessID * (floor(rand()*(200+1))+1)) = LN.LastNameID 
join CUSTOMER_BUILD.dbo.tblCUSTOMER C on LN.LastNameID = C.CustomerID
join (
		select C.customerId, CONCAT(C.areacode, '-', C.phonenum) as PNumber 
		from CUSTOMER_BUILD.dbo.tblCUSTOMER C
		) as subquery on c.CustomerID = subquery.customerid
join (
		
	select StudentPermAddress as VendorAddress, StudentPermZip as VendorZip, StudentPermState as VendorState, StudentPermCity as VendorCity, StudentID
	from UNIVERSITY.dbo.tblSTUDENT S
	) as subquery2 on C.CustomerID = subquery2.studentID

go
select *
from Coffeeshop.dbo.tblVendor

drop table tblVendor
go
UPDATE tblVendor
SET ContactEmail = 
		CONCAT(ContactFName, '.', ContactLName, ContactEmail) 

go

insert into CoffeeShop.dbo.tblEventType
values('Poetry Slam', 'Truth spittin hour. Or maybe cringetown, USA'), ('Live Music', 'Genre inclusive'),('Standup Comedy', 'No gurantees that it will actually be funny')
		
