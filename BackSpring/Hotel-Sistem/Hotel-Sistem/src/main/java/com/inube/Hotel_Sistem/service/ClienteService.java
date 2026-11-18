package com.inube.Hotel_Sistem.service;

import com.inube.Hotel_Sistem.model.ClienteModel;
import com.inube.Hotel_Sistem.repository.ClienteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import static com.inube.Hotel_Sistem.util.UtilConstants.*;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ClienteService {
    private final ClienteRepository repository;

    public ClienteModel guardar(ClienteModel cliente) {
        if (cliente.getEstado() == null) {
            cliente.setEstado(CODEPOS);
        }
        return repository.save(cliente);
    }

    public List<ClienteModel> listar(){ return repository.findByEstado(CODEPOS);}

    public ClienteModel buscarPorId(Integer id){
        return repository.findById(id).orElseThrow(() ->new RuntimeException(MSG2));
    }

    public ClienteModel actualizar(Integer id, ClienteModel request) {

        ClienteModel cliente = buscarPorId(id);
        cliente.setNombre(request.getNombre());
        cliente.setApellido(request.getApellido());
        cliente.setTelefono(request.getTelefono());
        cliente.setCorreo(request.getCorreo());

        return repository.save(cliente);
    }

    public void eliminar(Integer id) {

        ClienteModel cliente = buscarPorId(id);
        cliente.setEstado(CODENEG);
        repository.save(cliente);
    }
}
