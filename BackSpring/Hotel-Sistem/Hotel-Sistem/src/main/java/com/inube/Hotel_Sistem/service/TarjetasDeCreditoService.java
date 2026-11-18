package com.inube.Hotel_Sistem.service;

import com.inube.Hotel_Sistem.dto.TarjetaRequestDTO;
import com.inube.Hotel_Sistem.dto.TarjetaResponseDTO;
import com.inube.Hotel_Sistem.model.ClienteModel;
import com.inube.Hotel_Sistem.model.TarjetasModel;
import com.inube.Hotel_Sistem.repository.ClienteRepository;
import com.inube.Hotel_Sistem.repository.TarjetasRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;

import static com.inube.Hotel_Sistem.util.UtilConstants.CODEPOS;

@Service
@RequiredArgsConstructor
public class TarjetasDeCreditoService {

    private static final DateTimeFormatter FORMATO_EXPIRACION = DateTimeFormatter.ofPattern("MM/yy");

    private final TarjetasRepository tarjetasRepository;
    private final ClienteRepository clienteRepository;

    @Transactional
    public TarjetaResponseDTO guardar(TarjetaRequestDTO request) {

        // 1. Validar existencia del cliente
        ClienteModel cliente = clienteRepository.findById(request.getIdCliente())
                .orElseThrow(() -> new RuntimeException("El cliente no existe"));

        // 2. Verificar que el cliente esté activo
        if (!CODEPOS.equals(cliente.getEstado())) {
            throw new RuntimeException("El cliente no está activo");
        }

        // 3. Validar formato del número (Luhn) y fecha de expiración
        if (!pasaLuhn(request.getNumeroTarjeta())) {
            throw new RuntimeException("El número de tarjeta no es válido");
        }
        LocalDate fechaExpiracion = parsearExpiracion(request.getFechaExpiracion());

        if (fechaExpiracion.isBefore(LocalDate.now())) {
            throw new RuntimeException("La tarjeta está vencida");
        }

        // 4. Evitar duplicados: mismo número para el mismo cliente
        //    (coincide con uq_tarjetas_cliente_numero; incluye tarjetas inactivas)
        if (tarjetasRepository.existsByCliente_IdClienteAndNumeroTarjeta(
                cliente.getIdCliente(), request.getNumeroTarjeta())) {
            throw new RuntimeException("Esta tarjeta ya está registrada para el cliente");
        }

        // 5. Registrar y asociar al cliente
        TarjetasModel tarjeta = new TarjetasModel();
        tarjeta.setCliente(cliente);
        tarjeta.setTitular(request.getTitular().trim().toUpperCase());
        tarjeta.setNumeroTarjeta(request.getNumeroTarjeta());
        tarjeta.setFechaExpiracion(fechaExpiracion);
        tarjeta.setCvv(request.getCvv());
        tarjeta.setBanco(request.getBanco().trim());
        tarjeta.setTipoTarjeta(request.getTipoTarjeta().trim());
        tarjeta.setEstado(CODEPOS);

        return mapearADTO(tarjetasRepository.save(tarjeta));
    }

    @Transactional(readOnly = true)
    public TarjetaResponseDTO buscarPorId(Integer id) {
        TarjetasModel tarjeta = tarjetasRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("La tarjeta no existe"));
        return mapearADTO(tarjeta);
    }

    @Transactional(readOnly = true)
    public List<TarjetaResponseDTO> listarPorCliente(Integer idCliente) {

        // Validar que el cliente exista
        clienteRepository.findById(idCliente)
                .orElseThrow(() -> new RuntimeException("El cliente no existe"));

        return tarjetasRepository
                .findByCliente_IdClienteAndEstado(idCliente, CODEPOS)
                .stream()
                .map(this::mapearADTO)
                .toList();
    }

    private LocalDate parsearExpiracion(String valor) {
        try {
            YearMonth ym = YearMonth.parse(valor, FORMATO_EXPIRACION);
            if (ym.isBefore(YearMonth.now())) {
                throw new RuntimeException("La tarjeta está vencida");
            }
            return ym.atEndOfMonth();
        } catch (DateTimeParseException e) {
            throw new RuntimeException("La fecha de expiración debe tener formato MM/yy");
        }
    }

    // Algoritmo de Luhn
    private boolean pasaLuhn(String numero) {
        int suma = 0;
        boolean duplicar = false;
        for (int i = numero.length() - 1; i >= 0; i--) {
            int d = numero.charAt(i) - '0';
            if (duplicar) {
                d *= 2;
                if (d > 9) d -= 9;
            }
            suma += d;
            duplicar = !duplicar;
        }
        return suma % 10 == 0;
    }

    private String enmascarar(String numero) {
        String ultimos4 = numero.substring(numero.length() - 4);
        return "**** **** **** " + ultimos4;
    }

    private TarjetaResponseDTO mapearADTO(TarjetasModel t) {
        return new TarjetaResponseDTO(
                t.getIdTarjeta(),
                t.getCliente().getIdCliente(),
                t.getTitular(),
                enmascarar(t.getNumeroTarjeta()),
                t.getFechaExpiracion(),
                t.getBanco(),
                t.getTipoTarjeta(),
                t.getEstado()
        );
    }
}