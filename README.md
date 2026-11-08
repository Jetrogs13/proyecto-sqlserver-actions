# Proyecto Integrador: CI/CD con GitHub Actions, Docker y Microsoft SQL Server

## 1. Descripción General y Tecnologías Involucradas
Este proyecto automatiza el despliegue y validación de una base de datos **Microsoft SQL Server 2022** utilizando contenedores **Docker** dentro de un flujo de integración continua en **GitHub Actions**.

* **Docker (`mcr.microsoft.com/mssql/server:2022-latest`):** Permite levantar una instancia aislada, efímera y reproducible de SQL Server en cuestión de segundos sin necesidad de instalar el motor localmente en el servidor.
* **GitHub Actions:** Orquesta la ejecución automática de pruebas de base de datos en cada `push` y genera reportes programados (`cron`) exportados como *Artifacts*.
* **GitHub Secrets (`MSSQL_SA_PASSWORD`):** Garantiza que las credenciales de administrador del sistema (`sa`) nunca queden expuestas en texto plano dentro del código fuente.
* **Microsoft SQL Server (T-SQL):** Implementa la lógica de negocio en el servidor mediante Tablas, Tipos de Tabla definidos por el usuario (`TABLE TYPE`), Procedimientos Almacenados y Triggers `AFTER INSERT`.

---

## 2. Desarrollo del Reto Principal

### A. Funcionamiento de la tabla lógica `inserted`
En SQL Server, cuando se dispara un trigger `AFTER INSERT` o `AFTER UPDATE`, el motor de base de datos crea automáticamente en memoria una pseudo-tabla (tabla lógica de solo lectura) llamada `inserted`:
1. **Estructura idéntica:** Tiene exactamente las mismas columnas y tipos de datos que la tabla donde se definió el trigger (en este caso, `Ventas`).
2. **Alcance por sentencia, no por fila:** En SQL Server los triggers se ejecutan **una sola vez por cada sentencia DML**, sin importar si el `INSERT` afectó a 1 fila o a 10,000 filas. Por lo tanto, `inserted` contiene el **conjunto completo** de filas recién insertadas en esa transacción.
3. **Por qué fallaba el trigger original:** Al hacer `SELECT @VentaID = VentaID FROM inserted`, se intentaba guardar múltiples filas dentro de una variable escalar `@VentaID` que solo puede almacenar un valor a la vez, perdiendo la auditoría del resto de las filas.

### B. ¿Qué es el procesamiento por conjuntos (Set-Based Processing)?
El procesamiento por conjuntos (*Set-Based Processing*) es el paradigma nativo de los motores relacionales basados en álgebra relacional. Consiste en declarar **qué transformación** se desea aplicar sobre un conjunto completo de registros en una sola instrucción (`INSERT INTO ... SELECT`, `UPDATE ... FROM ... INNER JOIN`), permitiendo que el optimizador de consultas (*Query Optimizer*) de SQL Server elija el plan de ejecución físico más eficiente (usando índices, *Hash Joins* o *Merge Joins* en bloque).

### C. Comparativa: Operaciones Fila a Fila (Row-by-Row / Cursores) vs. Operaciones por Conjunto (Set-Based)

| Criterio | Fila a Fila (Row-by-Row / Cursores / Loops) | Por Conjunto (Set-Based) |
| :--- | :--- | :--- |
| **Enfoque de programación** | Imperativo: le dice al motor *cómo* recorrer fila por fila (`WHILE`, `CURSOR`, `FETCH NEXT`). | Declarativo: le indica al motor *qué* subconjunto de datos procesar en una sola operación. |
| **Rendimiento y CPU** | Muy bajo en volúmenes medianos/grandes; genera sobrecarga de cambio de contexto por cada fila. | Altamente optimizado; el motor procesa bloques de páginas de memoria completos de una sola vez. |
| **Bloqueos (Locks) y Transacciones** | Mantiene bloqueos abiertos durante más tiempo mientras itera, aumentando el riesgo de *deadlocks*. | Minimiza el tiempo de bloqueo al ejecutar una única operación atómica. |
| **Escalabilidad** | Degradación lineal o exponencial conforme crece el número de registros insertados. | Escala eficientemente desde 1 hasta millones de filas usando planes de ejecución optimizados. |

---

## 3. Solución Implementada (Reto Principal + Reto Avanzado)
1. Se creó el tipo de tabla `dbo.TipoVentasInsertadas` para transferir lotes completos de ventas entre el trigger y el procedimiento almacenado.
2. El trigger `trg_AuditarVenta` vuelca la totalidad de la tabla lógica `inserted` en una variable tipo tabla `@LoteVentas` y la envía a `sp_RegistrarAuditoria`.
3. El procedimiento almacenado `sp_RegistrarAuditoria` registra todas las auditorías con un `INSERT ... SELECT` y descuenta automáticamente el stock en la tabla `Inventario` mediante un `UPDATE ... INNER JOIN` agrupado por producto.