`include "Header_File.svh"
module Issue_Unit 
    (

    input logic    [WIDTH-1:0]rd1_Pipeline_1,
    input logic    [WIDTH-1:0]rd1_Pipeline_2,
    input logic    [WIDTH-1:0]rd2_Pipeline_1,
    input logic    [WIDTH-1:0]rd2_Pipeline_2,

    input logic     RF_Write_en_0_I,
    input logic     RF_Write_en_1_I,

    input logic     Mem_Read_en_0_I,
    input logic     Mem_Read_en_1_I,

    input logic     Mem_Write_en_0_I,
    input logic     Mem_Write_en_1_I,
    
    input logic     Sign_Extender_en_0_I,
    input logic     Sign_Extender_en_1_I,

    input logic     [ALU_OP-1:0]ALU_OP_0_I,
    input logic     [ALU_OP-1:0]ALU_OP_1_I,

    input logic     JAL_en_0_I,
    input logic     JAL_en_1_I,

    input logic     JALR_en_0_I,
    input logic     JALR_en_1_I,

    input logic     [LOAD_TYPE-1:0]Load_Type_0_I,
    input logic     [LOAD_TYPE-1:0]Load_Type_1_I,


    input logic     [1:0]Store_Type_0_I,
    input logic     [1:0]Store_Type_1_I,

    input logic     [4:0]Shift_Size_0_I,
    input logic     [4:0]Shift_Size_1_I,

    // input logic     [WIDTH-1:0]Imm_0_I,
    // input logic     [WIDTH-1:0]Imm_1_I,

    input logic     imm_en_0_I,
    input logic     imm_en_1_I,

    input logic     [4:0]rd_0_I,
    input logic     [4:0]rd_1_I,

    input logic     [WIDTH-1:0]PC_0_I,
    input logic     [WIDTH-1:0]PC_1_I,

    input logic     [1:0]Branch_en_0_I,
    input logic     [1:0]Branch_en_1_I,

    output logic    [WIDTH-1:0]Branch_Pipeline_rd1_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_rd2_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_rd_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_PC_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_imm_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_imm_en_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_shift_size_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_ALU_OP_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_JALR_en_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_JAL_en_out,
    output logic    Branch_Pipeline_RF_write_en_out,

    output logic    [WIDTH-1:0]Memory_Pipeline_rd1_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_rd2_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_rd_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_PC_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_imm_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_imm_en_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_shift_size_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_ALU_OP_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_Mem_Read_en_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_Mem_Write_en_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_JAL_en_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_JALR_en_out,
    output logic    Memory_Pipeline_RF_write_en_out
    );
    
    logic    [WIDTH-1:0]rs1[1:0],
    logic    [WIDTH-1:0]rs2[1:0],

    logic     [1:0]RF_Write_en_Issue,
    logic     [1:0]Mem_Read_en_Issue,
    logic     [1:0]Mem_Write_en_Issue,
    logic     [1:0]Sign_Extender_en_Issue,
    logic     [ALU_OP-1:0]ALU_OP_Issue[1:0],
    logic     [1:0]JAL_en_Issue,
    logic     [1:0]JALR_en_Issue,
    logic     [LOAD_TYPE-1:0]Load_Type_Issue[1:0],
    logic     [1:0]Store_Type_Issue[1:0],
    logic     [4:0]Shift_Size[1:0],
    // logic     [WIDTH-1:0]Imm[1:0],
    logic     [1:0]imm_en,
    logic     [4:0]rd[1:0],
    logic     [WIDTH-1:0]PC[1:0],
    logic     [1:0]Branch_en[1:0],

    assign RF_Write_en_Issue = {RF_Write_en_1_I , RF_Write_en_0_I};
    assign Mem_Read_en_Issue = {Mem_Read_en_1_I , Mem_Read_en_0_I};
    assign Mem_Write_en_Issue = {Mem_Write_en_1_I , Mem_Write_en_0_I};
    assign Sign_Extender_en_Issue = {Sign_Extender_en_1_I , Sign_Extender_en_0_I};
    assign ALU_OP_Issue = {ALU_OP_1_I , ALU_OP_0_I};
    assign JAL_en_Issue = {JAL_en_1_I , JAL_en_0_I};
    assign JALR_en_Issue = {JALR_en_1_I , JALR_en_0_I};
    assign Load_Type_Issue = {Load_Type_1_I , Load_Type_0_I};
    assign Store_Type_Issue = {Store_Type_1_I , Store_Type_0_I};
    assign Shift_Size = {Shift_Size_1_I , Shift_Size_0_I};
    // assign Imm = {Imm_1_I , Imm_0_I};
    assign imm_en = {imm_en_1_I , imm_en_0_I};
    assign rd = {rd_1_I , rd_0_eI};
    assign PC = {PC_1_I , PC_0_I};
    assign Branch_en = {Branch_en_1_I , Branch_en_0_I};



    assign rs1[0] = rd1_Pipeline_1;
    assign rs1[1] = rd1_Pipeline_2;
    assign rs2[0] = rd2_Pipeline_1;
    assign rs2[1] = rd2_Pipeline_2;

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
                    Branch_Pipeline_rd1_out = rs1[0];
                    Branch_Pipeline_rd2_out = rs2[0];
                    Branch_Pipeline_rd_out  = rd[0];
                    Branch_Pipeline_PC_out  = PC[0];
                    // Branch_Pipeline_imm_out = Imm[0];
                    Branch_Pipeline_imm_en_out = imm_en[0];
                    Branch_Pipeline_shift_size_out = Shift_Size[0];
                    Branch_Pipeline_ALU_OP_out = ALU_OP_Issue[0];
                    Branch_Pipeline_JAL_en_out = JAL_en_Issue[0];
                    Branch_Pipeline_JALR_en_out = JALR_en_Issue[0];
                    Branch_Pipeline_RF_write_en_out = RF_Write_en_Issue[0];

                    Memory_Pipeline_rd1_out = rs1[1];
                    Memory_Pipeline_rd2_out = rs2[1];
                    Memory_Pipeline_rd_out  = rd[1];
                    Memory_Pipeline_PC_out  = PC[1];
                    // Memory_Pipeline_imm_out = Imm[1];
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
                    Branch_Pipeline_rd1_out = rs1[1];
                    Branch_Pipeline_rd2_out = rs2[1];
                    Branch_Pipeline_rd_out  = rd[1];
                    Branch_Pipeline_PC_out  = PC[1];
                    // Branch_Pipeline_imm_out = Imm[1];
                    Branch_Pipeline_imm_en_out = imm_en[1];
                    Branch_Pipeline_shift_size_out = Shift_Size[1];
                    Branch_Pipeline_ALU_OP_out = ALU_OP_Issue[1];
                    Branch_Pipeline_JAL_en_out = JAL_en_Issue[1];
                    Branch_Pipeline_JALR_en_out = JALR_en_Issue[1];
                    Branch_Pipeline_RF_write_en_out = RF_Write_en_Issue[1];

                    Memory_Pipeline_rd1_out = rs1[0];
                    Memory_Pipeline_rd2_out = rs2[0];
                    Memory_Pipeline_rd_out  = rd[0];
                    Memory_Pipeline_PC_out  = PC[0];
                    // Memory_Pipeline_imm_out = Imm[0];
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
                    Branch_Pipeline_rd1_out = 32'd0;
                    Branch_Pipeline_rd2_out = 32'd0;
                    Branch_Pipeline_rd_out  = 32'd0;
                    Branch_Pipeline_PC_out  = 32'd0;
                    // Branch_Pipeline_imm_out = 32'd0;
                    Branch_Pipeline_imm_en_out = 32'd0;
                    Branch_Pipeline_shift_size_out = 32'd0;
                    Branch_Pipeline_ALU_OP_out = 32'd0;
                    Branch_Pipeline_JAL_en_out = 32'd0;
                    Branch_Pipeline_JALR_en_out = 32'd0;
                    Branch_Pipeline_RF_write_en_out = 32'd0;

                    Memory_Pipeline_rd1_out = 32'd0;
                    Memory_Pipeline_rd2_out = 32'd0;
                    Memory_Pipeline_rd_out  = 32'd0;
                    Memory_Pipeline_PC_out  = 32'd0;
                    // Memory_Pipeline_imm_out = 32'd0;
                    Memory_Pipeline_imm_en_out = 32'd0;
                    Memory_Pipeline_shift_size_out = 32'd0;
                    Memory_Pipeline_ALU_OP_out = 32'd0;
                    Memory_Pipeline_Mem_Read_en_out = 32'd0;
                    Memory_Pipeline_Mem_Write_en_out = 32'd0;
                    Memory_Pipeline_JAL_en_out = 32'd0;
                    Memory_Pipeline_JALR_en_out = 32'd0;
                    Memory_Pipeline_RF_write_en_out = 32'd0;
                end
            endcase
        end

         else
         begin
            Branch_Pipeline_rd1_out = rs1[0];
            Branch_Pipeline_rd2_out = rs2[0];
            Branch_Pipeline_rd_out  = rd[0];
            Branch_Pipeline_PC_out  = PC[0];
            // Branch_Pipeline_imm_out = Imm[0];
            Branch_Pipeline_imm_en_out = imm_en[0];
            Branch_Pipeline_shift_size_out = Shift_Size[0];
            Branch_Pipeline_ALU_OP_out = ALU_OP_Issue[0];
            Branch_Pipeline_JAL_en_out = JAL_en_Issue[0];
            Branch_Pipeline_JALR_en_out = JALR_en_Issue[0];
            Branch_Pipeline_RF_write_en_out = RF_Write_en_Issue[0];

            Memory_Pipeline_rd1_out = rs1[1];
            Memory_Pipeline_rd2_out = rs2[1];
            Memory_Pipeline_rd_out  = rd[1];
            Memory_Pipeline_PC_out  = PC[1];
            // Memory_Pipeline_imm_out = Imm[1];
            Memory_Pipeline_imm_en_out = imm_en[1];
            Memory_Pipeline_shift_size_out = Shift_Size[1];
            Memory_Pipeline_ALU_OP_out = ALU_OP_Issue[1];
            Memory_Pipeline_Mem_Read_en_out = Mem_Read_en_Issue[1];
            Memory_Pipeline_Mem_Write_en_out = Mem_Write_en_Issue[1];
            Memory_Pipeline_JAL_en_out = JAL_en_Issue[1];
            Memory_Pipeline_JALR_en_out = JALR_en_Issue[1];
            Memory_Pipeline_RF_write_en_out = RF_Write_en_Issue[1];
         end
    end
endmodule