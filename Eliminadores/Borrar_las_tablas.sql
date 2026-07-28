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
DROP INDEX index_aerolinea_alianzaid ON ESE_CU_ELE.Aerolinea;
DROP INDEX index_aerolinea_paisid ON ESE_CU_ELE.Aerolinea;
DROP INDEX index_aeropuerto_ciudadid ON ESE_CU_ELE.Aeropuerto;
DROP INDEX index_vuelo_aeropuertosalidaid ON ESE_CU_ELE.Vuelo;
DROP INDEX index_vuelo_aeropuertollegadaid ON ESE_CU_ELE.Vuelo;
DROP INDEX index_vuelo_aerolineaid ON ESE_CU_ELE.Vuelo;
DROP INDEX index_ventavuelo_ventaid ON ESE_CU_ELE.Venta_Vuelo;
DROP INDEX index_ventavuelo_vueloid ON ESE_CU_ELE.Venta_Vuelo;
DROP INDEX index_detallepropuestavuelo_propuestanro ON ESE_CU_ELE.Detalle_Propuesta_Vuelo;
DROP INDEX index_detallepropuestavuelo_vueloid ON ESE_CU_ELE.Detalle_Propuesta_Vuelo;
DROP INDEX index_hospedaje_ciudadid ON ESE_CU_ELE.Hospedaje;
DROP INDEX index_habitacion_hospedajeid ON ESE_CU_ELE.Habitacion;
DROP INDEX index_excursion_proveedorid ON ESE_CU_ELE.Excursion;
DROP INDEX index_ventaexcursion_ventanro ON ESE_CU_ELE.Venta_Excursion;
DROP INDEX index_ventaexcursion_excursionid ON ESE_CU_ELE.Venta_Excursion;
DROP INDEX index_ventahospedaje_ventanro ON ESE_CU_ELE.Venta_Hospedaje;
DROP INDEX index_ventahospedaje_habitacionid ON ESE_CU_ELE.Venta_Hospedaje;
DROP INDEX index_propuesta_solicitudid ON ESE_CU_ELE.Propuesta;
DROP INDEX index_propuesta_agentelegajo ON ESE_CU_ELE.Propuesta;
DROP INDEX index_estadopropuesta_propuestanro ON ESE_CU_ELE.Estado_Propuesta;
DROP INDEX index_venta_agencianro ON ESE_CU_ELE.Venta;
DROP INDEX index_venta_agentelegajo ON ESE_CU_ELE.Venta;
DROP INDEX index_venta_clienteid ON ESE_CU_ELE.Venta;
DROP INDEX index_venta_canalventaid ON ESE_CU_ELE.Venta;
DROP INDEX index_venta_mediodepagoid ON ESE_CU_ELE.Venta;
DROP INDEX index_ventapropuesta_ventanro ON ESE_CU_ELE.Venta_Propuesta;
DROP INDEX index_encuesta_clienteid ON ESE_CU_ELE.Encuesta;
DROP INDEX index_encuesta_agentelegajo ON ESE_CU_ELE.Encuesta;
DROP INDEX index_detalleencuestapuntaje_encuestaid ON ESE_CU_ELE.Detalle_Encuesta_Puntaje;


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
ALTER TABLE ESE_CU_ELE.Aerolinea DROP CONSTRAINT FK_Aerolinea_Alianza;
ALTER TABLE ESE_CU_ELE.Aerolinea DROP CONSTRAINT FK_Aerolinea_Pais;
ALTER TABLE ESE_CU_ELE.Aeropuerto DROP CONSTRAINT FK_Aeropuerto_Ciudad;
ALTER TABLE ESE_CU_ELE.Vuelo DROP CONSTRAINT FK_Vuelo_AeropuertoSalida;
ALTER TABLE ESE_CU_ELE.Vuelo DROP CONSTRAINT FK_Vuelo_AeropuertoLlegada;
ALTER TABLE ESE_CU_ELE.Vuelo DROP CONSTRAINT FK_Vuelo_Aerolinea;
ALTER TABLE ESE_CU_ELE.Vuelo_Beneficio DROP CONSTRAINT FK_VueloBeneficio_Vuelo;
ALTER TABLE ESE_CU_ELE.Vuelo_Beneficio DROP CONSTRAINT FK_VueloBeneficio_Beneficio;
ALTER TABLE ESE_CU_ELE.Detalle_Propuesta_Vuelo DROP CONSTRAINT FK_DetallePropuestaVuelo_Propuesta;
ALTER TABLE ESE_CU_ELE.Detalle_Propuesta_Vuelo DROP CONSTRAINT FK_DetallePropuestaVuelo_Vuelo;
ALTER TABLE ESE_CU_ELE.Venta_Vuelo DROP CONSTRAINT FK_VentaVuelo_Venta;
ALTER TABLE ESE_CU_ELE.Venta_Vuelo DROP CONSTRAINT FK_VentaVuelo_Vuelo;
ALTER TABLE ESE_CU_ELE.Hospedaje DROP CONSTRAINT FK_Hospedaje_Ciudad;
ALTER TABLE ESE_CU_ELE.Habitacion DROP CONSTRAINT FK_Habitacion_Hospedaje;
ALTER TABLE ESE_CU_ELE.Hospedaje_Beneficio DROP CONSTRAINT FK_HospedajeBeneficio_Hospedaje;
ALTER TABLE ESE_CU_ELE.Hospedaje_Beneficio DROP CONSTRAINT FK_HospedajeBeneficio_Beneficio;
ALTER TABLE ESE_CU_ELE.Excursion DROP CONSTRAINT FK_Excursion_Proveedor;
ALTER TABLE ESE_CU_ELE.Venta_Excursion DROP CONSTRAINT FK_VentaExcursion_Venta;
ALTER TABLE ESE_CU_ELE.Venta_Excursion DROP CONSTRAINT FK_VentaExcursion_Excursion;
ALTER TABLE ESE_CU_ELE.Venta_Hospedaje DROP CONSTRAINT FK_VentaHospedaje_Venta;
ALTER TABLE ESE_CU_ELE.Venta_Hospedaje DROP CONSTRAINT FK_VentaHospedaje_Habitacion;
ALTER TABLE ESE_CU_ELE.Detalle_Propuesta_Hospedaje DROP CONSTRAINT FK_DetallePropuestaHospedaje_Propuesta;
ALTER TABLE ESE_CU_ELE.Detalle_Propuesta_Hospedaje DROP CONSTRAINT FK_DetallePropuestaHospedaje_Habitacion;
ALTER TABLE ESE_CU_ELE.Estado_Propuesta DROP CONSTRAINT FK_EstadoPropuesta_Propuesta;
ALTER TABLE ESE_CU_ELE.Propuesta DROP CONSTRAINT FK_Propuesta_Solicitud;
ALTER TABLE ESE_CU_ELE.Propuesta DROP CONSTRAINT FK_Propuesta_Agente;
ALTER TABLE ESE_CU_ELE.Venta DROP CONSTRAINT FK_Venta_Agencia;
ALTER TABLE ESE_CU_ELE.Venta DROP CONSTRAINT FK_Venta_Agente;
ALTER TABLE ESE_CU_ELE.Venta DROP CONSTRAINT FK_Venta_Cliente;
ALTER TABLE ESE_CU_ELE.Venta DROP CONSTRAINT FK_Venta_Canal;
ALTER TABLE ESE_CU_ELE.Venta DROP CONSTRAINT FK_Venta_MedioPago;
ALTER TABLE ESE_CU_ELE.Venta_Propuesta DROP CONSTRAINT FK_VentaPropuesta_Propuesta;
ALTER TABLE ESE_CU_ELE.Venta_Propuesta DROP CONSTRAINT FK_VentaPropuesta_Venta;
ALTER TABLE ESE_CU_ELE.Encuesta DROP CONSTRAINT FK_Encuesta_Cliente;
ALTER TABLE ESE_CU_ELE.Encuesta DROP CONSTRAINT FK_Encuesta_Agente;
ALTER TABLE ESE_CU_ELE.Detalle_Encuesta_Puntaje DROP CONSTRAINT FK_DetalleEncuesta_Aspecto;
ALTER TABLE ESE_CU_ELE.Detalle_Encuesta_Puntaje DROP CONSTRAINT FK_DetalleEncuesta_Encuesta;
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
DROP TABLE ESE_CU_ELE.Canal_De_Venta;
DROP TABLE ESE_CU_ELE.Medio_De_Pago;
DROP TABLE ESE_CU_ELE.Aspecto;
DROP TABLE ESE_CU_ELE.Estado_Propuesta;
DROP TABLE ESE_CU_ELE.Propuesta;
DROP TABLE ESE_CU_ELE.Venta;
DROP TABLE ESE_CU_ELE.Venta_Propuesta;
DROP TABLE ESE_CU_ELE.Encuesta;
DROP TABLE ESE_CU_ELE.Detalle_Encuesta_Puntaje;
DROP TABLE ESE_CU_ELE.Alianza;
DROP TABLE ESE_CU_ELE.Aerolinea;
DROP TABLE ESE_CU_ELE.Aeropuerto;
DROP TABLE ESE_CU_ELE.Beneficio_Vuelo;
DROP TABLE ESE_CU_ELE.Vuelo;
DROP TABLE ESE_CU_ELE.Vuelo_Beneficio;
DROP TABLE ESE_CU_ELE.Detalle_Propuesta_Vuelo;
DROP TABLE ESE_CU_ELE.Venta_Vuelo;
DROP TABLE ESE_CU_ELE.Hospedaje;
DROP TABLE ESE_CU_ELE.Habitacion;
DROP TABLE ESE_CU_ELE.Beneficio_Hospedaje;
DROP TABLE ESE_CU_ELE.Hospedaje_Beneficio;
DROP TABLE ESE_CU_ELE.Proveedor_Excursion;
DROP TABLE ESE_CU_ELE.Excursion;
DROP TABLE ESE_CU_ELE.Venta_Excursion;
DROP TABLE ESE_CU_ELE.Venta_Hospedaje;
DROP TABLE ESE_CU_ELE.Detalle_Propuesta_Hospedaje;
GO


-- Borro la stored procedure de la migracion
DROP PROCEDURE ESE_CU_ELE.migracion;
GO


-- Borro el esquema de nuestro grupo
DROP SCHEMA ESE_CU_ELE;
GO