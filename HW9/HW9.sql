/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

INSERT INTO Purchasing.Suppliers (SupplierID, SupplierCategoryID, SupplierName, PrimaryContactPersonID, AlternateContactPersonID, DeliveryCityID, PostalCityID, PaymentDays, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryPostalCode, PostalAddressLine1, PostalPostalCode, LastEditedBy)
  VALUES (NEXT VALUE FOR Sequences.SupplierID, 2, 'Inserted1', 21, 24, 18557, 18557, 30, '(218) 555-0105', '(218) 555-0105', 'http://www.ins.com', '', '95245', 'PO Box 1039', '95245', 1),
  (NEXT VALUE FOR Sequences.SupplierID, 2, 'Inserted2', 21, 24, 18557, 18557, 30, '(218) 555-0105', '(218) 555-0105', 'http://www.ins.com', '', '95245', 'PO Box 1039', '95245', 1),
  (NEXT VALUE FOR Sequences.SupplierID, 2, 'Inserted3', 21, 24, 18557, 18557, 30, '(218) 555-0105', '(218) 555-0105', 'http://www.ins.com', '', '95245', 'PO Box 1039', '95245', 1),
  (NEXT VALUE FOR Sequences.SupplierID, 2, 'Inserted4', 21, 24, 18557, 18557, 30, '(218) 555-0105', '(218) 555-0105', 'http://www.ins.com', '', '95245', 'PO Box 1039', '95245', 1),
  (NEXT VALUE FOR Sequences.SupplierID, 2, 'Inserted5', 21, 24, 18557, 18557, 30, '(218) 555-0105', '(218) 555-0105', 'http://www.ins.com', '', '95245', 'PO Box 1039', '95245', 1);


