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
