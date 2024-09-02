CREATE DATABASE RESTAURANT
USE RESTAURANT
CREATE TABLE Meals
(
Id int PRIMARY KEY IDENTITY,
Name nvarchar(255),
Price decimal(18, 2)
)
CREATE TABLE Tables
(
Id int PRIMARY KEY IDENTITY,
Name nvarchar(255),
)
CREATE TABLE Orders
(
Id int PRIMARY KEY IDENTITY,
Name nvarchar(255),
CreatedAt datetime2,
TableId int FOREIGN KEY REFERENCES Tables(Id)
)
CREATE TABLE OrderMeals
(
Id int PRIMARY KEY IDENTITY,
OrderId int FOREIGN KEY REFERENCES Orders(Id),
MealId int FOREIGN KEY REFERENCES Meals(Id),
)


--Task 1
SELECT *, dbo.CountTableOrders(t.Id) OrderCount FROM Tables t


CREATE FUNCTION CountTableOrders(@tableId int)
RETURNS int AS
BEGIN
	DECLARE @count int
	SELECT @count=COUNT(*) FROM Tables t
	JOIN Orders o
	ON o.TableId=t.Id
	WHERE t.Id=@tableId
	RETURN @count
END


-- Task2

CREATE FUNCTION CountMeals(@mealId int)
RETURNS int AS
BEGIN
	DECLARE @count int
	SELECT @count=COUNT(*) FROM Meals m
	JOIN OrderMeals om
	ON om.MealId=m.Id
	WHERE m.Id=@mealId
	RETURN @count
END

SELECT *, dbo.CountMeals(m.Id) [Meal Order Count] FROM Meals m


-- Task 3

SELECT o.Name, o.CreatedAt, m.Name, m.Price FROM Orders o
JOIN OrderMeals om ON o.Id=om.OrderId
JOIN Meals m ON  om.MealId=m.Id


-- Task 4

SELECT o.Name, o.CreatedAt, m.Name, m.Price, o.TableId FROM Orders o
JOIN OrderMeals om ON o.Id=om.OrderId
JOIN Meals m ON  om.MealId=m.Id

-- Task 5

CREATE FUNCTION SumOrdersForTable(@tableId int)
RETURNS decimal(18, 2) AS
BEGIN
	DECLARE @total decimal(18, 2)
	SELECT @total=SUM(m.Price) FROM Orders o
	JOIN OrderMeals om
	ON o.Id=om.OrderId
	JOIN Meals m
	ON m.Id=om.MealId
	WHERE o.TableId=@tableId
	RETURN @total
END

SELECT *, dbo.SumOrdersForTable(t.Id) [Total Price] FROM Tables t


-- Task 6

SELECT DATEDIFF(HOUR,
(SELECT TOP 1 o.CreatedAt FROM Orders o
WHERE TableId=1
ORDER BY CreatedAt DESC),

(SELECT TOP 1 o.CreatedAt FROM Orders o
WHERE TableId=1
ORDER BY CreatedAt ASC)
)
[Hour Difference]


-- Task 7

SELECT * FROM Orders o
WHERE 30 < DATEDIFF(MINUTE, GETDATE(), o.CreatedAt)

-- Task 8

CREATE VIEW CountTableOrdersView AS SELECT *, dbo.CountTableOrders(t.Id) OrderCount FROM Tables t 

SELECT * FROM CountTableOrdersView WHERE OrderCount=0

-- Task 9

CREATE FUNCTION CountTableOrdersInAnHour(@tableId int)
RETURNS int AS
BEGIN
	DECLARE @count int
	SELECT @count=COUNT(*) FROM Tables t
	JOIN Orders o
	ON o.TableId=t.Id
	WHERE t.Id=@tableId AND 1 < DATEDIFF(HOUR, GETDATE(), o.CreatedAt)
	RETURN @count
END


CREATE VIEW CountTableOrdersInAnHourView 
AS
SELECT *, dbo.CountTableOrdersInAnHour(t.Id) OrderCount FROM Tables t

SELECT * FROM CountTableOrdersInAnHourView WHERE OrderCount=0