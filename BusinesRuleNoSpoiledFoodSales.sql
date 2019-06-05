use CoffeeShop
go

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