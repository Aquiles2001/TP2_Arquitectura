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
        parameter DSVR     = 163,
        parameter DSVR_BIT = 8,
        parameter FIFO_W   = 8
    )
    
    (
        input  wire clk, reset,
        input  wire rd_uart, wr_uart, rx,
        input  wire [7:0] w_data,
        output wire tx_full, rx_empty, tx,
        output wire [7:0] r_data
    );
    
    wire tick, rx_done_tick, tx_done;
    wire tx_empty, tx_fifo_not_empty;
    wire [7:0] tx_fifo_out, rx_data_out;
    
    baud_rate_generator #(.M(DSVR), .N(DSVR_BIT)) baud_rate_generator_unit
        (   
            .clk(clk), .reset(reset), 
            .q(), .max_tick(tick)
        );
    
    UART_Rx #(.D_BIT(D_BIT), .SB_TICK(SB_TICK)) uart_unit
        (
            .clk(clk), .reset(reset), .rx(rx), .s_tick(tick),
            .rx_done_tick(rx_done_tick), .dout(rx_data_out)
        );    
    
    FIFO #(.B(D_BIT), .W(FIFO_W)) fifo_rx_unit
        (
            .clk(clk), .reset(reset), .rd(rd_uart), .wr(rx_done_tick), .w_data(rx_data_out), 
            .empty(rx_empty), .full(), .r_data(r_data)
        );
    
    FIFO #(.B(D_BIT), .W(FIFO_W)) fifo_tx_unit
        (
            .clk(clk), .reset(reset), .rd(tx_done_tick), .wr(wr_uart), .w_data(w_data),
            .empty(tx_empty), .full(tx_full), .r_data(tx_fifo_out)
        );
    
    UART_Tx #() uart_tx_unit
        (
            .clk(clk), .reset(reset), .tx_start(tx_fifo_not_empty), .s_tick(tick), .d_in(tx_fifo_out),
            .tx_done_tick(tx_done_tick), .tx(tx) 
        );
        
    assign tx_fifo_not_empty = ~tx_empty;
    
    
endmodule
