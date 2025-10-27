﻿﻿USE GD2C2025
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

IF OBJECT_ID('GRUPO_43.detalle_curso', 'U') IS NOT NULL
DROP TABLE GRUPO_43.detalle_curso;

IF OBJECT_ID('GRUPO_43.categoria', 'U') IS NOT NULL
DROP TABLE GRUPO_43.categoria;

IF OBJECT_ID('GRUPO_43.curso', 'U') IS NOT NULL
DROP TABLE GRUPO_43.curso;

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

IF OBJECT_ID('GRUPO_43.pago', 'U') IS NOT NULL
DROP TABLE GRUPO_43.pago;

IF OBJECT_ID('GRUPO_43.encuesta', 'U') IS NOT NULL
DROP TABLE GRUPO_43.encuesta;

IF OBJECT_ID('GRUPO_43.pregunta', 'U') IS NOT NULL
DROP TABLE GRUPO_43.pregunta;

IF OBJECT_ID('GRUPO_43.detalle_encuesta', 'U') IS NOT NULL
DROP TABLE GRUPO_43.detalle_encuesta;

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

CREATE TABLE GRUPO_43.turno(
	turno_id char(8),
	turno_descripcion NVARCHAR(255)
);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.turnos
AS
BEGIN
	SET NOCOUNT ON;
	TRUNCATE TABLE GRUPO_43.turno;

	INSERT INTO GRUPO_43.turno
	SELECT
		RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY Curso_Turno) AS VARCHAR(8)), 8),
		Curso_Turno
	FROM (
		SELECT DISTINCT Curso_Turno
		FROM gd_esquema.Maestra
		WHERE Curso_Turno IS NOT NULL
	)gd
END
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

CREATE TABLE GRUPO_43.categoria(
	 categoria_id char(8) CONSTRAINT PK_categoria PRIMARY KEY,
	 categoria_descripcion NVARCHAR(255)
)
GO

CREATE OR ALTER PROCEDURE GRUPO_43.categorias
AS
BEGIN
	
	SET NOCOUNT ON;
	TRUNCATE TABLE GRUPO_43.categoria;

	INSERT INTO GRUPO_43.categoria(
		categoria_id,
		categoria_descripcion
	)
	SELECT
		RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY Curso_Categoria) AS VARCHAR(8)), 8),
		Curso_Categoria
	FROM(
		SELECT DISTINCT Curso_Categoria
		FROM gd_esquema.Maestra
		WHERE Curso_Categoria IS NOT NULL)gd
END
GO

CREATE TABLE GRUPO_43.detalle_curso(
	detalle_curso_id char(8) CONSTRAINT PK_detalle_curso PRIMARY KEY,
	detalle_curso_nombre NVARCHAR(255),
	detalle_curso_descripcion NVARCHAR(255),
	detalle_curso_categoria char(8), 
	FOREIGN KEY(detalle_curso_categoria) REFERENCES GRUPO_43.categoria
)
GO


CREATE OR ALTER PROCEDURE GRUPO_43.detalles_curso
AS
BEGIN
	TRUNCATE TABLE GRUPO_43.detalle_curso;
	SET NOCOUNT ON;

	INSERT INTO GRUPO_43.detalle_curso(
		detalle_curso_id,
		detalle_curso_nombre,
		detalle_curso_descripcion,
		detalle_curso_categoria
	)
	SELECT 
		RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY Curso_Nombre) AS VARCHAR(8)), 8),
		Curso_Nombre,
		Curso_Descripcion,
		c.categoria_id
	FROM (
		SELECT DISTINCT
			Curso_Nombre,
			Curso_Descripcion,
			Curso_Categoria
		FROM gd_esquema.Maestra
	)gd JOIN GRUPO_43.categoria c ON categoria_descripcion = gd.Curso_Categoria
END
GO

