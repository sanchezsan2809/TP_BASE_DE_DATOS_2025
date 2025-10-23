USE GD2C2025
GO

CREATE SCHEMA GRUPO_43 AUTHORIZATION dbo;
GO

CREATE OR ALTER PROCEDURE GRUPO_43.localidades
AS 
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('GRUPO_43.localidad', 'U') IS NOT NULL
        DROP TABLE GRUPO_43.localidad;

    CREATE TABLE GRUPO_43.localidad(
        localidad_id CHAR(8) CONSTRAINT PK_localidad PRIMARY KEY,
        localidad_descripcion NVARCHAR(255) NOT NULL,
        localidad_provincia NVARCHAR(255) NOT NULL
    );

    INSERT INTO GRUPO_43.localidad (localidad_id, localidad_descripcion, localidad_provincia)
    SELECT
        RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY localidad_provincia, localidad_descripcion) AS VARCHAR(8)), 8),
        localidad_descripcion,
        localidad_provincia
    FROM (
        SELECT DISTINCT 
            Profesor_Localidad AS localidad_descripcion, 
            Profesor_Provincia AS localidad_provincia
        FROM gd_esquema.Maestra
        WHERE Profesor_Localidad IS NOT NULL AND Profesor_Provincia IS NOT NULL

        UNION

        SELECT DISTINCT
            Alumno_Localidad AS localidad_descripcion, 
            Alumno_Provincia AS localidad_provincia
        FROM gd_esquema.Maestra
        WHERE Alumno_Localidad IS NOT NULL AND Alumno_Provincia IS NOT NULL

        UNION

        SELECT DISTINCT
            Sede_Localidad AS localidad_descripcion, 
            Sede_Provincia AS localidad_provincia
        FROM gd_esquema.Maestra
        WHERE Sede_Localidad IS NOT NULL AND Sede_Provincia IS NOT NULL
    ) localidad;
END
GO


EXEC GRUPO_43.localidades;
GO

CREATE OR ALTER PROCEDURE GRUPO_43.profesores
AS
BEGIN
	IF OBJECT_ID('GRUPO_43.profesor', 'U') IS NOT NULL
	DROP TABLE GRUPO_43.profesor;

	CREATE TABLE GRUPO_43.profesor(
		profesor_id CHAR(8) CONSTRAINT PK_profesor PRIMARY KEY,
		profesor_nombre NVARCHAR(255) NOT NULL,
		profesor_apellido NVARCHAR(255) NOT NULL,
		profesor_dni NVARCHAR(255) NOT NULL CONSTRAINT UQ_profesor_dni UNIQUE,
		profesor_fecha_nacimiento DATETIME2(6),
		profesor_localidad CHAR(8) NOT NULL CONSTRAINT DF_localidad DEFAULT '00000000',
        profesor_mail NVARCHAR(255) DEFAULT 'SIN ESPECIFICAR',
        profesor_direccion NVARCHAR(255) DEFAULT 'SIN ESPECIFICAR',
        profesor_telefono NVARCHAR(255) DEFAULT 'SIN ESPECIFICAR',
		FOREIGN KEY(profesor_localidad) REFERENCES GRUPO_43.localidad(localidad_id)
	);


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
		ISNULL(l.localidad_id, '00000000') AS profesor_localidad,
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
			Profesor_Provincia,
			Profesor_Mail,
			Profesor_Direccion,
			Profesor_Telefono
		FROM gd_esquema.Maestra
		WHERE Profesor_Dni IS NOT NULL
	)p
	LEFT JOIN GRUPO_43.localidad l ON l.localidad_descripcion = p.Profesor_Localidad AND l.localidad_provincia = p.Profesor_Provincia;

END;
GO

EXEC GRUPO_43.profesores;
GO

CREATE OR ALTER PROCEDURE GRUPO_43.alumnos
AS
BEGIN
	IF OBJECT_ID('GRUPO_43.alumno', 'U') IS NOT NULL
	DROP TABLE GRUPO_43.alumno;

	CREATE TABLE GRUPO_43.alumno(
		alumno_id CHAR(8) CONSTRAINT PK_alumno PRIMARY KEY,
		alumno_nombre VARCHAR(255) NOT NULL,
		alumno_apellido VARCHAR(255) NOT NULL,
		alumno_dni BIGINT NOT NULL CONSTRAINT UQ_alumno_dni UNIQUE,
		alumno_fecha_nacimiento DATETIME2(6),
		alumno_localidad CHAR(8) NOT NULL CONSTRAINT DF_alumno_localidad DEFAULT '00000000',
        alumno_mail VARCHAR(255) DEFAULT 'SIN ESPECIFICAR',
        alumno_direccion VARCHAR(255) DEFAULT 'SIN ESPECIFICAR',
        alumno_telefono VARCHAR(255) DEFAULT 'SIN ESPECIFICAR',
		FOREIGN KEY(alumno_localidad) REFERENCES GRUPO_43.localidad(localidad_id)
	);


	INSERT INTO GRUPO_43.alumno(
		alumno_id,
		alumno_nombre,
		alumno_apellido,
		alumno_dni,
		alumno_fecha_nacimiento,
		alumno_localidad,
		alumno_mail,
		alumno_direccion,
		alumno_telefono
	)
	SELECT DISTINCT
		RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY Alumno_Dni) AS VARCHAR(8)), 8) alumno_id,
		Alumno_Nombre, 
		Alumno_Apellido,
		Alumno_Dni,
		Alumno_FechaNacimiento,
		ISNULL(l.localidad_id, '00000000') AS alumno_localidad,
		ISNULL(Alumno_Mail, 'SIN ESPECIFICAR') alumno_mail,
		ISNULL(Alumno_Direccion, 'SIN ESPECIFICAR') alumno_direccion,
		ISNULL(Alumno_Telefono, 'SIN ESPECIFICAR') alumno_telefono
	FROM(
		SELECT DISTINCT
			Alumno_Nombre,
			Alumno_Apellido,
			Alumno_Dni,
			Alumno_FechaNacimiento,
			Alumno_Localidad,	
			Alumno_Provincia,
			Alumno_Mail,
			Alumno_Direccion,
			Alumno_Telefono
		FROM gd_esquema.Maestra
		WHERE Alumno_Dni IS NOT NULL
	)p
	LEFT JOIN GRUPO_43.localidad l ON l.localidad_descripcion = p.Alumno_Localidad AND l.localidad_provincia = p.Alumno_Provincia;

END;
GO

EXEC GRUPO_43.alumnos;
GO