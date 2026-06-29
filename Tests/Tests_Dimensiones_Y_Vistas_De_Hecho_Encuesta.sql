SET NOCOUNT ON;

PRINT '====================================';
PRINT 'BI AUDITOR TP - VERTICAL ENCUESTAS';
PRINT '====================================';

DECLARE @errores INT = 0;
DECLARE @cnt_esperado BIGINT;
DECLARE @cnt_actual BIGINT;
DECLARE @sum_esperado DECIMAL(38, 3);
DECLARE @sum_actual DECIMAL(38, 3);
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
-- BASE DE ENCUESTAS (ORIGEN)
------------------------------------------------------------
DROP TABLE IF EXISTS #EncuestaBase;

SELECT
    D.encuesta_id,
    D.aspecto_id,
    D.puntaje,
    A.nombre AS aspecto_nombre,
    E.fecha AS fecha_encuesta,
    YEAR(E.fecha) AS anio,
    MONTH(E.fecha) AS mes,
    Ag.agente_legajo,
    Edad.edad_correcta,
    CASE
        WHEN Edad.edad_correcta IS NULL THEN NULL
        WHEN Edad.edad_correcta BETWEEN 26 AND 35 THEN N'Entre 26 y 35 años inclusive'
        WHEN Edad.edad_correcta BETWEEN 36 AND 50 THEN N'Entre 36 y 50 años inclusive'
        WHEN Edad.edad_correcta > 50 THEN N'Mayores de 50 años'
        ELSE NULL -- Los menores de 26 no están contemplados en la dimensión adoptada
    END AS rango_etario_agente_esperado
INTO #EncuestaBase
FROM ESE_CU_ELE.Detalle_Encuesta_Puntaje AS D
INNER JOIN ESE_CU_ELE.Encuesta AS E
    ON E.encuesta_id = D.encuesta_id
INNER JOIN ESE_CU_ELE.Venta AS V
    ON V.venta_nro = E.venta_nro
INNER JOIN ESE_CU_ELE.Agente AS Ag
    ON Ag.agente_legajo = V.agente_legajo
INNER JOIN ESE_CU_ELE.Aspecto AS A
    ON A.aspecto_id = D.aspecto_id
CROSS APPLY
(
    SELECT
        CASE
            WHEN Ag.fecha_nacimiento IS NULL OR E.fecha IS NULL THEN NULL
            ELSE
                DATEDIFF(YEAR, Ag.fecha_nacimiento, E.fecha)
                - CASE
                    WHEN DATEADD(
                            YEAR,
                            DATEDIFF(YEAR, Ag.fecha_nacimiento, E.fecha),
                            Ag.fecha_nacimiento
                        ) > E.fecha
                    THEN 1
                    ELSE 0
                  END
        END AS edad_correcta
) AS Edad;

------------------------------------------------------------
-- TEST 0: CALIDAD DE DATOS DE ORIGEN
------------------------------------------------------------
PRINT 'TEST 0 - Calidad de datos de Encuestas';

SELECT @cnt_esperado = COUNT(*)
FROM ESE_CU_ELE.Detalle_Encuesta_Puntaje;

SELECT @cnt_actual = COUNT(*)
FROM #EncuestaBase;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 0.1 FAILED: Hay detalles de encuestas que no pudieron incorporarse a la base analítica.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 0.1 PASSED: Todos los detalles de encuestas mapearon a la base.';

IF EXISTS
(
    SELECT 1
    FROM #EncuestaBase
    WHERE encuesta_id IS NULL
       OR puntaje IS NULL
       OR aspecto_nombre IS NULL
       OR fecha_encuesta IS NULL
       OR edad_correcta IS NULL
)
BEGIN
    PRINT '❌ TEST 0.2 FAILED: Existen campos nulos en datos clave de origen.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 0.2 PASSED: No hay nulos en campos clave de encuestas.';

IF EXISTS
(
    SELECT 1
    FROM #EncuestaBase
    WHERE puntaje < 1 OR puntaje > 10
)
BEGIN
    PRINT '❌ TEST 0.3 FAILED: Existen encuestas con puntajes fuera del rango 1-10.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 0.3 PASSED: Todos los puntajes están en el dominio correcto.';

------------------------------------------------------------
-- TEST 1: DIMENSIÓN PUNTAJE
------------------------------------------------------------
PRINT 'TEST 1 - Dimensión Puntaje';

