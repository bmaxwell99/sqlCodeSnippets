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
UPDATE tblVendor
SET ContactEmail = 
		CONCAT(ContactFName, '.', ContactLName, ContactEmail) 
go


select 