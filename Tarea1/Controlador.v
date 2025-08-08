/**
 * Archivo: Controlador.v
 * Autor: Diego Alfaro Segura (diego.alfarosegura@ucr.ac.cr)
 * 
 * Módulo Controlador, describe un controlador automatizado de entrada
 * en un estacionamiento. Recibe señales de sensores de Entrada/Salida
 * del carro y un código ingresado de 16 bits, junto a señal de Enter 
 * que indica cuando se ingresa la clave al sistema. Según las condiciones
 * abre/cierra la puerta (Abrir/Cerrar) o activan las alarmas (AlrmInt/AlrmCom).
 * Se compara el código con la clave correcta, por defecto es 2468 en 
 * formato BCD, pero este parámetro se puede modificar.
 *
 * Versión: 1
 * Fecha: 5/9/2024
 * 
 * Copyright (c) 2024 Diego Alfaro Segura
 * MIT License
 */


// ++++++++++++++++++++ Módulo Controlador ++++++++++++++++++++
module Controlador #(parameter CLAVE_VALIDA = {4'd2, 4'd4, 4'd6, 4'd8}) // Definición de clave por defecto = 2468
                    (input Clk, Reset,
                     input Entrada, Salida, Enter,
                     input [15:0] Clave,
                     output Abrir, Cerrar, AlrmInt, AlrmCom);

/* +++++++++++++++++++++++++++++ Asignación de estados +++++++++++++++++++++++++++++ */
   // Se asignan los estados según el diagrama ASM de la máquina.
   // Se usa un FF para cada estado para evitar race conditions durante operacion del IC.
      localparam a = 7'b0000001;
      localparam b = 7'b0000010;
      localparam c = 7'b0000100;
      localparam d = 7'b0001000;
      localparam e = 7'b0010000;
      localparam f = 7'b0100000;
      localparam g = 7'b1000000;

/* +++++++++++++++++++++++++++++ Memoria de estados +++++++++++++++++++++++++++++ */

      // Se declaran los vectores de estado presente y de próximo estado.
      reg [6:0] EstPres, ProxEstado;

      // Se define el flanco creciente de reloj como el flanco activo de reloj y reset sincrónico.
      always @(posedge Clk, posedge Reset)
            if (Reset)  EstPres <= a;
            else        EstPres <= ProxEstado;

/* +++++++++++++++++++++++++++++ Memoria de entradas +++++++++++++++++++++++++++++ */

      // Se declaran vectores para memoria de entradas.
      reg EntradaFF, SalidaFF, EnterFF;
      reg [15:0] ClaveFF;
      wire BCD; // Se define un wire para la comparación de las claves.

      // Se carga el vector de entradas presentes en el flanco inactivo de reloj.
      always @(negedge Clk) begin
            EntradaFF <= Entrada;
            SalidaFF  <= Salida;
            EnterFF   <= Enter;
            ClaveFF   <= Clave;
      end

/* +++++++++++++++++++++++++++++ Lógica de cálculo de próximo estado +++++++++++++++++++++++++++++ */
      
      always @(*) begin

      // Valores por defecto para mantener el comportamiento de FF.
            ProxEstado = EstPres;

      // Lógica de cálculo de próximo estados según diagrama ASM.
      case (EstPres)
            a   : if(EntradaFF)     ProxEstado = b;
                  else              ProxEstado = a;

            b   : case({EnterFF, BCD})
                        2'b0?   :   ProxEstado = b;
                        2'b10   :   ProxEstado = c;
                        2'b11   :   ProxEstado = e;
                  endcase

            c   : case({EnterFF, BCD})
                        2'b0?   :   ProxEstado = c;
                        2'b10   :   ProxEstado = d;
                        2'b11   :   ProxEstado = e;
                  endcase

            d   : case({EnterFF, BCD})
                        2'b0?   :   ProxEstado = d;
                        2'b10   :   ProxEstado = f;
                        2'b11   :   ProxEstado = e;
                  endcase

            e   : case({SalidaFF, EntradaFF})
                        2'b0?   :   ProxEstado = e;
                        2'b10   :   ProxEstado = a;
                        2'b11   :   ProxEstado = g;
                  endcase

            f   :                   ProxEstado = f;

            g   :                   ProxEstado = g;
            
            default:                ProxEstado = a;
      endcase
      
      end

/* +++++++++++++++++++++++++++++ Lógica de cálculo de salidas +++++++++++++++++++++++++++++ */
      // Lógica de cálculo de salidas según diagrama ASM.
            assign Abrir  = (!SalidaFF & EstPres == e);
            assign Cerrar = ((SalidaFF & !EntradaFF & EstPres == e)|(EstPres == g));
            assign AlrmInt = (EstPres == f);
            assign AlrmCom = (EstPres == g);

      // Lógica de comparación de la clave ingresada con la valida.
            assign BCD = (ClaveFF == CLAVE_VALIDA);

endmodule