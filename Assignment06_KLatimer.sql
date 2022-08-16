--*************************************************************************--
-- Title: Assignment06
-- Author: Katie Latimer
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
--8/13/22, KLATIMER, CREATED FILE
--8/14/22, KLATIMER, MODIFIED FILE
--
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KLatimer')
	 Begin 
	  Alter Database [Assignment06DB_KLatimer] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KLatimer;
	 End
	Create Database Assignment06DB_KLatimer;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KLatimer;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--REVIEWING THE COLUMNS
--SELECT * FROM Categories

--Creating view for categories table
go


CREATE
VIEW
vCategories
WITH SCHEMABINDING
AS
SELECT CategoryID, CategoryName FROM dbo.Categories
GO

--CHECKING VIEW
SELECT
	CategoryID, CategoryName
		FROM vCategories;
GO

--Reviewing data in the products table
--SELECT * FROM Products

--CREATING VIEW
CREATE
VIEW
vProducts
WITH SCHEMABINDING
AS
SELECT ProductID, ProductName, CategoryID, UnitPrice
	FROM dbo.Products
GO

--checking view
SELECT 
	ProductID, ProductName, CategoryID, UnitPrice
		FROM vProducts;
GO

--Reviewing inventories table data
--SELECT * FROM Inventories

--Creating view
CREATE 
VIEW
vInventories
WITH SCHEMABINDING
AS
SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
	FROM dbo.Inventories
GO

--checking view
SELECT 
	InventoryID, InventoryDate, EmployeeID,
	ProductID, [Count]
		FROM vInventories;
GO

--Reviewing data on employees table
--SELECT * FROM Employees

--creating view


CREATE
VIEW
vEmployees
WITH SCHEMABINDING
AS
SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	FROM dbo.Employees
GO

--checking view
SELECT
	EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
		FROM vEmployees;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--View for Categories
--SELECT * FROM vCategories
--go

--Setting permissions
Deny Select on dbo.Categories to Public;
Grant Select on vCategories to Public;

--testing view
--SELECT * FROM vCategories

--View for Products
--SELECT * FROM vProducts

--setting permissions
 Deny Select on dbo.Products to Public;
 Grant Select on vProducts to Public;

 -- view for Inventories
 --SELECT * FROM vInventories
 
 --setting permissions
 Deny Select on dbo.Inventories to Public;
 Grant Select on vInventories to Public;

 --view for employees
 --SELECT * FROM vEmployees

 --setting permissions
 Deny Select on dbo.Employees to Public;
 Grant Select on vEmployees to Public;
 
-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--Copied my code from assignment 5

--SELECT CategoryName, ProductName, UnitPrice
	--FROM Categories JOIN Products
		--ON Categories.CategoryID = Products.CategoryID
			--ORDER BY CategoryName, ProductName;
--GO


--Inserting top numeric number to incorporate the order by into the view
--SELECT TOP 10000
	-- CategoryName, ProductName, UnitPrice
		--FROM Categories JOIN Products
			--ON Categories.CategoryID = Products.CategoryID
				--ORDER BY CategoryName, ProductName;
--GO

--Creating View
go



CREATE
VIEW vProductsByCategories
as
SELECT TOP 10000
	 CategoryName, ProductName, UnitPrice
		FROM Categories JOIN Products
			ON Categories.CategoryID = Products.CategoryID
				ORDER BY CategoryName, ProductName;
GO

SELECT * FROM vProductsByCategories


-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

--copying my code from assignment 5
--SELECT ProductName, InventoryDate, Count
	--FROM Products JOIN Inventories
		--ON Products.ProductID = Inventories.ProductID
			--ORDER BY InventoryDate, ProductName, Count;
--GO

--Inserting top numeric so the order by works, reordering data to match results

--SELECT TOP 10000
	--ProductName, InventoryDate, [Count]
		--FROM Products JOIN Inventories
			--ON Products.ProductID = Inventories.ProductID
				--ORDER BY ProductName, InventoryDate, [Count];
--GO

--Creating view
go

CREATE
VIEW vInventoriesByProductsByDates
AS
SELECT TOP 10000
	ProductName, InventoryDate, [Count]
		FROM Products JOIN Inventories
			ON Products.ProductID = Inventories.ProductID
				ORDER BY ProductName, InventoryDate, [Count];
GO

--Testing view
SELECT * FROM vInventoriesByProductsByDates

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

