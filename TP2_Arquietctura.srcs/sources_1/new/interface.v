`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Student: Aquiles Benjamin Lencina
// Create Date: 01/06/2024
// Module Name: interface
// Project Name: TP2 Arquitectura
//////////////////////////////////////////////////////////////////////////////////

module interface
    #(
        parameter SIZE_DATA = 8,
        parameter SIZE_COD  = 6
    )
    
    (
        // Entradas 
        input  wire                 clock,
        input  wire                 reset,
        input  wire                 rx_empty,
        input  wire                 tx_full,
        input  wire [SIZE_DATA-1:0] r_data,
        input  wire [SIZE_DATA-1:0] result,
        
        // Salidas
        output wire [SIZE_DATA-1:0] data_a,
        output wire [SIZE_DATA-1:0] data_b,
        output wire [SIZE_COD-1:0]  op_code,
        output wire                 rd_uart,
        output wire                 wr_uart,
        output wire [SIZE_DATA-1:0] w_data
    );
    
    // Parametros de estado 
    localparam [2:0]
        idle          = 3'b000,
        read_a        = 3'b001,
        read_b        = 3'b010,  
        read_op_code  = 3'b011,
        write_result  = 3'b100;
        
    reg [2:0]           state_reg;
    reg [2:0]           state_next;
    reg [SIZE_DATA-1:0] data_a_reg;
    reg [SIZE_DATA-1:0] data_b_reg;
    reg [SIZE_COD-1:0]  op_code_reg;
    reg [SIZE_DATA-1:0] result_reg;
    reg                 rd_reg;
    reg                 wr_reg;

    always @(posedge clock, posedge reset)
        if (reset)
            begin
                state_reg   <= idle;
                data_a_reg  <= {SIZE_DATA {1'b0}};
                data_b_reg  <= {SIZE_DATA {1'b0}};
                op_code_reg <= {SIZE_COD {1'b0}};
                result_reg  <= {SIZE_DATA {1'b0}};
                rd_reg      <= 1'b0;
                wr_reg      <= 1'b0;
                
            end
            
        else
            begin
                state_reg   <= state_next;
                wr_reg      <= 1'b0; 
                rd_reg      <= 1'b0;
                
                case(state_reg)
                idle:
                    begin
                        if (~rx_empty)
                            begin
                                state_next <= read_a;
                            end
                    
                        else
                            state_next <= idle;
                            
                    end
                    
                read_a:
                    begin
                        rd_reg <= 1'b0;
                        if (~rx_empty)
                            begin
                                data_a_reg <= r_data [SIZE_DATA-1:0];
                                state_next <= read_b;
                                rd_reg     <= 1'b1;
                            end
                        
                        else
                            state_next <= read_a;
                        
                    end
                            
                read_b:
                    begin
                        rd_reg <= 1'b0;
                        if (~rx_empty)
                            begin
                                data_b_reg <= r_data [SIZE_DATA-1:0];
                                state_next  <= read_op_code;
                                rd_reg     <= 1'b1;            
                            end
                        
                        else
                            state_next <= read_b;
                            
                    end
                        
                read_op_code:
                    begin
                        rd_reg <= 1'b0;
                        if (~rx_empty)
                            begin
                                op_code_reg <= r_data[SIZE_COD-1:0];
                                state_next  <= write_result;                             
                                rd_reg      <= 1'b1;
                            end
                        
                        else
                            state_next <= read_op_code;
                
                    end
                            
                write_result:
                    begin
                        rd_reg <= 1'b0;
                        if (~tx_full)
                            begin
                                result_reg  <= result;
                                wr_reg      <= 1'b1;
                                state_next  <= idle;
                            end                           
                            
                    end
                                    
            endcase
            
     
        end

    assign w_data  = result_reg;
    assign data_a  = data_a_reg;
    assign data_b  = data_b_reg;
    assign op_code = op_code_reg;
    assign rd_uart = rd_reg;
    assign wr_uart = wr_reg;
                                     
endmodule