﻿/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

SELECT p.PersonID, p.FullName FROM Application.People p
  WHERE p.IsSalesperson = 1 AND p.PersonID NOT in (SELECT DISTINCT i.SalespersonPersonID FROM Sales.Invoices i WHERE i.InvoiceDate = '20150704')

;WITH CTE (s) AS 
(
SELECT DISTINCT i.SalespersonPersonID AS s FROM Sales.Invoices i WHERE i.InvoiceDate = '20150704'
)
SELECT p.PersonID, p.FullName
  FROM Application.People p
  WHERE p.IsSalesperson = 1 AND p.PersonID NOT IN (SELECT * FROM CTE)
/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/
SELECT si.StockItemID,si.StockItemName, si.UnitPrice FROM Warehouse.StockItems si WHERE si.UnitPrice = (
SELECT MIN(si.UnitPrice) AS min_price
FROM Warehouse.StockItems si)

SELECT si.StockItemID,si.StockItemName, si.UnitPrice FROM Warehouse.StockItems si WHERE si.UnitPrice <= ALL (
SELECT MIN(si.UnitPrice) AS min_price FROM Warehouse.StockItems si)

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/
SELECT c.* FROM Website.Customers c WHERE c.CustomerID in (
SELECT TOP 5 ct.CustomerID FROM Sales.CustomerTransactions ct ORDER BY ct.TransactionAmount DESC)

  ;WITH MaxCusTranCTE AS 
    (
    SELECT TOP 5 ct.CustomerID FROM Sales.CustomerTransactions ct ORDER BY ct.TransactionAmount DESC
    )
SELECT c.* FROM Website.Customers c WHERE c.CustomerID IN (SELECT * FROM MaxCusTranCTE)

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

SELECT COUNT(*) FROM (SELECT DISTINCT
  c1.CityID,
  c1.CityName
  FROM Sales.InvoiceLines il
  JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
  JOIN Sales.Orders o ON i.OrderID = o.OrderID
  JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
  JOIN Application.Cities c1 ON c.DeliveryCityID = c1.CityID
  WHERE il.StockItemID IN (
  SELECT TOP 3 StockItemID FROM Warehouse.StockItems si ORDER BY UnitPrice DESC )) AS r

  ;WITH cityCTE AS
    (
    SELECT TOP 3 si.StockItemID FROM Warehouse.StockItems si 
    ORDER BY si.UnitPrice DESC
    )

    SELECT DISTINCT
          c.CityID,
          c.CityName,
          il.StockItemID
          FROM Sales.InvoiceLines il
          JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
          JOIN Sales.Orders o ON i.OrderID = o.OrderID
          JOIN Sales.Customers cus ON i.CustomerID = cus.CustomerID
          JOIN Application.Cities c ON c.CityID = cus.DeliveryCityID
    JOIN cityCTE ON il.StockItemID = cityCTE.StockItemID



-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: напишите здесь свое решение
