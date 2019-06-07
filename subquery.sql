use CoffeeShop

select *
from tblOrderLineItem OLI
join tblProduct P on OLI.ProductID = P.ProductID
join tblPurchLineItem PLI on P.ProductID = PLI.ProductID
where P.ProductID in (
					select top ((OLI.OrderLineItemTotal  / OLI.OrderLineQuantity) - PLI.Cost)  P.ProductID
					from tblOrderLineItem OLI
					join tblProduct P on OLI.ProductID = P.ProductID
					join tblPurchLineItem PLI on P.ProductID = PLI.ProductID 
					)


