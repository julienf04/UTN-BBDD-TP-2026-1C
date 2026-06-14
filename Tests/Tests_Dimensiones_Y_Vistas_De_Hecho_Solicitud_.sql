SET NOCOUNT ON;

PRINT '====================================';
PRINT 'BI AUDITOR TP - INICIO';
PRINT '====================================';

DECLARE @errores INT = 0;
DECLARE @cnt_esperado BIGINT;
DECLARE @cnt_actual BIGINT;
DECLARE @sum_esperado DECIMAL(38, 2);
DECLARE @sum_actual DECIMAL(38, 2);
DECLARE @msg NVARCHAR(2048);

------------------------------------------------------------
-- DOMINIOS AUXILIARES
------------------------------------------------------------
DROP TABLE IF EXISTS #Meses;
;WITH M AS
(
    SELECT 1 AS mes
    UNION ALL
    SELECT mes + 1
    FROM M
    WHERE mes < 12
)
SELECT mes
INTO #Meses
FROM M
OPTION (MAXRECURSION 0);

DROP TABLE IF EXISTS #EdadDomain;
;WITH E AS
(
    SELECT 0 AS edad
    UNION ALL
    SELECT edad + 1
    FROM E
    WHERE edad < 255
)
SELECT edad
INTO #EdadDomain
FROM E
OPTION (MAXRECURSION 0);

------------------------------------------------------------
-- BASE DE SOLICITUDES
------------------------------------------------------------
DROP TABLE IF EXISTS #SolicitudBase;

SELECT
    S.nro_solicitud_id,
    S.cliente_id,
    S.fecha_solicitud,
    S.fecha_inicio_tentativa,
    YEAR(S.fecha_solicitud) AS anio,
    MONTH(S.fecha_solicitud) AS mes,
    CASE
        WHEN S.fecha_solicitud IS NULL THEN NULL
        WHEN MONTH(S.fecha_solicitud) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(S.fecha_solicitud) BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END AS cuatrimestre,
    CASE
        WHEN S.fecha_solicitud IS NULL THEN NULL
        WHEN MONTH(S.fecha_solicitud) BETWEEN 1 AND 3 THEN N'Verano'
        WHEN MONTH(S.fecha_solicitud) BETWEEN 4 AND 6 THEN N'Otoño'
        WHEN MONTH(S.fecha_solicitud) BETWEEN 7 AND 9 THEN N'Invierno'
        ELSE N'Primavera'
    END AS temporada_esperada,
    DATEDIFF(DAY, S.fecha_solicitud, S.fecha_inicio_tentativa) AS dias_anticipacion,
    E.edad_correcta,
    CASE
        WHEN E.edad_correcta IS NULL THEN NULL
        WHEN E.edad_correcta <= 25 THEN N'Menores de 25 años inclusive'
        WHEN E.edad_correcta BETWEEN 26 AND 35 THEN N'Entre 26 y 35 años inclusive'
        WHEN E.edad_correcta BETWEEN 36 AND 50 THEN N'Entre 36 y 50 años inclusive'
        ELSE N'Mayores de 50 años'
    END AS rango_etario_cliente_esperado
INTO #SolicitudBase
FROM ESE_CU_ELE.Solicitud_De_Cotizacion AS S
INNER JOIN ESE_CU_ELE.Cliente AS C
    ON C.cliente_id = S.cliente_id
CROSS APPLY
(
    SELECT
        CASE
            WHEN C.fecha_nacimiento IS NULL OR S.fecha_solicitud IS NULL THEN NULL
            ELSE
                DATEDIFF(YEAR, C.fecha_nacimiento, S.fecha_solicitud)
                - CASE
                    WHEN DATEADD(
                            YEAR,
                            DATEDIFF(YEAR, C.fecha_nacimiento, S.fecha_solicitud),
                            C.fecha_nacimiento
                        ) > S.fecha_solicitud
                    THEN 1
                    ELSE 0
                  END
        END AS edad_correcta
) AS E;

------------------------------------------------------------
-- TEST 0: CALIDAD DE DATOS DE ORIGEN
------------------------------------------------------------
PRINT 'TEST 0 - Calidad de datos de Solicitud_De_Cotizacion';

SELECT @cnt_esperado = COUNT(*)
FROM ESE_CU_ELE.Solicitud_De_Cotizacion;

SELECT @cnt_actual = COUNT(*)
FROM #SolicitudBase;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 0.1 FAILED: Hay solicitudes que no pudieron incorporarse a la base.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 0.1 PASSED: Todas las solicitudes quedaron en la base.';

