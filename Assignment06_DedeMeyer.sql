--*************************************************************************--
-- Title: Assignment06
-- Author: DedeMeyer
-- Desc: This file demonstrates how to use VIEWs
-- Change Log: When,Who,What
-- 2020-08-11,DedeMeyer,CREATEd File
--**************************************************************************--
BEGIN Try
	Use Master;
	If Exists(SELECT Name FROM SysDatabases Where Name = 'Assignment06DB_DedeMeyer')
	 BEGIN 
	  ALTER Database [Assignment06DB_DedeMeyer] set Single_user With Rollback Immediate;
	  DROP Database Assignment06DB_DedeMeyer;
	 End
	CREATE Database Assignment06DB_DedeMeyer;
End Try
BEGIN Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_DedeMeyer;

-- CREATE TABLEs (Module 01)-- 
CREATE TABLE Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

CREATE TABLE Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

CREATE TABLE Employees -- New TABLE
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

CREATE TABLE Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- ADD CONSTRAINTs (Module 02) -- 
BEGIN  -- Categories
	ALTER TABLE Categories 
	 ADD CONSTRAINT pkCategories 
	  PRIMARY KEY (CategoryId);

	ALTER TABLE Categories 
	 ADD CONSTRAINT ukCategories 
	  UNIQUE (CategoryName);
End
go 

BEGIN -- Products
	ALTER TABLE Products 
	 ADD CONSTRAINT pkProducts 
	  PRIMARY KEY (ProductId);

	ALTER TABLE Products 
	 ADD CONSTRAINT ukProducts 
	  UNIQUE (ProductName);

	ALTER TABLE Products 
	 ADD CONSTRAINT fkProductsToCategories 
	  FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId);

	ALTER TABLE Products 
	 ADD CONSTRAINT ckProductUnitPriceZeroOrHigher 
	  CHECK (UnitPrice >= 0);
End
go

BEGIN -- Employees
	ALTER TABLE Employees
	 ADD CONSTRAINT pkEmployees 
	  PRIMARY KEY (EmployeeId);

	ALTER TABLE Employees 
	 ADD CONSTRAINT fkEmployeesToEmployeesManager 
	  FOREIGN KEY (ManagerId) REFERENCES Employees(EmployeeId);
End
go

BEGIN -- Inventories
	ALTER TABLE Inventories 
	 ADD CONSTRAINT pkInventories 
	  PRIMARY KEY (InventoryId);

	ALTER TABLE Inventories
	 ADD CONSTRAINT dfInventoryDate
	  Default GetDate() For InventoryDate;

	ALTER TABLE Inventories
	 ADD CONSTRAINT fkInventoriesToProducts
	  FOREIGN KEY (ProductId) REFERENCES Products(ProductId);

	ALTER TABLE Inventories 
	 ADD CONSTRAINT ckInventoryCountZeroOrHigher 
	  CHECK ([Count] >= 0);

	ALTER TABLE Inventories
	 ADD CONSTRAINT fkInventoriesToEmployees
	  FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
INSERT INTO Categories 
(CategoryName)
SELECT CategoryName 
 FROM Northwind.dbo.Categories
 ORDER BY CategoryID;
go

INSERT INTO Products
(ProductName, CategoryID, UnitPrice)
SELECT ProductName,CategoryID, UnitPrice 
 FROM Northwind.dbo.Products
  ORDER BY ProductID;
go

INSERT INTO Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
SELECT E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 FROM Northwind.dbo.Employees as E
  ORDER BY E.EmployeeID;
go

INSERT INTO Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
SELECT '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
FROM Northwind.dbo.Products
UNION
SELECT '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
FROM Northwind.dbo.Products
UNION
SELECT '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
FROM Northwind.dbo.Products
ORDER BY 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories TABLEs
SELECT * FROM Categories;
go
SELECT * FROM Products;
go
SELECT * FROM Employees;
go
SELECT * FROM Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you VIEWs, but be descriptive and consistent
 2) You can use your working code FROM assignment 5 for much of this assignment
 3) You must use the BASIC VIEWs for each TABLE after they are CREATEd in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you CREATE BACIC VIEWs to show data FROM each TABLE in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) CREATE one VIEW per TABLE!
--		  3) Use SchemaBinding to protect the VIEWs FROM being orphaned!

----First create and check the code you want for your view
--CREATE --DROP
--TABLE Categories
--([CategoryID] [int] IDENTITY(1,1) NOT NULL 
--,[CategoryName] [nvarchar](100) NOT NULL
--);
--GO

--BEGIN  -- Categories
--	ALTER TABLE Categories 
--	 ADD CONSTRAINT pkCategories 
--	  PRIMARY KEY (CategoryId);

