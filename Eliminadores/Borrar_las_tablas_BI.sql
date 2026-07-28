-- Script que borra todas las tablas y todo de nuestra resolucion de la entrega BI del TP
-- Si necesito probar cosas de nuevo, borro todo y listo


-- Uso la base de datos del TP
USE GD1C2026
GO


-- Borro las tablas desde las hojas hasta las raices (primero los Hechos y despues las Dimensiones)
-- Hechos
DROP TABLE ESE_CU_ELE.BI_Hecho_Venta;
DROP TABLE ESE_CU_ELE.BI_Hecho_Solicitud_De_Cotizacion;
DROP TABLE ESE_CU_ELE.BI_Hecho_Encuesta;
DROP TABLE ESE_CU_ELE.BI_Hecho_Propuesta;
--Dimensiones
DROP TABLE ESE_CU_ELE.BI_Dim_Tiempo;
DROP TABLE ESE_CU_ELE.BI_Dim_Temporada;
DROP TABLE ESE_CU_ELE.BI_Dim_Rango_Etario_Cliente;
DROP TABLE ESE_CU_ELE.BI_Dim_Rango_Etario_Agente;
DROP TABLE ESE_CU_ELE.BI_Dim_Estado_De_Propuesta;
DROP TABLE ESE_CU_ELE.BI_Dim_Canal_De_Venta;
DROP TABLE ESE_CU_ELE.BI_Dim_Tipo_Servicio;
DROP TABLE ESE_CU_ELE.BI_Dim_Aspecto;
DROP TABLE ESE_CU_ELE.BI_Dim_Puntaje;


-- Borro las stored procedures de la migracion
DROP PROCEDURE ESE_CU_ELE.BI_carga_hechos;
GO
DROP PROCEDURE ESE_CU_ELE.BI_carga_dimensiones;
GO

-- Borro las vistas

DROP VIEW ESE_CU_ELE.BI_View_Ticket_Promedio;
GO
DROP VIEW ESE_CU_ELE.BI_View_Distribucion_Facturacion;
GO
DROP VIEW ESE_CU_ELE.BI_View_Ranking_De_Solicitudes_Por_Temporada;
GO
DROP VIEW ESE_CU_ELE.BI_View_Anticipacion_Promedio_De_Solicitudes;
GO
DROP VIEW ESE_CU_ELE.BI_View_Tasa_De_Aceptacion_De_Propuestas;
GO
DROP VIEW ESE_CU_ELE.BI_View_Cotizacion_Promedio_Por_Temporada;
GO
DROP VIEW ESE_CU_ELE.BI_View_Tiempo_Promedio_De_Respuesta;
GO
DROP VIEW ESE_CU_ELE.BI_View_Desvio_De_Presupuesto;
GO
DROP VIEW ESE_CU_ELE.BI_View_Promedio_Mensual_Puntaje_Por_Aspecto;
GO
DROP VIEW ESE_CU_ELE.BI_View_Promedio_Satisfaccion_Por_Rango_Etario_Agente;
GO