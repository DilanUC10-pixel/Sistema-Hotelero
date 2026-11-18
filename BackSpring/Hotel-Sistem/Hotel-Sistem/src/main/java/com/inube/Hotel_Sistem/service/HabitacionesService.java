package com.inube.Hotel_Sistem.service;

import com.inube.Hotel_Sistem.dto.HabitacionResponseDTO;
import com.inube.Hotel_Sistem.model.CatalogoHabitacionModel;
import com.inube.Hotel_Sistem.model.HabitacionesModel;
import com.inube.Hotel_Sistem.repository.CatalogoHabitacionRepository;
import com.inube.Hotel_Sistem.repository.HabitacionesRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import static com.inube.Hotel_Sistem.util.UtilConstants.*;

import java.util.List;

@Service
@RequiredArgsConstructor
public class HabitacionesService {
    private final HabitacionesRepository habitacionesRepository;
    private final CatalogoHabitacionRepository catalogoRepository;

    public HabitacionesModel guardar(HabitacionesModel habitacion) {

        // 1. Validar que se haya seleccionado un catálogo
        if (habitacion.getIdCatalogoHabitacion() == null) {
            throw new RuntimeException("Debe seleccionar una categoría de habitación");
        }

        // 2. Buscar el catálogo y validar su existencia
        CatalogoHabitacionModel catalogo = catalogoRepository
                .findById(habitacion.getIdCatalogoHabitacion())
                .orElseThrow(() ->
                        new RuntimeException("El catálogo de habitación no existe"));

        // 3. Verificar que el catálogo esté activo
        if (!CODEPOS.equals(catalogo.getEstado())) {
            throw new RuntimeException("El catálogo de habitación no está activo");
        }

        // 4. Inicializar valores por defecto
        if (habitacion.getEstado() == null) {
            habitacion.setEstado(CODEPOS);
        }
        if (habitacion.getDisponible() == null) {
            habitacion.setDisponible(1);
        }

        // 5. Registrar habitación
        return habitacionesRepository.save(habitacion);
    }

    public List<HabitacionResponseDTO> listarTodos() {
        List<HabitacionesModel> habitaciones = habitacionesRepository.findByEstado(CODEPOS);
        return mapearAListaDTO(habitaciones);
    }

    public HabitacionesModel buscarPorId(Integer id) {
        HabitacionesModel habitacion = habitacionesRepository.findById(id)
                .orElseThrow(() -> new RuntimeException(MSG8));
        if (!CODEPOS.equals(habitacion.getEstado())) {
            throw new RuntimeException(MSG8);
        }
        return habitacion;
    }

    private List<HabitacionResponseDTO> mapearAListaDTO(List<HabitacionesModel> habitaciones) {
        return habitaciones.stream().map(h -> new HabitacionResponseDTO(
                h.getIdHabitacion(),
                h.getNumeroHabitacion(),
                h.getPiso(),
                h.getDescripcion(),
                h.getPrecioBaseNoche(),
                h.getCapacidad(),
                h.getDisponible(),
                h.getIdCatalogoHabitacion()
        )).toList();
    }


}
