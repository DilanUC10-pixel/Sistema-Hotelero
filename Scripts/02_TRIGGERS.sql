-- =====================================================================
-- ULA-RESORT - ARCHIVO 2: TRIGGERS (REGLAS DE NEGOCIO Y BITACORA)
-- Ejecutar despues de 01_ula_resort_tablas.sql
--
-- NOTA: la validacion de TRASLAPE DE FECHAS (RN-02 / RNF-11) NO se hace
-- en trigger porque un trigger de fila no puede consultar su propia tabla
-- (ORA-04091, tabla mutante). Esa validacion va en el Service/Repository
-- de Spring Boot; ver la consulta de disponibilidad en 03_ula_resort_inserts.sql
-- =====================================================================

-- =====================================================================
-- CLIENTES: BITACORA
-- =====================================================================

CREATE OR REPLACE TRIGGER trg_clientes_bit
AFTER INSERT OR UPDATE ON clientes
FOR EACH ROW
DECLARE
    v_accion             VARCHAR2(25);
    v_fecha_creacion     DATE := NULL;
    v_fecha_modificacion DATE := NULL;
BEGIN
    IF INSERTING THEN
        v_accion := 'INSERT';
        v_fecha_creacion := SYSDATE;

    ELSIF UPDATING THEN
        v_fecha_modificacion := SYSDATE;
        v_fecha_creacion := CAST(:OLD.fechaRegistro AS DATE);

        IF :OLD.estado = 0 AND :NEW.estado = 1 THEN
            v_accion := 'Activate';
        ELSIF :OLD.estado = 1 AND :NEW.estado = 0 THEN
            v_accion := 'Deactivate';
        ELSE
            v_accion := 'UPDATE';
        END IF;
    END IF;

    INSERT INTO clientes_bit (
        idClientes_bit, idCliente, nombre, apellido, telefono, correo,
        direccion, fechaRegistro, estado,
        fechaCreacion, fechaModificacion, accion
    )
    VALUES (
        RAWTOHEX(SYS_GUID()), :NEW.idCliente, :NEW.nombre, :NEW.apellido,
        :NEW.telefono, :NEW.correo, :NEW.direccion, :NEW.fechaRegistro,
        :NEW.estado,
        v_fecha_creacion, v_fecha_modificacion, v_accion
    );
END trg_clientes_bit;
/

-- =====================================================================
-- CATALOGO_HABITACIONES: BITACORA
-- =====================================================================

CREATE OR REPLACE TRIGGER trg_catalogo_habitaciones_bit
AFTER INSERT OR UPDATE ON catalogo_habitaciones
FOR EACH ROW
DECLARE
    v_accion VARCHAR2(25);
BEGIN
    IF INSERTING THEN
        v_accion := 'INSERT';

    ELSIF UPDATING THEN
        IF :OLD.estado = 0 AND :NEW.estado = 1 THEN
            v_accion := 'Activate';
        ELSIF :OLD.estado = 1 AND :NEW.estado = 0 THEN
            v_accion := 'Deactivate';
        ELSE
            v_accion := 'UPDATE';
        END IF;
    END IF;

    INSERT INTO catalogo_habitaciones_bit (
        idCatalogo_habitaciones_bit, idCatalogoHabitacion, nombreCategoria,
        capacidadPersonas, descripcion, precioBase, amenidades, estado,
        fechaAuditoria, accion
    )
    VALUES (
        RAWTOHEX(SYS_GUID()), :NEW.idCatalogoHabitacion, :NEW.nombreCategoria,
        :NEW.capacidadPersonas, :NEW.descripcion, :NEW.precioBase,
        :NEW.amenidades, :NEW.estado,
        SYSDATE, v_accion
    );
END trg_catalogo_habitaciones_bit;
/

-- =====================================================================
-- HABITACIONES: REGLAS DE NEGOCIO
--  - La categoria del catalogo debe existir y estar activa
--    (se valida al registrar o al cambiar de categoria).
-- =====================================================================

CREATE OR REPLACE TRIGGER trg_habitaciones_reglas
BEFORE INSERT OR UPDATE ON habitaciones
FOR EACH ROW
DECLARE
    v_estado_catalogo NUMBER(1);