IF EXISTS
(
    SELECT 1
    FROM #SolicitudBase
    WHERE cliente_id IS NULL
       OR fecha_solicitud IS NULL
       OR fecha_inicio_tentativa IS NULL
       OR edad_correcta IS NULL
       OR temporada_esperada IS NULL
       OR cuatrimestre IS NULL
       OR dias_anticipacion IS NULL
       OR rango_etario_cliente_esperado IS NULL
)
BEGIN
    PRINT '❌ TEST 0.2 FAILED: Existen campos nulos en datos clave de Solicitud_De_Cotizacion.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 0.2 PASSED: No hay nulos en campos clave.';

IF EXISTS
(
    SELECT 1
    FROM #SolicitudBase
    WHERE dias_anticipacion < 0
)
BEGIN
    PRINT '❌ TEST 0.3 FAILED: Existen solicitudes con anticipación negativa.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 0.3 PASSED: No hay anticipaciones negativas.';

------------------------------------------------------------
-- TEST 1: DIMENSIÓN TEMPORADA
------------------------------------------------------------
PRINT 'TEST 1 - Dimensión Temporada';

SELECT @cnt_esperado = 4;
SELECT @cnt_actual = COUNT(*)
FROM ESE_CU_ELE.BI_Dim_Temporada;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 1.1 FAILED: BI_Dim_Temporada debe tener exactamente 4 filas.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 1.1 PASSED: Cantidad de temporadas correcta.';

IF EXISTS
(
    SELECT temporada, mes_inicio, mes_fin
    FROM ESE_CU_ELE.BI_Dim_Temporada
    EXCEPT
    SELECT *
    FROM (VALUES
        (N'Verano',    CAST(1  AS TINYINT), CAST(3  AS TINYINT)),
        (N'Otoño',     CAST(4  AS TINYINT), CAST(6  AS TINYINT)),
        (N'Invierno',  CAST(7  AS TINYINT), CAST(9  AS TINYINT)),
        (N'Primavera', CAST(10 AS TINYINT), CAST(12 AS TINYINT))
    ) V(temporada, mes_inicio, mes_fin)
)
OR EXISTS
(
    SELECT *
    FROM (VALUES
        (N'Verano',    CAST(1  AS TINYINT), CAST(3  AS TINYINT)),
        (N'Otoño',     CAST(4  AS TINYINT), CAST(6  AS TINYINT)),
        (N'Invierno',  CAST(7  AS TINYINT), CAST(9  AS TINYINT)),
        (N'Primavera', CAST(10 AS TINYINT), CAST(12 AS TINYINT))
    ) V(temporada, mes_inicio, mes_fin)
    EXCEPT
    SELECT temporada, mes_inicio, mes_fin
    FROM ESE_CU_ELE.BI_Dim_Temporada
)
BEGIN
    PRINT '❌ TEST 1.2 FAILED: BI_Dim_Temporada no coincide con la definición del TP.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 1.2 PASSED: Temporadas exactas.';

IF EXISTS
(
    SELECT M.mes
    FROM #Meses AS M
    LEFT JOIN ESE_CU_ELE.BI_Dim_Temporada AS T
        ON M.mes BETWEEN T.mes_inicio AND T.mes_fin
    GROUP BY M.mes
    HAVING COUNT(T.temporada_id) <> 1
)
BEGIN
    PRINT '❌ TEST 1.3 FAILED: Algún mes no pertenece a exactamente una temporada.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 1.3 PASSED: Cobertura mensual de temporadas correcta.';

SELECT @cnt_esperado = COUNT(*)
FROM #SolicitudBase;

SELECT @cnt_actual = COUNT(*)
FROM #SolicitudBase AS SB
INNER JOIN ESE_CU_ELE.BI_Dim_Temporada AS T
    ON SB.mes BETWEEN T.mes_inicio AND T.mes_fin;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 1.4 FAILED: No todas las solicitudes mapearon exactamente una temporada.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 1.4 PASSED: Cada solicitud mapea exactamente una temporada.';

------------------------------------------------------------
-- TEST 2: DIMENSIÓN RANGO ETARIO CLIENTE
------------------------------------------------------------
PRINT 'TEST 2 - Dimensión Rango Etario Cliente';

SELECT @cnt_esperado = 4;
SELECT @cnt_actual = COUNT(*)
FROM ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 2.1 FAILED: BI_Dim_Rango_Etario_Cliente debe tener exactamente 4 filas.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 2.1 PASSED: Cantidad de rangos de cliente correcta.';

