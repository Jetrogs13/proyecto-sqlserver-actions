USE EmpresaDB;
GO

CREATE TABLE Inventario (
    ProductoID INT IDENTITY(1,1) PRIMARY KEY,
    Producto VARCHAR(100) NOT NULL UNIQUE,
    Stock INT NOT NULL CHECK (Stock >= 0),
    UltimaActualizacion DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Ventas (
    VentaID INT IDENTITY(1,1) PRIMARY KEY,
    Producto VARCHAR(100),
    Cantidad INT,
    Fecha DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE AuditoriaVentas (
    AuditoriaID INT IDENTITY(1,1) PRIMARY KEY,
    VentaID INT,
    FechaRegistro DATETIME DEFAULT GETDATE(),
    Mensaje VARCHAR(255)
);
GO

CREATE TYPE dbo.TipoVentasInsertadas AS TABLE (
    VentaID INT,
    Producto VARCHAR(100),
    Cantidad INT
);
GO