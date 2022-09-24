-- 1 Los pedidos que hayan sido finalizados en menor cantidad de días que la demora promedio
SELECT * FROM Pedidos P
WHERE DATEDIFF(DAY, P.FechaSolicitud, P.FechaFinalizacion) < (
    SELECT AVG(DATEDIFF(DAY, FechaSolicitud, FechaFinalizacion)) FROM Pedidos
)

-- 2 Los productos cuyo costo sea mayor que el costo del producto de Roble más caro.
SELECT * FROM Productos P
WHERE P.Costo > ( SELECT MAX(P.Costo) FROM Materiales M
    INNER JOIN Materiales_x_Producto MxP ON MxP.IDMaterial = M.ID
    INNER JOIN Productos P ON P.ID = MxP.IDProducto
    WHERE M.Nombre = 'Roble'
)

-- 3 Los clientes que no hayan solicitado ningún producto de material Pino en el año 2022.  --REVISAR
SELECT * FROM Clientes C
WHERE Not Exists (
    SELECT DISTINCT P.IDCLIENTE FROM Pedidos P
    INNER JOIN Productos PRO ON PRO.ID = P.IDProducto
    INNER JOIN Materiales_x_Producto MxP ON MxP.IDProducto = PRO.ID
    INNER JOIN Materiales MAT ON MAT.ID = MxP.IDMaterial
    WHERE MAT.Nombre = 'Pino' AND YEAR(P.FechaSolicitud) = 2022 AND P.IDCliente = C.ID
)

-- 4 Los colaboradores que no hayan realizado ninguna tarea de Lijado en pedidos que se solicitaron en el año 2021.
SELECT COL.Apellidos, COL.Nombres FROM Colaboradores COL
WHERE NOT EXISTS (
    SELECT * FROM Tareas_x_Pedido TxP
    INNER JOIN Tareas T ON T.ID = TxP.IDTarea
    INNER JOIN Pedidos P ON P.ID = TxP.IDPedido
    WHERE T.Nombre = 'Lijado' AND YEAR(P.FechaSolicitud) = 2021 AND TXP.Legajo = COL.Legajo
)

-- 5 Los clientes a los que les hayan enviado (no necesariamente entregado) al menos un tercio de sus pedidos. --REVISAR
SELECT Apellidos, Nombres FROM (
    SELECT C.ID, C.Apellidos, C.Nombres,
    (
        SELECT COUNT(*) FROM Pedidos P
        WHERE P.IDCliente = C.ID
    ) AS CantPedidos,
    (
        SELECT COUNT(*) FROM Envios E
        INNER JOIN Pedidos P ON P.ID = E.IDPedido
        WHERE P.IDCliente = C.ID
    ) AS CantPedidosEnviados
    FROM Clientes C
) AS EnviosClientes
WHERE CantPedidosEnviados > CantPedidos / 3.0


-- 6 Los colaboradores que hayan realizado todas las tareas (no necesariamente en un mismo pedido).
SELECT * FROM Colaboradores COL WHERE EXISTS (
    SELECT Legajo, COUNT(DISTINCT IDTarea) FROM Tareas_x_Pedido
    WHERE Legajo = COL.Legajo
    GROUP BY Legajo
    HAVING COUNT(DISTINCT IDTarea) = (
        SELECT COUNT(*) FROM TAREAS
    )    
)

-- 7 Por cada producto, la descripción y la cantidad de colaboradores fulltime que hayan trabajado en él y la cantidad de colaboradores parttime.
SELECT Descripcion, SUM(Colaboradores_FullTime) Colaboradores_FullTime, SUM(Colaboradores_PartTime) Colaboradores_PartTime FROM (
    SELECT PROD.ID, PROD.Descripcion AS Descripcion, 
    (        
        SELECT COUNT(DISTINCT T.Legajo ) FROM Tareas_x_Pedido T
        INNER JOIN Pedidos PED ON PED.ID = T.IDPedido
        INNER JOIN Colaboradores COL ON COL.Legajo = T.Legajo
        WHERE PED.IDProducto = PROD.ID AND COL.ModalidadTrabajo = 'F'
    ) AS Colaboradores_FullTime,
    (
        SELECT COUNT(DISTINCT T.Legajo ) FROM Tareas_x_Pedido T
        INNER JOIN Pedidos PED ON PED.ID = T.IDPedido
        INNER JOIN Colaboradores COL ON COL.Legajo = T.Legajo
        WHERE PED.IDProducto = PROD.ID AND COL.ModalidadTrabajo = 'P'
    ) AS Colaboradores_PartTime
    FROM Productos PROD
) AS Productos
GROUP BY ID, Descripcion

-- 8 Por cada producto, la descripción y la cantidad de pedidos enviados y la cantidad de pedidos sin envío.
SELECT Descripcion, Cant_Pedidos_Enviados, (Cant_Pedidos_Totales - Cant_Pedidos_Enviados) AS Cant_Pedidos_Sin_Envio FROM (
    SELECT PROD.Descripcion,
        (
            SELECT COUNT(*) FROM Pedidos PED
            WHERE PED.IDProducto = PROD.ID
        ) AS Cant_Pedidos_Totales,
        (
            SELECT COUNT(*) FROM Pedidos PED
            INNER JOIN Envios ENV ON ENV.IDPedido = PED.ID
            WHERE PED.IDProducto = PROD.ID
        ) AS Cant_Pedidos_Enviados
    FROM Productos PROD
) AS Productos