IF EXISTS
(
    SELECT rango_etario, min_edad, max_edad
    FROM ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente
    EXCEPT
    SELECT *
    FROM (VALUES
        (N'Menores de 25 años inclusive', CAST(0   AS TINYINT), CAST(25  AS TINYINT)),
        (N'Entre 26 y 35 años inclusive', CAST(26  AS TINYINT), CAST(35  AS TINYINT)),
        (N'Entre 36 y 50 años inclusive', CAST(36  AS TINYINT), CAST(50  AS TINYINT)),
        (N'Mayores de 50 años',           CAST(51  AS TINYINT), CAST(255 AS TINYINT))
    ) V(rango_etario, min_edad, max_edad)
)
OR EXISTS
(
    SELECT *
    FROM (VALUES
        (N'Menores de 25 años inclusive', CAST(0   AS TINYINT), CAST(25  AS TINYINT)),
        (N'Entre 26 y 35 años inclusive', CAST(26  AS TINYINT), CAST(35  AS TINYINT)),
        (N'Entre 36 y 50 años inclusive', CAST(36  AS TINYINT), CAST(50  AS TINYINT)),
        (N'Mayores de 50 años',           CAST(51  AS TINYINT), CAST(255 AS TINYINT))
    ) V(rango_etario, min_edad, max_edad)
    EXCEPT
    SELECT rango_etario, min_edad, max_edad
    FROM ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente
)
BEGIN
    PRINT '❌ TEST 2.2 FAILED: BI_Dim_Rango_Etario_Cliente no coincide con la definición del TP.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 2.2 PASSED: Rangos de cliente exactos.';

IF EXISTS
(
    SELECT E.edad
    FROM #EdadDomain AS E
    LEFT JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente AS R
        ON E.edad BETWEEN R.min_edad AND R.max_edad
    GROUP BY E.edad
    HAVING COUNT(R.rango_etario_cliente_id) <> 1
)
BEGIN
    PRINT '❌ TEST 2.3 FAILED: Alguna edad de 0 a 255 no pertenece a exactamente un rango de cliente.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 2.3 PASSED: Cobertura etaria de clientes correcta.';

SELECT @cnt_esperado = COUNT(*)
FROM #SolicitudBase;

SELECT @cnt_actual = COUNT(*)
FROM #SolicitudBase AS SB
INNER JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente AS R
    ON SB.edad_correcta BETWEEN R.min_edad AND R.max_edad;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 2.4 FAILED: No todas las solicitudes mapearon exactamente un rango etario de cliente.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 2.4 PASSED: Cada solicitud mapea exactamente un rango etario de cliente.';

------------------------------------------------------------
-- TEST 3: DIMENSIÓN RANGO ETARIO AGENTE
------------------------------------------------------------
PRINT 'TEST 3 - Dimensión Rango Etario Agente';

SELECT @cnt_esperado = 3;
SELECT @cnt_actual = COUNT(*)
FROM ESE_CU_ELE.BI_Dim_Rango_Etario_Agente;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 3.1 FAILED: BI_Dim_Rango_Etario_Agente debe tener exactamente 3 filas.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 3.1 PASSED: Cantidad de rangos de agente correcta.';

IF EXISTS
(
    SELECT rango_etario, min_edad, max_edad
    FROM ESE_CU_ELE.BI_Dim_Rango_Etario_Agente
    EXCEPT
    SELECT *
    FROM (VALUES
        (N'Entre 26 y 35 años inclusive', CAST(26  AS TINYINT), CAST(35  AS TINYINT)),
        (N'Entre 36 y 50 años inclusive', CAST(36  AS TINYINT), CAST(50  AS TINYINT)),
        (N'Mayores de 50 años',           CAST(51  AS TINYINT), CAST(255 AS TINYINT))
    ) V(rango_etario, min_edad, max_edad)
)
OR EXISTS
(
    SELECT *
    FROM (VALUES
        (N'Entre 26 y 35 años inclusive', CAST(26  AS TINYINT), CAST(35  AS TINYINT)),
        (N'Entre 36 y 50 años inclusive', CAST(36  AS TINYINT), CAST(50  AS TINYINT)),
        (N'Mayores de 50 años',           CAST(51  AS TINYINT), CAST(255 AS TINYINT))
    ) V(rango_etario, min_edad, max_edad)
    EXCEPT
    SELECT rango_etario, min_edad, max_edad
    FROM ESE_CU_ELE.BI_Dim_Rango_Etario_Agente
)
BEGIN
    PRINT '❌ TEST 3.2 FAILED: BI_Dim_Rango_Etario_Agente no coincide con la definición adoptada.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 3.2 PASSED: Rangos de agente exactos.';

IF EXISTS
(
    SELECT E.edad
    FROM #EdadDomain AS E
    LEFT JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Agente AS R
        ON E.edad BETWEEN R.min_edad AND R.max_edad
    GROUP BY E.edad
    HAVING
        (
            E.edad BETWEEN 26 AND 255
            AND COUNT(R.rango_etario_agente_id) <> 1
        )
        OR
        (
            E.edad BETWEEN 0 AND 25
            AND COUNT(R.rango_etario_agente_id) <> 0
        )
)
BEGIN
    PRINT '❌ TEST 3.3 FAILED: La cobertura etaria de agentes no respeta la definición adoptada.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 3.3 PASSED: Cobertura etaria de agentes correcta.';

