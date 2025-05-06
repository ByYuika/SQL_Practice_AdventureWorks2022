# SQL_Practice_AdventureWorks2022
### Q1

1. PurchaseOrderID, from Purchasing.PurchaseOrderDetail
2. PurchaseOrderDetailID, from Purchasing.PurchaseOrderDetail
3. OrderQty, from Purchasing.PurchaseOrderDetail
4. UnitPrice, from Purchasing.PurchaseOrderDetail
5. LineTotal, from Purchasing.PurchaseOrderDetail
6. OrderDate, from Purchasing.PurchaseOrderHeader
7. A derived column, aliased as “OrderSizeCategory”, calculated via CASE logic as follows:
o When OrderQty > 500, the logic should return “Large”
o When OrderQty > 50 but <= 500, the logic should return “Medium”
o Otherwise, the logic should return “Small”
8. The “Name” field from Production.Product, aliased as “ProductName”
9. The “Name” field from Production.ProductSubcategory, aliased as “Subcategory”; if this value is
NULL, return the string “None” instead
10. The “Name” field from Production.ProductCategory, aliased as “Category”; if this value is NULL,
return the string “None” instead
Only return rows where the order date occurred in December of ANY year. The
MONTH function should provide a helpful shortcut here.

```sql
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
```

### Q2

The Sales data in our AdventureWorks database is structured almost identically to our Purchasing data. It is so similar, in fact, that we can actually align columns from several of the Sales and Purchasing tables to create a unified dataset in which some rows pertain to Sales, and some to Purchasing. Note that we are talking about combining data by columns rather than by rows here – think UNION. So with that said, your second challenge is to enhance your query from Challenge 1 by “stacking” it with the corresponding Sales data. That may seem daunting, but it is actually WAY easier than it sounds! It turns out that our two Purchasing tables from the Exercise 1 query map to an equivalent Sales table:
• Purchasing.PurchaseOrderDetail maps to Sales.SalesOrderDetail
• Purchasing.PurchaseOrderHeader maps to Sales.SalesOrderHeader
Further, the joins to the product tables work just the same.

```sql
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
WHERE MONTH(soh.OrderDate) = 12;
```

### Q3

1. BusinessEntityID, from Person.Person
2. PersonType, from Person.Person
3. A derived column, aliased as “FullName”, that combines the first, last, and middle names from
Person.Person.
o There should be exactly one space between each of the names.
o If “MiddleName” is NULL and you try to “add” it to the other two names, the result will
be NULL, which isn’t what you want.
o You could use ISNULL to return an empty string if the middle name is NULL, but then
you’d end up with an extra space between first and last name – a space we would have
needed if we had a middle name to work with.
o So what we really need is to apply conditional, IF/THEN type logic; if middle name is
NULL, we just need a space between first name and last name. If not, then we need a
space, the middle name, and then another space. See if you can accomplish this with a
CASE statement.
4. The “AddressLine1” field from Person.Address; alias this as “Address”.
5. The “City” field from Person.Address
6. The “PostalCode” field from Person.Address
7. The “Name” field from Person.StateProvince; alias this as “State”.
8. The “Name” field from Person.CountryRegion; alias this as “Country”.
Only return rows where person type (from Person.Person) is “SP”, OR the postal code begins with a
“9” AND the postal code is exactly 5 characters long AND the country (i.e., “Name” from
Person.CountryRegion) is “United States”.

```sql
SELECT 
	pp.BusinessEntityID, pp.PersonType,
	CASE 
		WHEN pp.MiddleName is null then CONCAT(pp.FirstName, ' ', pp.LastName)
		ELSE CONCAT(pp.FirstName, ' ', pp.MiddleName, ' ', pp.LastName) 
	END  AS FullName,
	pa.AddressLine1 AS Address,
	pa.City AS City,
	pa.PostalCode AS PostalCode,
	sp.Name AS State,
	cr.Name AS Country
FROM Person.Person pp
JOIN Person.BusinessEntityAddress bea ON pp.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address pa ON pa.AddressID = bea.AddressID
JOIN Person.StateProvince sp ON sp.StateProvinceID = pa.StateProvinceID
JOIN Person.CountryRegion cr ON cr.CountryRegionCode = sp.CountryRegionCode
where pp.PersonType = 'SP' OR (pa.PostalCode LIKE '9%' AND LEN(pa.PostalCode) = 5 AND cr.Name = 'United States')
```

### Q4

Enhance your query from Exercise 3 as follows:

