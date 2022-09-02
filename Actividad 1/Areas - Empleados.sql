CREATE DATABASE Clase1
GO

USE Clase1
GO

CREATE TABLE Areas (
	ID smallint primary key identity(1, 1),
	Nombre varchar(50) not null,
	Presupuesto money not null check ( Presupuesto > 0),
	Mail varchar(120) not null unique
)
GO

CREATE TABLE Empleados(
	ID bigint not null primary key,
	IDArea smallint  null foreign key references Areas (ID),
	Apelidos varchar(100) not null,
	Nombres varchar(100) not null,
	Nacimiento date null
)
GO