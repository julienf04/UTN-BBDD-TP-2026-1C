------------------ DIVISION DEL SCRIPT (las lineas son aproximadas) ------------------

-- CREACION DEL ESQUEMA (linea 41)

-- CREACION DE LAS TABLAS CON SUS CONSTRAINS (EXCEPTO LAS FK) (linea 89)
------ ZONA DE TRABAJO DEL VERDE (linea 92)
------ ZONA DE TRABAJO DEL ROJO (linea 592)
------ ZONA DE TRABAJO DEL AZUL (linea 1093)
------ ZONA DE TRABAJO DEL AMARILLO (linea 1593)

-- CREACION DE LAS FK DE LAS TABLAS (linea 1990)
------ ZONA DE TRABAJO DEL VERDE (linea 2082)
------ ZONA DE TRABAJO DEL ROJO (linea 2582)
------ ZONA DE TRABAJO DEL AZUL (linea 3083)
------ ZONA DE TRABAJO DEL AMARILLO (linea 3547)

-- CREACION DE TRIGGERS SOBRE LAS TABLAS (linea 4070)
------ ZONA DE TRABAJO DEL VERDE (linea 4073)
------ ZONA DE TRABAJO DEL ROJO (linea 4573)
------ ZONA DE TRABAJO DEL AZUL (linea 5074)
------ ZONA DE TRABAJO DEL AMARILLO (linea 5574)

-- MIGRACION DE LOS DATOS (linea 6061)
------ ZONA DE TRABAJO DEL VERDE (linea 6069)
------ ZONA DE TRABAJO DEL ROJO (linea 6569)
------ ZONA DE TRABAJO DEL AZUL (linea 7070)
------ ZONA DE TRABAJO DEL AMARILLO (linea 7570)

-- CREACION DE INDICES (linea 8065)
------ ZONA DE TRABAJO DEL VERDE (linea 8068)
------ ZONA DE TRABAJO DEL ROJO (linea 8568)
------ ZONA DE TRABAJO DEL AZUL (linea 9069)
------ ZONA DE TRABAJO DEL AMARILLO (linea 9569)



-- ZONA DE TRABAJO GLOBAL INICIAL


----------------------------------------------
-- CREACION DEL ESQUEMA
----------------------------------------------

CREATE SCHEMA ESE_CU_ELE;
GO
PRINT(N'Esquema ESE_CU_ELE creado');

----------------------------------------------
-- CREACION DE LAS TABLAS CON SUS CONSTRAINS (EXCEPTO LAS FK)
----------------------------------------------

-- ZONA DE TRABAJO DEL VERDE

--------------- Pais ---------------

CREATE TABLE ESE_CU_ELE.Pais (
    pais_id BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre nvarchar(255) UNIQUE
);

--------------- Provincia ---------------

CREATE TABLE ESE_CU_ELE.Provincia (
    provincia_id BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre nvarchar(255) UNIQUE
);

--------------- Ciudad ---------------

CREATE TABLE ESE_CU_ELE.Ciudad (
    ciudad_id BIGINT PRIMARY KEY IDENTITY(1,1),
    pais_id BIGINT, -- FK
    nombre nvarchar(255),
    CONSTRAINT unique_ciudad_nombre_paisid UNIQUE(pais_id, nombre)
);

--------------- Localidad ---------------

CREATE TABLE ESE_CU_ELE.Localidad (
    localidad_id BIGINT PRIMARY KEY IDENTITY(1,1),
    provincia_id BIGINT, -- FK
    nombre nvarchar(255),
    CONSTRAINT unique_localidad_nombre_provinciaid UNIQUE(provincia_id, nombre)
);

--------------- Cliente ---------------

CREATE TABLE ESE_CU_ELE.Cliente (
    cliente_id BIGINT PRIMARY KEY IDENTITY(1,1),
    localidad BIGINT, -- FK
    nombre nvarchar(255),
    apellido nvarchar(255),
    dni nvarchar(255),
    telefono nvarchar(255),
    mail nvarchar(255),
    direccion nvarchar(255),
    fecha_nacimiento DATE
);

--------------- Agencia ---------------

CREATE TABLE ESE_CU_ELE.Agencia (
    agencia_nro BIGINT PRIMARY KEY,
    localidad BIGINT, -- FK
    direccion nvarchar(255),
    telefono nvarchar(255),
    mail nvarchar(255)
);

--------------- Agente ---------------

CREATE TABLE ESE_CU_ELE.Agente (
    agente_legajo BIGINT PRIMARY KEY,
    agencia_nro BIGINT, -- FK
    localidad BIGINT, -- FK
    nombre nvarchar(255),
    apellido nvarchar(255),
    direccion nvarchar(255),
    dni nvarchar(255),
    telefono nvarchar(255),
    mail nvarchar(255),
    fecha_nacimiento DATE
);

--------------- Solicitud_De_Cotizacion ---------------

CREATE TABLE ESE_CU_ELE.Solicitud_De_Cotizacion (
    nro_solicitud_id BIGINT PRIMARY KEY,
    cliente_id BIGINT, -- FK
    agente_legajo BIGINT, -- FK
    fecha_solicitud DATE,
    fecha_inicio_tentativa DATE,
    fecha_fin_tentativa DATE, 
    cantidad_pasajeros INT,
    observaciones nvarchar(max),
    presupuesto_estimado decimal(18,2)
);

--------------- Detalle_Solicitud_De_Cotizacion ---------------

CREATE TABLE ESE_CU_ELE.Detalle_Solicitud_De_Cotizacion (
    detalle_solicitud_cotizacion_id BIGINT PRIMARY KEY IDENTITY(1,1),
    solicitud_cotizacion_id BIGINT, -- FK
    ciudad_id BIGINT, -- FK
    cant_dias_aprox INT,
    observaciones nvarchar(max)
);



-- ZONA DE TRABAJO DEL ROJO


--------------- Canal_De_Venta ---------------
CREATE TABLE ESE_CU_ELE.Canal_De_Venta (
    canal_venta_id BIGINT PRIMARY KEY IDENTITY(1,1),
    canal nvarchar(255) UNIQUE
);

--------------- Medio_De_Pago ---------------
CREATE TABLE ESE_CU_ELE.Medio_De_Pago (
    medio_de_pago_id BIGINT PRIMARY KEY IDENTITY(1,1),
    descripcion nvarchar(255) UNIQUE
);

--------------- Aspecto ---------------
CREATE TABLE ESE_CU_ELE.Aspecto (
    aspecto_id BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre nvarchar(255) UNIQUE
);

--------------- Propuesta ---------------
CREATE TABLE ESE_CU_ELE.Propuesta (
    propuesta_nro BIGINT PRIMARY KEY,
    nro_solicitud_id BIGINT, -- FK hacia Solicitud_De_Cotizacion
    agente_legajo BIGINT,    -- FK hacia Agente
    fecha_emision DATE,
    fecha_vigencia_hasta DATE,
    fecha_desde DATE,
    fecha_hasta DATE,
    descuento decimal(18,2),
    importe_total decimal(18,2),
    estado nvarchar(255)
);

--------------- Venta ---------------
CREATE TABLE ESE_CU_ELE.Venta (
    venta_nro BIGINT PRIMARY KEY,
    agencia_nro BIGINT,         -- FK hacia Agencia
    agente_legajo BIGINT,       -- FK hacia Agente
    cliente_id BIGINT,          -- FK hacia Cliente
    canal_venta_id BIGINT,      -- FK hacia Canal_De_Venta
    medio_de_pago_id BIGINT,    -- FK hacia Medio_De_Pago
    descuento decimal(18,2),
    importe_total decimal(18,2),
    fecha DATE
);

--------------- Venta_Propuesta ---------------
CREATE TABLE ESE_CU_ELE.Venta_Propuesta (
    propuesta_nro BIGINT, -- FK
    venta_nro BIGINT,     -- FK
    CONSTRAINT PK_Venta_Propuesta PRIMARY KEY (propuesta_nro, venta_nro)
);

--------------- Encuesta ---------------
CREATE TABLE ESE_CU_ELE.Encuesta (
    encuesta_id BIGINT PRIMARY KEY, -- Guardamos el código original directo de la Maestra
    venta_nro BIGINT,     -- FK hacia Venta
    propuesta_nro BIGINT, -- FK hacia Propuesta
    fecha DATE,
    comentario nvarchar(max)
);

--------------- Detalle_Encuesta_Puntaje ---------------
CREATE TABLE ESE_CU_ELE.Detalle_Encuesta_Puntaje (
    aspecto_id BIGINT,  -- FK
    encuesta_id BIGINT, -- FK
    puntaje INT,
    CONSTRAINT PK_Detalle_Encuesta_Puntaje PRIMARY KEY (aspecto_id, encuesta_id)
);


