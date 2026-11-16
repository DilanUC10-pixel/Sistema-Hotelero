-- =====================================================================
-- ULA-RESORT - ARCHIVO 3: INSERTS DE PRUEBA, CONSULTAS Y PRUEBAS DE REGLAS
-- Ejecutar despues de 01_ula_resort_tablas.sql y 02_ula_resort_triggers.sql
-- Los IDs se generan con las secuencias; las relaciones se resuelven
-- con subconsultas. Los triggers validan las reglas de negocio.
-- =====================================================================

-- =====================================================
-- 1. CATALOGO_HABITACIONES
-- =====================================================

INSERT INTO catalogo_habitaciones (nombreCategoria, capacidadPersonas, descripcion, precioBase, amenidades)
VALUES ('Habitacion 1 Persona', 1, 'Habitacion individual con cama sencilla.', 800.00,
        'Wi-Fi, TV, aire acondicionado');

INSERT INTO catalogo_habitaciones (nombreCategoria, capacidadPersonas, descripcion, precioBase, amenidades)
VALUES ('Habitacion 2 Personas', 2, 'Habitacion con cama king size o dos individuales.', 1200.00,
        'Wi-Fi, TV, aire acondicionado, minibar');

INSERT INTO catalogo_habitaciones (nombreCategoria, capacidadPersonas, descripcion, precioBase, amenidades)
VALUES ('Habitacion Familiar', 4, 'Habitacion amplia con dos camas matrimoniales.', 1800.00,
        'Wi-Fi, TV, aire acondicionado, minibar, sala');

INSERT INTO catalogo_habitaciones (nombreCategoria, capacidadPersonas, descripcion, precioBase, amenidades)
VALUES ('Suite Junior', 3, 'Suite con sala de estar y balcon.', 2500.00,
        'Wi-Fi, TV, minibar, balcon, tina de bano');

INSERT INTO catalogo_habitaciones (nombreCategoria, capacidadPersonas, descripcion, precioBase, amenidades)
VALUES ('Suite Master', 5, 'Suite de lujo con vista al mar y jacuzzi.', 4000.00,
        'Wi-Fi, TV, minibar, jacuzzi, terraza, servicio a la habitacion');

-- =====================================================
-- 2. HABITACIONES (la 103 esta fuera de servicio: disponible = 0)
-- =====================================================

INSERT INTO habitaciones (numeroHabitacion, piso, descripcion, precioBaseNoche, capacidad, idCatalogoHabitacion, disponible)
VALUES ('101', 1, 'Individual vista al jardin', 800.00, 1,
        (SELECT idCatalogoHabitacion FROM catalogo_habitaciones WHERE nombreCategoria = 'Habitacion 1 Persona'), 1);

INSERT INTO habitaciones (numeroHabitacion, piso, descripcion, precioBaseNoche, capacidad, idCatalogoHabitacion, disponible)
VALUES ('103', 1, 'Individual en mantenimiento', 800.00, 1,
        (SELECT idCatalogoHabitacion FROM catalogo_habitaciones WHERE nombreCategoria = 'Habitacion 1 Persona'), 0);

INSERT INTO habitaciones (numeroHabitacion, piso, descripcion, precioBaseNoche, capacidad, idCatalogoHabitacion, disponible)
VALUES ('201', 2, 'Doble vista a la alberca', 1200.00, 2,
        (SELECT idCatalogoHabitacion FROM catalogo_habitaciones WHERE nombreCategoria = 'Habitacion 2 Personas'), 1);

INSERT INTO habitaciones (numeroHabitacion, piso, descripcion, precioBaseNoche, capacidad, idCatalogoHabitacion, disponible)
VALUES ('202', 2, 'Doble con balcon', 1250.00, 2,
        (SELECT idCatalogoHabitacion FROM catalogo_habitaciones WHERE nombreCategoria = 'Habitacion 2 Personas'), 1);

