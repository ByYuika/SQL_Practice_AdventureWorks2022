select 
	pod.PurchaseOrderID, pod.PurchaseOrderDetailID, pod.OrderQty, pod.UnitPrice, pod.LineTotal, poh.OrderDate,
	case 
		when pod.OrderQty > 500 then 'Large'
		when pod.OrderQty between 50 and 500 then 'Medium'
		else 'Small'
	end as OrderSizeCategory,
	pro.Name as ProductName,
	isnull(prs.Name, 'None') as Subcategory,
	isnull(prc.Name, 'None') as Category,
	'Purchasing' as Source
from Purchasing.PurchaseOrderDetail pod
join Purchasing.PurchaseOrderHeader poh on pod.PurchaseOrderID = poh.PurchaseOrderID
join Production.Product pro on pod.ProductID = pro.ProductID
left join Production.ProductSubcategory prs on pro.ProductSubcategoryID = prs.ProductSubcategoryID 
left join Production.ProductCategory prc on prs.ProductCategoryID = prc.ProductCategoryID
where MONTH(poh.OrderDate) = 12
union all
select 
	sod.SalesOrderID, sod.SalesOrderDetailID, sod.OrderQty, sod.UnitPrice, sod.LineTotal, soh.OrderDate,
	case 
		when sod.OrderQty > 500 then 'Large'
		when sod.OrderQty between 50 and 500 then 'Medium'
		else 'Small'
	end as OrderSizeCategory,
	pro.Name as ProductName,
	isnull(prs.Name, 'None') as Subcategory,
	isnull(prc.Name, 'None') as Category,
	'Sales' as Source
from Sales.SalesOrderHeader soh
join  Sales.SalesOrderDetail sod on sod.SalesOrderID = soh.SalesOrderID
join Production.Product pro on sod.ProductID = pro.ProductID
left join Production.ProductSubcategory prs on pro.ProductSubcategoryID = prs.ProductSubcategoryID 
left join Production.ProductCategory prc on prs.ProductCategoryID = prc.ProductCategoryID
where MONTH(soh.OrderDate) = 12;