-- 9 Por cada cliente, apellidos y nombres y la cantidad de pedidos solicitados en los años 2020, 2021 y 2022. (Cada año debe mostrarse en una columna separada)
SELECT C.ID, C.Apellidos, C.Nombres,
    (
        SELECT COUNT(*) FROM Pedidos PED
        WHERE PED.IDCliente = C.ID AND YEAR(PED.FechaSolicitud) = 2020
    )  AS Pedidos_2020,
    (
        SELECT COUNT(*) FROM Pedidos PED
        WHERE PED.IDCliente = C.ID AND YEAR(PED.FechaSolicitud) = 2021
    )  AS Pedidos_2021,
    (
        SELECT COUNT(*) FROM Pedidos PED
        WHERE PED.IDCliente = C.ID AND YEAR(PED.FechaSolicitud) = 2022
    )  AS Pedidos_2022
FROM Clientes C

-- 10 Por cada producto, listar la descripción del producto, el costo y los materiales de construcción (en una celda separados por coma)
SELECT PROD.ID, PROD.Descripcion, PROD.Costo, 
    (
        SELECT STRING_AGG(MAT.Nombre, ', ') 
        FROM Materiales MAT 
        INNER JOIN Materiales_x_Producto MxP ON MxP.IDMaterial = MAT.ID
        WHERE MxP.IDProducto = PROD.ID
    ) AS Materiales_de_Construccion
FROM Productos PROD

-- 11 Por cada pedido, listar el ID, la fecha de solicitud, el nombre del producto, los apellidos y nombres de los colaboradores que trabajaron en el pedido y la/s tareas que el colaborador haya realizado (en una celda separados por coma)
SELECT PED.ID, PED.FechaSolicitud, PROD.Descripcion, COL.Nombres, COL.Apellidos, STRING_AGG(TAR.Nombre, ', ')
FROM Colaboradores COL
INNER JOIN Tareas_x_Pedido TxP ON TxP.Legajo = COL.Legajo
INNER JOIN Tareas TAR ON TAR.ID = TxP.IDTarea
INNER JOIN Pedidos PED ON PED.ID = TxP.IDPedido
INNER JOIN Productos PROD ON PROD.ID = PED.IDProducto
GROUP BY PED.ID, PED.FechaSolicitud, PROD.Descripcion, COL.Nombres, COL.Apellidos

-- 12 Las descripciones de los productos que hayan requerido el doble de colaboradores fulltime que colaboradores partime.
SELECT Descripcion FROM (
    SELECT PROD.ID, PROD.Descripcion AS Descripcion, 
    (        
        SELECT COUNT(DISTINCT T.Legajo ) FROM Tareas_x_Pedido T
        INNER JOIN Pedidos PED ON PED.ID = T.IDPedido
        INNER JOIN Colaboradores COL ON COL.Legajo = T.Legajo
        WHERE PED.IDProducto = PROD.ID AND COL.ModalidadTrabajo = 'F'
    ) AS Colaboradores_FullTime,
    (
        SELECT COUNT(DISTINCT T.Legajo ) FROM Tareas_x_Pedido T
        INNER JOIN Pedidos PED ON PED.ID = T.IDPedido
        INNER JOIN Colaboradores COL ON COL.Legajo = T.Legajo
        WHERE PED.IDProducto = PROD.ID AND COL.ModalidadTrabajo = 'P'
    ) AS Colaboradores_PartTime
    FROM Productos PROD
) AS Productos
GROUP BY ID, Descripcion
HAVING SUM(Colaboradores_FullTime) = SUM(Colaboradores_PartTime)*2

-- 13 Las descripciones de los productos que tuvieron más pedidos sin envíos que con envíos pero que al menos tuvieron un pedido enviado.
SELECT Descripcion FROM (
    SELECT PROD.Descripcion,
        (
            SELECT COUNT(*) FROM Pedidos PED
            WHERE PED.IDProducto = PROD.ID
        ) AS Cant_Pedidos_Totales,
        (
            SELECT COUNT(*) FROM Pedidos PED
            INNER JOIN Envios ENV ON ENV.IDPedido = PED.ID
            WHERE PED.IDProducto = PROD.ID
        ) AS Cant_Pedidos_Enviados
    FROM Productos PROD
) AS Productos
WHERE (Cant_Pedidos_Totales - Cant_Pedidos_Enviados) > Cant_Pedidos_Enviados AND Cant_Pedidos_Enviados > 0

-- 14 Los nombre y apellidos de los clientes que hayan realizado pedidos en los años 2020, 2021 y 2022 pero que la cantidad de pedidos haya decrecido en cada año. Añadirle al listado aquellos clientes que hayan realizado exactamente la misma cantidad de pedidos en todos los años y que dicha cantidad no sea cero.
SELECT Apellidos, Nombres FROM (
    SELECT C.ID, C.Apellidos, C.Nombres,
        (
            SELECT COUNT(*) FROM Pedidos PED
            WHERE PED.IDCliente = C.ID AND YEAR(PED.FechaSolicitud) = 2020
        )  AS Pedidos_2020,
        (
            SELECT COUNT(*) FROM Pedidos PED
            WHERE PED.IDCliente = C.ID AND YEAR(PED.FechaSolicitud) = 2021
        )  AS Pedidos_2021,
        (
            SELECT COUNT(*) FROM Pedidos PED
            WHERE PED.IDCliente = C.ID AND YEAR(PED.FechaSolicitud) = 2022
        )  AS Pedidos_2022
    FROM Clientes C
) AS Clientes
WHERE (Pedidos_2020 > Pedidos_2021 AND Pedidos_2021 > Pedidos_2022) OR 
      (Pedidos_2020 = Pedidos_2021 AND Pedidos_2021 = Pedidos_2022 AND Pedidos_2022 > 0)