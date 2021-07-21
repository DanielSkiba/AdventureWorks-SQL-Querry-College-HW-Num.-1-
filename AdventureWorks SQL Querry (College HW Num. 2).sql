/*2*/
SELECT year(o.OrderDate) AS Year, MONTH(o.OrderDate) AS Month,
       COUNT(distinct o.customerID) AS Cus_Num,
	   sum(o.Quantity*o.UnitPrice+o.Shipping) AS Total_Profit, 
	   sum(o.Quantity*o.UnitPrice+o.Shipping)/COUNT(distinct o.CustomerID) AS AVG_Per_Cus
FROM ORDERs o
GROUP BY year(o.OrderDate),MONTH(o.OrderDate)

/*3*/
SELECT year,Num_Of_Products,COUNT(customerid) AS Num_Of_Cus
FROM (SELECT year(OrderDate) AS Year,CustomerID,COUNT( Distinct ProductID) AS Num_Of_Products
		FROM ORDERs
		GROUP BY year(OrderDate),MONTH(OrderDate),CustomerID) A
GROUP BY year,Num_Of_Products
ORDER BY year,Num_Of_Products

/*4*/
SELECT CASE WHEN Vetek_In_Month<6 THEN 'Less THEN 6 Months'
			WHEN Vetek_In_Month<=12 THEN '6-12 Months'
			WHEN Vetek_In_Month<=18 THEN '12-18 Months'
			ELSE 'More Then 18 Months' END AS Vetek,
			COUNT(customerid) AS Num_Of_Cus
FROM (SELECT CustomerID,datediff(month,min(ORDERdate),'2021-05-31') AS Vetek_In_Month
	  FROM ORDERs
	  GROUP BY CustomerID) A
GROUP BY CASE WHEN Vetek_In_Month<6 THEN 'Less THEN 6 Months'
			WHEN Vetek_In_Month<=12 THEN '6-12 Months'
			WHEN Vetek_In_Month<=18 THEN '12-18 Months'
			ELSE 'More Then 18 Months' END

/*5-JOIN*/
SELECT a.year,b.CategoryName,CAST(Cat_Profit/Total_Profit AS decimal (8,3)) AS Part_Of_Total
FROM (SELECT year(ORDERdate) AS year,sum(Quantity*UnitPrice+Shipping) AS Total_Profit
		FROM ORDERs
		GROUP BY year(ORDERdate)) A JOIN 
	(SELECT year(ORDERdate) AS year,CategoryName,sum(Quantity*UnitPrice+Shipping) AS Cat_Profit
		FROM ORDERs o JOIN Products p 
		ON o.ProductID=p.ProductID
		GROUP BY year(ORDERdate),CategoryName) B ON a.year=b.year

/*5-partition*/
SELECT year,CategoryName,CAST(Cat_Sum/sum(Cat_Sum) over(partitiON BY year) AS decimal(8,3)) AS Part_Of_Total
FROM (SELECT year(ORDERdate) year,p.CategoryName,sum(o.Quantity*o.UnitPrice+o.Shipping) AS Cat_Sum
	FROM ORDERs o JOIN Products p 
	ON o.ProductID=p.ProductID
	GROUP BY year(ORDERdate),p.CategoryName) A

/*6*/
SELECT a.year,a.Month,Bags /Allp*100 AS Precent 
FROM 
(SELECT year(ORDERdate) AS year ,Month(ORDERdate) AS Month,sum(o.Quantity*o.UnitPrice+o.Shipping) AS Bags
 FROM ORDERs o JOIN products p ON o.productid=p.ProductID
 where  p.QuantityPerUnit like '% bags%'
 GROUP BY year(ORDERdate),Month(ORDERdate)) A 
JOIN 
(SELECT year(ORDERdate) AS year,Month(ORDERdate) AS Month,sum(o.Quantity*o.UnitPrice+o.Shipping) AS Allp
 FROM ORDERs o 
 GROUP BY year(ORDERdate),Month(ORDERdate)) B 
ON a.year=b.year and a.Month=b.Month

/*7*/
SELECT lASt.customerid,First_Total_Order,LASt_Total_Order
FROM (SELECT customerid,Total_Order AS First_Total_Order
FROM (SELECT ORDERid,customerid,Total_Order,ORDERdate,rank() over(partitiON BY customerid ORDER BY ORDERdate ) AS rank	
	  FROM (SELECT  ORDERid,customerid,sum(Quantity*UnitPrice+Shipping) AS Total_Order,ORDERdate
			FROM Orders
			WHERE customerid in (SELECT customerid
								  FROM ORDERs
								  GROUP BY customerid
								  having COUNT(*)>=2)
			GROUP BY ORDERid,customerid,ORDERdate)a ) b
WHERE RANK = 1) first
JOIN
(SELECT	customerid,Total_Order AS LASt_Total_Order
FROM (SELECT ORDERid,customerid,Total_Order,ORDERdate,rank() over(partitiON BY customerid ORDER BY ORDERdate DESC) AS rank	
	  FROM (SELECT  ORDERid,customerid,sum(Quantity*UnitPrice+Shipping) AS Total_Order,ORDERdate
			FROM Orders
			WHERE customerid in (SELECT customerid
								  FROM ORDERs
								  GROUP BY customerid
								  having COUNT(*)>=2)
			GROUP BY ORDERid,customerid,ORDERdate)a ) b
WHERE RANK = 1) lASt
ON first.customerid=lASt.customerid

/*8*/
SELECT CASE WHEN days<31 THEN 'Month'
			WHEN days<=180 THEN '6 Months'
			WHEN days<=365 THEN 'Year'
			ELSE 'Over_Year' END AS hefresh,
			COUNT(customerid) AS Num_Of_Cus
FROM (SELECT A.CustomerID,AVG(DATEDIFF(day,ORDERdate,next)) AS days
	  --SELECT A.CustomerID,OrderDate,Next,DATEDIFF(day,ORDERdate,next)
		FROM (SELECT CustomerID,OrderDate,lead(ORDERdate) over (ORDER BY customerid,ORDERdate)AS Next,RANK() over (partitiON BY customerid ORDER BY ORDERdate DESC) AS rank
				FROM ORDERs) A
		where rank>1
		GROUP BY A.CustomerID
		HAVING COUNT(*)>=2) B
GROUP BY CASE WHEN days<31 THEN 'Month'
			WHEN days<=180 THEN '6 Months'
			WHEN days<=365 THEN 'Year'
			ELSE 'Over_Year' END