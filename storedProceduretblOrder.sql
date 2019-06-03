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
