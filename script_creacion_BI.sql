USE GD2C2025
GO
--	1) Drop vistas
DROP VIEW IF EXISTS GRUPO_43.bi_view_categorias_mas_solicitadas; 
DROP VIEW IF EXISTS  GRUPO_43.bi_view_turnos_mas_solicitados; 
DROP VIEW IF EXISTS  GRUPO_43.bi_tasa_rechazo_inscripciones;
DROP VIEW IF EXISTS  GRUPO_43.bi_desempeño_cursada_por_sede;
DROP VIEW IF EXISTS  GRUPO_43.bi_tiempo_promedio_finalizacion_curso;
DROP VIEW IF EXISTS  GRUPO_43.bi_nota_promedio_finales;
DROP VIEW IF EXISTS  GRUPO_43.bi_tasa_ausentismo_finales;
DROP VIEW IF EXISTS  GRUPO_43.bi_desvio_pagos;
DROP VIEW IF EXISTS  GRUPO_43.tasa_morosidad_financiera_mensual;
DROP VIEW IF EXISTS  GRUPO_43.ingresos_por_categoria_curso;
DROP VIEW IF EXISTS  GRUPO_43.indice_satisfaccion_anual;

--	2) Drop tablas de hechos
IF OBJECT_ID('GRUPO_43.bi_facto_inscripciones', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_facto_inscripciones;
IF OBJECT_ID('GRUPO_43.bi_facto_cursadas', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_facto_cursadas;
IF OBJECT_ID('GRUPO_43.bi_facto_finales', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_facto_finales;
IF OBJECT_ID('GRUPO_43.bi_facto_pagos', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_facto_pagos;
IF OBJECT_ID('GRUPO_43.bi_facto_satisfaccion', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_facto_satisfaccion;

--	3) Drop dimensiones
IF OBJECT_ID('GRUPO_43.bi_dim_tiempo', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_tiempo;
IF OBJECT_ID('GRUPO_43.bi_dim_alumno', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_alumno;
IF OBJECT_ID('GRUPO_43.bi_dim_sede', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_sede;
IF OBJECT_ID('GRUPO_43.bi_dim_profesor', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_profesor;
IF OBJECT_ID('GRUPO_43.bi_dim_curso', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_curso;
IF OBJECT_ID('GRUPO_43.bi_dim_medio_pago', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_medio_pago;
IF OBJECT_ID('GRUPO_43.bi_dim_turno', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_turno;
IF OBJECT_ID('GRUPO_43.bi_dim_rango_satisfaccion', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_rango_satisfaccion;


--	Creación de tablas de dimensiones
CREATE TABLE GRUPO_43.bi_dim_tiempo(
	id_dim_tiempo INT IDENTITY PRIMARY KEY, 
	anio INT NOT NULL 
		CHECK (anio BETWEEN 2000 AND 2025),
	cuatrimestre INT NOT NULL
		CHECK (cuatrimestre IN (1,2)),
	mes INT NOT NULL
		CHECK(mes BETWEEN 1 AND 12)
); 

CREATE TABLE GRUPO_43.bi_dim_sede(
	id_dim_sede INT IDENTITY PRIMARY KEY,
	nombre NVARCHAR(255) NOT NULL
); 


CREATE TABLE GRUPO_43.bi_dim_RE_alumno(
	id_dim_alumno INT IDENTITY PRIMARY KEY,
	rango_etario INT NOT NULL
		CHECK(rango_etario BETWEEN 0 AND 3)
); 

CREATE TABLE GRUPO_43.bi_dim_RE_profesor(
	id_dim_profesor INT IDENTITY PRIMARY KEY,
	rango_etario INT NOT NULL
		CHECK (rango_etario BETWEEN 0 AND 2)
);

CREATE TABLE GRUPO_43.bi_dim_curso_categoria(
    id_dim_curso_categoria INT IDENTITY PRIMARY KEY,
    categoria VARCHAR(255) NOT NULL
);

CREATE TABLE GRUPO_43.bi_dim_medio_pago(
	id_dim_medio_pago INT IDENTITY PRIMARY KEY,
	tipo_medio_pago VARCHAR(255) NOT NULL
); 

CREATE TABLE GRUPO_43.bi_dim_turno(
	id_dim_turno INT IDENTITY PRIMARY KEY, 
	turno char(8) NOT NULL
); 

CREATE TABLE GRUPO_43.bi_dim_rango_satisfaccion(
	id_dim_rango_satisfaccion INT IDENTITY PRIMARY KEY,
	rango_satisfaccion INT NOT NULL
		check(rango_satisfaccion BETWEEN 0 AND 2)
)

--	Creación de tablas de hechos
CREATE TABLE GRUPO_43.bi_facto_inscripciones(
	id_f_insc INT IDENTITY PRIMARY KEY,  
	id_dim_sede INT NOT NULL,
	id_dim_curso_categoria INT NOT NULL, 
	id_dim_turno INT NOT NULL, 
	estado_inscripcion BIT, 
	id_dim_tiempo_inscripcion INT NOT NULL,
	FOREIGN KEY(id_dim_tiempo_inscripcion) REFERENCES GRUPO_43.bi_dim_tiempo, 
	FOREIGN KEY(id_dim_sede) REFERENCES GRUPO_43.bi_dim_sede,
	FOREIGN KEY(id_dim_curso_categoria) REFERENCES GRUPO_43.bi_dim_curso_categoria,
	FOREIGN KEY(id_dim_turno) REFERENCES GRUPO_43.bi_dim_turno
); 

CREATE TABLE GRUPO_43.bi_facto_cursadas(
	id_f_cursada INT IDENTITY PRIMARY KEY, 
	id_dim_tiempo_inicio INT NOT NULL,
	id_dim_tiempo_finalizacion INT NOT NULL,
	id_dim_sede INT NOT NULL,
	id_dim_curso_categoria INT NOT NULL,
	estado_cursada BIT,
	FOREIGN KEY(id_dim_tiempo_inicio) REFERENCES GRUPO_43.bi_dim_tiempo,
	FOREIGN KEY(id_dim_tiempo_finalizacion) REFERENCES GRUPO_43.bi_dim_tiempo, 
	FOREIGN KEY(id_dim_sede) REFERENCES GRUPO_43.bi_dim_sede,
	FOREIGN KEY(id_dim_curso_categoria) REFERENCES GRUPO_43.bi_dim_curso_categoria,
); 

CREATE TABLE GRUPO_43.bi_facto_finales(
	id_f_final INT IDENTITY PRIMARY KEY,
	id_dim_tiempo INT NOT NULL,
	id_dim_sede INT NOT NULL,
	id_dim_curso_categoria INT NOT NULL,
	id_dim_RE_alumno INT NOT NULL,
	nota_final BIGINT,
	presencia_final BIT NOT NULL,
	FOREIGN KEY(id_dim_tiempo) REFERENCES GRUPO_43.bi_dim_tiempo, 
	FOREIGN KEY(id_dim_sede) REFERENCES GRUPO_43.bi_dim_sede,
	FOREIGN KEY(id_dim_curso_categoria) REFERENCES GRUPO_43.bi_dim_curso_categoria, 
	FOREIGN KEY(id_dim_RE_alumno) REFERENCES GRUPO_43.bi_dim_RE_alumno
); 

CREATE TABLE GRUPO_43.bi_facto_pagos(
	id_f_pago INT IDENTITY PRIMARY KEY,
	id_dim_tiempo INT NOT NULL,
	id_dim_tiempo_vencimiento INT NOT NULL,
	id_dim_tiempo_pago INT NOT NULL,
	id_dim_sede INT NOT NULL, 
	id_dim_medio_pago INT NOT NULL,
	id_dim_curso_categoria INT NOT NULL,
	monto_facturado decimal(8,2) NOT NULL,
	monto_pagado decimal(8,2) NOT NULL,
	estado_pago BIT, 
	FOREIGN KEY(id_dim_tiempo) REFERENCES GRUPO_43.bi_dim_tiempo,
	FOREIGN KEY(id_dim_sede) REFERENCES GRUPO_43.bi_dim_sede, 
	FOREIGN KEY(id_dim_medio_pago) REFERENCES GRUPO_43.bi_dim_medio_pago,
	FOREIGN KEY(id_dim_curso_categoria) REFERENCES GRUPO_43.bi_dim_curso_categoria,
	FOREIGN KEY(id_dim_tiempo_vencimiento) REFERENCES GRUPO_43.bi_dim_tiempo,
	FOREIGN KEY(id_dim_tiempo_pago) REFERENCES GRUPO_43.bi_dim_tiempo 
); 


CREATE TABLE GRUPO_43.bi_facto_satisfaccion(
	id_f_encuesta INT IDENTITY PRIMARY KEY,
	id_dim_tiempo INT NOT NULL, 
	id_dim_sede INT NOT NULL,
	id_dim_RE_profesor INT NOT NULL,
	id_dim_bloque_satisfaccion INT NOT NULL, 
	FOREIGN KEY(id_dim_tiempo) REFERENCES GRUPO_43.bi_dim_tiempo,
	FOREIGN KEY(id_dim_sede) REFERENCES GRUPO_43.bi_dim_sede, 
	FOREIGN KEY (id_dim_RE_profesor) REFERENCES GRUPO_43.bi_dim_RE_profesor,
	FOREIGN KEY (id_dim_bloque_satisfaccion) REFERENCES GRUPO_43.bi_dim_rango_satisfaccion
); 
GO

--	Procedures para dimensiones

CREATE OR ALTER PROCEDURE GRUPO_43.cargar_dimension_tiempo
AS
BEGIN
	SET NOCOUNT ON; 
	DELETE FROM GRUPO_43.bi_dim_tiempo; 

	DECLARE @fecha DATE = '2019-01-01'; 
	DECLARE @fechafin DATE = '2025-12-31'; 

	WHILE @fecha <= @fechafin
	BEGIN
		INSERT INTO GRUPO_43.bi_dim_tiempo(
			anio,
			cuatrimestre, 
			mes
		)
		VALUES(
			YEAR(@fecha),
			CASE WHEN MONTH(@fecha) <= 6 THEN 1 ELSE 2 END, 
			MONTH(@fecha)
		)

		SET @fecha = DATEADD(MONTH, 1, @fecha);
	END

END; 
GO

CREATE OR ALTER PROCEDURE GRUPO_43.cargar_dimension_sede 
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

CREATE OR ALTER PROCEDURE GRUPO_43.cargar_dimension_alumno
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM GRUPO_43.bi_dim_alumno;

	INSERT INTO GRUPO_43.bi_dim_alumno(
		edad, 
		rango_etario
	)
	SELECT
		DATEDIFF(YEAR, alumno_fecha_nacimiento, GETDATE()), 
		CASE
			WHEN DATEDIFF(YEAR, alumno_fecha_nacimiento, GETDATE()) BETWEEN 18 AND 25 THEN 0
			WHEN DATEDIFF(YEAR, alumno_fecha_nacimiento, GETDATE()) BETWEEN 26 AND 35 THEN 1 
			WHEN DATEDIFF(YEAR, alumno_fecha_nacimiento, GETDATE()) BETWEEN 36 AND 50 THEN 2
			ELSE 3
		END
	FROM GRUPO_43.alumno
END
GO

CREATE OR ALTER PROCEDURE GRUPO_43.cargar_dimension_profesor
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM GRUPO_43.bi_dim_profesor; 

	INSERT INTO GRUPO_43.bi_dim_profesor(
		edad, 
		rango_etario
	)
	SELECT 
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

CREATE OR ALTER PROCEDURE GRUPO_43.cargar_categorias
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM GRUPO_43.bi_dim_categoria;

	INSERT INTO GRUPO_43.bi_dim_categoria(
		nombre_categoria
	)
	SELECT DISTINCT 
		categoria_descripcion
	FROM GRUPO_43.categoria
END
GO

CREATE OR ALTER PROCEDURE GRUPO_43.cargar_dimension_curso 
AS
BEGIN
	SET NOCOUNT ON; 
	DELETE FROM GRUPO_43.bi_dim_curso; 

	INSERT INTO GRUPO_43.bi_dim_curso(
		curso_codigo, 
		id_dim_categoria
	)
	SELECT DISTINCT
		c.curso_codigo, 
		cat.id_dim_categoria
	FROM GRUPO_43.curso c
	JOIN GRUPO_43.detalle_curso dc ON c.curso_detalle_curso_id = dc.detalle_curso_id
	JOIN GRUPO_43.bi_dim_categoria cat ON cat.nombre_categoria = dc.detalle_curso_categoria
END
GO

CREATE OR ALTER PROCEDURE GRUPO_43.cargar_dimension_medio_pago
AS
BEGIN
	SET NOCOUNT ON; 
	DELETE FROM GRUPO_43.bi_dim_medio_pago; 

	INSERT INTO GRUPO_43.bi_dim_medio_pago(
		tipo_medio_pago
	)
	SELECT DISTINCT pago_medio_de_pago
	FROM GRUPO_43.pago
END;
GO

CREATE OR ALTER PROCEDURE GRUPO_43.cargar_dimension_turno
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
CREATE OR ALTER PROCEDURE GRUPO_43.cargar_facto_inscripciones
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
        CASE WHEN i.inscrip_curso_estado = 'Confirmada' THEN 1 ELSE 0 END
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

CREATE OR ALTER PROCEDURE GRUPO_43.cargar_facto_cursadas AS
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

    -- Nota TP
   JOIN GRUPO_43.bi_dim_tiempo t_ini 
        ON t_ini.fecha = TRY_CONVERT(date, c.curso_fecha_inicio)
    JOIN GRUPO_43.bi_dim_tiempo t_fin 
        ON t_fin.fecha = TRY_CONVERT(date, c.curso_fecha_fin)

    LEFT JOIN GRUPO_43.tp tp
        ON tp.tp_alumno_legajo = a.alumno_legajo
        AND tp.tp_curso_codigo = c.curso_codigo
        AND TRY_CONVERT(date, tp.tp_fecha_evaluacion)
            BETWEEN TRY_CONVERT(date, c.curso_fecha_inicio)
                AND TRY_CONVERT(date, c.curso_fecha_fin)


    -- Evaluaciones (nota mínima en rango de fechas)
   CROSS APPLY (
        SELECT MIN(e.evaluacion_nota) AS nota_minima
        FROM GRUPO_43.evaluacion e
        WHERE e.evaluacion_alumno_legajo = a.alumno_legajo
          AND e.evaluacion_curso_id = c.curso_codigo
          AND TRY_CONVERT(date, e.evaluacion_fecha)
                BETWEEN TRY_CONVERT(date, c.curso_fecha_inicio)
                    AND TRY_CONVERT(date, c.curso_fecha_fin)
    ) eval;
END;
GO

CREATE OR ALTER PROCEDURE GRUPO_43.cargar_facto_finales
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

CREATE OR ALTER PROCEDURE GRUPO_43.cargar_facto_pagos
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
	GROUP BY 
		tf.id_dim_tiempo,
        s.id_dim_sede,
        mp.id_dim_medio_pago,
        cu.id_dim_curso,
        tv.id_dim_tiempo,
        tp.id_dim_tiempo,
        f.fact_importe_total;

END
GO

CREATE OR ALTER PROCEDURE GRUPO_43.cargar_facto_satisfaccion
AS
BEGIN
	SET NOCOUNT ON; 
	DELETE FROM GRUPO_43.bi_facto_satisfaccion; 

	INSERT INTO GRUPO_43.bi_facto_satisfaccion(
		id_dim_tiempo, 
		id_dim_sede,
		id_dim_curso,
		id_dim_profesor,
		nota_respuesta,
		bloque_satisfaccion
	)
	SELECT
		t.id_dim_tiempo,
		s.id_dim_sede,
		cu.id_dim_curso,
		p.id_dim_profesor,
		de.detalle_encuesta_nota,
		CASE WHEN de.detalle_encuesta_nota < 5 THEN 0 
		WHEN de.detalle_encuesta_nota < 7 THEN 1
		ELSE 2
		END
	FROM GRUPO_43.encuesta e
	JOIN GRUPO_43.detalle_encuesta de 
		ON de.detalle_encuesta_curso_id = e.encuesta_curso_id 
		AND de.detalle_encuesta_fecha_registro = e.encuesta_fecha_registro
	JOIN GRUPO_43.curso c ON c.curso_codigo = e.encuesta_curso_id
	JOIN GRUPO_43.bi_dim_tiempo t ON t.fecha = de.detalle_encuesta_fecha_registro
	JOIN GRUPO_43.bi_dim_sede s ON s.sede_id = c.curso_sede_id
	JOIN GRUPO_43.bi_dim_curso cu ON cu.curso_codigo = c.curso_codigo
	JOIN GRUPO_43.bi_dim_profesor p ON p.profesor_id = c.curso_profesor_id
END
GO
--	EXEC de dimensiones
EXEC GRUPO_43.cargar_dimension_profesor;
EXEC GRUPO_43.cargar_dimension_sede;
EXEC GRUPO_43.cargar_dimension_alumno;
EXEC GRUPO_43.cargar_dimension_tiempo;
EXEC GRUPO_43.cargar_dimension_turno;
EXEC GRUPO_43.cargar_dimension_medio_pago;
EXEC GRUPO_43.cargar_categorias;
EXEC GRUPO_43.cargar_dimension_curso; 

--	EXEC de tablas de hechos
EXEC GRUPO_43.cargar_facto_satisfaccion;
EXEC GRUPO_43.cargar_facto_pagos;
EXEC GRUPO_43.cargar_facto_inscripciones;
EXEC GRUPO_43.cargar_facto_cursadas;
EXEC GRUPO_43.cargar_facto_finales;
GO


--	Creación de vistas
--	1) Categorías y turnos más solicitados
CREATE OR ALTER VIEW GRUPO_43.bi_view_categorias_mas_solicitadas
AS
SELECT TOP 3
	c.categoria CATEGORIA, 
	COUNT(CASE WHEN i.estado_inscripcion = 1 THEN 1 END) INSCRIPCIONES_ACEPTADAS
FROM GRUPO_43.bi_facto_inscripciones i
JOIN GRUPO_43.bi_dim_curso c ON c.id_dim_curso = i.id_dim_curso
GROUP BY c.categoria
ORDER BY inscripciones_aceptadas DESC
GO

CREATE OR ALTER VIEW GRUPO_43.bi_view_turnos_mas_solicitados
AS
SELECT TOP 3
	t.turno TURNO, 
	COUNT(CASE WHEN i.estado_inscripcion = 1 THEN 1 END) INSCRIPCIONES_ACEPTADAS
FROM GRUPO_43.bi_facto_inscripciones i
JOIN GRUPO_43.bi_dim_turno t ON t.id_dim_turno = i.id_dim_turno
GROUP BY t.turno
ORDER BY inscripciones_aceptadas DESC
GO

--	2) Tasa de rechazo de inscripciones
CREATE OR ALTER VIEW GRUPO_43.bi_tasa_rechazo_inscripciones
AS
SELECT 
	s.sede_id SEDE, 
	t.mes MES,
	CAST(COUNT(CASE WHEN i.estado_inscripcion = 0 THEN 1 END) AS FLOAT) 
	/ COUNT(*) * 100 TASA_DE_RECHAZO
FROM GRUPO_43.bi_facto_inscripciones i
JOIN GRUPO_43.bi_dim_tiempo t ON t.id_dim_tiempo = i.id_dim_tiempo_inscripcion
JOIN GRUPO_43.bi_dim_sede s ON s.id_dim_sede = i.id_dim_sede
GROUP BY s.sede_id, t.mes
GO

--	3) Comparación de desempeño de cursada por sede
CREATE OR ALTER VIEW GRUPO_43.bi_desempeño_cursada_por_sede
AS
SELECT
	s.sede_id SEDE,
	t.anio AÑO, 
	CAST(COUNT(CASE WHEN c.estado_cursada = 1 THEN 1 END) AS FLOAT) 
	/ COUNT(*) * 100  DESEMPEÑO
FROM GRUPO_43.bi_facto_cursadas c
JOIN GRUPO_43.bi_dim_sede s ON s.id_dim_sede = c.id_dim_sede
JOIN GRUPO_43.bi_dim_tiempo t ON t.id_dim_tiempo = c.id_dim_tiempo_inicio
GROUP BY s.sede_id, t.anio
GO

--	4) Tiempo promedio de finalización de curso
CREATE OR ALTER VIEW GRUPO_43.bi_tiempo_promedio_finalizacion_curso
AS
SELECT 
	c.categoria CATEGORIA,
	ti.anio ANIO_INICIO,
	AVG(DATEDIFF(DAY, ti.fecha, tf.fecha)) PROMEDIO_TIEMPO_FINALIZACION
FROM GRUPO_43.bi_facto_cursadas cu
JOIN GRUPO_43.bi_dim_tiempo ti ON ti.id_dim_tiempo = cu.id_dim_tiempo_inicio
JOIN GRUPO_43.bi_dim_curso c ON c.id_dim_curso = cu.id_dim_curso
JOIN GRUPO_43.bi_dim_alumno a ON a.id_dim_alumno = cu.id_dim_alumno
JOIN GRUPO_43.bi_facto_finales f 
	ON f.id_dim_curso = c.id_dim_curso
	AND f.id_dim_alumno = a.id_dim_alumno
JOIN GRUPO_43.bi_dim_tiempo tf ON tf.id_dim_tiempo = f.id_dim_tiempo
WHERE cu.estado_cursada = 1
GROUP BY c.categoria, ti.anio
GO

--	5) Nota promedio de finales
CREATE OR ALTER VIEW GRUPO_43.bi_nota_promedio_finales
AS
SELECT
	a.rango_etario RANGO_ETARIO,
	c.categoria,
	t.anio,
	t.semestre,
	AVG(CAST((f.nota_final) AS DECIMAL(10,2))) PROMEDIO_NOTA
FROM GRUPO_43.bi_facto_finales f
JOIN GRUPO_43.bi_dim_tiempo t ON f.id_dim_tiempo = t.id_dim_tiempo
JOIN GRUPO_43.bi_dim_alumno a ON a.id_dim_alumno = f.id_dim_alumno
JOIN GRUPO_43.bi_dim_curso c ON c.id_dim_curso = f.id_dim_curso
GROUP BY a.rango_etario, c.categoria, t.anio, t.semestre
GO

--	6) Tasa de ausentismo finales
CREATE OR ALTER VIEW GRUPO_43.bi_tasa_ausentismo_finales
AS
SELECT 
	t.anio AÑO,
	t.semestre SEMESTRE,
	s.sede_id SEDE,
	CAST(COUNT(CASE WHEN f.presencia_final = 0 THEN 1 END) AS FLOAT) 
	/ COUNT(*) * 100 AS TASA_AUSENTISMO
FROM GRUPO_43.bi_facto_finales f
JOIN GRUPO_43.bi_dim_tiempo t ON t.id_dim_tiempo = f.id_dim_tiempo
JOIN GRUPO_43.bi_dim_sede s ON s.id_dim_sede = f.id_dim_sede
GROUP BY t.anio, t.semestre, s.sede_id
GO

--	7) Desvío de pagos
CREATE OR ALTER VIEW GRUPO_43.bi_desvio_pagos
AS
SELECT
	tv.anio AÑO,
	tv.semestre SEMESTRE,
	CAST(COUNT(CASE WHEN tp.fecha > tv.fecha AND p.estado_pago = 1 THEN 1 END) AS FLOAT)
	/ NULLIF(CAST(COUNT (CASE WHEN p.estado_pago = 1 THEN 1 END) AS float), 0) * 100 AS TASA_DESVIOS
FROM GRUPO_43.bi_facto_pagos p
JOIN GRUPO_43.bi_dim_tiempo tv ON tv.id_dim_tiempo = p.id_dim_tiempo_vencimiento
JOIN GRUPO_43.bi_dim_tiempo tp ON tp.id_dim_tiempo = p.id_dim_tiempo_pago
GROUP BY tv.anio, tv.semestre
GO

--	8) Tasa de Morosidad Financiera mensual
CREATE OR ALTER VIEW GRUPO_43.tasa_morosidad_financiera_mensual
AS
SELECT
	t.anio ANIO,
	t.mes MES, 
	CAST(SUM(CASE WHEN p.estado_pago = 0 THEN p.monto_facturado END) AS float)
	/ NULLIF(SUM(p.monto_facturado), 0) * 100 AS TASA_MOROSIDAD
FROM GRUPO_43.bi_facto_pagos p
JOIN GRUPO_43.bi_dim_tiempo t ON t.id_dim_tiempo = p.id_dim_tiempo_vencimiento
GROUP BY t.anio, t.mes
GO

--	9) Ingresos por categoría de cursos

CREATE VIEW GRUPO_43.ingresos_por_categoria_curso
AS
WITH ingresos AS (
	SELECT
		s.sede_id SEDE, 
		t.anio AÑO, 
		c.categoria CATEGORIA,
		SUM(p.monto_pagado) INGRESOS
	FROM GRUPO_43.bi_facto_pagos p 
	JOIN GRUPO_43.bi_dim_sede s ON s.id_dim_sede = p.id_dim_sede
	JOIN GRUPO_43.bi_dim_tiempo t ON t.id_dim_tiempo = p.id_dim_tiempo_pago
	JOIN GRUPO_43.bi_dim_curso c ON c.id_dim_curso = p.id_dim_curso
	GROUP BY s.sede_id, t.anio, c.categoria
),
ranking AS (
	SELECT
		SEDE,
		AÑO,
		CATEGORIA,
		INGRESOS,
		ROW_NUMBER() OVER(
			PARTITION BY SEDE, AÑO
			ORDER BY INGRESOS DESC
		) AS RN
	FROM ingresos
)
SELECT
	SEDE, 
	AÑO, 
	CATEGORIA,
	INGRESOS
FROM ranking
WHERE RN <= 3;
GO

--	10) ?ndice de satisfacción
CREATE OR ALTER VIEW GRUPO_43.indice_satisfaccion_anual
AS
SELECT
	t.anio AÑO, 
	p.rango_etario RANGO_ETARIO,
	se.sede_id SEDE,
	(
		(
			(CAST(COUNT(CASE WHEN s.bloque_satisfaccion = 2 THEN 1 END) AS float) / COUNT(*)) 
			- 
			(CAST(COUNT(CASE WHEN s.bloque_satisfaccion = 0 THEN 1 END) AS float) / COUNT(*))
		) + 100
	) / 2 AS INDICE_SATISFACCION
FROM GRUPO_43.bi_facto_satisfaccion s
JOIN GRUPO_43.bi_dim_profesor p ON p.id_dim_profesor = s.id_dim_profesor
JOIN GRUPO_43.bi_dim_sede se ON se.id_dim_sede = s.id_dim_sede
JOIN GRUPO_43.bi_dim_tiempo t ON t.id_dim_tiempo = s.id_dim_tiempo
GROUP BY t.anio, p.rango_etario, se.sede_id
GO


SELECT *
FROM GRUPO_43.bi_view_categorias_mas_solicitadas

SELECT *
FROM GRUPO_43.bi_view_turnos_mas_solicitados

SELECT *
FROM GRUPO_43.bi_desempeño_cursada_por_sede

SELECT *
FROM GRUPO_43.bi_tiempo_promedio_finalizacion_curso

SELECT *
FROM GRUPO_43.bi_nota_promedio_finales

SELECT *
FROM GRUPO_43.bi_tasa_ausentismo_finales

SELECT *
FROM GRUPO_43.bi_desvio_pagos

SELECT *
FROM GRUPO_43.tasa_morosidad_financiera_mensual

SELECT *
FROM GRUPO_43.ingresos_por_categoria_curso

SELECT *

FROM GRUPO_43.indice_satisfaccion_anual
