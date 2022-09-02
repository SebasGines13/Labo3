
-- 1 Apellido, nombres y fecha de ingreso de todos los colaboradores
SELECT Apellidos, Nombres, FechaNacimiento FROM Colaboradores

-- 2 Apellido, nombres y antigüedad de todos los colaboradores
SELECT Apellidos, Nombres, YEAR(GETDATE()) - AñoIngreso Antiguedad FROM Colaboradores

-- 3 Apellido y nombres de aquellos colaboradores que trabajen part-time.
SELECT Apellidos, Nombres FROM Colaboradores
WHERE ModalidadTrabajo = 'P'

-- 4 Apellido y nombres, antigüedad y modalidad de trabajo de aquellos colaboradores cuyo sueldo sea entre 50000 y 100000.
SELECT Apellidos, Nombres, YEAR(GETDATE()) - AñoIngreso Antiguedad, ModalidadTrabajo FROM Colaboradores
WHERE Sueldo BETWEEN 50000 AND 100000

-- 5 Apellidos y nombres y edad de los colaboradores con legajos 4, 6, 12 y 25.
SELECT Apellidos, Nombres, YEAR(GETDATE()) - YEAR(FechaNacimiento) Edad FROM Colaboradores
WHERE Legajo in (4, 6, 12, 25)

-- 6 Todos los datos de todos los productos ordenados por precio de venta. Del más caro al más barato
SELECT * FROM Productos
ORDER BY Precio DESC

-- 7 El nombre del producto más costoso.
SELECT Top 1 Descripcion FROM Productos
ORDER BY Costo DESC

-- 8 Todos los datos de todos los pedidos que hayan superado el monto de $20000.
SELECT * FROM Pedidos
WHERE Costo > 20000

-- 9 Apellido y nombres de los clientes que no hayan registrado teléfono.
SELECT Apellidos, Nombres FROM Clientes
WHERE Telefono is NULL

-- 10 Apellido y nombres de los clientes que hayan registrado mail pero no teléfono.
SELECT Apellidos, Nombres FROM Clientes
WHERE Mail is NOT NULL AND Telefono is NULL 

/* 11
Apellidos, nombres y datos de contacto de todos los clientes.
Nota: En datos de contacto debe figurar el número de celular, si no tiene celular el número de teléfono fijo y si no tiene este último el mail. En caso de no tener ninguno de los tres debe figurar 'Incontactable'.
*/
SELECT Apellidos, Nombres, Coalesce(Celular, Telefono, Mail, 'Incontactable') as Contacto FROM CLIENTES

/* 12
Apellidos, nombres y medio de contacto de todos los clientes. Si tiene celular debe figurar 'Celular'. Si no tiene celular pero tiene teléfono fijo debe figurar 'Teléfono fijo' de lo contrario debe figurar 'Email'. Si no posee ninguno de los tres debe figurar NULL.
*/

SELECT Apellidos, Nombres,
       CASE 
            WHEN Celular is not null then 'Celular'
            WHEN Telefono is not null then 'Teléfono fijo'
            WHEN Mail is not null then 'Email'
            ELSE NULL
       END as 'Medio de Contacto'
    FROM Clientes

-- 13 Todos los datos de los colaboradores que hayan nacido luego del año 2000
SELECT * FROM Colaboradores
WHERE YEAR(FechaNacimiento) > 2000

-- 14 Todos los datos de los colaboradores que hayan nacido entre los meses de Enero y Julio (inclusive)
SELECT * FROM Colaboradores
WHERE MONTH(FechaNacimiento) BETWEEN 1 and 7

-- 15 Todos los datos de los clientes cuyo apellido finalice con vocal
SELECT * FROM Clientes
WHERE Apellidos like '%[AEIOU]'

-- 16 Todos los datos de los clientes cuyo nombre comience con 'A' y contenga al menos otra 'A'. Por ejemplo, Ana, Anatasia, Aaron, etc
SELECT * FROM Clientes
WHERE Nombres like 'A%A%'

-- 17 Todos los colaboradores que tengan más de 10 años de antigüedad
SELECT * FROM Colaboradores
WHERE YEAR(GETDATE()) - AñoIngreso > 10

-- 18 Los códigos de producto, sin repetir, que hayan registrado al menos un pedido
SELECT Distinct PR.ID FROM Productos PR
INNER JOIN Pedidos PE ON PE.IDProducto = PR.ID

-- 19 Todos los datos de todos los productos con su precio aumentado en un 20%
SELECT ID, IDCategoria, Descripcion, DiasConstruccion, Costo, Precio, Precio*1.2 as 'Precio + 20%', PrecioVentaMayorista, CantidadMayorista, Estado FROM Productos

-- 20 Todos los datos de todos los colaboradores ordenados por apellido ascendentemente en primera instancia y por nombre descendentemente en segunda instancia.
SELECT * FROM Colaboradores
ORDER BY Apellidos ASC, Nombres DESC



