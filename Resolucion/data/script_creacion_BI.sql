----------------------------------------------
-- CREACION DE LAS TABLAS DE DIMENSIONES
----------------------------------------------

-- Aca va la creacion de todas las tablas de dimensiones

--------------- Dim_Tiempo ---------------

CREATE TABLE ESE_CU_ELE.BI_Dim_Tiempo (
	tiempo_id BIGINT PRIMARY KEY IDENTITY(1,1),
	anio INT,
	mes TINYINT,
	cuatrimestre TINYINT
);

--------------- Dim_Rango_Etario_Cliente ---------------

CREATE TABLE ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente (
	rango_etario_cliente_id BIGINT PRIMARY KEY IDENTITY(1,1),
	rango_etario nvarchar(255),
	min_edad TINYINT,
	max_edad TINYINT
);

--------------- Dim_Rango_Etario_Agente ---------------

CREATE TABLE ESE_CU_ELE.BI_Dim_Rango_Etario_Agente (
	rango_etario_agente_id BIGINT PRIMARY KEY IDENTITY(1,1),
	rango_etario nvarchar(255),
	min_edad TINYINT,
	max_edad TINYINT
);

--------------- Dim_Temporada ---------------

CREATE TABLE ESE_CU_ELE.BI_Dim_Temporada (
	temporada_id BIGINT PRIMARY KEY IDENTITY(1,1),
	temporada nvarchar(255),
	mes_inicio TINYINT,
	mes_fin TINYINT
);

--------------- Dim_Tipo_Servicio ---------------

CREATE TABLE ESE_CU_ELE.BI_Dim_Tipo_Servicio (
	tipo_servicio_id BIGINT PRIMARY KEY IDENTITY(1,1),
	tipo_servicio nvarchar(255)
);

--------------- Dim_Canal_De_Venta ---------------

CREATE TABLE ESE_CU_ELE.BI_Dim_Canal_De_Venta (
	canal_de_venta_id BIGINT PRIMARY KEY IDENTITY(1,1),
	canal nvarchar(255)
);

--------------- Dim_Estado_De_Propuesta ---------------

CREATE TABLE ESE_CU_ELE.BI_Dim_Estado_De_Propuesta (
	estado_de_propuesta_id BIGINT PRIMARY KEY IDENTITY(1,1),
	estado nvarchar(255)
);

--------------- Dim_Puntaje ---------------

CREATE TABLE ESE_CU_ELE.BI_Dim_Puntaje (
	puntaje_id BIGINT PRIMARY KEY IDENTITY(1,1),
	puntaje INT
);

--------------- Dim_Aspecto ---------------

CREATE TABLE ESE_CU_ELE.BI_Dim_Aspecto (
	aspecto_id BIGINT PRIMARY KEY IDENTITY(1,1),
	aspecto nvarchar(255)
);


PRINT(N'Creadas las tablas de dimensiones');
GO



----------------------------------------------
-- CREACION DE LAS TABLAS DE HECHOS
----------------------------------------------

-- Aca va la creacion de todas las tablas de hechos


--------------- Hecho_Solicitud_De_Cotizacion ---------------

CREATE TABLE ESE_CU_ELE.BI_Hecho_Solicitud_De_Cotizacion (
	tiempo_id BIGINT, -- FK
	temporada_id BIGINT, -- FK
	rango_etario_cliente_id BIGINT, -- FK
	cantidad_solicitudes INT,
	suma_dias_anticipacion INT,

	FOREIGN KEY(tiempo_id) REFERENCES ESE_CU_ELE.BI_Dim_Tiempo(tiempo_id),
	FOREIGN KEY(temporada_id) REFERENCES ESE_CU_ELE.BI_Dim_Temporada(temporada_id),
	FOREIGN KEY(rango_etario_cliente_id) REFERENCES ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente(rango_etario_cliente_id)
);

--------------- Hecho_Encuesta ---------------

CREATE TABLE ESE_CU_ELE.BI_Hecho_Encuesta (
    tiempo_id BIGINT, -- FK
    rango_etario_agente_id BIGINT, -- FK
    puntaje_id BIGINT, -- FK
    aspecto_id BIGINT, -- FK
    cantidad_encuestas INT,
    suma_puntaje INT,

    FOREIGN KEY(tiempo_id) REFERENCES ESE_CU_ELE.BI_Dim_Tiempo(tiempo_id),
    FOREIGN KEY(rango_etario_agente_id) REFERENCES ESE_CU_ELE.BI_Dim_Rango_Etario_Agente(rango_etario_agente_id),
    FOREIGN KEY(puntaje_id) REFERENCES ESE_CU_ELE.BI_Dim_Puntaje(puntaje_id),
    FOREIGN KEY(aspecto_id) REFERENCES ESE_CU_ELE.BI_Dim_Aspecto(aspecto_id)
);







