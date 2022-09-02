CREATE DATABASE Actividad1
GO

USE Actividad1
GO

CREATE TABLE Carreras(
	ID varchar(4) primary key,
	Nombre varchar(100) not null,
	FecCreacion date not null check ( FecCreacion <= getdate() ),
    Mail varchar(120) not null,
	Nivel varchar(20) not null check ( Nivel in ( 'Diplomatura', 'Pregrado', 'Grado', 'Posgrado') )	
)
GO

CREATE TABLE Materias(
	ID int primary key identity(1, 1),
	IDCarrera varchar(4) not null foreign key references Carreras (ID),
	Nombre varchar(100) not null,
    CargaHoraria smallint not null check ( CargaHoraria > 0 )	
)
GO

CREATE TABLE Alumnos (
	Legajo int primary key identity(1000, 1),
	IDCarrera varchar(4) not null foreign key references Carreras (ID),	
	Apelidos varchar(100) not null,
	Nombres varchar(100) not null,
    FecNacimiento date not null check ( FecNacimiento <= getdate() ),
	Mail varchar(120) not null unique,
    Telefono varchar(20) null
)
GO

INSERT INTO Carreras ( ID, Nombre, FecCreacion, Mail, Nivel )
    values
    ('PROG', 'PROGRAMACION', '2022-03-09', 'programacion@utn.com.ar', 'PreGrado'),
    ('LSIS', 'LICENCIATURA EN ANALISIS DE SISTEMAS', '2022-03-02', 'analisisdesistemas@utn.com.ar', 'Grado'),
    ('LITE', 'LITERATURA', '2022-03-02', 'literatura@utn.com.ar', 'PosGrado'),
    ('ROB' , 'ROBOTICA', '2021-06-01', 'robotica@utn.com.ar', 'Diplomatura')
GO

INSERT INTO Materias ( IDCarrera, Nombre, CargaHoraria )
    values
    ('PROG','Laboratorio I', 60),
    ('PROG','Laboratorio II', 50),
    ('PROG','Laboratorio III', 40),
    ('PROG','Programacion I', 60),
    ('PROG','Programacion II', 50),
    ('PROG','Programacion III', 40),
    ('LSIS','Laboratorio I', 60),
    ('LSIS','Laboratorio II', 50),
    ('LSIS','Laboratorio III', 40),
    ('LSIS','Programacion I', 60),
    ('LSIS','Programacion II', 50),
    ('LSIS','Programacion III', 40),
    ('LITE','Lengua', 50),
    ('LITE','Historia del lenguaje', 50),
    ('ROB' ,'Algoritmos', 100),
    ('ROB' ,'Fisica', 90)
GO

INSERT INTO Alumnos ( IDCarrera, Apelidos, Nombres, FecNacimiento, Mail, Telefono )
    values
    ('PROG', 'PROGRAMACION', '2022-03-09', 'programacion@utn.com.ar', 'PreGrado')
GO