CREATE TABLE GRUPO_43.curso(
	curso_codigo char(8) CONSTRAINT PK_curso PRIMARY KEY,
	curso_sede_id char(8),
	curso_profesor_id char(8),
	curso_turno_id char(8),
	curso_detalle_curso_id char(8),
	curso_dia nvarchar(255),
	curso_fecha_inicio nvarchar(255),
	curso_fecha_fin nvarchar(255),
	curso_duracion BIGINT,
	curso_precio_mensual decimal(38,2)
);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.cursos
AS
BEGIN
	SET NOCOUNT ON;
	TRUNCATE TABLE GRUPO_43.curso;

	INSERT INTO GRUPO_43.curso(
		curso_codigo,
		curso_sede_id, 
		curso_profesor_id,
		curso_turno_id,
		curso_detalle_curso_id,
		curso_fecha_inicio, 
		curso_fecha_fin,
		curso_duracion,
		curso_precio_mensual,
		curso_dia
	)
	SELECT 
		Curso_Codigo,
		s.sede_id,
		p.profesor_id,
		t.turno_id,
		d.detalle_curso_id, 
		Curso_FechaInicio,
		Curso_FechaFin,
		Curso_DuracionMeses, 
		Curso_PrecioMensual, 
		Curso_Dia
	FROM (
		SELECT DISTINCT 
		Curso_Codigo,
		Curso_FechaInicio,
		Curso_FechaFin, 
		Curso_DuracionMeses, 
		Curso_PrecioMensual, 
		Curso_Dia, 
		Sede_Nombre, 
		Profesor_Dni, 
		Curso_Turno, 
		Curso_Nombre
		FROM gd_esquema.Maestra
	)gd
	LEFT JOIN GRUPO_43.sede s ON gd.Sede_Nombre = s.sede_nombre
	LEFT JOIN GRUPO_43.profesor p ON gd.Profesor_Dni = p.profesor_dni
	LEFT JOIN GRUPO_43.turno t ON gd.Curso_Turno = t.turno_descripcion
	LEFT JOIN GRUPO_43.detalle_curso d ON gd.Curso_Nombre = d.detalle_curso_nombre 
	WHERE gd.Curso_Nombre IS NOT NULL

END
GO

CREATE TABLE GRUPO_43.inscripcion_curso(
	inscrip_curso_numero BIGINT CONSTRAINT PK_inscripcion_curso PRIMARY KEY,
	inscrip_curso_alumno_legajo BIGINT,
	inscrip_curso_codigo char(8),
	inscrip_curso_fecha datetime2(6),
	inscrip_curso_fecha_respuesta datetime2(6),
	inscrip_curso_estado NVARCHAR(255), 
	FOREIGN KEY(inscrip_curso_alumno_legajo) REFERENCES GRUPO_43.alumno,
	FOREIGN KEY(inscrip_curso_codigo) REFERENCES GRUPO_43.curso
);
GO


CREATE OR ALTER PROCEDURE GRUPO_43.inscripciones_curso
AS
BEGIN
	SET NOCOUNT ON;
	TRUNCATE TABLE GRUPO_43.inscripcion_curso;

	INSERT INTO GRUPO_43.inscripcion_curso(
		inscrip_curso_numero,
		inscrip_curso_alumno_legajo,
		inscrip_curso_codigo, 
		inscrip_curso_fecha,
		inscrip_curso_fecha_respuesta,
		inscrip_curso_estado
	)
	SELECT
		Inscripcion_Numero, 
		Alumno_Legajo,
		Curso_Codigo,
		Inscripcion_Fecha, 
		Inscripcion_FechaRespuesta,
		Inscripcion_Estado
	FROM (
		SELECT DISTINCT
			Inscripcion_Numero,
			Alumno_Legajo,
			Curso_Codigo, 
			Inscripcion_Fecha, 
			Inscripcion_FechaRespuesta, 
			Inscripcion_Estado
		FROM gd_esquema.Maestra
		WHERE 
			Inscripcion_Numero IS NOT NULL
			AND Alumno_Legajo IS NOT NULL
			AND Curso_Codigo IS NOT NULL
			AND Inscripcion_Fecha IS NOT NULL
	)gd


END
GO
---- GESTION DE EVALUACIONES:

CREATE TABLE GRUPO_43.detalle_modulo(
	detalle_modulo_nombre NVARCHAR(255) CONSTRAINT PK_detalle_modulo PRIMARY KEY,
	detalle_modulo_descripcion NVARCHAR(255)
);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.detalle_modulos
AS
BEGIN
	SET NOCOUNT ON;
	TRUNCATE TABLE GRUPO_43.detalle_modulo;

	INSERT INTO GRUPO_43.detalle_modulo(
		detalle_modulo_nombre,
		detalle_modulo_descripcion
	)
	SELECT
		Modulo_Nombre,
		Modulo_Descripcion
	FROM(
		SELECT DISTINCT
			Modulo_Nombre,
			Modulo_Descripcion
		FROM gd_esquema.Maestra
		WHERE Modulo_Nombre IS NOT NULL AND Modulo_Descripcion IS NOT NULL
	)gd
