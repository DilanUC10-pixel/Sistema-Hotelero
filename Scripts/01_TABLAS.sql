-- =====================================================================
-- ARCHIVO 1: TABLAS, SECUENCIAS Y COMENTARIOS
-- Motor: Oracle 12c o superior
-- Orden de ejecucion: 01_tablas -> 02_triggers -> 03_inserts
-- Convenciones:
--   * estado: 1 = activo, 0 = inactivo (borrado logico, nunca DELETE)
--   * Cada tabla tiene su tabla _bit (bitacora) que registra cada
--     INSERT / UPDATE / Activate / Deactivate (alimentada por triggers)
--   * Dinero con NUMBER(p,2) para evitar errores de precision
-- =====================================================================

-- =====================================================
-- 1. ELIMINAR OBJETOS ANTERIORES
-- =====================================================

BEGIN
    FOR t IN (
        SELECT column_value AS nombre
        FROM TABLE(sys.odcivarchar2list(
            'RESERVACIONES_BIT',            'RESERVACIONES',
            'PAQUETES_PROMOCIONALES_BIT',   'PAQUETES_PROMOCIONALES',
            'TARJETAS_CREDITO_BIT',         'TARJETAS_CREDITO',
            'HABITACIONES_BIT',             'HABITACIONES',
            'CATALOGO_HABITACIONES_BIT',    'CATALOGO_HABITACIONES',
            'CLIENTES_BIT',                 'CLIENTES'
        ))
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || t.nombre || ' CASCADE CONSTRAINTS';
        EXCEPTION WHEN OTHERS THEN
            IF SQLCODE != -942 THEN RAISE; END IF;
        END;
    END LOOP;
END;
/

BEGIN
    FOR s IN (
        SELECT column_value AS nombre
        FROM TABLE(sys.odcivarchar2list(
            'SEQ_CLIENTES', 'SEQ_CATALOGO_HABITACIONES', 'SEQ_HABITACIONES',
            'SEQ_TARJETAS_CREDITO', 'SEQ_PAQUETES_PROMOCIONALES', 'SEQ_RESERVACIONES'
        ))
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.nombre;
        EXCEPTION WHEN OTHERS THEN
            IF SQLCODE != -2289 THEN RAISE; END IF;
        END;
    END LOOP;
END;
/

-- =====================================================
-- 2. SECUENCIAS
-- =====================================================

CREATE SEQUENCE seq_clientes               START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_catalogo_habitaciones  START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_habitaciones           START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_tarjetas_credito       START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_paquetes_promocionales START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_reservaciones          START WITH 1 INCREMENT BY 1 NOCACHE;

-- =====================================================================
-- 3. CLIENTES
-- estado: 1 = activo, 0 = inactivo
-- =====================================================================

CREATE TABLE clientes (
    idCliente      NUMBER DEFAULT seq_clientes.NEXTVAL PRIMARY KEY,
    nombre         VARCHAR2(100) NOT NULL,
    apellido       VARCHAR2(100) NOT NULL,
    telefono       VARCHAR2(20),
    correo         VARCHAR2(150) NOT NULL,
    direccion      VARCHAR2(200),
    fechaRegistro  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado         NUMBER(1) DEFAULT 1 NOT NULL CHECK (estado IN (0, 1)),

    CONSTRAINT uq_clientes_correo UNIQUE (correo),
    CONSTRAINT chk_clientes_correo
        CHECK (REGEXP_LIKE(correo, '^[^@ ]+@[^@ ]+\.[^@ ]+$'))
);

COMMENT ON TABLE clientes IS 'Tabla entidad de administracion de clientes del resort';

COMMENT ON COLUMN clientes.idCliente IS 'ID numerico identificador del cliente';
COMMENT ON COLUMN clientes.nombre IS 'Nombre del cliente';
COMMENT ON COLUMN clientes.apellido IS 'Apellido del cliente';
COMMENT ON COLUMN clientes.telefono IS 'Telefono del cliente';
COMMENT ON COLUMN clientes.correo IS 'Email del cliente (unico)';
COMMENT ON COLUMN clientes.direccion IS 'Direccion del cliente';
COMMENT ON COLUMN clientes.fechaRegistro IS 'Fecha de registro del cliente en la base de datos';
COMMENT ON COLUMN clientes.estado IS 'Estado logico del cliente (1 = activo, 0 = inactivo)';

CREATE TABLE clientes_bit (
    idClientes_bit    VARCHAR2(36) NOT NULL,
    idCliente         NUMBER NOT NULL,
    nombre            VARCHAR2(100),
    apellido          VARCHAR2(100),
    telefono          VARCHAR2(20),
    correo            VARCHAR2(150),
    direccion         VARCHAR2(200),
    fechaRegistro     TIMESTAMP,
    estado            NUMBER(1),
    fechaCreacion     DATE DEFAULT SYSDATE,
    fechaModificacion DATE,
    accion            VARCHAR2(25),

    CONSTRAINT pk_clientes_bit PRIMARY KEY (idClientes_bit),
    CONSTRAINT fk_clientes_bit FOREIGN KEY (idCliente)
        REFERENCES clientes (idCliente)
);

COMMENT ON TABLE clientes_bit IS 'Tabla bitacora para clientes';

COMMENT ON COLUMN clientes_bit.idClientes_bit IS 'ID UUID identificador de la bitacora';
COMMENT ON COLUMN clientes_bit.idCliente IS 'ID del cliente auditado';
COMMENT ON COLUMN clientes_bit.fechaCreacion IS 'Fecha de creacion o insercion';
COMMENT ON COLUMN clientes_bit.fechaModificacion IS 'Fecha de modificacion';
COMMENT ON COLUMN clientes_bit.accion IS 'Accion de auditoria: INSERT, UPDATE, Activate o Deactivate';

-- =====================================================================
-- 4. CATALOGO_HABITACIONES
-- estado: 1 = activa, 0 = inactiva
-- =====================================================================

CREATE TABLE catalogo_habitaciones (
    idCatalogoHabitacion NUMBER DEFAULT seq_catalogo_habitaciones.NEXTVAL PRIMARY KEY,
    nombreCategoria      VARCHAR2(100) NOT NULL,
    capacidadPersonas    NUMBER(2) NOT NULL,
    descripcion          VARCHAR2(500),
    precioBase           NUMBER(10,2) NOT NULL,
    amenidades           VARCHAR2(500),
    estado               NUMBER(1) DEFAULT 1 NOT NULL CHECK (estado IN (0, 1)),

    CONSTRAINT uq_catalogo_nombre    UNIQUE (nombreCategoria),
    CONSTRAINT chk_catalogo_capacidad CHECK (capacidadPersonas > 0),
    CONSTRAINT chk_catalogo_precio    CHECK (precioBase >= 0)
);

COMMENT ON TABLE catalogo_habitaciones IS 'Tabla entidad del catalogo de categorias de habitacion';

COMMENT ON COLUMN catalogo_habitaciones.idCatalogoHabitacion IS 'ID numerico identificador de la categoria';
COMMENT ON COLUMN catalogo_habitaciones.nombreCategoria IS 'Nombre de la categoria (unico)';
COMMENT ON COLUMN catalogo_habitaciones.capacidadPersonas IS 'Capacidad de personas de la categoria';
COMMENT ON COLUMN catalogo_habitaciones.descripcion IS 'Descripcion de la categoria';
COMMENT ON COLUMN catalogo_habitaciones.precioBase IS 'Precio base de referencia por noche';
COMMENT ON COLUMN catalogo_habitaciones.amenidades IS 'Amenidades incluidas en la categoria';
COMMENT ON COLUMN catalogo_habitaciones.estado IS 'Estado logico de la categoria (1 = activa, 0 = inactiva)';

CREATE TABLE catalogo_habitaciones_bit (
    idCatalogo_habitaciones_bit VARCHAR2(36) NOT NULL,
    idCatalogoHabitacion        NUMBER NOT NULL,
    nombreCategoria             VARCHAR2(100),
    capacidadPersonas           NUMBER(2),
    descripcion                 VARCHAR2(500),
    precioBase                  NUMBER(10,2),
    amenidades                  VARCHAR2(500),
    estado                      NUMBER(1),
    fechaAuditoria              DATE DEFAULT SYSDATE,
    accion                      VARCHAR2(25),

    CONSTRAINT pk_catalogo_hab_bit PRIMARY KEY (idCatalogo_habitaciones_bit),
    CONSTRAINT fk_catalogo_hab_bit FOREIGN KEY (idCatalogoHabitacion)
        REFERENCES catalogo_habitaciones (idCatalogoHabitacion)
);

COMMENT ON TABLE catalogo_habitaciones_bit IS 'Tabla bitacora para el catalogo de habitaciones';

COMMENT ON COLUMN catalogo_habitaciones_bit.idCatalogo_habitaciones_bit IS 'ID UUID identificador de la bitacora';
COMMENT ON COLUMN catalogo_habitaciones_bit.idCatalogoHabitacion IS 'ID de la categoria auditada';
COMMENT ON COLUMN catalogo_habitaciones_bit.fechaAuditoria IS 'Fecha de registro de auditoria';
COMMENT ON COLUMN catalogo_habitaciones_bit.accion IS 'Accion de auditoria: INSERT, UPDATE, Activate o Deactivate';

-- =====================================================================
-- 5. HABITACIONES
-- disponible: 1 = libre para asignacion general, 0 = fuera de servicio
--             (la disponibilidad real por fechas se valida contra RESERVACIONES)
-- estado:     1 = activa, 0 = inactiva (borrado logico)
-- =====================================================================

CREATE TABLE habitaciones (
    idHabitacion         NUMBER DEFAULT seq_habitaciones.NEXTVAL PRIMARY KEY,
    numeroHabitacion     VARCHAR2(10) NOT NULL,
    piso                 NUMBER(2) NOT NULL,
    descripcion          VARCHAR2(500),
    precioBaseNoche      NUMBER(10,2) NOT NULL,
    capacidad            NUMBER(2) NOT NULL,
    idCatalogoHabitacion NUMBER NOT NULL,
    disponible           NUMBER(1) DEFAULT 1 NOT NULL CHECK (disponible IN (0, 1)),
    estado               NUMBER(1) DEFAULT 1 NOT NULL CHECK (estado IN (0, 1)),

    CONSTRAINT uq_habitaciones_numero UNIQUE (numeroHabitacion),
    CONSTRAINT fk_habitaciones_catalogo
        FOREIGN KEY (idCatalogoHabitacion)
        REFERENCES catalogo_habitaciones (idCatalogoHabitacion),
    CONSTRAINT chk_habitaciones_precio    CHECK (precioBaseNoche >= 0),
    CONSTRAINT chk_habitaciones_capacidad CHECK (capacidad > 0)
);

COMMENT ON TABLE habitaciones IS 'Tabla entidad de administracion de habitaciones del resort';

COMMENT ON COLUMN habitaciones.idHabitacion IS 'ID numerico identificador de la habitacion';
COMMENT ON COLUMN habitaciones.numeroHabitacion IS 'Numero de la habitacion (unico)';
COMMENT ON COLUMN habitaciones.piso IS 'Piso donde se ubica la habitacion';
COMMENT ON COLUMN habitaciones.descripcion IS 'Descripcion de la habitacion';
COMMENT ON COLUMN habitaciones.precioBaseNoche IS 'Precio por noche usado para calcular las reservaciones';
COMMENT ON COLUMN habitaciones.capacidad IS 'Maximo de huespedes permitidos';
COMMENT ON COLUMN habitaciones.idCatalogoHabitacion IS 'ID de la categoria del catalogo a la que pertenece';
COMMENT ON COLUMN habitaciones.disponible IS 'Disponibilidad general (1 = libre para asignacion, 0 = fuera de servicio)';
COMMENT ON COLUMN habitaciones.estado IS 'Estado logico de la habitacion (1 = activa, 0 = inactiva)';

CREATE TABLE habitaciones_bit (
    idHabitaciones_bit   VARCHAR2(36) NOT NULL,
    idHabitacion         NUMBER NOT NULL,
    numeroHabitacion     VARCHAR2(10),
    piso                 NUMBER(2),
    descripcion          VARCHAR2(500),
    precioBaseNoche      NUMBER(10,2),
    capacidad            NUMBER(2),
    idCatalogoHabitacion NUMBER,
    disponible           NUMBER(1),
    estado               NUMBER(1),
    fechaAuditoria       DATE DEFAULT SYSDATE,
    accion               VARCHAR2(25),

    CONSTRAINT pk_habitaciones_bit PRIMARY KEY (idHabitaciones_bit),
    CONSTRAINT fk_habitaciones_bit FOREIGN KEY (idHabitacion)
        REFERENCES habitaciones (idHabitacion)
);

COMMENT ON TABLE habitaciones_bit IS 'Tabla bitacora para habitaciones';

COMMENT ON COLUMN habitaciones_bit.idHabitaciones_bit IS 'ID UUID identificador de la bitacora';
COMMENT ON COLUMN habitaciones_bit.idHabitacion IS 'ID de la habitacion auditada';
COMMENT ON COLUMN habitaciones_bit.fechaAuditoria IS 'Fecha de registro de auditoria';
COMMENT ON COLUMN habitaciones_bit.accion IS 'Accion de auditoria: INSERT, UPDATE, Activate o Deactivate';

-- =====================================================================
-- 6. TARJETAS_CREDITO
-- Solo con fines academicos se almacena el numero completo.
-- Se agrega UNIQUE (idTarjeta, idCliente) para que RESERVACIONES pueda
-- garantizar que la tarjeta pertenece al cliente de la reservacion.
-- =====================================================================

CREATE TABLE tarjetas_credito (
    idTarjeta        NUMBER DEFAULT seq_tarjetas_credito.NEXTVAL PRIMARY KEY,
    titular          VARCHAR2(120) NOT NULL,
    numeroTarjeta    VARCHAR2(16) NOT NULL,
    fechaExpiracion  DATE NOT NULL,
    cvv              VARCHAR2(4),
    banco            VARCHAR2(80),
    tipoTarjeta      VARCHAR2(10) NOT NULL,
    idCliente        NUMBER NOT NULL,
    estado           NUMBER(1) DEFAULT 1 NOT NULL CHECK (estado IN (0, 1)),

    CONSTRAINT fk_tarjetas_clientes
        FOREIGN KEY (idCliente)
        REFERENCES clientes (idCliente),

    CONSTRAINT uq_tarjetas_cliente_numero UNIQUE (idCliente, numeroTarjeta),
    CONSTRAINT uq_tarjetas_id_cliente     UNIQUE (idTarjeta, idCliente),

    CONSTRAINT chk_tarjetas_numero CHECK (REGEXP_LIKE(numeroTarjeta, '^[0-9]{13,16}$')),
    CONSTRAINT chk_tarjetas_cvv    CHECK (cvv IS NULL OR REGEXP_LIKE(cvv, '^[0-9]{3,4}$')),
    CONSTRAINT chk_tarjetas_tipo   CHECK (tipoTarjeta IN ('CREDITO', 'DEBITO'))
);

COMMENT ON TABLE tarjetas_credito IS 'Tabla entidad de tarjetas de los clientes (almacenamiento en claro solo con fines academicos)';

COMMENT ON COLUMN tarjetas_credito.idTarjeta IS 'ID numerico identificador de la tarjeta';
COMMENT ON COLUMN tarjetas_credito.titular IS 'Nombre del titular de la tarjeta';
COMMENT ON COLUMN tarjetas_credito.numeroTarjeta IS 'Numero de la tarjeta (13 a 16 digitos)';
COMMENT ON COLUMN tarjetas_credito.fechaExpiracion IS 'Ultimo dia del mes de expiracion de la tarjeta';
COMMENT ON COLUMN tarjetas_credito.cvv IS 'Codigo de seguridad (opcional, solo academico)';
COMMENT ON COLUMN tarjetas_credito.banco IS 'Banco emisor';
COMMENT ON COLUMN tarjetas_credito.tipoTarjeta IS 'Tipo de tarjeta (CREDITO o DEBITO)';
COMMENT ON COLUMN tarjetas_credito.idCliente IS 'ID del cliente propietario de la tarjeta';
COMMENT ON COLUMN tarjetas_credito.estado IS 'Estado logico de la tarjeta (1 = activa, 0 = inactiva)';

-- La bitacora no guarda numeroTarjeta ni cvv por seguridad
CREATE TABLE tarjetas_credito_bit (
    idTarjetas_credito_bit VARCHAR2(36) NOT NULL,
    idTarjeta              NUMBER NOT NULL,
    titular                VARCHAR2(120),
    fechaExpiracion        DATE,
    banco                  VARCHAR2(80),
    tipoTarjeta            VARCHAR2(10),
    idCliente              NUMBER,
    estado                 NUMBER(1),
    fechaAuditoria         DATE DEFAULT SYSDATE,
    accion                 VARCHAR2(25),

    CONSTRAINT pk_tarjetas_credito_bit PRIMARY KEY (idTarjetas_credito_bit),
    CONSTRAINT fk_tarjetas_credito_bit FOREIGN KEY (idTarjeta)
        REFERENCES tarjetas_credito (idTarjeta)
);

COMMENT ON TABLE tarjetas_credito_bit IS 'Tabla bitacora para tarjetas (no almacena numero ni cvv)';

COMMENT ON COLUMN tarjetas_credito_bit.idTarjetas_credito_bit IS 'ID UUID identificador de la bitacora';
COMMENT ON COLUMN tarjetas_credito_bit.idTarjeta IS 'ID de la tarjeta auditada';
COMMENT ON COLUMN tarjetas_credito_bit.fechaAuditoria IS 'Fecha de registro de auditoria';
COMMENT ON COLUMN tarjetas_credito_bit.accion IS 'Accion de auditoria: INSERT, UPDATE, Activate o Deactivate';

-- =====================================================================
-- 7. PAQUETES_PROMOCIONALES
-- estado: 1 = activo, 0 = inactivo
-- =====================================================================

CREATE TABLE paquetes_promocionales (
    idPaquete            NUMBER DEFAULT seq_paquetes_promocionales.NEXTVAL PRIMARY KEY,
    nombrePaquete        VARCHAR2(120) NOT NULL,
    descripcion          VARCHAR2(500),
    porcentajeDescuento  NUMBER(5,2) NOT NULL,
    fechaInicioVigencia  DATE NOT NULL,
    fechaFinVigencia     DATE NOT NULL,
    condiciones          VARCHAR2(500),
    estado               NUMBER(1) DEFAULT 1 NOT NULL CHECK (estado IN (0, 1)),

    CONSTRAINT chk_paquetes_descuento CHECK (porcentajeDescuento BETWEEN 0 AND 100),
    CONSTRAINT chk_paquetes_vigencia  CHECK (fechaFinVigencia >= fechaInicioVigencia)
);

COMMENT ON TABLE paquetes_promocionales IS 'Tabla entidad de paquetes promocionales con descuento';

COMMENT ON COLUMN paquetes_promocionales.idPaquete IS 'ID numerico identificador del paquete';
COMMENT ON COLUMN paquetes_promocionales.nombrePaquete IS 'Nombre del paquete';
COMMENT ON COLUMN paquetes_promocionales.descripcion IS 'Descripcion del paquete';
COMMENT ON COLUMN paquetes_promocionales.porcentajeDescuento IS 'Porcentaje de descuento (0 a 100)';
COMMENT ON COLUMN paquetes_promocionales.fechaInicioVigencia IS 'Primer dia de vigencia del paquete';
COMMENT ON COLUMN paquetes_promocionales.fechaFinVigencia IS 'Ultimo dia de vigencia del paquete';
COMMENT ON COLUMN paquetes_promocionales.condiciones IS 'Condiciones para aplicar el paquete';
COMMENT ON COLUMN paquetes_promocionales.estado IS 'Estado logico del paquete (1 = activo, 0 = inactivo)';

CREATE TABLE paquetes_promocionales_bit (
    idPaquetes_promocionales_bit VARCHAR2(36) NOT NULL,
    idPaquete                    NUMBER NOT NULL,
    nombrePaquete                VARCHAR2(120),
    descripcion                  VARCHAR2(500),
    porcentajeDescuento          NUMBER(5,2),
    fechaInicioVigencia          DATE,
    fechaFinVigencia             DATE,
    condiciones                  VARCHAR2(500),
    estado                       NUMBER(1),
    fechaAuditoria               DATE DEFAULT SYSDATE,
    accion                       VARCHAR2(25),

    CONSTRAINT pk_paquetes_prom_bit PRIMARY KEY (idPaquetes_promocionales_bit),
    CONSTRAINT fk_paquetes_prom_bit FOREIGN KEY (idPaquete)
        REFERENCES paquetes_promocionales (idPaquete)
);

COMMENT ON TABLE paquetes_promocionales_bit IS 'Tabla bitacora para paquetes promocionales';

COMMENT ON COLUMN paquetes_promocionales_bit.idPaquetes_promocionales_bit IS 'ID UUID identificador de la bitacora';
COMMENT ON COLUMN paquetes_promocionales_bit.idPaquete IS 'ID del paquete auditado';
COMMENT ON COLUMN paquetes_promocionales_bit.fechaAuditoria IS 'Fecha de registro de auditoria';
COMMENT ON COLUMN paquetes_promocionales_bit.accion IS 'Accion de auditoria: INSERT, UPDATE, Activate o Deactivate';

-- =====================================================================
-- 8. RESERVACIONES
-- estatusReservacion: PENDIENTE, CONFIRMADA, CANCELADA, FINALIZADA
-- estado: 1 = activa, 0 = inactiva (borrado logico)
-- idPaquete es opcional (NULL = sin promocion)
-- =====================================================================

CREATE TABLE reservaciones (
    idReservacion       NUMBER DEFAULT seq_reservaciones.NEXTVAL PRIMARY KEY,
    idCliente           NUMBER NOT NULL,
    idHabitacion        NUMBER NOT NULL,
    idTarjeta           NUMBER NOT NULL,
    idPaquete           NUMBER,
    fechaEntrada        DATE NOT NULL,
    fechaSalida         DATE NOT NULL,
    cantidadHuespedes   NUMBER(2) NOT NULL,
    numeroNoches        NUMBER(3) NOT NULL,
    precioNoche         NUMBER(10,2) NOT NULL,
    subtotal            NUMBER(12,2) NOT NULL,
    descuentoAplicado   NUMBER(12,2) DEFAULT 0 NOT NULL,
    totalPagar          NUMBER(12,2) NOT NULL,
    estatusReservacion  VARCHAR2(15) DEFAULT 'PENDIENTE' NOT NULL,
    fechaReservacion    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado              NUMBER(1) DEFAULT 1 NOT NULL CHECK (estado IN (0, 1)),

    CONSTRAINT fk_reservaciones_clientes
        FOREIGN KEY (idCliente)
        REFERENCES clientes (idCliente),

    CONSTRAINT fk_reservaciones_habitaciones
        FOREIGN KEY (idHabitacion)
        REFERENCES habitaciones (idHabitacion),

    CONSTRAINT fk_reservaciones_paquetes
        FOREIGN KEY (idPaquete)
        REFERENCES paquetes_promocionales (idPaquete),

    -- La tarjeta debe pertenecer al mismo cliente de la reservacion
    CONSTRAINT fk_reservaciones_tarjeta_cliente
        FOREIGN KEY (idTarjeta, idCliente)
        REFERENCES tarjetas_credito (idTarjeta, idCliente),

    CONSTRAINT chk_reservaciones_fechas    CHECK (fechaSalida > fechaEntrada),
    CONSTRAINT chk_reservaciones_huespedes CHECK (cantidadHuespedes > 0),
    CONSTRAINT chk_reservaciones_noches    CHECK (numeroNoches > 0),
    CONSTRAINT chk_reservaciones_montos
        CHECK (precioNoche >= 0 AND subtotal >= 0 AND descuentoAplicado >= 0 AND totalPagar >= 0),
    CONSTRAINT chk_reservaciones_estatus
        CHECK (estatusReservacion IN ('PENDIENTE', 'CONFIRMADA', 'CANCELADA', 'FINALIZADA'))
);

COMMENT ON TABLE reservaciones IS 'Tabla entidad de reservaciones de habitaciones';

COMMENT ON COLUMN reservaciones.idReservacion IS 'ID numerico identificador de la reservacion';
COMMENT ON COLUMN reservaciones.idCliente IS 'ID del cliente que reserva';
COMMENT ON COLUMN reservaciones.idHabitacion IS 'ID de la habitacion reservada';
COMMENT ON COLUMN reservaciones.idTarjeta IS 'ID de la tarjeta asociada (debe pertenecer al cliente)';
COMMENT ON COLUMN reservaciones.idPaquete IS 'ID del paquete promocional aplicado (nulo si no aplica)';
COMMENT ON COLUMN reservaciones.fechaEntrada IS 'Fecha de entrada (check-in)';
COMMENT ON COLUMN reservaciones.fechaSalida IS 'Fecha de salida (check-out), debe ser mayor a la de entrada';
COMMENT ON COLUMN reservaciones.cantidadHuespedes IS 'Cantidad de huespedes';
COMMENT ON COLUMN reservaciones.numeroNoches IS 'Numero de noches (fechaSalida - fechaEntrada)';
COMMENT ON COLUMN reservaciones.precioNoche IS 'Precio por noche aplicado al momento de reservar';
COMMENT ON COLUMN reservaciones.subtotal IS 'numeroNoches * precioNoche';
COMMENT ON COLUMN reservaciones.descuentoAplicado IS 'Monto descontado por el paquete promocional';
COMMENT ON COLUMN reservaciones.totalPagar IS 'subtotal - descuentoAplicado';
COMMENT ON COLUMN reservaciones.estatusReservacion IS 'Estatus del negocio (PENDIENTE, CONFIRMADA, CANCELADA, FINALIZADA)';
COMMENT ON COLUMN reservaciones.fechaReservacion IS 'Fecha y hora en que se registro la reservacion';
COMMENT ON COLUMN reservaciones.estado IS 'Estado logico de la reservacion (1 = activa, 0 = inactiva)';

CREATE TABLE reservaciones_bit (
    idReservaciones_bit VARCHAR2(36) NOT NULL,
    idReservacion       NUMBER NOT NULL,
    idCliente           NUMBER,
    idHabitacion        NUMBER,
    idTarjeta           NUMBER,
    idPaquete           NUMBER,
    fechaEntrada        DATE,
    fechaSalida         DATE,
    cantidadHuespedes   NUMBER(2),
    numeroNoches        NUMBER(3),
    precioNoche         NUMBER(10,2),
    subtotal            NUMBER(12,2),
    descuentoAplicado   NUMBER(12,2),
    totalPagar          NUMBER(12,2),
    estatusReservacion  VARCHAR2(15),
    fechaReservacion    TIMESTAMP,
    estado              NUMBER(1),
    fechaCreacion       DATE DEFAULT SYSDATE,
    fechaModificacion   DATE,
    accion              VARCHAR2(25),

    CONSTRAINT pk_reservaciones_bit PRIMARY KEY (idReservaciones_bit),
    CONSTRAINT fk_reservaciones_bit FOREIGN KEY (idReservacion)
        REFERENCES reservaciones (idReservacion)
);

COMMENT ON TABLE reservaciones_bit IS 'Tabla bitacora para reservaciones';

COMMENT ON COLUMN reservaciones_bit.idReservaciones_bit IS 'ID UUID identificador de la bitacora';
COMMENT ON COLUMN reservaciones_bit.idReservacion IS 'ID de la reservacion auditada';
COMMENT ON COLUMN reservaciones_bit.fechaCreacion IS 'Fecha de creacion o insercion';
COMMENT ON COLUMN reservaciones_bit.fechaModificacion IS 'Fecha de modificacion';
COMMENT ON COLUMN reservaciones_bit.accion IS 'Accion de auditoria: INSERT, UPDATE, Confirm, Cancel, Finish, Activate o Deactivate';