INSERT INTO habitaciones (numeroHabitacion, piso, descripcion, precioBaseNoche, capacidad, idCatalogoHabitacion, disponible)
VALUES ('301', 3, 'Familiar con sala', 1800.00, 4,
        (SELECT idCatalogoHabitacion FROM catalogo_habitaciones WHERE nombreCategoria = 'Habitacion Familiar'), 1);

INSERT INTO habitaciones (numeroHabitacion, piso, descripcion, precioBaseNoche, capacidad, idCatalogoHabitacion, disponible)
VALUES ('302', 3, 'Familiar vista al mar', 1900.00, 4,
        (SELECT idCatalogoHabitacion FROM catalogo_habitaciones WHERE nombreCategoria = 'Habitacion Familiar'), 1);

INSERT INTO habitaciones (numeroHabitacion, piso, descripcion, precioBaseNoche, capacidad, idCatalogoHabitacion, disponible)
VALUES ('401', 4, 'Suite Junior con balcon', 2500.00, 3,
        (SELECT idCatalogoHabitacion FROM catalogo_habitaciones WHERE nombreCategoria = 'Suite Junior'), 1);

INSERT INTO habitaciones (numeroHabitacion, piso, descripcion, precioBaseNoche, capacidad, idCatalogoHabitacion, disponible)
VALUES ('501', 5, 'Suite Master penthouse', 4000.00, 5,
        (SELECT idCatalogoHabitacion FROM catalogo_habitaciones WHERE nombreCategoria = 'Suite Master'), 1);

-- =====================================================
-- 3. CLIENTES
-- (Luis se desactiva mas adelante para probar RN-05 y la bitacora)
-- =====================================================

INSERT INTO clientes (nombre, apellido, telefono, correo, direccion)
VALUES ('Ana', 'Lopez', '5511223344', 'ana.lopez@correo.com', 'Av. Reforma 100, CDMX');

INSERT INTO clientes (nombre, apellido, telefono, correo, direccion)
VALUES ('Carlos', 'Ramirez', '5522334455', 'carlos.ramirez@correo.com', 'Calle Hidalgo 45, Pachuca, Hgo.');

INSERT INTO clientes (nombre, apellido, telefono, correo, direccion)
VALUES ('Maria', 'Fernandez', '5533445566', 'maria.fernandez@correo.com', 'Col. Centro 12, Tecamac, Edo. Mex.');

INSERT INTO clientes (nombre, apellido, telefono, correo, direccion)
VALUES ('Luis', 'Hernandez', '5544556677', 'luis.hernandez@correo.com', 'Av. Juarez 300, Puebla');

-- =====================================================
-- 4. TARJETAS_CREDITO
-- Numeros de prueba publicos; no son tarjetas reales.
-- (Los triggers exigen cliente activo y tarjeta no vencida al registrar)
-- =====================================================

INSERT INTO tarjetas_credito (titular, numeroTarjeta, fechaExpiracion, cvv, banco, tipoTarjeta, idCliente)
VALUES ('ANA LOPEZ', '4111111111111111', DATE '2028-08-31', '123', 'BBVA', 'CREDITO',
        (SELECT idCliente FROM clientes WHERE correo = 'ana.lopez@correo.com'));

INSERT INTO tarjetas_credito (titular, numeroTarjeta, fechaExpiracion, cvv, banco, tipoTarjeta, idCliente)
VALUES ('CARLOS RAMIREZ', '5555555555554444', DATE '2027-12-31', '456', 'Banorte', 'CREDITO',
        (SELECT idCliente FROM clientes WHERE correo = 'carlos.ramirez@correo.com'));

INSERT INTO tarjetas_credito (titular, numeroTarjeta, fechaExpiracion, cvv, banco, tipoTarjeta, idCliente)
VALUES ('CARLOS RAMIREZ', '378282246310005', DATE '2027-06-30', '7890', 'Amex', 'CREDITO',
        (SELECT idCliente FROM clientes WHERE correo = 'carlos.ramirez@correo.com'));

