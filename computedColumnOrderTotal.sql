create function fn_orderTotal(@PK Int)
returns int
as
begin
	declare @ret int =
	(select sum(OrderlineTotal)
	from tblOrder O
	join tblOrderLineItem OLI on O.OrderID = oli.OrderID
	where O.OrderID = @PK
	)
return @ret
end