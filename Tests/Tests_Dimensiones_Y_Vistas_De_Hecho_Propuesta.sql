
SET NOCOUNT ON;

PRINT '====================================';
PRINT 'BI AUDITOR TP - VERTICAL PROPUESTAS';
PRINT '====================================';

DECLARE @errores INT = 0;
DECLARE @cnt_esperado BIGINT;
DECLARE @cnt_actual BIGINT;
DECLARE @sum_esperado DECIMAL(38,2);
DECLARE @sum_actual DECIMAL(38,2);
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
-- BASE DE PROPUESTAS (ORIGEN)
------------------------------------------------------------

DROP TABLE IF EXISTS #PropuestaBase;

SELECT

    P.propuesta_nro,
    P.nro_solicitud_id,
    P.agente_legajo,

    P.fecha_emision,
    P.fecha_desde,
    P.fecha_hasta,

    YEAR(P.fecha_emision) AS anio,
    MONTH(P.fecha_emision) AS mes,

    CASE
        WHEN MONTH(P.fecha_emision) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(P.fecha_emision) BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END AS cuatrimestre,

    CASE
        WHEN MONTH(P.fecha_desde) BETWEEN 1 AND 3 THEN N'Verano'
        WHEN MONTH(P.fecha_desde) BETWEEN 4 AND 6 THEN N'Otoño'
        WHEN MONTH(P.fecha_desde) BETWEEN 7 AND 9 THEN N'Invierno'
        ELSE N'Primavera'
    END AS temporada_esperada,

    S.fecha_solicitud,

    P.importe_total,

    S.presupuesto_estimado,

    DATEDIFF
    (
        DAY,
        S.fecha_solicitud,
        P.fecha_emision
    ) AS dias_respuesta,

    P.importe_total
    -
    S.presupuesto_estimado
    AS desvio_presupuesto,

    EP.estado,

    Edad.edad_correcta,

    CASE

        WHEN Edad.edad_correcta IS NULL THEN NULL

        WHEN Edad.edad_correcta BETWEEN 26 AND 35
            THEN N'Entre 26 y 35 años inclusive'

        WHEN Edad.edad_correcta BETWEEN 36 AND 50
            THEN N'Entre 36 y 50 años inclusive'

        WHEN Edad.edad_correcta > 50
            THEN N'Mayores de 50 años'

        ELSE NULL

    END
    AS rango_etario_agente_esperado

INTO #PropuestaBase

FROM ESE_CU_ELE.Propuesta P

INNER JOIN ESE_CU_ELE.Solicitud_De_Cotizacion S
ON S.nro_solicitud_id = P.nro_solicitud_id

INNER JOIN ESE_CU_ELE.Agente A
ON A.agente_legajo = P.agente_legajo

INNER JOIN ESE_CU_ELE.Estado_Propuesta EP
ON EP.propuesta_nro = P.propuesta_nro

CROSS APPLY
(
    SELECT

        CASE

            WHEN A.fecha_nacimiento IS NULL
              OR P.fecha_emision IS NULL

            THEN NULL

            ELSE

                DATEDIFF
                (
                    YEAR,
                    A.fecha_nacimiento,
                    P.fecha_emision
                )

                -

                CASE

                    WHEN DATEADD
                    (
                        YEAR,
                        DATEDIFF
                        (
                            YEAR,
                            A.fecha_nacimiento,
                            P.fecha_emision
                        ),
                        A.fecha_nacimiento
                    )

                    >

                    P.fecha_emision

                    THEN 1

                    ELSE 0

                END

        END

        AS edad_correcta

) Edad;

------------------------------------------------------------
-- TEST 0 : CALIDAD DE DATOS DE ORIGEN
------------------------------------------------------------

PRINT 'TEST 0 - Calidad de datos de Propuesta';

SELECT @cnt_esperado = COUNT(*)
FROM ESE_CU_ELE.Propuesta;

SELECT @cnt_actual = COUNT(*)
FROM #PropuestaBase;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 0.1 FAILED: Hay propuestas que no pudieron incorporarse a la base analítica.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 0.1 PASSED: Todas las propuestas quedaron en la base.';

