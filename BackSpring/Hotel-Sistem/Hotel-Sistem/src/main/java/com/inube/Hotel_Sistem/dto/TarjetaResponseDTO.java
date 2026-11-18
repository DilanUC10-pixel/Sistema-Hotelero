package com.inube.Hotel_Sistem.dto;

import java.time.LocalDate;

public record TarjetaResponseDTO(
        Integer idTarjeta,
        Integer idCliente,
        String titular,
        String numeroEnmascarado,
        LocalDate fechaExpiracion,
        String banco,
        String tipoTarjeta,
        Integer estado
) {
}