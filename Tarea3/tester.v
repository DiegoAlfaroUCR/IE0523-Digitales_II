/**
 * Archivo: tester.v
 * Autor: Diego Alfaro Segura (diego.alfarosegura@ucr.ac.cr)
 * 
 * Módulo de prueba, genera una secuencia de entradas para el módulo Cajero.
 *
 * Versión: 1
 * Fecha: 4/10/2024
 * 
 * Copyright (c) 2024 Diego Alfaro Segura
 * MIT License
 */

`timescale 1ns/1ns

// +++++++ Módulo tester +++++++

module tester(output reg Clk, Reset,
              output reg TARJETA_RECIBIDA, TIPO_TRANS,          // Inputs estacionarios
              output reg [15:0] PIN,
              output reg DIGITO_STB, MONTO_STB,                 // Inputs strobes        
              output reg [3:0] DIGITO,                          // Digito entrante
              output reg [31:0] MONTO,                          // Monto entrante
              output reg [63:0] BALANCE_INICIAL,                // Balance inicial

              input BALANCE_ACTUALIZADO, ENTREGAR_DINERO,                           // Outputs de transacciones correctas
              input PIN_INCORRECTO, ADVERTENCIA, BLOQUEO, FONDOS_INSUFICIENTES);    // Outputs de transacciones incorrectas

    initial begin
        // Valores iniciales de señales
            Clk = 0;
            Reset = 1;
            TARJETA_RECIBIDA = 0;
            DIGITO = 4'h0; DIGITO_STB = 0;
            MONTO = 0; MONTO_STB = 0;


            // Reset momentáneo al inicio para iniciar en estado a
            #1 Reset = 0;
            #11 Reset = 1;

        // ++++++++++++++++++++ Prueba #1, deposito ++++++++++++++++++++

            // Entra una tarjeta
            #2 TARJETA_RECIBIDA = 1; PIN = 16'h0259; BALANCE_INICIAL = 64'd1000;
            TIPO_TRANS = 0; MONTO = 32'd500; 

            // Se ingresa el pin correcto
            #5 DIGITO = 4'h0; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h2; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h5; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h9; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            // Se ingresa el monto.
            #10 MONTO_STB = 1;
            #10 MONTO_STB = 0;

        // ++++++++++++++++++++ Prueba #2, retiro con montos suficientes ++++++++++++++++++++
            #27

            // Entra una tarjeta
            #2 TARJETA_RECIBIDA = 1; PIN = 16'h0259; BALANCE_INICIAL = 64'd1000;
            TIPO_TRANS = 1; MONTO = 32'd500; 

            // Se ingresa el pin correcto
            #5 DIGITO = 4'h0; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h2; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h5; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h9; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            // Se ingresa el monto.
            #10 MONTO_STB = 1;
            #10 MONTO_STB = 0;

        // ++++++++++++++++++++ Prueba #3, retiro con montos insuficientes ++++++++++++++++++++
            #27

            // Entra una tarjeta
            #2 TARJETA_RECIBIDA = 1; PIN = 16'h0259; BALANCE_INICIAL = 64'd1000;
            TIPO_TRANS = 1; MONTO = 32'd5000; 

            // Se ingresa el pin correcto
            #5 DIGITO = 4'h0; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h2; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h5; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h9; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            // Se ingresa el monto
            #10 MONTO_STB = 1;
            #10 MONTO_STB = 0;

        // ++++++++++++++++++++ Prueba #4, ingreso de pin incorrecto menos de 3 veces ++++++++++++++++++++
            #27

            // Entra una tarjeta
            #2 TARJETA_RECIBIDA = 1; PIN = 16'h0259; BALANCE_INICIAL = 64'd1000;
            TIPO_TRANS = 0; MONTO = 32'd5000; 

            // Se ingresa un pin incorrecto
            #5 DIGITO = 4'h1; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h1; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h1; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h1; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            // Se ingresa el pin correcto
            #4 DIGITO = 4'h0; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h2; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h5; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h9; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #10 MONTO_STB = 1;
            #10 MONTO_STB = 0;

        // ++++++++++++++++++++ Prueba #5, ingreso de pin incorrecto 3 veces ++++++++++++++++++++
            #27

            // Entra una tarjeta
            #2 TARJETA_RECIBIDA = 1; PIN = 16'h0259; BALANCE_INICIAL = 64'd1000;
            TIPO_TRANS = 0; MONTO = 32'd5000;

            // Se ingresa un pin incorrecto
            #5 DIGITO = 4'h1; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h1; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h1; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h1; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            // Se ingresa un pin incorrecto
            #4 DIGITO = 4'h2; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h2; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h2; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h2; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            // Se ingresa un pin incorrecto
            #4 DIGITO = 4'h3; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h3; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h3; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            #4 DIGITO = 4'h3; #6 DIGITO_STB = 1;
            #10 DIGITO_STB = 0;

            // Se aplica reset para salir del bloqueo
            #30 Reset = 0;
            #5  Reset = 1;    
        #5 $finish;
    end

    // Se genera la señal de reloj 
    always begin
        #5 Clk = !Clk;
end

endmodule