IF EXISTS
(
    SELECT 1
    FROM #PropuestaBase
    WHERE propuesta_nro IS NULL
       OR nro_solicitud_id IS NULL
       OR agente_legajo IS NULL
       OR fecha_emision IS NULL
       OR estado IS NULL
)
BEGIN
    PRINT '❌ TEST 0.2 FAILED: Existen campos obligatorios nulos.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 0.2 PASSED: No existen nulos en campos obligatorios.';

IF EXISTS
(
    SELECT 1
    FROM #PropuestaBase
    WHERE dias_respuesta < 0
)
BEGIN
    PRINT '❌ TEST 0.3 FAILED: Existen propuestas emitidas antes de la solicitud.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 0.3 PASSED: Los días de respuesta son válidos.';

IF EXISTS
(
    SELECT 1
    FROM #PropuestaBase
    WHERE importe_total < 0
)
BEGIN
    PRINT '❌ TEST 0.4 FAILED: Existen importes negativos.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 0.4 PASSED: Todos los importes son válidos.';

------------------------------------------------------------
-- TEST 1 : DIMENSION ESTADO PROPUESTA
------------------------------------------------------------

PRINT 'TEST 1 - Dimension Estado Propuesta';

IF EXISTS
(
    SELECT estado
    FROM ESE_CU_ELE.BI_Dim_Estado_De_Propuesta

    EXCEPT

    SELECT DISTINCT estado
    FROM ESE_CU_ELE.Estado_Propuesta
    WHERE estado IS NOT NULL
)
OR EXISTS
(
    SELECT DISTINCT estado
    FROM ESE_CU_ELE.Estado_Propuesta
    WHERE estado IS NOT NULL

    EXCEPT

    SELECT estado
    FROM ESE_CU_ELE.BI_Dim_Estado_De_Propuesta
)
BEGIN
    PRINT '❌ TEST 1.1 FAILED: Los estados no coinciden con el origen.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 1.1 PASSED: Dominio de estados correcto.';

IF EXISTS
(
    SELECT estado
    FROM ESE_CU_ELE.BI_Dim_Estado_De_Propuesta
    GROUP BY estado
    HAVING COUNT(*) > 1
)
BEGIN
    PRINT '❌ TEST 1.2 FAILED: Existen estados duplicados.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 1.2 PASSED: No existen estados duplicados.';

IF EXISTS
(
    SELECT 1
    FROM ESE_CU_ELE.BI_Dim_Estado_De_Propuesta
    WHERE estado IS NULL
       OR LTRIM(RTRIM(estado))=''
)
BEGIN
    PRINT '❌ TEST 1.3 FAILED: Existen estados nulos o vacíos.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 1.3 PASSED: Todos los estados son válidos.';


------------------------------------------------------------
-- TEST 2 : HECHO PROPUESTA
------------------------------------------------------------

PRINT 'TEST 2 - Hecho Propuesta';

DROP TABLE IF EXISTS #HechoPropuestaEsperado;
DROP TABLE IF EXISTS #HechoPropuestaActual;

SELECT
    Tiempo.tiempo_id,
    Temporada.temporada_id,
    Rango.rango_etario_agente_id,
    EstadoBI.estado_de_propuesta_id AS estado_propuesta,

    COUNT(*) AS cantidad_propuestas,

    SUM
    (
        CASE
            WHEN PB.estado='Aceptada'
            THEN 1
            ELSE 0
        END
    ) AS cantidad_propuestas_aceptadas,

    SUM(PB.importe_total) AS suma_importe_total,

    SUM(PB.dias_respuesta) AS suma_dias_en_responder,

    COUNT(*) AS cantidad_presupuestos,

    SUM(PB.desvio_presupuesto) AS suma_desvio_presupuestos

INTO #HechoPropuestaEsperado

FROM #PropuestaBase PB

INNER JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo
ON Tiempo.anio=PB.anio
AND Tiempo.mes=PB.mes

INNER JOIN ESE_CU_ELE.BI_Dim_Temporada Temporada
ON MONTH(PB.fecha_desde)
BETWEEN Temporada.mes_inicio
AND Temporada.mes_fin

INNER JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Agente Rango
ON PB.edad_correcta
BETWEEN Rango.min_edad
AND Rango.max_edad

INNER JOIN ESE_CU_ELE.BI_Dim_Estado_De_Propuesta EstadoBI
ON EstadoBI.estado=PB.estado

GROUP BY

Tiempo.tiempo_id,
Temporada.temporada_id,
Rango.rango_etario_agente_id,
EstadoBI.estado_de_propuesta_id;