SELECT @cnt_esperado = 10;
SELECT @cnt_actual = COUNT(*)
FROM ESE_CU_ELE.BI_Dim_Puntaje;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 1.1 FAILED: BI_Dim_Puntaje debe tener exactamente 10 filas.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 1.1 PASSED: Cantidad de puntajes correcta.';

IF EXISTS
(
    SELECT puntaje
    FROM ESE_CU_ELE.BI_Dim_Puntaje
    EXCEPT
    SELECT *
    FROM (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10)) V(puntaje)
)
BEGIN
    PRINT '❌ TEST 1.2 FAILED: BI_Dim_Puntaje tiene valores inesperados.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 1.2 PASSED: Dominio de puntajes exacto.';

------------------------------------------------------------
-- TEST 2: DIMENSIÓN ASPECTO
------------------------------------------------------------
PRINT 'TEST 2 - Dimensión Aspecto';

SELECT @cnt_esperado = COUNT(DISTINCT nombre)
FROM ESE_CU_ELE.Aspecto
WHERE nombre IS NOT NULL;

SELECT @cnt_actual = COUNT(*)
FROM ESE_CU_ELE.BI_Dim_Aspecto;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 2.1 FAILED: La cantidad de aspectos en BI no coincide con la tabla transaccional.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 2.1 PASSED: Cantidad de aspectos correcta.';

IF EXISTS
(
    SELECT aspecto FROM ESE_CU_ELE.BI_Dim_Aspecto
    EXCEPT
    SELECT nombre FROM ESE_CU_ELE.Aspecto WHERE nombre IS NOT NULL
)
BEGIN
    PRINT '❌ TEST 2.2 FAILED: Existen aspectos en BI_Dim_Aspecto que no están en el origen.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 2.2 PASSED: Nomenclatura de aspectos exacta.';

------------------------------------------------------------
-- TEST 3: HECHO ENCUESTA
------------------------------------------------------------
PRINT 'TEST 3 - Hecho Encuesta';

DROP TABLE IF EXISTS #HechoEncuestaEsperado;
DROP TABLE IF EXISTS #HechoEncuestaActual;

SELECT
    T.tiempo_id,
    R.rango_etario_agente_id,
    P.puntaje_id,
    A.aspecto_id,
    COUNT(EB.encuesta_id) AS cantidad_encuestas,
    SUM(EB.puntaje) AS suma_puntaje
INTO #HechoEncuestaEsperado
FROM #EncuestaBase AS EB
INNER JOIN ESE_CU_ELE.BI_Dim_Tiempo AS T
    ON T.anio = EB.anio
   AND T.mes = EB.mes
INNER JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Agente AS R
    ON EB.edad_correcta BETWEEN R.min_edad AND R.max_edad
INNER JOIN ESE_CU_ELE.BI_Dim_Puntaje AS P
    ON P.puntaje = EB.puntaje
INNER JOIN ESE_CU_ELE.BI_Dim_Aspecto AS A
    ON A.aspecto = EB.aspecto_nombre
GROUP BY
    T.tiempo_id,
    R.rango_etario_agente_id,
    P.puntaje_id,
    A.aspecto_id;

SELECT
    tiempo_id,
    rango_etario_agente_id,
    puntaje_id,
    aspecto_id,
    cantidad_encuestas,
    suma_puntaje
INTO #HechoEncuestaActual
FROM ESE_CU_ELE.BI_Hecho_Encuesta;

SELECT @cnt_esperado = COUNT(*) FROM #HechoEncuestaEsperado;
SELECT @cnt_actual   = COUNT(*) FROM #HechoEncuestaActual;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 3.1 FAILED: La cantidad de filas del hecho Encuesta no coincide con lo esperado.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 3.1 PASSED: Cantidad de filas del hecho correcta.';

IF EXISTS
(
    SELECT * FROM #HechoEncuestaEsperado
    EXCEPT
    SELECT * FROM #HechoEncuestaActual
)
OR EXISTS
(
    SELECT * FROM #HechoEncuestaActual
    EXCEPT
    SELECT * FROM #HechoEncuestaEsperado
)
BEGIN
    PRINT '❌ TEST 3.2 FAILED: El contenido y/o métricas del hecho no coinciden con la expectativa.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 3.2 PASSED: Contenido y métricas del hecho correctas.';