END	
GO

CREATE TABLE GRUPO_43.modulo(
	modulo_curso_id char(8), 
	modulo_detalle_modulo_nombre NVARCHAR(255),
	FOREIGN KEY(modulo_curso_id) REFERENCES GRUPO_43.curso,
	FOREIGN KEY(modulo_detalle_modulo_nombre) REFERENCES GRUPO_43.detalle_modulo,
	CONSTRAINT PK_MODULO PRIMARY KEY (modulo_curso_id, modulo_detalle_modulo_nombre)
);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.modulos
AS 
BEGIN
	SET NOCOUNT ON;
	TRUNCATE TABLE GRUPO_43.modulo;
	
	INSERT INTO GRUPO_43.modulo (modulo_curso_id, modulo_detalle_modulo_nombre)
	SELECT
		c.curso_codigo,
		d.detalle_modulo_nombre
	FROM(
		SELECT DISTINCT 
			Modulo_Nombre,
			Curso_Codigo	
		FROM gd_esquema.Maestra
		WHERE Modulo_Nombre IS NOT NULL AND Modulo_Descripcion IS NOT NULL
	)gd
	LEFT JOIN GRUPO_43.curso c ON gd.Curso_Codigo = c.curso_codigo
	LEFT JOIN GRUPO_43.detalle_modulo d ON gd.Modulo_Nombre = d.detalle_modulo_nombre
END
GO


CREATE TABLE GRUPO_43.evaluacion(
		evaluacion_modulo_nombre NVARCHAR(255),
		evaluacion_curso_id CHAR(8),
		evaluacion_alumno_legajo BIGINT,
		evaluacion_instancia BIGINT NOT NULL,
		evaluacion_presente BIT NOT NULL,
		evaluacion_nota BIGINT NULL DEFAULT 1,
		evaluacion_fecha DATETIME2(6),
		CONSTRAINT PK_evaluacion PRIMARY KEY (evaluacion_modulo_nombre, evaluacion_curso_id, evaluacion_alumno_legajo),
		FOREIGN KEY(evaluacion_curso_id,evaluacion_modulo_nombre) REFERENCES GRUPO_43.modulo,
		FOREIGN KEY(evaluacion_alumno_legajo) REFERENCES GRUPO_43.alumno
	);
GO	

CREATE OR ALTER PROCEDURE GRUPO_43.evaluaciones
AS
BEGIN

	SET NOCOUNT ON;
	TRUNCATE TABLE GRUPO_43.evaluacion;

	INSERT INTO GRUPO_43.evaluacion(
		evaluacion_modulo_nombre,
		evaluacion_curso_id,
		evaluacion_alumno_legajo,
		evaluacion_instancia,
		evaluacion_presente,
		evaluacion_nota,
		evaluacion_fecha
	)
	SELECT
		Modulo_Nombre,
		Curso_Codigo, 
		Alumno_Legajo, 
		Evaluacion_Curso_Instancia, 
		Evaluacion_Curso_Presente, 
		Evaluacion_Curso_Nota, 
		Evaluacion_Curso_fechaEvaluacion
	FROM(
	SELECT DISTINCT
			Modulo_Nombre,
			Curso_Codigo,
			Alumno_Legajo,
			Evaluacion_Curso_Instancia, 
			Evaluacion_Curso_Presente, 
			Evaluacion_Curso_Nota, 
			Evaluacion_Curso_fechaEvaluacion 
	FROM gd_esquema.Maestra
	WHERE
		Modulo_Nombre IS NOT NULL AND
		Curso_Codigo IS NOT NULL AND 
		Alumno_Legajo IS NOT NULL AND
		Evaluacion_Curso_Instancia IS NOT NULL AND
		Evaluacion_Curso_Presente IS NOT NULL AND
		Evaluacion_Curso_Nota IS NOT NULL AND
		Evaluacion_Curso_fechaEvaluacion IS NOT NULL
	)gd

END;
GO

