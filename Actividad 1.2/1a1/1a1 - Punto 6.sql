CREATE DATABASE ActividadGrupal4
GO

USE ActividadGrupal4
GO

-- 1 Equipo de futbol tiene 1 Estadio - Alternativa con restricciones luego de creadas las tablas	

CREATE TABLE Estadios(
	ID int not null,
	Nombre varchar(100) not null,
	FecInauguracion date not null,
    Capacidad int not null,
	Direccion varchar(100) not null	
)
GO

Alter Table Estadios
Add Constraint PK_Estadios Primary Key (ID)
go

Alter Table Estadios
Add Constraint CHK_FechaMenorAHoy check ( FecInauguracion <= getdate() )
GO

CREATE TABLE Equipos(
	ID int not null,
	IDEstadio int not null,
	Nombre varchar(100) not null,
	Nombre_ApellidoDT varchar(100) not null,
    Division tinyint not null ,	
	FecFundacion date not null
)
GO

Alter Table Equipos
Add Constraint PK_Equipos Primary Key (ID)
go

Alter Table Equipos
Add Constraint CHK_FechaMenorAHoyMayor1900 check ( FecFundacion >= '1900' AND FecFundacion <= getdate() )
GO

Alter Table Equipos
Add Constraint CHK_Division check ( Division in ( '1', '2', '3', '4') )
GO

Alter Table Equipos
Add Constraint FK_Equipos_Estadio Foreign key (IDEstadio)
references Estadios(ID)
GO