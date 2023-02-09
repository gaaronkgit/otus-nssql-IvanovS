/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".
Задания выполняются с использованием базы данных WideWorldImporters.
Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak
Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters;

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT 
  si.StockItemID, si.StockItemName
  FROM Warehouse.StockItems si
  WHERE si.StockItemName LIKE '%urgent%' OR si.StockItemName LIKE 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/
SELECT 
  s.SupplierID,
  s.SupplierName,
  po.PurchaseOrderID
  FROM Purchasing.Suppliers s
  LEFT JOIN Purchasing.PurchaseOrders po ON po.SupplierID = s.SupplierID
  WHERE po.PurchaseOrderID IS null

/*
3. Заказы (Orders) с товарами ценой (UnitPrice) более 100$
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ (10.01.2011)
* название месяца, в котором был сделан заказ (используйте функцию FORMAT или DATENAME)
* номер квартала, в котором был сделан заказ (используйте функцию DATEPART)
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.
Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).
Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SELECT 
    o.OrderID,
    FORMAT( o.OrderDate, 'd', 'ru-ru' ) AS date_1, 
    DATENAME(MONTH,o.OrderDate) AS date_2,
    DATEPART(QUARTER,o.OrderDate) AS date_3,
  CASE 
    WHEN DATEPART(MONTH,o.OrderDate) BETWEEN 1 AND 4 THEN 1
    WHEN DATEPART(MONTH,o.OrderDate) BETWEEN 5 AND 9 THEN 2
    WHEN DATEPART(MONTH,o.OrderDate) > 9 THEN 3
    END AS date_4,
    c.CustomerName
  FROM Sales.Orders o
  JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
  JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
  WHERE o.PickingCompletedWhen IS NOT NULL AND (ol.Quantity > 20 OR ol.UnitPrice > 100)
  ORDER BY date_3 ASC, date_4 ASC, date_1 ASC
  OFFSET 1000 ROW
  FETCH NEXT 100 Rows Only

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT 
    dm.DeliveryMethodName,
    po.ExpectedDeliveryDate,
    s.SupplierName,
    p.FullName
  FROM Purchasing.PurchaseOrders po
  JOIN Purchasing.Suppliers s ON po.SupplierID = s.SupplierID
  JOIN Application.DeliveryMethods dm ON po.DeliveryMethodID = dm.DeliveryMethodID
  JOIN Application.People p ON po.ContactPersonID = p.PersonID

/*
5. Десять последних продаж (по дате продажи - InvoiceDate) с именем клиента (клиент - CustomerID) и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
Вывести: ИД продажи (InvoiceID), дата продажи (InvoiceDate), имя заказчика (CustomerName), имя сотрудника (SalespersonFullName)
Таблицы: Sales.Invoices, Sales.Customers, Application.People.
*/
SELECT 
  TOP 10 
  i.InvoiceID,
  i.InvoiceDate,
  c.CustomerName,
  p.FullName
  FROM Sales.Invoices i
  JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
  JOIN Application.People p ON i.SalespersonPersonID = p.PersonID
  ORDER BY i.InvoiceDate desc, c.CustomerID, i.SalespersonPersonID
/*
6. Все ид и имена клиентов (клиент - CustomerID) и их контактные телефоны (PhoneNumber),
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems, имена клиентов и их контакты в таблице Sales.Customers.
Таблицы: Sales.Invoices, Sales.InvoiceLines, Sales.Customers, Warehouse.StockItems.
*/
SELECT 
  DISTINCT c.CustomerID,
  c.CustomerName,
  c.PhoneNumber
  FROM Sales.Invoices i
  JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
  JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
  JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID AND si.StockItemName = 'Chocolate frogs 250g'