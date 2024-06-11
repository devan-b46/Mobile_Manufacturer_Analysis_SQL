# <p align="center">SQL Project for Mobile Manufacturer Analysis</p>


<p align="center"><img src=images/logo.jpg height="300"></p>

## Business Scenario

The database “Cellphones Information” contains details on cell phone sales or transactions.
Detailes stored are: Dim_manufacturer, Dim_model, Dim_customer, Dim_Location and Fact_Transactions.
The first four store entries for the respective elements and Fact_Transactions stores all the information about sales of specific cellphones

---

### **Tools Used:** Excel, SSMS (SQL Server Management Studio)


### ER Relationship:

<img src=images/sqldatabaseschema.png height="450">






---
### Questions I Wanted To Answer From the Dataset:

1. List all the states in which we have customers who have bought cellphones from 2005 till today.
2. What state in the US is buying the most 'Samsung' cell phones?
3. Show the number of transactions for each model per zip code per state.
4. Show the cheapest cellphone (Output should contain the price also)
5. Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.
6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500
7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010
8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.
9. Show the manufacturers that sold cellphones in 2010 but did not in 2009.
10. Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.
 
 
 
 

### **Queries for above questions** 
**1. List all the states in which we have customers who have bought cellphones from 2005 till today.**
```sql
SELECT DISTINCT	L.State,L.Country, Date
FROM	DIM_LOCATION L
JOIN	FACT_TRANSACTIONS T
ON      L.IDLocation=T.IDLocation					
WHERE	YEAR(Date) >= 2005							
ORDER BY Date
```
**2. What state in the US is buying the most 'Samsung' cell phones?**
```sql
SELECT  State,Country, Manufacturer_Name, 
		COUNT(*) NO_OF_PHONES_BOUGHT								
FROM	(SELECT	IDCustomer,T.Date, L.Country, L.State,MF.Manufacturer_Name,
				DENSE_RANK() OVER (ORDER BY STATE) Ranks 
		FROM	FACT_TRANSACTIONS T
		JOIN	DIM_MODEL M
		ON      T.IDModel=M.IDModel									
		JOIN	DIM_MANUFACTURER MF
		ON      M.IDManufacturer=MF.IDManufacturer					
		JOIN	DIM_LOCATION L
		ON      T.IDLocation=L.IDLocation							
		WHERE	L.Country='US' 
				AND 
                MF.Manufacturer_Name='SAMSUNG'
		        GROUP BY 
        IDCustomer,T.Date, L.Country,L.State,MF.Manufacturer_Name) AS X
WHERE	RANKS =1													
GROUP BY 
		State,Country, Manufacturer_Name 

```


**3. Show the number of transactions for each model per zip code per state.**
```sql
SELECT		IDModel, ZipCode, State, COUNT(IDCustomer) AS No_of_Transactions
FROM		FACT_TRANSACTIONS T
JOIN		DIM_LOCATION L
ON		T.IDLocation = L.IDLocation
GROUP BY	IDModel, ZipCode,State
ORDER BY	IDModel, ZipCode, State
```

**4. Show the cheapest cellphone (Output should contain the price also)**
```sql
SELECT	TOP 1	T.IDModel,MF.Manufacturer_Name,M.Model_Name,
				TotalPrice/Quantity as [Cheapest Price]		
FROM	FACT_TRANSACTIONS T
JOIN	DIM_MODEL M
ON	T.IDModel=M.IDModel
JOIN	DIM_MANUFACTURER MF
ON	M.IDManufacturer=MF.IDManufacturer
ORDER BY 
		[Cheapest Price] ASC
```

**5. Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.**
```sql

SELECT		top 5 Manufacturer_Name,T.IDModel,
			AVG(TotalPrice) AveragePrice, 
			COUNT(Quantity) SalesQuantity
FROM		FACT_TRANSACTIONS T
INNER JOIN	DIM_MODEL M
ON		T.IDModel=M.IDModel
INNER JOIN	DIM_MANUFACTURER MF
ON		M.IDManufacturer=MF.IDManufacturer
GROUP BY	Manufacturer_Name, T.IDModel
ORDER BY	AveragePrice DESC

```

