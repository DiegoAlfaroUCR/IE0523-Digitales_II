/**
 * Archivo: Receptor.v
 * Autor: Diego Alfaro Segura (diego.alfarosegura@ucr.ac.cr)
 * 
 * Módulo Receptor, recibe la comunicación I2C de un generador.
 *
 * Versión: 1
 * Fecha: 24/10/2024
 * 
 * Copyright (c) 2024 Diego Alfaro Segura
 * MIT License
 */


// ++++++++++++++++++++ Módulo Receptor ++++++++++++++++++++
module Receptor(input Clk, Reset,                     // Entradas comunes de chip
                input [6:0] I2C_ADDR,                 // Dirección asignada del chip
                input [15:0] RD_DATA,                 // Datos en memoria del chip
                input SCL,                            // Reloj SCL
                input SDA_OUT, SDA_OE,                 // Comunicación serial
                
                output reg SDA_IN,                    // Respuesta de Receptor
                output reg [15:0] WR_DATA);           // Escritura a memoria del chip

/* ++++++++++++++++++++++++ Asignación de registros internos ++++++++++++++++++++++++ */
    // Vectores de estado presente y de próximo estado
    reg [6:0] EstPres, ProxEstado;

    // Wires para revisar flancos de reloj
    reg prev_SCL;                                // Se guarda valor anterior de SCL
    wire posedge_SCL;                            // Wire para revisar si se da un posedge de SCL
    wire negedge_SCL;                            // Wire para revisar si se da un negedge de SCL
    assign posedge_SCL = !prev_SCL && SCL;
    assign negedge_SCL = prev_SCL && !SCL;

    // Wires para revisar flanco de SDA_OUT por stop/start
    reg prev_SDA_OUT;
    wire posedge_SDA_OUT;
    wire negedge_SDA_OUT;
    assign posedge_SDA_OUT = !prev_SDA_OUT && SDA_OUT;
    assign negedge_SDA_OUT = prev_SDA_OUT && !SDA_OUT;

    // Registros para con contar bytes
    reg [4:0] cont_BYTES, next_cont_BYTES;

    // Registro para manejar SDA_IN
    reg next_SDA_IN;

    // Registro para manejar la actualización de los datos al registro
    reg [15:0] next_WR_DATA;

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
            prev_SCL   <= 1'b1;
            cont_BYTES <= 5'b0;
            WR_DATA    <= 16'b0;
            SDA_IN     <= 1'b1;
            prev_SDA_OUT <= 1'b1;
        end
        else begin
            EstPres    <= ProxEstado;
            prev_SCL   <= SCL;
            cont_BYTES <= next_cont_BYTES;
            WR_DATA    <= next_WR_DATA;
            SDA_IN     <= next_SDA_IN;
            prev_SDA_OUT <= SDA_OUT;
        end

/* +++++++++++++++++++++++++++++ Lógica combinacional +++++++++++++++++++++++++++++ */
    always @(*) begin

    // Valores por defecto para mantener el comportamiento de FF.
    ProxEstado = EstPres;
    next_cont_BYTES = cont_BYTES;
    next_WR_DATA = WR_DATA;
    next_SDA_IN = SDA_IN;

    // Lógica combinacional según el estado presente.
    case (EstPres)
        Estado_Idle:
            if(negedge_SDA_OUT && SCL) ProxEstado = Iniciar_Trans;

        Iniciar_Trans:
            if(posedge_SCL) begin
                next_cont_BYTES = cont_BYTES + 1;
                if(cont_BYTES == 5'd7) begin
                    next_cont_BYTES = 5'b0;
                    if(SDA_OUT) ProxEstado = Ack_Nack_Lectura;
                    else        ProxEstado = Ack_Nack_Escritura;
                end
                else if (!(I2C_ADDR[6-cont_BYTES] == SDA_OUT)) begin
                    ProxEstado = Parar_Trans;
                end
            end

        Ack_Nack_Lectura: begin
            // Generar ACK del receptor si es apropiado
            if(negedge_SCL && cont_BYTES == 5'b0) begin
                next_SDA_IN = 1'b0;
                ProxEstado = Estado_Lectura;
            end

            // Esperar ACK/NACK de parte del Receptor si es apropiado
            else if(negedge_SCL) begin
                if(SDA_OUT == 1'b0) ProxEstado = Estado_Lectura;
                else ProxEstado = Parar_Trans;
            end
        end

        Estado_Lectura: begin
            // Se escriben los valores del registro
            if(negedge_SCL) begin
                next_cont_BYTES = cont_BYTES + 1;
                next_SDA_IN = RD_DATA[15-cont_BYTES];
                if(cont_BYTES == 5'd8 || cont_BYTES == 5'd15) ProxEstado = Ack_Nack_Lectura;
            end
        end

        Ack_Nack_Escritura: begin
            // Cambiar de estado luego de generar ACK/NACK
            if(posedge_SCL) begin
                if(cont_BYTES == 5'd16) ProxEstado = Parar_Trans;
                else ProxEstado = Estado_Escritura;
            end

            // Se genera ACK del receptor
            if(negedge_SCL) begin
                if(cont_BYTES == 5'd16) next_SDA_IN = 1'b1;
                else next_SDA_IN = 1'b0;      
            end
        end

        Estado_Escritura: begin
            if(negedge_SCL) next_SDA_IN = 1'b1; // Reinicia la señal SDA_IN

            if(posedge_SCL) begin
                if(cont_BYTES == 5'd7 || cont_BYTES == 5'd15) ProxEstado = Ack_Nack_Escritura;
                next_cont_BYTES = cont_BYTES + 1;
                next_WR_DATA = {WR_DATA[14:0], SDA_OUT};
            end
        end

        Parar_Trans: begin
            // Detectar stop condition
            if(negedge_SCL) next_SDA_IN = 1'b1;
            if(posedge_SDA_OUT && SCL) begin
                ProxEstado = Estado_Idle;
                next_cont_BYTES = 5'b0;
            end
        end

        default: ProxEstado = Estado_Idle;
    endcase
    end

endmodule