IF EXISTS
(
    SELECT tiempo_id, rango_etario_agente_id, puntaje_id, aspecto_id
    FROM ESE_CU_ELE.BI_Hecho_Encuesta
    GROUP BY tiempo_id, rango_etario_agente_id, puntaje_id, aspecto_id
    HAVING COUNT(*) > 1
)
BEGIN
    PRINT '❌ TEST 3.3 FAILED: Hay duplicados en el grano del hecho.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 3.3 PASSED: Grano del hecho sin duplicados.';

IF EXISTS
(
    SELECT 1
    FROM ESE_CU_ELE.BI_Hecho_Encuesta
    WHERE tiempo_id IS NULL
       OR rango_etario_agente_id IS NULL
       OR puntaje_id IS NULL
       OR aspecto_id IS NULL
       OR cantidad_encuestas IS NULL
       OR suma_puntaje IS NULL
)
BEGIN
    PRINT '❌ TEST 3.4 FAILED: El hecho tiene nulos en claves o métricas.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 3.4 PASSED: Sin nulos en claves o métricas.';

------------------------------------------------------------
-- TEST 4: VISTA 9 - PROMEDIO MENSUAL DE PUNTAJE POR ASPECTO
------------------------------------------------------------
PRINT 'TEST 4 - Vista 9 (Promedio Mensual de Puntaje por Aspecto)';

DROP TABLE IF EXISTS #Vista9Esperada;
DROP TABLE IF EXISTS #Vista9Actual;

SELECT
    T.anio AS año,
    T.mes,
    A.aspecto,
    CAST(SUM(HE.suma_puntaje) * 1.0 / SUM(HE.cantidad_encuestas) AS DECIMAL(18,2)) AS promedio_puntaje
INTO #Vista9Esperada
FROM #HechoEncuestaEsperado AS HE
INNER JOIN ESE_CU_ELE.BI_Dim_Tiempo AS T
    ON T.tiempo_id = HE.tiempo_id
INNER JOIN ESE_CU_ELE.BI_Dim_Aspecto AS A
    ON A.aspecto_id = HE.aspecto_id
GROUP BY T.anio, T.mes, A.aspecto;

DECLARE @colAnioVista9 SYSNAME;

SELECT @colAnioVista9 =
    CASE
        WHEN EXISTS
        (
            SELECT 1 FROM sys.columns c INNER JOIN sys.objects o ON o.object_id = c.object_id
            WHERE o.type = 'V' AND o.name = 'BI_View_Promedio_Mensual_Puntaje_Por_Aspecto' AND c.name = 'anio'
        ) THEN N'anio'
        WHEN EXISTS
        (
            SELECT 1 FROM sys.columns c INNER JOIN sys.objects o ON o.object_id = c.object_id
            WHERE o.type = 'V' AND o.name = 'BI_View_Promedio_Mensual_Puntaje_Por_Aspecto' AND c.name = N'año'
        ) THEN N'año'
        ELSE NULL
    END;

IF @colAnioVista9 IS NULL
BEGIN
    PRINT '❌ TEST 4.0 FAILED: No se encontró una columna de año válida en la Vista 9.';
    SET @errores += 1;