SELECT

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

INTO #HechoPropuestaActual

FROM ESE_CU_ELE.BI_Hecho_Propuesta;


------------------------------------------------------------
-- TEST 2.1
------------------------------------------------------------

IF EXISTS
(
SELECT *
FROM #HechoPropuestaEsperado

EXCEPT

SELECT *
FROM #HechoPropuestaActual
)

OR EXISTS
(

SELECT *
FROM #HechoPropuestaActual

EXCEPT

SELECT *
FROM #HechoPropuestaEsperado

)

BEGIN

PRINT '❌ TEST 2.1 FAILED: El contenido del hecho no coincide.';
SET @errores+=1;

END

ELSE

PRINT '✔ TEST 2.1 PASSED: Contenido correcto.';

------------------------------------------------------------
-- TEST 2.2
------------------------------------------------------------

IF EXISTS
(
SELECT

tiempo_id,
temporada_id,
rango_etario_agente_id,
estado_propuesta

FROM ESE_CU_ELE.BI_Hecho_Propuesta

GROUP BY

tiempo_id,
temporada_id,
rango_etario_agente_id,
estado_propuesta

HAVING COUNT(*)>1
)

BEGIN

PRINT '❌ TEST 2.2 FAILED: Hay duplicados en el grano.';

SET @errores+=1;

END

ELSE

PRINT '✔ TEST 2.2 PASSED: Sin duplicados.';

------------------------------------------------------------
-- TEST 2.3
------------------------------------------------------------

IF EXISTS
(
SELECT 1

FROM ESE_CU_ELE.BI_Hecho_Propuesta

WHERE

tiempo_id IS NULL
OR temporada_id IS NULL
OR rango_etario_agente_id IS NULL
OR estado_propuesta IS NULL

OR cantidad_propuestas IS NULL
OR cantidad_propuestas_aceptadas IS NULL
OR suma_importe_total IS NULL
OR suma_dias_en_responder IS NULL
OR cantidad_presupuestos IS NULL
OR suma_desvio_presupuestos IS NULL
)

BEGIN

PRINT '❌ TEST 2.3 FAILED: Existen nulos en claves o métricas.';
SET @errores+=1;

END

ELSE

PRINT '✔ TEST 2.3 PASSED: Sin nulos.';

------------------------------------------------------------
-- TEST 2.4
------------------------------------------------------------

IF EXISTS
(
SELECT 1

FROM ESE_CU_ELE.BI_Hecho_Propuesta

WHERE

cantidad_propuestas<=0

OR cantidad_presupuestos<=0

OR cantidad_propuestas_aceptadas<0

)

BEGIN

PRINT '❌ TEST 2.4 FAILED: Métricas inválidas.';
SET @errores+=1;

END

ELSE

PRINT '✔ TEST 2.4 PASSED: Métricas válidas.';

------------------------------------------------------------
-- TEST 3 : VISTA 5
-- TASA DE ACEPTACION DE PROPUESTAS
------------------------------------------------------------

PRINT 'TEST 3 - Vista Tasa de Aceptacion de Propuestas';

DROP TABLE IF EXISTS #Vista5Esperada;
DROP TABLE IF EXISTS #Vista5Actual;

SELECT

    Tiempo.cuatrimestre,

    CAST
    (
        SUM(cantidad_propuestas_aceptadas) * 100.0
        /
        SUM(cantidad_propuestas)

        AS DECIMAL(18,2)

    ) AS tasa_aceptacion

INTO #Vista5Esperada

FROM #HechoPropuestaEsperado HP

INNER JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo

ON Tiempo.tiempo_id = HP.tiempo_id

GROUP BY

Tiempo.cuatrimestre;

SELECT

cuatrimestre,

CAST
(
    tasa_aceptacion
    AS DECIMAL(18,2)
)

AS tasa_aceptacion

INTO #Vista5Actual

FROM ESE_CU_ELE.BI_View_Tasa_De_Aceptacion_De_Propuestas;

SELECT @cnt_esperado = COUNT(*)
FROM #Vista5Esperada;

SELECT @cnt_actual = COUNT(*)
FROM #Vista5Actual;

IF @cnt_actual <> @cnt_esperado
BEGIN

    PRINT '❌ TEST 3.1 FAILED: Cantidad de filas incorrecta.';
    SET @errores += 1;

