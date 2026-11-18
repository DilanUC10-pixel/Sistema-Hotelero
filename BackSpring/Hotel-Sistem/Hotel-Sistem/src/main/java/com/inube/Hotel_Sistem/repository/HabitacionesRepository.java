package com.inube.Hotel_Sistem.repository;

import com.inube.Hotel_Sistem.model.HabitacionesModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HabitacionesRepository extends JpaRepository<HabitacionesModel, Integer> {
}