PRINT(N'Creadas las tablas de hechos');
GO



----------------------------------------------
-- MIGRACION A LAS TABLAS DE DIMENSIONES
----------------------------------------------

-- Aca va la migracion de las tablas del modelo transaccional a las tablas de dimensiones del modelo BI

CREATE PROCEDURE ESE_CU_ELE.BI_migracion_dimensiones
AS
BEGIN

--------------- Dim_Tiempo ---------------

INSERT INTO ESE_CU_ELE.BI_Dim_Tiempo (anio, mes, cuatrimestre)
SELECT DISTINCT
	YEAR(fechas.fecha) AS anio,
	MONTH(fechas.fecha) AS mes,
	CASE -- Cuatrimestre: Periodo de 4 meses
		WHEN MONTH(fecha) BETWEEN 1 AND 4 THEN 1
		WHEN MONTH(fecha) BETWEEN 5 AND 8 THEN 2
		ELSE 3
	END
FROM (
	SELECT fecha_emision AS fecha FROM ESE_CU_ELE.Propuesta
	UNION
	SELECT fecha_vigencia_hasta AS fecha FROM ESE_CU_ELE.Propuesta
	UNION
	SELECT fecha_desde AS fecha FROM ESE_CU_ELE.Propuesta
	UNION
	SELECT fecha_hasta AS fecha FROM ESE_CU_ELE.Propuesta
	UNION
	SELECT fecha_desde AS fecha FROM ESE_CU_ELE.Detalle_Propuesta_Hospedaje
	UNION
	SELECT fecha_hasta AS fecha FROM ESE_CU_ELE.Detalle_Propuesta_Hospedaje
	UNION
	SELECT fecha AS fecha FROM ESE_CU_ELE.Encuesta
	UNION
	SELECT fecha_solicitud AS fecha FROM ESE_CU_ELE.Solicitud_De_Cotizacion
	UNION
	SELECT fecha_inicio_tentativa AS fecha FROM ESE_CU_ELE.Solicitud_De_Cotizacion
	UNION
	SELECT fecha_fin_tentativa AS fecha FROM ESE_CU_ELE.Solicitud_De_Cotizacion
	UNION
	SELECT fecha AS fecha FROM ESE_CU_ELE.Venta
	UNION
	SELECT fecha_desde AS fecha FROM ESE_CU_ELE.Venta_Hospedaje
	UNION
	SELECT fecha_hasta AS fecha FROM ESE_CU_ELE.Venta_Hospedaje
	UNION
	SELECT fecha_reserva AS fecha FROM ESE_CU_ELE.Venta_Excursion
	-- No agergo las fechas de nacimiento del Cliente y Agente porque no son fechas propias del negocio.
) AS fechas


--------------- Dim_Temporada ---------------

INSERT INTO ESE_CU_ELE.BI_Dim_Temporada (temporada, mes_inicio, mes_fin)
VALUES 
	('Verano', 1, 3),
	('Otoño', 4, 6),
	('Invierno', 7, 9),
	('Primavera', 10, 12);


--------------- Dim_Rango_Etario_Cliente ---------------

INSERT INTO ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente (rango_etario, min_edad, max_edad)
VALUES
	('Menores de 25 años inclusive', 0, 25),
	('Entre 25 y 35 años inclusive', 26, 35),
	('Entre 35 y 50 años inclusive', 36, 50),
	('Mayores de 50 años', 51, 255);


--------------- Dim_Rango_Etario_Agente ---------------

INSERT INTO ESE_CU_ELE.BI_Dim_Rango_Etario_Agente (rango_etario, min_edad, max_edad)
VALUES
	('Entre 25 y 35 años inclusive', 26, 35),
	('Entre 35 y 50 años inclusive', 36, 50),
	('Mayores de 50 años', 51, 255);


--------------- Dim_Aspecto ---------------

INSERT INTO ESE_CU_ELE.BI_Dim_Aspecto (aspecto)
SELECT DISTINCT nombre
FROM ESE_CU_ELE.Aspecto
WHERE nombre IS NOT NULL;


--------------- Dim_Puntaje ---------------

INSERT INTO ESE_CU_ELE.BI_Dim_Puntaje (puntaje)
VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);

END; -- FIN PROCEDIMIENTO migracion de las dimensiones
GO


--------------- Ejecucion del procedimiento de dimensiones ---------------

BEGIN TRY
    BEGIN TRANSACTION
    EXECUTE ESE_CU_ELE.BI_migracion_dimensiones;
    PRINT(N'Migracion a las tablas de dimensiones hecha');
    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT(N'Se hizo un Rollback en la migracion de las tablas de dimensiones debido al siguiente error: ' + ERROR_MESSAGE());
