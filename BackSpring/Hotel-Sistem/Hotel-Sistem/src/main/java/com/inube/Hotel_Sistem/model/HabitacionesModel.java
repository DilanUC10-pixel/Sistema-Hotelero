package com.inube.Hotel_Sistem.model;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;

@Entity
@Table(name = "habitaciones")
@Data
public class HabitacionesModel {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_habitaciones")
    @SequenceGenerator(name = "seq_habitaciones", sequenceName = "seq_habitaciones", allocationSize = 1)
    @Column(name = "IDHABITACION")
    private Integer idHabitacion;

    @Column(name = "NUMEROHABITACION")
    private String numeroHabitacion;

    @Column(name = "PISO")
    private Integer piso;

    @Column(name = "DESCRIPCION")
    private String descripcion;

    @Column(name = "PRECIOBASENOCHE")
    private BigDecimal precioBaseNoche;

    @Column(name = "CAPACIDAD")
    private Integer capacidad;

    @Column(name = "IDCATALOGOHABITACION")
    private Integer idCatalogoHabitacion;

    @Column(name = "DISPONIBLE")
    private Integer disponible;

    @Column(name = "ESTADO")
    private Integer estado;
}