1. Join in the HumanResources.Employee table to Person.Person on BusinessEntityID. Note that
many people in the Person.Person table are not employees, and we don’t want to limit our
output to just employees, so choose your join type accordingly.
2. Add the “JobTitle” field from HumanResources.Employee to our output. If it is NULL (as it will be
for people in our Person.Person table who are not employees, return “None”.
3. Add a derived column, aliased as “JobCategory”, that returns different categories based on the
value in the “JobTitle” column as follows:
o If the job title contains the words “Manager”, “President”, or “Executive”, return
“Management”. Applying wildcards with LIKE could be a helpful approach here.
o If the job title contains the word “Engineer”, return “Engineering”.
o If the job title contains the word “Production”, return “Production”.
o If the job title contains the word “Marketing”, return “Marketing”.
o If the job title is NULL, return “NA”.
o If the job title is one of the following exact strings (NOT patterns), return “Human
Resources”: “Recruiter”, “Benefits Specialist”, OR “Human Resources Administrative
Assistant”. You could use a series of ORs here, but the IN keyword could be a nice
shortcut.
o As a default case when none of the other conditions are true, return “Other”.

```sql
select 
	isnull(he.JobTitle, 'None') as JobTitle,
	case
		when he.JobTitle LIKE '%Manager%' OR he.JobTitle LIKE '%Executive%' OR he.JobTitle LIKE '%President%' then 'Management'
		when he.JobTitle LIKE '%Engineer%' then 'Engineering'
		when he.JobTitle LIKE '%Engineer%' then 'Engineering'
		when he.JobTitle LIKE '%Marketing%' then 'Marketing'
		when he.JobTitle is null then 'NA'
		when he.JobTitle IN ('Recruiter', 'Benefits Specialist', 'Human Resources Administrative') then 'Human Resources'
		else 'other'
	end as JobTitle
from Person.Person pp
right join HumanResources.Employee he on he.BusinessEntityID = pp.BusinessEntityID
```

### Q5

Select the number of days remaining until the end of the current month; that is, the difference in days between the current date and the last day of the current month. Your solution should be dynamic: it should work no matter what day, month, or year you run it, which means it needs to calculate the end of the current month based on the current date.

```sql
SELECT DATEDIFF(DAY, GETDATE(), EOMONTH(GETDATE())) as DATE;
```

## AdventureWorksDW2022

### Q1 . What is the total sales?

```sql
SELECT
(SELECT SUM(SalesAmount) FROM FactInternetSales) + (SELECT SUM(SalesAmount) FROM FactResellerSales)
AS TotalSales
```

### Q2. What is the total profit?

```sql
SELECT
((SELECT SUM(SalesAmount) FROM FactInternetSales) + (SELECT SUM(SalesAmount) FROM FactResellerSales))
- ((SELECT SUM(TotalProductCost) FROM FactInternetSales) + (SELECT SUM(TotalProductCost) FROM FactResellerSales))
AS TotalProfits
```

### Q3. What is the total cost amount?

```sql
SELECT
((SELECT SUM(TotalProductCost) FROM FactInternetSales) + (SELECT SUM(TotalProductCost) FROM FactResellerSales))
AS TotalCostAmount
```

### Q4. What is the sales per year?

```sql
SELECT
	PerYear,
	SUM(SalesAmount) AS TotalSales
FROM
	(SELECT
	YEAR(OrderDate) AS PerYear,
	SalesAmount
	FROM FactInternetSales
	UNION ALL
	SELECT
	YEAR(OrderDate) AS PerYear,
	SalesAmount
	FROM FactResellerSales) AS Total
GROUP BY PerYear
ORDER BY PerYear
```

### Q5. What is the average sales per customers?

```sql
Select
fis.CustomerKey,
AVG(fis.SalesAmount) AS AverageSales
FROM FactInternetSales fis
GROUP BY fis.CustomerKey
ORDER BY fis.CustomerKey
```

### Q6. What is the number of products in each category?

```sql
SELECT
dc.ProductCategoryKey,
dc.EnglishProductCategoryName,
COUNT(dp.ProductKey) AS NumberOfProducts
FROM DimProduct dp
JOIN DimProductSubcategory dps ON dps.ProductSubcategoryAlternateKey = dp.ProductSubcategoryKey
JOIN DimProductCategory dc ON dc.ProductCategoryKey = dps.ProductCategoryKey
GROUP BY dc.ProductCategoryKey, dc.EnglishProductCategoryName
```

### Q7. Top 10 Customers with the highest purchase

```sql
SELECT TOP 10
dc.customerKey,
CONCAT(dc.FirstName, ' ', dc.MiddleName, ' ', dc.LastName) AS FullName,
SUM(fis.SalesAmount * fcr.AverageRate) AS Purchase,
dg.CountryRegionCode
FROM DimCustomer dc
RIGHT JOIN FactInternetSales fis ON fis.CustomerKey = dc.CustomerKey
JOIN DimCurrency dcu ON fis.CurrencyKey = dcu.CurrencyKey
JOIN FactCurrencyRate fcr ON dcu.CurrencyKey = fcr.CurrencyKey AND dc.DateFirstPurchase = fcr.Date
JOIN dbo.DimGeography dg ON dg.GeographyKey = dc.GeographyKey
GROUP BY dc.customerKey, CONCAT(dc.FirstName, ' ', dc.MiddleName, ' ', dc.LastName), dg.CountryRegionCode
ORDER BY Purchase desc

SELECT TOP 10
CONCAT(dc.FirstName, ' ', dc.MiddleName, ' ', dc.LastName) AS FullName,
SUM(fis.SalesAmount) AS Purchase
FROM DimCustomer dc
JOIN FactInternetSales fis ON fis.CustomerKey = dc.CustomerKey
GROUP BY CONCAT(dc.FirstName, ' ', dc.MiddleName, ' ', dc.LastName)
ORDER BY Purchase desc
```

### Q8. Top 10 Customers with the highest order

```sql
SELECT TOP 10
dc.customerKey,
CONCAT(dc.FirstName, ' ', dc.MiddleName, ' ', dc.LastName) AS FullName,
COUNT(fis.CustomerKey) AS NumberOfOrder,
dg.CountryRegionCode
FROM DimCustomer dc
RIGHT JOIN FactInternetSales fis ON fis.CustomerKey = dc.CustomerKey
JOIN dbo.DimGeography dg ON dg.GeographyKey = dc.GeographyKey
GROUP BY dc.customerKey, CONCAT(dc.FirstName, ' ', dc.MiddleName, ' ', dc.LastName), dg.CountryRegionCode
ORDER BY NumberOfOrder desc
```

### Q10. Top 10 most sale products

```sql
SELECT TOP 10
dp.EnglishProductName AS ProductsName,
COUNT(fis.ProductKey) + COUNT(frs.ProductKey) AS Products
FROM dbo.FactInternetSales fis
JOIN dbo.DimProduct dp ON fis.ProductKey = dp.ProductKey
JOIN dbo.FactResellerSales frs ON frs.ProductKey = dp.ProductKey
GROUP BY dp.EnglishProductName
ORDER BY COUNT(fis.ProductKey) desc
```

### Q11. What is the total customer?

```sql
SELECT Count(dc.CustomerKey)
FROM dbo.DimCustomer dc
```

### Q12. What is the total transaction?

```sql
SELECT
(SELECT COUNT(SalesOrderNumber) FROM FactInternetSales) + (SELECT COUNT(SalesOrderNumber) FROM FactResellerSales)
AS TotalTransaction
```

### Q13. Distribution of order. Distribution of order is simply to see how many customers are making orders.

```sql
SELECT totalOrders, COUNT(*)
FROM
(SELECT
COUNT(*) AS totalOrders,
fis.customerKey AS NumberOfCustomers
FROM dbo.FactInternetSales fis
GROUP BY fis.customerKey
) Number
GROUP BY totalOrders
ORDER BY COUNT(*) desc
```

### Q14. Ranking customers by sales

--The CASE function is a powerful function in SQL,
--it works like the (IF statement in other programming languages).
--Here use it to rank the customers according to their sales.
--Customers with sales greater than 10000 are ranked Diamond, customers with sales between 5000 and 9999 are ranked Gold,
--customers with sales between 1000 and 4999 are ranked Silver, any customer with sales less than 1000 are ranked Bronze.
--This is useful when the company wants to award membership card or give discount to the top buying customers.

```sql
SELECT
	CONCAT(dc.FirstName, ' ', dc.MiddleName, ' ', dc.LastName) AS FullName,
	SUM(fis.SalesAmount) AS totalSales,
	CASE
	WHEN SUM(fis.SalesAmount) > 10000 then 'Diamond'
	WHEN SUM(fis.SalesAmount) BETWEEN  5000 AND 9999 then 'Gold'
	WHEN SUM(fis.SalesAmount) BETWEEN  1000 AND 4999 then 'Silver'
	ELSE 'Bronze'
	END AS CustomerRank
FROM dbo.FactInternetSales fis
JOIN dbo.DimCustomer dc ON dc.CustomerKey = fis.CustomerKey
GROUP BY
```

---

Other
