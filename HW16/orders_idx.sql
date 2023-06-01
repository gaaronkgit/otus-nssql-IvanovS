CREATE INDEX idx_orders_idaddress
ON prodsite.dbo.orders (idaddress)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orders_idagree
ON prodsite.dbo.orders (idagree)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orders_idagreement
ON prodsite.dbo.orders (idagreement)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orders_idcustomer
ON prodsite.dbo.orders (idcustomer)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orders_iddepartment
ON prodsite.dbo.orders (iddepartment)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orders_iddestanation
ON prodsite.dbo.orders (iddestanation)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orders_iddocoper
ON prodsite.dbo.orders (iddocoper)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orders_iddocstate
ON prodsite.dbo.orders (iddocstate)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orders_idordersgroup
ON prodsite.dbo.orders (idordersgroup)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orders_idpeople
ON prodsite.dbo.orders (idpeople)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orders_idseller
ON prodsite.dbo.orders (idseller)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orders_idvalut
ON prodsite.dbo.orders (idvalut)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX idx_orders_idversion
ON prodsite.dbo.orders (idversion)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO

CREATE INDEX ind_orders_idparent
ON prodsite.dbo.orders (idparent)
WITH (STATISTICS_NORECOMPUTE = ON)
ON [PRIMARY]
GO