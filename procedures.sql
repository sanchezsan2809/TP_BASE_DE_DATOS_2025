USE GD2C2025
GO

CREATE SCHEMA GRUPO_43 AUTHORIZATION dbo;
GO

IF OBJECT_ID('GRUPO_43.profesor', 'U') IS NOT NULL
DROP TABLE GRUPO_43.profesor;

IF OBJECT_ID('GRUPO_43.alumno', 'U') IS NOT NULL
DROP TABLE GRUPO_43.alumno;

IF OBJECT_ID('GRUPO_43.sede', 'U') IS NOT NULL
DROP TABLE GRUPO_43.sede;

IF OBJECT_ID('GRUPO_43.localidad', 'U') IS NOT NULL
DROP TABLE GRUPO_43.localidad;

IF OBJECT_ID('GRUPO_43.modulo', 'U') IS NOT NULL
DROP TABLE GRUPO_43.modulo;

IF OBJECT_ID('GRUPO_43.evaluacion', 'U') IS NOT NULL
DROP TABLE GRUPO_43.evaluacion;

IF OBJECT_ID('GRUPO_43.tp', 'U') IS NOT NULL
DROP TABLE GRUPO_43.tp;

IF OBJECT_ID('GRUPO_43.instancia_final', 'U') IS NOT NULL
DROP TABLE GRUPO_43.instancia_final;

IF OBJECT_ID('GRUPO_43.inscripcion_final', 'U') IS NOT NULL
DROP TABLE GRUPO_43.inscripcion_final;

IF OBJECT_ID('GRUPO_43.factura', 'U') IS NOT NULL
DROP TABLE GRUPO_43.factura;

IF OBJECT_ID('GRUPO_43.detalle_factura', 'U') IS NOT NULL
DROP TABLE GRUPO_43.detalle_factura;

CREATE TABLE GRUPO_43.localidad(
	localidad_id char(8) CONSTRAINT PK_localidad PRIMARY KEY,
	localidad_descripcion NVARCHAR(255) NOT NULL,
	localidad_provincia NVARCHAR(255) NOT NULL
);
GO

/* Gesti�n de inscripciones*/

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

CREATE TABLE GRUPO_43.sede(
	sede_id char(8) CONSTRAINT PK_sede PRIMARY KEY,
	sede_direccion nvarchar(255) DEFAULT 'SIN ESPECIFICAR',
	sede_localidad char(8) DEFAULT '00000000', 
	sede_nombre nvarchar(255),
	sede_telefono nvarchar(255) DEFAULT 'SIN ESPECIFICAR',
	sede_mail nvarchar(255) DEFAULT 'SIN ESPECIFICAR', 
	FOREIGN KEY(sede_localidad) REFERENCES GRUPO_43.localidad(localidad_id)
)
GO

CREATE OR ALTER PROCEDURE GRUPO_43.sedes
AS
BEGIN
	SET NOCOUNT ON;
	
	TRUNCATE TABLE GRUPO_43.sede;

	IF NOT EXISTS(SELECT 1 FROM GRUPO_43.localidad WHERE localidad_id = '00000000')
	BEGIN
		INSERT INTO GRUPO_43.localidad(localidad_id, localidad_descripcion, localidad_provincia)
		VALUES('00000000', 'SIN ESPECIFICAR', 'SIN ESPECIFICAR');
	END

	INSERT INTO GRUPO_43.sede(
		sede_id, 
		sede_direccion,
		sede_localidad, 
		sede_nombre,
		sede_telefono, 
		sede_mail
	)
	SELECT
		RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY Sede_nombre) AS VARCHAR(8)), 8),
		ISNULL(Sede_Direccion, 'SIN ESPECIFICAR'),
		ISNULL(l.localidad_id, '00000000') sede_localidad,
		Sede_Nombre,
		ISNULL(Sede_Telefono, 'SIN ESPECIFICAR'),
		ISNULL(Sede_Mail, 'SIN ESPECIFICAR')
	FROM
		(SELECT DISTINCT
			Sede_Direccion, 
			Sede_Localidad, 
			Sede_Provincia,
			Sede_Nombre, 
			Sede_Telefono,  
			Sede_Mail
		FROM gd_esquema.Maestra) gd
	LEFT JOIN GRUPO_43.localidad l 
		ON l.localidad_descripcion = gd.Sede_Localidad
		AND l.localidad_provincia = gd.Sede_provincia;
END
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
GO	

