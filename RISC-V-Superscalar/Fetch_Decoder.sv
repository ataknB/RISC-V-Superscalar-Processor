`include "Header_File.svh"
module Fetch_Decoder(
    input logic [31:0] inst [1:0],
    
    output logic branch_en [1:0],
    output logic [31:0] imm_out [1:0]
);

    logic [31:0] imm [1:0];
    logic [3:0] sub_op_code [1:0];
    logic sign_extender_type [1:0];

    always_comb begin
        for (int i = 0; i < 2; i++) begin
            if (inst[i][6:2] == 5'b11000) begin
                branch_en[i] = 1'b1;
                sub_op_code[i] = {1'b0, inst[i][14:12]};
                imm[i] = { {20{inst[i][31]}}, inst[i][7], inst[i][30:25], inst[i][11:8], 1'b0 };

                casex(sub_op_code[i])
                    4'bx000: sign_extender_type[i] = 1'b0; // beq
                    4'bx001: sign_extender_type[i] = 1'b0; // bne
                    4'bx100: sign_extender_type[i] = 1'b0; // blt
                    4'bx101: sign_extender_type[i] = 1'b1; // bge
                    4'bx110: sign_extender_type[i] = 1'b1; // bltu
                    4'bx111: sign_extender_type[i] = 1'b1; // bgeu
                    default: sign_extender_type[i] = 1'b0;
                endcase
            end else begin
                branch_en[i] = 1'b0;
                sub_op_code[i] = 4'd0;
                imm[i] = 32'd0;
                sign_extender_type[i] = 1'b0;
            end
        end
    end

    // Sign Extender Instances
    Sign_Extender Sign_Extender_0(
        .in(imm[0]),
        .op_code(5'b11000),
        .sign_extender_en(1'b1),
        .sign_extender_type(sign_extender_type[0]),
        .imm_out(imm_out[0])
    );

    Sign_Extender Sign_Extender_1(
        .in(imm[1]),
        .op_code(5'b11000),
        .sign_extender_en(1'b1),
        .sign_extender_type(sign_extender_type[1]),
        .imm_out(imm_out[1])
    );

endmodule
