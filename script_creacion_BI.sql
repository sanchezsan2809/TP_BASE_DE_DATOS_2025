USE GD2C2025
GO

IF OBJECT_ID('GRUPO_43.bi_dim_tiempo', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_tiempo;
IF OBJECT_ID('GRUPO_43.bi_dim_alumno', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_alumno;
IF OBJECT_ID('GRUPO_43.bi_dim_profesor', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_profesor;
IF OBJECT_ID('GRUPO_43.bi_dim_curso', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_curso;
IF OBJECT_ID('GRUPO_43.bi_dim_sede', 'U') IS NOT NULL DROP TABLE GRUPO_43.bi_dim_sede;
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
	cuatrimestre INT NOT NULL
		CHECK(cuatrimestre BETWEEN 1 AND 3),
	mes INT NOT NULL
		CHECK(mes BETWEEN 1 AND 12),
	dia INT NOT NULL
		CHECK (dia BETWEEN 1 AND 31),
	dia_semana INT NOT NULL
		CHECK (dia_semana BETWEEN 1 AND 7)
); 

CREATE TABLE GRUPO_43.bi_dim_alumno(
	id_dim_alumno INT IDENTITY PRIMARY KEY,
	alumno_legajo BIGINT NOT NULL, 
	nombre VARCHAR(255) NOT NULL, 
	apellido VARCHAR(255) NOT NULL,
	fecha_nacimiento smalldatetime NOT NULL,
	edad INT NOT NULL
		CHECK(edad >= 18), 
	rango_etario INT NOT NULL
		CHECK(rango_etario BETWEEN 0 AND 3),
	sede_actual char(8) NOT NULL
); 

CREATE TABLE GRUPO_43.bi_dim_profesor(
	id_dim_profesor INT IDENTITY PRIMARY KEY,
	profesor_id char(8) NOT NULL,
	nombre CHAR(255) NOT NULL,
	apellido CHAR(255) NOT NULL,
	fecha_nacimiento smalldatetime NOT NULL,
	edad INT NOT NULL
		CHECK (edad >= 18),
	rango_etario INT NOT NULL
		CHECK (rango_etario BETWEEN 0 AND 3)
);

CREATE TABLE GRUPO_43.bi_dim_curso(
	id_dim_curso INT IDENTITY PRIMARY KEY, 
	curso_codigo CHAR(8) NOT NULL, 
	categoria CHAR(8) NOT NULL,
	precio decimal(8,2) NOT NULL
); 

CREATE TABLE GRUPO_43.bi_dim_sede(
	id_dim_sede INT IDENTITY PRIMARY KEY, 
	sede_id CHAR(8) NOT NULL, 
	nombre NVARCHAR(255) NOT NULL
); 

CREATE TABLE GRUPO_43.bi_dim_medio_pago(
	id_dim_medio_pago INT IDENTITY PRIMARY KEY,
	tipo_medio_pago VARCHAR(255) NOT NULL
); 

CREATE TABLE GRUPO_43.bi_dim_turno(
	id_dim_turno INT IDENTITY PRIMARY KEY, 
	turno char(8) NOT NULL
); 

--	Creación de tablas de hechos
CREATE TABLE GRUPO_43.bi_facto_inscripciones(
	id_f_insc INT IDENTITY PRIMARY KEY, 
	id_dim_tiempo INT NOT NULL, 
	id_dim_sede INT NOT NULL,
	id_dim_curso INT NOT NULL, 
	id_dim_alumno INT NOT NULL, 
	id_dim_turno INT NOT NULL, 
	estado_inscripcion BIT, 
	id_dim_tiempo_inscripcion INT NOT NULL,
	FOREIGN KEY(id_dim_tiempo) REFERENCES GRUPO_43.bi_dim_tiempo, 
	FOREIGN KEY(id_dim_sede) REFERENCES GRUPO_43.bi_dim_sede,
	FOREIGN KEY(id_dim_curso) REFERENCES GRUPO_43.bi_dim_curso, 
	FOREIGN KEY(id_dim_alumno) REFERENCES GRUPO_43.bi_dim_alumno,
	FOREIGN KEY(id_dim_turno) REFERENCES GRUPO_43.bi_dim_alumno,
	FOREIGN KEY(id_dim_tiempo) REFERENCES GRUPO_43.bi_dim_tiempo, 
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
	nota_tp BIGINT,
	nota_modulo_1 BIGINT,
	nota_modulo_2 BIGINT, 
	nota_modulo_3 BIGINT, 
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
	estado_final BIT, 
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
	FOREIGN KEY(id_dim_tiempo_pago) REFERENCES GRUPO_43.bi_dim_tiempo, 
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


