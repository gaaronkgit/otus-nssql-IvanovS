CREATE TABLE prodsite.dbo.people (
  idpeople INT NOT NULL
 ,lastname NVARCHAR(100) NOT NULL
 ,firstname NVARCHAR(100) NOT NULL
 ,middlename NVARCHAR(100) NULL
 ,phone NVARCHAR(15) NULL
 ,email NVARCHAR(200) NULL
 ,CONSTRAINT PK_people PRIMARY KEY CLUSTERED (idpeople)
) ON [PRIMARY]
GO


CREATE TABLE prodsite.dbo.customertype (
  idcustomertype INT NOT NULL
 ,name NVARCHAR(100) NULL
 ,comment NCHAR(10) NULL
 ,CONSTRAINT PK_customertype PRIMARY KEY CLUSTERED (idcustomertype)
) ON [PRIMARY]
GO

CREATE TABLE prodsite.dbo.customer (
  idcustomer INT NOT NULL
 ,lastname NVARCHAR(100) NOT NULL
 ,firstname NVARCHAR(100) NOT NULL
 ,middlename NVARCHAR(100) NULL
 ,idcustomertype INT NOT NULL
 ,address NVARCHAR(MAX) NULL
 ,dtcre DATE NULL
 ,CONSTRAINT PK_customer PRIMARY KEY CLUSTERED (idcustomer)
) ON [PRIMARY]
GO

CREATE TABLE prodsite.dbo.orders (
  idorder INT NOT NULL
 ,idpeople INT NOT NULL
 ,idcustomer INT NULL
 ,dtcre DATE NULL
 ,dtedit DATE NULL
 ,sm DECIMAL(18, 2) NULL
 ,name NVARCHAR(100) NULL
 ,CONSTRAINT PK_orders PRIMARY KEY CLUSTERED (idorder)
) ON [PRIMARY]
GO

CREATE TABLE prodsite.dbo.orderitem (
  idorderitem INT NOT NULL
 ,idorder INT NOT NULL
 ,idpeople INT NOT NULL
 ,idproductiontype INT NOT NULL
 ,qu INT NOT NULL
 ,thick DECIMAL(18, 2) NULL
 ,width DECIMAL(18, 2) NULL
 ,height DECIMAL(18, 2) NULL
 ,price DECIMAL(18, 2) NULL
 ,sm NCHAR(10) NULL
 ,numpos INT NULL
 ,CONSTRAINT PK_orderitem PRIMARY KEY CLUSTERED (idorderitem)
) ON [PRIMARY]
GO

CREATE TABLE prodsite.dbo.producttype (
  idproducttype INT NOT NULL
 ,name NVARCHAR(100) NOT NULL
 ,CONSTRAINT PK_producttype PRIMARY KEY CLUSTERED (idproducttype)
) ON [PRIMARY]
GO

CREATE TABLE prodsite.dbo.productiontype (
  idproductiontype INT NOT NULL
 ,name NVARCHAR(100) NOT NULL
 ,comment NVARCHAR(MAX) NULL
 ,idproducttype INT NOT NULL
 ,CONSTRAINT PK_productiontype PRIMARY KEY CLUSTERED (idproductiontype)
) ON [PRIMARY]
GO

CREATE TABLE prodsite.dbo.docstate (
  iddocstate INT NOT NULL
 ,name NVARCHAR(100) NOT NULL
 ,comment NVARCHAR(MAX) NULL
 ,CONSTRAINT PK_docstate PRIMARY KEY CLUSTERED (iddocstate)
) ON [PRIMARY]
GO

CREATE TABLE prodsite.dbo.manufactdoc (
  idmanufactdoc INT NOT NULL
 ,name NVARCHAR(50) NULL
 ,dtcre DATE NULL
 ,dtdoc DATE NULL
 ,idpeople INT NOT NULL
 ,iddcostate INT NOT NULL
 ,CONSTRAINT PK_manufactdoc PRIMARY KEY CLUSTERED (idmanufactdoc)
) ON [PRIMARY]
GO

CREATE TABLE prodsite.dbo.manufactdocpos (
  idmnufactdoc INT NOT NULL
 ,idmanufactdocpos INT NOT NULL
 ,idorderitem INT NOT NULL
 ,orderitemnum INT NOT NULL
 ,cart INT NOT NULL
 ,cell INT NOT NULL
 ,barcode NVARCHAR(100) NULL
 ,CONSTRAINT PK_manufactdocpos PRIMARY KEY CLUSTERED (idmanufactdocpos)
) ON [PRIMARY]
GO