INSERT INTO tarjetas_credito (titular, numeroTarjeta, fechaExpiracion, cvv, banco, tipoTarjeta, idCliente)
VALUES ('MARIA FERNANDEZ', '4012888888881881', DATE '2029-05-31', '321', 'Santander', 'DEBITO',
        (SELECT idCliente FROM clientes WHERE correo = 'maria.fernandez@correo.com'));

INSERT INTO tarjetas_credito (titular, numeroTarjeta, fechaExpiracion, cvv, banco, tipoTarjeta, idCliente)
VALUES ('LUIS HERNANDEZ', '6011111111111117', DATE '2028-01-31', '654', 'HSBC', 'CREDITO',
        (SELECT idCliente FROM clientes WHERE correo = 'luis.hernandez@correo.com'));

-- Borrado logico: cliente Luis y tarjeta Amex de Carlos (generan 'Deactivate' en la bitacora)
UPDATE clientes SET estado = 0 WHERE correo = 'luis.hernandez@correo.com';
UPDATE tarjetas_credito SET estado = 0 WHERE numeroTarjeta = '378282246310005';

-- =====================================================
-- 5. PAQUETES_PROMOCIONALES
--   - Escapada de Fin de Ano : vigente y activo
--   - Luna de Miel           : vigente y activo
--   - Promo Primavera        : activo pero VENCIDO
--   - Black Friday           : INACTIVO (estado = 0)
-- =====================================================

INSERT INTO paquetes_promocionales (nombrePaquete, descripcion, porcentajeDescuento, fechaInicioVigencia, fechaFinVigencia, condiciones)
VALUES ('Escapada de Fin de Ano', '15% de descuento en estancias de diciembre.', 15.00,
        DATE '2026-11-01', DATE '2026-12-31', 'Minimo 2 noches');

INSERT INTO paquetes_promocionales (nombrePaquete, descripcion, porcentajeDescuento, fechaInicioVigencia, fechaFinVigencia, condiciones)
VALUES ('Luna de Miel', '10% de descuento para parejas recien casadas.', 10.00,
        DATE '2026-11-01', DATE '2027-02-28', 'Maximo 2 huespedes');

INSERT INTO paquetes_promocionales (nombrePaquete, descripcion, porcentajeDescuento, fechaInicioVigencia, fechaFinVigencia, condiciones)
VALUES ('Promo Primavera', '20% de descuento en temporada de primavera.', 20.00,
        DATE '2026-01-01', DATE '2026-03-31', 'Sin condiciones');

INSERT INTO paquetes_promocionales (nombrePaquete, descripcion, porcentajeDescuento, fechaInicioVigencia, fechaFinVigencia, condiciones, estado)
VALUES ('Black Friday', '25% de descuento por tiempo limitado.', 25.00,
        DATE '2026-11-20', DATE '2026-11-30', 'Pago anticipado', 0);

-- =====================================================
-- 6. RESERVACIONES
-- Montos: subtotal = noches * precioNoche
--         descuento = subtotal * porcentaje / 100
--         total = subtotal - descuento
-- =====================================================

-- R1: Ana, hab. 201, 3 noches, Escapada de Fin de Ano (15%): 3600 - 540 = 3060
INSERT INTO reservaciones (idCliente, idHabitacion, idTarjeta, idPaquete, fechaEntrada, fechaSalida,
                           cantidadHuespedes, numeroNoches, precioNoche, subtotal, descuentoAplicado,
                           totalPagar, estatusReservacion)
VALUES ((SELECT idCliente FROM clientes WHERE correo = 'ana.lopez@correo.com'),
        (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '201'),
        (SELECT idTarjeta FROM tarjetas_credito WHERE numeroTarjeta = '4111111111111111'),
        (SELECT idPaquete FROM paquetes_promocionales WHERE nombrePaquete = 'Escapada de Fin de Ano'),
        DATE '2026-12-20', DATE '2026-12-23', 2, 3, 1200.00, 3600.00, 540.00, 3060.00, 'CONFIRMADA');