END

ELSE

PRINT '✔ TEST 3.1 PASSED: Cantidad de filas correcta.';

IF EXISTS
(
    SELECT *

    FROM #Vista5Esperada

    EXCEPT

    SELECT *

    FROM #Vista5Actual
)

OR EXISTS
(

    SELECT *

    FROM #Vista5Actual

    EXCEPT

    SELECT *

    FROM #Vista5Esperada

)

BEGIN

PRINT '❌ TEST 3.2 FAILED: El contenido de la Vista 5 no coincide.';

SET @errores += 1;

END

ELSE

PRINT '✔ TEST 3.2 PASSED: Contenido correcto.';

IF EXISTS
(
SELECT cuatrimestre

FROM #Vista5Actual

GROUP BY cuatrimestre

HAVING COUNT(*) > 1
)

BEGIN

PRINT '❌ TEST 3.3 FAILED: Hay duplicados en la Vista 5.';

SET @errores += 1;

END

ELSE

PRINT '✔ TEST 3.3 PASSED: Sin duplicados.';

IF EXISTS
(
SELECT 1

FROM #Vista5Actual

WHERE

cuatrimestre IS NULL

OR tasa_aceptacion IS NULL

OR tasa_aceptacion < 0

OR tasa_aceptacion > 100
)

BEGIN

PRINT '❌ TEST 3.4 FAILED: Valores inválidos en la Vista 5.';

SET @errores += 1;

END

ELSE

PRINT '✔ TEST 3.4 PASSED: Valores correctos.';

------------------------------------------------------------
-- TEST 4 : VISTA 6
-- COTIZACION PROMEDIO POR TEMPORADA
------------------------------------------------------------

PRINT 'TEST 4 - Vista Cotizacion Promedio por Temporada';

DROP TABLE IF EXISTS #Vista6Esperada;
DROP TABLE IF EXISTS #Vista6Actual;

SELECT

    Tiempo.anio,
    Temporada.temporada,

    CAST
    (
        SUM(HP.suma_importe_total) * 1.0
        /
        SUM(HP.cantidad_propuestas)

        AS DECIMAL(18,2)

    ) AS cotizacion_promedio

INTO #Vista6Esperada

FROM #HechoPropuestaEsperado HP

INNER JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo
ON Tiempo.tiempo_id = HP.tiempo_id

INNER JOIN ESE_CU_ELE.BI_Dim_Temporada Temporada
ON Temporada.temporada_id = HP.temporada_id

GROUP BY

Tiempo.anio,
Temporada.temporada;


SELECT

anio,
temporada,

CAST
(
cotizacion_promedio
AS DECIMAL(18,2)

)

AS cotizacion_promedio

INTO #Vista6Actual

FROM ESE_CU_ELE.BI_View_Cotizacion_Promedio_Por_Temporada;


SELECT @cnt_esperado = COUNT(*)
FROM #Vista6Esperada;

SELECT @cnt_actual = COUNT(*)
FROM #Vista6Actual;

IF @cnt_actual <> @cnt_esperado
BEGIN

    PRINT '❌ TEST 4.1 FAILED: Cantidad de filas incorrecta.';
    SET @errores += 1;

END
ELSE

    PRINT '✔ TEST 4.1 PASSED: Cantidad de filas correcta.';


IF EXISTS
(
SELECT *

FROM #Vista6Esperada

EXCEPT

SELECT *

FROM #Vista6Actual

)

OR EXISTS
(

SELECT *

FROM #Vista6Actual

EXCEPT

SELECT *

FROM #Vista6Esperada

)

BEGIN

PRINT '❌ TEST 4.2 FAILED: El contenido de la Vista 6 no coincide.';

SET @errores += 1;

END

ELSE

PRINT '✔ TEST 4.2 PASSED: Contenido correcto.';


IF EXISTS
(
SELECT

anio,
temporada

FROM #Vista6Actual

GROUP BY

anio,
temporada

HAVING COUNT(*) > 1

)

BEGIN

PRINT '❌ TEST 4.3 FAILED: Existen duplicados en la Vista 6.';

SET @errores += 1;

END

ELSE

PRINT '✔ TEST 4.3 PASSED: Sin duplicados.';


IF EXISTS
(
SELECT 1

FROM #Vista6Actual

WHERE

anio IS NULL

OR temporada IS NULL

OR cotizacion_promedio IS NULL

OR cotizacion_promedio < 0

)

