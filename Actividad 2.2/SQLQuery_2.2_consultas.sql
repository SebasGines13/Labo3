
-- 1 Por cada producto listar la descripción del producto, el precio y el nombre de la categoría a la que pertenece.
SELECT P.Descripcion, P.Precio, C.Nombre  FROM Productos P
INNER JOIN Categorias C ON C.ID = P.IDCategoria

-- 2 Listar las categorías de producto de las cuales no se registren productos.
SELECT distinct C.Nombre FROM Categorias C
LEFT JOIN Productos P ON P.IDCategoria = C.ID 
WHERE P.IDCategoria is null

-- 3 Listar el nombre de la categoría de producto de aquel o aquellos productos que más tiempo lleven en construir.
SELECT Top 1 with ties C.Nombre  FROM Categorias C
INNER JOIN Productos P ON P.IDCategoria = C.ID
ORDER BY P.DiasConstruccion DESC

-- 4 Listar apellidos y nombres y dirección de mail de aquellos clientes que no hayan registrado pedidos.
SELECT C.ID, C.Apellidos, C.Nombres, C.Mail FROM Clientes C
LEFT JOIN Pedidos P ON P.IDCliente = C.ID
WHERE P.IDCliente IS NULL

-- 5 Listar apellidos y nombres, mail, teléfono y celular de aquellos clientes que hayan realizado algún pedido cuyo costo supere $1000000
SELECT Distinct C.Apellidos, C.Nombres, C.Mail, C. Telefono, C.Mail FROM Clientes C
INNER JOIN Pedidos P ON P.IdCliente = C.Id
WHERE P.Costo > 1000000

-- 6 Listar IDPedido, Costo, Fecha de solicitud y fecha de finalización, descripción del producto, costo y apellido y nombre del cliente. Sólo listar aquellos registros de pedidos que hayan sido pagados.
SELECT P.ID, P.COSTO, P.FechaSolicitud , P.FechaFinalizacion, PR.Descripcion, PR.COSTO, C.APELLIDOS, C.NOMBRES FROM PEDIDOS P 
INNER JOIN PRODUCTOS PR ON PR.ID = P.IDProducto 
INNER JOIN CLIENTES C ON C.ID = P.IDCLIENTE
WHERE P.Pagado = 1

/* 
7 Listar IDPedido, Fecha de solicitud, fecha de finalización, días de construcción del producto, días de construcción del pedido (fecha de finalización - fecha de solicitud) y una columna llamada Tiempo de construcción con la siguiente información:
'Con anterioridad' → Cuando la cantidad de días de construcción del pedido sea menor a los días de construcción del producto.
'Exacto'' → Si la cantidad de días de construcción del pedido y el producto son iguales
'Con demora' → Cuando la cantidad de días de construcción del pedido sea mayor a los días de construcción del producto.
*/

SELECT P.ID, P.FechaSolicitud, P.FechaFinalizacion, PR.DiasConstruccion, DATEDIFF(DAY, P.FechaSolicitud, P.FechaFinalizacion) AS "Dias de construcción del pedido",
CASE
    WHEN DATEDIFF(DAY, P.FechaSolicitud, P.FechaFinalizacion) < PR.DiasConstruccion THEN 'Con anterioridad'
    WHEN DATEDIFF(DAY, P.FechaSolicitud, P.FechaFinalizacion) = PR.DiasConstruccion THEN 'Exacto'
    WHEN DATEDIFF(DAY, P.FechaSolicitud, P.FechaFinalizacion) > PR.DiasConstruccion THEN 'Con demora'
END AS "Tiempo de construcción"
FROM Pedidos P
INNER JOIN PRODUCTOS PR ON PR.ID = P.IDPRODUCTO


 -- 8 Listar por cada cliente el apellido y nombres y los nombres de las categorías de aquellos productos de los cuales hayan realizado pedidos. No deben figurar registros duplicados.

 SELECT DISTINCT C.Apellidos, C.Nombres, CAT.Nombre FROM Clientes C
 INNER JOIN Pedidos P ON P.IDCliente = C.ID
 INNER JOIN Productos PR ON PR.ID = P.IDProducto
 INNER JOIN Categorias CAT ON CAT.ID = PR.IDCategoria

 -- 9 Listar apellidos y nombres de aquellos clientes que hayan realizado algún pedido cuya cantidad sea exactamente igual a la cantidad considerada mayorista del producto.
 SELECT Distinct C.Apellidos, C.Nombres FROM Clientes C
 INNER JOIN Pedidos P ON P.IDCliente = C.ID
 INNER JOIN Productos PR ON PR.ID = P.IDProducto
 WHERE P.Cantidad = PR.CantidadMayorista

 -- 10 Listar por cada producto el nombre del producto, el nombre de la categoría, el precio de venta minorista, el precio de venta mayorista y el porcentaje de ahorro que se obtiene por la compra mayorista a valor mayorista en relación al valor minorista.

 SELECT PR.Descripcion, CAT.Nombre, PR.Precio, PR.PrecioVentaMayorista, ((1-PR.PrecioVentaMayorista/PR.Precio)*100) AS "% Ahorro precio mayorista" FROM Productos PR 
 INNER JOIN Categorias CAT ON CAT.ID = PR.IDCategoria



