`include "Header_File.svh"
module Decoder
(
    input logic  [WIDTH-1:0] inst_0,
    input logic  [WIDTH-1:0] inst_1,

    output logic [4:0] op_code_0 ,
    output logic [4:0] op_code_1 ,

    output logic [3:0] sub_op_code_0 ,
    output logic [3:0] sub_op_code_1 ,

    output logic [RS-1:0] rs1_0, 
    output logic [RS-1:0] rs1_1, 

    output logic [RS-1:0] rs2_0,
    output logic [RS-1:0] rs2_1,

    output logic [RD-1:0] rd_0,
    output logic [RD-1:0] rd_1,

    output logic [WIDTH-1:0] imm_0,
    output logic [WIDTH-1:0] imm_1,

    output logic [4:0] shift_size_0,
    output logic [4:0] shift_size_1
);  

    logic [WIDTH-1:0] inst [1:0];
    assign inst[0] = inst_0;
    assign inst[1] = inst_1;

    integer i;

    always_comb begin
        for (i = 0; i < 2; i = i + 1) begin
            case (inst[i][6:2])
                5'b01101: // LUI
                begin
                    op_code[i]       = inst[i][6:2];
                    sub_op_code[i]   = {inst[i][30], inst[i][14:12]};
                    shift_size[i]    = 5'd0;
                    imm[i]           = {inst[i][31:12], 12'd0};
                    rs1[i]           = 5'd0;
                    rs2[i]           = 5'd0;
                    rd[i]            = inst[i][11:7];
                end

                5'b00101: // AUIPC
                begin
                    op_code[i]       = inst[i][6:2];
                    sub_op_code[i]   = {inst[i][30], inst[i][14:12]};
                    shift_size[i]    = 5'd0;
                    imm[i]           = {inst[i][31:12], 12'd0};
                    rs1[i]           = 5'd0;
                    rs2[i]           = 5'd0;
                    rd[i]            = inst[i][11:7];
                end

                5'b00100: // I-Type (Immediate ALU Operations)
                begin
                    op_code[i]       = inst[i][6:2];
                    sub_op_code[i]   = {inst[i][30], inst[i][14:12]};
                    shift_size[i]    = inst[i][24:20];
                    imm[i]           = {{20{inst[i][31]}}, inst[i][31:20]};
                    rs1[i]           = inst[i][19:15];
                    rs2[i]           = 5'd0;
                    rd[i]            = inst[i][11:7];
                end

                5'b01100: // R-Type (Register ALU Operations)
                begin
                    op_code[i]       = inst[i][6:2];
                    sub_op_code[i]   = {inst[i][30], inst[i][14:12]};
                    shift_size[i]    = inst[i][24:20];
                    imm[i]           = 32'd0;
                    rs1[i]           = inst[i][19:15];
                    rs2[i]           = inst[i][24:20];
                    rd[i]            = inst[i][11:7];
                end

                5'b00000: // Load Type
                begin
                    op_code[i]       = inst[i][6:2];
                    sub_op_code[i]   = {inst[i][30], inst[i][14:12]};
                    shift_size[i]    = 5'd0;
                    imm[i]           = {{20{inst[i][31]}}, inst[i][31:20]};
                    rs1[i]           = inst[i][19:15];
                    rs2[i]           = 5'd0;
                    rd[i]            = inst[i][11:7];
                end

                5'b01000: // Store Type
                begin
                    op_code[i]       = inst[i][6:2];
                    sub_op_code[i]   = {inst[i][30], inst[i][14:12]};
                    shift_size[i]    = 5'd0;
                    imm[i]           = {{20{inst[i][31]}}, inst[i][31:25], inst[i][11:7]};
                    rs1[i]           = inst[i][19:15];
                    rs2[i]           = inst[i][24:20];
                    rd[i]            = 5'd0;
                end

                5'b11011: // JAL (Jump and Link)
                begin
                    op_code[i]       = inst[i][6:2];
                    sub_op_code[i]   = 4'b1111;
                    shift_size[i]    = 5'd0;
                    imm[i]           = {{12{inst[i][31]}}, inst[i][19:12], inst[i][20], inst[i][30:21], 1'b0};
                    rs1[i]           = 5'd0;
                    rs2[i]           = 5'd0;
                    rd[i]            = inst[i][11:7];
                end

                5'b11001: // JALR (Jump and Link Register)
                begin
                    op_code[i]       = inst[i][6:2];
                    sub_op_code[i]   = 4'd0;
                    shift_size[i]    = 5'd0;
                    imm[i]           = {{20{inst[i][31]}}, inst[i][31:20]};
                    rs1[i]           = inst[i][19:15];
                    rs2[i]           = 5'd0;
                    rd[i]            = inst[i][11:7];
                end

                5'b11000: // Branch Type
                begin
                    op_code[i]       = inst[i][6:2];
                    sub_op_code[i]   = {inst[i][30], inst[i][14:12]};
                    shift_size[i]    = 5'd0;
                    imm[i]           = {{19{inst[i][31]}}, inst[i][31], inst[i][7], inst[i][30:25], inst[i][11:8], 1'b0};
                    rs1[i]           = inst[i][19:15];
                    rs2[i]           = inst[i][24:20];
                    rd[i]            = 5'd0;
                end

                default: // Invalid instruction
                begin
                    op_code[i]       = 5'd0;
                    sub_op_code[i]   = 4'd0;
                    shift_size[i]    = 5'd0;
                    imm[i]           = 32'd0;
                    rs1[i]           = 5'd0;
                    rs2[i]           = 5'd0;
                    rd[i]            = 5'd0;
                end
            endcase
        end
    end

    logic [4:0] op_code [1:0];
    logic [3:0] sub_op_code [1:0];

    logic [RS-1:0] rs1 [1:0]; 
    logic [RS-1:0] rs2 [1:0];
    logic [RD-1:0] rd [1:0];

    logic [WIDTH-1:0] imm [1:0];
    logic [4:0] shift_size [1:0];

    assign op_code_0 = op_code[0];
    assign op_code_1 = op_code[1];

    assign sub_op_code_0 = sub_op_code[0];
    assign sub_op_code_1 = sub_op_code[1];

    assign rs1_0 = rs1[0];
    assign rs1_1 = rs1[1];

    assign rs2_0 = rs2[0];
    assign rs2_1 = rs2[1];

    assign rd_0 = rd[0];
    assign rd_1 = rd[1];

    assign imm_0 = imm[0];
    assign imm_1 = imm[1];

    assign shift_size_0 = shift_size[0];
    assign shift_size_1 = shift_size[1];

endmodule