CREATE TABLE GRUPO_43.tp(
		tp_curso_codigo CHAR(8),
		tp_alumno_legajo BIGINT,
		tp_nota BIGINT NOT NULL DEFAULT 0,
		tp_fecha_evaluacion DATETIME2(6),
		CONSTRAINT PK_tp PRIMARY KEY (tp_curso_codigo, tp_alumno_legajo),
		FOREIGN KEY(tp_curso_codigo) REFERENCES GRUPO_43.curso,
		FOREIGN KEY(tp_alumno_legajo) REFERENCES GRUPO_43.alumno
);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.tps
AS
BEGIN
	SET NOCOUNT ON;
	TRUNCATE TABLE GRUPO_43.tp;
	
	INSERT INTO GRUPO_43.tp(
		tp_curso_codigo,
		tp_alumno_legajo,
		tp_nota,
		tp_fecha_evaluacion
	)
	SELECT
		Curso_Codigo,
		Alumno_Legajo,
		Trabajo_Practico_Nota,
		Trabajo_Practico_FechaEvaluacion
	FROM(
		SELECT DISTINCT
			Trabajo_Practico_Nota,
			Trabajo_Practico_FechaEvaluacion,
			Alumno_Legajo, 
			Curso_Codigo
		FROM gd_esquema.Maestra
		WHERE Trabajo_Practico_Nota IS NOT NULL and Trabajo_Practico_FechaEvaluacion IS NOT NULL 
		)gd
END;
GO

CREATE TABLE GRUPO_43.instancia_final(
	instancia_final_id CHAR(8) CONSTRAINT PK_instancia_final PRIMARY KEY,
	instancia_final_curso char(8),
	instancia_final_hora NVARCHAR(255) NOT NULL,
	instancia_final_descripcion NVARCHAR(255) NOT NULL,
	instancia_final_fecha DATETIME2(6)
	FOREIGN KEY(instancia_final_curso) REFERENCES GRUPO_43.curso
);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.instancias_finales
AS
BEGIN
	SET NOCOUNT ON
	TRUNCATE TABLE GRUPO_43.instancia_final;


	INSERT INTO GRUPO_43.instancia_final (
	instancia_final_id,
	instancia_final_curso,
	instancia_final_hora, 
	instancia_final_fecha, 
	instancia_final_descripcion
	)
	 SELECT DISTINCT
        RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY instancia_final_fecha) AS VARCHAR(8)), 8) AS instancia_final_id,
        Curso_Codigo,
		instancia_final_hora,
        instancia_final_fecha,
        instancia_final_descripcion
    FROM (
        SELECT DISTINCT
			Curso_Codigo,
            Examen_final_Hora AS instancia_final_hora,
            Examen_final_Fecha AS instancia_final_fecha,
            Examen_final_Descripcion AS instancia_final_descripcion
        FROM gd_esquema.Maestra
        WHERE 
			Curso_Codigo IS NOT NULL
			AND Examen_final_Fecha IS NOT NULL
			AND Examen_Final_Fecha IS NOT NULL
			AND Examen_Final_Descripcion IS NOT NULL
    ) AS instancia;
END 
GO

CREATE TABLE GRUPO_43.inscripcion_final(
	inscripcion_final_nro BIGINT CONSTRAINT PK_inscripcion_final PRIMARY KEY,
	inscripcion_final_fecha VARCHAR(255) NOT NULL,
	inscripcion_final_instancia CHAR(8),
	inscripcion_final_alumno_legajo BIGINT,
	FOREIGN KEY(inscripcion_final_instancia) REFERENCES GRUPO_43.instancia_final(instancia_final_id),
	FOREIGN KEY(inscripcion_final_alumno_legajo) REFERENCES GRUPO_43.alumno
);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.inscripciones_finales
AS 
BEGIN
	SET NOCOUNT ON
	TRUNCATE TABLE GRUPO_43.inscripcion_final;

	INSERT INTO GRUPO_43.inscripcion_final(
	inscripcion_final_nro,
	inscripcion_final_fecha, 
	inscripcion_final_instancia,
	inscripcion_final_alumno_legajo
	)
	SELECT DISTINCT
        inscripcion_final_nro,
        inscripcion_final_fecha,
        i.instancia_final_id inscripcion_final_instancia,
		inscripcion_final_alumno_legajo
    FROM (
        SELECT DISTINCT
            Inscripcion_Final_Nro AS inscripcion_final_nro,
            Inscripcion_Final_Fecha AS inscripcion_final_fecha, 
			Alumno_Legajo as inscripcion_final_alumno_legajo,
			Examen_Final_Descripcion, 
			Examen_Final_Fecha, 
			Examen_Final_Hora
        FROM gd_esquema.Maestra
        WHERE Inscripcion_Final_Nro IS NOT NULL
    ) gd
	LEFT JOIN GRUPO_43.instancia_final i 
	ON gd.Examen_Final_Descripcion = i.instancia_final_descripcion
	AND gd.Examen_Final_Fecha = i.instancia_final_fecha
	AND gd.Examen_Final_Hora = i.instancia_final_hora
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

	-- ACLARACIÓN: p.Curso_Codigo en realidad deberia salir de la tabla CURSOS, por el momento la implementacion cumple con su objetivo suponiendo que el codigo sera su PK