BEGIN
    IF INSERTING OR :NEW.idCatalogoHabitacion != :OLD.idCatalogoHabitacion THEN

        BEGIN
            SELECT estado
            INTO v_estado_catalogo
            FROM catalogo_habitaciones
            WHERE idCatalogoHabitacion = :NEW.idCatalogoHabitacion;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20020,
                    'La categoria del catalogo de habitaciones no existe.');
        END;

        IF v_estado_catalogo != 1 THEN
            RAISE_APPLICATION_ERROR(-20021,
                'La categoria del catalogo de habitaciones esta inactiva.');
        END IF;

    END IF;
END trg_habitaciones_reglas;
/

-- =====================================================================
-- HABITACIONES: BITACORA
-- =====================================================================

CREATE OR REPLACE TRIGGER trg_habitaciones_bit
AFTER INSERT OR UPDATE ON habitaciones
FOR EACH ROW
DECLARE
    v_accion VARCHAR2(25);
BEGIN
    IF INSERTING THEN
        v_accion := 'INSERT';

    ELSIF UPDATING THEN
        IF :OLD.estado = 0 AND :NEW.estado = 1 THEN
            v_accion := 'Activate';
        ELSIF :OLD.estado = 1 AND :NEW.estado = 0 THEN
            v_accion := 'Deactivate';
        ELSE
            v_accion := 'UPDATE';
        END IF;
    END IF;

    INSERT INTO habitaciones_bit (
        idHabitaciones_bit, idHabitacion, numeroHabitacion, piso, descripcion,
        precioBaseNoche, capacidad, idCatalogoHabitacion, disponible, estado,
        fechaAuditoria, accion
    )
    VALUES (
        RAWTOHEX(SYS_GUID()), :NEW.idHabitacion, :NEW.numeroHabitacion,
        :NEW.piso, :NEW.descripcion, :NEW.precioBaseNoche, :NEW.capacidad,
        :NEW.idCatalogoHabitacion, :NEW.disponible, :NEW.estado,
        SYSDATE, v_accion
    );
END trg_habitaciones_bit;
/

-- =====================================================================
-- TARJETAS_CREDITO: REGLAS DE NEGOCIO (solo al registrar)
--  - El cliente debe existir y estar activo.
--  - La tarjeta no puede estar vencida.
-- =====================================================================

CREATE OR REPLACE TRIGGER trg_tarjetas_reglas
BEFORE INSERT ON tarjetas_credito
FOR EACH ROW
DECLARE
    v_estado_cliente NUMBER(1);
BEGIN
    BEGIN
        SELECT estado
        INTO v_estado_cliente
        FROM clientes
        WHERE idCliente = :NEW.idCliente;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20010,
                'El cliente de la tarjeta no existe.');
    END;

    IF v_estado_cliente != 1 THEN
        RAISE_APPLICATION_ERROR(-20011,
            'No se puede registrar una tarjeta a un cliente inactivo.');
    END IF;

    IF :NEW.fechaExpiracion < TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20012,
            'La tarjeta esta vencida.');
    END IF;
END trg_tarjetas_reglas;
/

-- =====================================================================
-- TARJETAS_CREDITO: BITACORA (no guarda numeroTarjeta ni cvv)
-- =====================================================================

CREATE OR REPLACE TRIGGER trg_tarjetas_credito_bit
AFTER INSERT OR UPDATE ON tarjetas_credito
FOR EACH ROW
DECLARE
    v_accion VARCHAR2(25);
BEGIN
    IF INSERTING THEN
        v_accion := 'INSERT';

    ELSIF UPDATING THEN
        IF :OLD.estado = 0 AND :NEW.estado = 1 THEN
            v_accion := 'Activate';
        ELSIF :OLD.estado = 1 AND :NEW.estado = 0 THEN
            v_accion := 'Deactivate';
        ELSE
            v_accion := 'UPDATE';
        END IF;
    END IF;

    INSERT INTO tarjetas_credito_bit (
        idTarjetas_credito_bit, idTarjeta, titular, fechaExpiracion, banco,
        tipoTarjeta, idCliente, estado, fechaAuditoria, accion
    )
    VALUES (
        RAWTOHEX(SYS_GUID()), :NEW.idTarjeta, :NEW.titular,
        :NEW.fechaExpiracion, :NEW.banco, :NEW.tipoTarjeta, :NEW.idCliente,
        :NEW.estado, SYSDATE, v_accion
    );
END trg_tarjetas_credito_bit;
/

