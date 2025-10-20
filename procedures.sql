USE GD2C2025
GO

CREATE OR ALTER PROCEDURE profesores
AS
BEGIN
	IF OBJECT_ID('dbo.profesor', 'U') IS NOT NULL
	DROP TABLE dbo.profesor;

	CREATE TABLE dbo.profesor(
	profesor_nombre NVARCHAR(255),
	profesor_apellido NVARCHAR(255),
	profesor_dni NVARCHAR(255),
	profesor_fecha_nacimiento DATETIME2(6),
	profesor_localidad NVARCHAR(255),
	profesor_mail NVARCHAR(255),
	profesor_direccion NVARCHAR(255),
	profesor_telefono NVARCHAR(255)
	)

	INSERT INTO profesor
	SELECT DISTINCT 
	Profesor_nombre, 
	Profesor_Apellido, 
	Profesor_Dni,
	Profesor_FechaNacimiento, 
	Profesor_Localidad, 
	Profesor_Mail, 
	Profesor_Direccion, 
	Profesor_Telefono 
	FROM gd_esquema.maestra
END;
GO


EXEC dbo.profesores
SELECT * FROM profesor