-- ZONA DE TRABAJO DEL AZUL

--------------- Alianza ---------------

CREATE TABLE ESE_CU_ELE.Alianza (
    alianza_id BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre nvarchar(255) UNIQUE
);

--------------- Aerolinea ---------------

CREATE TABLE ESE_CU_ELE.Aerolinea (
    aerolinea_id BIGINT PRIMARY KEY IDENTITY(1,1),
    alianza_id BIGINT, -- FK
    pais_id BIGINT, -- FK
    nombre nvarchar(255),
    codigo nvarchar(10),
    CONSTRAINT unique_aerolinea_codigo UNIQUE(codigo)
);

--------------- Aeropuerto ---------------

CREATE TABLE ESE_CU_ELE.Aeropuerto (
    aeropuerto_id BIGINT PRIMARY KEY IDENTITY(1,1),
    ciudad_id BIGINT, -- FK
    nombre nvarchar(200),
    codigo nvarchar(10),
    CONSTRAINT unique_aeropuerto_codigo UNIQUE(codigo)
);

--------------- Beneficio_Vuelo ---------------

CREATE TABLE ESE_CU_ELE.Beneficio_Vuelo (
    beneficio_id BIGINT PRIMARY KEY IDENTITY(1,1),
    beneficio_nombre nvarchar(255) UNIQUE
);

--------------- Vuelo ---------------

CREATE TABLE ESE_CU_ELE.Vuelo (
    vuelo_id BIGINT PRIMARY KEY IDENTITY(1,1),
    aeropuerto_salida_id BIGINT, -- FK
    aeropuerto_llegada_id BIGINT, -- FK
    aerolinea_id BIGINT, -- FK
    fecha_hora_salida DATETIME,
    fecha_hora_llegada DATETIME,
    duracion INT,
    CONSTRAINT unique_vuelo UNIQUE (aeropuerto_salida_id, aeropuerto_llegada_id, aerolinea_id, fecha_hora_salida)
);

--------------- Vuelo_Beneficio ---------------

CREATE TABLE ESE_CU_ELE.Vuelo_Beneficio (
    vuelo_id BIGINT, -- FK
    beneficio_id BIGINT, -- FK
    CONSTRAINT PK_Vuelo_Beneficio PRIMARY KEY (vuelo_id, beneficio_id)
);

--------------- Detalle_Propuesta_Vuelo ---------------

CREATE TABLE ESE_CU_ELE.Detalle_Propuesta_Vuelo (
    detalle_propuesta_vuelo_id BIGINT PRIMARY KEY IDENTITY(1,1),
    propuesta_nro BIGINT, -- FK
    vuelo_id BIGINT, -- FK
    cantidad_pasajes INT,
    precio_unitario decimal(18,2)
);

--------------- Venta_Vuelo ---------------

CREATE TABLE ESE_CU_ELE.Venta_Vuelo (
    venta_vuelo_id BIGINT PRIMARY KEY IDENTITY(1,1),
    venta_id BIGINT, -- FK
    vuelo_id BIGINT, -- FK
    cantidad_pasajes INT,
    precio_unitario decimal(18,2),
    cod_reserva nvarchar(255)
);





--ZONA DE TRABAJO DEL AMARILLO
--------------- Hospedaje ---------------

CREATE TABLE ESE_CU_ELE.Hospedaje (
    hospedaje_id BIGINT PRIMARY KEY IDENTITY (1,1),
    ciudad_id BIGINT, -- FK
    hora_check_in TIME,
    hora_check_out TIME,
    direccion nvarchar(255),
    nombre nvarchar(255)
);

--------------- Habitación ---------------

CREATE TABLE ESE_CU_ELE.Habitacion (
    habitacion_id BIGINT PRIMARY KEY IDENTITY(1,1),
    hospedaje_id BIGINT, -- FK
    precio decimal(18,2),
    nombre nvarchar(255),
    descripcion nvarchar(max)
);

--------------- Beneficio_Hospedaje ---------------

CREATE TABLE ESE_CU_ELE.Beneficio_Hospedaje (
    beneficio_id BIGINT PRIMARY KEY IDENTITY(1,1),
    beneficio_nombre nvarchar(255) NOT NULL UNIQUE
);

--------------- Hospedaje_Beneficio ---------------

CREATE TABLE ESE_CU_ELE.Hospedaje_Beneficio (
    hospedaje_beneficio_id BIGINT PRIMARY KEY IDENTITY(1,1),
    hospedaje_id BIGINT, -- FK
    beneficio_id BIGINT, -- FK
    CONSTRAINT UQ_Hospedaje_Beneficio
        UNIQUE (hospedaje_id, beneficio_id)
);

--------------- Proveedor_Excursion ---------------

CREATE TABLE ESE_CU_ELE.Proveedor_Excursion (
    proveedor_id BIGINT PRIMARY KEY IDENTITY(1,1),
    mail nvarchar(255),
    telefono nvarchar(255),
    nombre nvarchar(255)
);

--------------- Excursión ---------------

CREATE TABLE ESE_CU_ELE.Excursion (
    excursion_id BIGINT PRIMARY KEY IDENTITY(1,1),
    proveedor_id BIGINT, -- FK
    horario nvarchar(50),
    duracion INT,
    precio decimal(18,2),
    descripcion nvarchar(max),
    nombre nvarchar(255)
);

--------------- Venta_Excursion ---------------

CREATE TABLE ESE_CU_ELE.Venta_Excursion (
    venta_excursion_id BIGINT PRIMARY KEY IDENTITY(1,1),
    venta_nro BIGINT, -- FK
    excursion_id BIGINT, -- FK
    fecha_reserva DATE,
    cant INT,
    precio_unitario decimal(18,2),
    codigo_reserva nvarchar(255)
);

--------------- Venta_Hospedaje ---------------

CREATE TABLE ESE_CU_ELE.Venta_Hospedaje (
    venta_hospedaje_id BIGINT PRIMARY KEY IDENTITY(1,1),
    venta_nro BIGINT, -- FK
    habitacion_id BIGINT, -- FK
    fecha_desde DATE,
    fecha_hasta DATE,
    cantidad INT,
    precio_unitario decimal(18,2),
    codigo_reserva nvarchar(255)
);

---------- Detalle_Propuesta_Hospedaje -------------

CREATE TABLE ESE_CU_ELE.Detalle_Propuesta_Hospedaje (
    propuesta_nro BIGINT, -- FK
    habitacion_id BIGINT, -- FK
    fecha_desde DATE,
    fecha_hasta DATE,
    cantidad_habitaciones INT,
    precio_unitario decimal(18,2),
    CONSTRAINT PK_Detalle_Propuesta_Hospedaje
        PRIMARY KEY (propuesta_nro, habitacion_id)
);








PRINT(N'Tablas creadas (sin las FK)');

----------------------------------------------
-- CREACION DE LAS FK DE LAS TABLAS
----------------------------------------------

-- ZONA DE TRABAJO DEL VERDE


--------------- Ciudad ---------------

ALTER TABLE ESE_CU_ELE.Ciudad
ADD CONSTRAINT FK_Ciudad_Pais FOREIGN KEY(pais_id) REFERENCES ESE_CU_ELE.Pais(pais_id);

--------------- Localidad ---------------

ALTER TABLE ESE_CU_ELE.Localidad
ADD CONSTRAINT FK_Localidad_Provincia FOREIGN KEY(provincia_id) REFERENCES ESE_CU_ELE.Provincia(provincia_id);

--------------- Cliente ---------------

ALTER TABLE ESE_CU_ELE.Cliente
ADD CONSTRAINT FK_Cliente_Localidad FOREIGN KEY(localidad) REFERENCES ESE_CU_ELE.Localidad(localidad_id);

--------------- Agencia ---------------

ALTER TABLE ESE_CU_ELE.Agencia
ADD CONSTRAINT FK_Agencia_Localidad FOREIGN KEY(localidad) REFERENCES ESE_CU_ELE.Localidad(localidad_id);

--------------- Agente ---------------

ALTER TABLE ESE_CU_ELE.Agente
ADD CONSTRAINT FK_Agente_Agencia FOREIGN KEY(agencia_nro) REFERENCES ESE_CU_ELE.Agencia(agencia_nro),
    CONSTRAINT FK_Agente_Localidad FOREIGN KEY(localidad) REFERENCES ESE_CU_ELE.Localidad(localidad_id);

--------------- Solicitud_De_Cotizacion ---------------