--Copying my code from assignment 5
--SELECT DISTINCT  
	--	InventoryDate, [EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
		--	FROM Inventories INNER JOIN Employees
			--	ON Inventories.EmployeeID = Employees.EmployeeID
				--	ORDER BY InventoryDate; 			
--GO

--setting numeric so order by works

--SELECT DISTINCT  
	--TOP 10000
		--InventoryDate, [EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
			--FROM Inventories INNER JOIN Employees
				--ON Inventories.EmployeeID = Employees.EmployeeID
					--ORDER BY InventoryDate; 			
--GO

--creating view
go


CREATE
VIEW vInventoriesByEmployeesByDates
AS
SELECT DISTINCT  
	TOP 10000
		InventoryDate, [EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
			FROM Inventories INNER JOIN Employees
				ON Inventories.EmployeeID = Employees.EmployeeID
					ORDER BY InventoryDate; 			
GO

--TESTING VIEW
SELECT * FROM vInventoriesByEmployeesByDates


-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--Copying my code from assignment 5
--SELECT CategoryName, ProductName, InventoryDate, [Count]
	--FROM Inventories 
	--INNER JOIN Products 
	--ON Inventories.ProductID = Products.ProductID
	--INNER JOIN Categories 
	--ON Products.CategoryID = Categories.CategoryID
		--ORDER BY CategoryName, ProductName, InventoryDate, [Count];
--GO

--setting the numeric so the order by works with the view
--SELECT
	--TOP 10000
		--CategoryName, ProductName, InventoryDate, [Count]
		--FROM Inventories 
		--INNER JOIN Products 
		--ON Inventories.ProductID = Products.ProductID
		--INNER JOIN Categories 
		--ON Products.CategoryID = Categories.CategoryID
			--ORDER BY CategoryName, ProductName, InventoryDate, [Count];
--GO

--CREATING VIEW
go


CREATE
VIEW vInventoriesByProductsByCategories
AS
SELECT
	TOP 10000
		CategoryName, ProductName, InventoryDate, [Count]
		FROM Inventories 
		INNER JOIN Products 
		ON Inventories.ProductID = Products.ProductID
		INNER JOIN Categories 
		ON Products.CategoryID = Categories.CategoryID
			ORDER BY CategoryName, ProductName, InventoryDate, [Count];
GO

--TESTING VIEW
SELECT * FROM vInventoriesByProductsByCategories;

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--Copying my code from assignment 5
--SELECT 
--CategoryName, 
--ProductName, 
--InventoryDate, 
--[Count], 
--[EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
	--FROM Inventories 
		--INNER JOIN Employees 
		--ON Inventories.EmployeeID = Employees.EmployeeID 
		--INNER JOIN Products 
		--ON Inventories.ProductID = Products.ProductID
		--INNER JOIN Categories 
		--ON Products.CategoryID = Categories.CategoryID
			--ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;
--GO

--Adding numeric so the order by works with the view
--SELECT TOP 10000
--CategoryName, 
--ProductName, 
--InventoryDate, 
--[Count], 
--[EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
	--FROM Inventories 
		--INNER JOIN Employees 
		--ON Inventories.EmployeeID = Employees.EmployeeID 
		--INNER JOIN Products 
		--ON Inventories.ProductID = Products.ProductID
		--INNER JOIN Categories 
		--ON Products.CategoryID = Categories.CategoryID
			--ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;
--GO

--CREATING VIEW
go




CREATE 
VIEW vInventoriesByProductsByEmployees
AS
SELECT TOP 10000
CategoryName, 
ProductName, 
InventoryDate, 
[Count], 
[EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
	FROM Inventories 
		INNER JOIN Employees 
		ON Inventories.EmployeeID = Employees.EmployeeID 
		INNER JOIN Products 
		ON Inventories.ProductID = Products.ProductID
		INNER JOIN Categories 
		ON Products.CategoryID = Categories.CategoryID
			ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;
GO

--TESTING VIEW
SELECT * FROM vInventoriesByProductsByEmployees

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Côte de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

--Copying my code from assignment 5
--SELECT 
--CategoryName, 
--ProductName, 
--InventoryDate, 
--[Count],
--[EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName 
	--FROM Inventories
		--INNER JOIN Employees
		--ON Inventories.EmployeeID = Employees.EmployeeID
		--INNER JOIN Products
		--ON Inventories.ProductID = Products.ProductID
		--INNER JOIN Categories
		--ON Products.CategoryID = Categories.CategoryID
			--WHERE Inventories.ProductID IN (SELECT ProductID FROM Products WHERE ProductName IN ('Chai', 'Chang') )
				--ORDER BY InventoryDate, CategoryName, ProductName;
--GO

--adding numeric for the order by to work with the view

--SELECT 
--TOP 10000
--CategoryName, 
--ProductName, 
--InventoryDate, 
--[Count],
--[EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName 
	--FROM Inventories
		--INNER JOIN Employees
		--ON Inventories.EmployeeID = Employees.EmployeeID
		--INNER JOIN Products
		--ON Inventories.ProductID = Products.ProductID
		--INNER JOIN Categories
		--ON Products.CategoryID = Categories.CategoryID
			--WHERE Inventories.ProductID IN (SELECT ProductID FROM Products WHERE ProductName IN ('Chai', 'Chang') )
				--ORDER BY InventoryDate, CategoryName, ProductName;


--CREATING VIEW
go



CREATE 
VIEW vInventoriesForChaiAndChangByEmployees
AS
SELECT 
TOP 10000
CategoryName, 
ProductName, 
InventoryDate, 
[Count],
[EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName 
	FROM Inventories
		INNER JOIN Employees
		ON Inventories.EmployeeID = Employees.EmployeeID
		INNER JOIN Products
		ON Inventories.ProductID = Products.ProductID
		INNER JOIN Categories
		ON Products.CategoryID = Categories.CategoryID
			WHERE Inventories.ProductID IN (SELECT ProductID FROM Products WHERE ProductName IN ('Chai', 'Chang') )
				ORDER BY InventoryDate, CategoryName, ProductName;
GO

--TESTING VIEW
SELECT * FROM vInventoriesForChaiAndChangByEmployees;
GO


-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--Copying my code from assignment 5
--SELECT
	--[ManagerName] = Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName,
	--[EmployeeName] = Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
		--FROM Employees AS Emp
		--INNER JOIN Employees AS Mgr
		--ON Emp.ManagerID = Mgr.EmployeeID
			--ORDER BY [ManagerName];
--GO

--adding numeric so the order by functions within the view
--SELECT TOP 10000
	--[ManagerName] = Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName,
	--[EmployeeName] = Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
		--FROM Employees AS Emp
		--INNER JOIN Employees AS Mgr
		--ON Emp.ManagerID = Mgr.EmployeeID
			--ORDER BY [ManagerName];
--GO

--creating views



CREATE 
VIEW vEmployeesByManager
AS
SELECT TOP 10000
	[ManagerName] = Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName,
	[EmployeeName] = Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
		FROM Employees AS Emp
		INNER JOIN Employees AS Mgr
		ON Emp.ManagerID = Mgr.EmployeeID
			ORDER BY [ManagerName];
GO

--TESTING VIEW
SELECT * FROM vEmployeesByManager

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
go
--CREATING COMBINED VIEW
CREATE 
VIEW vInventoriesByProductsByCategoriesByEmployees
AS
	SELECT top 10000
	vCat.CategoryID,
	vCat.CategoryName,
	vPro.ProductID,
	vPro.ProductName,
	vPro.UnitPrice,
	vInv.InventoryID,
	vInv.InventoryDate,
	vInv.[Count],
	vEmp.EmployeeID,
	[EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName 
	FROM
		vCategories AS vCat JOIN vProducts as vPro
		ON vCat.CategoryID = vPro.CategoryID
		JOIN vInventories as vInv
		ON vPro.ProductID = vInv.ProductID
		JOIN vEmployees as vEmp
		ON vInv.EmployeeID = vEmp.EmployeeID
	ORDER BY CategoryName, ProductName, InventoryID, EmployeeName
GO


--GO
--CREATE 
--VIEW vInventoriesByProductsByCategoriesByEmployees
--AS
	--SELECT 
	--vCat.CategoryID,
	--vCat.CategoryName,
	--vPro.ProductID,
	--vPro.ProductName,
	--vPro.UnitPrice,
	--vInv.InventoryID,
	--vInv.InventoryDate,
	--vInv.[Count],
	--vEmp.EmployeeID,
	--vEmp.[EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
	--FROM
		--vCategories AS vCat JOIN vProducts as vPro
		--ON vCat.CategoryID = vPro.CategoryID
		--JOIN vInventories as vInv
		--ON vPro.ProductID = vInv.ProductID
		--JOIN vEmployees as vEmp
		--ON vInv.EmployeeID = vEmp.EmployeeID
	--ORDER BY CategoryName, ProductName, InventoryID, EmployeeName;

--go



-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/