USE GD2C2025
GO

CREATE SCHEMA GRUPO_43 AUTHORIZATION dbo;
GO

CREATE OR ALTER PROCEDURE GRUPO_43.localidades
AS 
BEGIN
	IF OBJECT_ID('GRUPO_43.localidad', 'U') IS NOT NULL
	DROP TABLE GRUPO_43.localidad;

	CREATE TABLE GRUPO_43.localidad(
		localidad_id char(8) CONSTRAINT PK_localidad PRIMARY KEY,
		localidad_descripcion NVARCHAR(255) NOT NULL,
		localidad_provincia NVARCHAR(255) NOT NULL
	);

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
		profesor_localidad char(8),
		profesor_mail NVARCHAR(255),
		profesor_direccion NVARCHAR(255),
		profesor_telefono NVARCHAR(255), 
		CONSTRAINT DF_fecha_nacimiento DEFAULT NULL FOR profesor_fecha_nacimiento,
		CONSTRAINT DF_localidad DEFAULT 'SIN ESPECIFICAR' FOR profesor_localidad,
		CONSTRAINT DF_mail DEFAULT 'SIN ESPECIFICAR' FOR profesor_mail,
		CONSTRAINT DF_direccion DEFAULT 'SIN ESPECIFICAR' FOR profesor_direccion,
		CONSTRAINT DF_telefono DEFAULT 'SIN ESPECIFICAR' FOR profesor_telefono,
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


CREATE OR ALTER PROCEDURE GRUPO_43.instancias_finales
AS
BEGIN
	SET NOCOUNT ON

	IF OBJECT_ID('GRUPO_43.instancia_final', 'U') IS NOT NULL
	DROP TABLE GRUPO_43.instancia_final;

	CREATE TABLE GRUPO_43.instancia_final(
		instancia_final_id CHAR(8) CONSTRAINT PK_instancia_final PRIMARY KEY,
		instancia_final_hora VARCHAR(255) NOT NULL,
		instancia_final_descripcion VARCHAR(255) NOT NULL,
		instancia_final_fecha DATETIME2(6)
		-- FOREIGN KEY(instancia_final_curso) REFERENCES GRUPO43.curso(curso_id)
	);

	INSERT INTO GRUPO_43.instancia_final (
	instancia_final_id,
	instancia_final_hora, 
	instancia_final_fecha, 
	instancia_final_descripcion
	--instancia_final_curso
	)
	 SELECT DISTINCT
        RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY instancia_final_fecha) AS VARCHAR(8)), 8) AS instancia_final_id,
        instancia_final_hora,
        instancia_final_fecha,
        instancia_final_descripcion
    FROM (
        SELECT DISTINCT
            Examen_final_Hora AS instancia_final_hora,
            Examen_final_Fecha AS instancia_final_fecha,
            Examen_final_Descripcion AS instancia_final_descripcion
        FROM gd_esquema.Maestra
        WHERE Examen_final_Fecha IS NOT NULL
    ) AS instancia;
	-- LEFT JOIN GRUPO_43.curso ON instancia.instancia_final_curso = curso_id
END 
GO

EXEC GRUPO_43.instancias_finales
GO

CREATE OR ALTER PROCEDURE GRUPO_43.inscripciones_finales
AS 
BEGIN
	SET NOCOUNT ON
	IF OBJECT_ID('GRUPO_43.inscripcion_final', 'U') IS NOT NULL
	DROP TABLE GRUPO_43.inscripcion_final;

	CREATE TABLE GRUPO_43.inscripcion_final(
		inscripcion_final_nro BIGINT CONSTRAINT PK_inscripcion_final PRIMARY KEY,
		inscripcion_final_fecha VARCHAR(255) NOT NULL,
		--inscripcion_final_instancia CHAR(8),
		--inscripcion_final_alumno_id CHAR(8),
		--FOREIGN KEY(inscripcion_final_instancia) REFERENCES GRUPO_43.instancia_final(instancia_final_id)
		-- FOREIGN KEY(inscripcion_final_alumno_id) REFERENCES GRUPO_43.alumno(alumno_id)
	);
	INSERT INTO GRUPO_43.inscripcion_final(
	inscripcion_final_nro,
	inscripcion_final_fecha 
	--inscripcion_final_instancia
	--instancia_final_alumno_id
	)
	SELECT DISTINCT
        inscripcion_final_nro,
        inscripcion_final_fecha
        --inscripcion_final_instancia
		--inscripcion_final_alumno_id
    FROM (
        SELECT DISTINCT
            Inscripcion_Final_Nro AS inscripcion_final_nro,
            Inscripcion_Final_Fecha AS inscripcion_final_fecha
        FROM gd_esquema.Maestra
        WHERE Inscripcion_Final_Nro IS NOT NULL
    ) AS inscripcion;
	--LEFT JOIN GRUPO_43.instancia_final if ON 
END 
GO

EXEC GRUPO_43.inscripciones_finales
GO