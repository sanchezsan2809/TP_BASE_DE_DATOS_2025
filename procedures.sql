USE GD2C2025
GO

CREATE SCHEMA GRUPO_43 AUTHORIZATION dbo;
GO

IF OBJECT_ID('GRUPO_43.profesor', 'U') IS NOT NULL
DROP TABLE GRUPO_43.profesor;

IF OBJECT_ID('GRUPO_43.alumno', 'U') IS NOT NULL
DROP TABLE GRUPO_43.alumno;

IF OBJECT_ID('GRUPO_43.localidad', 'U') IS NOT NULL
DROP TABLE GRUPO_43.localidad;

IF OBJECT_ID('GRUPO_43.modulo', 'U') IS NOT NULL
DROP TABLE GRUPO_43.modulo;

IF OBJECT_ID('GRUPO_43.instancia_final', 'U') IS NOT NULL
DROP TABLE GRUPO_43.instancia_final;

IF OBJECT_ID('GRUPO_43.inscripcion_final', 'U') IS NOT NULL
DROP TABLE GRUPO_43.inscripcion_final;

CREATE TABLE GRUPO_43.localidad(
	localidad_id char(8) CONSTRAINT PK_localidad PRIMARY KEY,
	localidad_descripcion NVARCHAR(255) NOT NULL,
	localidad_provincia NVARCHAR(255) NOT NULL
);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.localidades
AS 
BEGIN
	TRUNCATE TABLE GRUPO_43.profesor;

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
	
	TRUNCATE TABLE GRUPO_43.profesor;

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

CREATE TABLE GRUPO_43.alumno(
	alumno_legajo BIGINT CONSTRAINT PK_alumno PRIMARY KEY,
	alumno_nombre VARCHAR(255) NOT NULL,
	alumno_apellido VARCHAR(255) NOT NULL,
	alumno_dni BIGINT NOT NULL CONSTRAINT UQ_alumno_dni UNIQUE,
	alumno_fecha_nacimiento DATETIME2(6),
	alumno_localidad CHAR(8) NOT NULL CONSTRAINT DF_alumno_localidad DEFAULT '00000000',
    alumno_mail VARCHAR(255) DEFAULT 'SIN ESPECIFICAR',
    alumno_domicilio VARCHAR(255) DEFAULT 'SIN ESPECIFICAR',
    alumno_telefono VARCHAR(255) DEFAULT 'SIN ESPECIFICAR',
	FOREIGN KEY(alumno_localidad) REFERENCES GRUPO_43.localidad(localidad_id)
	);
GO


CREATE OR ALTER PROCEDURE GRUPO_43.alumnos
AS
BEGIN
	TRUNCATE TABLE GRUPO_43.alumno;

	INSERT INTO GRUPO_43.alumno(
		alumno_legajo,
		alumno_nombre,
		alumno_apellido,
		alumno_dni,
		alumno_fecha_nacimiento,
		alumno_localidad,
		alumno_mail,
		alumno_domicilio,
		alumno_telefono
	)
	SELECT DISTINCT
		Alumno_Legajo,
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
			Alumno_Legajo,
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

---- GESTION DE EVALUACIONES:

CREATE TABLE GRUPO_43.modulo(
	modulo_id char(8) CONSTRAINT PK_modulo PRIMARY KEY,
	-- falta: modulo_curso_id char(8) CONSTRAINT PK_localidad PRIMARY KEY 
	modulo_nombre VARCHAR(255) NOT NULL,
	modulo_descripcion VARCHAR(255) NOT NULL
);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.modulos
AS 
BEGIN
	TRUNCATE TABLE GRUPO_43.modulo;
	

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

CREATE TABLE GRUPO_43.instancia_final(
	instancia_final_id CHAR(8) CONSTRAINT PK_instancia_final PRIMARY KEY,
	instancia_final_hora VARCHAR(255) NOT NULL,
	instancia_final_descripcion VARCHAR(255) NOT NULL,
	instancia_final_fecha DATETIME2(6)
	-- FOREIGN KEY(instancia_final_curso) REFERENCES GRUPO43.curso(curso_id)
);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.instancias_finales
AS
BEGIN
	SET NOCOUNT ON
	TRUNCATE TABLE GRUPO_43.instancia_final;


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

CREATE TABLE GRUPO_43.inscripcion_final(
	inscripcion_final_nro BIGINT CONSTRAINT PK_inscripcion_final PRIMARY KEY,
	inscripcion_final_fecha VARCHAR(255) NOT NULL,
	--inscripcion_final_instancia CHAR(8),
	--inscripcion_final_alumno_id CHAR(8),
	--FOREIGN KEY(inscripcion_final_instancia) REFERENCES GRUPO_43.instancia_final(instancia_final_id)
	-- FOREIGN KEY(inscripcion_final_alumno_id) REFERENCES GRUPO_43.alumno(alumno_id)
);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.inscripciones_finales
AS 
BEGIN
	SET NOCOUNT ON
	TRUNCATE TABLE GRUPO_43.inscripcion_final;

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

EXEC GRUPO_43.modulos;
GO

EXEC GRUPO_43.localidades;
GO

EXEC GRUPO_43.alumnos;
GO

EXEC GRUPO_43.profesores;
GO


EXEC GRUPO_43.instancias_finales;
GO

EXEC GRUPO_43.inscripciones_finales;
GO