ALTER TABLE prodsite.dbo.customer
ADD CONSTRAINT FK_customer_customertype FOREIGN KEY (idcustomertype) REFERENCES dbo.customertype (idcustomertype)
GO

ALTER TABLE prodsite.dbo.orders
ADD CONSTRAINT FK_orders_customer FOREIGN KEY (idcustomer) REFERENCES dbo.customer (idcustomer)
GO

ALTER TABLE prodsite.dbo.orders
ADD CONSTRAINT FK_orders_people FOREIGN KEY (idpeople) REFERENCES dbo.people (idpeople)
GO

ALTER TABLE prodsite.dbo.orderitem
ADD CONSTRAINT FK_orderitem_orders FOREIGN KEY (idorder) REFERENCES dbo.orders (idorder)
GO

ALTER TABLE prodsite.dbo.orderitem
ADD CONSTRAINT FK_orderitem_people FOREIGN KEY (idpeople) REFERENCES dbo.people (idpeople)
GO

ALTER TABLE prodsite.dbo.orderitem
ADD CONSTRAINT FK_orderitem_productiontype FOREIGN KEY (idproductiontype) REFERENCES dbo.productiontype (idproductiontype)
GO

ALTER TABLE prodsite.dbo.productiontype
ADD CONSTRAINT FK_productiontype_producttype FOREIGN KEY (idproducttype) REFERENCES dbo.producttype (idproducttype)
GO

ALTER TABLE prodsite.dbo.manufactdoc
ADD CONSTRAINT FK_manufactdoc_docstate FOREIGN KEY (iddcostate) REFERENCES dbo.docstate (iddocstate)
GO

ALTER TABLE prodsite.dbo.manufactdoc
ADD CONSTRAINT FK_manufactdoc_people FOREIGN KEY (idpeople) REFERENCES dbo.people (idpeople)
GO

ALTER TABLE prodsite.dbo.manufactdocpos
ADD CONSTRAINT FK_manufactdocpos_manufactdoc FOREIGN KEY (idmanufactdoc) REFERENCES dbo.manufactdoc (idmanufactdoc)
GO