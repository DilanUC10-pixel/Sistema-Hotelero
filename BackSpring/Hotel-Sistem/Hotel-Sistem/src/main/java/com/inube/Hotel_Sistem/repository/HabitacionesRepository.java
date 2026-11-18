package com.inube.Hotel_Sistem.repository;

import com.inube.Hotel_Sistem.model.HabitacionesModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HabitacionesRepository extends JpaRepository<HabitacionesModel, Integer> {
    List<HabitacionesModel> findByEstado(Integer estado);
}