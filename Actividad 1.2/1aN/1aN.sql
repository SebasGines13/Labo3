CREATE DATABASE ActividadGrupal2
GO

USE ActividadGrupal2
GO

-- 1 Equipo de futbol tiene N jugadores	


CREATE TABLE Equipos(
	ID int primary key not null identity(1,1),
	--IDEstadio int not null foreign key references Estadios (ID),
	Nombre varchar(100) not null,
	Nombre_ApellidoDT varchar(100) not null,
    Division tinyint not null check ( Division in ( '1', '2', '3', '4') ),	
	FecFundacion date not null check ( FecFundacion >= '1900' AND FecFundacion <= getdate() )
)
GO

CREATE TABLE Jugadores(
	ID int primary key not null identity(1,1),
	IDEquipo int not null foreign key references Equipos (ID),
	Nombre varchar(50) not null,
	Apellido varchar(50) not null,
	FecNacimiento date not null check ( FecNacimiento >= '1900-01-01' ),
    Sueldo money null check ( Sueldo > 0),	
	Dni varchar(10) not null unique
)
GO