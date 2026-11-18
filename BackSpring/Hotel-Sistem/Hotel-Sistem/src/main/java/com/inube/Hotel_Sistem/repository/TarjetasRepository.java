package com.inube.Hotel_Sistem.repository;

import com.inube.Hotel_Sistem.model.TarjetasModel;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface TarjetasRepository extends JpaRepository<TarjetasModel, Integer> {

    boolean existsByCliente_IdClienteAndNumeroTarjeta(Integer idCliente, String numeroTarjeta);
    List<TarjetasModel> findByCliente_IdClienteAndEstado(Integer idCliente, Integer estado);
}