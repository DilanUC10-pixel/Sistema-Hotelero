package com.inube.Hotel_Sistem.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;

@Entity
@Table(name = "clientes")
@Data
public class ClienteModel {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_clientes")
    @SequenceGenerator(name = "seq_clientes", sequenceName = "seq_clientes", allocationSize = 1)
    @Column(name = "IDCLIENTE")
    private Integer idCliente;

    @Column(name = "NOMBRE")
    private String nombre;

    @Column(name = "APELLIDO")
    private String apellido;

    @Column(name = "TELEFONO")
    private String telefono;

    @Column(name = "CORREO")
    private String correo;

    @Column(name = "DIRECCION")
    private String direccion;

    @Column(name = "FECHAREGISTRO")
    private LocalDate fechaRegistro;

    @Column(name = "ESTADO")
    private Integer estado;

}