--	ALTER TABLE Categories 
--	 ADD CONSTRAINT ukCategories 
--	  UNIQUE (CategoryName);
--END
--GO 
--INSERT INTO Categories 
--(CategoryName)
--SELECT CategoryName 
-- FROM Northwind.dbo.Categories
-- ORDER BY CategoryID;
--GO

--SELECT * FROM Categories

--Then create the view:

GO
CREATE
VIEW [dbo].[vCategories]
WITH SCHEMABINDING
AS
	SELECT
	 [CategoryID]  
	,[CategoryName] 
	FROM dbo.Categories
	;
GO

SELECT * FROM Categories
SELECT * FROM [dbo].[vCategories]

--2nd table
--CREATE TABLE Products
--([ProductID] [int] IDENTITY(1,1) NOT NULL 
--,[ProductName] [nvarchar](100) NOT NULL 
--,[CategoryID] [int] NULL  
--,[UnitPrice] [mOney] NOT NULL
--);
--GO

--BEGIN -- Products
--	ALTER TABLE Products 
--	 ADD CONSTRAINT pkProducts 
--	  PRIMARY KEY (ProductId);

--	ALTER TABLE Products 
--	 ADD CONSTRAINT ukProducts 
--	  UNIQUE (ProductName);

--	ALTER TABLE Products 
--	 ADD CONSTRAINT fkProductsToCategories 
--	  FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId);

--	ALTER TABLE Products 
--	 ADD CONSTRAINT ckProductUnitPriceZeroOrHigher 
--	  CHECK (UnitPrice >= 0);
--END
--GO

--INSERT INTO Products
--(ProductName, CategoryID, UnitPrice)
--SELECT ProductName,CategoryID, UnitPrice 
-- FROM Northwind.dbo.Products
--  ORDER BY ProductID;
--GO

GO
CREATE
VIEW [dbo].[vProducts]
WITH SCHEMABINDING
AS
	SELECT
	 [ProductID]  
	,[ProductName] 
	,[CategoryID]
	,[UnitPrice]
	FROM .dbo.Products
	;
GO

SELECT * FROM Products
SELECT * FROM [dbo].[vProducts]

--3rd table
--CREATE TABLE Employees 
--([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
--,[EmployeeFirstName] [nvarchar](100) NOT NULL
--,[EmployeeLastName] [nvarchar](100) NOT NULL 
--,[ManagerID] [int] NULL  
--);
--GO

--BEGIN -- Employees
--	ALTER TABLE Employees
--	 ADD CONSTRAINT pkEmployees 
--	  PRIMARY KEY (EmployeeId);

--	ALTER TABLE Employees 
--	 ADD CONSTRAINT fkEmployeesToEmployeesManager 
--	  FOREIGN KEY (ManagerId) REFERENCES Employees(EmployeeId);
--END
--GO

--INSERT INTO Employees
--(EmployeeFirstName, EmployeeLastName, ManagerID)
--SELECT E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
-- FROM Northwind.dbo.Employees AS E
--  ORDER BY E.EmployeeID;
--GO

CREATE
VIEW [dbo].[vEmployees]
WITH SCHEMABINDING
AS
	SELECT
	 [EmployeeID]  
	,[EmployeeFirstName] 
	,[EmployeeLastName]
	,[ManagerID]
	FROM .dbo.Employees
	;
GO

SELECT * FROM Employees
SELECT * FROM [dbo].[vEmployees]

--4th table
--CREATE TABLE Inventories
--([InventoryID] [int] IDENTITY(1,1) NOT NULL
--,[InventoryDate] [Date] NOT NULL
--,[EmployeeID] [int] NOT NULL -- New Column
--,[ProductID] [int] NOT NULL
--,[Count] [int] NOT NULL
--);
--GO

--BEGIN -- Inventories
--	ALTER TABLE Inventories 
--	 ADD CONSTRAINT pkInventories 
--	  PRIMARY KEY (InventoryId);

--	ALTER TABLE Inventories
--	 ADD CONSTRAINT dfInventoryDate
--	  DEFAULT GetDate() FOR InventoryDate;

--	ALTER TABLE Inventories
--	 ADD CONSTRAINT fkInventoriesToProducts
--	  FOREIGN KEY (ProductId) REFERENCES Products(ProductId);

--	ALTER TABLE Inventories 
--	 ADD CONSTRAINT ckInventoryCountZeroOrHigher 
--	  CHECK ([Count] >= 0);

--	ALTER TABLE Inventories
--	 ADD CONSTRAINT fkInventoriesToEmployees
--	  FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId);
--END 
--GO

