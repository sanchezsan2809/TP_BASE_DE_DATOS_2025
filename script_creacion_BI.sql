USE GD2C2025
GO

IF OBJECT_ID('GRUPO_43.bi_dim_tiempo', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_tiempo;
IF OBJECT_ID('GRUPO_43.bi_dim_sede', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_sede;
IF OBJECT_ID('GRUPO_43.bi_dim_alumno', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_alumno;
IF OBJECT_ID('GRUPO_43.bi_dim_profesor', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_profesor;
IF OBJECT_ID('GRUPO_43.bi_dim_curso', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_curso;
IF OBJECT_ID('GRUPO_43.bi_dim_medio_pago', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_medio_pago;
IF OBJECT_ID('GRUPO_43.bi_dim_turno', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_turno;

IF OBJECT_ID('GRUPO_43.bi_facto_inscripciones', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_facto_inscripciones;
IF OBJECT_ID('GRUPO_43.bi_facto_cursadas', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_facto_cursadas;
IF OBJECT_ID('GRUPO_43.bi_facto_finales', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_facto_finales;
IF OBJECT_ID('GRUPO_43.bi_facto_pagos', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_facto_pagos;
IF OBJECT_ID('GRUPO_43.bi_facto_satisfaccion', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_facto_satisfaccion;

--	Creación de tablas de dimensiones
CREATE TABLE GRUPO_43.bi_dim_tiempo(
	id_dim_tiempo INT IDENTITY PRIMARY KEY,
	fecha smalldatetime NOT NULL, 
	anio INT NOT NULL 
		CHECK (anio BETWEEN 2000 AND 2025),
	semestre INT NOT NULL
		CHECK (semestre IN (1,2)),
	mes INT NOT NULL
		CHECK(mes BETWEEN 1 AND 12),
	dia INT NOT NULL
		CHECK (dia BETWEEN 1 AND 31)
); 

CREATE TABLE GRUPO_43.bi_dim_sede(
	id_dim_sede INT IDENTITY PRIMARY KEY, 
	sede_id CHAR(8) NOT NULL, 
	nombre NVARCHAR(255) NOT NULL
); 


CREATE TABLE GRUPO_43.bi_dim_alumno(
	id_dim_alumno INT IDENTITY PRIMARY KEY,
	alumno_legajo BIGINT NOT NULL, 
	nombre VARCHAR(255) NOT NULL, 
	apellido VARCHAR(255) NOT NULL,
	edad INT NOT NULL
		CHECK(edad >= 18), 
	rango_etario INT NOT NULL
		CHECK(rango_etario BETWEEN 0 AND 3),
	id_dim_sede_actual INT NOT NULL,
	FOREIGN KEY(id_dim_sede_actual) REFERENCES GRUPO_43.bi_dim_sede
); 

CREATE TABLE GRUPO_43.bi_dim_profesor(
	id_dim_profesor INT IDENTITY PRIMARY KEY,
	profesor_id char(8) NOT NULL,
	nombre varchar(255) NOT NULL,
	apellido varchar(255) NOT NULL,
	edad INT NOT NULL
		CHECK (edad >= 18),
	rango_etario INT NOT NULL
		CHECK (rango_etario BETWEEN 0 AND 3)
);

CREATE TABLE GRUPO_43.bi_dim_curso(
	id_dim_curso INT IDENTITY PRIMARY KEY, 
	curso_codigo CHAR(8) NOT NULL, 
	categoria CHAR(8) NOT NULL,
); 


CREATE TABLE GRUPO_43.bi_dim_medio_pago(
	id_dim_medio_pago INT IDENTITY PRIMARY KEY,
	tipo_medio_pago VARCHAR(255) NOT NULL
); 

CREATE TABLE GRUPO_43.bi_dim_turno(
	id_dim_turno INT IDENTITY PRIMARY KEY, 
	turno nvarchar(255) NOT NULL
); 

--	Creación de tablas de hechos
CREATE TABLE GRUPO_43.bi_facto_inscripciones(
	id_f_insc INT IDENTITY PRIMARY KEY,  
	id_dim_sede INT NOT NULL,
	id_dim_curso INT NOT NULL, 
	id_dim_alumno INT NOT NULL, 
	id_dim_turno INT NOT NULL, 
	estado_inscripcion BIT, 
	id_dim_tiempo_inscripcion INT NOT NULL,
	FOREIGN KEY(id_dim_tiempo_inscripcion) REFERENCES GRUPO_43.bi_dim_tiempo, 
	FOREIGN KEY(id_dim_sede) REFERENCES GRUPO_43.bi_dim_sede,
	FOREIGN KEY(id_dim_curso) REFERENCES GRUPO_43.bi_dim_curso, 
	FOREIGN KEY(id_dim_alumno) REFERENCES GRUPO_43.bi_dim_alumno,
	FOREIGN KEY(id_dim_turno) REFERENCES GRUPO_43.bi_dim_turno
); 

CREATE TABLE GRUPO_43.bi_facto_cursadas(
	id_f_cursada INT IDENTITY PRIMARY KEY, 
	id_dim_tiempo_inicio INT NOT NULL,
	id_dim_tiempo_finalizacion INT NOT NULL,
	id_dim_sede INT NOT NULL,
	id_dim_curso INT NOT NULL,
	id_dim_alumno INT NOT NULL, 
	id_dim_profesor INT NOT NULL, 
	estado_cursada BIT,
	FOREIGN KEY(id_dim_tiempo_inicio) REFERENCES GRUPO_43.bi_dim_tiempo,
	FOREIGN KEY(id_dim_tiempo_finalizacion) REFERENCES GRUPO_43.bi_dim_tiempo, 
	FOREIGN KEY(id_dim_sede) REFERENCES GRUPO_43.bi_dim_sede,
	FOREIGN KEY(id_dim_curso) REFERENCES GRUPO_43.bi_dim_curso,
	FOREIGN KEY(id_dim_alumno) REFERENCES GRUPO_43.bi_dim_alumno, 
	FOREIGN KEY(id_dim_profesor) REFERENCES GRUPO_43.bi_dim_profesor
); 

CREATE TABLE GRUPO_43.bi_facto_finales(
	id_f_final INT IDENTITY PRIMARY KEY,
	id_dim_tiempo INT NOT NULL,
	id_dim_sede INT NOT NULL,
	id_dim_curso INT NOT NULL,
	id_dim_alumno INT NOT NULL,
	nota_final BIGINT,
	presencia_final BIT NOT NULL,
	FOREIGN KEY(id_dim_tiempo) REFERENCES GRUPO_43.bi_dim_tiempo, 
	FOREIGN KEY(id_dim_sede) REFERENCES GRUPO_43.bi_dim_sede,
	FOREIGN KEY(id_dim_curso) REFERENCES GRUPO_43.bi_dim_curso, 
	FOREIGN KEY(id_dim_alumno) REFERENCES GRUPO_43.bi_dim_alumno
); 

CREATE TABLE GRUPO_43.bi_facto_pagos(
	id_f_pago INT IDENTITY PRIMARY KEY,
	id_dim_tiempo INT NOT NULL, 
	id_dim_sede INT NOT NULL, 
	id_dim_medio_pago INT NOT NULL,
	id_dim_curso INT NOT NULL,
	id_dim_tiempo_vencimiento INT NOT NULL,
	id_dim_tiempo_pago INT NOT NULL,
	monto_facturado decimal(8,2) NOT NULL,
	monto_pagado decimal(8,2) NOT NULL,
	estado_pago BIT, 
	FOREIGN KEY(id_dim_tiempo) REFERENCES GRUPO_43.bi_dim_tiempo,
	FOREIGN KEY(id_dim_sede) REFERENCES GRUPO_43.bi_dim_sede, 
	FOREIGN KEY(id_dim_medio_pago) REFERENCES GRUPO_43.bi_dim_medio_pago,
	FOREIGN KEY(id_dim_curso) REFERENCES GRUPO_43.bi_dim_curso,
	FOREIGN KEY(id_dim_tiempo_vencimiento) REFERENCES GRUPO_43.bi_dim_tiempo,
	FOREIGN KEY(id_dim_tiempo_pago) REFERENCES GRUPO_43.bi_dim_tiempo 
); 

CREATE TABLE GRUPO_43.bi_facto_satisfaccion(
	id_f_encuesta INT IDENTITY PRIMARY KEY,
	id_dim_tiempo INT NOT NULL, 
	id_dim_sede INT NOT NULL,
	id_dim_curso INT NOT NULL, 
	id_dim_profesor INT NOT NULL,
	id_dim_alumno INT NOT NULL, 
	nota_respuesta BIGINT NOT NULL,
	bloque_satisfaccion INT NOT NULL
		CHECK(bloque_satisfaccion BETWEEN 0 AND 2), 
	FOREIGN KEY(id_dim_tiempo) REFERENCES GRUPO_43.bi_dim_tiempo,
	FOREIGN KEY(id_dim_sede) REFERENCES GRUPO_43.bi_dim_sede, 
	FOREIGN KEY(id_dim_curso) REFERENCES GRUPO_43.bi_dim_curso,
	FOREIGN KEY (id_dim_profesor) REFERENCES GRUPO_43.bi_dim_profesor,
	FOREIGN KEY (id_dim_alumno) REFERENCES GRUPO_43.bi_dim_alumno
); 
GO

--	Procedures para dimensiones

CREATE OR ALTER PROCEDURE GRUPO_43.bi_dim_tiempo
AS
BEGIN
	SET NOCOUNT ON; 
	DELETE FROM GRUPO_43.bi_dim_tiempo; 

	DECLARE @fecha DATE = '2019-01-01'; 
	DECLARE @fechafin DATE = '2025-12-31'; 

	WHILE @fecha <= @fechafin
	BEGIN
		INSERT INTO GRUPO_43.bi_dim_tiempo(
			fecha,
			anio,
			semestre, 
			mes, 
			dia
		)
		VALUES(
			@fecha, 
			YEAR(@fecha),
			CASE WHEN MONTH(@fecha) <= 6 THEN 1 ELSE 2 END, 
			MONTH(@fecha), 
			DAY(@fecha)
		)

		SET @fecha = DATEADD(DAY, 1, @fecha);
	END

END; 
GO

CREATE OR ALTER PROCEDURE GRUPO_43.bi_dim_sede 
AS
BEGIN
	SET NOCOUNT ON; 
	DELETE FROM GRUPO_43.bi_dim_sede; 

	INSERT INTO GRUPO_43.bi_dim_sede(
		sede_id, 
		nombre
	)
	SELECT
		sede_id,
		sede_nombre
	FROM GRUPO_43.sede
END
GO

CREATE OR ALTER PROCEDURE GRUPO_43.bi_dim_alumno
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM GRUPO_43.bi_dim_alumno;

	INSERT INTO GRUPO_43.bi_dim_alumno(
		alumno_legajo, 
		nombre, 
		apellido, 
		edad, 
		rango_etario, 
		id_dim_sede_actual
	)
	SELECT 
		alumno_legajo, 
		alumno_nombre, 
		alumno_apellido, 
		DATEDIFF(YEAR, alumno_fecha_nacimiento, GETDATE()), 
		CASE
			WHEN DATEDIFF(YEAR, alumno_fecha_nacimiento, GETDATE()) BETWEEN 18 AND 25 THEN 0
			WHEN DATEDIFF(YEAR, alumno_fecha_nacimiento, GETDATE()) BETWEEN 26 AND 35 THEN 1 
			WHEN DATEDIFF(YEAR, alumno_fecha_nacimiento, GETDATE()) BETWEEN 36 AND 50 THEN 2
			ELSE 3
		END,
		ISNULL(curso_sede_id, 'NO ASIGNADO')
	FROM GRUPO_43.alumno
	LEFT JOIN GRUPO_43.inscripcion_curso ON alumno_legajo = inscrip_curso_alumno_legajo
	LEFT JOIN  GRUPO_43.curso ON inscrip_curso_codigo = curso_codigo
	LEFT JOIN GRUPO_43.bi_dim_sede ON curso_sede_id = sede_id
END
GO

CREATE OR ALTER PROCEDURE GRUPO_43.bi_dim_profesor
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM GRUPO_43.bi_dim_profesor; 

	INSERT INTO GRUPO_43.bi_dim_profesor(
		profesor_id, 
		nombre, 
		apellido, 
		edad, 
		rango_etario
	)
	SELECT 
		profesor_id, 
		profesor_nombre, 
		profesor_apellido,
		DATEDIFF(YEAR, profesor_fecha_nacimiento, GETDATE()), 
		CASE
			WHEN DATEDIFF(YEAR, profesor_fecha_nacimiento, GETDATE()) BETWEEN 18 AND 25 THEN 0
			WHEN DATEDIFF(YEAR, profesor_fecha_nacimiento, GETDATE()) BETWEEN 26 AND 35 THEN 1 
			WHEN DATEDIFF(YEAR, profesor_fecha_nacimiento, GETDATE()) BETWEEN 36 AND 50 THEN 2
			ELSE 3
		END
	FROM GRUPO_43.profesor
END
GO

CREATE OR ALTER PROCEDURE GRUPO_43.bi_dim_curso 
AS
BEGIN
	SET NOCOUNT ON; 
	DELETE FROM GRUPO_43.bi_dim_curso; 

	INSERT INTO GRUPO_43.bi_dim_curso(
		curso_codigo, 
		categoria
	)
	SELECT DISTINCT
		curso_codigo, 
		detalle_curso_categoria
	FROM GRUPO_43.curso
	JOIN GRUPO_43.detalle_curso ON curso_detalle_curso_id = detalle_curso_id
END
GO

CREATE OR ALTER PROCEDURE GRUPO_43.bi_dim_medio_pago
AS
BEGIN
	SET NOCOUNT ON; 
	DELETE FROM GRUPO_43.bi_dim_medio_pago; 

	INSERT INTO GRUPO_43.bi_dim_medio_pago(
		tipo_medio_pago
	)
	SELECT DISTINCT pago_medio_de_pago
	FROM GRUPO_43.pago
END
GO; 

CREATE OR ALTER PROCEDURE GRUPO_43.bi_dim_turno
AS
BEGIN
	SET NOCOUNT ON; 
	DELETE FROM GRUPO_43.bi_dim_turno; 

	INSERT INTO GRUPO_43.bi_dim_turno(
		turno
	)
	SELECT DISTINCT ISNULL(turno_descripcion, 'No especificado')
	FROM GRUPO_43.turno
END
GO

--	Procedures para hechos
CREATE OR ALTER PROCEDURE GRUPO_43.bi_facto_inscripciones
AS
BEGIN
    SET NOCOUNT ON; 
    DELETE FROM GRUPO_43.bi_facto_inscripciones; 

    INSERT INTO GRUPO_43.bi_facto_inscripciones(
        id_dim_tiempo_inscripcion, 
        id_dim_sede, 
        id_dim_curso, 
        id_dim_alumno, 
        id_dim_turno, 
        estado_inscripcion
    )
    SELECT
        t.id_dim_tiempo,
        s.id_dim_sede, 
        c.id_dim_curso,
        a.id_dim_alumno, 
        tu.id_dim_turno,
        i.inscrip_curso_estado
    FROM GRUPO_43.inscripcion_curso i
    JOIN GRUPO_43.bi_dim_tiempo t 
        ON t.fecha = i.inscrip_curso_fecha
    JOIN GRUPO_43.curso co 
        ON co.curso_codigo = i.inscrip_curso_codigo
    JOIN GRUPO_43.bi_dim_sede s 
        ON s.sede_id = co.curso_sede_id
    JOIN GRUPO_43.bi_dim_curso c 
        ON c.curso_codigo = co.curso_codigo
    JOIN GRUPO_43.bi_dim_alumno a 
        ON a.alumno_legajo = i.inscrip_curso_alumno_legajo
    JOIN GRUPO_43.turno t2
        ON t2.turno_id = co.curso_turno_id
    JOIN GRUPO_43.bi_dim_turno tu
        ON tu.turno = t2.turno_descripcion;
END
GO

CREATE OR ALTER PROCEDURE GRUPO_43.bi_facto_cursadas AS
BEGIN
    SET NOCOUNT ON; 
    DELETE FROM GRUPO_43.bi_facto_cursadas; 

    INSERT INTO GRUPO_43.bi_facto_cursadas(
        id_dim_tiempo_inicio, 
        id_dim_tiempo_finalizacion, 
        id_dim_sede, 
        id_dim_curso, 
        id_dim_alumno, 
        id_dim_profesor, 
        estado_cursada
    )
    SELECT
        t_ini.id_dim_tiempo, 
        t_fin.id_dim_tiempo, 
        sdim.id_dim_sede, 
        cdim.id_dim_curso,
        adim.id_dim_alumno, 
        prodim.id_dim_profesor,
        CASE 
            WHEN ISNULL(tp.tp_nota,0) >= 4 
                 AND ISNULL(eval.nota_minima,0) >= 4 
            THEN 1 ELSE 0
        END AS estado_cursada
    FROM GRUPO_43.inscripcion_curso ic 
    JOIN GRUPO_43.curso c 
        ON c.curso_codigo = ic.inscrip_curso_codigo
    JOIN GRUPO_43.alumno a 
        ON a.alumno_legajo = ic.inscrip_curso_alumno_legajo
    
    -- Dimensiones
    JOIN GRUPO_43.bi_dim_alumno adim 
        ON adim.alumno_legajo = a.alumno_legajo
    JOIN GRUPO_43.bi_dim_curso cdim 
        ON cdim.curso_codigo = c.curso_codigo
    JOIN GRUPO_43.bi_dim_profesor prodim 
        ON prodim.profesor_id = c.curso_profesor_id
    JOIN GRUPO_43.bi_dim_sede sdim 
        ON sdim.sede_id = c.curso_sede_id
    JOIN GRUPO_43.bi_dim_tiempo t_ini 
        ON t_ini.fecha = c.curso_fecha_inicio
    JOIN GRUPO_43.bi_dim_tiempo t_fin 
        ON t_fin.fecha = c.curso_fecha_fin

    -- Nota TP
    LEFT JOIN GRUPO_43.tp tp
        ON tp.tp_alumno_legajo = a.alumno_legajo
        AND tp.tp_curso_codigo = c.curso_codigo
        AND tp.tp_fecha_evaluacion BETWEEN c.curso_fecha_inicio AND c.curso_fecha_fin

    -- Evaluaciones (nota mínima en rango de fechas)
    CROSS APPLY (
        SELECT MIN(e.evaluacion_nota) AS nota_minima
        FROM GRUPO_43.evaluacion e
        WHERE e.evaluacion_alumno_legajo = a.alumno_legajo
          AND e.evaluacion_curso_id = c.curso_codigo
          AND e.evaluacion_fecha BETWEEN c.curso_fecha_inicio AND c.curso_fecha_fin
    ) eval;
END;
GO

CREATE OR ALTER PROCEDURE bi_facto_finales
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM GRUPO_43.bi_facto_finales; 

	INSERT INTO GRUPO_43.bi_facto_finales(
		id_dim_tiempo,
		id_dim_sede, 
		id_dim_curso, 
		id_dim_alumno, 
		nota_final, 
		presencia_final
	)
	SELECT
		t.id_dim_tiempo,
		s.id_dim_sede,
		cu.id_dim_curso,
		a.id_dim_alumno,
		f.final_nota,
		f.final_presente
	FROM GRUPO_43.evaluacion_final f
	JOIN GRUPO_43.instancia_final ins_f ON ins_f.instancia_final_id = f.final_instancia_final
	JOIN GRUPO_43.curso c ON ins_f.instancia_final_curso = c.curso_codigo
	JOIN GRUPO_43.bi_dim_tiempo t ON t.fecha = ins_f.instancia_final_fecha
	JOIN GRUPO_43.bi_dim_sede s ON s.sede_id = c.curso_sede_id
	JOIN GRUPO_43.bi_dim_curso cu ON cu.curso_codigo = c.curso_codigo
	JOIN GRUPO_43.bi_dim_alumno a ON a.alumno_legajo = f.final_alumno_legajo
END
GO 

CREATE OR ALTER PROCEDURE GRUPO_43.bi_facto_pagos
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM GRUPO_43.bi_facto_pagos; 

	INSERT INTO GRUPO_43.bi_facto_pagos(
		id_dim_tiempo,
		id_dim_sede,
		id_dim_medio_pago,
		id_dim_curso,
		id_dim_tiempo_vencimiento,
		id_dim_tiempo_pago,
		monto_facturado,
		monto_pagado,
		estado_pago
	)
	SELECT 
		tf.id_dim_tiempo,
		s.id_dim_sede,
		mp.id_dim_medio_pago,
		cu.id_dim_curso,
		tv.id_dim_tiempo,
		tp.id_dim_tiempo,
		f.fact_importe_total,
		SUM(p.pago_importe),
		CASE WHEN SUM(p.pago_importe) = f.fact_importe_total THEN 1 ELSE 0 END 
	FROM GRUPO_43.pago p
	JOIN GRUPO_43.factura f ON f.fact_nro = p.pago_fact_id 
	JOIN GRUPO_43.detalle_factura df ON df.detalle_factura_fact_id = f.fact_nro
	JOIN GRUPO_43.curso c ON c.curso_codigo = df.detalle_factura_curso_id 
	JOIN GRUPO_43.bi_dim_tiempo tf ON tf.fecha = f.fact_fecha_emision
	JOIN GRUPO_43.bi_dim_sede s ON s.sede_id = c.curso_sede_id
	JOIN GRUPO_43.bi_dim_medio_pago mp ON mp.tipo_medio_pago = p.pago_medio_de_pago
	JOIN GRUPO_43.bi_dim_curso cu ON cu.curso_codigo = c.curso_codigo
	JOIN GRUPO_43.bi_dim_tiempo tv ON tv.fecha = f.fact_fecha_venc
	JOIN GRUPO_43.bi_dim_tiempo tp ON tp.fecha = (
		SELECT MAX(p2.pago_fecha)
		FROM GRUPO_43.pago p2
		WHERE p2.pago_fact_id = f.fact_nro)
	GROUP BY f.fact_nro

END
GO