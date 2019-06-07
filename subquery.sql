use CoffeeShop

select top 1 EmpFName, EmpLName, ProductName, GrossProfit
from tblOrderLineItem OLI
join tblProduct P on OLI.ProductID = P.ProductID
join tblEmpShift ES on OLI.EmpShiftID = ES.EmpShiftID
join tblEmpPosition EP on ES.EmpPositionID = EP.EmpPositionID
join tblEmployee E on EP.EmployeeID = E.EmployeeID
join				(
					select P.ProductID, sum((OLI.OrderLineItemTotal  / OLI.OrderLineQuantity) - PLI.Cost) as GrossProfit
					from tblOrderLineItem OLI
					join tblProduct P on OLI.ProductID = P.ProductID
					join tblPurchLineItem PLI on P.ProductID = PLI.ProductID 
					group by P.ProductID
					) as subquery on P.ProductID = subquery.productID

order by GrossProfit asc


