`include "Header_File.svh"

module Decode_Register(
    input logic clk,
    input logic rst,

    input logic [WIDTH-1:0] Normal_F,
    input logic [WIDTH-1:0] PC_out_F,
    input logic [WIDTH-1:0] InstructionMemory_out_F[1:0],

    output logic [WIDTH-1:0] Normal_De,
    output logic [WIDTH-1:0] PC_out_De,
    output logic [WIDTH-1:0] InstructionMemory_out_De[1:0]
);

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            Normal_De <= 32'd0;
            PC_out_De <= 32'd0;
            InstructionMemory_out_De <= '{default: 32'd0};
        end else begin
            Normal_De <= Normal_F;
            PC_out_De <= PC_out_F;
            InstructionMemory_out_De <= InstructionMemory_out_F;
        end
    end
endmodule

module Issue_Register (
    input logic clk,
    input logic rst,

    input logic [WIDTH-1:0]Normal_De,
    input logic [WIDTH-1:0]PC_out_De,
    input logic [WIDTH-1:0]InstructionMemory_out_De[1:0],

    input logic [RS-1:0] rs1_De[1:0],
    input logic [RS-1:0] rs2_De[1:0],
    input logic [RD-1:0] rd_De[1:0],
    input logic [31:0] imm_De[1:0],
    input logic [31:0] imm_en_De[1:0],
    input logic [WIDTH-1:0]shift_size_De[1:0],
    input logic [LOAD_TYPE-1:0]load_type_De,
    input logic [1:0]store_type_De,
    input logic [1:0]imm_en,
    input logic [1:0]rf_write_en_De,
    input logic [1:0]mem_read_en_De,
    input logic [1:0]mem_write_en_De,
    input logic [1:0]sign_extender_en_De,
    input logic [1:0]sign_extender_type_De,
    input logic [1:0]alu_op_De,

    input logic [1:0]Branch_en_De[1:0],

    input logic [OPCODE-1:0]op_code_De[1:0],

    output logic [WIDTH-1:0]PC_out_Issue[1:0],

    output logic [1:0]Branch_en_Issue[1:0],

    output logic [RS-1:0] rs1_Issue[1:0],
    output logic [RS-1:0] rs2_Issue[1:0],
    output logic [RD-1:0] rd_Issue[1:0],
    output logic [31:0] imm_Issue[1:0],
    output logic [1:0]imm_en_Issue,
    output logic [WIDTH-1:0]shift_size_Issue[1:0],
    output logic [LOAD_TYPE-1:0]load_type_Issue,
    output logic [1:0]store_type_Issue,
    output logic [1:0]imm_Issue,
    output logic [1:0]rf_write_en_Issue,
    output logic [1:0]mem_read_en_Issue,
    output logic [1:0]mem_write_en_Issue,
    output logic [1:0]sign_extender_en_Issue,
    output logic [1:0]sign_extender_type_Issue,

    output logic [OPCODE-1:0]op_code_Issue[1:0],

    output logic [1:0]alu_op_Issue
    
    );

    always_ff @(posedge clk, negedge rst) begin
        if (!rst) 
        begin
            rs1_Issue <= '{default: 5'd0};
            rs2_Issue <= '{default: 5'd0};
            rd_Issue <= '{default: 5'd0};
            imm_Issue <= '{default: 32'd0};
            shift_size_Issue <= '{default: 5'd0};
            load_type_Issue <= '{default: 1'd0};
            store_type_Issue <= '{default: 1'd0};
            imm_Issue <= '{default: 1'd0};
            rf_write_en_Issue <= '{default: 1'd0};
            mem_read_en_Issue <= '{default: 1'd0};
            mem_write_en_Issue <= '{default: 1'd0};
            sign_extender_en_Issue <= '{default: 1'd0};
            sign_extender_type_Issue <= '{default: 1'd0};
            alu_op_Issue <= '{default: 1'd0};
            op_code_Issue <= '{default: 5'd0};
            PC_out_Issue <= '{default: 32'd0};
            imm_en_Issue <= '{default: 1'd0};
        end
        else
        begin
            rs1_Issue <= rs1_De;
            rs2_Issue <= rs2_De;
            rd_Issue <= rd_De;
            imm_Issue <= imm_De;
            shift_size_Issue <= shift_size_De;
            load_type_Issue <= load_type_De;
            store_type_Issue <= store_type_De;
            imm_Issue <= imm_en;
            rf_write_en_Issue <= rf_write_en_De;
            mem_read_en_Issue <= mem_read_en_De;
            mem_write_en_Issue <= mem_write_en_De;
            sign_extender_en_Issue <= sign_extender_en_De;
            sign_extender_type_Issue <= sign_extender_type_De;
            alu_op_Issue <= alu_op_De;
            op_code_Issue <= op_code_De;
            PC_out_Issue <= PC_out_De;
            imm_en_Issue <= imm_en_De;
        end
    end

endmodule

// module Execute_Register (
//     input logic clk,
//     input logic rst,

//     input logic [WIDTH-1:0] Normal_Addr_Issue[1:0],
//     input logic [WIDTH-1:0] PC_out_Issue[1:0],
//     input logic [1:0] PC_MUX_Controller_Issue[1:0],

//     input logic Load_Type_Issue[1:0],
//     input logic Store_Type_Issue[1:0],
//     input logic [1:0] JAL_en_Issue,
//     input logic [1:0] RF_Write_en_Issue,
//     input logic [1:0] Mem_Read_en_Issue,
//     input logic [1:0] Branch_en_Issue,
//     input logic [1:0] Sign_Extender_en_Issue,
//     input logic [1:0] ALU_OP_Issue,
//     input logic [1:0] Imm_Sign_Extended_Issue,

//     input logic [4:0] rs1_Issue[1:0],
//     input logic [4:0] rs2_Issue[1:0],
//     input logic [4:0] rd_Issue[1:0],

//     input logic Flush_Mem,
//     input logic Stall_Mem,

//     output logic [WIDTH-1:0] Normal_Addr_Execute[1:0],
//     output logic [WIDTH-1:0] PC_out_Execute[1:0],
//     output logic [1:0] PC_MUX_Controller_Execute[1:0],
//     output logic Load_Type_Execute[1:0],
//     output logic Store_Type_Execute[1:0],
//     output logic [1:0] JAL_en_Execute,
//     output logic [1:0] RF_Write_en_Execute,
//     output logic [1:0] Mem_Read_en_Execute,
//     output logic [1:0] Branch_en_Execute,
//     output logic [1:0] Sign_Extender_en_Execute,
//     output logic [1:0] ALU_OP_Execute,
//     output logic [1:0] Imm_Sign_Extended_Execute,

//     output logic [4:0] rs1_Execute[1:0],
//     output logic [4:0] rs2_Execute[1:0],
//     output logic [4:0] rd_Execute[1:0]
// );

//     always_ff @(posedge clk or negedge rst) begin
//         if (!rst || Flush_Mem) begin
//             Normal_Addr_Execute <= '{default: 32'd0};
//             PC_out_Execute <= '{default: 32'd0};
//             PC_MUX_Controller_Execute <= '{default: 2'd0};
//             Load_Type_Execute <= '{default: 1'd0};
//             Store_Type_Execute <= '{default: 1'd0};
//             JAL_en_Execute <= '{default: 1'd0};
//             RF_Write_en_Execute <= '{default: 1'd0};
//             Mem_Read_en_Execute <= '{default: 1'd0};
//             Branch_en_Execute <= '{default: 1'd0};
//             Sign_Extender_en_Execute <= '{default: 1'd0};
//             ALU_OP_Execute <= '{default: 1'd0};
//             Imm_Sign_Extended_Execute <= '{default: 1'd0};
//             rs1_Execute <= '{default: 5'd0};
//             rs2_Execute <= '{default: 5'd0};
//             rd_Execute <= '{default: 5'd0};
//         end else if (!Stall_Mem) begin
//             Normal_Addr_Execute <= Normal_Addr_Issue;
//             PC_out_Execute <= PC_out_Issue;
//             PC_MUX_Controller_Execute <= PC_MUX_Controller_Issue;
//             Load_Type_Execute <= Load_Type_Issue;
//             Store_Type_Execute <= Store_Type_Issue;
//             JAL_en_Execute <= JAL_en_Issue;
//             RF_Write_en_Execute <= RF_Write_en_Issue;
//             Mem_Read_en_Execute <= Mem_Read_en_Issue;
//             Branch_en_Execute <= Branch_en_Issue;
//             Sign_Extender_en_Execute <= Sign_Extender_en_Issue;
//             ALU_OP_Execute <= ALU_OP_Issue;
//             Imm_Sign_Extended_Execute <= Imm_Sign_Extended_Issue;
//             rs1_Execute <= rs1_Issue;
//             rs2_Execute <= rs2_Issue;
//             rd_Execute <= rd_Issue;
//         end
//     end
// endmodule

module Execute_Register(
    input logic clk,
    input logic rst,

    input logic [WIDTH-1:0] Branch_Pipeline_rs1_Issue,
    input logic [WIDTH-1:0] Branch_Pipeline_rs2_Issue,
    input logic [4:0]       Branch_Pipeline_rd_Issue,
    input logic [WIDTH-1:0] Branch_Pipeline_PC_Issue,
    input logic [WIDTH-1:0] Branch_Pipeline_Imm_Issue,
    input logic [1:0]Branch_Pipeline_imm_en_Issue,
    input logic [4:0]       Branch_Pipeline_shift_size_Issue,
    input logic [WIDTH-1:0] Branch_Pipeline_ALU_out_Issue,
    input logic [WIDTH-1:0] Branch_Pipeline_ALU_OP_Issue,
    input logic Branch_Pipeline_RF_write_en_out_Issue,

    input logic [WIDTH-1:0] Memory_Pipeline_rs1_Issue,
    input logic [WIDTH-1:0] Memory_Pipeline_rs2_Issue,
    input logic [4:0] Memory_Pipeline_rd_Issue,
    input logic [WIDTH-1:0] Memory_Pipeline_PC_Issue,
    input logic [WIDTH-1:0] Memory_Pipeline_Imm_Issue,
    input logic [1:0]Memory_Pipeline_imm_en_Issue,
    input logic [WIDTH-1:0] Memory_Pipeline_ALU_OP_Issue,
    input logic [WIDTH-1:0] Memory_Pipeline_Mem_Read_en_Issue,
    input logic [WIDTH-1:0] Memory_Pipeline_Mem_Write_en_Issue,
    input logic [4:0]       Memory_Pipeline_shift_size_Issue,
    input logic [WIDTH-1:0]Memory_Pipeline_ALU_out_Issue,
    input logic Memory_Pipeline_RF_write_en_out_Issue,

    output logic [WIDTH-1:0] Branch_Pipeline_rs1_Execute,
    output logic [WIDTH-1:0] Branch_Pipeline_rs2_Execute,
    output logic [4:0] Branch_Pipeline_rd_Execute,
    output logic [WIDTH-1:0] Branch_Pipeline_PC_Execute,
    output logic [WIDTH-1:0] Branch_Pipeline_Imm_Execute,
    output logic [1:0]Branch_Pipeline_imm_en_Execute,
    output logic [4:0]Branch_Pipeline_shift_size_Execute,
    output logic [WIDTH-1:0]Branch_Pipeline_ALU_out_Execute,
    output logic [WIDTH-1:0] Branch_Pipeline_ALU_OP_Execute,
    output logic Branch_Pipeline_RF_write_en_out_Execute,


    output logic [WIDTH-1:0] Memory_Pipeline_rs1_Execute,
    output logic [WIDTH-1:0] Memory_Pipeline_rs2_Execute,
    output logic [4:0] Memory_Pipeline_rd_Execute,
    output logic [WIDTH-1:0] Memory_Pipeline_PC_Execute,
    output logic [WIDTH-1:0] Memory_Pipeline_Imm_Execute,
    output logic [1:0]Memory_Pipeline_imm_en_Execute,
    output logic [4:0]Memory_Pipeline_shift_size_Execute,
    output logic [WIDTH-1:0]Memory_Pipeline_ALU_out_Execute,
    output logic [WIDTH-1:0] Memory_Pipeline_ALU_OP_Execute,
    output logic [WIDTH-1:0] Memory_Pipeline_Mem_Read_en_Execute,
    output logic [WIDTH-1:0] Memory_Pipeline_Mem_Write_en_Execute,
    output logic Memory_Pipeline_RF_write_en_out_Execute
    );

    always_ff @(posedge clk , negedge rst)
    begin
        if(~rst)
        begin
            Branch_Pipeline_rs1_Execute <= 32'd0;
            Branch_Pipeline_rs2_Execute <= 32'd0;
            Branch_Pipeline_rd_Execute <= 5'd0;
            Branch_Pipeline_PC_Execute <= 32'd0;
            Branch_Pipeline_Imm_Execute <= 32'd0;
            Branch_Pipeline_imm_en_Execute <= 2'd0;
            Branch_Pipeline_shift_size_Execute <= 5'd0;
            Branch_Pipeline_ALU_out_Execute <= 32'd0;
            Branch_Pipeline_ALU_OP_Execute <= 32'd0;
            Branch_Pipeline_RF_write_en_out_Execute <= 1'b0;
            

            Memory_Pipeline_rs1_Execute <= 32'd0;
            Memory_Pipeline_rs2_Execute <= 32'd0;
            Memory_Pipeline_rd_Execute <= 5'd0;
            Memory_Pipeline_PC_Execute <= 32'd0;
            Memory_Pipeline_Imm_Execute <= 32'd0;
            Memory_Pipeline_imm_en_Execute <= 2'd0;
            Memory_Pipeline_shift_size_Execute <= 5'd0;
            Memory_Pipeline_ALU_out_Execute <= 32'd0;
            Memory_Pipeline_ALU_OP_Execute <= 32'd0;
            Memory_Pipeline_Mem_Read_en_Execute <= 32'd0;
            Memory_Pipeline_Mem_Write_en_Execute <= 32'd0;
            Memory_Pipeline_RF_write_en_out_Execute <= 1'b0;
        end

        else
        begin
            Branch_Pipeline_rs1_Execute <= Branch_Pipeline_rs1_Issue;
            Branch_Pipeline_rs2_Execute <= Branch_Pipeline_rs2_Issue;
            Branch_Pipeline_rd_Execute <= Branch_Pipeline_rd_Issue;
            Branch_Pipeline_PC_Execute <= Branch_Pipeline_PC_Issue;
            Branch_Pipeline_Imm_Execute <= Branch_Pipeline_Imm_Issue;
            Branch_Pipeline_imm_en_Execute <= Branch_Pipeline_imm_en_Issue;
            Branch_Pipeline_shift_size_Execute <= Branch_Pipeline_shift_size_Issue;
            Branch_Pipeline_ALU_out_Execute <= Branch_Pipeline_ALU_out_Issue;
            Branch_Pipeline_ALU_OP_Execute <= Branch_Pipeline_ALU_OP_Issue;
            Branch_Pipeline_RF_write_en_out_Execute <= Branch_Pipeline_RF_write_en_out_Issue;

            Memory_Pipeline_rs1_Execute <= Memory_Pipeline_rs1_Issue;
            Memory_Pipeline_rs2_Execute <= Memory_Pipeline_rs2_Issue;
            Memory_Pipeline_rd_Execute <= Memory_Pipeline_rd_Issue;
            Memory_Pipeline_PC_Execute <= Memory_Pipeline_PC_Issue;
            Memory_Pipeline_Imm_Execute <= Memory_Pipeline_Imm_Issue;
            Memory_Pipeline_imm_en_Execute <= Memory_Pipeline_imm_en_Issue;
            Memory_Pipeline_shift_size_Execute <= Memory_Pipeline_shift_size_Issue;
            Memory_Pipeline_ALU_out_Execute <= Memory_Pipeline_ALU_out_Issue;
            Memory_Pipeline_ALU_OP_Execute <= Memory_Pipeline_ALU_OP_Issue;
            Memory_Pipeline_Mem_Read_en_Execute <= Memory_Pipeline_Mem_Read_en_Issue;
            Memory_Pipeline_Mem_Write_en_Execute <= Memory_Pipeline_Mem_Write_en_Issue;
            Memory_Pipeline_RF_write_en_out_Execute <= Memory_Pipeline_RF_write_en_out_Issue;
        end
    end
endmodule

module Memory_Register(
    input logic clk,
    input logic rst,

    input logic [WIDTH-1:0] ALU_Memory_Out_Execute,
    input logic [4:0] Memory_Pipeline_rd_Execute,
    input logic Memory_Write_en_Execute,
    input logic Memory_Read_en_Execute,
    input logic [WIDTH-1:0] Memory_Pipeline_rs2_Execute,
    input logic [WIDTH-1:0] Memory_Pipeline_PC_Execute,

    input logic [WIDTH-1:0] ALU_Branch_Out_Execute,
    input logic [4:0] Branch_Pipeline_rd_Execute,
    input logic [WIDTH-1:0] Branch_Pipeline_PC_Execute,

    output logic [WIDTH-1:0] ALU_Memory_Out_Mem,
    output logic [4:0] Memory_Pipeline_rd_Mem,
    output logic Memory_Write_en_Mem,
    output logic Memory_Read_en_Mem,
    output logic [WIDTH-1:0] Memory_Pipeline_rs2_Mem,
    output logic [WIDTH-1:0] Memory_Pipeline_PC_Mem,

    output logic [WIDTH-1:0] ALU_Branch_Out_Mem,
    output logic [4:0] Branch_Pipeline_rd_Mem,
    output logic [WIDTH-1:0] Branch_Pipeline_PC_Mem
);

    always_ff @(posedge clk or negedge rst)
    begin
        if (~rst) begin
            ALU_Memory_Out_Mem       <= '0;
            Memory_Pipeline_rd_Mem   <= '0;
            Memory_Write_en_Mem      <= 1'b0;
            Memory_Read_en_Mem       <= 1'b0;
            Memory_Pipeline_rs2_Mem  <= '0;
            Memory_Pipeline_PC_Mem   <= '0;

            ALU_Branch_Out_Mem       <= '0;
            Branch_Pipeline_rd_Mem   <= '0;
            Branch_Pipeline_PC_Mem   <= '0;
        end
        else begin
            ALU_Memory_Out_Mem       <= ALU_Memory_Out_Execute;
            Memory_Pipeline_rd_Mem   <= Memory_Pipeline_rd_Execute;
            Memory_Write_en_Mem      <= Memory_Write_en_Execute;
            Memory_Read_en_Mem       <= Memory_Read_en_Execute;
            Memory_Pipeline_rs2_Mem  <= Memory_Pipeline_rs2_Execute;
            Memory_Pipeline_PC_Mem   <= Memory_Pipeline_PC_Execute;

            ALU_Branch_Out_Mem       <= ALU_Branch_Out_Execute;
            Branch_Pipeline_rd_Mem   <= Branch_Pipeline_rd_Execute;
            Branch_Pipeline_PC_Mem   <= Branch_Pipeline_PC_Execute;
        end
    end

endmodule


module WriteBack_Register(
    input logic rst,
    input logic clk,

    input logic [WIDTH-1:0]RF_wd_Memory_in_Mem,
    input logic [4:0]Memory_Pipeline_rd_Mem,
    input logic Memory_Pipeline_RF_en_Mem,
    input logic [WIDTH-1:0]Memory_Pipeline_PC_Mem,
    input logic Memory_Read_en_Mem,

    input logic [WIDTH-1:0]ALU_Branch_Out_Mem,
    input logic [4:0]Branch_Pipeline_rd_Mem,
    input logic Branch_Pipeline_RF_en_Mem,
    input logic [WIDTH-1:0]Branch_Pipeline_PC_Mem,

    output logic [WIDTH-1:0]RF_wd_Memory_in_WB,
    output logic [4:0]Memory_Pipeline_rd_WB,
    output logic Memory_Pipeline_RF_en_WB,
    output logic [WIDTH-1:0]Memory_Pipeline_PC_WB,
    output logic Memory_Read_en_WB,

    output logic [WIDTH-1:0]ALU_Branch_Out_WB,
    output logic [4:0]Branch_Pipeline_rd_WB,
    output logic Branch_Pipeline_RF_en_WB,
    output logic [WIDTH-1:0]Branch_Pipeline_PC_WB
    );

    always_ff @(posedge clk , negedge rst)
    begin
        if(~rst)
        begin
            ALU_Memory_Out_WB <= 32'd0;
            Memory_Data_WB <= 32'd0;
            Memory_Pipeline_rd_WB <= 5'd0;
            Memory_Pipeline_RF_en_WB <= 1'b0;
            Memory_Pipeline_PC_WB <= 32'd0;

            ALU_Branch_Out_WB <= 32'd0;
            Branch_Pipeline_rd_WB <= 5'd0;
            Branch_Pipeline_RF_en_WB <= 1'b0;
            Branch_Pipeline_PC_WB <= 32'd0;
        end

        else
        begin
            ALU_Memory_Out_WB <= ALU_Memory_Out_Mem;
            Memory_Data_WB <= Memory_Data_Mem;
            Memory_Pipeline_rd_WB <= Memory_Pipeline_rd_Mem;
            Memory_Pipeline_RF_en_WB <= Memory_Pipeline_RF_en_Mem;
            Memory_Pipeline_PC_WB <= Memory_Pipeline_PC_Mem;

            ALU_Branch_Out_WB <= ALU_Branch_Out_Mem;
            Branch_Pipeline_rd_WB <= Branch_Pipeline_rd_Mem;
            Branch_Pipeline_RF_en_WB <= Branch_Pipeline_RF_en_Mem;
            Branch_Pipeline_PC_WB <= Branch_Pipeline_PC_Mem;
        end
    end
endmodule