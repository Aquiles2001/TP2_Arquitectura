`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Student: Aquiles Benjamin Lencina
// Create Date: 01/06/2024
// Module Name: Interface
// Project Name: TP2 Arquitectura
//////////////////////////////////////////////////////////////////////////////////

module Interface
    #(
        parameter SIZE_DATA = 8,
        parameter SIZE_COD  = 6
    )
    
    (
        input  wire clk,
        input  wire reset,
        input  wire rx_empty,
        input  wire tx_full,
        input  wire [SIZE_DATA-1:0] r_data,
        input  wire [SIZE_DATA-1:0] result,
        
        output wire data_a,
        output wire data_b,
        output wire [SIZE_COD-1:0] op_code,
        output wire rd_uart,
        output wire wr_uart,
        output wire [SIZE_DATA-1:0] w_data
    );
    
    localparam [2:0]
        idle          = 3'b000,
        read_a        = 3'b001,
        read_b        = 3'b010,  
        read_op_code  = 3'b011,
        write_result  = 3'b100;
        
    reg [1:0] state_reg, state_next;
    reg [SIZE_DATA-1:0] w_reg, w_next;
    reg [SIZE_DATA-1:0] data_a_reg, data_a_next;
    reg [SIZE_DATA-1:0] data_b_reg, data_b_next;
    reg [SIZE_DATA-1:0] op_code_reg, op_code_next;
    reg [SIZE_DATA-1:0] result_reg, result_next;
    reg rd_reg, rd_next;
    reg wr_reg, wr_next;   
    
    always @(posedge clk, posedge reset)
        if (reset)
            begin
                state_reg   <= idle;
                rd_reg      <= 0;
                wr_reg      <= 0;
                data_a_reg  <= 0;
                data_b_reg  <= 0;
                op_code_reg <= 0;
                result_reg  <= 0;
                w_reg       <= 0;
                
            end
            
        else
            begin
                state_reg   <= state_next;
                rd_reg      <= rd_next;
                wr_reg      <= wr_next;
                data_a_reg  <= data_a_next;
                data_b_reg  <= data_b_next;
                op_code_reg <= op_code_next;
                result_reg  <= result_next;
                w_reg       <= w_next;
     
            end
            
    always @(*)
        begin
        
            state_next   <= state_reg;
            rd_next      <= rd_reg;
            wr_next      <= wr_reg;
            data_a_next  <= data_a_reg;
            data_b_next  <= data_b_reg;
            op_code_next <= op_code_reg;
            result_next  <= result_reg;
            w_next       <= w_reg;
            
            case(state_reg)
                idle:
                    if (~rx_empty)
                        begin
                            state_next = read_a;
                            rd_next    = 1'b1;
                        end
                    
                    else
                        state_next = idle;
                read_a:
                    if (~rx_empty)
                        begin
                            data_a_next = r_data;
                            rd_next    = 1'b1;
                            state_next = read_b;
                        end
                        
                read_b:
                    if (~rx_empty)
                        begin
                            data_b_next = r_data;
                            rd_next    = 1'b1;
                            state_next = read_op_code;
                        end
                        
                read_op_code:
                    if (~rx_empty)
                        begin
                            op_code_next = r_data[SIZE_COD-1:0];
                            rd_next      = 1'b0;
                            wr_next      = 1'b1;
                            state_next   = write_result;
                        end
                        
                write_result:
                    if (~tx_full)
                        begin
                            result_next  = result;
                            wr_next      = 1'b0;
                            state_next   = idle;
                        end       
                    
            endcase
            
        end

    assign w_data  = result_reg;
    assign data_a  = data_a_reg;
    assign data_b  = data_b_reg;
    assign op_code = op_code_reg;
    assign rd_uart = rd_reg;
    assign wr_uart = rd_reg; 
                                
endmodule