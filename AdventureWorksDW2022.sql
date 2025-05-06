--Q1 . What is the total sales?
SELECT 
	(SELECT SUM(SalesAmount) FROM FactInternetSales) + (SELECT SUM(SalesAmount) FROM FactResellerSales)
AS TotalSales

--Q2. What is the total profit?
SELECT 
	((SELECT SUM(SalesAmount) FROM FactInternetSales) + (SELECT SUM(SalesAmount) FROM FactResellerSales)) 
	- ((SELECT SUM(TotalProductCost) FROM FactInternetSales) + (SELECT SUM(TotalProductCost) FROM FactResellerSales)) 
AS TotalProfits

--Q3. What is the total cost amount?
SELECT 
	 ((SELECT SUM(TotalProductCost) FROM FactInternetSales) + (SELECT SUM(TotalProductCost) FROM FactResellerSales)) 
AS TotalCostAmount

--Q4. What is the sales per year?
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

--Q5. What is the average sales per customers?
Select 
	fis.CustomerKey,
	AVG(fis.SalesAmount) AS AverageSales
FROM FactInternetSales fis
GROUP BY fis.CustomerKey
ORDER BY fis.CustomerKey

--Q6. What is the number of products in each category?
SELECT 
    dc.ProductCategoryKey,
	dc.EnglishProductCategoryName,
	COUNT(dp.ProductKey) AS NumberOfProducts
FROM DimProduct dp
JOIN DimProductSubcategory dps ON dps.ProductSubcategoryAlternateKey = dp.ProductSubcategoryKey
JOIN DimProductCategory dc ON dc.ProductCategoryKey = dps.ProductCategoryKey
GROUP BY dc.ProductCategoryKey, dc.EnglishProductCategoryName

--Q7. Top 10 Customers with the highest purchase
SELECT TOP 10
	CONCAT(dc.FirstName, ' ', dc.MiddleName, ' ', dc.LastName) AS FullName,
	SUM(fis.SalesAmount) AS Purchase
FROM DimCustomer dc
JOIN FactInternetSales fis ON fis.CustomerKey = dc.CustomerKey
GROUP BY CONCAT(dc.FirstName, ' ', dc.MiddleName, ' ', dc.LastName)
ORDER BY Purchase desc

--Q8. Top 10 Customers with the highest order
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

--Q10. Top 10 most sale products
SELECT TOP 10
	dp.EnglishProductName AS ProductsName,
	COUNT(fis.ProductKey) + COUNT(frs.ProductKey) AS Products
FROM dbo.FactInternetSales fis 
JOIN dbo.DimProduct dp ON fis.ProductKey = dp.ProductKey
JOIN dbo.FactResellerSales frs ON frs.ProductKey = dp.ProductKey
GROUP BY dp.EnglishProductName
ORDER BY COUNT(fis.ProductKey) desc

--Q11. What is the total customer?
SELECT Count(dc.CustomerKey)
FROM dbo.DimCustomer dc

--Q12. What is the total transaction?
SELECT 
	(SELECT COUNT(SalesOrderNumber) FROM FactInternetSales) + (SELECT COUNT(SalesOrderNumber) FROM FactResellerSales)
AS TotalTransaction

--Q13. Distribution of order. Distribution of order is simply to see how many customers are making orders.
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

--Q14. Ranking customers by sales
--The CASE function is a powerful function in SQL, 
--it works like the (IF statement in other programming languages). 
--Here use it to rank the customers according to their sales. 
--Customers with sales greater than 10000 are ranked Diamond, customers with sales between 5000 and 9999 are ranked Gold,
--customers with sales between 1000 and 4999 are ranked Silver, any customer with sales less than 1000 are ranked Bronze.
--This is useful when the company wants to award membership card or give discount to the top buying customers.

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
GROUP BY dc.CustomerKey, CONCAT(dc.FirstName, ' ', dc.MiddleName, ' ', dc.LastName) 