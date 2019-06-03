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


	--> if Discount Type is Percent, then multiply by value
	
	begin
	set @ret =
		(select (Oli.OrderLineQuantity * P.Price * D.DiscValue)
		from tblOrderLineItem OLI
		join tblProduct P on OLI.ProductID = P.ProductID
		join tblDiscount D on OLI.DiscountID = D.DiscountID
		where Oli.OrderLineItemID = @PK
		) 

		if exists(select *
		from tblOrderLineItem OLI
		join tblDiscount D on OLI.DiscountID = D.DiscountID
		join tblDiscountType DT on D.DiscTypeID = DT.DiscTypeID
		where Oli.OrderLineItemID = @PK
		and DT.DiscTypeName = 'Percent'
		)
	end

	--> if Discount Type is Flat, then minus by value
	begin
	set @ret =
		(select (Oli.OrderLineQuantity * P.Price - D.DiscValue)
		from tblOrderLineItem OLI
		join tblProduct P on OLI.ProductID = P.ProductID
		join tblDiscount D on OLI.DiscountID = D.DiscountID
		where Oli.OrderLineItemID = @PK
		) 

		if exists(select *
		from tblOrderLineItem OLI
		join tblDiscount D on OLI.DiscountID = D.DiscountID
		join tblDiscountType DT on D.DiscTypeID = DT.DiscTypeID
		where Oli.OrderLineItemID = @PK
		and DT.DiscTypeName = 'Flat'
		)
	end

	--> if Discount Type is Comped, then return zero
	begin
	set @ret = 0
		
		if exists(select *
		from tblOrderLineItem OLI
		join tblDiscount D on OLI.DiscountID = D.DiscountID
		join tblDiscountType DT on D.DiscTypeID = DT.DiscTypeID
		where Oli.OrderLineItemID = @PK
		and DT.DiscTypeName = 'Percent'
		)
	end
return @ret
end