BEGIN

PRINT '❌ TEST 4.4 FAILED: Existen valores inválidos en la Vista 6.';

SET @errores += 1;

END

ELSE

PRINT '✔ TEST 4.4 PASSED: Valores válidos.';


------------------------------------------------------------
-- TEST 4.5
------------------------------------------------------------

SELECT @sum_esperado =
(
SELECT CAST(AVG(importe_total) AS DECIMAL(18,2))
FROM #PropuestaBase
);

SELECT @sum_actual =
(
SELECT CAST(AVG(cotizacion_promedio) AS DECIMAL(18,2))
FROM #Vista6Actual
);

IF @sum_actual < 0
BEGIN

PRINT '❌ TEST 4.5 FAILED: La Vista 6 devolvió promedios inválidos.';

SET @errores += 1;

END

ELSE

PRINT '✔ TEST 4.5 PASSED: Promedios válidos.';

------------------------------------------------------------
-- TEST 5 : VISTA 7
-- TIEMPO PROMEDIO DE RESPUESTA
------------------------------------------------------------

PRINT 'TEST 5 - Vista Tiempo Promedio de Respuesta';

DROP TABLE IF EXISTS #Vista7Esperada;
DROP TABLE IF EXISTS #Vista7Actual;

SELECT

    Tiempo.anio,
    Tiempo.mes,
    Rango.rango_etario,

    CAST
    (
        SUM(HP.suma_dias_en_responder) * 1.0
        /
        SUM(HP.cantidad_propuestas)

        AS DECIMAL(18,2)

    ) AS tiempo_promedio_respuesta

INTO #Vista7Esperada

FROM #HechoPropuestaEsperado HP

INNER JOIN ESE_CU_ELE.BI_Dim_Tiempo Tiempo
ON Tiempo.tiempo_id = HP.tiempo_id

INNER JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Agente Rango
ON Rango.rango_etario_agente_id = HP.rango_etario_agente_id

GROUP BY

Tiempo.anio,
Tiempo.mes,
Rango.rango_etario;


SELECT

anio,
mes,
rango_etario,

CAST
(
tiempo_promedio_respuesta
AS DECIMAL(18,2)

)

AS tiempo_promedio_respuesta

INTO #Vista7Actual

FROM ESE_CU_ELE.BI_View_Tiempo_Promedio_De_Respuesta;


------------------------------------------------------------
-- TEST 5.1
------------------------------------------------------------

SELECT @cnt_esperado = COUNT(*)
FROM #Vista7Esperada;

SELECT @cnt_actual = COUNT(*)
FROM #Vista7Actual;

IF @cnt_actual <> @cnt_esperado
BEGIN

    PRINT '❌ TEST 5.1 FAILED: Cantidad de filas incorrecta.';
    SET @errores += 1;

END

ELSE

PRINT '✔ TEST 5.1 PASSED: Cantidad de filas correcta.';


------------------------------------------------------------
-- TEST 5.2
------------------------------------------------------------

IF EXISTS
(
SELECT *

FROM #Vista7Esperada

EXCEPT

SELECT *

FROM #Vista7Actual

)

OR EXISTS
(

SELECT *

FROM #Vista7Actual

EXCEPT

SELECT *

FROM #Vista7Esperada

)

BEGIN

PRINT '❌ TEST 5.2 FAILED: El contenido de la Vista 7 no coincide.';

SET @errores += 1;

END

ELSE

PRINT '✔ TEST 5.2 PASSED: Contenido correcto.';


------------------------------------------------------------
-- TEST 5.3
------------------------------------------------------------

IF EXISTS
(
SELECT

anio,
mes,
rango_etario

FROM #Vista7Actual

GROUP BY

anio,
mes,
rango_etario

HAVING COUNT(*) > 1

)

BEGIN

PRINT '❌ TEST 5.3 FAILED: Existen filas duplicadas.';

SET @errores += 1;

END

ELSE

PRINT '✔ TEST 5.3 PASSED: Sin duplicados.';


------------------------------------------------------------
-- TEST 5.4
------------------------------------------------------------

IF EXISTS
(
SELECT 1

FROM #Vista7Actual

WHERE

anio IS NULL

OR mes IS NULL

OR rango_etario IS NULL

OR tiempo_promedio_respuesta IS NULL

OR tiempo_promedio_respuesta < 0

)