END CATCH;
GO


----------------------------------------------
-- MIGRACION A LAS TABLAS DE HECHOS Y GENERACION DE METRICAS
----------------------------------------------

-- Aca va la migracion de las tablas del modelo transaccional a las tablas de dimensiones del modelo BI y la generacion de las metricas

CREATE PROCEDURE ESE_CU_ELE.BI_migracion_hechos
AS
BEGIN

--------------- Hecho_Solicitud_De_Cotizacion ---------------

INSERT INTO ESE_CU_ELE.BI_Hecho_Solicitud_De_Cotizacion (tiempo_id, temporada_id, rango_etario_cliente_id, cantidad_solicitudes, suma_dias_anticipacion)
SELECT
	Tiempo.tiempo_id,
	Temporada.temporada_id,
	Rango_etario_cliente.rango_etario_cliente_id,
	COUNT(Solicitud.nro_solicitud_id) AS cantidad_solicitudes,
	SUM(
		DATEDIFF(DAY, Solicitud.fecha_solicitud, Solicitud.fecha_inicio_tentativa)
	) AS suma_dias_anticipacion
FROM ESE_CU_ELE.Solicitud_De_Cotizacion AS Solicitud
-- Dim_Tiempo
INNER JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo ON (Tiempo.anio = YEAR(Solicitud.fecha_solicitud) AND Tiempo.mes = MONTH(Solicitud.fecha_solicitud))
-- Dim_Temporada
INNER JOIN ESE_CU_ELE.BI_Dim_Temporada Temporada ON MONTH(Solicitud.fecha_solicitud) BETWEEN Temporada.mes_inicio AND Temporada.mes_fin
-- Dim_Rango_Etario_Cliente
INNER JOIN ESE_CU_ELE.Cliente Cliente ON Cliente.cliente_id = Solicitud.cliente_id
INNER JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente Rango_Etario_Cliente ON 
	-- Calcular la edad que tenía el cliente cuando realizó la solicitud
	DATEDIFF(YEAR, Cliente.fecha_nacimiento, Solicitud.fecha_solicitud) -
		CASE
			WHEN DATEADD(YEAR, DATEDIFF(YEAR, Cliente.fecha_nacimiento, Solicitud.fecha_solicitud), Cliente.fecha_nacimiento) > Solicitud.fecha_solicitud
			THEN 1
			ELSE 0
		END
	BETWEEN Rango_Etario_Cliente.min_edad AND Rango_Etario_Cliente.max_edad
GROUP BY Tiempo.tiempo_id, Temporada.temporada_id, Rango_Etario_Cliente.rango_etario_cliente_id;

--------------- Hecho_Encuesta ---------------

INSERT INTO ESE_CU_ELE.BI_Hecho_Encuesta (
    tiempo_id, 
    rango_etario_agente_id, 
    puntaje_id, 
    aspecto_id, 
    cantidad_encuestas, 
    suma_puntaje
)
SELECT
    Tiempo.tiempo_id,
    Rango_Agente.rango_etario_agente_id,
    Puntaje.puntaje_id,
    Aspecto.aspecto_id,
    COUNT(Detalle.encuesta_id) AS cantidad_encuestas,
    SUM(Detalle.puntaje) AS suma_puntaje
FROM ESE_CU_ELE.Detalle_Encuesta_Puntaje AS Detalle
INNER JOIN ESE_CU_ELE.Encuesta Encuesta ON Encuesta.encuesta_id = Detalle.encuesta_id
INNER JOIN ESE_CU_ELE.Venta Venta ON Venta.venta_nro = Encuesta.venta_nro
INNER JOIN ESE_CU_ELE.Agente Agente ON Agente.agente_legajo = Venta.agente_legajo
INNER JOIN ESE_CU_ELE.Aspecto Trans_Aspecto ON Trans_Aspecto.aspecto_id = Detalle.aspecto_id
-- Dim_Tiempo
INNER JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo ON (Tiempo.anio = YEAR(Encuesta.fecha) AND Tiempo.mes = MONTH(Encuesta.fecha))
-- Dim_Aspecto
INNER JOIN ESE_CU_ELE.BI_Dim_Aspecto Aspecto ON Aspecto.aspecto = Trans_Aspecto.nombre
-- Dim_Puntaje
INNER JOIN ESE_CU_ELE.BI_Dim_Puntaje Puntaje ON Puntaje.puntaje = Detalle.puntaje
-- Dim_Rango_Etario_Agente
INNER JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Agente Rango_Agente ON 
    (DATEDIFF(YEAR, Agente.fecha_nacimiento, Encuesta.fecha) -
     CASE 
        WHEN DATEADD(YEAR, DATEDIFF(YEAR, Agente.fecha_nacimiento, Encuesta.fecha), Agente.fecha_nacimiento) > Encuesta.fecha 
        THEN 1 
        ELSE 0 
     END) BETWEEN Rango_Agente.min_edad AND Rango_Agente.max_edad
GROUP BY Tiempo.tiempo_id, Rango_Agente.rango_etario_agente_id, Puntaje.puntaje_id, Aspecto.aspecto_id;

END; -- FIN PROCEDIMIENTO migracion de los hechos
GO


--------------- Ejecucion del procedimiento de hechos ---------------

BEGIN TRY
    BEGIN TRANSACTION
    EXECUTE ESE_CU_ELE.BI_migracion_hechos;
    PRINT(N'Migracion a las tablas de hechos hecha');
    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT(N'Se hizo un Rollback en la migracion de las tablas de hechos debido al siguiente error: ' + ERROR_MESSAGE());
END CATCH;
GO



----------------------------------------------
-- CREACION DE LAS VISTAS
----------------------------------------------

-- Aca va la creacion de las vistas pedidas en el TP

--------------- 3. Ranking de solicitudes por temporadas ---------------
CREATE VIEW ESE_CU_ELE.BI_View_Ranking_De_Solicitudes_Por_Temporada
AS
SELECT
	Temporada.temporada,
	Tiempo.anio AS año,
	Rango_Etario_Cliente.rango_etario,
	SUM(Hecho_Solicitudes.cantidad_solicitudes) AS cantidad_solicitudes
FROM ESE_CU_ELE.BI_Hecho_Solicitud_De_Cotizacion AS Hecho_Solicitudes
JOIN ESE_CU_ELE.BI_Dim_Temporada Temporada ON Temporada.temporada_id = Hecho_Solicitudes.temporada_id
JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo ON Tiempo.tiempo_id = Hecho_Solicitudes.tiempo_id
JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente Rango_Etario_Cliente ON Rango_Etario_Cliente.rango_etario_cliente_id = Hecho_Solicitudes.rango_etario_cliente_id
GROUP BY Temporada.temporada, Tiempo.anio, Rango_Etario_Cliente.rango_etario;
GO


--------------- 4. Anticipación promedio de solicitudes ---------------
CREATE VIEW ESE_CU_ELE.BI_View_Anticipacion_Promedio_De_Solicitudes
AS
SELECT
	Rango_Etario_Cliente.rango_etario,
	Tiempo.cuatrimestre,
	CAST( SUM(suma_dias_anticipacion) * 1.0 / SUM(cantidad_solicitudes) AS DECIMAL(18,2) ) AS promedio_dias_de_anticipacion
FROM ESE_CU_ELE.BI_Hecho_Solicitud_De_Cotizacion AS Hecho_Solicitudes
JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente Rango_Etario_Cliente ON Rango_Etario_Cliente.rango_etario_cliente_id = Hecho_Solicitudes.rango_etario_cliente_id
JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo ON Tiempo.tiempo_id = Hecho_Solicitudes.tiempo_id
GROUP BY Rango_Etario_Cliente.rango_etario, Tiempo.cuatrimestre
GO

--------------- 9. Promedio mensual de puntaje por aspecto de la encuesta ---------------

CREATE VIEW ESE_CU_ELE.BI_View_Promedio_Mensual_Puntaje_Por_Aspecto
AS
SELECT
    Tiempo.anio AS año,
    Tiempo.mes,
    Aspecto.aspecto,
    CAST(SUM(Hecho.suma_puntaje) * 1.0 / SUM(Hecho.cantidad_encuestas) AS DECIMAL(18,2)) AS promedio_puntaje
FROM ESE_CU_ELE.BI_Hecho_Encuesta AS Hecho
JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo ON Tiempo.tiempo_id = Hecho.tiempo_id
JOIN ESE_CU_ELE.BI_Dim_Aspecto Aspecto ON Aspecto.aspecto_id = Hecho.aspecto_id
GROUP BY Tiempo.anio, Tiempo.mes, Aspecto.aspecto;
GO


--------------- 10. Promedio de satisfacción por rango etario del agente ---------------

CREATE VIEW ESE_CU_ELE.BI_View_Promedio_Satisfaccion_Por_Rango_Etario_Agente
AS
SELECT
    Rango_Agente.rango_etario AS rango_etario_agente,
    CAST(SUM(Hecho.suma_puntaje) * 1.0 / SUM(Hecho.cantidad_encuestas) AS DECIMAL(18,2)) AS promedio_satisfaccion
FROM ESE_CU_ELE.BI_Hecho_Encuesta AS Hecho
JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Agente Rango_Agente ON Rango_Agente.rango_etario_agente_id = Hecho.rango_etario_agente_id
GROUP BY Rango_Agente.rango_etario;
GO


PRINT(N'Vistas creadas')