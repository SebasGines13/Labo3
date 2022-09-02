CREATE DATABASE ClaseDos
GO

USE ClaseDos
GO

CREATE TABLE Empleados(
	ID bigint not null primary key,
	Apelidos varchar(100) not null,
	Nombres varchar(100) not null,
	Genero char null,	
	IDArea smallint  null
)
GO

ALTER TABLE Empleados
	ADD FechaNacimiento date null
GO

CREATE TABLE Areas(
	ID SMALLINT NOT NULL,
	Nombre VARCHAR(40) NOT NULL,
	Presupuesto MONEY NOT NULL,
	Email VARCHAR(120) NOT NULL UNIQUE
)
GO

ALTER TABLE Areas
	ADD Constraint PK_Areas Primary Key (ID)
GO

ALTER TABLE Areas
	ADD Constraint CHK_PresupuestoPositivo Check ( Presupuesto > 0 )
GO

ALTER TABLE Empleados
	ADD Constraint FK_Empleados_Areas foreign key (IDArea) references Areas(ID)
GO