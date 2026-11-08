USE EmpresaDB;
GO

CREATE OR ALTER TRIGGER trg_AuditarVenta
ON Ventas
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted)
        RETURN;

    DECLARE @LoteVentas dbo.TipoVentasInsertadas;

    INSERT INTO @LoteVentas (VentaID, Producto, Cantidad)
    SELECT VentaID, Producto, Cantidad
    FROM inserted;

    EXEC sp_RegistrarAuditoria @NuevasVentas = @LoteVentas;
END;
GO