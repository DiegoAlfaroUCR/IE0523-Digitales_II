/**
 * Archivo: Cajero.v
 * Autor: Diego Alfaro Segura (diego.alfarosegura@ucr.ac.cr)
 * 
 * Módulo Cajero, describe el comportamiento de un chip que comunica/controla
 * las acciones de un cajero automático y un usuario con tarjeta. Esto para
 * realizar transacciones como retiros o depositos.
 *
 * Versión: 1
 * Fecha: 4/10/2024
 * 
 * Copyright (c) 2024 Diego Alfaro Segura
 * MIT License
 */


// ++++++++++++++++++++ Módulo Controlador ++++++++++++++++++++
module Cajero(input Clk, Reset,
              input TARJETA_RECIBIDA, TIPO_TRANS,   // Inputs estacionarios
              input [15:0] PIN,                     // Pin correcto
              input DIGITO_STB, MONTO_STB,          // Inputs strobes        
              input [3:0] DIGITO,                   // Digito entrante
              input [31:0] MONTO,                   // Monto entrante
              input [63:0] BALANCE_INICIAL,         // Balance inicial

              output reg BALANCE_ACTUALIZADO, ENTREGAR_DINERO,                          // Outputs de transacciones correctas
              output reg PIN_INCORRECTO, ADVERTENCIA, BLOQUEO, FONDOS_INSUFICIENTES);   // Outputs de transacciones incorrectas

/* ++++++++++++++++++++++++ Asignación de registros internos ++++++++++++++++++++++++ */
    // Registros internos especificados en enunciado.
    (* keep *) reg [63:0] BALANCE;      // Se agrega el (* keep *) para que Yosys no lo elimine
    reg [1:0]  INTENTOS, next_INTENTOS;

    // Registros internos para manejar la asignación de entradas.
    reg [15:0] DIGITOS_IN;
    reg [31:0] MONTO_IN;

    // Registros para contador de cantidad de digitos ingresados.
    reg [2:0] numDIGITOS, next_numDIGITOS;

    // Se declaran los vectores de estado presente y de próximo estado.
    reg [6:0] EstPres, ProxEstado;

/* +++++++++++++++++++++++++++++ Asignación de estados +++++++++++++++++++++++++++++ */
   // Se asignan los estados según el diagrama ASM de la máquina.
   // Se usa un FF para cada estado para evitar race conditions durante operacion del IC.
    localparam Estado_Inicial = 7'b0000001;
    localparam Esperando_PIN  = 7'b0000010;
    localparam Pin_Autorizado = 7'b0000100;
    localparam Estado_Bloqueo = 7'b0001000;
    localparam Hacer_Deposito = 7'b0010000;
    localparam Hacer_Retiro   = 7'b0100000;
    localparam Sin_Fondos     = 7'b1000000;

/* +++++++++++++++++++++++++++++ Definición de Flip Flops +++++++++++++++++++++++++++++ */
    // Se define el flanco creciente de reloj como el flanco activo de reloj y reset sincrónico.
    always @(posedge Clk, negedge Reset)
        if (~Reset)  begin
            EstPres     <= Estado_Inicial;
            INTENTOS    <= 2'd0;
            numDIGITOS  <= 2'd0;
        end
        else begin
            EstPres    <= ProxEstado;
            INTENTOS   <= next_INTENTOS;
            numDIGITOS <= next_numDIGITOS;

            if (DIGITO_STB) begin
                DIGITOS_IN[3:0]   <= DIGITO;
                DIGITOS_IN[7:4]   <= DIGITOS_IN[3:0];
                DIGITOS_IN[11:8]  <= DIGITOS_IN[7:4];
                DIGITOS_IN[15:12] <= DIGITOS_IN[11:8];
                end
            if (MONTO_STB) MONTO_IN <= MONTO;
        end

/* +++++++++++++++++++++++++++++ Lógica combinacional +++++++++++++++++++++++++++++ */
    always @(*) begin

    // Valores por defecto para mantener el comportamiento de FF.
    ProxEstado = EstPres;
    next_INTENTOS = INTENTOS;
    next_numDIGITOS = numDIGITOS;

    // Valor por defecto del balance.
    BALANCE = BALANCE_INICIAL;

    // Valores por defecto de las salidas binarias
    PIN_INCORRECTO = 1'b0;
    ADVERTENCIA = 1'b0;
    BLOQUEO = 1'b0;
    BALANCE_ACTUALIZADO = 1'b0;
    ENTREGAR_DINERO = 1'b0;
    FONDOS_INSUFICIENTES = 1'b0;

    // Lógica combinacional según el estado presente.
    case (EstPres)
        Estado_Inicial:
            if(TARJETA_RECIBIDA) begin
                ProxEstado = Esperando_PIN;
            end
            else ProxEstado = Estado_Inicial;

        Esperando_PIN:  begin
                ProxEstado = Esperando_PIN;  // Siguiente estado por defecto es Esperando_PIN

                // Caso donde se ingresaron los 4 digitos.
                if(numDIGITOS == 3'd4) begin
                    // Caso donde pin es correcto, se cambia de estado.
                    if(DIGITOS_IN == PIN)     ProxEstado = Pin_Autorizado;

                    // Caso donde pin no es correcto.
                    else begin
                        next_numDIGITOS = 3'd0;                 // Se reinicia la cantidad de digitos
                        next_INTENTOS = INTENTOS + 1;           // Se aumenta la cantidad de intentos fallidos
                        PIN_INCORRECTO = 1;                     // Se asigna como pin incorrecto
                        case (INTENTOS)
                            2'd1: ADVERTENCIA = 1;              // Si INTENTOS = 1 ya es el segundo incorrecto
                            2'd2: ProxEstado = Estado_Bloqueo;  // Si INTENTOS = 2 ya es el tercer incorrecto, cambia de estado
                            default: ProxEstado = Esperando_PIN;
                        endcase
                        end
                end
                // Caso donde no se ingresaron los 4 bits, solo se verifica contador de digitos.
                else if (DIGITO_STB) next_numDIGITOS = numDIGITOS + 1;
            end

        Pin_Autorizado: begin
                next_numDIGITOS = 3'd0;
                next_INTENTOS   = 2'd0;
                if(MONTO_STB) begin
                    if(TIPO_TRANS) begin
                        if(BALANCE_INICIAL > MONTO) ProxEstado = Hacer_Retiro;
                        else ProxEstado = Sin_Fondos;
                    end
                    else ProxEstado = Hacer_Deposito;
                end
                else ProxEstado = Pin_Autorizado;
            end

        Estado_Bloqueo: begin
                ProxEstado = Estado_Bloqueo;
                BLOQUEO = 1;
            end

        Hacer_Deposito: begin
                ProxEstado = Estado_Inicial;
                BALANCE = BALANCE_INICIAL + MONTO_IN;
                BALANCE_ACTUALIZADO = 1;
            end

        Hacer_Retiro  : begin
                ProxEstado = Estado_Inicial;
                BALANCE = BALANCE_INICIAL - MONTO_IN;
                BALANCE_ACTUALIZADO = 1;
                ENTREGAR_DINERO = 1;
            end

        Sin_Fondos   : begin
                ProxEstado = Estado_Inicial;
                FONDOS_INSUFICIENTES = 1;
            end
        
        default: ProxEstado = Estado_Inicial;
    endcase
    end

endmodule