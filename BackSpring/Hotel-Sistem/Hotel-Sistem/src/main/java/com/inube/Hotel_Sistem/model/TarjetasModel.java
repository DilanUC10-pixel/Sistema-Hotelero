package com.inube.Hotel_Sistem.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;

@Entity
@Table(name = "tarjetas_credito")
@Data
public class TarjetasModel {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_tarjetas_gen")
    @SequenceGenerator(name = "seq_tarjetas_gen", sequenceName = "seq_tarjetas_credito", allocationSize = 1)
    @Column(name = "IDTARJETA")
    private Integer idTarjeta;

    @Column(name = "TITULAR")
    private String titular;

    @Column(name = "NUMEROTARJETA")
    private String numeroTarjeta;

    @Column(name = "FECHAEXPIRACION")
    private LocalDate fechaExpiracion;

    @Column(name = "CVV")
    private String cvv;

    @Column(name = "BANCO")
    private String banco;

    @Column(name = "TIPOTARJETA")
    private String tipoTarjeta;

    @ManyToOne
    @JoinColumn(name = "IDCLIENTE")
    private ClienteModel cliente;

    @Column(name = "ESTADO")
    private Integer estado;
}