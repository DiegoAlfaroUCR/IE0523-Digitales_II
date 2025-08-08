/**
 * Archivo: Generador.v
 * Autor: Diego Alfaro Segura (diego.alfarosegura@ucr.ac.cr)
 * 
 * Módulo Generador, inicia y coordina la comunicación I2C con
 * otros módulos receptores.
 *
 * Versión: 1
 * Fecha: 24/10/2024
 * 
 * Copyright (c) 2024 Diego Alfaro Segura
 * MIT License
 */


// ++++++++++++++++++++ Módulo Generador ++++++++++++++++++++
module Generador(input Clk, Reset,                     // Entradas comunes de chip
                 input START_STB, RNW,                 // Instrucciones binarias de CPU
                 input [6:0] I2C_ADDR,                 // Dirección ingresada por CPU
                 input [15:0] WR_DATA,                 // Datos ingresados por CPU
                 input SDA_IN,                         // Respuesta de Receptor

                 output SCL,                           // Reloj SCL
                 output reg [15:0] RD_DATA,            // Salida hacia CPU
                 output reg SDA_OUT, SDA_OE);          // Comunicación serial

/* ++++++++++++++++++++++++ Asignación de registros internos ++++++++++++++++++++++++ */
    // Vectores de estado presente y de próximo estado
    reg [6:0] EstPres, ProxEstado;

    // Registro para manejar reloj SCL
    reg [1:0] cont_SCL;                          // Divisor de frecuencia
    reg start_SCL, next_start_SCL;               // Señal para inciar el reloj
    reg prev_SCL;                                // Valor anterior del contador
    assign SCL = cont_SCL[1];                    // Valor actual del contador

    // Wires para revisar flancos de reloj
    wire posedge_SCL;                            // Wire para revisar si se da un posedge de SCL
    wire negedge_SCL;                            // Wire para revisar si se da un negedge de SCL
    assign posedge_SCL = !prev_SCL && SCL;
    assign negedge_SCL = prev_SCL && !SCL;

    // Registros para con contar bytes
    reg [4:0] cont_BYTES, next_cont_BYTES;

    // Registro para manejar la actualización de SDA_OUT
    reg next_SDA_OUT, next_SDA_OE;

    // Registro para manejar la actualización de los datos leídos
    reg [15:0] next_RD_DATA;

/* +++++++++++++++++++++++++++++ Asignación de estados +++++++++++++++++++++++++++++ */
   // Se asignan los estados según el diagrama ASM de la máquina.
   // Se usa un FF para cada estado para evitar race conditions durante operacion del IC.
    localparam Estado_Idle        = 7'b0000001;
    localparam Iniciar_Trans      = 7'b0000010;
    localparam Ack_Nack_Lectura   = 7'b0000100;
    localparam Estado_Lectura     = 7'b0001000;
    localparam Ack_Nack_Escritura = 7'b0010000;
    localparam Estado_Escritura   = 7'b0100000;
    localparam Parar_Trans        = 7'b1000000;


/* +++++++++++++++++++++++++++++ Definición de Flip Flops +++++++++++++++++++++++++++++ */
    // Se define el flanco creciente de reloj como el flanco activo de reloj y reset sincrónico.
    always @(posedge Clk, negedge Reset)
        if (~Reset)  begin
            EstPres    <= Estado_Idle;
            cont_SCL   <= 2'b11;
            SDA_OUT    <= 1'b1;
            SDA_OE     <= 1'b1;
            start_SCL  <= 1'b0;
            prev_SCL   <= 1'b1;
            cont_BYTES <= 5'b0;
            RD_DATA    <= 16'b0;
        end
        else begin
            EstPres    <= ProxEstado;
            SDA_OUT    <= next_SDA_OUT;
            SDA_OE     <= next_SDA_OE;
            prev_SCL   <= SCL;
            start_SCL  <= next_start_SCL;
            cont_BYTES <= next_cont_BYTES;
            RD_DATA    <= next_RD_DATA;

            if(start_SCL) cont_SCL <= cont_SCL + 1;
            else cont_SCL <= 2'b11;
        end