-- R2: Carlos, hab. 301, 3 noches, sin paquete: 5400
INSERT INTO reservaciones (idCliente, idHabitacion, idTarjeta, idPaquete, fechaEntrada, fechaSalida,
                           cantidadHuespedes, numeroNoches, precioNoche, subtotal, descuentoAplicado,
                           totalPagar, estatusReservacion)
VALUES ((SELECT idCliente FROM clientes WHERE correo = 'carlos.ramirez@correo.com'),
        (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '301'),
        (SELECT idTarjeta FROM tarjetas_credito WHERE numeroTarjeta = '5555555555554444'),
        NULL,
        DATE '2026-12-26', DATE '2026-12-29', 4, 3, 1800.00, 5400.00, 0.00, 5400.00, 'CONFIRMADA');

-- R3: Maria, hab. 401, 2 noches, Luna de Miel (10%): 5000 - 500 = 4500 (PENDIENTE)
INSERT INTO reservaciones (idCliente, idHabitacion, idTarjeta, idPaquete, fechaEntrada, fechaSalida,
                           cantidadHuespedes, numeroNoches, precioNoche, subtotal, descuentoAplicado,
                           totalPagar, estatusReservacion)
VALUES ((SELECT idCliente FROM clientes WHERE correo = 'maria.fernandez@correo.com'),
        (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '401'),
        (SELECT idTarjeta FROM tarjetas_credito WHERE numeroTarjeta = '4012888888881881'),
        (SELECT idPaquete FROM paquetes_promocionales WHERE nombrePaquete = 'Luna de Miel'),
        DATE '2027-01-10', DATE '2027-01-12', 2, 2, 2500.00, 5000.00, 500.00, 4500.00, 'PENDIENTE');

-- R4: Ana, hab. 101, 2 noches pasadas, sin paquete: 1600 (se finaliza con UPDATE)
INSERT INTO reservaciones (idCliente, idHabitacion, idTarjeta, idPaquete, fechaEntrada, fechaSalida,
                           cantidadHuespedes, numeroNoches, precioNoche, subtotal, descuentoAplicado,
                           totalPagar, estatusReservacion)
VALUES ((SELECT idCliente FROM clientes WHERE correo = 'ana.lopez@correo.com'),
        (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '101'),
        (SELECT idTarjeta FROM tarjetas_credito WHERE numeroTarjeta = '4111111111111111'),
        NULL,
        DATE '2026-10-05', DATE '2026-10-07', 1, 2, 800.00, 1600.00, 0.00, 1600.00, 'CONFIRMADA');

-- R5: Carlos, hab. 501, 2 noches: 8000 (se cancela con UPDATE)
INSERT INTO reservaciones (idCliente, idHabitacion, idTarjeta, idPaquete, fechaEntrada, fechaSalida,
                           cantidadHuespedes, numeroNoches, precioNoche, subtotal, descuentoAplicado,
                           totalPagar, estatusReservacion)
VALUES ((SELECT idCliente FROM clientes WHERE correo = 'carlos.ramirez@correo.com'),
        (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '501'),
        (SELECT idTarjeta FROM tarjetas_credito WHERE numeroTarjeta = '5555555555554444'),
        NULL,
        DATE '2026-11-25', DATE '2026-11-27', 3, 2, 4000.00, 8000.00, 0.00, 8000.00, 'CONFIRMADA');

-- R6: Maria, hab. 202, 3 noches, sin paquete: 3750
INSERT INTO reservaciones (idCliente, idHabitacion, idTarjeta, idPaquete, fechaEntrada, fechaSalida,
                           cantidadHuespedes, numeroNoches, precioNoche, subtotal, descuentoAplicado,
                           totalPagar, estatusReservacion)
