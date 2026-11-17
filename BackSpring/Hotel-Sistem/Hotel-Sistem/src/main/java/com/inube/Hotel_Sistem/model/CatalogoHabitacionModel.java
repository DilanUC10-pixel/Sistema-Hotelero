package com.inube.Hotel_Sistem.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "catalogo_habitaciones")
@Data
public class CatalogoHabitacionModel {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_catalogo_habitaciones")
    @SequenceGenerator(name = "seq_catalogo_habitaciones", sequenceName = "seq_catalogo_habitaciones", allocationSize = 1)
    @Column(name = "IDCATALOGOHABITACION")
    private Integer idCatalogoHabitacion;

    @Column(name = "NOMBRECATEGORIA")
    private String nombreCategoria;

    @Column(name = "CAPACIDADPERSONAS")
    private Integer capacidadPersonas;

    @Column(name = "DESCRIPCION")
    private String descripcion;

    @Column(name = "PRECIOBASE")
    private Double precioBase;

    @Column(name = "AMENIDADES")
    private String amenidades;

    @Column(name = "ESTADO")
    private Integer estado;
}
