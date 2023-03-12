/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

DROP TABLE IF EXISTS #StockItems;
DECLARE @xmlQuery BIT = 0;

CREATE TABLE #StockItems (
  [StockItemName] NVARCHAR(MAX)
 ,[SupplierID] INT
 ,[UnitPackageID] INT
 ,[OuterPackageID] INT
 ,[QuantityPerOuter] INT
 ,[TypicalWeightPerUnit] NUMERIC(10, 3)
 ,[LeadTimeDays] INT
 ,[IsChillerStock] BIT
 ,[TaxRate] NUMERIC(10, 3)
 ,[UnitPrice] NUMERIC(10, 5)
);

IF @xmlQuery = 0
BEGIN

  DECLARE @xmlDocument XML;
  SELECT
    @xmlDocument = BulkColumn
  FROM OPENROWSET
  (BULK 'E:\OTUS\StockItems-188-1fb5df.xml',
  SINGLE_CLOB)
  AS data;

  DECLARE @docHandle INT;
  EXEC sp_xml_preparedocument @docHandle OUTPUT
                             ,@xmlDocument;

  INSERT INTO #StockItems
    SELECT
      *
    FROM OPENXML(@docHandle, N'/StockItems/Item')
    WITH (
    [StockItemName] NVARCHAR(100) '@Name',
    [SupplierID] INT 'SupplierID',
    [UnitPackageID] INT 'Package/UnitPackageID',
    [OuterPackageID] INT 'Package/OuterPackageID',
    [QuantityPerOuter] INT 'Package/QuantityPerOuter',
    [TypicalWeightPerUnit] DECIMAL(18, 3) 'Package/TypicalWeightPerUnit',
    [LeadTimeDays] INT 'LeadTimeDays',
    [IsChillerStock] BIT 'IsChillerStock',
    [TaxRate] DECIMAL(18, 3) 'TaxRate',
    [UnitPrice] NUMERIC(18, 2) 'UnitPrice');
  EXEC sp_xml_removedocument @docHandle;
END

ELSE
BEGIN
  DECLARE @x XML;
  SET @x = (SELECT
      *
    FROM OPENROWSET
    (BULK 'E:\OTUS\StockItems-188-1fb5df.xml',
    SINGLE_CLOB) AS d);

  INSERT INTO #StockItems
    SELECT
      t.Supplier.value('@Name[1]', 'nvarchar(100)') AS [StockItemName]
     ,t.Supplier.value('SupplierID[1]', 'int') AS [SupplierID]
     ,t.Supplier.value('Package[1]/UnitPackageID[1]', 'int') AS [UnitPackageID]
     ,t.Supplier.value('Package[1]/OuterPackageID[1]', 'int') AS [OuterPackageID]
     ,t.Supplier.value('Package[1]/QuantityPerOuter[1]', 'int') AS [QuantityPerOuter]
     ,t.Supplier.value('Package[1]/TypicalWeightPerUnit[1]', 'decimal(18,3)') AS [TypicalWeightPerUnit]
     ,t.Supplier.value('LeadTimeDays[1]', 'int') AS [LeadTimeDays]
     ,t.Supplier.value('IsChillerStock[1]', 'bit') AS [IsChillerStock]
     ,t.Supplier.value('TaxRate[1]', 'decimal(18,3)') AS [TaxRate]
     ,t.Supplier.value('UnitPrice[1]', 'decimal(18,3)') AS [UnitPrice]
    FROM @x.nodes('/StockItems/Item') AS t (Supplier);
END


MERGE Warehouse.StockItems AS TARGET
  USING (SELECT 	
    [StockItemName]
  	[SupplierID],
  	[UnitPackageID],
    [OuterPackageID],
    [QuantityPerOuter],
  	[TypicalWeightPerUnit],
    [LeadTimeDays],
    [IsChillerStock],
    [TaxRate]
    [UnitPrice] FROM #StockItems) AS SOURCE

  ON (TARGET.[StockItemName] = SOURCE.[StockItemName])

  WHEN MATCHED THEN UPDATE SET
  TARGET.SupplierID = SOURCE.SupplierID
  ,TARGET.[UnitPackageID] = SOURCE.[UnitPackageID]
  ,TARGET.[OuterPackageID] = SOURCE.[OuterPackageID]
  ,TARGET.[QuantityPerOuter] = SOURCE.[QuantityPerOuter]
  ,TARGET.[TypicalWeightPerUnit] = SOURCE.[TypicalWeightPerUnit]
  ,TARGET.[LeadTimeDays] = SOURCE.[LeadTimeDays]
  ,TARGET.[IsChillerStock] = SOURCE.[IsChillerStock]
  ,TARGET.[TaxRate] = SOURCE.[TaxRate]
  ,TARGET.[UnitPrice] = SOURCE.[UnitPrice]

  WHEN NOT MATCHED 
  		THEN INSERT (  	
        [SupplierID],
      	[UnitPackageID],
        [OuterPackageID],
        [QuantityPerOuter],
      	[TypicalWeightPerUnit],
        [LeadTimeDays],
        [IsChillerStock],
        [TaxRate],
        [UnitPrice])
  VALUES (        
    SOURCE.[SupplierID],
    SOURCE.[UnitPackageID],
    SOURCE.[OuterPackageID],
    SOURCE.[QuantityPerOuter],
    SOURCE.[TypicalWeightPerUnit],
    SOURCE.[LeadTimeDays],
    SOURCE.[IsChillerStock],
    SOURCE.[TaxRate],
    SOURCE.[UnitPrice])
DROP TABLE IF EXISTS #StockItems;
GO





/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

SELECT 
  StockItemName AS [@Name]
 ,SupplierID AS [SupplierID]
 ,UnitPackageID AS [Package/UnitPackageID]
 ,OuterPackageID AS [Package/OuterPackageID]
 ,QuantityPerOuter AS [Package/QuantityPerOuter]
 ,TypicalWeightPerUnit AS [Package/TypicalWeightPerUnit]
 ,LeadTimeDays
 ,IsChillerStock
 ,TaxRate 
 ,UnitPrice
  FROM Warehouse.StockItems si
  FOR XML PATH('Items'), ROOT('StockItems')


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

  SELECT 
    si.StockItemID
    ,JSON_VALUE(si.CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture
    ,JSON_VALUE(si.CustomFields, '$.Tags[0]') AS FirstTag
    FROM Warehouse.StockItems si

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/


SELECT
  si.StockItemID,
  si.StockItemName
FROM Warehouse.StockItems si
CROSS APPLY OPENJSON(si.CustomFields, '$.Tags') vin
WHERE vin.value = 'Vintage';
