/**
 * Archivo: testbench.v
 * Autor: Diego Alfaro Segura (diego.alfarosegura@ucr.ac.cr)
 * 
 * Banco de pruebas que conecta el módulo de prueba con el módulo Controlador.
 * Se guardan las variables en el archivo "resultados.vcd" 
 *
 * Versión: 1
 * Fecha: 5/9/2024
 * 
 * Copyright (c) 2024 Diego Alfaro Segura
 * MIT License
 */

`include "tester.v"
`include "Controlador.v"

module testbench;

    // Conexiones entre tester y módulo.
    wire Clk, Reset;
    wire Entrada, Salida, Enter;
    wire [15:0] Clave;
    wire Abrir, Cerrar, AlrmInt, AlrmCom;

    // Se guardan los resultados en un vcd.
    initial begin
        $dumpfile("resultados.vcd");
        $dumpvars(0, C0);
    end

    // Tester
    tester T0 (
        .Clk     (Clk),
        .Reset   (Reset),
        .Abrir   (Abrir),
        .Cerrar  (Cerrar),
        .AlrmInt (AlrmInt),
        .AlrmCom (AlrmCom),
        .Entrada (Entrada),
        .Salida  (Salida),
        .Enter   (Enter),
        .Clave   (Clave)
    );

    // Módulo
    // Se redefine la clave válida como 0259 en BCD.
    Controlador #(.CLAVE_VALIDA({4'd0, 4'd2, 4'd5, 4'd9})) C0 (
        .Clk     (Clk),
        .Reset   (Reset),
        .Abrir   (Abrir),
        .Cerrar  (Cerrar),
        .AlrmInt (AlrmInt),
        .AlrmCom (AlrmCom),
        .Entrada (Entrada),
        .Salida  (Salida),
        .Enter   (Enter),
        .Clave   (Clave)
    );

endmodule