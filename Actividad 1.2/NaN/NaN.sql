CREATE DATABASE ActividadGrupal3
GO

USE ActividadGrupal3
GO

-- N Equipos de futbol participan en N competencias	


CREATE TABLE Equipos(
	ID int primary key not null identity(1,1),
	--IDEstadio int not null foreign key references Estadios (ID),
	Nombre varchar(100) not null,
	Nombre_ApellidoDT varchar(100) not null,
    Division tinyint not null check ( Division in ( '1', '2', '3', '4') ),	
	FecFundacion date not null check ( FecFundacion >= '1900' AND FecFundacion <= getdate() )
)
GO

CREATE TABLE Competencias(
	ID int primary key not null identity(1,1),
	Nombre varchar(100) not null,
	Internacional bit not null,
	Temporada smallint not null check ( Temporada >= 1900 AND Temporada <= YEAR(getDate()) )
)
GO

CREATE TABLE Competencias_X_Equipos (
	IDCompetencia int,
	IDEquipo int,
	PRIMARY KEY (IDCompetencia, IDEquipo),
	FOREIGN KEY (IDCompetencia) REFERENCES Competencias (ID),
	FOREIGN KEY (IDEquipo) REFERENCES Equipos (ID)
)
GO