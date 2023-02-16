/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "02 - �������� SELECT � ������� �������, GROUP BY, HAVING".
������� ����������� � �������������� ���� ������ WideWorldImporters.
����� �� ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
����� WideWorldImporters-Full.bak
�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters;

/*
1. ��������� ������� ���� ������, ����� ����� ������� �� �������.
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ������� ���� �� ����� �� ���� �������
* ����� ����� ������ �� �����
������� �������� � ������� Sales.Invoices � ��������� ��������.
*/
SELECT
  YEAR(i.InvoiceDate) [year]
 ,MONTH(i.InvoiceDate) [month]
 ,AVG(il.UnitPrice) avgPrice
 ,SUM(il.UnitPrice * il.Quantity) sm
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il
  ON il.InvoiceID = i.InvoiceID
GROUP BY YEAR(i.InvoiceDate)
        ,MONTH(i.InvoiceDate)
  ORDER BY [year],[month]

/*
2. ���������� ��� ������, ��� ����� ����� ������ ��������� 4 600 000
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ����� ����� ������
������� �������� � ������� Sales.Invoices � ��������� ��������.
���������� �� ���� � ������.
*/
SELECT
  YEAR(i.InvoiceDate) [year]
 ,MONTH(i.InvoiceDate) [month]
 ,SUM(il.UnitPrice * il.Quantity) sm
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il
  ON il.InvoiceID = i.InvoiceID
GROUP BY YEAR(i.InvoiceDate)
        ,MONTH(i.InvoiceDate)
HAVING SUM(il.UnitPrice * il.Quantity) > 4600000
  ORDER BY [year],[month]



/*
3. ������� ����� ������, ���� ������ �������
� ���������� ���������� �� �������, �� �������,
������� ������� ����� 50 �� � �����.
����������� ������ ���� �� ����,  ������, ������.
�������:
* ��� �������
* ����� �������
* ������������ ������
* ����� ������
* ���� ������ �������
* ���������� ����������
������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

SELECT
  YEAR(i.InvoiceDate) [year]
 ,MONTH(i.InvoiceDate) [month]
 ,si.StockItemName
 ,SUM(il.UnitPrice * il.Quantity) sm
 ,MIN(i.InvoiceDate) firstInvoiceDate
 ,SUM(il.Quantity) smQu
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il
  ON il.InvoiceID = i.InvoiceID
JOIN Warehouse.StockItems si
  ON si.StockItemID = il.StockItemID
GROUP BY YEAR(i.InvoiceDate)
        ,MONTH(i.InvoiceDate)
        ,si.StockItemName
HAVING SUM(il.Quantity) < 50
ORDER BY [year], [month], si.StockItemName

-- ---------------------------------------------------------------------------
-- �����������
-- ---------------------------------------------------------------------------
/*
4. �������� ������ ������ ("���������� ��� ������, ��� ����� ����� ������ ��������� 4 600 000") 
�� ������ 2015 ��� ���, ����� �����, � ������� ����� ������ ���� ������ ��������� ����� ����� ����������� � �����������,
�� � �������� ����� ������ ���� �� '-'.
���������� �� ���� � ������.
������ ����������:
-----+-------+------------
Year | Month | SalesTotal
-----+-------+------------
2015 | 1     | -
2015 | 2     | -
2015 | 3     | -
2015 | 4     | 5073264.75
2015 | 5     | -
2015 | 6     | -
2015 | 7     | 5155672.00
2015 | 8     | -
2015 | 9     | 4662600.00
2015 | 10    | -
2015 | 11    | -
2015 | 12    | -
*/
