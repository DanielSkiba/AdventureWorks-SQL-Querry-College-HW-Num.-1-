--Q1--
SELECT D.Name,COUNT(distinct c.ProductID) as Num_Of_Products
FROM sales.Customer A JOIN Sales.SalesOrderHeader B on A.CustomerID=B.CustomerID
JOIN Sales.SalesOrderDetail C on B.SalesOrderID=C.SalesOrderID
JOIN Sales.Store D on A.StoreID=D.BusinessEntityID
group BY D.Name
ORDER BY 1,2

--Q2--
SELECT D.Name,COUNT(DISTINCT A.SalesOrderID) AS Num_Of_Orders
FROM  Sales.SalesOrderDetail A JOIN Production.Product B on B.ProductID=A.ProductID
JOIN Production.ProductSubcategory C on C.ProductSubcategoryID=B.ProductSubcategoryID
JOIN Production.ProductCategory D on C.ProductCategoryID=D.ProductCategoryID
GROUP BY D.ProductCategoryID,D.Name
HAVING COUNT(DISTINCT A.SalesOrderID)<= ALL (SELECT COUNT(DISTINCT AA.SalesOrderID)
											FROM Sales.SalesOrderDetail AA JOIN Production.Product BB on BB.ProductID=AA.ProductID
											JOIN Production.ProductSubcategory CC on CC.ProductSubcategoryID=BB.ProductSubcategoryID
											JOIN Production.ProductCategory DD on CC.ProductCategoryID=DD.ProductCategoryID
											GROUP BY DD.ProductCategoryID)

--Q3--
SELECT COUNT(distinct A.CustomerID) 'Num Of Customer'
FROM sales.SalesOrderHeader A
WHERE 5 < (SELECT COUNT (B.CustomerID)
			FROM Sales.SalesOrderHeader B
			WHERE A.CustomerID = B.CustomerID
			AND YEAR(B.OrderDate)=2013)
			OR
	25000 < (SELECT avg(C.TotalDue)
			FROM Sales.SalesOrderHeader C
			WHERE A.CustomerID = C.CustomerID
			AND YEAR(C.OrderDate)=2014)


--Q4--
SELECT CountryRegionCode as Country,sum(SOH.SubTotal) AS SubTotal_From_Orders
FROM Sales.SalesTerritory ST JOIN Sales.SalesOrderHeader SOH  on ST.TerritoryID=SOH.TerritoryID
WHERE YEAR(SOH.OrderDate)=2013
GROUP BY CountryRegionCode 
union
SELECT 'Total' ,sum(SOH.SubTotal) AS SubTotal_From_Orders
FROM  Sales.SalesOrderHeader SOH 
WHERE YEAR(SOH.OrderDate)=2013
ORDER BY 2

--Q5--
SELECT COUNT(CASE WHEN ST.CountryRegionCode  NOT IN ('US') THEN SOH.SalesOrderID end) as 'US',
		 COUNT(SOH.SalesOrderID) AS 'ALL'
FROM Sales.SalesOrderHeader SOH inner JOIN Sales.SalesTerritory ST on SOH.TerritoryID=ST.TerritoryID