------------------------------------------------------------
-- TEST 4: DIMENSIÓN TIEMPO
------------------------------------------------------------
PRINT 'TEST 4 - Dimensión Tiempo';

IF EXISTS
(
    SELECT 1
    FROM ESE_CU_ELE.BI_Dim_Tiempo
    WHERE anio IS NULL
       OR mes IS NULL
       OR cuatrimestre IS NULL
       OR mes NOT BETWEEN 1 AND 12
       OR cuatrimestre NOT BETWEEN 1 AND 3
       OR cuatrimestre <> CASE
                            WHEN mes BETWEEN 1 AND 4 THEN 1
                            WHEN mes BETWEEN 5 AND 8 THEN 2
                            ELSE 3
                          END
)
BEGIN
    PRINT '❌ TEST 4.1 FAILED: BI_Dim_Tiempo tiene filas inválidas o cuatrimestres mal calculados.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 4.1 PASSED: Estructura y cuatrimestre de tiempo correctos.';

IF EXISTS
(
    SELECT anio, mes
    FROM ESE_CU_ELE.BI_Dim_Tiempo
    GROUP BY anio, mes
    HAVING COUNT(*) <> 1
)
BEGIN
    PRINT '❌ TEST 4.2 FAILED: Existe más de una fila para el mismo (anio, mes) en BI_Dim_Tiempo.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 4.2 PASSED: Unicidad (anio, mes) correcta.';

SELECT @cnt_esperado = COUNT(*)
FROM #SolicitudBase;

SELECT @cnt_actual = COUNT(*)
FROM #SolicitudBase AS SB
INNER JOIN ESE_CU_ELE.BI_Dim_Tiempo AS T
    ON T.anio = SB.anio
   AND T.mes = SB.mes;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 4.3 FAILED: No todas las solicitudes mapearon exactamente un tiempo.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 4.3 PASSED: Cada solicitud mapea exactamente un tiempo.';

------------------------------------------------------------
-- TEST 5: DIMENSIONES EXTRA
------------------------------------------------------------
PRINT 'TEST 5 - Dimensiones extra';

SELECT @cnt_esperado = 2;
SELECT @cnt_actual = COUNT(*) FROM ESE_CU_ELE.BI_Dim_Tipo_Servicio;
IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 5.1 FAILED: BI_Dim_Tipo_Servicio debe tener exactamente 2 filas.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 5.1 PASSED: Cantidad de tipos de servicio correcta.';

IF EXISTS
(
    SELECT tipo_servicio
    FROM ESE_CU_ELE.BI_Dim_Tipo_Servicio
    EXCEPT
    SELECT *
    FROM (VALUES
        (N'Venta Directa'),
        (N'Propuesta a Medida')
    ) V(tipo_servicio)
)
OR EXISTS
(
    SELECT *
    FROM (VALUES
        (N'Venta Directa'),
        (N'Propuesta a Medida')
    ) V(tipo_servicio)
    EXCEPT
    SELECT tipo_servicio
    FROM ESE_CU_ELE.BI_Dim_Tipo_Servicio
)
BEGIN
    PRINT '❌ TEST 5.2 FAILED: BI_Dim_Tipo_Servicio no coincide con el TP.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 5.2 PASSED: Tipos de servicio exactos.';

IF NOT EXISTS (SELECT 1 FROM ESE_CU_ELE.BI_Dim_Canal_De_Venta)
BEGIN
    PRINT '❌ TEST 5.3 FAILED: BI_Dim_Canal_De_Venta está vacía.';
    SET @errores += 1;
END
ELSE IF EXISTS
(
    SELECT 1
    FROM ESE_CU_ELE.BI_Dim_Canal_De_Venta
    WHERE canal IS NULL OR LTRIM(RTRIM(canal)) = ''
)
BEGIN
    PRINT '❌ TEST 5.3 FAILED: BI_Dim_Canal_De_Venta tiene labels nulos o vacíos.';
    SET @errores += 1;
END
ELSE IF EXISTS
(
    SELECT canal
    FROM ESE_CU_ELE.BI_Dim_Canal_De_Venta
    GROUP BY canal
    HAVING COUNT(*) > 1
)
BEGIN
    PRINT '❌ TEST 5.3 FAILED: BI_Dim_Canal_De_Venta tiene labels duplicados.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 5.3 PASSED: BI_Dim_Canal_De_Venta OK.';