END;
GO

CREATE TABLE GRUPO_43.pago(
	pago_id CHAR(8) CONSTRAINT PK_pago PRIMARY KEY,
	pago_fact_id BIGINT NOT NULL,
	pago_fecha DATETIME2(6) NOT NULL,
	pago_importe DECIMAL(18,2) NOT NULL,
	pago_medio_de_pago VARCHAR(255),
	FOREIGN KEY(pago_fact_id) REFERENCES GRUPO_43.factura(fact_nro)
	);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.pagos
AS
BEGIN
	TRUNCATE TABLE GRUPO_43.pago;

	INSERT INTO GRUPO_43.pago(
		pago_id,
		pago_fact_id,
		pago_fecha,
		pago_importe,
		pago_medio_de_pago
	)
	SELECT DISTINCT
		RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY p.Pago_Fecha) AS VARCHAR(8)), 8) AS pago_id,
		p.Factura_Numero,
		p.Pago_Fecha,
		p.Pago_Importe,
		p.Pago_MedioPago
	FROM gd_esquema.Maestra p
	INNER JOIN GRUPO_43.factura f ON f.fact_nro = p.Factura_Numero
	WHERE p.Pago_Fecha IS NOT NULL
END;
GO

-- GESTION DE ENCUESTAS

CREATE TABLE GRUPO_43.encuesta(
    encuesta_curso_id CHAR(8) NOT NULL,
    encuesta_observaciones VARCHAR(255) NOT NULL,
    encuesta_fecha_registro DATETIME2(6) NOT NULL,
    FOREIGN KEY(encuesta_curso_id) REFERENCES GRUPO_43.curso(curso_codigo),
    CONSTRAINT PK_encuesta PRIMARY KEY (encuesta_curso_id,encuesta_fecha_registro)
);
GO 

CREATE OR ALTER PROCEDURE GRUPO_43.encuestas
AS
BEGIN
    TRUNCATE TABLE GRUPO_43.encuesta;

    INSERT INTO GRUPO_43.encuesta(
        encuesta_curso_id,
        encuesta_observaciones,
        encuesta_fecha_registro
    )
    SELECT DISTINCT
        p.Curso_Codigo,
        p.Encuesta_Observacion,
        p.Encuesta_FechaRegistro
    FROM gd_esquema.Maestra p
    INNER JOIN GRUPO_43.curso c ON c.curso_codigo = p.Curso_Codigo
    WHERE p.Encuesta_Observacion IS NOT NULL 
      AND p.Encuesta_FechaRegistro IS NOT NULL;
END;
GO

CREATE TABLE GRUPO_43.pregunta(
    pregunta_id CHAR(8) CONSTRAINT PK_pregunta PRIMARY KEY,
    pregunta_contenido VARCHAR(255) NOT NULL
);
GO

CREATE OR ALTER PROCEDURE GRUPO_43.preguntas
AS
BEGIN
    TRUNCATE TABLE GRUPO_43.pregunta;

    INSERT INTO GRUPO_43.pregunta(
        pregunta_id,
        pregunta_contenido
    )
    SELECT DISTINCT
        RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY CAST(REPLACE(REPLACE(p.pregunta, 'Pregunta N°:', ''), ' ', '') AS INT)) AS VARCHAR(8)), 8) AS pregunta_id,
        p.pregunta
    FROM (
        SELECT DISTINCT 
            Encuesta_Pregunta1 as pregunta
        FROM gd_esquema.Maestra
        WHERE Encuesta_Pregunta1 IS NOT NULL

        UNION

        SELECT DISTINCT
            Encuesta_Pregunta2 as pregunta
        FROM gd_esquema.Maestra
        WHERE Encuesta_Pregunta2 IS NOT NULL

        UNION

        SELECT DISTINCT
            Encuesta_Pregunta3 as pregunta
        FROM gd_esquema.Maestra
        WHERE Encuesta_Pregunta3 IS NOT NULL
        
        UNION
        
        SELECT DISTINCT
            Encuesta_Pregunta4 as pregunta
        FROM gd_esquema.Maestra
        WHERE Encuesta_Pregunta4 IS NOT NULL)p
    WHERE p.pregunta IS NOT NULL