**6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500**
```sql

SELECT		T.IDCustomer, Customer_Name, Email, Phone,T.Date,	
			AVG(TotalPrice) AVERAGE_AMOUNT
FROM		FACT_TRANSACTIONS T
INNER JOIN	DIM_CUSTOMER C
ON		T.IDCustomer=C.IDCustomer
INNER JOIN	DIM_DATE D
ON		T.Date=D.DATE
WHERE		YEAR=2009
GROUP BY	T.IDCustomer, Customer_Name, Email, Phone,T.Date
HAVING		AVG(TotalPrice)>500

```

**7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010**
```sql
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

```

**8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.**
```sql

SELECT DISTINCT * FROM		
		(SELECT		T.IDModel, Model_Name, Manufacturer_Name, 
					YEAR(DATE) Years, TotalPrice, 
					DENSE_RANK() OVER (PARTITION BY YEAR(DATE) ORDER BY TOTALPRICE DESC) RANKS
		FROM		FACT_TRANSACTIONS T
		INNER JOIN	DIM_MODEL MD
		ON		T.IDModel=MD.IDModel
		INNER JOIN	DIM_MANUFACTURER MF
		ON		MD.IDManufacturer=MF.IDManufacturer
		WHERE		YEAR(Date)=2009 
					    OR 
					    YEAR(Date)=2010
		) as A
WHERE RANKS=2

```

**9. Show the manufacturers that sold cellphones in 2010 but did not in 2009.**
```sql
SELECT		MF.Manufacturer_Name
FROM		FACT_TRANSACTIONS T
JOIN		DIM_MODEL MD
ON		MD.IDModel=T.IDModel
JOIN		DIM_MANUFACTURER MF
ON		MF.IDManufacturer=MD.IDManufacturer
WHERE		YEAR(DATE) = 2010
GROUP BY	MF.Manufacturer_Name
EXCEPT
SELECT		MF.Manufacturer_Name
FROM		FACT_TRANSACTIONS T
JOIN		DIM_MODEL MD
ON		MD.IDModel=T.IDModel
JOIN		DIM_MANUFACTURER MF
ON		MF.IDManufacturer=MD.IDManufacturer
WHERE		YEAR(DATE) = 2009
GROUP BY	MF.Manufacturer_Name

```

**10. Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.**
```sql
SELECT *, (AVG_PRICE - LAG_PRICE)/LAG_PRICE AS PERCENTAGE_CHANGE FROM (
    SELECT *, LAG(AVG_PRICE,1) OVER(PARTITION BY IDCUSTOMER ORDER BY YEAR) AS LAG_PRICE FROM (
      SELECT IDCustomer,YEAR(Date) AS YEAR,
              AVG(TotalPrice) AS AVG_PRICE, SUM(Quantity) AS     QUANTITY 
      FROM    FACT_TRANSACTIONS
      WHERE   IDCustomer IN (	SELECT TOP 10 IDCustomer FROM FACT_TRANSACTIONS
    						GROUP BY IDCustomer
    						ORDER BY SUM(TotalPrice) DESC)
    GROUP BY IDCustomer, YEAR(Date)
    ) AS A
) AS B

```

---
### **Conclusion**

By successfully tackling all the questions in this case study,  I've gained valuable insights into the cellphone sales data.  

The constructed database schema provides a solid foundation for further analysis, while the formulated SQL queries have effectively extracted key information regarding customer locations, sales trends by model and manufacturer, pricing strategies, and high-value customers. 

These findings can be leveraged to optimize marketing campaigns, identify areas for growth, and make data-driven decisions to maximize sales and customer satisfaction. 

This project has demonstrably strengthened my expertise in SQL and its application to real-world business scenarios.
