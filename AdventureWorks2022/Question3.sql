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
WHERE pp.PersonType = 'SP' OR (pa.PostalCode LIKE '9%' AND LEN(pa.PostalCode) = 5 AND cr.Name = 'United States')
