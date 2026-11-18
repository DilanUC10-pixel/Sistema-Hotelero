package com.inube.Hotel_Sistem.controller;


import com.inube.Hotel_Sistem.dto.ApiResponse;
import com.inube.Hotel_Sistem.model.HabitacionesModel;
import com.inube.Hotel_Sistem.service.HabitacionesService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static com.inube.Hotel_Sistem.util.UtilConstants.*;

@RestController
@RequestMapping("/api/habitaciones")
@RequiredArgsConstructor
@Tag(name = "Categoria", description = "Operaciones de categoria")
public class HabitacionesController {
    private final HabitacionesService service;

    @PostMapping
    public ResponseEntity<ApiResponse<?>> guardar(@RequestBody HabitacionesModel cliente) {
        return ResponseEntity.ok(new ApiResponse<>(true, MSG7, service.guardar(cliente)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<?>> listarTodos() {
        return ResponseEntity.ok(new ApiResponse<>(true, MSG1, service.listarTodos()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<?>> buscarPorId(@PathVariable Integer id) {
        return ResponseEntity.ok(new ApiResponse<>(true, MSG1, service.buscarPorId(id)));
    }

}