IF NOT EXISTS (SELECT 1 FROM ESE_CU_ELE.BI_Dim_Estado_De_Propuesta)
BEGIN
    PRINT '❌ TEST 5.4 FAILED: BI_Dim_Estado_De_Propuesta está vacía.';
    SET @errores += 1;
END
ELSE IF EXISTS
(
    SELECT 1
    FROM ESE_CU_ELE.BI_Dim_Estado_De_Propuesta
    WHERE estado IS NULL OR LTRIM(RTRIM(estado)) = ''
)
BEGIN
    PRINT '❌ TEST 5.4 FAILED: BI_Dim_Estado_De_Propuesta tiene labels nulos o vacíos.';
    SET @errores += 1;
END
ELSE IF EXISTS
(
    SELECT estado
    FROM ESE_CU_ELE.BI_Dim_Estado_De_Propuesta
    GROUP BY estado
    HAVING COUNT(*) > 1
)
BEGIN
    PRINT '❌ TEST 5.4 FAILED: BI_Dim_Estado_De_Propuesta tiene labels duplicados.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 5.4 PASSED: BI_Dim_Estado_De_Propuesta OK.';

IF NOT EXISTS (SELECT 1 FROM ESE_CU_ELE.BI_Dim_Aspecto)
BEGIN
    PRINT '❌ TEST 5.5 FAILED: BI_Dim_Aspecto está vacía.';
    SET @errores += 1;
END
ELSE IF EXISTS
(
    SELECT 1
    FROM ESE_CU_ELE.BI_Dim_Aspecto
    WHERE aspecto IS NULL OR LTRIM(RTRIM(aspecto)) = ''
)
BEGIN
    PRINT '❌ TEST 5.5 FAILED: BI_Dim_Aspecto tiene labels nulos o vacíos.';
    SET @errores += 1;
END
ELSE IF EXISTS
(
    SELECT aspecto
    FROM ESE_CU_ELE.BI_Dim_Aspecto
    GROUP BY aspecto
    HAVING COUNT(*) > 1
)
BEGIN
    PRINT '❌ TEST 5.5 FAILED: BI_Dim_Aspecto tiene labels duplicados.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 5.5 PASSED: BI_Dim_Aspecto OK.';

IF NOT EXISTS (SELECT 1 FROM ESE_CU_ELE.BI_Dim_Puntaje)
BEGIN
    PRINT '❌ TEST 5.6 FAILED: BI_Dim_Puntaje está vacía.';
    SET @errores += 1;
END
ELSE IF EXISTS
(
    SELECT 1
    FROM ESE_CU_ELE.BI_Dim_Puntaje
    WHERE puntaje IS NULL
)
BEGIN
    PRINT '❌ TEST 5.6 FAILED: BI_Dim_Puntaje tiene puntajes nulos.';
    SET @errores += 1;
END
ELSE IF EXISTS
(
    SELECT puntaje
    FROM ESE_CU_ELE.BI_Dim_Puntaje
    GROUP BY puntaje
    HAVING COUNT(*) > 1
)
BEGIN
    PRINT '❌ TEST 5.6 FAILED: BI_Dim_Puntaje tiene puntajes duplicados.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 5.6 PASSED: BI_Dim_Puntaje OK.';

------------------------------------------------------------
-- TEST 6: HECHO SOLICITUD DE COTIZACION
------------------------------------------------------------
PRINT 'TEST 6 - Hecho Solicitud De Cotizacion';

DROP TABLE IF EXISTS #HechoEsperado;
DROP TABLE IF EXISTS #HechoActual;

SELECT
    T.tiempo_id,
    Temp.temporada_id,
    R.rango_etario_cliente_id,
    COUNT(*) AS cantidad_solicitudes,
    SUM(SB.dias_anticipacion) AS suma_dias_anticipacion
INTO #HechoEsperado
FROM #SolicitudBase AS SB
INNER JOIN ESE_CU_ELE.BI_Dim_Tiempo AS T
    ON T.anio = SB.anio
   AND T.mes = SB.mes
INNER JOIN ESE_CU_ELE.BI_Dim_Temporada AS Temp
    ON SB.mes BETWEEN Temp.mes_inicio AND Temp.mes_fin
INNER JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente AS R
    ON SB.edad_correcta BETWEEN R.min_edad AND R.max_edad
GROUP BY
    T.tiempo_id,
    Temp.temporada_id,
    R.rango_etario_cliente_id;

SELECT
    tiempo_id,
    temporada_id,
    rango_etario_cliente_id,
    cantidad_solicitudes,
    suma_dias_anticipacion
INTO #HechoActual
FROM ESE_CU_ELE.BI_Hecho_Solicitud_De_Cotizacion;

