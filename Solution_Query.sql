--SQL Advance Case Study

use db_SQLCaseStudies

-- SHOWING ALL THE TABLES:

SELECT * FROM DIM_CUSTOMER
SELECT * FROM DIM_DATE
SELECT * FROM DIM_LOCATION
SELECT * FROM DIM_MANUFACTURER
SELECT * FROM FACT_TRANSACTIONS
SELECT * FROM DIM_MODEL


--Q1--BEGIN 
	
SELECT DISTINCT	L.State,L.Country, Date
FROM	DIM_LOCATION L
JOIN	FACT_TRANSACTIONS T
ON		L.IDLocation=T.IDLocation						--Joined to get Location(zipcode, city, country) names for Transactions
WHERE	YEAR(Date) >= 2005								--Filtered the date for year 2005
ORDER BY Date

--Q1--END


--Q2--BEGIN
	
SELECT  State,Country, Manufacturer_Name, 
		COUNT(*) NO_OF_PHONES_BOUGHT									--Counts the number of repetition of the State that is Ranked 1.
FROM	(SELECT	IDCustomer,T.Date, L.Country, L.State,MF.Manufacturer_Name,
				DENSE_RANK() OVER (ORDER BY STATE) Ranks 
		FROM	FACT_TRANSACTIONS T
		JOIN	DIM_MODEL M
		ON		T.IDModel=M.IDModel									--Joined to connect with Manufacturer table to get Manufacturer name.
		JOIN	DIM_MANUFACTURER MF
		ON		M.IDManufacturer=MF.IDManufacturer					--Joined to get Manufacturer names and to filter Samsung
		JOIN	DIM_LOCATION L
		ON		T.IDLocation=L.IDLocation							--Joined to get City, Country from Location table for Transactions,andtocountmostrepeatedstate
		WHERE	L.Country='US' 
				AND 
				MF.Manufacturer_Name='SAMSUNG'
		GROUP BY 
				IDCustomer,T.Date, L.Country,L.State,MF.Manufacturer_Name) AS X
WHERE	RANKS =1														--Filtered to only get the topmost state
GROUP BY 
		State,Country, Manufacturer_Name 

--Q2--END

--Q3--BEGIN     

SELECT		IDModel, ZipCode, State,
			COUNT(IDCustomer) AS No_of_Transactions
FROM		FACT_TRANSACTIONS T
JOIN		DIM_LOCATION L
ON			T.IDLocation = L.IDLocation
GROUP BY	IDModel, ZipCode,State
ORDER BY	IDModel, ZipCode, State

--Q3--END


--Q4--BEGIN

SELECT	TOP 1	T.IDModel,MF.Manufacturer_Name,M.Model_Name,
				TotalPrice/Quantity as [Cheapest Price]		--To get the bottom priced phone
FROM	FACT_TRANSACTIONS T
JOIN	DIM_MODEL M
ON		T.IDModel=M.IDModel
JOIN	DIM_MANUFACTURER MF
ON		M.IDManufacturer=MF.IDManufacturer
ORDER BY 
		[Cheapest Price] ASC

--Q4--END


--Q5--BEGIN

SELECT		top 5 Manufacturer_Name,T.IDModel,
			AVG(TotalPrice) AveragePrice, 
			COUNT(Quantity) SalesQuantity
FROM		FACT_TRANSACTIONS T
INNER JOIN	DIM_MODEL M
ON			T.IDModel=M.IDModel
INNER JOIN	DIM_MANUFACTURER MF
ON			M.IDManufacturer=MF.IDManufacturer
GROUP BY	Manufacturer_Name, T.IDModel
ORDER BY	AveragePrice DESC

--Q5--END


--Q6--BEGIN

SELECT		T.IDCustomer, Customer_Name, Email, Phone,T.Date,	
			AVG(TotalPrice) AVERAGE_AMOUNT
FROM		FACT_TRANSACTIONS T
INNER JOIN	DIM_CUSTOMER C
ON			T.IDCustomer=C.IDCustomer
INNER JOIN	DIM_DATE D
ON			T.Date=D.DATE
WHERE		YEAR=2009
GROUP BY	T.IDCustomer, Customer_Name, Email, Phone,T.Date
HAVING		AVG(TotalPrice)>500

--Q6--END

	
--Q7--BEGIN  

SELECT * FROM (
		SELECT TOP 5 IDMODEL FROM FACT_TRANSACTIONS
		WHERE YEAR(DATE)=2008
		GROUP BY IDMODEL,YEAR(DATE)
		ORDER BY SUM(QUANTITY) DESC) AS A
INTERSECT
SELECT * FROM (
		SELECT TOP 5 IDMODEL FROM FACT_TRANSACTIONS
		WHERE YEAR(DATE)=2009
		GROUP BY IDMODEL,YEAR(DATE)
		ORDER BY SUM(QUANTITY) DESC) AS B
INTERSECT
SELECT * FROM (
		SELECT TOP 5 IDMODEL FROM FACT_TRANSACTIONS
		WHERE YEAR(DATE)=2010
		GROUP BY IDMODEL,YEAR(DATE)
		ORDER BY SUM(QUANTITY) DESC) AS C

--Q7--END	


--Q8--BEGIN

SELECT DISTINCT * FROM		
		(SELECT		T.IDModel, Model_Name, Manufacturer_Name, 
					YEAR(DATE) Years, TotalPrice, 
					DENSE_RANK() OVER (PARTITION BY YEAR(DATE) ORDER BY TOTALPRICE DESC) RANKS
		FROM		FACT_TRANSACTIONS T
		INNER JOIN	DIM_MODEL MD
		ON			T.IDModel=MD.IDModel
		INNER JOIN	DIM_MANUFACTURER MF
		ON			MD.IDManufacturer=MF.IDManufacturer
		WHERE		YEAR(Date)=2009 
					OR 
					YEAR(Date)=2010
		) as A
WHERE RANKS=2

--Q8--END


--Q9--BEGIN
	
SELECT		MF.Manufacturer_Name
FROM		FACT_TRANSACTIONS T
JOIN		DIM_MODEL MD
ON			MD.IDModel=T.IDModel
JOIN		DIM_MANUFACTURER MF
ON			MF.IDManufacturer=MD.IDManufacturer
WHERE		YEAR(DATE) = 2010
GROUP BY	MF.Manufacturer_Name
EXCEPT
SELECT		MF.Manufacturer_Name
FROM		FACT_TRANSACTIONS T
JOIN		DIM_MODEL MD
ON			MD.IDModel=T.IDModel
JOIN		DIM_MANUFACTURER MF
ON			MF.IDManufacturer=MD.IDManufacturer
WHERE		YEAR(DATE) = 2009
GROUP BY	MF.Manufacturer_Name

--Q9--END


--Q10--BEGIN
	
SELECT *, (AVG_PRICE - LAG_PRICE)/LAG_PRICE AS PERCENTAGE_CHANGE FROM (
SELECT *, LAG(AVG_PRICE,1) OVER(PARTITION BY IDCUSTOMER ORDER BY YEAR) AS LAG_PRICE FROM (
SELECT IDCustomer,YEAR(Date) AS YEAR, AVG(TotalPrice) AS AVG_PRICE, SUM(Quantity) AS QUANTITY 
FROM FACT_TRANSACTIONS
WHERE IDCustomer IN (	SELECT TOP 10 IDCustomer FROM FACT_TRANSACTIONS
						GROUP BY IDCustomer
						ORDER BY SUM(TotalPrice) DESC)
GROUP BY IDCustomer, YEAR(Date)
) AS A
) AS B

--Q10--END
	
