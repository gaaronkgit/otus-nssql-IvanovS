--1.Написать функцию возвращающую Клиента с наибольшей суммой покупки.
CREATE FUNCTION dbo.f_get_name_max_sm_customer ()
RETURNS NVARCHAR(MAX)
  AS 
  BEGIN
DECLARE @cus_name NVARCHAR(MAX) = (SELECT TOP 1 r.CustomerName FROM (SELECT 
  c.CustomerName,
  SUM(il.Quantity * il.UnitPrice) AS sm
  FROM Sales.InvoiceLines il
  JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
  JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
  GROUP BY 
  c.CustomerName) r
  ORDER BY r.sm DESC)

  RETURN @cus_name
END;
GO
--

--2. Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
--Использовать таблицы :
--Sales.Customers
--Sales.Invoices
--Sales.InvoiceLines
CREATE PROCEDURE dbo.get_sm_by_cutomer @idcustomer int
AS 
BEGIN
	SELECT sum(il.Quantity * il.UnitPrice) AS sm FROM Sales.Customers c
  JOIN Sales.Invoices i ON c.CustomerID = i.CustomerID
  JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
  WHERE c.CustomerID = @idcustomer
END
GO

--3. Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
--Функции однопоточные, поэтому медленее
CREATE PROCEDURE dbo.sp_f_get_name_max_sm_customer
AS 
  SELECT TOP 1 r.CustomerID FROM (SELECT SUM(il.UnitPrice) AS sm,c.CustomerID FROM Sales.Invoices i
  JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
  JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
  GROUP BY c.CustomerID
  ) r
  ORDER BY sm DESC
RETURN
GO

--4.Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.
CREATE FUNCTION dbo.f_get_ordersm_by_customer ()
RETURNS TABLE
AS
  RETURN (SELECT
    o.CustomerID,
      o.OrderID
     ,SUM(ol.Quantity * ol.UnitPrice) AS sm_order
    FROM Sales.Orders o
    JOIN Sales.OrderLines ol
      ON o.OrderID = ol.OrderID
    GROUP BY o.OrderID,o.CustomerID)
GO

SELECT c.CustomerName,fgobc.OrderID,fgobc.sm_order FROM Sales.Customers c
  JOIN dbo.f_get_ordersm_by_customer() fgobc ON c.CustomerID = fgobc.CustomerID