-- =====================================================================
-- PAQUETES_PROMOCIONALES: BITACORA
-- =====================================================================

CREATE OR REPLACE TRIGGER trg_paquetes_promocionales_bit
AFTER INSERT OR UPDATE ON paquetes_promocionales
FOR EACH ROW
DECLARE
    v_accion VARCHAR2(25);
BEGIN
    IF INSERTING THEN
        v_accion := 'INSERT';

    ELSIF UPDATING THEN
        IF :OLD.estado = 0 AND :NEW.estado = 1 THEN
            v_accion := 'Activate';
        ELSIF :OLD.estado = 1 AND :NEW.estado = 0 THEN
            v_accion := 'Deactivate';
        ELSE
            v_accion := 'UPDATE';
        END IF;
    END IF;

    INSERT INTO paquetes_promocionales_bit (
        idPaquetes_promocionales_bit, idPaquete, nombrePaquete, descripcion,
        porcentajeDescuento, fechaInicioVigencia, fechaFinVigencia,
        condiciones, estado, fechaAuditoria, accion
    )
    VALUES (
        RAWTOHEX(SYS_GUID()), :NEW.idPaquete, :NEW.nombrePaquete,
        :NEW.descripcion, :NEW.porcentajeDescuento, :NEW.fechaInicioVigencia,
        :NEW.fechaFinVigencia, :NEW.condiciones, :NEW.estado,
        SYSDATE, v_accion
    );
END trg_paquetes_promocionales_bit;
/

-- =====================================================================
-- RESERVACIONES: REGLAS DE NEGOCIO (solo al registrar)
--  - RN-05: el cliente debe existir y estar activo.
--  - La habitacion debe existir, estar activa y disponible, y su
--    categoria del catalogo debe estar vigente (activa).
--  - RN-04: los huespedes no pueden exceder la capacidad de la habitacion.
--  - RN-06: la tarjeta debe existir, ser del cliente, estar activa y no vencida.
--  - RN-03: el paquete (si se envia) debe estar activo y vigente hoy.
--  - El calculo de noches, subtotal, descuento y total lo realiza el Service.
-- =====================================================================

CREATE OR REPLACE TRIGGER trg_reservaciones_reglas
BEFORE INSERT ON reservaciones
FOR EACH ROW
DECLARE
    v_estado_cliente  NUMBER(1);
    v_estado_hab      NUMBER(1);
    v_disponible      NUMBER(1);
    v_capacidad       NUMBER(2);
    v_estado_catalogo NUMBER(1);
    v_estado_tarjeta  NUMBER(1);
    v_exp_tarjeta     DATE;
    v_estado_paquete  NUMBER(1);
    v_inicio_paquete  DATE;
    v_fin_paquete     DATE;
BEGIN
    -- CLIENTE EXISTENTE Y ACTIVO
    BEGIN
        SELECT estado
        INTO v_estado_cliente
        FROM clientes
        WHERE idCliente = :NEW.idCliente;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20030,
                'El cliente no existe.');
    END;

    IF v_estado_cliente != 1 THEN
        RAISE_APPLICATION_ERROR(-20031,
            'Un cliente inactivo no puede generar reservaciones.');
    END IF;

    -- HABITACION EXISTENTE, ACTIVA, DISPONIBLE Y CON CATEGORIA VIGENTE
    BEGIN
        SELECT h.estado, h.disponible, h.capacidad, c.estado
        INTO v_estado_hab, v_disponible, v_capacidad, v_estado_catalogo
        FROM habitaciones h
        JOIN catalogo_habitaciones c
          ON c.idCatalogoHabitacion = h.idCatalogoHabitacion
        WHERE h.idHabitacion = :NEW.idHabitacion;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20032,
                'La habitacion no existe.');
    END;

    IF v_estado_hab != 1 OR v_disponible != 1 THEN
        RAISE_APPLICATION_ERROR(-20033,
            'La habitacion esta inactiva o fuera de servicio.');
    END IF;

    IF v_estado_catalogo != 1 THEN
        RAISE_APPLICATION_ERROR(-20034,
            'La categoria de la habitacion no esta vigente.');
    END IF;

    -- CAPACIDAD
    IF :NEW.cantidadHuespedes > v_capacidad THEN
        RAISE_APPLICATION_ERROR(-20035,
            'La cantidad de huespedes excede la capacidad de la habitacion.');
    END IF;

    -- TARJETA DEL CLIENTE, ACTIVA Y NO VENCIDA
    BEGIN
        SELECT estado, fechaExpiracion
        INTO v_estado_tarjeta, v_exp_tarjeta
        FROM tarjetas_credito
        WHERE idTarjeta = :NEW.idTarjeta
          AND idCliente = :NEW.idCliente;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20036,
                'La tarjeta no existe o no pertenece al cliente.');
    END;

    IF v_estado_tarjeta != 1 THEN
        RAISE_APPLICATION_ERROR(-20037,
            'Una tarjeta inactiva no puede utilizarse en una reservacion.');
    END IF;

    IF v_exp_tarjeta < TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20038,
            'La tarjeta esta vencida.');
    END IF;

    -- PAQUETE PROMOCIONAL (OPCIONAL): ACTIVO Y VIGENTE
    IF :NEW.idPaquete IS NOT NULL THEN
        BEGIN
            SELECT estado, fechaInicioVigencia, fechaFinVigencia
            INTO v_estado_paquete, v_inicio_paquete, v_fin_paquete
            FROM paquetes_promocionales
            WHERE idPaquete = :NEW.idPaquete;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20039,
                    'El paquete promocional no existe.');
        END;

        IF v_estado_paquete != 1
           OR TRUNC(SYSDATE) NOT BETWEEN v_inicio_paquete AND v_fin_paquete THEN
            RAISE_APPLICATION_ERROR(-20040,
                'El paquete promocional esta inactivo o fuera de vigencia.');
        END IF;
    END IF;
