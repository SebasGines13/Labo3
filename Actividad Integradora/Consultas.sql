
--- 1 Listado con Apellido y nombres de los técnicos que, en promedio, hayan demorado más de 225 minutos en la prestación de servicios.
SELECT T.Apellido, T.Nombre FROM Tecnicos T
INNER JOIN Servicios S ON S.IDTecnico = T.ID
GROUP BY T.ID, T.Apellido, T.Nombre
HAVING AVG(S.Duracion) > 225

-- 2 Listado con Descripción del tipo de servicio, el texto 'Particular' y la cantidad de clientes de tipo Particular. Luego añadirle un listado con descripción del tipo de servicio, el texto 'Empresa' y la cantidad de clientes de tipo Empresa.
SELECT TS.Descripcion, 'Particular' AS TipoCliente, COUNT(DISTINCT C.ID)  FROM Servicios S
INNER JOIN TiposServicio TS ON TS.ID = S.IDTipo
INNER JOIN Clientes C ON C.ID = S.IDCliente
WHERE C.Tipo = 'P'
GROUP BY TS.Descripcion
UNION
SELECT TS.Descripcion, 'Empresa' AS TipoCliente, COUNT(DISTINCT C.ID) FROM Servicios S
INNER JOIN TiposServicio TS ON TS.ID = S.IDTipo
INNER JOIN Clientes C ON C.ID = S.IDCliente
WHERE C.Tipo = 'E'
GROUP BY TS.Descripcion

-- 3 Listado con Apellidos y nombres de los clientes que hayan abonado con las cuatro formas de pago.
SELECT C.Apellido, C.Nombre FROM Clientes C
INNER JOIN Servicios S ON S.IDCliente = C.ID
GROUP BY C.ID, C.Apellido, C.Nombre
HAVING COUNT(DISTINCT S.FormaPago) = 4


-- 4 La descripción del tipo de servicio que en promedio haya brindado mayor cantidad de días de garantía.
SELECT TOP 1 with ties TS.Descripcion FROM TiposServicio TS 
INNER JOIN Servicios S ON S.IDTipo = TS.ID
GROUP BY TS.Descripcion
ORDER BY AVG(S.DiasGarantia*1.0) DESC

-- 5 Agregar las tablas y/o restricciones que considere necesario para permitir a un cliente que contrate a un técnico por un período determinado. Dicha contratación debe poder registrar la fecha de inicio y fin del trabajo, el costo total, el domicilio al que debe el técnico asistir y la periodicidad del trabajo (1 - Diario, 2 - Semanal, 3 - Quincenal).
create table Periodicidades(
    ID tinyint not null primary key,
    Descripcion varchar(100) not null
)
go
create table Contratos(
    ID int not null primary key identity(1, 1),
    IDPeriodicidad tinyint not null,
    IDTecnico int not null,
    IDCliente int not null,
    FechaInicio date not null,
    FechaFin date not null,
    Domicilio varchar(200) not null,
    CostoTotal money not null check (CostoTotal >= 0),
    foreign key (IDCliente) references Clientes(ID),
    foreign key (IDTecnico) references Tecnicos(ID),
    foreign key (IDPeriodicidad) references Periodicidades(ID),
    Check(FechaFin >= FechaInicio)
)
go