SELECT @cnt_esperado = COUNT(*) FROM #HechoEsperado;
SELECT @cnt_actual   = COUNT(*) FROM #HechoActual;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 6.1 FAILED: La cantidad de filas del hecho no coincide con el esperado.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 6.1 PASSED: Cantidad de filas del hecho correcta.';

IF EXISTS
(
    SELECT tiempo_id, temporada_id, rango_etario_cliente_id, cantidad_solicitudes, suma_dias_anticipacion
    FROM #HechoEsperado
    EXCEPT
    SELECT tiempo_id, temporada_id, rango_etario_cliente_id, cantidad_solicitudes, suma_dias_anticipacion
    FROM #HechoActual
)
OR EXISTS
(
    SELECT tiempo_id, temporada_id, rango_etario_cliente_id, cantidad_solicitudes, suma_dias_anticipacion
    FROM #HechoActual
    EXCEPT
    SELECT tiempo_id, temporada_id, rango_etario_cliente_id, cantidad_solicitudes, suma_dias_anticipacion
    FROM #HechoEsperado
)
BEGIN
    PRINT '❌ TEST 6.2 FAILED: El contenido del hecho no coincide con lo esperado.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 6.2 PASSED: Contenido del hecho correcto.';

IF EXISTS
(
    SELECT tiempo_id, temporada_id, rango_etario_cliente_id
    FROM ESE_CU_ELE.BI_Hecho_Solicitud_De_Cotizacion
    GROUP BY tiempo_id, temporada_id, rango_etario_cliente_id
    HAVING COUNT(*) > 1
)
BEGIN
    PRINT '❌ TEST 6.3 FAILED: Hay duplicados en el grano del hecho.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 6.3 PASSED: Grano del hecho sin duplicados.';

IF EXISTS
(
    SELECT 1
    FROM ESE_CU_ELE.BI_Hecho_Solicitud_De_Cotizacion
    WHERE tiempo_id IS NULL
       OR temporada_id IS NULL
       OR rango_etario_cliente_id IS NULL
       OR cantidad_solicitudes IS NULL
       OR suma_dias_anticipacion IS NULL
)
BEGIN
    PRINT '❌ TEST 6.4 FAILED: El hecho tiene nulos en claves o métricas.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 6.4 PASSED: Sin nulos en claves o métricas.';

IF EXISTS
(
    SELECT 1
    FROM ESE_CU_ELE.BI_Hecho_Solicitud_De_Cotizacion
    WHERE cantidad_solicitudes <= 0
       OR suma_dias_anticipacion < 0
)
BEGIN
    PRINT '❌ TEST 6.5 FAILED: El hecho tiene métricas fuera de rango.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 6.5 PASSED: Métricas del hecho en rango esperado.';

IF EXISTS
(
    SELECT 1
    FROM ESE_CU_ELE.BI_Hecho_Solicitud_De_Cotizacion AS H
    LEFT JOIN ESE_CU_ELE.BI_Dim_Tiempo AS T
        ON T.tiempo_id = H.tiempo_id
    WHERE T.tiempo_id IS NULL
)
OR EXISTS
(
    SELECT 1
    FROM ESE_CU_ELE.BI_Hecho_Solicitud_De_Cotizacion AS H
    LEFT JOIN ESE_CU_ELE.BI_Dim_Temporada AS Temp
        ON Temp.temporada_id = H.temporada_id
    WHERE Temp.temporada_id IS NULL
)
OR EXISTS
(
    SELECT 1
    FROM ESE_CU_ELE.BI_Hecho_Solicitud_De_Cotizacion AS H
    LEFT JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente AS R
        ON R.rango_etario_cliente_id = H.rango_etario_cliente_id
    WHERE R.rango_etario_cliente_id IS NULL
)
BEGIN
    PRINT '❌ TEST 6.6 FAILED: El hecho tiene claves foráneas huérfanas.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 6.6 PASSED: Claves foráneas del hecho correctas.';

SELECT @sum_esperado = CAST(COUNT(*) AS DECIMAL(38,2))
FROM #SolicitudBase;

SELECT @sum_actual = CAST(SUM(CAST(cantidad_solicitudes AS DECIMAL(38,2))) AS DECIMAL(38,2))
FROM ESE_CU_ELE.BI_Hecho_Solicitud_De_Cotizacion;

IF @sum_actual <> @sum_esperado
BEGIN
    PRINT '❌ TEST 6.7 FAILED: SUM(cantidad_solicitudes) del hecho no coincide con la fuente.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 6.7 PASSED: Total de solicitudes correcto.';

SELECT @sum_esperado = CAST(SUM(CAST(dias_anticipacion AS DECIMAL(38,2))) AS DECIMAL(38,2))
FROM #SolicitudBase;

SELECT @sum_actual = CAST(SUM(CAST(suma_dias_anticipacion AS DECIMAL(38,2))) AS DECIMAL(38,2))
FROM ESE_CU_ELE.BI_Hecho_Solicitud_De_Cotizacion;