END;
GO

CREATE TABLE GRUPO_43.detalle_encuesta(
    detalle_encuesta_id CHAR(8) NOT NULL,
    detalle_pregunta_id CHAR(8) NOT NULL,
    detalle_encuesta_curso_id CHAR(8) NOT NULL,
    detalle_encuesta_fecha_registro DATETIME2(6) NOT NULL,
    detalle_encuesta_nota BIGINT NOT NULL,
    CONSTRAINT FK_detalle_encuesta 
        FOREIGN KEY(detalle_encuesta_curso_id, detalle_encuesta_fecha_registro) 
        REFERENCES GRUPO_43.encuesta(encuesta_curso_id, encuesta_fecha_registro),
    CONSTRAINT FK_detalle_encuesta_pregunta
        FOREIGN KEY (detalle_pregunta_id)
        REFERENCES GRUPO_43.pregunta(pregunta_id),
    CONSTRAINT PK_detalle_encuesta 
        PRIMARY KEY (detalle_encuesta_id,detalle_encuesta_curso_id, detalle_encuesta_fecha_registro, detalle_pregunta_id)
);
GO


CREATE OR ALTER PROCEDURE GRUPO_43.detalle_encuestas
AS
BEGIN
    TRUNCATE TABLE GRUPO_43.detalle_encuesta;

    INSERT INTO GRUPO_43.detalle_encuesta(
        detalle_encuesta_id,
        detalle_pregunta_id,
        detalle_encuesta_curso_id,
        detalle_encuesta_fecha_registro,
        detalle_encuesta_nota
    )
    SELECT 
        RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY v.Curso_Codigo, v.Encuesta_FechaRegistro, v.pregunta) AS VARCHAR(8)), 8) AS detalle_encuesta_id,
        q.pregunta_id,
        v.Curso_Codigo,
        v.Encuesta_FechaRegistro,
        v.Encuesta_Nota
    FROM (
        SELECT 
            Curso_Codigo, Encuesta_FechaRegistro, Encuesta_Pregunta1 AS pregunta, Encuesta_Nota1 AS Encuesta_Nota
        FROM gd_esquema.Maestra
        WHERE Encuesta_Pregunta1 IS NOT NULL

        UNION ALL

        SELECT 
            Curso_Codigo, Encuesta_FechaRegistro, Encuesta_Pregunta2 AS pregunta, Encuesta_Nota2 AS Encuesta_Nota
        FROM gd_esquema.Maestra
        WHERE Encuesta_Pregunta2 IS NOT NULL

        UNION ALL

        SELECT 
            Curso_Codigo, Encuesta_FechaRegistro, Encuesta_Pregunta3 AS pregunta, Encuesta_Nota3 AS Encuesta_Nota
        FROM gd_esquema.Maestra
        WHERE Encuesta_Pregunta3 IS NOT NULL

        UNION ALL

        SELECT 
            Curso_Codigo, Encuesta_FechaRegistro, Encuesta_Pregunta4 AS pregunta, Encuesta_Nota4 AS Encuesta_Nota
        FROM gd_esquema.Maestra
        WHERE Encuesta_Pregunta4 IS NOT NULL
    ) AS v
    INNER JOIN GRUPO_43.pregunta q 
        ON q.pregunta_contenido = v.pregunta
    WHERE v.pregunta IS NOT NULL;
END;
GO

EXEC GRUPO_43.turnos;
GO

EXEC GRUPO_43.categorias;
GO

EXEC GRUPO_43.detalles_curso;
GO

EXEC GRUPO_43.cursos;
GO

EXEC GRUPO_43.inscripciones_curso;
GO

SELECT * 
FROM GRUPO_43.inscripcion_curso

EXEC GRUPO_43.detalle_modulos;
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


EXEC GRUPO_43.pagos;
GO

EXEC GRUPO_43.encuestas;
GO

EXEC GRUPO_43.preguntas;
GO

EXEC GRUPO_43.detalle_encuestas;
GO