/* +++++++++++++++++++++++++++++ Lógica combinacional +++++++++++++++++++++++++++++ */
    always @(*) begin

    // Valores por defecto para mantener el comportamiento de FF.
    ProxEstado = EstPres;
    next_start_SCL = start_SCL;
    next_cont_BYTES = cont_BYTES;
    next_RD_DATA = RD_DATA;
    next_SDA_OUT = SDA_OUT;
    next_SDA_OE = SDA_OE;

    // Lógica combinacional según el estado presente.
    case (EstPres)
        Estado_Idle: begin
            if(START_STB) begin
                next_SDA_OUT = 1'b0;
                next_start_SCL = 1'b1;
                ProxEstado = Iniciar_Trans;
            end
        end

        Iniciar_Trans:
            if(negedge_SCL) begin
                next_cont_BYTES = cont_BYTES + 1;
                if(cont_BYTES == 5'd7) begin
                    next_SDA_OUT = RNW;
                end
                else if (cont_BYTES == 5'd8) begin
                    next_SDA_OE = 5'b0;
                    next_SDA_OUT = 1'b1;
                    next_cont_BYTES = 5'b0;
                    if(RNW) ProxEstado = Ack_Nack_Lectura;
                    else    ProxEstado = Ack_Nack_Escritura;
                end
                else begin
                    next_SDA_OUT = I2C_ADDR[6-cont_BYTES];
                    ProxEstado = Iniciar_Trans;
                end
            end

        Ack_Nack_Lectura: begin
            // Esperar ACK del receptor
            if(posedge_SCL && cont_BYTES == 5'd0) begin
                if(SDA_IN) ProxEstado = Parar_Trans;
                else       ProxEstado = Estado_Lectura;
            end

            // Cambiar de estado luego de generar ACK/NACK
            if(posedge_SCL && SDA_OE) begin
                if(cont_BYTES == 5'd8) ProxEstado = Estado_Lectura;
                else ProxEstado = Parar_Trans;
            end

            // Iniciar ACK/NACK de parte del generador
            else if(negedge_SCL) begin
                if(cont_BYTES == 5'd8) begin
                    // ACK
                    next_SDA_OUT = 1'b0;
                    next_SDA_OE = 1'b1;
                end
                if(cont_BYTES == 5'd16) begin
                    // NACK
                    next_SDA_OUT = 1'b1;
                    next_SDA_OE = 1'b1;
                end
            end
        end

        Estado_Lectura: begin
            // Valor por defecto
            if(negedge_SCL) begin
                next_SDA_OUT = 1'b1;
                next_SDA_OE = 1'b0; 
            end

            // Se leen los valores seriales y se guardan
            if(posedge_SCL) begin
                if(cont_BYTES == 5'd7 || cont_BYTES == 5'd15) ProxEstado = Ack_Nack_Lectura;
                next_cont_BYTES = cont_BYTES + 1;
                next_RD_DATA = {RD_DATA[14:0], SDA_IN}; 
            end
        end

        Ack_Nack_Escritura: begin
            // Se espera ACK del receptor
            if(posedge_SCL) begin
                if(!SDA_IN) ProxEstado = Estado_Escritura;
                else ProxEstado = Parar_Trans;
            end

            if(negedge_SCL) next_SDA_OE = 4'b0;
        end

        Estado_Escritura: begin
            if(posedge_SCL) begin
                // Pasa a esperar ACK si ya pasaron 8 bits
                if(cont_BYTES == 5'd8 || cont_BYTES == 5'd16) ProxEstado = Ack_Nack_Escritura;
            end

            if(negedge_SCL) begin
                next_SDA_OE = 1'b1;
                next_cont_BYTES = cont_BYTES + 1;
                next_SDA_OUT = WR_DATA[15-cont_BYTES];
            end
        end

        Parar_Trans: begin
            if(negedge_SCL) begin
                next_SDA_OUT = 1'b0;
                next_SDA_OE = 1'b1; 
            end

            // Generar stop condition
            if(posedge_SCL) begin
                next_cont_BYTES = 5'b0;     // Reiniciar el contador de Bytes
                next_start_SCL = 1'b0;      // Se detiene el reloj
                next_SDA_OUT = 1'b1;        // Elevar SDA para generar la condicion de stop
                ProxEstado = Estado_Idle;   // Volver a estado inicial
            end
        end

        default: ProxEstado = Estado_Idle;
    endcase
    end

endmodule