USE EmpresaDB;
GO

INSERT INTO Inventario (Producto, Stock) VALUES
('Laptop', 20),
('Monitor', 30),
('Teclado Mecánico', 50),
('Mouse Gamer', 40);
GO

INSERT INTO Ventas (Producto, Cantidad) VALUES ('Laptop', 3);
INSERT INTO Ventas (Producto, Cantidad) VALUES ('Monitor', 5);
GO

INSERT INTO Ventas (Producto, Cantidad) VALUES
('Teclado Mecánico', 4),
('Mouse Gamer', 6),
('Laptop', 2);
GO

PRINT '=== TABLA VENTAS ===';
SELECT * FROM Ventas;

PRINT '=== TABLA AUDITORIA VENTAS ===';
SELECT * FROM AuditoriaVentas;

PRINT '=== TABLA INVENTARIO (EXISTENCIAS ACTUALIZADAS) ===';
SELECT * FROM Inventario;
GO