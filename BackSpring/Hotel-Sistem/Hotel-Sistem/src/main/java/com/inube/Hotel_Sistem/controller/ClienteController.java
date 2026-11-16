package com.inube.Hotel_Sistem.controller;

import com.inube.Hotel_Sistem.dto.ApiResponse;
import com.inube.Hotel_Sistem.model.ClienteModel;
import com.inube.Hotel_Sistem.service.ClienteService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static com.inube.Hotel_Sistem.util.UtilConstants.*;

@RestController
@RequestMapping("/api/clientes")
@RequiredArgsConstructor
@Tag(name = "Clientes", description = "Operaciones de clientes")
public class ClienteController {
    private final ClienteService service;

    @PostMapping
    public ResponseEntity<ApiResponse<?>> guardar(@RequestBody ClienteModel cliente) {
        return ResponseEntity.ok(new ApiResponse<>(true, MSG3, service.guardar(cliente)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<?>> listar() {
        return ResponseEntity.ok(new ApiResponse<>(true, MSG1, service.listar()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<?>> buscarPorId(@PathVariable Integer id) {
        return ResponseEntity.ok(new ApiResponse<>(true, MSG1, service.buscarPorId(id)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<?>> actualizar(@PathVariable Integer id, @RequestBody ClienteModel cliente) {
        return ResponseEntity.ok(new ApiResponse<>(true, MSG4, service.actualizar(id, cliente)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<?>> eliminar(@PathVariable Integer id) {
        service.eliminar(id);
        return ResponseEntity.ok(new ApiResponse<>(true, MSG5, null));
    }
}