END
ELSE
BEGIN
CREATE TABLE #Vista9Actual
    (
        año INT,
        mes TINYINT,
        aspecto NVARCHAR(255),
        promedio_puntaje DECIMAL(18,2)
    );

    DECLARE @sqlVista9 NVARCHAR(MAX) =
        N'INSERT INTO #Vista9Actual (año, mes, aspecto, promedio_puntaje)
          SELECT
              ' + QUOTENAME(@colAnioVista9) + N' AS año,
              mes,
              aspecto,
              CAST(promedio_puntaje AS DECIMAL(18,2))
          FROM ESE_CU_ELE.BI_View_Promedio_Mensual_Puntaje_Por_Aspecto;';
    EXEC sys.sp_executesql @sqlVista9;

    SELECT @cnt_esperado = COUNT(*) FROM #Vista9Esperada;
    SELECT @cnt_actual   = COUNT(*) FROM #Vista9Actual;

    IF @cnt_actual <> @cnt_esperado
    BEGIN
        PRINT '❌ TEST 4.1 FAILED: La Vista 9 no tiene la cantidad de filas esperada.';
        SET @errores += 1;
    END
    ELSE
        PRINT '✔ TEST 4.1 PASSED: Cantidad de filas de la Vista 9 correcta.';

    IF EXISTS (SELECT * FROM #Vista9Esperada EXCEPT SELECT * FROM #Vista9Actual)
    OR EXISTS (SELECT * FROM #Vista9Actual EXCEPT SELECT * FROM #Vista9Esperada)
    BEGIN
        PRINT '❌ TEST 4.2 FAILED: La Vista 9 no coincide con el cruce analítico esperado.';
        SET @errores += 1;
    END
    ELSE
        PRINT '✔ TEST 4.2 PASSED: Contenido de la Vista 9 correcto.';

    IF EXISTS
    (
        SELECT año, mes, aspecto
        FROM #Vista9Actual
        GROUP BY año, mes, aspecto
        HAVING COUNT(*) > 1
    )
    BEGIN
        PRINT '❌ TEST 4.3 FAILED: La Vista 9 tiene duplicados en su grano (año, mes, aspecto).';
        SET @errores += 1;
    END
    ELSE
        PRINT '✔ TEST 4.3 PASSED: Vista 9 sin duplicados en el grano.';
END

------------------------------------------------------------
-- TEST 5: VISTA 10 - PROMEDIO DE SATISFACCION POR RANGO ETARIO AGENTE
------------------------------------------------------------
PRINT 'TEST 5 - Vista 10 (Promedio Satisfacción por Rango Etario Agente)';

DROP TABLE IF EXISTS #Vista10Esperada;
DROP TABLE IF EXISTS #Vista10Actual;

SELECT
    R.rango_etario AS rango_etario_agente,
    CAST(SUM(HE.suma_puntaje) * 1.0 / SUM(HE.cantidad_encuestas) AS DECIMAL(18,2)) AS promedio_satisfaccion
INTO #Vista10Esperada
FROM #HechoEncuestaEsperado AS HE
INNER JOIN ESE_CU_ELE.BI_Dim_Rango_Etario_Agente AS R
    ON R.rango_etario_agente_id = HE.rango_etario_agente_id
GROUP BY R.rango_etario;

SELECT
    rango_etario_agente,
    CAST(promedio_satisfaccion AS DECIMAL(18,2)) AS promedio_satisfaccion
INTO #Vista10Actual
FROM ESE_CU_ELE.BI_View_Promedio_Satisfaccion_Por_Rango_Etario_Agente;

SELECT @cnt_esperado = COUNT(*) FROM #Vista10Esperada;
SELECT @cnt_actual   = COUNT(*) FROM #Vista10Actual;

IF @cnt_actual <> @cnt_esperado
BEGIN
    PRINT '❌ TEST 5.1 FAILED: La Vista 10 no tiene la cantidad de filas esperada.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 5.1 PASSED: Cantidad de filas de la Vista 10 correcta.';

IF EXISTS (SELECT * FROM #Vista10Esperada EXCEPT SELECT * FROM #Vista10Actual)
OR EXISTS (SELECT * FROM #Vista10Actual EXCEPT SELECT * FROM #Vista10Esperada)
BEGIN
    PRINT '❌ TEST 5.2 FAILED: La Vista 10 no coincide con el cruce analítico esperado.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 5.2 PASSED: Contenido de la Vista 10 correcto.';

IF EXISTS
(
    SELECT 1
    FROM #Vista10Actual
    WHERE rango_etario_agente IS NULL OR promedio_satisfaccion IS NULL
)
BEGIN
    PRINT '❌ TEST 5.3 FAILED: La Vista 10 tiene rangos o promedios nulos.';
    SET @errores += 1;
END
ELSE
    PRINT '✔ TEST 5.3 PASSED: Valores de la Vista 10 válidos.';

------------------------------------------------------------
-- VALIDACIÓN FINAL
------------------------------------------------------------
PRINT '====================================';

IF @errores = 0
BEGIN
    PRINT '🎉 TODOS LOS TESTS DE LA VERTICAL ENCUESTAS PASARON CORRECTAMENTE';
    PRINT '====================================';
END
ELSE
BEGIN
    PRINT '⚠ SE DETECTARON ERRORES EN EL MODELO BI (ENCUESTAS)';
    PRINT '====================================';
    SET @msg = CONCAT(N'Se detectaron ', @errores, N' error(es) en el test suite de encuestas.');
    THROW 50000, @msg, 1;
END