IF @sum_actual <> @sum_esperado
BEGIN
    PRINT '❌ TEST 6.8 FAILED: SUM(suma_dias_anticipacion) del hecho no coincide con la fuente.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 6.8 PASSED: Suma de días de anticipación correcta.';

------------------------------------------------------------
-- TEST 7: VISTA 3 - RANKING DE SOLICITUDES POR TEMPORADA
------------------------------------------------------------
PRINT 'TEST 7 - Vista Ranking de Solicitudes por Temporada';

DROP TABLE IF EXISTS #Vista3Esperada;
DROP TABLE IF EXISTS #Vista3Actual;

SELECT
    SB.temporada_esperada AS temporada,
    SB.anio,
    SB.rango_etario_cliente_esperado AS rango_etario,
    COUNT(*) AS cantidad_solicitudes
INTO #Vista3Esperada
FROM #SolicitudBase AS SB
GROUP BY
    SB.temporada_esperada,
    SB.anio,
    SB.rango_etario_cliente_esperado;

DECLARE @colAnioVista3 SYSNAME;

SELECT @colAnioVista3 =
    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM sys.columns c
            INNER JOIN sys.objects o
                ON o.object_id = c.object_id
            WHERE o.type = 'V'
              AND o.name = 'BI_View_Ranking_De_Solicitudes_Por_Temporada'
              AND c.name = 'anio'
        )
        THEN N'anio'
        WHEN EXISTS
        (
            SELECT 1
            FROM sys.columns c
            INNER JOIN sys.objects o
                ON o.object_id = c.object_id
            WHERE o.type = 'V'
              AND o.name = 'BI_View_Ranking_De_Solicitudes_Por_Temporada'
              AND c.name = N'año'
        )
        THEN N'año'
        ELSE NULL
    END;

IF @colAnioVista3 IS NULL
BEGIN
    PRINT '❌ TEST 7.0 FAILED: No se encontró una columna de año válida en la vista 3.';
    SET @errores += 1;
END
ELSE
BEGIN
    CREATE TABLE #Vista3Actual
    (
        temporada NVARCHAR(255),
        anio INT,
        rango_etario NVARCHAR(255),
        cantidad_solicitudes INT
    );

    DECLARE @sqlVista3 NVARCHAR(MAX) =
        N'INSERT INTO #Vista3Actual (temporada, anio, rango_etario, cantidad_solicitudes)
          SELECT
              Temporada,
              ' + QUOTENAME(@colAnioVista3) + N' AS anio,
              rango_etario,
              cantidad_solicitudes
          FROM ESE_CU_ELE.BI_View_Ranking_De_Solicitudes_Por_Temporada;';

    EXEC sys.sp_executesql @sqlVista3;

    SELECT @cnt_esperado = COUNT(*) FROM #Vista3Esperada;
    SELECT @cnt_actual   = COUNT(*) FROM #Vista3Actual;

    IF @cnt_actual <> @cnt_esperado
    BEGIN
        PRINT '❌ TEST 7.1 FAILED: La vista 3 no tiene la cantidad de filas esperada.';
        SET @errores += 1;
    END
    ELSE
        PRINT '✔ TEST 7.1 PASSED: Cantidad de filas de la vista 3 correcta.';

    IF EXISTS
    (
        SELECT temporada, anio, rango_etario, cantidad_solicitudes
        FROM #Vista3Esperada
        EXCEPT
        SELECT temporada, anio, rango_etario, cantidad_solicitudes
        FROM #Vista3Actual
    )
    OR EXISTS
    (
        SELECT temporada, anio, rango_etario, cantidad_solicitudes
        FROM #Vista3Actual
        EXCEPT
        SELECT temporada, anio, rango_etario, cantidad_solicitudes
        FROM #Vista3Esperada
    )
    BEGIN
        PRINT '❌ TEST 7.2 FAILED: La vista 3 no coincide con la expectativa del TP.';
        SET @errores += 1;
    END
    ELSE
        PRINT '✔ TEST 7.2 PASSED: Contenido de la vista 3 correcto.';

    IF EXISTS
    (
        SELECT temporada, anio, rango_etario
        FROM #Vista3Actual
        GROUP BY temporada, anio, rango_etario
        HAVING COUNT(*) > 1
    )
    BEGIN
        PRINT '❌ TEST 7.3 FAILED: La vista 3 tiene duplicados en el grano.';
        SET @errores += 1;
    END
    ELSE
        PRINT '✔ TEST 7.3 PASSED: Vista 3 sin duplicados en el grano.';

    SELECT @sum_esperado = CAST(COUNT(*) AS DECIMAL(38,2))
    FROM #SolicitudBase;

    SELECT @sum_actual = CAST(SUM(CAST(cantidad_solicitudes AS DECIMAL(38,2))) AS DECIMAL(38,2))
    FROM #Vista3Actual;

    IF @sum_actual <> @sum_esperado
    BEGIN
        PRINT '❌ TEST 7.4 FAILED: La suma de solicitudes de la vista 3 no coincide con la fuente.';
        SET @errores += 1;
    END
    ELSE
        PRINT '✔ TEST 7.4 PASSED: Total de solicitudes de la vista 3 correcto.';

    IF EXISTS
    (
        SELECT 1
        FROM #Vista3Actual
        WHERE temporada IS NULL
           OR anio IS NULL
           OR rango_etario IS NULL
           OR cantidad_solicitudes IS NULL
           OR cantidad_solicitudes <= 0
    )
    BEGIN
        PRINT '❌ TEST 7.5 FAILED: La vista 3 tiene valores nulos o inválidos.';
        SET @errores += 1;
    END
    ELSE
        PRINT '✔ TEST 7.5 PASSED: Valores de la vista 3 válidos.';
