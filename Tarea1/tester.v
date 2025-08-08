/**
 * Archivo: tester.v
 * Autor: Diego Alfaro Segura (diego.alfarosegura@ucr.ac.cr)
 * 
 * Módulo de prueba, genera una secuencia de entradas para el módulo Controlador.
 * Se generan las señales de reloj y reset, al igual que las entradas de los sensores y
 * el código ingresado al controlador.
 *
 * Versión: 1
 * Fecha: 5/9/2024
 * 
 * Copyright (c) 2024 Diego Alfaro Segura
 * MIT License
 */

`timescale 1ns/1ns

// +++++++ Módulo tester +++++++

module tester (input Abrir, Cerrar, AlrmInt, AlrmCom,
               output reg Clk, Reset,
               output reg Entrada, Salida, Enter,
               output reg [15:0] Clave);

    initial begin
        // Valores iniciales de señales
        Clk = 0;
        Reset = 0;
        Entrada = 0; Salida = 0; Enter = 0;
        Clave = 16'b0;

        // Reset momentáneo al inicio para iniciar en estado a
        #1 Reset = 1;
        #1 Reset = 0;

        // ++++++++++++++++++++ Prueba #1, funcionamiento normal básico ++++++++++++++++++++
        // Inicia en 4 ns

        // Entra un carro
        #2 Entrada = 1;

        // Se ingresa el código correcto
        #7 Clave = {4'd0, 4'd2, 4'd5, 4'd9};
        #3 Enter = 1; #7 Enter = 0;

        // Sale el carro, ya no esta ingresando clave.
        #11 Entrada = 0; Clave = {4'd0, 4'd0, 4'd0, 4'd0};
        #15 Salida = 1;

        // ++++++++++++++++++++ Prueba #2, ingreso de pin incorrecto menos de 3 veces ++++++++++++++++++++

        // Prueba empieza a los 57 ns

        // Entra un carro
        #10 Entrada = 1; Salida = 0;

        // Se ingresa el código correcto en el tercer intento
        #4 Clave = {4'd0, 4'd2, 4'd5, 4'd1}; #3 Enter = 1; #7 Enter = 0;
        #5 Clave = {4'd0, 4'd6, 4'd5, 4'd5}; #3 Enter = 1; #7 Enter = 0;
        #6 Clave = {4'd0, 4'd2, 4'd5, 4'd9}; #3 Enter = 1; #7 Enter = 0;

        // Sale el carro
        #7 Entrada = 0; Enter = 0; Clave = {4'd0, 4'd0, 4'd0, 4'd0};
        #8 Salida = 1;

        // ++++++++++++++++++++ Prueba #3, ingreso de pin incorrecto 3 o más veces ++++++++++++++++++++
        // Empieza a los 127 ns

        // Entra un carro
        #10 Entrada = 1; Salida = 0;

        // No se ingresa el código correcto
        #4 Clave = {4'd0, 4'd2, 4'd5, 4'd10};  #3 Enter = 1; #7 Enter = 0;
        #5 Clave = {4'd0, 4'd6, 4'd5, 4'd5};   #3 Enter = 1; #7 Enter = 0;
        #6 Clave = {4'd0, 4'd3, 4'd5, 4'd9};   #3 Enter = 1; #7 Enter = 0;

        // Reset de las alarmas
        #14 Reset = 1; Entrada = 0; Clave = {4'd0, 4'd0, 4'd0, 4'd0};
        #1 Reset = 0;

        // ++++++++++++++++++++ Prueba #4, alarma de bloqueo ++++++++++++++++++++
        // Empieza a los 197 ns

        // Entra un carro
        #10 Entrada = 1;

        // Se ingresa el código correcto
        #5 Clave = {4'd0, 4'd2, 4'd5, 4'd9};
        #4 Enter = 1; #7 Enter = 0;

        // Carro saliendo y entra otro.
        #5 Salida = 1;

        #20 $finish;
    end

    // Se genera la señal de reloj 
    always begin
        #5 Clk = !Clk;
end

endmodule