VALUES ((SELECT idCliente FROM clientes WHERE correo = 'maria.fernandez@correo.com'),
        (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '202'),
        (SELECT idTarjeta FROM tarjetas_credito WHERE numeroTarjeta = '4012888888881881'),
        NULL,
        DATE '2026-12-30', DATE '2027-01-02', 2, 3, 1250.00, 3750.00, 0.00, 3750.00, 'CONFIRMADA');

-- Cambios de estatus (generan 'Finish' y 'Cancel' en la bitacora)
UPDATE reservaciones
SET estatusReservacion = 'FINALIZADA'
WHERE fechaEntrada = DATE '2026-10-05'
  AND idHabitacion = (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '101');

-- Cancelacion = cambio de estatus + borrado logico
UPDATE reservaciones
SET estatusReservacion = 'CANCELADA',
    estado = 0
WHERE fechaEntrada = DATE '2026-11-25'
  AND idHabitacion = (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '501');

COMMIT;

-- =====================================================
-- 7. CONSULTAS DE VERIFICACION
-- =====================================================

-- Conteo de registros por tabla
SELECT 'CLIENTES' AS tabla, COUNT(*) AS total FROM clientes
UNION ALL SELECT 'CATALOGO_HABITACIONES', COUNT(*) FROM catalogo_habitaciones
UNION ALL SELECT 'HABITACIONES',          COUNT(*) FROM habitaciones
UNION ALL SELECT 'TARJETAS_CREDITO',      COUNT(*) FROM tarjetas_credito
UNION ALL SELECT 'PAQUETES_PROMOCIONALES', COUNT(*) FROM paquetes_promocionales
UNION ALL SELECT 'RESERVACIONES',         COUNT(*) FROM reservaciones;

-- Habitaciones con su categoria
SELECT h.idHabitacion, h.numeroHabitacion, h.piso, c.nombreCategoria,
       h.capacidad, h.precioBaseNoche,
       DECODE(h.disponible, 1, 'Disponible', 'Fuera de servicio') AS disponibilidad
FROM habitaciones h
JOIN catalogo_habitaciones c ON c.idCatalogoHabitacion = h.idCatalogoHabitacion
WHERE h.estado = 1
ORDER BY h.numeroHabitacion;

-- Paquetes promocionales vigentes hoy (GET /api/paquetes)
SELECT idPaquete, nombrePaquete, porcentajeDescuento, fechaInicioVigencia, fechaFinVigencia
FROM paquetes_promocionales
WHERE estado = 1
  AND TRUNC(SYSDATE) BETWEEN fechaInicioVigencia AND fechaFinVigencia;

-- Habitaciones disponibles para un rango de fechas y huespedes
-- (GET /api/habitaciones/disponibles). Dos rangos se traslapan si:
--   entrada_existente < salida_solicitada AND salida_existente > entrada_solicitada
SELECT h.idHabitacion, h.numeroHabitacion, c.nombreCategoria,
       h.capacidad, h.precioBaseNoche
FROM habitaciones h
JOIN catalogo_habitaciones c ON c.idCatalogoHabitacion = h.idCatalogoHabitacion
WHERE h.estado = 1
  AND h.disponible = 1
  AND c.estado = 1
  AND h.capacidad >= 2                                  -- huespedes solicitados
  AND NOT EXISTS (
        SELECT 1
        FROM reservaciones r
        WHERE r.idHabitacion = h.idHabitacion
          AND r.estado = 1
          AND r.estatusReservacion IN ('PENDIENTE', 'CONFIRMADA')
          AND r.fechaEntrada < DATE '2026-12-22'        -- fechaSalida solicitada
          AND r.fechaSalida  > DATE '2026-12-20'        -- fechaEntrada solicitada
      )
ORDER BY h.numeroHabitacion;

-- Reservaciones de un cliente (GET /api/clientes/{id}/reservaciones)
SELECT r.idReservacion, h.numeroHabitacion, r.fechaEntrada, r.fechaSalida,
       r.totalPagar, r.estatusReservacion
