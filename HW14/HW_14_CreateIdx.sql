USE prodsite
GO

CREATE CLUSTERED INDEX IDX_producttype_idproducttype
ON prodsite.dbo.producttype (idproducttype)
GO

CREATE CLUSTERED INDEX IDX_productiontype
ON prodsite.dbo.productiontype (idproductiontype, idproducttype)
GO

CREATE CLUSTERED INDEX IDX_people_idpeople
ON prodsite.dbo.people (idpeople)
GO

CREATE CLUSTERED INDEX IDX_orders
ON prodsite.dbo.orders (idorder, idcustomer)
GO

CREATE CLUSTERED INDEX IDX_orderitem
ON prodsite.dbo.orderitem (idorder, idorderitem)
GO

CREATE CLUSTERED INDEX IDX_manufactdocpos
ON prodsite.dbo.manufactdocpos (idmnufactdoc, idmanufactdocpos)
GO

CREATE CLUSTERED INDEX IDX_manufactdoc_idmanufactdoc
ON prodsite.dbo.manufactdoc (idmanufactdoc)
GO

CREATE CLUSTERED INDEX IDX_docstate_iddocstate
ON prodsite.dbo.docstate (iddocstate)
GO

CREATE CLUSTERED INDEX IDX_customertype_idcustomertype
ON prodsite.dbo.customertype (idcustomertype)
GO

CREATE CLUSTERED INDEX IDX_customer_idcustomer
ON prodsite.dbo.customer (idcustomer)
GO