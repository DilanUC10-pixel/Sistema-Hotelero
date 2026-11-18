package com.inube.Hotel_Sistem.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class TarjetaRequestDTO {

    @NotNull(message = "Debe indicar el cliente")
    private Integer idCliente;

    @NotBlank(message = "El titular es obligatorio")
    @Size(max = 100, message = "El titular no puede exceder 100 caracteres")
    private String titular;

    // Solo dígitos, de 13 a 19 (el algoritmo de Luhn se valida en el service)
    @NotBlank(message = "El número de tarjeta es obligatorio")
    @Pattern(regexp = "^\\d{13,19}$", message = "El número de tarjeta debe tener entre 13 y 19 dígitos")
    private String numeroTarjeta;

    // Formato MM/yy, ejemplo: 08/28
    @NotBlank(message = "La fecha de expiración es obligatoria")
    @Pattern(regexp = "^(0[1-9]|1[0-2])/\\d{2}$", message = "La fecha de expiración debe tener formato MM/yy")
    private String fechaExpiracion;

    @NotBlank(message = "El CVV es obligatorio")
    @Pattern(regexp = "^\\d{3,4}$", message = "El CVV debe tener 3 o 4 dígitos")
    private String cvv;

    @NotBlank(message = "El banco es obligatorio")
    @Size(max = 50)
    private String banco;

    @NotBlank(message = "El tipo de tarjeta es obligatorio")
    @Size(max = 30)
    private String tipoTarjeta;
}