FROM reservaciones r
JOIN habitaciones h ON h.idHabitacion = r.idHabitacion
WHERE r.idCliente = (SELECT idCliente FROM clientes WHERE correo = 'ana.lopez@correo.com')
  AND r.estado = 1
ORDER BY r.fechaEntrada;

-- Reporte consolidado de reservaciones confirmadas por categoria
-- (GET /api/reportes/reservaciones-confirmadas)
SELECT cat.nombreCategoria,
       cl.nombre || ' ' || cl.apellido AS cliente,
       h.numeroHabitacion,
       NVL(p.nombrePaquete, 'Sin paquete') AS paquete,
       r.fechaEntrada,
       r.fechaSalida,
       r.totalPagar,
       COUNT(*)           OVER (PARTITION BY cat.idCatalogoHabitacion) AS reservacionesCategoria,
       SUM(r.totalPagar)  OVER (PARTITION BY cat.idCatalogoHabitacion) AS totalCategoria
FROM reservaciones r
JOIN clientes cl                ON cl.idCliente = r.idCliente
JOIN habitaciones h             ON h.idHabitacion = r.idHabitacion
JOIN catalogo_habitaciones cat  ON cat.idCatalogoHabitacion = h.idCatalogoHabitacion
LEFT JOIN paquetes_promocionales p ON p.idPaquete = r.idPaquete
WHERE r.estado = 1
  AND r.estatusReservacion = 'CONFIRMADA'
ORDER BY cat.nombreCategoria, r.fechaReservacion;

-- Resumen por categoria (total de reservaciones y monto generado)
SELECT cat.nombreCategoria,
       COUNT(*)           AS totalReservaciones,
       SUM(r.totalPagar)  AS totalGenerado
FROM reservaciones r
JOIN habitaciones h            ON h.idHabitacion = r.idHabitacion
JOIN catalogo_habitaciones cat ON cat.idCatalogoHabitacion = h.idCatalogoHabitacion
WHERE r.estado = 1
  AND r.estatusReservacion = 'CONFIRMADA'
GROUP BY cat.nombreCategoria
ORDER BY totalGenerado DESC;

-- Bitacoras (auditoria)
SELECT accion, COUNT(*) AS total FROM clientes_bit GROUP BY accion;
SELECT accion, COUNT(*) AS total FROM tarjetas_credito_bit GROUP BY accion;
SELECT accion, COUNT(*) AS total FROM habitaciones_bit GROUP BY accion;
SELECT accion, COUNT(*) AS total FROM paquetes_promocionales_bit GROUP BY accion;
SELECT accion, COUNT(*) AS total FROM reservaciones_bit GROUP BY accion;

-- =====================================================
-- 8. PRUEBAS DE REGLAS DE NEGOCIO (opcionales: deben FALLAR)
-- Descomenta una a la vez para generar la evidencia de validaciones.
-- =====================================================

-- ORA-20031: cliente inactivo no puede reservar (RN-05)
-- INSERT INTO reservaciones (idCliente, idHabitacion, idTarjeta, fechaEntrada, fechaSalida,
--                            cantidadHuespedes, numeroNoches, precioNoche, subtotal, totalPagar)
-- VALUES ((SELECT idCliente FROM clientes WHERE correo = 'luis.hernandez@correo.com'),
--         (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '101'),
--         (SELECT idTarjeta FROM tarjetas_credito WHERE numeroTarjeta = '6011111111111117'),
--         DATE '2027-03-01', DATE '2027-03-03', 1, 2, 800.00, 1600.00, 1600.00);

-- ORA-20037: tarjeta inactiva no puede usarse (RN-06)
-- INSERT INTO reservaciones (idCliente, idHabitacion, idTarjeta, fechaEntrada, fechaSalida,
--                            cantidadHuespedes, numeroNoches, precioNoche, subtotal, totalPagar)
-- VALUES ((SELECT idCliente FROM clientes WHERE correo = 'carlos.ramirez@correo.com'),
--         (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '101'),
--         (SELECT idTarjeta FROM tarjetas_credito WHERE numeroTarjeta = '378282246310005'),
--         DATE '2027-03-01', DATE '2027-03-03', 1, 2, 800.00, 1600.00, 1600.00);

