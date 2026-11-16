package com.inube.Hotel_Sistem.repository;

import com.inube.Hotel_Sistem.model.ClienteModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public interface ClienteRepository extends JpaRepository<ClienteModel, Integer> {
    List<ClienteModel> findByEstado(Integer estado);
}