/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM Purchasing.Suppliers WHERE SupplierName = 'Inserted1'


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE Purchasing.Suppliers SET PhoneNumber = '(423) 555-0103' WHERE SupplierName = 'Inserted3'

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE Sales.Customers AS TARGET
  USING (SELECT   
    CustomerID
   ,CustomerName
   ,BillToCustomerID
   ,CustomerCategoryID
   ,BuyingGroupID
   ,PrimaryContactPersonID
   ,AlternateContactPersonID
   ,DeliveryMethodID
   ,DeliveryCityID
   ,PostalCityID
   ,CreditLimit
   ,AccountOpenedDate
   ,StandardDiscountPercentage
   ,IsStatementSent
   ,IsOnCreditHold
   ,PaymentDays
   ,PhoneNumber
   ,FaxNumber
   ,DeliveryRun
   ,RunPosition
   ,'http://www.tailspintoys_new.com'
   ,DeliveryAddressLine1
   ,DeliveryAddressLine2
   ,DeliveryPostalCode
   ,DeliveryLocation
   ,PostalAddressLine1
   ,PostalAddressLine2
   ,PostalPostalCode
   ,LastEditedBy
   ,ValidFrom
   ,ValidTo 
    FROM Sales.Customers WHERE CustomerID = 1 ) AS SOURCE
  ON (TARGET.CustomerID = SOURCE.CustomerID)
  	WHEN MATCHED 
		THEN UPDATE SET 
      CustomerName =                SOURCE.CustomerName   
      ,BillToCustomerID =           SOURCE.BillToCustomerID
     ,CustomerCategoryID =          SOURCE.CustomerCategoryID
     ,BuyingGroupID =               SOURCE.BuyingGroupID
     ,PrimaryContactPersonID =      SOURCE.PrimaryContactPersonID
     ,AlternateContactPersonID =    SOURCE.AlternateContactPersonID
     ,DeliveryMethodID =            SOURCE.DeliveryMethodID
     ,DeliveryCityID =              SOURCE.DeliveryCityID
     ,PostalCityID =                SOURCE.PostalCityID
     ,CreditLimit =                 SOURCE.CreditLimit
     ,AccountOpenedDate =           SOURCE.AccountOpenedDate
     ,StandardDiscountPercentage =  SOURCE.StandardDiscountPercentage
     ,IsStatementSent =             SOURCE.IsStatementSent
     ,IsOnCreditHold =              SOURCE.IsOnCreditHold
     ,PaymentDays =                 SOURCE.PaymentDays
     ,PhoneNumber =                 SOURCE.PhoneNumber
     ,FaxNumber =                   SOURCE.FaxNumber
     ,DeliveryRun =                 SOURCE.DeliveryRun
     ,RunPosition =                 SOURCE.RunPosition
     ,WebsiteURL =                  SOURCE.WebsiteURL
     ,DeliveryAddressLine1 =        SOURCE.DeliveryAddressLine1
     ,DeliveryAddressLine2 =        SOURCE.DeliveryAddressLine2
     ,DeliveryPostalCode =          SOURCE.DeliveryPostalCode
     ,DeliveryLocation =            SOURCE.DeliveryLocation
     ,PostalAddressLine1 =          SOURCE.PostalAddressLine1
     ,PostalAddressLine2 =          SOURCE.PostalAddressLine2
     ,PostalPostalCode =            SOURCE.PostalPostalCode
     ,LastEditedBy =                SOURCE.LastEditedBy
     ,ValidFrom =                   SOURCE.ValidFrom
     ,ValidTo =                     SOURCE.ValidTo
	WHEN NOT MATCHED 
		THEN INSERT (
  CustomerID
, CustomerName
, BillToCustomerID
, CustomerCategoryID
, BuyingGroupID
, PrimaryContactPersonID
, AlternateContactPersonID
, DeliveryMethodID
, DeliveryCityID
, PostalCityID
, CreditLimit
, AccountOpenedDate
, StandardDiscountPercentage
, IsStatementSent
, IsOnCreditHold
, PaymentDays
, PhoneNumber
, FaxNumber
, DeliveryRun
, RunPosition
, WebsiteURL
, DeliveryAddressLine1
, DeliveryAddressLine2
, DeliveryPostalCode
, DeliveryLocation
, PostalAddressLine1
, PostalAddressLine2
, PostalPostalCode
, LastEditedBy
, ValidFrom
, ValidTo)
  VALUES (NEXT VALUE FOR Sequences.CustomerID
  ,SOURCE.CustomerName   
  ,SOURCE.BillToCustomerID
  ,SOURCE.CustomerCategoryID
  ,SOURCE.BuyingGroupID
  ,SOURCE.PrimaryContactPersonID
  ,SOURCE.AlternateContactPersonID
  ,SOURCE.DeliveryMethodID
  ,SOURCE.DeliveryCityID
  ,SOURCE.PostalCityID
  ,SOURCE.CreditLimit
  ,SOURCE.AccountOpenedDate
  ,SOURCE.StandardDiscountPercentage
  ,SOURCE.IsStatementSent
  ,SOURCE.IsOnCreditHold
  ,SOURCE.PaymentDays
  ,SOURCE.PhoneNumber
  ,SOURCE.FaxNumber
  ,SOURCE.DeliveryRun
  ,SOURCE.RunPosition
  ,SOURCE.WebsiteURL
  ,SOURCE.DeliveryAddressLine1
  ,SOURCE.DeliveryAddressLine2
  ,SOURCE.DeliveryPostalCode
  ,SOURCE.DeliveryLocation
  ,SOURCE.PostalAddressLine1
  ,SOURCE.PostalAddressLine2
  ,SOURCE.PostalPostalCode
  ,SOURCE.LastEditedBy
  ,SOURCE.ValidFrom
  ,SOURCE.ValidTo);

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/


exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.InvoiceLines" out  "C:\temp\InvoiceLines.txt" -T -w -t";" -S DESKTOP-GAF478R'


drop table if exists [Sales].[InvoiceLines_BulkDemo]

CREATE TABLE [Sales].[InvoiceLines_BulkDemo](
	[InvoiceLineID] [int] NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[TaxAmount] [decimal](18, 2) NOT NULL,
	[LineProfit] [decimal](18, 2) NOT NULL,
	[ExtendedPrice] [decimal](18, 2) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Sales_InvoiceLines_BulkDemo] PRIMARY KEY CLUSTERED 
(
	[InvoiceLineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA]
) ON [USERDATA]
----



	BULK INSERT [WideWorldImporters].[Sales].[InvoiceLines_BulkDemo]
				   FROM "C:\temp\InvoiceLines.txt"
				   WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = 'widechar',
						FIELDTERMINATOR = ';',
						ROWTERMINATOR ='\n',
						KEEPNULLS,
						TABLOCK        
					  );