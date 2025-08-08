/**
 * Archivo: testbench.v
 * Autor: Diego Alfaro Segura (diego.alfarosegura@ucr.ac.cr)
 * 
 * Banco de pruebas que conecta el módulo de prueba con los módulos
 * Generador y Receptor.
 *
 * Versión: 1
 * Fecha:  24/10/2024
 * 
 * Copyright (c) 2024 Diego Alfaro Segura
 * MIT License
 */

`include "tester.v"
`include "Generador.v"
`include "Receptor.v"

module testbench;

    // Conexiones entre tester y módulos.
    wire Clk, Reset;                        // Entradas comunes de chip
    wire START_STB, RNW;                    // Instrucciones binarias de CPU
    wire [6:0] I2C_ADDR_Gen, I2C_ADDR_Rec;  // Dirección pedida/asignada por CPU
    wire [15:0] WR_DATA_Gen, WR_DATA_Rec;   // Datos ingresados por CPU/datos a escribir en el chip
    wire SDA_IN;                            // Respuesta de Receptor

    wire SCL;                               // Reloj SCL
    wire [15:0] RD_DATA_Gen, RD_DATA_Rec;   // Lectura de datos/datos guardados en el chip
    wire SDA_OUT, SDA_OE;                   // Salidas hacia Receptor

    // Se guardan los resultados en un vcd.
    initial begin
        $dumpfile("resultados.vcd");
        $dumpvars(0, testbench);
    end

    // Tester
    tester T1 (
        .Clk(Clk),
        .Reset(Reset),
        .START_STB(START_STB),
        .RNW(RNW),
        .I2C_ADDR_Gen(I2C_ADDR_Gen),
        .I2C_ADDR_Rec(I2C_ADDR_Rec),
        .WR_DATA_Gen(WR_DATA_Gen),
        .WR_DATA_Rec(WR_DATA_Rec),
        .SDA_IN(SDA_IN),
        .SCL(SCL),
        .RD_DATA_Gen(RD_DATA_Gen),
        .RD_DATA_Rec(RD_DATA_Rec),
        .SDA_OUT(SDA_OUT),
        .SDA_OE(SDA_OE)
    );

    // Generador
    Generador G1 (
        .Clk(Clk),
        .Reset(Reset),
        .START_STB(START_STB),
        .RNW(RNW),
        .I2C_ADDR(I2C_ADDR_Gen),
        .WR_DATA(WR_DATA_Gen),
        .SDA_IN(SDA_IN),
        .SCL(SCL),
        .RD_DATA(RD_DATA_Gen),
        .SDA_OUT(SDA_OUT),
        .SDA_OE(SDA_OE)
    );

    // Receptor
    Receptor R1 (
        .Clk(Clk),
        .Reset(Reset),
        .I2C_ADDR(I2C_ADDR_Rec),
        .WR_DATA(WR_DATA_Rec),
        .SDA_IN(SDA_IN),
        .SCL(SCL),
        .RD_DATA(RD_DATA_Rec),
        .SDA_OUT(SDA_OUT),
        .SDA_OE(SDA_OE)
    );

endmodule