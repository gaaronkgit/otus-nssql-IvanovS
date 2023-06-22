/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

  SET STATISTICS TIME, IO ON
  DROP TABLE IF EXISTS #t

  SELECT
    SUM(il.Quantity * il.UnitPrice) AS sm
   ,MONTH(i.InvoiceDate) AS [month] INTO #t
  FROM Sales.Invoices i
  JOIN Sales.InvoiceLines il
    ON i.InvoiceID = il.InvoiceID
  WHERE i.InvoiceDate > '20150101'
  GROUP BY MONTH(i.InvoiceDate)


  SELECT
    i.InvoiceID
   ,c.CustomerName
   ,i.InvoiceDate
   ,SUM(il.Quantity * il.UnitPrice) AS sm
   ,s.sm + (SELECT
        COALESCE(SUM(t2.sm), 0)
      FROM #t t2
      WHERE t2.[month] < s.[month])
    AS total
  FROM #t s
  JOIN Sales.Invoices i
    ON s.[month] = MONTH(i.InvoiceDate)
  JOIN Sales.InvoiceLines il
    ON i.InvoiceID = il.InvoiceID
  JOIN Sales.Customers c
    ON i.CustomerID = c.CustomerID
  WHERE i.InvoiceDate > '20150101'
  GROUP BY i.InvoiceDate
          ,s.month
          ,s.sm
          ,i.InvoiceID
          ,c.CustomerName
  ORDER BY i.InvoiceDate
  SET STATISTICS TIME, IO OFF
/*Время работы SQL Server: Время ЦП = 422 мс, затраченное время = 681 мс*/


/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
  SET STATISTICS TIME, IO ON
  DROP TABLE IF EXISTS #t

  SELECT
    i.InvoiceID
   ,c.CustomerName
   ,SUM(il.Quantity * il.UnitPrice) AS sm
   ,i.InvoiceDate
   ,MONTH(i.InvoiceDate) AS [month] INTO #t
  FROM Sales.Invoices i
  JOIN Sales.InvoiceLines il
    ON i.InvoiceID = il.InvoiceID
  JOIN Sales.Customers c
    ON i.CustomerID = c.CustomerID
  WHERE i.InvoiceDate > '20150101'
  GROUP BY i.InvoiceDate
          ,i.InvoiceID
          ,c.CustomerName

  SELECT
    t.*
   ,COALESCE(SUM(t.sm) OVER (PARTITION BY t.month ORDER BY t.InvoiceDate
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
    0) AS total
  FROM #t t
  SET STATISTICS TIME, IO OFF

/*Время ЦП = 94 мс, затраченное время = 291 мс
С использованием оконной функции быстрее
  */


/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

SELECT
  b.Month
 ,b.StockItemName
 ,b.Quantity
 ,b.Rank
FROM (SELECT
    a.*
   ,ROW_NUMBER() OVER (PARTITION BY a.Month ORDER BY a.[Quantity] DESC) AS [Rank]
  FROM (SELECT DISTINCT
      MONTH(ct.TransactionDate) AS [Month]
     ,si.StockItemName
     ,SUM(il.Quantity) OVER (PARTITION BY MONTH(ct.TransactionDate), si.StockItemName) AS [Quantity]
    FROM Sales.InvoiceLines il
    JOIN Sales.CustomerTransactions ct
      ON il.InvoiceID = ct.InvoiceID
    JOIN Warehouse.StockItems si
      ON il.StockItemID = si.StockItemID
    WHERE YEAR(ct.TransactionDate) = 2016) a) b
WHERE [Rank] <= 2
ORDER BY b.Month ASC
, b.Quantity DESC;

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT
  ROW_NUMBER() OVER (ORDER BY StockItemName ASC) AS [№]
 ,si.StockItemID
 ,si.StockItemName
 ,si.Brand
 ,si.UnitPrice
 ,ROW_NUMBER() OVER (PARTITION BY LEFT(StockItemName, 1) ORDER BY StockItemName ASC) AS [№ by Letter]
 ,SUM(sih.QuantityOnHand) OVER (PARTITION BY si.StockItemName) AS [QuantityOnHand]
 ,SUM(sih.QuantityOnHand) OVER (PARTITION BY LEFT(si.StockItemName, 1) ORDER BY LEFT(si.StockItemName, 1) ASC) AS qu
 ,LEAD(si.StockItemID) OVER (ORDER BY si.StockItemName) AS [Next StockItemID]
 ,LAG(si.StockItemID) OVER (ORDER BY si.StockItemName) AS [Previous StockItemID]
 ,ISNULL(LAG(si.StockItemName, 2) OVER (ORDER BY si.StockItemName), 'No items') AS [Previous by 2 StockItemName]
 ,NTILE(30) OVER (ORDER BY si.TypicalWeightPerUnit)
FROM Warehouse.StockItems si
JOIN Warehouse.StockItemHoldings sih
  ON si.StockItemID = sih.StockItemID;


/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

WITH cte
AS
(SELECT DISTINCT
    o.SalespersonPersonID
   ,p.FullName
   ,MAX(ct.CustomerTransactionID) OVER (PARTITION BY o.SalespersonPersonID) AS [CustomerTransactionID]
  FROM Application.People p
  JOIN Sales.Orders o
    ON p.PersonID = o.SalespersonPersonID
  JOIN Sales.Invoices i
    ON o.OrderID = i.OrderID
  JOIN Sales.CustomerTransactions ct
    ON i.InvoiceID = ct.InvoiceID)
SELECT
  cte.SalespersonPersonID
 ,cte.FullName
 ,c.CustomerID
 ,c.CustomerName
 ,ct.TransactionDate
 ,ct.TransactionAmount
FROM cte cte
JOIN Sales.CustomerTransactions ct
  ON cte.CustomerTransactionID = ct.CustomerTransactionID
JOIN Sales.Invoices i
  ON ct.InvoiceID = i.InvoiceID
JOIN Sales.Customers c
  ON i.CustomerID = c.CustomerID
ORDER BY cte.SalespersonPersonID;

GO

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT DISTINCT
  a.CustomerID
 ,a.CustomerName
 ,a.StockItemID
 ,a.UnitPrice
 ,a.TransactionDate
FROM (SELECT
    c.CustomerID
   ,c.CustomerName
   ,si.StockItemID
   ,si.UnitPrice
   ,MAX(ct.TransactionDate) OVER (PARTITION BY c.CustomerID, si.StockItemID) AS [TransactionDate]
   ,DENSE_RANK() OVER (PARTITION BY c.CustomerID ORDER BY si.UnitPrice DESC) AS [Rank]
  FROM Sales.Orders o
  JOIN Sales.OrderLines ol
    ON o.OrderID = ol.OrderID
  JOIN Warehouse.StockItems si
    ON ol.StockItemID = si.StockItemID
  JOIN Sales.Invoices i
    ON o.OrderID = i.OrderID
  JOIN Sales.CustomerTransactions ct
    ON i.InvoiceID = ct.InvoiceID
  JOIN Sales.Customers c
    ON o.CustomerID = c.CustomerID) a
WHERE a.Rank <= 2
ORDER BY a.CustomerID ASC
, a.UnitPrice DESC;
