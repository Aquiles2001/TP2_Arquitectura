`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Student: Aquiles Benjamin Lencina
// Create Date: 01/06/2024
// Module Name: baud_rate_generator
// Project Name: TP2 Arquitectura
//////////////////////////////////////////////////////////////////////////////////

module baud_rate_generator
    #(
        parameter N = 4,   // Numero de bit en el contador
        parameter M = 10 // Cantidad de Ticks a contar
    )

    (
        // Entradas
        input  wire         clock,
        input  wire         reset,
        
        // Salidas
        output wire         max_tick,
        output wire [N-1:0] q
    );
    
    reg  [N-1:0] r_reg;  // Registro para almacenar el valor actual del contador
    wire [N-1:0] r_next; // Cable para el proximo valor del contador
    
    always @(posedge clock, posedge reset)
        begin
            if (reset)
                r_reg <= 0;
        
            else
                r_reg <= r_next;
        end
    
    // Logica para el proximo valor del contador
    assign r_next = (r_reg == (M-1)) ? { N {1'b0}} : r_reg + 1;
    
    // Salida q es igual al valor del contador
    assign q = r_reg;
    
    // La señal max_tick es 1 cuando el contador alcanza su valor maximo, si no es cero.
    assign max_tick = (r_reg == (M-1)) ? 1'b1 : 1'b0;
    
endmodule
