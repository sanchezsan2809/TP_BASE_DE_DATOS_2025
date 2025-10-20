USE GD2C2025
GO

CREATE SCHEMA GRUPO_43 AUTHORIZATION dbo;
GO

CREATE OR ALTER PROCEDURE GRUPO_43.profesores
AS
BEGIN
	IF OBJECT_ID('GRUPO_43.profesor', 'U') IS NOT NULL
	DROP TABLE GRUPO_43.profesor;

	CREATE TABLE GRUPO_43.profesor(
		profesor_id CHAR(8),
		profesor_nombre NVARCHAR(255),
		profesor_apellido NVARCHAR(255),
		profesor_dni NVARCHAR(255),
		profesor_fecha_nacimiento DATETIME2(6),
		profesor_localidad NVARCHAR(255),
		profesor_mail NVARCHAR(255),
		profesor_direccion NVARCHAR(255),
		profesor_telefono NVARCHAR(255)
	);


	DECLARE 
		@id INT = 1,
		@nombre NVARCHAR(255),
		@apellido NVARCHAR(255),
		@dni NVARCHAR(255),
		@fecha_nacimiento DATETIME2(6),
		@localidad NVARCHAR(255),
		@mail NVARCHAR(255),
		@direccion NVARCHAR(255),
		@telefono NVARCHAR(255);

	DECLARE c_profesor CURSOR FOR 
		SELECT DISTINCT 
		Profesor_nombre, 
		Profesor_Apellido, 
		Profesor_Dni,
		Profesor_FechaNacimiento, 
		Profesor_Localidad, 
		Profesor_Mail, 
		Profesor_Direccion, 
		Profesor_Telefono 
		FROM gd_esquema.maestra;

	OPEN c_profesor;
	FETCH NEXT FROM c_profesor INTO
		@nombre, 
		@apellido, 
		@dni, 
		@fecha_nacimiento, 
		@localidad, 
		@mail, 
		@direccion, 
		@telefono; 

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO GRUPO_43.profesor(
			profesor_id, 
			profesor_nombre, 
			profesor_apellido, 
			profesor_dni, 
			profesor_fecha_nacimiento, 
			profesor_localidad, 
			profesor_mail, 
			profesor_direccion, 
			profesor_telefono)
		VALUES(
			RIGHT('00000000' + CAST(@id AS varchar(8)), 8), 
			@nombre, 
			@apellido, 
			@dni, 
			@fecha_nacimiento, 
			@localidad, 
			@mail, 
			@direccion, 
			@telefono
		);

		SET @id += 1;

		FETCH NEXT FROM c_profesor INTO
			@nombre, 
			@apellido, 
			@dni, 
			@fecha_nacimiento, 
			@localidad, 
			@mail, 
			@direccion, 
			@telefono; 
	END

	CLOSE c_profesor;
	DEALLOCATE c_profesor;

END;
GO

