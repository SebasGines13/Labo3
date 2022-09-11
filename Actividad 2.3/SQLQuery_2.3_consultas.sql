-- 1 La cantidad de colaboradores que nacieron luego del año 1995.
SELECT COUNT(FechaNacimiento) FROM Colaboradores
WHERE YEAR(FechaNacimiento) > 1995

-- 2 El costo total de todos los pedidos que figuren como Pagado.
SELECT SUM(COSTO) FROM Pedidos
WHERE Pagado = 1

-- 3 La cantidad total de unidades pedidas del producto con ID igual a 30.
SELECT SUM(Cantidad) FROM Pedidos
WHERE IDProducto = 30

-- 4 La cantidad de clientes distintos que hicieron pedidos en el año 2020.
SELECT COUNT(DISTINCT IDCLIENTE) FROM Pedidos
WHERE YEAR(FechaSolicitud) = 2020

-- 5 Por cada material, la cantidad de productos que lo utilizan.
SELECT IDMaterial, COUNT(IDProducto) FROM Materiales_x_Producto
GROUP BY IDMaterial

-- 6 Para cada producto, listar el nombre y la cantidad de pedidos pagados.
SELECT PR.Descripcion, COUNT(P.ID) AS "Cantidad de pedidos pagados" FROM Pedidos P
INNER JOIN Productos PR ON PR.ID = P.IDProducto
WHERE P.Pagado = 1
GROUP BY P.IDProducto, PR.Descripcion

-- 7 Por cada cliente, listar apellidos y nombres de los clientes y la cantidad de productos distintos que haya pedido.
SELECT C.Apellidos, C.Nombres, COUNT(DISTINCT IDProducto) FROM Clientes C
INNER JOIN Pedidos P ON P.IDCliente = C.ID
GROUP BY C.Apellidos, C.Nombres

-- 8 Por cada colaborador y tarea que haya realizado, listar apellidos y nombres, nombre de la tarea y la cantidad de veces que haya realizado esa tarea.
SELECT C.Apellidos, C.Nombres, T.Nombre, COUNT(T.ID) FROM Colaboradores C
INNER JOIN Tareas_x_Pedido TxP ON TxP.Legajo = C.Legajo
INNER JOIN Tareas T ON T.ID = TxP.IDTarea
GROUP BY C.Apellidos, C.Nombres, T.Nombre

-- 9 Por cada cliente, listar los apellidos y nombres y el importe individual más caro que hayan abonado en concepto de pago.
SELECT C.ID,C.Apellidos, C.Nombres, MAX(Importe) FROM Clientes C 
INNER JOIN Pedidos P ON P.IDCliente = C.ID
INNER JOIN Pagos PA ON PA.IDPedido = P.ID 
GROUP BY C.ID,C.Apellidos, C.Nombres

-- 10 Por cada colaborador, apellidos y nombres y la menor cantidad de unidades solicitadas en un pedido individual en el que haya trabajado.
SELECT C.Apellidos, C.Nombres, MIN(Cantidad) FROM Colaboradores C
INNER JOIN Tareas_x_Pedido TxP ON TxP.Legajo = C.Legajo
INNER JOIN Pedidos P ON P.ID = TxP.IDPedido
GROUP BY C.Apellidos, C.Nombres


-- 11 Listar apellidos y nombres de aquellos clientes que no hayan realizado ningún pedido. Es decir, que contabilicen 0 pedidos.
SELECT C.Apellidos, C.Nombres FROM Clientes C
LEFT JOIN Pedidos P ON P.IDCliente = C.ID
GROUP BY C.Apellidos, C.Nombres
HAVING COUNT(P.ID) = 0

-- 12 Obtener un listado de productos indicando descripción y precio de aquellos productos que hayan registrado más de 15 pedidos.
SELECT P.Descripcion, P.Precio, COUNT(P.ID) FROM Productos P 
INNER JOIN Pedidos PE ON PE.IDProducto = P.ID
GROUP BY P.Descripcion, P.Precio
HAVING COUNT(P.ID) > 15

-- 13 Obtener un listado de productos indicando descripción y nombre de categoría de los productos que tienen un precio promedio de pedidos mayor a $25000.
SELECT P.Descripcion, CAT.Nombre FROM Productos P
INNER JOIN Categorias CAT ON CAT.ID = P.IDCategoria
GROUP BY P.Descripcion, CAT.Nombre
HAVING AVG(P.Precio) > 25000

-- 14 Apellidos y nombres de los clientes que hayan registrado más de 15 pedidos que superen los $15000.
SELECT C.Apellidos, C.Nombres, COUNT(P.ID) FROM Clientes C
INNER JOIN Pedidos P ON P.IDCliente = C.ID
WHERE P.Costo > 15000
GROUP BY C.Apellidos, C.Nombres
HAVING COUNT(P.ID) > 15

-- 15 Para cada producto, listar el nombre, el texto 'Pagados'  y la cantidad de pedidos pagados. Anexar otro listado con nombre, el texto 'No pagados' y cantidad de pedidos no pagados.

SELECT PR.Descripcion, CONCAT('Pagados: ',COUNT(PR.ID)) FROM Productos PR 
INNER JOIN Pedidos P ON P.IDProducto = PR.ID
WHERE P.Pagado = 1
GROUP BY PR.Descripcion
UNION 
SELECT PR.Descripcion, CONCAT('No pagados: ',COUNT(PR.ID)) FROM Productos PR 
INNER JOIN Pedidos P ON P.IDProducto = PR.ID
WHERE P.Pagado = 0
GROUP BY PR.Descripcion
