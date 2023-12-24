
module alu_tb();
    reg [31:0] a,b;
    wire [3:0] ALUFlags;
    reg [2:0] ALUControl;
    reg clk, reset;
    reg [102:0] testvector[0:10000000]; // Se cambio la cantidad de bits del testvector para que no haya warnings
    wire [31:0] Result;
    reg [31:0] Result_expected; 
    reg [3:0] ALUFlags_expected;
    reg [31:0] vectornum; 
    reg [4:0] errors; // Solo 5 bits para marcar errores ya que solo hay 21 posibles errores como max.

    alu dut(.a(a),.b(b),.ALUControl(ALUControl),.Result(Result),.ALUFlags(ALUFlags));

    always begin
        clk=1; #5; clk=0; #5;
    end
    
    initial begin
        $readmemh("alu_test_vector.tv", testvector);
        errors=0;
        vectornum=0;
        reset = 1; #17; reset=0;
    end

    always @(posedge clk)
    begin
        ALUFlags_expected=testvector[vectornum][3:0];
        Result_expected=testvector[vectornum][35:4];
        b = testvector[vectornum][67:36];
        a = testvector[vectornum][99:68];
        ALUControl = testvector[vectornum][102:100];
    end

    always @(negedge clk)
    begin
        if  (~reset)
            begin
                if ((Result !== Result_expected) || (ALUFlags !== ALUFlags_expected))
                    begin
                        $display();
                        $display("Testvector: %h", testvector[vectornum]);
                        $display("Vectornum: %d", vectornum);
                        $display();
                        $display("Input a: %h", {a});
                        $display("Input b: %h", {b});
                        $display("Input ALUControl: %b", {ALUControl});
                        $display();
                        $display("Output Result del ALU: %h", Result);
                        $display("Output Result que pusimos en la tabla: %h", Result_expected);
                        $display();
                        $display("Output ALUFlags del ALU: %b", ALUFlags);
                        $display("Output ALUFlags que pusimos en la tabla: %b", ALUFlags_expected);
                        $display();
                        errors=errors+1;
                    end
                vectornum = vectornum+1;

                if (testvector[vectornum][0] === 1'bx)
                    begin
                        $display("Errores Totales:%d",errors);
                        $finish;  
                    end
            end
    end

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars;
    end

endmodule

