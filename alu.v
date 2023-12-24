// 32 bit ALU for ARM processor
module alu (input [31:0] a, b, 
            input [2:0] ALUControl,
            output reg [31:0] Result,
            output reg [31:0] Result2,
            output wire [3:0] ALUFlags);
    
    wire negative, zero, carry, overflow;
    wire [31:0] condinvb;
    wire [32:0] sum;
    reg Asign;
    reg Bsign;
    reg [63:0] lres;
    
    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum = a + condinvb + ALUControl;

    always @(*)
    begin
        case (ALUControl[2:0])
            3'b000: Result = sum; 
            3'b001: Result = sum; 
            3'b010: Result = a & b; 
            3'b011: Result = a | b; 
            3'b100: Result = a * b;     //MUL
            3'b101: lres = a * b;       //UMULL
            3'b110: begin               //SMULL
                Asign = a[31];
                Bsign = b[31];
                if(Asign ^ Bsign)begin
                    lres[63] = 1;
                end 
                else begin
                    lres[63] = 0;
                end
                lres[62:0] = a[30:0] * b[30:0];
            end
        endcase
        if (ALUControl[2:0] === 3'b101 || ALUControl[2:0] === 3'b110) begin
                Result = lres[31:0];
                Result2 = lres[63:32];
            end
    end

    assign negative = Result[31];
    assign zero = (Result == 32'b0);
    
    assign carry = (ALUControl[1]==1'b0) & sum[32];
    assign overflow = (ALUControl[1] == 1'b0) & ~(a[31] ^ b[31] ^ ALUControl[0]) & (a[31] ^ sum[31]);
    assign ALUFlags = {negative, zero, carry, overflow};

endmodule