BEGIN

PRINT '❌ TEST 5.4 FAILED: Existen valores inválidos.';

SET @errores += 1;

END

ELSE

PRINT '✔ TEST 5.4 PASSED: Valores válidos.';


------------------------------------------------------------
-- TEST 5.5
------------------------------------------------------------

IF EXISTS
(
SELECT 1

FROM #Vista7Actual

WHERE tiempo_promedio_respuesta > 365

)

BEGIN

PRINT '❌ TEST 5.5 FAILED: Tiempo promedio fuera de rango.';

SET @errores += 1;

END

ELSE

PRINT '✔ TEST 5.5 PASSED: Tiempo promedio consistente.';



------------------------------------------------------------
-- TEST 6 : VISTA 8
-- DESVIO DE PRESUPUESTO
------------------------------------------------------------

PRINT 'TEST 6 - Vista Desvio de Presupuesto';

DROP TABLE IF EXISTS #Vista8Esperada;
DROP TABLE IF EXISTS #Vista8Actual;

SELECT

CAST
(
SUM(suma_desvio_presupuestos)*1.0
/
SUM(cantidad_presupuestos)

AS DECIMAL(18,2)

)

AS desvio_promedio

INTO #Vista8Esperada

FROM #HechoPropuestaEsperado;


SELECT

CAST
(
desvio_promedio
AS DECIMAL(18,2)

)

AS desvio_promedio

INTO #Vista8Actual

FROM ESE_CU_ELE.BI_View_Desvio_De_Presupuesto;


------------------------------------------------------------
-- TEST 6.1
------------------------------------------------------------

SELECT @cnt_esperado=COUNT(*)
FROM #Vista8Esperada;

SELECT @cnt_actual=COUNT(*)
FROM #Vista8Actual;

IF @cnt_actual<>@cnt_esperado
BEGIN

PRINT '❌ TEST 6.1 FAILED';

SET @errores+=1;

END

ELSE

PRINT '✔ TEST 6.1 PASSED';


------------------------------------------------------------
-- TEST 6.2
------------------------------------------------------------

IF EXISTS
(
SELECT *
FROM #Vista8Esperada

EXCEPT

SELECT *
FROM #Vista8Actual
)

OR EXISTS
(
SELECT *
FROM #Vista8Actual

EXCEPT

SELECT *
FROM #Vista8Esperada
)

BEGIN

PRINT '❌ TEST 6.2 FAILED';

SET @errores+=1;

END

ELSE

PRINT '✔ TEST 6.2 PASSED';


------------------------------------------------------------
-- TEST 6.3
------------------------------------------------------------

IF EXISTS
(
SELECT 1
FROM #Vista8Actual
WHERE desvio_promedio IS NULL
)

BEGIN

PRINT '❌ TEST 6.3 FAILED';

SET @errores+=1;

END

ELSE

PRINT '✔ TEST 6.3 PASSED';



------------------------------------------------------------
-- LIMPIEZA
------------------------------------------------------------

DROP TABLE IF EXISTS #Meses;
DROP TABLE IF EXISTS #EdadDomain;

DROP TABLE IF EXISTS #PropuestaBase;

DROP TABLE IF EXISTS #HechoPropuestaEsperado;
DROP TABLE IF EXISTS #HechoPropuestaActual;

DROP TABLE IF EXISTS #Vista5Esperada;
DROP TABLE IF EXISTS #Vista5Actual;

DROP TABLE IF EXISTS #Vista6Esperada;
DROP TABLE IF EXISTS #Vista6Actual;

DROP TABLE IF EXISTS #Vista7Esperada;
DROP TABLE IF EXISTS #Vista7Actual;

DROP TABLE IF EXISTS #Vista8Esperada;
DROP TABLE IF EXISTS #Vista8Actual;


------------------------------------------------------------
-- RESULTADO FINAL
------------------------------------------------------------

PRINT '==========================================';

IF @errores=0

BEGIN

PRINT 'TODOS LOS TESTS PASARON CORRECTAMENTE.';

END

ELSE

BEGIN

PRINT 'SE DETECTARON ' + CAST(@errores AS VARCHAR(10)) + ' ERROR(ES).';

THROW 51000,'FALLARON TESTS DEL MODELO BI.',1;

END

PRINT '==========================================';
GO
