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

---- GESTION DE EVALUACIONES:

CREATE OR ALTER PROCEDURE GRUPO_43.modulos
AS 
BEGIN
	IF OBJECT_ID('GRUPO_43.modulo', 'U') IS NOT NULL
	DROP TABLE GRUPO_43.modulo;

	CREATE TABLE GRUPO_43.modulo(
		modulo_id char(8) CONSTRAINT PK_localidad PRIMARY KEY,
		-- falta: modulo_curso_id char(8) CONSTRAINT PK_localidad PRIMARY KEY 
		modulo_nombre VARCHAR(255) NOT NULL,
		modulo_descripcion VARCHAR(255) NOT NULL
	);

	INSERT INTO GRUPO_43.modulo (modulo_id, modulo_nombre, modulo_descripcion)
	SELECT
		RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY modulo_nombre, modulo_descripcion) AS VARCHAR(8)), 8),
		modulo_nombre,
		modulo_descripcion
	FROM(
		SELECT DISTINCT 
			Modulo_Descripcion as modulo_descripcion,
			Modulo_Nombre as modulo_nombre
		FROM gd_esquema.Maestra
		WHERE Modulo_Nombre IS NOT NULL AND Modulo_Descripcion IS NOT NULL
	)modulo

END
GO

CREATE OR ALTER PROCEDURE GRUPO_43.evaluaciones
AS
BEGIN
	IF OBJECT_ID('GRUPO_43.evaluacion', 'U') IS NOT NULL
	DROP TABLE GRUPO_43.evaluacion;

	CREATE TABLE GRUPO_43.evaluacion(
		-- evaluacion_modulo_id CHAR(8),
		-- evaluacion_curso_id CHAR(8)
		-- evaluacion_alumno_id CHAR(8)
		evaluacion_instancia BIGINT NOT NULL,
		evaluacion_presente BIT NOT NULL,
		evaluacion_nota BIGINT NULL DEFAULT 1,
		evaluacion_fecha DATETIME2(6),
		-- CONSTRAINT PK_evaluacion PRIMARY KEY (evaluacion_modulo_id, evaluacion_curso_id, evaluacion_alumno_id),
		-- FOREIGN KEY(evaluacion_modulo_id) REFERENCES GRUPO_43.modulo(modulo_id)
		-- FOREIGN KEY(evaluacion_curso_id) REFERENCES GRUPO_43.curso(curso_id)
		-- FOREIGN KEY(evaluacion_alumno_id) REFERENCES GRUPO_43.alumno(alumno_id)
	);

INSERT INTO GRUPO_43.evaluacion(
		-- evaluacion_modulo_id,
		-- evaluacion_curso_id,
		-- evaluacion_alumno_id,
		evaluacion_instancia,
		evaluacion_presente,
		evaluacion_nota,
		evaluacion_fecha
	)
	SELECT DISTINCT
			-- m.modulo_id,
			-- c.curso_id
			-- a.alumno_id
			Evaluacion_Curso_Instancia, -- cambiar a: ma.Evaluacion_Curso_Instancia
			Evaluacion_Curso_Presente, -- cambiar a: ma.Evaluacion_Curso_Presente
			Evaluacion_Curso_Nota, -- cambiar a: ma.Evaluacion_Curso_Nota
			Evaluacion_Curso_fechaEvaluacion -- cambiar a: ma.Evaluacion_Curso_fechaEvaluacion
		 FROM gd_esquema.Maestra
 --   JOIN GRUPO_43.modulo m
 --       ON m.modulo_nombre = ma.Modulo_Nombre
 --       AND m.modulo_descripcion = ma.Modulo_Descripcion
	--JOIN GRUPO_43.curso c 
	--	ON c.curso_nombre = ma.Curso_Nombre
	--	AND c.curso_descripcion = ma.Curso_Descripcion
	--	AND c.curso_codigo = ma.Curso_Codigo
	--JOIN GRUPO_43.alumno a
	--	ON a.curso_nombre = ma.alumno
	--	AND a.alumno_dni = ma.Alumno_Dni
	--	AND a.alumno = ma.Alumno_Legajo
    WHERE Evaluacion_Curso_Instancia IS NOT NULL -- cambiar por: ma.Evaluacion_Curso_Instancia

END;
GO

EXEC GRUPO_43.evaluaciones;
GO

CREATE OR ALTER PROCEDURE GRUPO_43.tps
AS
BEGIN
	IF OBJECT_ID('GRUPO_43.tp', 'U') IS NOT NULL
	DROP TABLE GRUPO_43.tp;

	CREATE TABLE GRUPO_43.tp(
		-- tp_curso_id CHAR(8),
		-- tp_alumno_id CHAR(8),
		tp_nota BIGINT NOT NULL DEFAULT 0,
		tp_fecha_evaluacion DATETIME2(6),
		-- CONSTRAINT PK_tp PRIMARY KEY (tp_curso_id, tp_alumno_id),
		-- FOREIGN KEY(tp_curso_id) REFERENCES GRUPO_43.curso(curso_id),
		-- FOREIGN KEY(tp_alumno_id) REFERENCES GRUPO_43.alumno(alumno_id)
	);


	INSERT INTO GRUPO_43.tp(
		-- tp_curso_id,
		-- tp_alumno_id,
		tp_nota,
		tp_fecha_evaluacion
	)
	SELECT
		Trabajo_Practico_Nota,
		Trabajo_Practico_FechaEvaluacion
	FROM(
		SELECT DISTINCT
			Trabajo_Practico_Nota,
			Trabajo_Practico_FechaEvaluacion
		FROM gd_esquema.Maestra
		WHERE Trabajo_Practico_Nota IS NOT NULL and Trabajo_Practico_FechaEvaluacion IS NOT NULL 
	)tp
	-- Cuando esten todas las tablas se podrá vincular sus FK, logica similar a la de la tabla "evaluacion"

END;
GO

EXEC GRUPO_43.tps;
GO