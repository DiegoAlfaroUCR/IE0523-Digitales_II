/**
 * Archivo: tester.v
 * Autor: Diego Alfaro Segura (diego.alfarosegura@ucr.ac.cr)
 * 
 * Módulo de prueba, genera una secuencia de entradas para
 * módulos Generador y Receptor.
 *
 * Versión: 1
 * Fecha: 24/10/2024
 * 
 * Copyright (c) 2024 Diego Alfaro Segura
 * MIT License
 */

`timescale 1ns/1ns

// +++++++ Módulo tester +++++++

module tester(output reg Clk, Reset,                        // Entradas comunes de chip
              output reg START_STB, RNW,                    // Instrucciones binarias de CPU
              output reg[6:0] I2C_ADDR_Gen, I2C_ADDR_Rec,   // Dirección pedida/asignada por CPU
              output reg[15:0] WR_DATA_Gen,                 // Datos ingresados por CPU/datos a escribir en el chip
              input [15:0] WR_DATA_Rec,
              input SDA_IN,                            // Respuesta de Receptor

              input SCL,                                    // Reloj SCL
              input [15:0] RD_DATA_Gen,                     // Lectura de datos/datos guardados en el chip
              output reg [15:0] RD_DATA_Rec,
              input SDA_OUT, SDA_OE);                       // Salidas hacia Receptor

    localparam ADDR = 7'd59;

    initial begin
        // Valores iniciales de señales
            Clk = 0;
            Reset = 1;
            I2C_ADDR_Rec = ADDR;                // Address del receptor
            WR_DATA_Gen = 16'b1010101010101010; // Datos a escribir
            RD_DATA_Rec = 16'b1100110011001100; // Datos a leer
            START_STB = 1'b0;

            // Reset momentáneo al inicio para iniciar en estado a
            #1 Reset = 0;
            #11 Reset = 1;

        // ++++++++++++++++++++ Prueba #1, Lectura ++++++++++++++++++++
            I2C_ADDR_Gen = ADDR;
            RNW = 1'b1;

            // Se inicia la transacción
            #3 START_STB = 1'b1;

            #11 START_STB = 1'b0;

        // ++++++++++++++++++++ Prueba #2, Escritura ++++++++++++++++++++
            #1159 
            RNW = 1'b0;
            START_STB = 1'b1;

            #10 START_STB = 1'b0; 

        // ++++++++++++++++++++ Prueba #3, transacción con address equivocado ++++++++++++++++++++
            #1160 
            I2C_ADDR_Gen = 7'd0;
            START_STB = 1'b1;

            #10 START_STB = 1'b0; 

        // ++++++++++++++++++++ Prueba #4, Interrupción con reset ++++++++++++++++++++
            #430 
            START_STB = 1'b1;

            #10 START_STB = 1'b0;

            #120 Reset = 1'b0;
            #10 Reset = 1'b1;

            #20
        #5 $finish;
    end

    // Se genera la señal de reloj 
    always begin
        #5 Clk = !Clk;
end

endmodule