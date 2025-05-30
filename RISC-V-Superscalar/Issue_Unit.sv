`include "Header_File.svh"
module Issue_Unit 
    (

    input logic    [WIDTH-1:0]rs1[1:0],
    input logic    [WIDTH-1:0]rs2[1:0],

    input logic     [1:0]RF_Write_en_Issue,
    input logic     [1:0]Mem_Read_en_Issue,
    input logic     [1:0]Mem_Write_en_Issue,
    input logic     [1:0]Sign_Extender_en_Issue,
    input logic     [ALU_OP-1:0]ALU_OP_Issue[1:0],
    input logic     [1:0]JAL_en_Issue,
    input logic     [1:0]JALR_en_Issue,
    input logic     [LOAD_TYPE-1:0]Load_Type_Issue[1:0],
    input logic     [1:0]Store_Type_Issue[1:0],
    input logic     [4:0]Shift_Size[1:0],
    input logic     [WIDTH-1:0]Imm[1:0],
    input logic     [1:0]imm_en,
    input logic     [4:0]rd[1:0],
    input logic     [WIDTH-1:0]PC[1:0],

    input logic     [1:0]Branch_en,

    output logic    [WIDTH-1:0]Branch_Pipeline_rs1_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_rs2_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_rd_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_PC_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_imm_out,
    output logic    [1:0]Branch_Pipeline_imm_en_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_shift_size_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_ALU_OP_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_JALR_en_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_JAL_en_out,
    output logic    Branch_Pipeline_RF_write_en_out,

    output logic    [WIDTH-1:0]Memory_Pipeline_rs1_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_rs2_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_rd_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_PC_out,
    output logic    [1:0]Memory_Pipeline_imm_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_imm_en_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_shift_size_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_ALU_OP_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_Mem_Read_en_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_Mem_Write_en_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_JAL_en_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_JALR_en_out,
    output logic    Memory_Pipeline_RF_write_en_out

    );

    logic   [1:0]Store_en;
    assign  Store_en[0] = {|Store_Type_Issue[0][1:0]};
    assign  Store_en[1] = {|Store_Type_Issue[1][1:0]};

    logic   [1:0]Load_en;
    assign  Load_en[0] = {|Load_Type_Issue[0][2:0]};
    assign  Load_en[1] = {|Load_Type_Issue[1][2:0]};

    logic   [1:0]temp_mem;
    assign  temp_mem[0] = Store_en[0] || Load_en[0];
    assign  temp_mem[1] = Store_en[1] || Load_en[1];

    always_comb 
    begin
        if(Store_en[0] || Store_en[1] || Load_en[0] || Load_en[1])
        begin
            case(temp_mem)
                2'b00 , 2'b10 :
                begin
                    Branch_Pipeline_rs1_out = rs1[0];
                    Branch_Pipeline_rs2_out = rs2[0];
                    Branch_Pipeline_rd_out  = rd[0];
                    Branch_Pipeline_PC_out  = PC[0];
                    Branch_Pipeline_imm_out = Imm[0];
                    Branch_Pipeline_imm_en_out = imm_en[0];
                    Branch_Pipeline_shift_size_out = Shift_Size[0];
                    Branch_Pipeline_ALU_OP_out = ALU_OP_Issue[0];
                    Branch_Pipeline_JAL_en_out = JAL_en_Issue[0];
                    Branch_Pipeline_JALR_en_out = JALR_en_Issue[0];
                    Branch_Pipeline_RF_write_en_out = RF_Write_en_Issue[0];

                    Memory_Pipeline_rs1_out = rs1[1];
                    Memory_Pipeline_rs2_out = rs2[1];
                    Memory_Pipeline_rd_out  = rd[1];
                    Memory_Pipeline_PC_out  = PC[1];
                    Memory_Pipeline_imm_out = Imm[1];
                    Memory_Pipeline_imm_en_out = imm_en[1];
                    Memory_Pipeline_shift_size_out = Shift_Size[1];
                    Memory_Pipeline_ALU_OP_out = ALU_OP_Issue[1];
                    Memory_Pipeline_Mem_Read_en_out = Mem_Read_en_Issue[1];
                    Memory_Pipeline_Mem_Write_en_out = Mem_Write_en_Issue[1];
                    Memory_Pipeline_JAL_en_out = JAL_en_Issue[1];
                    Memory_Pipeline_JALR_en_out = JALR_en_Issue[1];
                    Memory_Pipeline_RF_write_en_out = RF_Write_en_Issue[1];
                end

                2'b01:
                begin
                    Branch_Pipeline_rs1_out = rs1[1];
                    Branch_Pipeline_rs2_out = rs2[1];
                    Branch_Pipeline_rd_out  = rd[1];
                    Branch_Pipeline_PC_out  = PC[1];
                    Branch_Pipeline_imm_out = Imm[1];
                    Branch_Pipeline_imm_en_out = imm_en[1];
                    Branch_Pipeline_shift_size_out = Shift_Size[1];
                    Branch_Pipeline_ALU_OP_out = ALU_OP_Issue[1];
                    Branch_Pipeline_JAL_en_out = JAL_en_Issue[1];
                    Branch_Pipeline_JALR_en_out = JALR_en_Issue[1];
                    Branch_Pipeline_RF_write_en_out = RF_Write_en_Issue[1];

                    Memory_Pipeline_rs1_out = rs1[0];
                    Memory_Pipeline_rs2_out = rs2[0];
                    Memory_Pipeline_rd_out  = rd[0];
                    Memory_Pipeline_PC_out  = PC[0];
                    Memory_Pipeline_imm_out = Imm[0];
                    Memory_Pipeline_imm_en_out = imm_en[0];
                    Memory_Pipeline_shift_size_out = Shift_Size[0];
                    Memory_Pipeline_ALU_OP_out = ALU_OP_Issue[0];
                    Memory_Pipeline_Mem_Read_en_out = Mem_Read_en_Issue[0];
                    Memory_Pipeline_Mem_Write_en_out = Mem_Write_en_Issue[0];
                    Memory_Pipeline_JAL_en_out = JAL_en_Issue[0];
                    Memory_Pipeline_JALR_en_out = JALR_en_Issue[0];
                    Memory_Pipeline_RF_write_en_out = RF_Write_en_Issue[0];
                end

                default:
                begin
                    Branch_Pipeline_rs1_out = '0;
                    Branch_Pipeline_rs2_out = '0;
                    Branch_Pipeline_rd_out  = '0;
                    Branch_Pipeline_PC_out  = '0;
                    Branch_Pipeline_imm_out = '0;
                    Branch_Pipeline_imm_en_out = '0;
                    Branch_Pipeline_shift_size_out = '0;
                    Branch_Pipeline_ALU_OP_out = '0;
                    Branch_Pipeline_JAL_en_out = '0;
                    Branch_Pipeline_JALR_en_out = '0;
                    Branch_Pipeline_RF_write_en = '0;

                    Memory_Pipeline_rs1_out = '0;
                    Memory_Pipeline_rs2_out = '0;
                    Memory_Pipeline_rd_out  = '0;
                    Memory_Pipeline_PC_out  = '0;
                    Memory_Pipeline_imm_out = '0;
                    Memory_Pipeline_imm_en_out = '0;
                    Memory_Pipeline_shift_size_out = '0;
                    Memory_Pipeline_ALU_OP_out = '0;
                    Memory_Pipeline_Mem_Read_en_out = '0;
                    Memory_Pipeline_Mem_Write_en_out = '0;
                    Memory_Pipeline_JAL_en_out = '0;
                    Memory_Pipeline_JALR_en_out = '0;
                    Memory_Pipeline_RF_write_en = '0;
                end
            endcase
        end
    end
endmodule