ALTER TABLE ESE_CU_ELE.Solicitud_De_Cotizacion
ADD CONSTRAINT FK_SolicitudCotizacion_Cliente FOREIGN KEY(cliente_id) REFERENCES ESE_CU_ELE.Cliente(cliente_id),
    CONSTRAINT FK_SolicitudCotizacion_Agente FOREIGN KEY(agente_legajo) REFERENCES ESE_CU_ELE.Agente(agente_legajo);
    
--------------- Detalle_Solicitud_De_Cotizacion ---------------

ALTER TABLE ESE_CU_ELE.Detalle_Solicitud_De_Cotizacion
ADD CONSTRAINT FK_DetalleSolicitudCotizacion_Solicitud_Cotizacion FOREIGN KEY(solicitud_cotizacion_id) 
        REFERENCES ESE_CU_ELE.Solicitud_De_Cotizacion(nro_solicitud_id);







-- ZONA DE TRABAJO DEL ROJO


----------------------------------------------
-- ZONA DE TRABAJO DEL ROJO (CONSTRAINTS FK)
----------------------------------------------

--------------- Propuesta ---------------
ALTER TABLE ESE_CU_ELE.Propuesta
ADD CONSTRAINT FK_Propuesta_Solicitud FOREIGN KEY(nro_solicitud_id) REFERENCES ESE_CU_ELE.Solicitud_De_Cotizacion(nro_solicitud_id),
    CONSTRAINT FK_Propuesta_Agente FOREIGN KEY(agente_legajo) REFERENCES ESE_CU_ELE.Agente(agente_legajo);

--------------- Venta ---------------
ALTER TABLE ESE_CU_ELE.Venta
ADD CONSTRAINT FK_Venta_Agencia FOREIGN KEY(agencia_nro) REFERENCES ESE_CU_ELE.Agencia(agencia_nro),
    CONSTRAINT FK_Venta_Agente FOREIGN KEY(agente_legajo) REFERENCES ESE_CU_ELE.Agente(agente_legajo),
    CONSTRAINT FK_Venta_Cliente FOREIGN KEY(cliente_id) REFERENCES ESE_CU_ELE.Cliente(cliente_id),
    CONSTRAINT FK_Venta_Canal FOREIGN KEY(canal_venta_id) REFERENCES ESE_CU_ELE.Canal_De_Venta(canal_venta_id),
    CONSTRAINT FK_Venta_MedioPago FOREIGN KEY(medio_de_pago_id) REFERENCES ESE_CU_ELE.Medio_De_Pago(medio_de_pago_id);

--------------- Venta_Propuesta ---------------
ALTER TABLE ESE_CU_ELE.Venta_Propuesta
ADD CONSTRAINT FK_VentaPropuesta_Propuesta FOREIGN KEY(propuesta_nro) REFERENCES ESE_CU_ELE.Propuesta(propuesta_nro),
    CONSTRAINT FK_VentaPropuesta_Venta FOREIGN KEY(venta_nro) REFERENCES ESE_CU_ELE.Venta(venta_nro);

--------------- Encuesta ---------------
ALTER TABLE ESE_CU_ELE.Encuesta
ADD CONSTRAINT FK_Encuesta_Venta FOREIGN KEY(venta_nro) REFERENCES ESE_CU_ELE.Venta(venta_nro),
    CONSTRAINT FK_Encuesta_Propuesta FOREIGN KEY(propuesta_nro) REFERENCES ESE_CU_ELE.Propuesta(propuesta_nro);

--------------- Detalle_Encuesta_Puntaje ---------------
ALTER TABLE ESE_CU_ELE.Detalle_Encuesta_Puntaje
ADD CONSTRAINT FK_DetalleEncuesta_Aspecto FOREIGN KEY(aspecto_id) REFERENCES ESE_CU_ELE.Aspecto(aspecto_id),
    CONSTRAINT FK_DetalleEncuesta_Encuesta FOREIGN KEY(encuesta_id) REFERENCES ESE_CU_ELE.Encuesta(encuesta_id);


-- ZONA DE TRABAJO DEL AZUL

--------------- Aerolinea ---------------

ALTER TABLE ESE_CU_ELE.Aerolinea
ADD CONSTRAINT FK_Aerolinea_Alianza FOREIGN KEY(alianza_id) REFERENCES ESE_CU_ELE.Alianza(alianza_id),
    CONSTRAINT FK_Aerolinea_Pais FOREIGN KEY(pais_id) REFERENCES ESE_CU_ELE.Pais(pais_id);

--------------- Aeropuerto ---------------

ALTER TABLE ESE_CU_ELE.Aeropuerto
ADD CONSTRAINT FK_Aeropuerto_Ciudad FOREIGN KEY(ciudad_id) REFERENCES ESE_CU_ELE.Ciudad(ciudad_id);

--------------- Vuelo ---------------

ALTER TABLE ESE_CU_ELE.Vuelo
ADD CONSTRAINT FK_Vuelo_AeropuertoSalida FOREIGN KEY(aeropuerto_salida_id) REFERENCES ESE_CU_ELE.Aeropuerto(aeropuerto_id),
    CONSTRAINT FK_Vuelo_AeropuertoLlegada FOREIGN KEY(aeropuerto_llegada_id) REFERENCES ESE_CU_ELE.Aeropuerto(aeropuerto_id),
    CONSTRAINT FK_Vuelo_Aerolinea FOREIGN KEY(aerolinea_id) REFERENCES ESE_CU_ELE.Aerolinea(aerolinea_id);

--------------- Vuelo_Beneficio ---------------

ALTER TABLE ESE_CU_ELE.Vuelo_Beneficio
ADD CONSTRAINT FK_VueloBeneficio_Vuelo FOREIGN KEY(vuelo_id) REFERENCES ESE_CU_ELE.Vuelo(vuelo_id),
    CONSTRAINT FK_VueloBeneficio_Beneficio FOREIGN KEY(beneficio_id) REFERENCES ESE_CU_ELE.Beneficio_Vuelo(beneficio_id);

--------------- Detalle_Propuesta_Vuelo ---------------

ALTER TABLE ESE_CU_ELE.Detalle_Propuesta_Vuelo
ADD CONSTRAINT FK_DetallePropuestaVuelo_Propuesta FOREIGN KEY(propuesta_nro) REFERENCES ESE_CU_ELE.Propuesta(propuesta_nro),
    CONSTRAINT FK_DetallePropuestaVuelo_Vuelo FOREIGN KEY(vuelo_id) REFERENCES ESE_CU_ELE.Vuelo(vuelo_id);

--------------- Venta_Vuelo ---------------

ALTER TABLE ESE_CU_ELE.Venta_Vuelo
ADD CONSTRAINT FK_VentaVuelo_Venta FOREIGN KEY(venta_id) REFERENCES ESE_CU_ELE.Venta(venta_nro),
    CONSTRAINT FK_VentaVuelo_Vuelo FOREIGN KEY(vuelo_id) REFERENCES ESE_CU_ELE.Vuelo(vuelo_id);





--ZONA DE TRABAJO DEL AMARILLO

--------------- Hospedaje ---------------

ALTER TABLE ESE_CU_ELE.Hospedaje
ADD CONSTRAINT FK_Hospedaje_Ciudad FOREIGN KEY(ciudad_id) REFERENCES ESE_CU_ELE.Ciudad(ciudad_id);

--------------- Habitación ---------------

ALTER TABLE ESE_CU_ELE.Habitacion
ADD CONSTRAINT FK_Habitacion_Hospedaje FOREIGN KEY(hospedaje_id) REFERENCES ESE_CU_ELE.Hospedaje(hospedaje_id);

----------- Hospedaje_Beneficio ---------------

ALTER TABLE ESE_CU_ELE.Hospedaje_Beneficio
ADD CONSTRAINT FK_HospedajeBeneficio_Hospedaje FOREIGN KEY(hospedaje_id) REFERENCES ESE_CU_ELE.Hospedaje(hospedaje_id),
    CONSTRAINT FK_HospedajeBeneficio_Beneficio FOREIGN KEY(beneficio_id) REFERENCES ESE_CU_ELE.Beneficio_Hospedaje(beneficio_id);

--------------- Excursion ---------------

ALTER TABLE ESE_CU_ELE.Excursion
ADD CONSTRAINT FK_Excursion_Proveedor FOREIGN KEY(proveedor_id) REFERENCES ESE_CU_ELE.Proveedor_Excursion(proveedor_id);

ALTER TABLE ESE_CU_ELE.Venta_Excursion
ADD CONSTRAINT FK_VentaExcursion_Venta FOREIGN KEY(venta_nro) REFERENCES ESE_CU_ELE.Venta(venta_nro),
    CONSTRAINT FK_VentaExcursion_Excursion FOREIGN KEY(excursion_id) REFERENCES ESE_CU_ELE.Excursion(excursion_id);

------------ Venta_Hospedaje ---------------

