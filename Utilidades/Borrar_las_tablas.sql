-- Script que borra todas las tablas y todo de nuestra resolucion del TP
-- Si necesito probar cosas de nuevo, borro todo y listo

-- Uso la base de datos del TP
USE GD1C2026
GO

-- Borro los indices
DROP INDEX index_ciudad_paisid ON ESE_CU_ELE.Ciudad;
DROP INDEX index_localidad_provinciaid ON ESE_CU_ELE.Localidad;
DROP INDEX index_cliente_localidad ON ESE_CU_ELE.Cliente;
DROP INDEX index_cliente_dni ON ESE_CU_ELE.Cliente;
DROP INDEX index_agencia_localidad ON ESE_CU_ELE.Agencia;
DROP INDEX index_agente_agencianro ON ESE_CU_ELE.Agente;
DROP INDEX index_agente_localidad ON ESE_CU_ELE.Agente;
DROP INDEX index_solicitudcotizacion_clienteid ON ESE_CU_ELE.Solicitud_De_Cotizacion;
DROP INDEX index_solicitudcotizacion_agentelegajo ON ESE_CU_ELE.Solicitud_De_Cotizacion;
DROP INDEX index_detallesolicitudcotizacion_solicitudcotizacionid ON ESE_CU_ELE.Detalle_Solicitud_De_Cotizacion;
DROP INDEX index_detallesolicitudcotizacion_ciudadid ON ESE_CU_ELE.Detalle_Solicitud_De_Cotizacion;

-- Borro las FK
ALTER TABLE ESE_CU_ELE.Ciudad DROP CONSTRAINT FK_Ciudad_Pais;
ALTER TABLE ESE_CU_ELE.Localidad DROP CONSTRAINT FK_Localidad_Provincia;
ALTER TABLE ESE_CU_ELE.Cliente DROP CONSTRAINT FK_Cliente_Localidad;
ALTER TABLE ESE_CU_ELE.Agencia DROP CONSTRAINT FK_Agencia_Localidad;
ALTER TABLE ESE_CU_ELE.Agente DROP CONSTRAINT FK_Agente_Agencia;
ALTER TABLE ESE_CU_ELE.Agente DROP CONSTRAINT FK_Agente_Localidad;
ALTER TABLE ESE_CU_ELE.Solicitud_De_Cotizacion DROP CONSTRAINT FK_SolicitudCotizacion_Cliente;
ALTER TABLE ESE_CU_ELE.Solicitud_De_Cotizacion DROP CONSTRAINT FK_SolicitudCotizacion_Agente;
ALTER TABLE ESE_CU_ELE.Detalle_Solicitud_De_Cotizacion DROP CONSTRAINT FK_DetalleSolicitudCotizacion_Solicitud_Cotizacion;
GO

-- Borro las tablas
DROP TABLE ESE_CU_ELE.Pais;
DROP TABLE ESE_CU_ELE.Provincia;
DROP TABLE ESE_CU_ELE.Ciudad;
DROP TABLE ESE_CU_ELE.Localidad;
DROP TABLE ESE_CU_ELE.Cliente;
DROP TABLE ESE_CU_ELE.Agencia;
DROP TABLE ESE_CU_ELE.Agente;
DROP TABLE ESE_CU_ELE.Solicitud_De_Cotizacion;
DROP TABLE ESE_CU_ELE.Detalle_Solicitud_De_Cotizacion;
GO

-- Borro la stored procedure de la migracion
DROP PROCEDURE ESE_CU_ELE.migracion;
GO

-- Borro el esquema de nuestro grupo
DROP SCHEMA ESE_CU_ELE;
GO