END trg_reservaciones_reglas;
/

-- =====================================================================
-- RESERVACIONES: BITACORA
-- Acciones por cambio de estatus: Confirm, Cancel, Finish
-- Acciones por borrado logico:    Activate, Deactivate
-- =====================================================================

CREATE OR REPLACE TRIGGER trg_reservaciones_bit
AFTER INSERT OR UPDATE ON reservaciones
FOR EACH ROW
DECLARE
    v_accion             VARCHAR2(25);
    v_fecha_creacion     DATE := NULL;
    v_fecha_modificacion DATE := NULL;
BEGIN
    IF INSERTING THEN
        v_accion := 'INSERT';
        v_fecha_creacion := SYSDATE;

    ELSIF UPDATING THEN
        v_fecha_modificacion := SYSDATE;
        v_fecha_creacion := CAST(:OLD.fechaReservacion AS DATE);

        IF :OLD.estatusReservacion != 'CANCELADA' AND :NEW.estatusReservacion = 'CANCELADA' THEN
            v_accion := 'Cancel';
        ELSIF :OLD.estatusReservacion != 'FINALIZADA' AND :NEW.estatusReservacion = 'FINALIZADA' THEN
            v_accion := 'Finish';
        ELSIF :OLD.estatusReservacion != 'CONFIRMADA' AND :NEW.estatusReservacion = 'CONFIRMADA' THEN
            v_accion := 'Confirm';
        ELSIF :OLD.estado = 0 AND :NEW.estado = 1 THEN
            v_accion := 'Activate';
        ELSIF :OLD.estado = 1 AND :NEW.estado = 0 THEN
            v_accion := 'Deactivate';
        ELSE
            v_accion := 'UPDATE';
        END IF;
    END IF;

    INSERT INTO reservaciones_bit (
        idReservaciones_bit, idReservacion, idCliente, idHabitacion, idTarjeta,
        idPaquete, fechaEntrada, fechaSalida, cantidadHuespedes, numeroNoches,
        precioNoche, subtotal, descuentoAplicado, totalPagar,
        estatusReservacion, fechaReservacion, estado,
        fechaCreacion, fechaModificacion, accion
    )
    VALUES (
        RAWTOHEX(SYS_GUID()), :NEW.idReservacion, :NEW.idCliente,
        :NEW.idHabitacion, :NEW.idTarjeta, :NEW.idPaquete, :NEW.fechaEntrada,
        :NEW.fechaSalida, :NEW.cantidadHuespedes, :NEW.numeroNoches,
        :NEW.precioNoche, :NEW.subtotal, :NEW.descuentoAplicado,
        :NEW.totalPagar, :NEW.estatusReservacion, :NEW.fechaReservacion,
        :NEW.estado,
        v_fecha_creacion, v_fecha_modificacion, v_accion
    );
END trg_reservaciones_bit;
/