-- ORA-20035: huespedes exceden la capacidad (RN-04)
-- INSERT INTO reservaciones (idCliente, idHabitacion, idTarjeta, fechaEntrada, fechaSalida,
--                            cantidadHuespedes, numeroNoches, precioNoche, subtotal, totalPagar)
-- VALUES ((SELECT idCliente FROM clientes WHERE correo = 'ana.lopez@correo.com'),
--         (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '101'),
--         (SELECT idTarjeta FROM tarjetas_credito WHERE numeroTarjeta = '4111111111111111'),
--         DATE '2027-03-01', DATE '2027-03-03', 2, 2, 800.00, 1600.00, 1600.00);

-- ORA-20033: habitacion fuera de servicio
-- INSERT INTO reservaciones (idCliente, idHabitacion, idTarjeta, fechaEntrada, fechaSalida,
--                            cantidadHuespedes, numeroNoches, precioNoche, subtotal, totalPagar)
-- VALUES ((SELECT idCliente FROM clientes WHERE correo = 'ana.lopez@correo.com'),
--         (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '103'),
--         (SELECT idTarjeta FROM tarjetas_credito WHERE numeroTarjeta = '4111111111111111'),
--         DATE '2027-03-01', DATE '2027-03-03', 1, 2, 800.00, 1600.00, 1600.00);

-- ORA-20040: paquete vencido o inactivo (RN-03)
-- INSERT INTO reservaciones (idCliente, idHabitacion, idTarjeta, idPaquete, fechaEntrada, fechaSalida,
--                            cantidadHuespedes, numeroNoches, precioNoche, subtotal, descuentoAplicado, totalPagar)
-- VALUES ((SELECT idCliente FROM clientes WHERE correo = 'ana.lopez@correo.com'),
--         (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '101'),
--         (SELECT idTarjeta FROM tarjetas_credito WHERE numeroTarjeta = '4111111111111111'),
--         (SELECT idPaquete FROM paquetes_promocionales WHERE nombrePaquete = 'Promo Primavera'),
--         DATE '2027-03-01', DATE '2027-03-03', 1, 2, 800.00, 1600.00, 320.00, 1280.00);

-- ORA-02290: fecha de salida menor o igual a la de entrada (RN-01)
-- INSERT INTO reservaciones (idCliente, idHabitacion, idTarjeta, fechaEntrada, fechaSalida,
--                            cantidadHuespedes, numeroNoches, precioNoche, subtotal, totalPagar)
-- VALUES ((SELECT idCliente FROM clientes WHERE correo = 'ana.lopez@correo.com'),
--         (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '101'),
--         (SELECT idTarjeta FROM tarjetas_credito WHERE numeroTarjeta = '4111111111111111'),
--         DATE '2027-03-03', DATE '2027-03-01', 1, 2, 800.00, 1600.00, 1600.00);

-- ORA-20036: la tarjeta no pertenece al cliente (si el trigger no existiera,
-- la FK compuesta fk_reservaciones_tarjeta_cliente lo bloquearia con ORA-02291)
-- INSERT INTO reservaciones (idCliente, idHabitacion, idTarjeta, fechaEntrada, fechaSalida,
--                            cantidadHuespedes, numeroNoches, precioNoche, subtotal, totalPagar)
-- VALUES ((SELECT idCliente FROM clientes WHERE correo = 'ana.lopez@correo.com'),
--         (SELECT idHabitacion FROM habitaciones WHERE numeroHabitacion = '101'),
--         (SELECT idTarjeta FROM tarjetas_credito WHERE numeroTarjeta = '5555555555554444'),
--         DATE '2027-03-01', DATE '2027-03-03', 1, 2, 800.00, 1600.00, 1600.00);