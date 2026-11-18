package com.inube.Hotel_Sistem.dto;

import java.math.BigDecimal;

public record HabitacionResponseDTO(
        Integer idHabitacion,
        String numeroHabitacion,              // era Integer
        Integer piso,
        String descripcion,
        BigDecimal precioBaseNoche,
        Integer capacidad,
        Integer disponible,
        Integer idCatalogoHabitacion
) {}
