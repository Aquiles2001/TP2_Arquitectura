`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Student: Aquiles Benjamin Lencina
// Create Date: 01/09/2024
// Module Name: top
// Project Name: TP2 Arquitectura
//////////////////////////////////////////////////////////////////////////////////


module top
    #(
        parameter D_BIT    = 8,
        parameter SB_TICK  = 16,
        parameter DVSR     = 326,
        parameter DVSR_BIT = 9,
        parameter FIFO_W   = 8,
        parameter SIZE_COD  = 6
    )
    
    (
        // Entradas
        input  wire clock,
        input  wire reset,
        
        // Salidas
        input  wire rx,
        output wire tx
    );
    
    wire                rd_uart;
    wire                wr_uart;
    wire                tx_full;
    wire                rx_empty;
    wire [D_BIT-1:0]    w_data;
    wire [D_BIT-1:0]    r_data;
    wire [D_BIT-1:0]    data_a;
    wire [D_BIT-1:0]    data_b;
    wire [SIZE_COD-1:0] code;
    wire [D_BIT-1:0]    result; 
    
    
    UART #(.D_BIT(D_BIT), .SB_TICK(SB_TICK), .DVSR(DVSR), .DVSR_BIT(DVSR_BIT), .FIFO_W(FIFO_W)) uart_unit
        (
            .clock(clock), .reset(reset), .rd_uart(rd_uart), .wr_uart(wr_uart), .w_data(w_data), .rx(rx),
            .tx_full(tx_full), .rx_empty(rx_empty), .tx(tx), .r_data(r_data)
        );
    
    ALU_logic #(.SIZE_COD(SIZE_COD), .SIZE_OP(D_BIT)) alu_logic_unit
        (
            .i_a(data_a), .i_b(data_b), .i_code(code),
            .result(result)
        );
        
    interface #(.SIZE_DATA(D_BIT), .SIZE_COD(SIZE_COD)) interface_unit
        (
            .clock(clock), .reset(reset), .rx_empty(rx_empty), .tx_full(tx_full), .r_data(r_data), .result(result),
            .data_a(data_a), .data_b(data_b), .op_code(code), .rd_uart(rd_uart), .wr_uart(wr_uart), .w_data(w_data)
        );
    
    assign dato_a = r_data; 
endmodule