END

------------------------------------------------------------
-- TEST 8: VISTA 4 - ANTICIPACION PROMEDIO DE SOLICITUDES
------------------------------------------------------------
PRINT 'TEST 8 - Vista Anticipacion Promedio de Solicitudes';

DROP TABLE IF EXISTS #Vista4Esperada;
DROP TABLE IF EXISTS #Vista4Actual;

SELECT
    SB.rango_etario_cliente_esperado AS rango_etario,
    SB.cuatrimestre,
    CAST(
        AVG(CAST(SB.dias_anticipacion AS DECIMAL(18,2)))
        AS DECIMAL(18,2)
    ) AS promedio_dias_de_anticipacion
INTO #Vista4Esperada
FROM #SolicitudBase AS SB
GROUP BY
    SB.rango_etario_cliente_esperado,
    SB.cuatrimestre;

SELECT
    rango_etario,
    cuatrimestre,
    promedio_dias_de_anticipacion
INTO #Vista4Actual
FROM ESE_CU_ELE.BI_View_Anticipacion_Promedio_De_Solicitudes;

SELECT @cnt_esperado = COUNT(*) FROM #Vista4Esperada;
SELECT @cnt_actual   = COUNT(*) FROM #Vista4Actual;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 8.1 FAILED: La vista 4 no tiene la cantidad de filas esperada.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 8.1 PASSED: Cantidad de filas de la vista 4 correcta.';

IF EXISTS
(
    SELECT rango_etario, cuatrimestre, promedio_dias_de_anticipacion
    FROM #Vista4Esperada
    EXCEPT
    SELECT rango_etario, cuatrimestre, promedio_dias_de_anticipacion
    FROM #Vista4Actual
)
OR EXISTS
(
    SELECT rango_etario, cuatrimestre, promedio_dias_de_anticipacion
    FROM #Vista4Actual
    EXCEPT
    SELECT rango_etario, cuatrimestre, promedio_dias_de_anticipacion
    FROM #Vista4Esperada
)
BEGIN
    PRINT '❌ TEST 8.2 FAILED: La vista 4 no coincide con la expectativa del TP.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 8.2 PASSED: Contenido de la vista 4 correcto.';

IF EXISTS
(
    SELECT rango_etario, cuatrimestre
    FROM #Vista4Actual
    GROUP BY rango_etario, cuatrimestre
    HAVING COUNT(*) > 1
)
BEGIN
    PRINT '❌ TEST 8.3 FAILED: La vista 4 tiene duplicados en el grano.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 8.3 PASSED: Vista 4 sin duplicados en el grano.';

IF EXISTS
(
    SELECT 1
    FROM #Vista4Actual
    WHERE rango_etario IS NULL
       OR cuatrimestre IS NULL
       OR promedio_dias_de_anticipacion IS NULL
       OR promedio_dias_de_anticipacion < 0
)
BEGIN
    PRINT '❌ TEST 8.4 FAILED: La vista 4 tiene valores nulos o inválidos.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 8.4 PASSED: Valores de la vista 4 válidos.';

------------------------------------------------------------
-- VALIDACIÓN FINAL
------------------------------------------------------------
PRINT '====================================';

IF @errores = 0
BEGIN
    PRINT '🎉 TODOS LOS TESTS PASARON CORRECTAMENTE';
    PRINT '====================================';
END
ELSE
BEGIN
    PRINT '⚠ SE DETECTARON ERRORES EN EL MODELO BI';
    PRINT '====================================';
    SET @msg = CONCAT(N'Se detectaron ', @errores, N' error(es) en el test suite BI.');
    THROW 50000, @msg, 1;
END