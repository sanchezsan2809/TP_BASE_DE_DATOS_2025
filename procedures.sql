USE GD2C2025
GO

CREATE SCHEMA GRUPO_43 AUTHORIZATION dbo;
GO

IF OBJECT_ID('GRUPO_43.profesor', 'U') IS NOT NULL
DROP TABLE GRUPO_43.profesor;


IF OBJECT_ID('GRUPO_43.localidad', 'U') IS NOT NULL
DROP TABLE GRUPO_43.localidad;

CREATE TABLE GRUPO_43.localidad(
	localidad_id char(8) CONSTRAINT PK_localidad PRIMARY KEY,
	localidad_descripcion NVARCHAR(255) NOT NULL,
	localidad_provincia NVARCHAR(255) NOT NULL
);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.localidades
AS 
BEGIN
	
	INSERT INTO GRUPO_43.localidad (localidad_id, localidad_descripcion, localidad_provincia)
	SELECT
		RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY localidad_provincia, localidad_descripcion) AS VARCHAR(8)), 8),
		localidad_descripcion,
		localidad_provincia
	FROM(
		SELECT DISTINCT 
			Profesor_Localidad as localidad_descripcion, 
			Profesor_Provincia as localidad_provincia
		FROM gd_esquema.Maestra
		WHERE Profesor_Localidad IS NOT NULL AND Profesor_Provincia IS NOT NULL

		UNION

		SELECT DISTINCT
			Alumno_Localidad, Alumno_Provincia
		FROM gd_esquema.Maestra
		WHERE Alumno_Localidad IS NOT NULL AND Alumno_Provincia IS NOT NULL

		UNION

		SELECT DISTINCT
			Sede_Localidad, Sede_Provincia
		FROM gd_esquema.Maestra
		WHERE Sede_Localidad IS NOT NULL AND Sede_Localidad IS NOT NULL

	)localidad

END
GO

EXEC GRUPO_43.localidades;
GO

CREATE TABLE GRUPO_43.profesor(
		profesor_id CHAR(8) CONSTRAINT PK_profesor PRIMARY KEY,
		profesor_nombre NVARCHAR(255) NOT NULL,
		profesor_apellido NVARCHAR(255) NOT NULL,
		profesor_dni NVARCHAR(255) NOT NULL CONSTRAINT UQ_profesor_dni UNIQUE,
		profesor_fecha_nacimiento DATETIME2(6),
		profesor_localidad char(8) DEFAULT '00000000',
		profesor_mail NVARCHAR(255) DEFAULT 'SIN ESPECIFICAR',
		profesor_direccion NVARCHAR(255) DEFAULT 'SIN ESPECIFICAR',
		profesor_telefono NVARCHAR(255) DEFAULT 'SIN ESPECIFICAR', 
		FOREIGN KEY(profesor_localidad) REFERENCES GRUPO_43.localidad(localidad_id)
);

GO

CREATE OR ALTER PROCEDURE GRUPO_43.profesores
AS
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
		profesor_telefono
	)
	SELECT DISTINCT
		RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY Profesor_Dni) AS VARCHAR(8)), 8) profesor_id,
		Profesor_nombre, 
		Profesor_Apellido,
		Profesor_Dni,
		Profesor_FechaNacimiento,
		l.localidad_id,
		ISNULL(Profesor_Mail, 'SIN ESPECIFICAR') profesor_mail,
		ISNULL(Profesor_Direccion, 'SIN ESPECIFICAR') profesor_direccion,
		ISNULL(Profesor_Telefono, 'SIN ESPECIFICAR') profesor_telefono
	FROM(
		SELECT DISTINCT
			Profesor_Nombre,
			Profesor_Apellido,
			Profesor_Dni,
			Profesor_FechaNacimiento,
			Profesor_Localidad,		
			Profesor_Mail,
			Profesor_Direccion,
			Profesor_Telefono
		FROM gd_esquema.Maestra
		WHERE Profesor_Dni IS NOT NULL
	)p
	LEFT JOIN GRUPO_43.localidad l ON l.localidad_descripcion = p.Profesor_Localidad 

END;
GO

EXEC GRUPO_43.profesores
GO

SELECT *
FROM GRUPO_43.localidad

SELECT *
FROM GRUPO_43.profesor