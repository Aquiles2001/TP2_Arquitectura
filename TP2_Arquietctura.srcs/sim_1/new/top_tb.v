`timescale 1ns / 1ps

module top_tb
    #(
        parameter D_BIT    = 8,
        parameter SB_TICK  = 16,
        parameter DVSR     = 326,
        parameter DVSR_BIT = 9,
        parameter FIFO_W   = 8,
        parameter SIZE_COD = 6
    ); 
    
    // Parámetros de operaciones
    localparam ADD  = 6'b100000;
    localparam SUB  = 6'b100010;
    localparam AND  = 6'b100100;  
    localparam OR   = 6'b100101;
    localparam XOR  = 6'b100110;
    localparam SRA  = 6'b000011;
    localparam SRL  = 6'b000010;
    localparam NOR  = 6'b100111;
    
    // Señales del testbench
    reg                 clock;
    reg                 reset;
    reg signed [D_BIT - 1 : 0] dato_a;
    reg signed [D_BIT - 1 : 0] dato_b;
    reg signed [D_BIT - 1 : 0] w_data;
    reg signed [D_BIT - 1 : 0] r_data;
    reg                 rx;
    wire                tx;
    reg [2:0]           choice_op;
    
    integer baud_rate = DVSR * SB_TICK * 10;
    
    integer i = 0;
    
    // Generador de reloj
    always begin
        #5 clock = ~clock; // Cambia el reloj cada 5 unidades de tiempo
    end       

    task automatic generate_randoms();
        begin
            dato_a = $random % (2 ** D_BIT) ;
            dato_b = $random % (2 ** D_BIT) ;
        end
    endtask
    
    task automatic send();
        begin 
            rx = 1'b0;
            
            #(baud_rate);
            
            for (i = 0; i < D_BIT; i = i + 1)
                begin
                    rx = w_data[i];
                    #(baud_rate);
                end
            
            rx = 1'b1;
            
            #(baud_rate);
        end
    endtask
    
    task automatic receive();
        begin
            while (tx)
                #1;
                
            #(baud_rate);
            
            for (i = 0; i < D_BIT; i = i + 1)
                begin
                    r_data[i] = tx;
                    #(baud_rate);
                end
            
            while (~tx)
                #1;
                
            #(baud_rate);
        end
    endtask
    
    task automatic ADD_t();
        begin
            $display("Suma %b + %b", dato_a, dato_b);
            
            w_data  = ADD;
            send();
            #20;
            
            w_data = {D_BIT{1'b0}};
            receive();
            #20;
            
            if ((dato_a + dato_b) == r_data)
                $display("Respuesta correcto");
            else
                $display("Respuesta incorrecto");
        end
    endtask
    
    task automatic SUB_t();
        begin
            $display("Resta %b - %b", dato_a, dato_b);
        
            w_data  = SUB;
            send();
            #20;
            
            w_data = {D_BIT{1'b0}};
            receive();
            #20;
            
            if ((dato_a - dato_b) == r_data)
                $display("Respuesta correcto");
            else
                $display("Respuesta incorrecto");     
        end
    endtask

    task automatic AND_t();
        begin
            $display("And %b & %b", dato_a, dato_b);
        
            w_data  = AND;
            send();
            #20;
            
            w_data = {D_BIT{1'b0}};
            receive();
            #20;
            
            if ((dato_a & dato_b) == r_data)
                $display("Respuesta correcto");
            else
                $display("Respuesta incorrecto");
        end
    endtask

    task automatic OR_t();
        begin
            $display("Or %b | %b", dato_a, dato_b);
        
            w_data  = OR;
            send();
            #20;
            
            w_data = {D_BIT{1'b0}};
            receive();
            #20;
            
            if ((dato_a | dato_b) == r_data)
                $display("Respuesta correcto");
            else
                $display("Respuesta incorrecto");
        end
    endtask
    
    task automatic XOR_t();
        begin
            $display("Xor %b ^ %b", dato_a, dato_b);
        
            w_data  = XOR;
            send();
            #20;
            
            w_data = {D_BIT{1'b0}};
            receive();
            #20;
            
            if ((dato_a ^ dato_b) == r_data)
                $display("Respuesta correcto");
            else
                $display("Respuesta incorrecto");
        end
    endtask
    
    task automatic SRA_t();
        begin
            $display("Sra %b >>> %b", dato_a, dato_b);
        
            w_data  = SRA;
            send();
            #20;
            
            w_data = {D_BIT{1'b0}};
            receive();
            #20;
            
            if ((dato_a >>> dato_b) == r_data)
                $display("Respuesta correcto");
            else
                $display("Respuesta incorrecto");
        end
    endtask
    
    task automatic SRL_t();
        begin
            $display("Srl %b >> %b", dato_a, dato_b);
        
            w_data  = SRL;
            send();
            #20;
            
            w_data = {D_BIT{1'b0}};
            receive();
            #20;
            
            if ((dato_a >> dato_b) == r_data)
                $display("Respuesta correcto");
            else
                $display("Respuesta incorrecto");
        end
    endtask

    task automatic NOR_t();
        begin
            $display("Nor ~(%b | %b)", dato_a, dato_b);
        
            w_data  = NOR;
            send();
            #20;
            
            w_data = {D_BIT{1'b0}};
            receive();
            #20;
            
            if (~(dato_a | dato_b) == r_data)
                $display("Respuesta correcto");
            else
                $display("Respuesta incorrecto");
        end
    endtask
    
    initial
    begin
        
        $srandom(1234);
        clock = 1'b0;
        reset = 1'b0;
        rx    = 1'b1;
        
        #10 @(posedge clock) reset = 1'b1;
        #10 @(posedge clock) reset = 1'b0;
        #10;
               
        repeat (10)
        begin
            generate_randoms();
            
            w_data = dato_a;
            send();
            
            #20;

            w_data = dato_b;
            send();
            
            #20;
            
           choice_op = $random % 8;
            
            case(choice_op)
                0: ADD_t();
                1: SUB_t();
                2: AND_t();
                3: OR_t();
                4: XOR_t();
                5: SRA_t();
                6: SRL_t();
                7: NOR_t();
            endcase
        end
        
        #20 $finish;
    end
    
    
        // Instancias
    top #(.D_BIT(D_BIT), .SB_TICK(SB_TICK), .DVSR(DVSR), .DVSR_BIT(DVSR_BIT), .FIFO_W(FIFO_W), .SIZE_COD(SIZE_COD)) top_level_unit
        (
            .clock(clock), .reset(reset), .rx(rx),
            .tx(tx)
        );
        
endmodule