CREATE OR ALTER PROCEDURE GRUPO_43.evaluaciones
AS
BEGIN
	TRUNCATE TABLE GRUPO_43.evaluacion;

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
			Evaluacion_Curso_Instancia AS evaluacion_instancia, -- cambiar a: ma.Evaluacion_Curso_Instancia
			Evaluacion_Curso_Presente AS evaluacion_presente, -- cambiar a: ma.Evaluacion_Curso_Presente
			Evaluacion_Curso_Nota AS evaluacion_nota, -- cambiar a: ma.Evaluacion_Curso_Nota
			Evaluacion_Curso_fechaEvaluacion AS evaluacion_fecha -- cambiar a: ma.Evaluacion_Curso_fechaEvaluacion
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

CREATE TABLE GRUPO_43.tp(
		-- tp_curso_id CHAR(8),
		-- tp_alumno_id CHAR(8),
		tp_nota BIGINT NOT NULL DEFAULT 0,
		tp_fecha_evaluacion DATETIME2(6),
		-- CONSTRAINT PK_tp PRIMARY KEY (tp_curso_id, tp_alumno_id),
		-- FOREIGN KEY(tp_curso_id) REFERENCES GRUPO_43.curso(curso_id),
		-- FOREIGN KEY(tp_alumno_id) REFERENCES GRUPO_43.alumno(alumno_id)
	);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.tps
AS
BEGIN
	TRUNCATE TABLE GRUPO_43.tp
	
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

---- GESTION DE PAGOS

CREATE TABLE GRUPO_43.factura(
	fact_nro BIGINT CONSTRAINT PK_factura PRIMARY KEY,
	fact_fecha_emision DATETIME2(6),
	fact_fecha_venc DATETIME2(6),
	fact_importe_total DECIMAL(18,2),
	fact_alumno_legajo BIGINT NULL,
	FOREIGN KEY(fact_alumno_legajo) REFERENCES GRUPO_43.alumno(alumno_legajo)
	);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.facturas
AS
BEGIN
	TRUNCATE TABLE GRUPO_43.factura;

	INSERT INTO GRUPO_43.factura(
		fact_nro,
		fact_fecha_emision,
		fact_fecha_venc,
		fact_importe_total,
		fact_alumno_legajo
	)
	SELECT DISTINCT
		p.Factura_Numero,
		p.Factura_FechaEmision,
		p.Factura_FechaVencimiento,
		p.Factura_Total,
		a.alumno_legajo
	FROM gd_esquema.Maestra p
	INNER JOIN GRUPO_43.alumno a ON a.alumno_legajo = p.Alumno_Legajo
	WHERE p.Factura_Numero IS NOT NULL

END;
GO

CREATE TABLE GRUPO_43.detalle_factura(
	detalle_factura_fact_id BIGINT NOT NULL,
	detalle_factura_curso_id BIGINT NOT NULL,
	detalle_factura_periodo_anio BIGINT NOT NULL,
	detalle_factura_periodo_mes BIGINT NOT NULL,
	detalle_factura_importe DECIMAL(8,2),
	FOREIGN KEY(detalle_factura_fact_id) REFERENCES GRUPO_43.factura(fact_nro),
	CONSTRAINT PK_detalle_factura PRIMARY KEY (detalle_factura_fact_id,detalle_factura_curso_id,detalle_factura_periodo_anio,detalle_factura_periodo_mes)
	);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.factura_detalles
AS
BEGIN
	TRUNCATE TABLE GRUPO_43.detalle_factura;

	INSERT INTO GRUPO_43.detalle_factura(
		detalle_factura_fact_id,
		detalle_factura_curso_id,
		detalle_factura_periodo_anio,
		detalle_factura_periodo_mes,
		detalle_factura_importe
	)
	SELECT DISTINCT
		f.fact_nro,
		p.Curso_Codigo,
		p.Periodo_Anio,
		p.Periodo_Mes,
		p.Detalle_Factura_Importe
	FROM gd_esquema.Maestra p
	INNER JOIN GRUPO_43.factura f ON f.fact_nro = p.Factura_Numero
	WHERE p.Curso_Codigo IS NOT NULL

END;
GO

EXEC GRUPO_43.modulos;
GO

EXEC GRUPO_43.localidades;
GO

EXEC GRUPO_43.sedes;
GO

EXEC GRUPO_43.alumnos;
GO

EXEC GRUPO_43.evaluaciones;
GO

EXEC GRUPO_43.tps;
GO

EXEC GRUPO_43.profesores;
GO


EXEC GRUPO_43.instancias_finales;
GO

EXEC GRUPO_43.inscripciones_finales;
GO

EXEC GRUPO_43.facturas;
GO

EXEC GRUPO_43.factura_detalles;
GO

SELECT *
FROM GRUPO_43.sede
