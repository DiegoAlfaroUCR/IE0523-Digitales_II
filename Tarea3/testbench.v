/**
 * Archivo: testbench.v
 * Autor: Diego Alfaro Segura (diego.alfarosegura@ucr.ac.cr)
 * 
 * Banco de pruebas que conecta el módulo de prueba con el módulo Cajero.
 *
 * Versión: 1
 * Fecha: 4/10/2024
 * 
 * Copyright (c) 2024 Diego Alfaro Segura
 * MIT License
 */

`include "tester.v"
`include "CajeroSynth.v"
`include "lib/cmos_cells.v"

module testbench;

    // Conexiones entre tester y módulo.
    wire Clk, Reset;
    wire TARJETA_RECIBIDA, TIPO_TRANS;          // Inputs estacionarios
    wire [15:0] PIN;                            // Pin correcto
    wire DIGITO_STB, MONTO_STB;                 // Inputs strobes        
    wire [3:0] DIGITO;                          // Digito entrante
    wire [31:0] MONTO;                          // Monto entrante
    wire [63:0] BALANCE_INICIAL;                // Balance inicial

    wire BALANCE_ACTUALIZADO, ENTREGAR_DINERO;                          // Outputs de transacciones correctas
    wire PIN_INCORRECTO, ADVERTENCIA, BLOQUEO, FONDOS_INSUFICIENTES;   // Outputs de transacciones incorrectas

    // Se guardan los resultados en un vcd.
    initial begin
        $dumpfile("resultados.vcd");
        $dumpvars(0, C0);
    end

    // Tester
    tester T0 (
        .Clk     (Clk),
        .Reset   (Reset),
        .TARJETA_RECIBIDA (TARJETA_RECIBIDA),
        .TIPO_TRANS (TIPO_TRANS),
        .PIN (PIN),
        .DIGITO_STB (DIGITO_STB),
        .MONTO_STB (MONTO_STB),
        .DIGITO (DIGITO),
        .MONTO (MONTO),
        .BALANCE_INICIAL (BALANCE_INICIAL),
        .BALANCE_ACTUALIZADO (BALANCE_ACTUALIZADO),
        .ENTREGAR_DINERO (ENTREGAR_DINERO),
        .PIN_INCORRECTO (PIN_INCORRECTO),
        .ADVERTENCIA (ADVERTENCIA),
        .BLOQUEO (BLOQUEO),
        .FONDOS_INSUFICIENTES (FONDOS_INSUFICIENTES)
    );

    // Módulo
    // Se redefine la clave válida como 0259 en BCD.
    Cajero C0 (
        .Clk     (Clk),
        .Reset   (Reset),
        .TARJETA_RECIBIDA (TARJETA_RECIBIDA),
        .TIPO_TRANS (TIPO_TRANS),
        .PIN (PIN),
        .DIGITO_STB (DIGITO_STB),
        .MONTO_STB (MONTO_STB),
        .DIGITO (DIGITO),
        .MONTO (MONTO),
        .BALANCE_INICIAL (BALANCE_INICIAL),
        .BALANCE_ACTUALIZADO (BALANCE_ACTUALIZADO),
        .ENTREGAR_DINERO (ENTREGAR_DINERO),
        .PIN_INCORRECTO (PIN_INCORRECTO),
        .ADVERTENCIA (ADVERTENCIA),
        .BLOQUEO (BLOQUEO),
        .FONDOS_INSUFICIENTES (FONDOS_INSUFICIENTES)
    );

endmodule