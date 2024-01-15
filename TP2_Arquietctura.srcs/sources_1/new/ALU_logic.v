`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Student: Aquiles Benjamin Lencina
// Create Date: 10/25/2023 09:03:09 PM 
// Module Name: ALU_logic
// Project Name: TP1 Arquitectura
//////////////////////////////////////////////////////////////////////////////////


module ALU_logic  
    #(
        parameter SIZE_COD  = 6, // Tamaño del codigo de operaciones
        parameter SIZE_OP   = 8  // Tamaño de los operandos
     )
     (
        // Entradas
        input signed [SIZE_OP - 1: 0]   i_a,       // operando a
        input signed [SIZE_OP - 1: 0]   i_b,       // operando b
        input        [SIZE_COD - 1: 0]  i_code,    // switches
        
        // Salidas
        output signed [SIZE_OP - 1: 0]  result        // Resultado de la operacion
     );
     
     reg [SIZE_OP - 1:0] tmp; // Registro temporal para almacenar el resultado
     
     always @(*) begin
        case (i_code)
            6'b100000: tmp = i_a + i_b;       // ADD 
            6'b100010: tmp = i_a - i_b;       // SUB 
            6'b100100: tmp = i_a & i_b;       // AND 
            6'b100101: tmp = i_a | i_b;       // OR 
            6'b100110: tmp = i_a ^ i_b;       // XOR 
            6'b000011: tmp = i_a >>> i_b;     // SRA
            6'b000010: tmp = i_a >> i_b;      // SRL
            6'b100111: tmp = ~(i_a | i_b);    // NOR 
            default  :   tmp = 8'b0; // Valor por default
        endcase
    end
    
    assign result = tmp; 
endmodule

