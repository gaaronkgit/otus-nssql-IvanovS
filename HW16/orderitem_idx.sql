CREATE INDEX idx_orderitem_idcolorin
ON prodsite.dbo.orderitem (idcolorin)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orderitem_idcolorout
ON prodsite.dbo.orderitem (idcolorout)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orderitem_idgood
ON prodsite.dbo.orderitem (idgood)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orderitem_idmodel
ON prodsite.dbo.orderitem (idmodel)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orderitem_idorder
ON prodsite.dbo.orderitem (idorder)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orderitem_idpower
ON prodsite.dbo.orderitem (idpower)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orderitem_idproductiontype
ON prodsite.dbo.orderitem (idproductiontype)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orderitem_idversion
ON prodsite.dbo.orderitem (idversion)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orderitem_parentid
ON prodsite.dbo.orderitem (parentid)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orderitem_width
ON prodsite.dbo.orderitem (width)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO