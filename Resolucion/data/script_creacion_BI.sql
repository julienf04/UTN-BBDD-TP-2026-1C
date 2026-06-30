----------------------------------------------
-- CREACION DE LAS TABLAS DE DIMENSIONES
----------------------------------------------

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

--------------- Hecho_Venta ---------------

CREATE TABLE ESE_CU_ELE.BI_Hecho_Venta (
    tiempo_id BIGINT, -- FK
    rango_etario_cliente_id BIGINT, -- FK
    canal_de_venta_id BIGINT, -- FK
    tipo_de_servicio_id BIGINT, -- FK
    cantidad_ventas INT,
    suma_importe_total DECIMAL(18,2),

    FOREIGN KEY(tiempo_id) REFERENCES ESE_CU_ELE.BI_Dim_Tiempo(tiempo_id),
    FOREIGN KEY(rango_etario_cliente_id) REFERENCES ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente(rango_etario_cliente_id),
    FOREIGN KEY(canal_de_venta_id) REFERENCES ESE_CU_ELE.BI_Dim_Canal_De_Venta(canal_de_venta_id),
    FOREIGN KEY(tipo_de_servicio_id) REFERENCES ESE_CU_ELE.BI_Dim_Tipo_Servicio(tipo_servicio_id)
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

--------------- Hecho_Propuesta ---------------

CREATE TABLE ESE_CU_ELE.BI_Hecho_Propuesta (

    tiempo_id BIGINT, -- FK
    temporada_id BIGINT, -- FK
    rango_etario_agente_id BIGINT, -- FK
    estado_propuesta BIGINT, -- FK

    cantidad_propuestas INT,
    cantidad_propuestas_aceptadas INT,
    suma_importe_total DECIMAL(18,2),
    suma_dias_en_responder INT,
    cantidad_presupuestos INT,
    suma_desvio_presupuestos DECIMAL(18,2),

    FOREIGN KEY (tiempo_id)
        REFERENCES ESE_CU_ELE.BI_Dim_Tiempo(tiempo_id),

    FOREIGN KEY (temporada_id)
        REFERENCES ESE_CU_ELE.BI_Dim_Temporada(temporada_id),

    FOREIGN KEY (rango_etario_agente_id)
        REFERENCES ESE_CU_ELE.BI_Dim_Rango_Etario_Agente(rango_etario_agente_id),

    FOREIGN KEY (estado_propuesta)
        REFERENCES ESE_CU_ELE.BI_Dim_Estado_De_Propuesta(estado_de_propuesta_id)

);


PRINT(N'Creadas las tablas de hechos');
GO



----------------------------------------------
-- MIGRACION A LAS TABLAS DE DIMENSIONES
----------------------------------------------

CREATE PROCEDURE ESE_CU_ELE.BI_carga_dimensiones
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


--------------- Dim_Canal_De_Venta ---------------

INSERT INTO ESE_CU_ELE.BI_Dim_Canal_De_Venta (canal)
SELECT DISTINCT canal
FROM ESE_CU_ELE.Canal_De_Venta
WHERE canal IS NOT NULL;


--------------- Dim_Tipo_Servicio ---------------

INSERT INTO ESE_CU_ELE.BI_Dim_Tipo_Servicio (tipo_servicio)
VALUES ('Venta Directa'), ('Propuesta a Medida');


--------------- Dim_Estado_De_Propuesta ---------------

INSERT INTO ESE_CU_ELE.BI_Dim_Estado_De_Propuesta (estado)
SELECT DISTINCT estado
FROM ESE_CU_ELE.Estado_Propuesta
WHERE estado IS NOT NULL;

END; -- FIN PROCEDIMIENTO carga de las dimensiones
GO


--------------- Ejecucion del procedimiento de dimensiones ---------------

BEGIN TRY
    BEGIN TRANSACTION
    EXECUTE ESE_CU_ELE.BI_carga_dimensiones;
    PRINT(N'Carga de datos a las tablas de dimensiones hecha');
    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT(N'Se hizo un Rollback en la carga de datos a las tablas de dimensiones debido al siguiente error: ' + ERROR_MESSAGE());
END CATCH;
GO


----------------------------------------------
-- MIGRACION A LAS TABLAS DE HECHOS Y GENERACION DE METRICAS
----------------------------------------------

CREATE PROCEDURE ESE_CU_ELE.BI_carga_hechos
AS
BEGIN

--------------- Hecho_Venta ---------------

-- Determina el tipo de servicio por la existencia de una propuesta vinculada a la venta.
-- Si la venta tiene al menos una propuesta asociada en Venta_Propuesta es "Propuesta a Medida",
-- de lo contrario es "Venta Directa".
INSERT INTO ESE_CU_ELE.BI_Hecho_Venta (tiempo_id, rango_etario_cliente_id, canal_de_venta_id, tipo_de_servicio_id, cantidad_ventas, suma_importe_total)
SELECT
    Tiempo.tiempo_id,
    Rango_Cliente.rango_etario_cliente_id,
    Canal.canal_de_venta_id,
    Tipo.tipo_servicio_id,
    COUNT(Venta.venta_nro)      AS cantidad_ventas,
    SUM(Venta.importe_total)    AS suma_importe_total
FROM ESE_CU_ELE.Venta AS Venta
-- Dim_Tiempo
INNER JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo
    ON Tiempo.anio = YEAR(Venta.fecha) AND Tiempo.mes = MONTH(Venta.fecha)
-- Dim_Rango_Etario_Cliente
INNER JOIN ESE_CU_ELE.Cliente Cliente ON Cliente.cliente_id = Venta.cliente_id
INNER JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente Rango_Cliente ON
    (DATEDIFF(YEAR, Cliente.fecha_nacimiento, Venta.fecha) -
        CASE
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, Cliente.fecha_nacimiento, Venta.fecha), Cliente.fecha_nacimiento) > Venta.fecha
            THEN 1 ELSE 0
        END)
    BETWEEN Rango_Cliente.min_edad AND Rango_Cliente.max_edad
-- Dim_Canal_De_Venta
INNER JOIN ESE_CU_ELE.Canal_De_Venta Canal_Trans ON Canal_Trans.canal_venta_id = Venta.canal_venta_id
INNER JOIN ESE_CU_ELE.BI_Dim_Canal_De_Venta Canal ON Canal.canal = Canal_Trans.canal
-- Dim_Tipo_Servicio
INNER JOIN ESE_CU_ELE.BI_Dim_Tipo_Servicio Tipo ON Tipo.tipo_servicio =
    CASE
        WHEN EXISTS (
            SELECT 1 FROM ESE_CU_ELE.Venta_Propuesta VP WHERE VP.venta_nro = Venta.venta_nro
        ) THEN 'Propuesta a Medida'
        ELSE 'Venta Directa'
    END
GROUP BY Tiempo.tiempo_id, Rango_Cliente.rango_etario_cliente_id, Canal.canal_de_venta_id, Tipo.tipo_servicio_id;


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
INNER JOIN ESE_CU_ELE.Agente Agente ON Agente.agente_legajo = Encuesta.agente_legajo
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


--------------- Hecho_Propuesta ---------------

INSERT INTO ESE_CU_ELE.BI_Hecho_Propuesta (
    tiempo_id,
    temporada_id,
    rango_etario_agente_id,
    estado_propuesta,
    cantidad_propuestas,
    cantidad_propuestas_aceptadas,
    suma_importe_total,
    suma_dias_en_responder,
    cantidad_presupuestos,
    suma_desvio_presupuestos
)
SELECT
    Tiempo.tiempo_id,
    Temporada.temporada_id,
    Rango_Agente.rango_etario_agente_id,
    EstadoBI.estado_de_propuesta_id,

    COUNT(*) AS cantidad_propuestas,

    SUM(
        CASE
            WHEN Estado.estado = 'Aceptada'
            THEN 1
            ELSE 0
        END
    ) AS cantidad_propuestas_aceptadas,

    SUM(P.importe_total) AS suma_importe_total,

    SUM(
        DATEDIFF(
            DAY,
            Solicitud.fecha_solicitud,
            P.fecha_emision
        )
    ) AS suma_dias_en_responder,

    COUNT(*) AS cantidad_presupuestos,

    SUM(
        P.importe_total - Solicitud.presupuesto_estimado
    ) AS suma_desvio_presupuestos

FROM ESE_CU_ELE.Propuesta P

INNER JOIN ESE_CU_ELE.Solicitud_De_Cotizacion Solicitud
    ON Solicitud.nro_solicitud_id = P.nro_solicitud_id

INNER JOIN ESE_CU_ELE.Agente Agente
    ON Agente.agente_legajo = P.agente_legajo

INNER JOIN ESE_CU_ELE.Estado_Propuesta Estado
    ON Estado.propuesta_nro = P.propuesta_nro

-- Dim_Tiempo
INNER JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo
ON Tiempo.anio = YEAR(P.fecha_emision)
AND Tiempo.mes = MONTH(P.fecha_emision)

-- Dim_Temporada
INNER JOIN ESE_CU_ELE.BI_Dim_Temporada Temporada
ON MONTH(P.fecha_desde)
BETWEEN Temporada.mes_inicio
AND Temporada.mes_fin

-- Dim_Rango_Etario_Agente
INNER JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Agente Rango_Agente
ON
(
DATEDIFF(YEAR,Agente.fecha_nacimiento,P.fecha_emision)
-
CASE
WHEN DATEADD(YEAR,
DATEDIFF(YEAR,Agente.fecha_nacimiento,P.fecha_emision),
Agente.fecha_nacimiento)>P.fecha_emision
THEN 1
ELSE 0
END
)
BETWEEN Rango_Agente.min_edad
AND Rango_Agente.max_edad

-- Dim_Estado
INNER JOIN ESE_CU_ELE.BI_Dim_Estado_De_Propuesta EstadoBI
ON EstadoBI.estado = Estado.estado

GROUP BY
Tiempo.tiempo_id,
Temporada.temporada_id,
Rango_Agente.rango_etario_agente_id,
EstadoBI.estado_de_propuesta_id;

END; -- FIN PROCEDIMIENTO carga de los hechos
GO


--------------- Ejecucion del procedimiento de hechos ---------------

BEGIN TRY
    BEGIN TRANSACTION
    EXECUTE ESE_CU_ELE.BI_carga_hechos;
    PRINT(N'Carga de datos a las tablas de hechos hecha');
    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT(N'Se hizo un Rollback en la carga de datos a las tablas de hechos debido al siguiente error: ' + ERROR_MESSAGE());
END CATCH;
GO



----------------------------------------------
-- CREACION DE LAS VISTAS
----------------------------------------------

--------------- 1. Ticket promedio ---------------

CREATE VIEW ESE_CU_ELE.BI_View_Ticket_Promedio
AS
SELECT
    Rango_Cliente.rango_etario                                          AS rango_etario_cliente,
    Canal.canal                                                          AS canal_de_venta,
    Tiempo.anio                                                          AS anio,
    Tiempo.mes,
    CAST(
        SUM(Hecho.suma_importe_total) * 1.0 / NULLIF(SUM(Hecho.cantidad_ventas), 0)
    AS DECIMAL(18,2))                                                    AS ticket_promedio
FROM ESE_CU_ELE.BI_Hecho_Venta AS Hecho
JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo
    ON Tiempo.tiempo_id = Hecho.tiempo_id
JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente Rango_Cliente
    ON Rango_Cliente.rango_etario_cliente_id = Hecho.rango_etario_cliente_id
JOIN ESE_CU_ELE.BI_Dim_Canal_De_Venta Canal
    ON Canal.canal_de_venta_id = Hecho.canal_de_venta_id
GROUP BY Rango_Cliente.rango_etario, Canal.canal, Tiempo.anio, Tiempo.mes;
GO


--------------- 2. Distribución de Facturación ---------------

CREATE VIEW ESE_CU_ELE.BI_View_Distribucion_Facturacion
AS
SELECT
    Tipo.tipo_servicio,
    Tiempo.anio                                                          AS anio,
    Tiempo.cuatrimestre,
    CAST(
        SUM(Hecho.suma_importe_total) * 100.0 /
        NULLIF(SUM(SUM(Hecho.suma_importe_total)) OVER (PARTITION BY Tiempo.anio, Tiempo.cuatrimestre), 0)
    AS DECIMAL(18,2))                                                    AS porcentaje_facturacion
FROM ESE_CU_ELE.BI_Hecho_Venta AS Hecho
JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo
    ON Tiempo.tiempo_id = Hecho.tiempo_id
JOIN ESE_CU_ELE.BI_Dim_Tipo_Servicio Tipo
    ON Tipo.tipo_servicio_id = Hecho.tipo_de_servicio_id
GROUP BY Tipo.tipo_servicio, Tiempo.anio, Tiempo.cuatrimestre;
GO


--------------- 3. Ranking de solicitudes por temporadas ---------------

CREATE VIEW ESE_CU_ELE.BI_View_Ranking_De_Solicitudes_Por_Temporada
AS
SELECT
	Temporada.temporada,
	Tiempo.anio AS anio,
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
GROUP BY Rango_Etario_Cliente.rango_etario, Tiempo.cuatrimestre;
GO


--------------- 5. Tasa de aceptación de propuestas ---------------

CREATE VIEW ESE_CU_ELE.BI_View_Tasa_De_Aceptacion_De_Propuestas
AS
SELECT
    Tiempo.cuatrimestre,
    CAST( SUM(Hecho_Propuesta.cantidad_propuestas_aceptadas) * 100.0
        / NULLIF(SUM(Hecho_Propuesta.cantidad_propuestas), 0) AS DECIMAL(18,2)) AS tasa_aceptacion
FROM ESE_CU_ELE.BI_Hecho_Propuesta AS Hecho_Propuesta
JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo
    ON Tiempo.tiempo_id = Hecho_Propuesta.tiempo_id
GROUP BY
    Tiempo.cuatrimestre;
GO


--------------- 6. Cotización promedio por temporada ---------------

CREATE VIEW ESE_CU_ELE.BI_View_Cotizacion_Promedio_Por_Temporada
AS
SELECT
    Tiempo.anio,
    Temporada.temporada,
    CAST( SUM(Hecho_Propuesta.suma_importe_total) * 1.0
        / NULLIF(SUM(Hecho_Propuesta.cantidad_propuestas), 0) AS DECIMAL(18,2)) AS cotizacion_promedio
FROM ESE_CU_ELE.BI_Hecho_Propuesta AS Hecho_Propuesta
JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo
    ON Tiempo.tiempo_id = Hecho_Propuesta.tiempo_id
JOIN ESE_CU_ELE.BI_Dim_Temporada Temporada
    ON Temporada.temporada_id = Hecho_Propuesta.temporada_id
GROUP BY
    Tiempo.anio,
    Temporada.temporada;
GO


--------------- 7. Tiempo promedio de respuesta ---------------

CREATE VIEW ESE_CU_ELE.BI_View_Tiempo_Promedio_De_Respuesta
AS
SELECT
	Tiempo.anio,
    Tiempo.mes,
    Rango_Etario_Agente.rango_etario,
    CAST(SUM(Hecho_Propuesta.suma_dias_en_responder) * 1.0
        / NULLIF(SUM(Hecho_Propuesta.cantidad_propuestas), 0) AS DECIMAL(18,2)) AS tiempo_promedio_respuesta
FROM ESE_CU_ELE.BI_Hecho_Propuesta AS Hecho_Propuesta
JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo
    ON Tiempo.tiempo_id = Hecho_Propuesta.tiempo_id
JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Agente Rango_Etario_Agente
    ON Rango_Etario_Agente.rango_etario_agente_id = Hecho_Propuesta.rango_etario_agente_id
GROUP BY
	Tiempo.anio,
    Tiempo.mes,
    Rango_Etario_Agente.rango_etario;
GO


--------------- 8. Desvío de presupuesto ---------------

CREATE VIEW ESE_CU_ELE.BI_View_Desvio_De_Presupuesto
AS
SELECT
    CAST( SUM(Hecho_Propuesta.suma_desvio_presupuestos) * 1.0
        / NULLIF(SUM(Hecho_Propuesta.cantidad_presupuestos), 0) AS DECIMAL(18,2)) AS desvio_promedio
FROM ESE_CU_ELE.BI_Hecho_Propuesta AS Hecho_Propuesta;
GO


--------------- 9. Promedio mensual de puntaje por aspecto de la encuesta ---------------

CREATE VIEW ESE_CU_ELE.BI_View_Promedio_Mensual_Puntaje_Por_Aspecto
AS
SELECT
    Tiempo.anio AS anio,
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