--INSERT INTO Inventories
--(InventoryDate, EmployeeID, ProductID, [Count])
--SELECT '20170101' AS InventoryDate, 5 AS EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 AS RandomValue
--FROM Northwind.dbo.Products
--UNION
--SELECT '20170201' AS InventoryDate, 7 AS EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 AS RandomValue
--FROM Northwind.dbo.Products
--UNION
--SELECT '20170301' AS InventoryDate, 9 AS EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 AS RandomValue
--FROM Northwind.dbo.Products
--ORDER BY 1, 2
--GO

GO
CREATE
VIEW [dbo].[vInventories]
WITH SCHEMABINDING
AS
	SELECT
	 [InventoryID]  
	,[InventoryDate] 
	,[EmployeeID]
	,[ProductID]
	,[Count]
	FROM .dbo.Inventories
	;
GO

SELECT * FROM Inventories
SELECT * FROM [dbo].[vInventories]

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT SELECT data 
-- FROM each TABLE, but can SELECT data FROM each VIEW?

DENY SELECT ON Categories TO PUBLIC;
GRANT SELECT ON [dbo].[vCategories] TO PUBLIC;

SELECT * FROM Categories
SELECT * FROM [dbo].[vCategories]

DENY SELECT ON Products TO PUBLIC;
GRANT SELECT ON [dbo].[vProducts] TO PUBLIC;

SELECT * FROM Products
SELECT * FROM [dbo].[vProducts]

DENY SELECT ON Employees TO PUBLIC;
GRANT SELECT ON [dbo].[vEmployees] TO PUBLIC;

SELECT * FROM Employees
SELECT * FROM [dbo].[vEmployees]

DENY SELECT ON Inventories TO PUBLIC;
GRANT SELECT ON [dbo].[vInventories] TO PUBLIC;

SELECT * FROM Inventories
SELECT * FROM [dbo].[vInventories]

-- Question 3 (10 pts): How can you CREATE a VIEW to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows SELECTed FROM the VIEW:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

--SELECT 
--	 CategoryName 
--	,ProductName 
--	,UnitPrice
--FROM Categories 
--	JOIN Products
--ON Categories.CategoryID = Products.CategoryID

GO
CREATE
VIEW [dbo].[vCategoryNameProductNameProductPrice]
WITH SCHEMABINDING
AS
SELECT 
	 [CategoryName] 
	,[ProductName] 
	,[UnitPrice]
FROM dbo.Categories 
	JOIN dbo.Products
ON Categories.CategoryID = Products.CategoryID
GO

SELECT * FROM [dbo].[vCategoryNameProductNameProductPrice] ORDER BY CategoryName

-- Question 4 (10 pts): How can you CREATE a VIEW to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows SELECTed FROM the VIEW:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

GO
CREATE
VIEW [dbo].[vProductCountPerInventoryDate]
WITH SCHEMABINDING
AS
SELECT 
	 [ProductName] 
	,[InventoryDate] 
	,[Count] =MAX(count)
FROM dbo.Products 
	JOIN dbo.Inventories
ON Products.ProductID = Inventories.ProductID
GROUP BY
	 [ProductName] 
	,[InventoryDate] 
	,[Count] 
GO

SELECT * FROM [dbo].[vProductCountPerInventoryDate]

-- Question 5 (10 pts): How can you CREATE a VIEW to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows SELECTed FROM the VIEW:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

GO
CREATE
VIEW [dbo].[vEmployeeWhoTookInventoryPerInventoryDate]
WITH SCHEMABINDING
AS
SELECT
DISTINCT
 [Inventory Date] = I.InventoryDate
,[Employee Name] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
FROM dbo.Inventories AS I
JOIN dbo.Employees AS E
ON E.EmployeeID = I.EmployeeID
;
GO
SELECT * FROM [dbo].[vEmployeeWhoTookInventoryPerInventoryDate]

-- Question 6 (10 pts): How can you CREATE a VIEW show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows SELECTed FROM the VIEW:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

GO
CREATE
VIEW [dbo].[vQuantityProductsByCategoryPerInventoryDate]
WITH SCHEMABINDING
AS
SELECT 
	 [Category] = C.CategoryName
	,[Prodcuts] = P.ProductName
	,[Inventory Date] = I.InventoryDate
	,[Quantity] = SUM(Count)
FROM dbo.Categories AS C
INNER JOIN dbo.Products AS P
ON C.CategoryID = P.CategoryID
INNER JOIN dbo.Inventories AS I
ON P.ProductID = I.ProductID 
GROUP BY
	 C.CategoryName
	,P.ProductName 
	,I.InventoryDate 
	;
GO
SELECT * FROM [dbo].[vQuantityProductsByCategoryPerInventoryDate]

-- Question 7 (10 pts): How can you CREATE a VIEW to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows SELECTed FROM the VIEW:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


