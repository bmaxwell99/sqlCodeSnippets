create procedure usp_addProduct
@ProductName varchar(50),
@ProductDesc varchar(300),
@Price numeric,
@ProductTypeName varchar(50)

as
declare @PT_ID int

set @PT_ID = (select producttypeID
				from tblProductType
				where ProductTypeName = @ProductTypeName)

begin tran m5
insert into tblProduct(ProductName, ProductDesc, Price, ProductTypeID)
values(@ProductName, @ProductDesc, @Price, @PT_ID)
commit tran m5


exec usp_addProduct
@ProductName = 'Oat and Nut Muffin',
@ProductDesc = 'High in fiber!' ,
@Price = 1.99,
@ProductTypeName = 'Food'

exec usp_addProduct
@ProductName = 'GreenTea Kombucha 12oz',
@ProductDesc = 'low alchohol content' ,
@Price = 4.99,
@ProductTypeName = 'Drink'

