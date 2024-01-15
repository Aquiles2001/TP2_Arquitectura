`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Student: Aquiles Benjamin Lencina
// Create Date: 01/06/2024
// Module Name: UART_rx
// Project Name: TP2 Arquitectura
//////////////////////////////////////////////////////////////////////////////////

module UART_rx
    #(
        parameter D_BIT   = 8,   // # Bits de datos
        parameter SB_TICK = 16   // # Ticks para bit de stop
    )
    (
        // Entradas
        input  wire                 clock,
        input  wire                 reset,
        input  wire                 rx,
        input  wire                 s_tick,
        
        // Salidas
        output reg                  rx_done_tick,
        output wire [D_BIT - 1:  0] dout  
    );
    
    // Parametrros de estado
    localparam [1:0]
        idle  = 2'b00,
        start = 2'b01,
        data  = 2'b10,
        stop  = 2'b11;
        
    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;
    reg [2:0] n_reg, n_next;
    reg [7:0] b_reg, b_next;
    
    // Proceso de control y estados 
    always @(posedge clock, posedge reset)
        begin   
            if (reset)
                begin
                    state_reg <= idle;
                    s_reg     <= { 4 {1'b0}};
                    n_reg     <= { 3 {1'b0}};
                    b_reg     <= { 8 {1'b0}};
                end
            
            else
                begin
                    state_reg <= state_next;
                    s_reg     <= s_next;
                    n_reg     <= n_next;
                    b_reg     <= b_next;
                end
                
        end
        
    // Logica de control        
    always @(*)
        begin
            state_next   = state_reg;
            rx_done_tick = 1'b0;
            s_next       = s_reg;
            n_next       = n_reg;
            b_next       = b_reg;
            
            case (state_reg)
                idle:
                    begin
                        if (~rx)
                            begin
                                state_next = start;
                                s_next     = { 4 {1'b0}};
                            end
                            
                    end
                    
                start:
                    begin 
                        if(s_tick)
                            if (s_reg == ((SB_TICK / 2) - 1))
                                begin
                                    state_next = data;
                                    s_next     = { 4 {1'b0}};
                                    n_next     = { 3 {1'b0}};
                                end
                            else
                                s_next = s_reg + 1;
                                
                    end
                     
                data:
                    begin
                        if (s_tick)
                            if (s_reg == (SB_TICK - 1))
                                begin
                                    s_next = { 4 {1'b0}};
                                    b_next = {rx, b_reg[7:1]};
                                
                                    if (n_reg == (D_BIT-1))
                                        state_next = stop;
                                    
                                    else
                                        n_next = n_reg + 1;
                                end
                            
                            else
                                s_next = s_reg + 1;
                                
                    end 
                               
                stop:
                    begin
                        if (s_tick)
                            if (s_reg == (SB_TICK-1))
                                begin
                                    state_next   = idle;
                                    rx_done_tick = 1'b1;
                                end
                        
                            else
                                s_next = s_reg + 1;
                                
                    end
                        
            endcase
        end
        
    // Salida    
    assign dout = b_reg;
    
endmodule 