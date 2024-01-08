`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Student: Aquiles Benjamin Lencina
// Create Date: 01/06/2024
// Module Name: FIFO
// Project Name: TP2 Arquitectura
//////////////////////////////////////////////////////////////////////////////////

module FIFO
    #(
        parameter B = 8, // Tamaño de los datos
        parameter W = 4  // Numero de bit de direccion
    )
    
    (
        input  wire clk, reset,
        input  wire rd, wr,
        input  wire [B-1:0] w_data,
        output wire empty, full,
        output wire [B-1:0] r_data
    );
    
    localparam [1:0]
        read       = 2'b01,
        write      = 2'b10,
        read_write = 2'b11;
    
    reg [B-1:0] array_reg [W-1:0];               // Arreglo de registros para almacenar los datos
    reg [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;  // Punteros de escritutra
    reg [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;  // Punteros de lectura
    reg full_reg, full_next, empty_reg, empty_next; // Señales de estado 
    
    wire wr_en; // Señal de habilitacion de escritura
    
    // Proceso de escritura
    always @(posedge clk)
        if (wr_en)
            array_reg[w_ptr_reg] <= w_data;
            
    // Salida de datos
    assign r_data = array_reg[r_ptr_reg];
    
    // Habilitacion de escritura
    assign wr_en = wr & ~full_reg;
    
    // Proceso de control y estados
    always @(posedge clk, posedge reset)
        if (reset)
            begin
                w_ptr_reg <= 0;
                r_ptr_reg <= 0;
                full_reg  <= 1'b0;
                empty_reg <= 1'b1;
            end        
            
        else
            begin
                w_ptr_reg <= w_ptr_next;
                r_ptr_reg <= r_ptr_next;
                full_reg  <= full_next;
                empty_reg <= empty_next;
            end
    
    // Logica de control         
    always @(*)
        begin
            w_ptr_succ = w_ptr_reg + 1;
            r_ptr_succ = r_ptr_reg + 1;
            w_ptr_next = w_ptr_reg;
            r_ptr_next = r_ptr_reg;
            full_next  = full_reg;
            empty_next = empty_reg;
            
            case ({wr,rd})
                read:
                    if (~empty_reg)
                        begin
                            r_ptr_next = r_ptr_succ;
                            full_next  = 1'b0;
                            if (r_ptr_succ==w_ptr_succ)
                                empty_next = 1'b1;
                        end
                
                write:
                    if (~full_reg)
                        begin
                            w_ptr_next =  w_ptr_succ;
                            empty_next = 1'b0;
                            if (w_ptr_succ == r_ptr_reg)
                                full_next = 1'b1;
                        end
                
                read_write:
                    begin
                        w_ptr_next = w_ptr_succ;
                        r_ptr_next = r_ptr_succ;
                    end
            endcase              
        end
    
    // Salidas
    assign full  = full_reg;
    assign empty = empty_reg;

endmodule