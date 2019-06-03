create function fn_OrderLineTotal(@PK INT)
returns int
as 
begin 

	declare @ret numeric = 
		(select (Oli.OrderLineQuantity * P.Price)
		from tblOrderLineItem OLI
		join tblProduct P on OLI.ProductID = P.ProductID
		join tblDiscount D on OLI.DiscountID = D.DiscountID
		where Oli.OrderLineItemID = @PK
		) 



return @ret
end