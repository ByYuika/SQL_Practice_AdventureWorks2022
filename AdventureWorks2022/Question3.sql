SELECT pp.BusinessEntityID, pp.PersonType,
	 IIF (pp.MiddleName is null, CONCAT(pp.FirstName, ' ', pp.LastName),  CONCAT (pp.FirstName, ' ', pp.MiddleName,' ', pp.LastName) ) AS FullName,
	 pa.AddressLine1 AS address
FROM Person.Person pp
LEFT JOIN Person.Address pa ON pp.rowguid = pa.rowguid;

select *
from Person.Address

select *
from Person.Person