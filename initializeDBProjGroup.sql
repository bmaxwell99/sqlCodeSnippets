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


Go

select customerID , CustomerFname, CustomerLname, DateOfBirth ,Email, CustomerAddress, CustomerCity, CustomerState, CustomerZip   
	into CoffeeShop.dbo.tblCustomer 
	from CUSTOMER_BUILD.dbo.tblCUSTOMER

go

select CUSTOMER_BUILD.dbo.tblCUSTOMER

GO
CREATE TABLE [dbo].[tblOrder](
	[OrderID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[OrderDate] [Date] NOT NULL,
	[CustomerID] [int] FOREIGN KEY REFERENCES tblCustomer (customerID) NOT NULL,
	[OrderTypeID] [int] FOREIGN KEY REFERENCES tblOrderType (OrderTypeID) NOT NULL)

GO

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


--> this is how you "manually" add row to a table
insert into dbo.tblOrderType
values('For here' , 'in a mug/plate'), ('To Go', 'In a bag/to go Cup')

alter table tblorderlineitem
	add fakecol int FOREIGN KEY REFERENCES tblVendor (VendorID) NOT NULL