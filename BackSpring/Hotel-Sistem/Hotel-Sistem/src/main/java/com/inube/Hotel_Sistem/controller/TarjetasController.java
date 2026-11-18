package com.inube.Hotel_Sistem.controller;

import com.inube.Hotel_Sistem.dto.TarjetaRequestDTO;
import com.inube.Hotel_Sistem.dto.TarjetaResponseDTO;
import com.inube.Hotel_Sistem.service.TarjetasDeCreditoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tarjetas")
@RequiredArgsConstructor
public class TarjetasController {

    private final TarjetasDeCreditoService tarjetasService;

    @PostMapping
    public ResponseEntity<TarjetaResponseDTO> registrar(@Valid @RequestBody TarjetaRequestDTO request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(tarjetasService.guardar(request));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TarjetaResponseDTO> buscarPorId(@PathVariable Integer id) {
        return ResponseEntity.ok(tarjetasService.buscarPorId(id));
    }

    @GetMapping("/cliente/{idCliente}")
    public ResponseEntity<List<TarjetaResponseDTO>> listarPorCliente(@PathVariable Integer idCliente) {
        return ResponseEntity.ok(tarjetasService.listarPorCliente(idCliente));
    }

    @GetMapping("/{id}/tarjetas")
    public ResponseEntity<List<TarjetaResponseDTO>> listarTarjetas(@PathVariable Integer id) {
        return ResponseEntity.ok(tarjetasService.listarPorCliente(id));
    }


}