GO
CREATE
VIEW [dbo].[vQuantityProductsByCategoryPerInventoryDateEmployeeWhoTookCount]
WITH SCHEMABINDING
AS
SELECT 
TOP 100000000000
 [Category] = C.CategoryName
,[Prodcuts] = P.ProductName
,[Inventory Date] = I.InventoryDate
,[Quantity] = I.[Count]
,[Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
FROM dbo.Categories AS C
INNER JOIN dbo.Products AS P
ON C.CategoryID = P.CategoryID
INNER JOIN dbo.Inventories AS I
ON P.ProductID = I.ProductID
INNER JOIN dbo.Employees AS E
ON I.EmployeeID = E.EmployeeID
ORDER BY
3,1,2,5
;
GO
SELECT * FROM [dbo].[vQuantityProductsByCategoryPerInventoryDateEmployeeWhoTookCount]

-- Question 8 (10 pts): How can you CREATE a VIEW to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows SELECTed FROM the VIEW:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

GO
CREATE
VIEW [dbo].[vQuantityChaiChangPerInventoryDateEmployeeWhoTookCount]
WITH SCHEMABINDING
AS
SELECT
TOP 100000000000000
 [Category] = C.CategoryName
,[Product] = P.ProductName 
,[Inventory Date] = I.InventoryDate
,[Quantity] = I.[Count]
,[Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
FROM dbo.Categories AS C
INNER JOIN dbo.Products AS P 
ON C.CategoryID = P.CategoryID
INNER JOIN dbo.Inventories AS I
ON P.ProductID = I.ProductID
INNER JOIN dbo.Employees AS E
ON I.EmployeeID = E.EmployeeID
WHERE P.ProductName IN 
	(SELECT ProductName FROM dbo.Products WHERE (ProductID ='1') OR (ProductID ='2'))
ORDER BY 3,1,2
;
GO

SELECT * FROM [dbo].[vQuantityChaiChangPerInventoryDateEmployeeWhoTookCount]

-- Question 9 (10 pts): How can you CREATE a VIEW to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows SELECTed FROM the VIEW:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

GO
CREATE
VIEW [dbo].[vEmployeesUnderManager]
WITH SCHEMABINDING
AS
SELECT
TOP 10000
 [Manager] = M.EmployeeFirstName + ' ' + M.EmployeeLastName
,[Employe] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
 FROM dbo.Employees AS E
  INNER JOIN dbo.Employees M
   ON E.ManagerID  = M.EmployeeID
 ORDER BY 1,2
 ;   
GO
SELECT * FROM [dbo].[vEmployeesUnderManager]

-- Question 10 (10 pts): How can you CREATE one VIEW to show all the data FROM all four 
-- BASIC VIEWs?

-- Here is an example of some rows SELECTed FROM the VIEW:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan
GO
CREATE
VIEW [dbo].[vInventoriesByProductsByCategoriesByEmployees]
WITH SCHEMABINDING
AS
SELECT
 C.[CategoryID] 
,C.[CategoryName]
,P.[ProductID]
,P.[ProductName]
,P.[UnitPrice]
,I.[InventoryID]
,I.[InventoryDate]
,I.[Count]
,E.[EmployeeID]
,[Employee]= E.EmployeeFirstName + ' ' + E.EmployeeLastName
,[Manager]= M.EmployeeFirstName + ' ' + M.EmployeeLastName
FROM dbo.Categories AS C
INNER JOIN dbo.Products AS P
ON C.CategoryID = P.CategoryID
INNER JOIN dbo.Inventories AS I
ON P.ProductID = I.ProductID
INNER JOIN dbo.Employees AS E
ON I.EmployeeID = E.EmployeeID
INNER JOIN dbo.Employees M
ON E.ManagerID  = M.EmployeeID
;
GO

SELECT * FROM [dbo].[vInventoriesByProductsByCategoriesByEmployees]

-- Test your VIEWs (NOTE: You must change the names to match yours as needed!)
SELECT * FROM [dbo].[vCategories]
SELECT * FROM [dbo].[vProducts]
SELECT * FROM [dbo].[vInventories]
SELECT * FROM [dbo].[vEmployees]

SELECT * FROM [dbo].[vCategoryNameProductNameProductPrice]
SELECT * FROM [dbo].[vProductCountPerInventoryDate]
SELECT * FROM [dbo].[vEmployeeWhoTookInventoryPerInventoryDate]
SELECT * FROM [dbo].[vQuantityProductsByCategoryPerInventoryDate]
SELECT * FROM [dbo].[vQuantityProductsByCategoryPerInventoryDateEmployeeWhoTookCount]
SELECT * FROM [dbo].[vQuantityChaiChangPerInventoryDateEmployeeWhoTookCount]
SELECT * FROM [dbo].[vEmployeesUnderManager]
SELECT * FROM [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/