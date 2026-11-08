USE EmpresaDB;
GO

CREATE OR ALTER PROCEDURE sp_RegistrarAuditoria
    @NuevasVentas dbo.TipoVentasInsertadas READONLY
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AuditoriaVentas (VentaID, Mensaje)
    SELECT
        VentaID,
        CONCAT('Venta registrada : ', Cantidad, ' de ', Producto)
    FROM @NuevasVentas;

    UPDATE inv
    SET
        inv.Stock = inv.Stock - ventas_agrupadas.TotalVendido,
        inv.UltimaActualizacion = GETDATE()
    FROM Inventario inv
    INNER JOIN (
        SELECT Producto, SUM(Cantidad) AS TotalVendido
        FROM @NuevasVentas
        GROUP BY Producto
    ) AS ventas_agrupadas
        ON inv.Producto = ventas_agrupadas.Producto;
END;
GO