ALTER TABLE ESE_CU_ELE.Venta_Hospedaje
ADD CONSTRAINT FK_VentaHospedaje_Venta FOREIGN KEY(venta_nro) REFERENCES ESE_CU_ELE.Venta(venta_nro),
    CONSTRAINT FK_VentaHospedaje_Habitacion FOREIGN KEY(habitacion_id) REFERENCES ESE_CU_ELE.Habitacion(habitacion_id);


---------------- Detalle_Propuesta_Hospedaje ----------------

ALTER TABLE ESE_CU_ELE.Detalle_Propuesta_Hospedaje
ADD CONSTRAINT FK_DetallePropuestaHospedaje_Propuesta FOREIGN KEY(propuesta_nro) REFERENCES ESE_CU_ELE.Propuesta(propuesta_nro),
    CONSTRAINT FK_DetallePropuestaHospedaje_Habitacion FOREIGN KEY(habitacion_id) REFERENCES ESE_CU_ELE.Habitacion(habitacion_id);




PRINT(N'Creadas las FK');
GO

----------------------------------------------
-- CREACION DE TRIGGERS SOBRE LAS TABLAS
----------------------------------------------

-- ZONA DE TRABAJO DEL VERDE





-- ZONA DE TRABAJO DEL ROJO

GO
CREATE TRIGGER ESE_CU_ELE.TR_Validar_Puntaje_Encuesta
ON ESE_CU_ELE.Detalle_Encuesta_Puntaje
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Si algún puntaje insertado o modificado está fuera del rango 1-10, cancelamos
    IF EXISTS (SELECT 1 FROM inserted WHERE puntaje < 1 OR puntaje > 10)
    BEGIN
        RAISERROR ('Error: El puntaje de la encuesta debe estar estrictamente entre 1 y 10.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO



-- ZONA DE TRABAJO DEL AZUL


--ZONA DE TRABAJO DEL AMARILLO



PRINT(N'Creados los Triggers');

----------------------------------------------
-- MIGRACION DE LOS DATOS
----------------------------------------------

GO
CREATE PROCEDURE ESE_CU_ELE.migracion
AS
BEGIN

-- ZONA DE TRABAJO DEL VERDE


--------------- Pais ---------------

INSERT INTO ESE_CU_ELE.Pais (nombre)
    SELECT Aeropuerto_Salida_Pais FROM gd_esquema.Maestra
    WHERE Aeropuerto_Salida_Pais IS NOT NULL
    UNION
    SELECT Aeropuerto_Llegada_Pais FROM gd_esquema.Maestra
    WHERE Aeropuerto_Llegada_Pais IS NOT NULL
    UNION
    SELECT Aerolinea_Pais FROM gd_esquema.Maestra
    WHERE Aerolinea_Pais IS NOT NULL
    UNION
    SELECT Hospedaje_Pais FROM gd_esquema.Maestra
    WHERE Hospedaje_Pais IS NOT NULL;


--------------- Provincia ---------------

INSERT INTO ESE_CU_ELE.Provincia (nombre)
    SELECT Agencia_Provincia FROM gd_esquema.Maestra
    WHERE Agencia_Provincia IS NOT NULL
    UNION
    SELECT Agente_Provincia FROM gd_esquema.Maestra
    WHERE Agente_Provincia IS NOT NULL
    UNION
    SELECT Cliente_Provincia FROM gd_esquema.Maestra
    WHERE Cliente_Provincia IS NOT NULL;


--------------- Ciudad ---------------

INSERT INTO ESE_CU_ELE.Ciudad (nombre, pais_id)
SELECT viejo.ciudad_nombre, nuevo_pais.pais_id 
	FROM (
		SELECT
            Aeropuerto_Salida_Ciudad AS ciudad_nombre, 
            Aeropuerto_Salida_Pais AS pais_nombre
            FROM gd_esquema.Maestra
            WHERE Aeropuerto_Salida_Ciudad IS NOT NULL AND Aeropuerto_Salida_Pais IS NOT NULL
		UNION
		SELECT 
            Aeropuerto_Llegada_Ciudad AS ciudad_nombre,
            Aeropuerto_Llegada_Pais AS pais_nombre
            FROM gd_esquema.Maestra
            WHERE Aeropuerto_Llegada_Ciudad IS NOT NULL AND Aeropuerto_Llegada_Pais IS NOT NULL
		UNION
		SELECT 
            Hospedaje_Ciudad AS ciudad_nombre,
            Hospedaje_Pais AS pais_nombre
            FROM gd_esquema.Maestra
            WHERE Hospedaje_Ciudad IS NOT NULL AND Hospedaje_Pais IS NOT NULL
	) AS viejo
	INNER JOIN ESE_CU_ELE.Pais nuevo_pais
	ON nuevo_pais.nombre = viejo.pais_nombre;


--------------- Localidad ---------------

INSERT INTO ESE_CU_ELE.Localidad (nombre, provincia_id)
SELECT viejo.localidad_nombre, nuevo_provincia.provincia_id
	FROM (
		SELECT
            Agencia_Localidad AS localidad_nombre, 
            Agencia_Provincia AS provincia_nombre
            FROM gd_esquema.Maestra
            WHERE Agencia_Localidad IS NOT NULL AND Agencia_Provincia IS NOT NULL
		UNION
		SELECT 
            Agente_Localidad AS localidad_nombre,
            Agente_Provincia AS provincia_nombre
            FROM gd_esquema.Maestra
            WHERE Agente_Localidad IS NOT NULL AND Agente_Provincia IS NOT NULL
		UNION
		SELECT 
            Cliente_Localidad AS localidad_nombre,
            Cliente_Provincia AS provincia_nombre
            FROM gd_esquema.Maestra
            WHERE Cliente_Localidad IS NOT NULL AND Cliente_Provincia IS NOT NULL
	) AS viejo
	INNER JOIN ESE_CU_ELE.Provincia nuevo_provincia
	ON nuevo_provincia.nombre = viejo.provincia_nombre;


--------------- Cliente ---------------

INSERT INTO ESE_CU_ELE.Cliente (localidad, nombre, apellido, dni, telefono, mail, direccion, fecha_nacimiento)
SELECT DISTINCT
    nuevo_localidad.localidad_id,
    viejo.Cliente_Nombre,
    viejo.Cliente_Apellido,
    viejo.Cliente_Dni,
    viejo.Cliente_Tel,
    viejo.Cliente_Mail,
    viejo.Cliente_Direccion,
    viejo.Cliente_Fecha_Nac
    FROM gd_esquema.Maestra AS viejo
INNER JOIN ESE_CU_ELE.Provincia nuevo_provincia
    ON nuevo_provincia.nombre = viejo.Cliente_Provincia
INNER JOIN ESE_CU_ELE.Localidad nuevo_localidad
    ON nuevo_localidad.nombre = viejo.Cliente_Localidad AND nuevo_localidad.provincia_id = nuevo_provincia.provincia_id
WHERE
    viejo.Cliente_Dni IS NOT NULL -- Hay personas con el mismo dni, asi que compruebo no solo por el dni, sino tambien por el nombre y apellido
    AND viejo.Cliente_Nombre IS NOT NULL
    AND viejo.Cliente_Apellido IS NOT NULL;


--------------- Agencia ---------------

INSERT INTO ESE_CU_ELE.Agencia (agencia_nro, localidad, direccion, telefono, mail)
SELECT DISTINCT
    viejo.Agencia_Nro_Agencia,
    nuevo_localidad.localidad_id,
    viejo.Agencia_Direccion,
    viejo.Agencia_Telefono,
    viejo.Agencia_Mail
FROM gd_esquema.Maestra AS viejo
INNER JOIN ESE_CU_ELE.Provincia nuevo_provincia
    ON nuevo_provincia.nombre = viejo.Agencia_Provincia
INNER JOIN ESE_CU_ELE.Localidad nuevo_localidad
    ON nuevo_localidad.nombre = viejo.Agencia_Localidad AND nuevo_localidad.provincia_id = nuevo_provincia.provincia_id
WHERE
    viejo.Agencia_Nro_Agencia IS NOT NULL;


--------------- Agente ---------------

INSERT INTO ESE_CU_ELE.Agente (agente_legajo, agencia_nro, localidad, nombre, apellido, direccion, dni, telefono, mail, fecha_nacimiento)
SELECT DISTINCT
    viejo.Agente_Legajo,
    viejo.Agencia_Nro_Agencia,
    nuevo_localidad.localidad_id,
    viejo.Agente_Nombre,
    viejo.Agente_Apellido,
    viejo.Agente_Direccion,
    viejo.Agente_Dni,
    viejo.Agente_Telefono,
    viejo.Agente_Mail,
    viejo.Agente_Fecha_Nac
    FROM gd_esquema.Maestra AS viejo
INNER JOIN ESE_CU_ELE.Provincia nuevo_provincia
    ON nuevo_provincia.nombre = viejo.Agente_Provincia
INNER JOIN ESE_CU_ELE.Localidad nuevo_localidad
    ON nuevo_localidad.nombre = viejo.Agente_Localidad AND nuevo_localidad.provincia_id = nuevo_provincia.provincia_id
WHERE
    viejo.Agente_Legajo IS NOT NULL;


--------------- Solicitud_De_Cotizacion ---------------

INSERT INTO ESE_CU_ELE.Solicitud_De_Cotizacion (nro_solicitud_id, cliente_id, agente_legajo, fecha_solicitud,
                                                fecha_inicio_tentativa, fecha_fin_tentativa, cantidad_pasajeros,
                                                observaciones, presupuesto_estimado)
SELECT DISTINCT
    viejo.Solicitud_Nro_Solicitud,
    nuevo_cliente.cliente_id,
    nuevo_agente.agente_legajo,
    viejo.Solicitud_Fecha_Solicitud,
    viejo.Solicitud_Fecha_Inicio_Tentativa,
    viejo.Solicitud_Fecha_Fin_Tentativa,
    viejo.Solicitud_Cant_Pax,
    viejo.Solicitud_Observaciones,
    viejo.Solicitud_Presupuesto_Estimado
    FROM gd_esquema.Maestra AS viejo
INNER JOIN ESE_CU_ELE.Cliente nuevo_cliente
    ON nuevo_cliente.dni = viejo.Cliente_Dni -- Hay personas con el mismo dni, asi que compruebo no solo por el dni, sino tambien por el nombre y apellido
       AND nuevo_cliente.nombre = viejo.Cliente_Nombre
       AND nuevo_cliente.apellido = viejo.Cliente_Apellido
INNER JOIN ESE_CU_ELE.Agente nuevo_agente
    ON nuevo_agente.agente_legajo = viejo.Agente_Legajo
WHERE
    viejo.Solicitud_Nro_Solicitud IS NOT NULL;


--------------- Detalle_Solicitud_De_Cotizacion ---------------

INSERT INTO ESE_CU_ELE.Detalle_Solicitud_De_Cotizacion (solicitud_cotizacion_id, ciudad_id, cant_dias_aprox, observaciones)
SELECT
    viejo.Solicitud_Nro_Solicitud,
    nuevo_ciudad.ciudad_id,
    viejo.Detalle_Solicitud_Cant_Dias_Aprox,
    viejo.Detalle_Solicitud_Observaciones
    FROM gd_esquema.Maestra AS viejo
INNER JOIN ESE_CU_ELE.Ciudad nuevo_ciudad
    ON nuevo_ciudad.nombre = viejo.Detalle_Solicitud_Ciudad
WHERE
    viejo.Solicitud_Nro_Solicitud IS NOT NULL;



-- ZONA DE TRABAJO DEL ROJO

PRINT 'Migrando bloque Rojo...';

--------------- Canal_De_Venta ---------------
INSERT INTO ESE_CU_ELE.Canal_De_Venta (canal)
SELECT DISTINCT Venta_Canal_Venta
FROM gd_esquema.Maestra
WHERE Venta_Canal_Venta IS NOT NULL;


--------------- Medio_De_Pago ---------------
INSERT INTO ESE_CU_ELE.Medio_De_Pago (descripcion)
SELECT DISTINCT Venta_Medio_Pago
FROM gd_esquema.Maestra
WHERE Venta_Medio_Pago IS NOT NULL;


--------------- Aspecto ---------------
INSERT INTO ESE_CU_ELE.Aspecto (nombre)
SELECT DISTINCT Aspecto_Aspecto
FROM gd_esquema.Maestra
WHERE Aspecto_Aspecto IS NOT NULL;


--------------- Propuesta ---------------
INSERT INTO ESE_CU_ELE.Propuesta (propuesta_nro, nro_solicitud_id, agente_legajo, fecha_emision, fecha_vigencia_hasta, fecha_desde, fecha_hasta, descuento, importe_total, estado)
SELECT DISTINCT 
    Propuesta_Nro_Propuesta,
    Solicitud_Nro_Solicitud,
    Agente_Legajo,
    Propuesta_Fecha_Emision,
    Propuesta_Vigencia_Hasta,
    Propuesta_Fecha_Desde,
    Propuesta_Fecha_Hasta,
    Propuesta_Descuento,
    Propuesta_Importe_Total,
    Propuesta_Estado
FROM gd_esquema.Maestra
WHERE Propuesta_Nro_Propuesta IS NOT NULL;


--------------- Venta ---------------
INSERT INTO ESE_CU_ELE.Venta (venta_nro, agencia_nro, agente_legajo, cliente_id, canal_venta_id, medio_de_pago_id, descuento, importe_total, fecha)
SELECT DISTINCT 
    viejo.Venta_Nro_Venta,
    viejo.Agencia_Nro_Agencia,
    viejo.Agente_Legajo,
    c.cliente_id,               -- Obtenemos el ID autoincremental de tu tabla Cliente
    canal.canal_venta_id,       -- Obtenemos el ID autoincremental de tu tabla Canal
    pago.medio_de_pago_id,      -- Obtenemos el ID autoincremental de tu tabla Medio Pago
    viejo.Venta_Descuento,
    viejo.Venta_Importe_Total,
    viejo.Venta_Fecha_Venta
FROM gd_esquema.Maestra viejo
INNER JOIN ESE_CU_ELE.Cliente c 
    ON c.dni = viejo.Cliente_Dni 
   AND c.nombre = viejo.Cliente_Nombre 
   AND c.apellido = viejo.Cliente_Apellido
INNER JOIN ESE_CU_ELE.Canal_De_Venta canal 
    ON canal.canal = viejo.Venta_Canal_Venta
INNER JOIN ESE_CU_ELE.Medio_De_Pago pago 
    ON pago.descripcion = viejo.Venta_Medio_Pago
WHERE viejo.Venta_Nro_Venta IS NOT NULL;


--------------- Venta_Propuesta ---------------
INSERT INTO ESE_CU_ELE.Venta_Propuesta (propuesta_nro, venta_nro)
SELECT DISTINCT 
    Propuesta_Nro_Propuesta,
    Venta_Nro_Venta
FROM gd_esquema.Maestra
WHERE Venta_Nro_Venta IS NOT NULL 
  AND Propuesta_Nro_Propuesta IS NOT NULL;


--------------- Encuesta ---------------
INSERT INTO ESE_CU_ELE.Encuesta (encuesta_id, venta_nro, propuesta_nro, fecha, comentario)
SELECT DISTINCT 
    Encuesta_Codigo_Encuesta,
    Venta_Nro_Venta,       
    Propuesta_Nro_Propuesta, 
    Encuesta_Fecha_Encuesta,
    Encuesta_Comentarios
FROM gd_esquema.Maestra
WHERE Encuesta_Codigo_Encuesta IS NOT NULL;


--------------- Detalle_Encuesta_Puntaje ---------------
INSERT INTO ESE_CU_ELE.Detalle_Encuesta_Puntaje (encuesta_id, aspecto_id, puntaje)
SELECT 
    viejo.Encuesta_Codigo_Encuesta,
    asp.aspecto_id,             -- Obtenemos el ID autoincremental de tu tabla Aspecto
    viejo.Detalle_Encuesta_Puntaje
FROM gd_esquema.Maestra viejo
INNER JOIN ESE_CU_ELE.Aspecto asp 
    ON asp.nombre = viejo.Aspecto_Aspecto
WHERE viejo.Encuesta_Codigo_Encuesta IS NOT NULL 
  AND viejo.Aspecto_Aspecto IS NOT NULL;

PRINT 'Bloque Rojo migrado con éxito.';


-- ZONA DE TRABAJO DEL AZUL

--------------- Alianza ---------------

INSERT INTO ESE_CU_ELE.Alianza (nombre)
SELECT DISTINCT Aerolinea_Alianza
FROM gd_esquema.Maestra
WHERE Aerolinea_Alianza IS NOT NULL;


--------------- Aerolinea ---------------

INSERT INTO ESE_CU_ELE.Aerolinea (alianza_id, pais_id, nombre, codigo)
SELECT DISTINCT
    al.alianza_id,
    p.pais_id,
    viejo.Aerolinea_Nombre,
    viejo.Aerolinea_Codigo
FROM gd_esquema.Maestra viejo
LEFT JOIN ESE_CU_ELE.Alianza al ON al.nombre = viejo.Aerolinea_Alianza
INNER JOIN ESE_CU_ELE.Pais p ON p.nombre = viejo.Aerolinea_Pais
WHERE viejo.Aerolinea_Nombre IS NOT NULL
  AND viejo.Aerolinea_Codigo IS NOT NULL;


--------------- Aeropuerto ---------------

INSERT INTO ESE_CU_ELE.Aeropuerto (ciudad_id, nombre, codigo)
SELECT DISTINCT c.ciudad_id, viejo.aeropuerto_nombre, viejo.aeropuerto_codigo
FROM (
    SELECT
        Aeropuerto_Salida_Descripcion AS aeropuerto_nombre,
        Aeropuerto_Salida_Codigo      AS aeropuerto_codigo,
        Aeropuerto_Salida_Ciudad      AS ciudad_nombre,
        Aeropuerto_Salida_Pais        AS pais_nombre
    FROM gd_esquema.Maestra
    WHERE Aeropuerto_Salida_Descripcion IS NOT NULL
      AND Aeropuerto_Salida_Codigo IS NOT NULL
    UNION
    SELECT
        Aeropuerto_Llegada_Descripcion,
        Aeropuerto_Llegada_Codigo,
        Aeropuerto_Llegada_Ciudad,
        Aeropuerto_Llegada_Pais
    FROM gd_esquema.Maestra
    WHERE Aeropuerto_Llegada_Descripcion IS NOT NULL
      AND Aeropuerto_Llegada_Codigo IS NOT NULL
) AS viejo
INNER JOIN ESE_CU_ELE.Pais p ON p.nombre = viejo.pais_nombre
INNER JOIN ESE_CU_ELE.Ciudad c ON c.nombre = viejo.ciudad_nombre AND c.pais_id = p.pais_id;


--------------- Beneficio_Vuelo ---------------

INSERT INTO ESE_CU_ELE.Beneficio_Vuelo (beneficio_nombre)
VALUES ('Carry On'), ('Valija');


--------------- Vuelo ---------------

INSERT INTO ESE_CU_ELE.Vuelo (aeropuerto_salida_id, aeropuerto_llegada_id, aerolinea_id, fecha_hora_salida, fecha_hora_llegada, duracion)
SELECT DISTINCT
    ap_sal.aeropuerto_id,
    ap_lle.aeropuerto_id,
    ae.aerolinea_id,
    CAST(CONVERT(VARCHAR(10), viejo.Vuelo_Fecha_Salida, 120) + ' ' + CASE WHEN LEN(viejo.Vuelo_Horario_Salida) = 4 THEN '0' + viejo.Vuelo_Horario_Salida ELSE viejo.Vuelo_Horario_Salida END AS DATETIME),
    CAST(CONVERT(VARCHAR(10), viejo.Vuelo_Fecha_Llegada, 120) + ' ' + CASE WHEN LEN(viejo.Vuelo_Horario_Llegada) = 4 THEN '0' + viejo.Vuelo_Horario_Llegada ELSE viejo.Vuelo_Horario_Llegada END AS DATETIME),
    viejo.Vuelo_Duracion
FROM gd_esquema.Maestra viejo
INNER JOIN ESE_CU_ELE.Aeropuerto ap_sal ON ap_sal.codigo = viejo.Aeropuerto_Salida_Codigo
INNER JOIN ESE_CU_ELE.Aeropuerto ap_lle ON ap_lle.codigo = viejo.Aeropuerto_Llegada_Codigo
INNER JOIN ESE_CU_ELE.Aerolinea ae ON ae.codigo = viejo.Aerolinea_Codigo
WHERE viejo.Vuelo_Fecha_Salida IS NOT NULL
  AND viejo.Aeropuerto_Salida_Codigo IS NOT NULL
  AND viejo.Aeropuerto_Llegada_Codigo IS NOT NULL;


--------------- Vuelo_Beneficio ---------------

INSERT INTO ESE_CU_ELE.Vuelo_Beneficio (vuelo_id, beneficio_id)
SELECT DISTINCT v.vuelo_id, bf.beneficio_id
FROM gd_esquema.Maestra viejo
INNER JOIN ESE_CU_ELE.Aeropuerto ap_sal ON ap_sal.codigo = viejo.Aeropuerto_Salida_Codigo
INNER JOIN ESE_CU_ELE.Aeropuerto ap_lle ON ap_lle.codigo = viejo.Aeropuerto_Llegada_Codigo
INNER JOIN ESE_CU_ELE.Aerolinea ae ON ae.codigo = viejo.Aerolinea_Codigo
INNER JOIN ESE_CU_ELE.Vuelo v
    ON v.aeropuerto_salida_id = ap_sal.aeropuerto_id
    AND v.aeropuerto_llegada_id = ap_lle.aeropuerto_id
    AND v.aerolinea_id = ae.aerolinea_id
    AND v.fecha_hora_salida = CAST(CONVERT(VARCHAR(10), viejo.Vuelo_Fecha_Salida, 120) + ' ' + CASE WHEN LEN(viejo.Vuelo_Horario_Salida) = 4 THEN '0' + viejo.Vuelo_Horario_Salida ELSE viejo.Vuelo_Horario_Salida END AS DATETIME)
INNER JOIN ESE_CU_ELE.Beneficio_Vuelo bf ON bf.beneficio_nombre = 'Carry On'
WHERE viejo.Vuelo_Incluye_Carry = 1
  AND viejo.Vuelo_Fecha_Salida IS NOT NULL;

INSERT INTO ESE_CU_ELE.Vuelo_Beneficio (vuelo_id, beneficio_id)
SELECT DISTINCT v.vuelo_id, bf.beneficio_id
FROM gd_esquema.Maestra viejo
INNER JOIN ESE_CU_ELE.Aeropuerto ap_sal ON ap_sal.codigo = viejo.Aeropuerto_Salida_Codigo
INNER JOIN ESE_CU_ELE.Aeropuerto ap_lle ON ap_lle.codigo = viejo.Aeropuerto_Llegada_Codigo
INNER JOIN ESE_CU_ELE.Aerolinea ae ON ae.codigo = viejo.Aerolinea_Codigo
INNER JOIN ESE_CU_ELE.Vuelo v
    ON v.aeropuerto_salida_id = ap_sal.aeropuerto_id
    AND v.aeropuerto_llegada_id = ap_lle.aeropuerto_id
    AND v.aerolinea_id = ae.aerolinea_id
    AND v.fecha_hora_salida = CAST(CONVERT(VARCHAR(10), viejo.Vuelo_Fecha_Salida, 120) + ' ' + CASE WHEN LEN(viejo.Vuelo_Horario_Salida) = 4 THEN '0' + viejo.Vuelo_Horario_Salida ELSE viejo.Vuelo_Horario_Salida END AS DATETIME)
INNER JOIN ESE_CU_ELE.Beneficio_Vuelo bf ON bf.beneficio_nombre = 'Valija'
WHERE viejo.Vuelo_Incluye_Valija = 1
  AND viejo.Vuelo_Fecha_Salida IS NOT NULL;


--------------- Detalle_Propuesta_Vuelo ---------------

INSERT INTO ESE_CU_ELE.Detalle_Propuesta_Vuelo (propuesta_nro, vuelo_id, cantidad_pasajes, precio_unitario)
SELECT DISTINCT
    viejo.Propuesta_Nro_Propuesta,
    v.vuelo_id,
    viejo.Detalle_Propuesta_Vuelo_Cant_Pasajes,
    viejo.Detalle_Propuesta_Vuelo_Precio
FROM gd_esquema.Maestra viejo
INNER JOIN ESE_CU_ELE.Aeropuerto ap_sal ON ap_sal.codigo = viejo.Aeropuerto_Salida_Codigo
INNER JOIN ESE_CU_ELE.Aeropuerto ap_lle ON ap_lle.codigo = viejo.Aeropuerto_Llegada_Codigo
INNER JOIN ESE_CU_ELE.Aerolinea ae ON ae.codigo = viejo.Aerolinea_Codigo
INNER JOIN ESE_CU_ELE.Vuelo v
    ON v.aeropuerto_salida_id = ap_sal.aeropuerto_id
    AND v.aeropuerto_llegada_id = ap_lle.aeropuerto_id
    AND v.aerolinea_id = ae.aerolinea_id
    AND v.fecha_hora_salida = CAST(CONVERT(VARCHAR(10), viejo.Vuelo_Fecha_Salida, 120) + ' ' + CASE WHEN LEN(viejo.Vuelo_Horario_Salida) = 4 THEN '0' + viejo.Vuelo_Horario_Salida ELSE viejo.Vuelo_Horario_Salida END AS DATETIME)
WHERE viejo.Propuesta_Nro_Propuesta IS NOT NULL
  AND viejo.Vuelo_Fecha_Salida IS NOT NULL;


--------------- Venta_Vuelo ---------------

INSERT INTO ESE_CU_ELE.Venta_Vuelo (venta_id, vuelo_id, cantidad_pasajes, precio_unitario, cod_reserva)
SELECT DISTINCT
    viejo.Venta_Nro_Venta,
    v.vuelo_id,
    viejo.Detalle_Venta_Vuelo_Cantidad_Pasajes,
    viejo.Detalle_Venta_Vuelo_Precio_Unitario,
    viejo.Detalle_Venta_Vuelo_Cod_Reserva
FROM gd_esquema.Maestra viejo
INNER JOIN ESE_CU_ELE.Aeropuerto ap_sal ON ap_sal.codigo = viejo.Aeropuerto_Salida_Codigo
INNER JOIN ESE_CU_ELE.Aeropuerto ap_lle ON ap_lle.codigo = viejo.Aeropuerto_Llegada_Codigo
INNER JOIN ESE_CU_ELE.Aerolinea ae ON ae.codigo = viejo.Aerolinea_Codigo
INNER JOIN ESE_CU_ELE.Vuelo v
    ON v.aeropuerto_salida_id = ap_sal.aeropuerto_id
    AND v.aeropuerto_llegada_id = ap_lle.aeropuerto_id
    AND v.aerolinea_id = ae.aerolinea_id
    AND v.fecha_hora_salida = CAST(CONVERT(VARCHAR(10), viejo.Vuelo_Fecha_Salida, 120) + ' ' + CASE WHEN LEN(viejo.Vuelo_Horario_Salida) = 4 THEN '0' + viejo.Vuelo_Horario_Salida ELSE viejo.Vuelo_Horario_Salida END AS DATETIME)
WHERE viejo.Venta_Nro_Venta IS NOT NULL
  AND viejo.Vuelo_Fecha_Salida IS NOT NULL
  AND viejo.Detalle_Venta_Vuelo_Cod_Reserva IS NOT NULL;


--ZONA DE TRABAJO DEL AMARILLO

--------------- Hospedaje ---------------

  INSERT INTO ESE_CU_ELE.Hospedaje
(
    ciudad_id,
    hora_check_in,
    hora_check_out,
    direccion,
    nombre
)
SELECT DISTINCT
    nueva_ciudad.ciudad_id,
    CAST(viejo.Hospedaje_Check_In AS TIME),
    CAST(viejo.Hospedaje_Check_Out AS TIME),
    viejo.Hospedaje_Direccion,
    viejo.Hospedaje_Nombre
FROM gd_esquema.Maestra AS viejo
INNER JOIN ESE_CU_ELE.Ciudad nueva_ciudad
    ON nueva_ciudad.nombre = viejo.Hospedaje_Ciudad
INNER JOIN ESE_CU_ELE.Pais nuevo_pais
    ON nuevo_pais.pais_id = nueva_ciudad.pais_id
   AND nuevo_pais.nombre = viejo.Hospedaje_Pais
WHERE viejo.Hospedaje_Nombre IS NOT NULL
  AND viejo.Hospedaje_Ciudad IS NOT NULL;


--------------- Habitacion ---------------

INSERT INTO ESE_CU_ELE.Habitacion
(
    hospedaje_id,
    precio,
    nombre,
    descripcion
)
SELECT DISTINCT
    nuevo_hospedaje.hospedaje_id,
    viejo.Habitacion_Precio_Noche,
    viejo.Habitacion_Nombre,
    viejo.Habitacion_Descripcion
FROM gd_esquema.Maestra AS viejo
INNER JOIN ESE_CU_ELE.Hospedaje nuevo_hospedaje
    ON nuevo_hospedaje.nombre = viejo.Hospedaje_Nombre
   AND nuevo_hospedaje.direccion = viejo.Hospedaje_Direccion
WHERE viejo.Habitacion_Nombre IS NOT NULL;


--------------- Beneficio_Hospedaje ---------------

INSERT INTO ESE_CU_ELE.Beneficio_Hospedaje
(
    beneficio_nombre
)
VALUES
(
    'Desayuno'
);


--------------- Hospedaje_Beneficio ---------------

INSERT INTO ESE_CU_ELE.Hospedaje_Beneficio
(
    hospedaje_id,
    beneficio_id
)
SELECT DISTINCT
    nuevo_hospedaje.hospedaje_id,
    nuevo_beneficio.beneficio_id
FROM gd_esquema.Maestra AS viejo
INNER JOIN ESE_CU_ELE.Hospedaje nuevo_hospedaje
    ON nuevo_hospedaje.nombre = viejo.Hospedaje_Nombre
   AND nuevo_hospedaje.direccion = viejo.Hospedaje_Direccion
INNER JOIN ESE_CU_ELE.Beneficio_Hospedaje nuevo_beneficio
    ON nuevo_beneficio.beneficio_nombre = 'Desayuno'
WHERE viejo.Hospedaje_Incluye_Desayuno = 1
  AND viejo.Hospedaje_Nombre IS NOT NULL;


--------------- Proveedor_Excursion ---------------

INSERT INTO ESE_CU_ELE.Proveedor_Excursion
(
    mail,
    telefono,
    nombre
)
SELECT DISTINCT
    viejo.Proveedor_Mail,
    viejo.Proveedor_Telefono,
    viejo.Proveedor_Nombre
FROM gd_esquema.Maestra AS viejo
WHERE viejo.Proveedor_Nombre IS NOT NULL;


--------------- Excursion ---------------

INSERT INTO ESE_CU_ELE.Excursion
(
    proveedor_id,
    horario,
    duracion,
    precio,
    descripcion,
    nombre
)
SELECT DISTINCT
    nuevo_proveedor.proveedor_id,
    viejo.Excursion_Horario,
    viejo.Excursion_Duracion,
    viejo.Excursion_Precio,
    viejo.Excursion_Descripcion,
    viejo.Excursion_Nombre
FROM gd_esquema.Maestra AS viejo
INNER JOIN ESE_CU_ELE.Proveedor_Excursion nuevo_proveedor
    ON nuevo_proveedor.nombre = viejo.Proveedor_Nombre
   AND nuevo_proveedor.mail = viejo.Proveedor_Mail
   AND nuevo_proveedor.telefono = viejo.Proveedor_Telefono
WHERE viejo.Excursion_Nombre IS NOT NULL;


--------------- Venta_Hospedaje ---------------

INSERT INTO ESE_CU_ELE.Venta_Hospedaje
(
    venta_nro,
    habitacion_id,
    fecha_desde,
    fecha_hasta,
    cantidad,
    precio_unitario,
    codigo_reserva
)
SELECT DISTINCT
    nueva_venta.venta_nro,
    nueva_habitacion.habitacion_id,
    viejo.Detalle_Venta_Hospedaje_Fecha_Desde,
    viejo.Detalle_Venta_Hospedaje_Fecha_Hasta,
    viejo.Detalle_Venta_Hospedaje_Cantidad,
    viejo.Detalle_Venta_Hospedaje_Precio_Unitario,
    viejo.Detalle_Venta_Hospedaje_Cod_Reserva
FROM gd_esquema.Maestra AS viejo
INNER JOIN ESE_CU_ELE.Venta nueva_venta
    ON nueva_venta.venta_nro = viejo.Venta_Nro_Venta
INNER JOIN ESE_CU_ELE.Hospedaje nuevo_hospedaje
    ON nuevo_hospedaje.nombre = viejo.Hospedaje_Nombre
   AND nuevo_hospedaje.direccion = viejo.Hospedaje_Direccion
INNER JOIN ESE_CU_ELE.Habitacion nueva_habitacion
    ON nueva_habitacion.hospedaje_id = nuevo_hospedaje.hospedaje_id
   AND nueva_habitacion.nombre = viejo.Habitacion_Nombre
   AND nueva_habitacion.descripcion = viejo.Habitacion_Descripcion
   AND nueva_habitacion.precio = viejo.Habitacion_Precio_Noche
WHERE viejo.Detalle_Venta_Hospedaje_Cod_Reserva IS NOT NULL;


--------------- Venta_Excursion ---------------

INSERT INTO ESE_CU_ELE.Venta_Excursion
(
    venta_nro,
    excursion_id,
    fecha_reserva,
    cant,
    precio_unitario,
    codigo_reserva
)
SELECT DISTINCT
    nueva_venta.venta_nro,
    nueva_excursion.excursion_id,
    viejo.Detalle_Venta_Excursion_Fecha_Reserva,
    viejo.Detalle_Venta_Excursion_Cant,
    viejo.Detalle_Venta_Excursion_Precio_Unitario,
    viejo.Detalle_Venta_Excursion_Cod_Reserva
FROM gd_esquema.Maestra AS viejo
INNER JOIN ESE_CU_ELE.Venta nueva_venta
    ON nueva_venta.venta_nro = viejo.Venta_Nro_Venta
INNER JOIN ESE_CU_ELE.Excursion nueva_excursion
    ON nueva_excursion.nombre = viejo.Excursion_Nombre
   AND nueva_excursion.descripcion = viejo.Excursion_Descripcion
   AND nueva_excursion.horario = viejo.Excursion_Horario
   AND nueva_excursion.duracion = viejo.Excursion_Duracion
   AND nueva_excursion.precio = viejo.Excursion_Precio
WHERE viejo.Detalle_Venta_Excursion_Cod_Reserva IS NOT NULL;


--------------- Detalle_Propuesta_Hospedaje ---------------

INSERT INTO ESE_CU_ELE.Detalle_Propuesta_Hospedaje
(
    propuesta_nro,
    habitacion_id,
    fecha_desde,
    fecha_hasta,
    cantidad_habitaciones,
    precio_unitario
)
SELECT DISTINCT
    nueva_propuesta.propuesta_nro,
    nueva_habitacion.habitacion_id,
    viejo.Detalle_Propuesta_Hospedaje_Fecha_Desde,
    viejo.Detalle_Propuesta_Hospedaje_Fecha_Hasta,
    viejo.Detalle_Propuesta_Hospedaje_Cant,
    viejo.Detalle_Propuesta_Hospedaje_Precio
FROM gd_esquema.Maestra AS viejo
INNER JOIN ESE_CU_ELE.Propuesta nueva_propuesta
    ON nueva_propuesta.propuesta_nro = viejo.Propuesta_Nro_Propuesta
INNER JOIN ESE_CU_ELE.Hospedaje nuevo_hospedaje
    ON nuevo_hospedaje.nombre = viejo.Hospedaje_Nombre
   AND nuevo_hospedaje.direccion = viejo.Hospedaje_Direccion
INNER JOIN ESE_CU_ELE.Habitacion nueva_habitacion
    ON nueva_habitacion.hospedaje_id = nuevo_hospedaje.hospedaje_id
   AND nueva_habitacion.nombre = viejo.Habitacion_Nombre
   AND nueva_habitacion.descripcion = viejo.Habitacion_Descripcion
   AND nueva_habitacion.precio = viejo.Habitacion_Precio_Noche
WHERE viejo.Propuesta_Nro_Propuesta IS NOT NULL
  AND viejo.Detalle_Propuesta_Hospedaje_Precio IS NOT NULL;

END;
GO

BEGIN TRY
    BEGIN TRANSACTION
    EXECUTE ESE_CU_ELE.migracion;
    PRINT('Migracion de los datos hecha');
    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT('Se hizo un Rollback en la migracion debido al siguiente error: ' + ERROR_MESSAGE());
END CATCH;


----------------------------------------------
-- CREACION DE INDICES
----------------------------------------------

-- ZONA DE TRABAJO DEL VERDE


--------------- Ciudad ---------------

CREATE INDEX index_ciudad_paisid ON ESE_CU_ELE.Ciudad(pais_id);

--------------- Localidad ---------------

CREATE INDEX index_localidad_provinciaid ON ESE_CU_ELE.Localidad(provincia_id);

--------------- Cliente ---------------

CREATE INDEX index_cliente_localidad ON ESE_CU_ELE.Cliente(localidad);
CREATE INDEX index_cliente_dni ON ESE_CU_ELE.Cliente(dni);

--------------- Agencia ---------------

CREATE INDEX index_agencia_localidad ON ESE_CU_ELE.Agencia(localidad);

--------------- Agente ---------------

CREATE INDEX index_agente_agencianro ON ESE_CU_ELE.Agente(agencia_nro);
CREATE INDEX index_agente_localidad ON ESE_CU_ELE.Agente(localidad);

--------------- Solicitud_De_Cotizacion ---------------

CREATE INDEX index_solicitudcotizacion_clienteid ON ESE_CU_ELE.Solicitud_De_Cotizacion(cliente_id);
CREATE INDEX index_solicitudcotizacion_agentelegajo ON ESE_CU_ELE.Solicitud_De_Cotizacion(agente_legajo);

--------------- Detalle_Solicitud_De_Cotizacion ---------------

CREATE INDEX index_detallesolicitudcotizacion_solicitudcotizacionid ON ESE_CU_ELE.Detalle_Solicitud_De_Cotizacion(solicitud_cotizacion_id);
CREATE INDEX index_detallesolicitudcotizacion_ciudadid ON ESE_CU_ELE.Detalle_Solicitud_De_Cotizacion(ciudad_id);


-- ZONA DE TRABAJO DEL ROJO

CREATE INDEX index_propuesta_solicitudid ON ESE_CU_ELE.Propuesta(nro_solicitud_id);
CREATE INDEX index_propuesta_agentelegajo ON ESE_CU_ELE.Propuesta(agente_legajo);

CREATE INDEX index_venta_agencianro ON ESE_CU_ELE.Venta(agencia_nro);
CREATE INDEX index_venta_agentelegajo ON ESE_CU_ELE.Venta(agente_legajo);
CREATE INDEX index_venta_clienteid ON ESE_CU_ELE.Venta(cliente_id);
CREATE INDEX index_venta_canalventaid ON ESE_CU_ELE.Venta(canal_venta_id);
CREATE INDEX index_venta_mediodepagoid ON ESE_CU_ELE.Venta(medio_de_pago_id);

CREATE INDEX index_ventapropuesta_ventanro ON ESE_CU_ELE.Venta_Propuesta(venta_nro);

CREATE INDEX index_encuesta_ventanro ON ESE_CU_ELE.Encuesta(venta_nro);
CREATE INDEX index_encuesta_propuestanro ON ESE_CU_ELE.Encuesta(propuesta_nro);

CREATE INDEX index_detalleencuestapuntaje_encuestaid ON ESE_CU_ELE.Detalle_Encuesta_Puntaje(encuesta_id);

-- ZONA DE TRABAJO DEL AZUL

--------------- Aerolinea ---------------

CREATE INDEX index_aerolinea_alianzaid ON ESE_CU_ELE.Aerolinea(alianza_id);
CREATE INDEX index_aerolinea_paisid ON ESE_CU_ELE.Aerolinea(pais_id);

--------------- Aeropuerto ---------------

CREATE INDEX index_aeropuerto_ciudadid ON ESE_CU_ELE.Aeropuerto(ciudad_id);

--------------- Vuelo ---------------

CREATE INDEX index_vuelo_aeropuertosalidaid ON ESE_CU_ELE.Vuelo(aeropuerto_salida_id);
CREATE INDEX index_vuelo_aeropuertollegadaid ON ESE_CU_ELE.Vuelo(aeropuerto_llegada_id);
CREATE INDEX index_vuelo_aerolineaid ON ESE_CU_ELE.Vuelo(aerolinea_id);

--------------- Venta_Vuelo ---------------

CREATE INDEX index_ventavuelo_ventaid ON ESE_CU_ELE.Venta_Vuelo(venta_id);
CREATE INDEX index_ventavuelo_vueloid ON ESE_CU_ELE.Venta_Vuelo(vuelo_id);

--------------- Detalle_Propuesta_Vuelo ---------------

CREATE INDEX index_detallepropuestavuelo_propuestanro ON ESE_CU_ELE.Detalle_Propuesta_Vuelo(propuesta_nro);
CREATE INDEX index_detallepropuestavuelo_vueloid ON ESE_CU_ELE.Detalle_Propuesta_Vuelo(vuelo_id);



--ZONA DE TRABAJO DEL AMARILLO

--------------- Hospedaje ---------------

CREATE INDEX index_hospedaje_ciudadid
ON ESE_CU_ELE.Hospedaje(ciudad_id);

--------------- Habitacion ---------------

CREATE INDEX index_habitacion_hospedajeid
ON ESE_CU_ELE.Habitacion(hospedaje_id);

--------------- Excursion ---------------

CREATE INDEX index_excursion_proveedorid
ON ESE_CU_ELE.Excursion(proveedor_id);

--------------- Venta_Excursion ---------------

CREATE INDEX index_ventaexcursion_ventanro
ON ESE_CU_ELE.Venta_Excursion(venta_nro);

CREATE INDEX index_ventaexcursion_excursionid
ON ESE_CU_ELE.Venta_Excursion(excursion_id);

--------------- Venta_Hospedaje ---------------

CREATE INDEX index_ventahospedaje_ventanro
ON ESE_CU_ELE.Venta_Hospedaje(venta_nro);

CREATE INDEX index_ventahospedaje_habitacionid
ON ESE_CU_ELE.Venta_Hospedaje(habitacion_id);


PRINT(N'Indices creados');

PRINT(N'Migracion total completada');
