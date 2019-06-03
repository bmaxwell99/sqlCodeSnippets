create procedure usp_AddOrder
@CustFname varchar (30),
@CustLname varchar (30),
@CustEmail varchar (50),
@orderTypeName varchar (30),
@orderDate date

as

declare @O_D date
declare @C_ID int
declare @OT_ID int

set @O_D = @orderDate

set @C_ID = (Select customerID 
			from tblCustomer 
			where CustomerFname = @CustFname
			and customerLname = @CustLname
			and email = @CustEmail)

set @OT_ID = (select ordertypeID
				from tblOrdertype
				where ordertypename = @orderTypeName)


Begin Tran m1
Insert into tblOrder (OrderDate, CustomerID, OrderTypeID)
Values(@O_D, @C_ID, @OT_ID)
commit tran m1

GO

select *
from tblcustomer

Exec dbo.usp_AddOrder
@CustFname = 'Karima',
@CustLname = 'ButterWorth',
@CustEmail = 'Karima.Butterworth303@bpdelawarematerials.com',
@orderTypeName = 'To Go',
@orderDate = 'July 7 1990'

Go
create function fn_noFutureOrders()
returns int
as
begin
	declare @ret int = 0
	if Exists(select orderDate
				from tblOrder
				where orderdate > getdate())

	begin
	set @ret = 1
	end

return @ret
end
go

alter table tblOrder
add constraint ck_noFutureOrders
check (dbo.fn_noFutureOrders() = 0)

go

create function fn_orderTotalComp(@PK Int)
returns numeric
as
begin

declare @ret numeric = (select LineTotal * Quantity as OrderTotal
				from tblOrderLineItem
				where OrderLineItemID = @PK)
return @ret
end
go

create function fn_noNegatives()
returns int
as
begin
	declare @ret int = 0
	if exists(Select *
				from tblOrderLineItem
				where Quantity < 0)

	begin
	set @ret = 1
	end

return @ret
end
Go
alter table tblorderlineitem
add constraint ck_nonegs
check (dbo.fn_noNegatives() = 0)

