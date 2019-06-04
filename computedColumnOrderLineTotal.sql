create function fn_OrderLineTotal(@PK Int)
returns numeric
as
begin
	declare @ret int 

				--> checks if there is no discount associated with the lineitem
				if not exists
							(select *
							from tblOrderLineItem OLI
							join tblDiscount D on Oli.DiscountID = d.DiscountID
							where oli.OrderLineItemID = @PK)

				--> calculates the return column
				begin 
				set @ret = (select (Oli.OrderLineQuantity * P.Price )
							from tblOrderLineItem OLI
							join tblProduct P on OLI.ProductID = P.ProductID
							where Oli.OrderLineItemID = @PK)
				end	
									
				--> checks if the discount associated with the lineitem is percent
				if exists(	select *
							from tblOrderLineItem OLI
							join tblDiscount D on Oli.DiscountID = d.DiscountID
							join tblDiscountType DT on D.DiscTypeID = DT.DiscTypeID
							where oli.OrderLineItemID = @PK
							and DT.DiscTypeName = 'Percent')

				--> then multiplies by the discount value
				begin 
				set @ret = (select (Oli.OrderLineQuantity * P.Price * D.DiscValue)
							from tblOrderLineItem OLI
							join tblProduct P on OLI.ProductID = P.ProductID
							join tblDiscount D on OLI.DiscountID = D.DiscountID
							where Oli.OrderLineItemID = @PK)
				end	

				--> checks if the discount associated with the lineitem is flat
				if exists(	select *
							from tblOrderLineItem OLI
							join tblDiscount D on Oli.DiscountID = d.DiscountID
							join tblDiscountType DT on D.DiscTypeID = DT.DiscTypeID
							where oli.OrderLineItemID = @PK
							and DT.DiscTypeName = 'flat')

				--> then substracts the discount value
				begin 
				set @ret = (select (Oli.OrderLineQuantity * P.Price - D.DiscValue)
							from tblOrderLineItem OLI
							join tblProduct P on OLI.ProductID = P.ProductID
							join tblDiscount D on OLI.DiscountID = D.DiscountID
							where Oli.OrderLineItemID = @PK)
				end	

				--> checks if the discount associated with the lineitem is comped
				if exists(	select *
							from tblOrderLineItem OLI
							join tblDiscount D on Oli.DiscountID = d.DiscountID
							join tblDiscountType DT on D.DiscTypeID = DT.DiscTypeID
							where oli.OrderLineItemID = @PK
							and DT.DiscTypeName = 'comped')

				--> then returns zero
				begin 
				set @ret = 0
				end	
return @ret
end
go

alter table tblOrderlineItem
add OrderLineItemTotal as (dbo.fn_OrderLineTotal(OrderLineItemID))