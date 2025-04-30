select 
	pod.PurchaseOrderID, pod.PurchaseOrderDetailID, pod.OrderQty, pod.UnitPrice, pod.LineTotal, poh.OrderDate,
	case 
		when pod.OrderQty > 500 then 'Large'
		when pod.OrderQty between 50 and 500 then 'Medium'
		else 'Small'
	end as OrderSizeCategory,
	pro.Name as ProductName,
	isnull(prs.Name, 'None') as Subcategory,
	isnull(prc.Name, 'None') as Category 
from Purchasing.PurchaseOrderDetail pod
join Purchasing.PurchaseOrderHeader poh on pod.PurchaseOrderID = poh.PurchaseOrderID
join Production.Product pro on pod.ProductID = pro.ProductID
left join Production.ProductSubcategory prs on pro.ProductSubcategoryID = prs.ProductSubcategoryID 
left join Production.ProductCategory prc on prs.ProductCategoryID = prc.ProductCategoryID
where MONTH(poh.OrderDate) = 12;

