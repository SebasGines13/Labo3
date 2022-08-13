CREATE DATABASE ActividadGrupal1
GO

USE ActividadGrupal1
GO

-- 1 Equipo de futbol tiene 1 Estadio	

CREATE TABLE Estadios(
	ID int primary key not null,
	Nombre varchar(100) not null,
	FecInauguracion date not null check ( FecInauguracion <= getdate() ),
    Capacidad int not null,
	Direccion varchar(100) not null	
)
GO

CREATE TABLE Equipos(
	ID int primary key not null,
	IDEstadio int not null foreign key references Estadios (ID),
	Nombre varchar(100) not null,
	Nombre_ApellidoDT varchar(100) not null,
    Division tinyint not null check ( Division in ( '1', '2', '3', '4') ),	
	FecFundacion date not null check ( FecFundacion >= '1900' AND FecFundacion <= getdate() )
)
GO