/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/


  SELECT
    d,
    ISNULL([Gasport, NY],0) AS [Gasport, NY],
    ISNULL([Jessie, ND],0) AS [Jessie, ND],
    ISNULL([Medicine Lodge, KS],0) AS [Medicine Lodge, KS],
    ISNULL([Peeples Valley, AZ],0) AS [Peeples Valley, AZ],
    ISNULL([Sylvanite, MT],0) AS [Sylvanite, MT]
  FROM (SELECT
      REPLACE(SUBSTRING(c.CustomerName, CHARINDEX('(', c.CustomerName) + 1, CHARINDEX(')', c.CustomerName)), ')', '') AS cus
     ,COUNT(*) AS cnt
  ,DATEPART(MONTH,i.InvoiceDate) AS [MONTH]
  ,DATEPART(YEAR,i.InvoiceDate) AS [YEAR]
  ,'01.' + CAST(DATEPART(MONTH,i.InvoiceDate) AS NVARCHAR) + '.' + CAST(DATEPART(year,i.InvoiceDate) AS NVARCHAR) AS d
    FROM Sales.Customers c
    JOIN Sales.Invoices i
      ON c.CustomerID = i.CustomerID
    WHERE c.CustomerID BETWEEN 2 and 6
    GROUP BY c.CustomerName
            ,i.InvoiceDate) t
  PIVOT (
  SUM(cnt)
  FOR cus IN ([Gasport, NY],[Jessie, ND],[Medicine Lodge, KS],[Peeples Valley, AZ],[Sylvanite, MT])
  ) p
  ORDER BY p.YEAR,p.month
/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/
SELECT tt.CustomerName, tt.AddressLine FROM (
SELECT *
FROM (
SELECT c.CustomerName, c.DeliveryAddressLine1, c.DeliveryAddressLine2
  FROM Sales.Customers c
  WHERE c.CustomerName LIKE 'Tailspin Toys%'
	) AS dataUPNT
UNPIVOT (AddressLine FOR adr IN (DeliveryAddressLine1, DeliveryAddressLine2)) AS unpt) AS tt

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

SELECT * FROM (SELECT 
  c.CountryID,
  c.CountryName,
  c.IsoAlpha3Code,
  CAST(cc.IsoNumericCode AS NVARCHAR(3)) as IsoNumericCode
  FROM Application.Countries c
  JOIN Application.Countries cc ON c.CountryID = cc.CountryID) AS tt
  UNPIVOT (
  	Code FOR column_code IN (IsoAlpha3Code, IsoNumericCode)
  ) unpvt

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT c.CustomerID,c.CustomerName,u.StockItemID,u.UnitPrice,u.InvoiceDate
  FROM Sales.Customers c
  CROSS APPLY(SELECT TOP 2 i.CustomerID, si.StockItemID, si.StockItemName, il.UnitPrice,i.InvoiceDate
  FROM Sales.InvoiceLines il 
  JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
  JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
    WHERE i.CustomerID = c.CustomerID
  ORDER BY il.UnitPrice DESC) AS u 
