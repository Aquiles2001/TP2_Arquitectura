`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Student: Aquiles Benjamin Lencina
// Create Date: 01/08/2024
// Module Name: UART
// Project Name: TP2 Arquitectura
//////////////////////////////////////////////////////////////////////////////////


module UART
    #(
        parameter D_BIT    = 8,
        parameter SB_TICK  = 16,
        parameter DVSR     = 326,
        parameter DVSR_BIT = 9,
        parameter FIFO_W   = 8
    )
    
    (
        // Entradas
        input  wire                 clock,
        input  wire                 reset,
        input  wire                 rd_uart,
        input  wire                 wr_uart,
        input  wire                 rx,
        input  wire [D_BIT - 1 : 0] w_data,
        
        // Salidas
        output wire                 tx_full,
        output wire                 rx_empty,
        output wire                 tx,
        output wire [D_BIT - 1 : 0] r_data
    );
    
    wire                 tick;
    wire                 rx_done_tick;
    wire                 tx_done_tick;
    wire                 tx_empty;
    wire                 tx_fifo_not_empty;
    wire [D_BIT - 1 : 0] tx_fifo_out;
    wire [D_BIT - 1 : 0] rx_data_out;
    
    baud_rate_generator #(.M(DVSR), .N(DVSR_BIT)) baud_rate_generator_unit
        (   
            .clock(clock), .reset(reset), 
            .q(), .max_tick(tick)
        );
    
    UART_rx #(.D_BIT(D_BIT), .SB_TICK(SB_TICK)) uart_rx_unit
        (
            .clock(clock), .reset(reset), .rx(rx), .s_tick(tick),
            .rx_done_tick(rx_done_tick), .dout(rx_data_out)
        );    
    
    FIFO #(.B(D_BIT), .W(FIFO_W)) fifo_rx_unit
        (
            .clock(clock), .reset(reset), .rd(rd_uart), .wr(rx_done_tick), .w_data(rx_data_out), 
            .empty(rx_empty), .full(), .r_data(r_data)
        );
    
    FIFO #(.B(D_BIT), .W(FIFO_W)) fifo_tx_unit
        (
            .clock(clock), .reset(reset), .rd(tx_done_tick), .wr(wr_uart), .w_data(w_data),
            .empty(tx_empty), .full(tx_full), .r_data(tx_fifo_out)
        );
    
    UART_tx #(.D_BIT(D_BIT), .SB_TICK(SB_TICK)) uart_tx_unit
        (
            .clock(clock), .reset(reset), .tx_start(tx_fifo_not_empty), .s_tick(tick), .din(tx_fifo_out),
            .tx_done_tick(tx_done_tick), .tx(tx) 
        );
        
    assign tx_fifo_not_empty = ~tx_empty;
    
    
endmodule
