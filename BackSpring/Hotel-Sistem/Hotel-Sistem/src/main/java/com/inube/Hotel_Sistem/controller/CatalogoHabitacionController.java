package com.inube.Hotel_Sistem.controller;

import com.inube.Hotel_Sistem.dto.ApiResponse;
import com.inube.Hotel_Sistem.model.CatalogoHabitacionModel;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import static com.inube.Hotel_Sistem.util.UtilConstants.*;

@RestController
@RequestMapping("/api/CatalogoHabitacion")
@RequiredArgsConstructor
@Tag(name = "CatalogoHabitacion", description = "Operaciones de catálogo de habitaciones")
public class CatalogoHabitacionController {
    private final com.inube.Hotel_Sistem.service.CatalogoHabitacionService service;

    @PostMapping
    public ResponseEntity<ApiResponse<?>> guardar(@RequestBody CatalogoHabitacionModel Chabitacion) {
        return ResponseEntity.ok(new ApiResponse<>(true, MSG6, service.guardar(Chabitacion)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<?>> listar() {
        return ResponseEntity.ok(new ApiResponse<>(true, MSG1, service.listar()));
    }
}
