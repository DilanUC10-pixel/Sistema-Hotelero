package com.inube.Hotel_Sistem.service;

import com.inube.Hotel_Sistem.model.CatalogoHabitacionModel;
import com.inube.Hotel_Sistem.repository.CatalogoHabitacionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import static com.inube.Hotel_Sistem.util.UtilConstants.*;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CatalogoHabitacionService {

    private final CatalogoHabitacionRepository repository;

    public CatalogoHabitacionModel guardar(CatalogoHabitacionModel Chabitacion) {
        if (Chabitacion.getEstado() == null) {
            Chabitacion.setEstado(CODEPOS);
        }
        return repository.save(Chabitacion);
    }

    public List<CatalogoHabitacionModel> listar(){ return repository.findByEstado(CODEPOS);}

}
