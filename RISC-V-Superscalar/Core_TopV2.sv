`include "Header_File.svh"
module Core_Top(
    input logic clk,
    input logic rst,
);
    logic [WIDTH-1:0]PC_Out_Pipeline_1_F;
    logic [WIDTH-1:0]PC_Out_Pipeline_0_F;

    logic [WIDTH-1:0]PC_Normal_Pipeline_0;
    logic [WIDTH-1:0]PC_Normal_Pipeline_1;

    logic [WIDTH-1:0]Instruction_IM_Pipeline_0_F;
    logic [WIDTH-1:0]Instruction_IM_Pipeline_1_F;

    Kogge_Stone PC_Incrementer_0(
        .in0(PC_Out_Pipeline_0_F),
        .in1(32'd4),

        .sub_en(1'b0),
        .out(PC_Normal_Pipeline_0)
    );

    Kogge_Stone PC_Incrementer_1(
        .in0(PC_Out_Pipeline_1_F),
        .in1(32'd4),

        .sub_en(1'b0),
        .out(PC_Normal_Pipeline_1)
    );

    PC PC(
        .clk(clk),
        .rst(rst),

        .PC_in_Pipeline_0(PC_Normal_Pipeline_0),
        .PC_in_Pipeline_1(PC_Normal_Pipeline_1),

        .PC_out_Pipeline_0(PC_out_Pipeline_0_F),
        .PC_out_Pipeline_1(PC_out_Pipeline_1_F)
    );



    Instruction_Memory Instruction_Memory(
        .Program_counter_IM_Pipeline_0(PC_out_Pipeline_0_F),
        .Program_counter_IM_Pipeline_1(PC_out_Pipeline_1_F),

        .Instruction_IM_Pipeline_0(Instruction_IM_Pipeline_0_F),
        .Instruction_IM_Pipeline_1(Instruction_IM_Pipeline_1_F)
    );

    //---------------Decoder Pipeline------------------------

    logic [WIDTH-1:0]PC_out_Pipeline_0_Dec;
    logic [WIDTH-1:0]Instruction_IM_Pipeline_0_Dec;
    Decoder_Pipeline_0 Decoder_Pipeline_0(
        .clk(clk),
        .rst(rst),

        .PC_out_Pipeline_0_F(PC_out_Pipeline_0_F),
        .Instruction_IM_Pipeline_0_F(Instruction_IM_Pipeline_0_F),

        .PC_out_Pipeline_0_Dec(PC_out_Pipeline_0_Dec),
        .Instruction_IM_Pipeline_0_Dec(Instruction_IM_Pipeline_0_Dec)
    );

    logic [WIDTH-1:0]PC_out_Pipeline_1_Dec;
    logic [WIDTH-1:0]Instruction_IM_Pipeline_1_Dec;
    Decoder_Pipeline_1 Decoder_Pipeline_1(
        .clk(clk),
        .rst(rst),

        .PC_out_Pipeline_1_F(PC_out_Pipeline_1_F),
        .Instruction_IM_Pipeline_1_F(Instruction_IM_Pipeline_1_F),

        .PC_out_Pipeline_1_Dec(PC_out_Pipeline_1_Dec),
        .Instruction_IM_Pipeline_1_Dec(Instruction_IM_Pipeline_1_Dec)
    );

    //_______________________________________________________

    logic [4:0]op_code_0_Dec;
    logic [4:0]op_code_1_Dec;

    logic [3:0]sub_op_code_0_Dec;
    logic [3:0]sub_op_code_1_Dec;

    logic [RS-1:0]rs1_0_Dec;
    logic [RS-1:0]rs1_1_Dec;

    logic [RS-1:0]rs2_0_Dec;
    logic [RS-1:0]rs2_1_Dec;

    logic [RD-1:0]rd_0_Dec;
    logic [RD-1:0]rd_1_Dec;

    logic [WIDTH-1:0]imm_0_Dec;
    logic [WIDTH-1:0]imm_1_Dec;

    logic [4:0]shift_size_0_Dec;
    logic [4:0]shift_size_1_Dec;

    Decoder Decoder(
        .inst_0(Instruction_IM_Pipeline_0_Dec),
        .inst_1(Instruction_IM_Pipeline_1_Dec),

        .op_code_0(op_code_0_Dec),
        .op_code_1(op_code_1_Dec),

        .sub_op_code_0(sub_op_code_0_Dec),
        .sub_op_code_1(sub_op_code_1_Dec),

        .rs1_0(rs1_0_Dec),
        .rs1_1(rs1_1_Dec),

        .rs2_0(rs2_0_Dec),
        .rs2_1(rs2_1_Dec),

        .rd_0(rd_0_Dec),
        .rd_1(rd_1_Dec),

        .imm_0(imm_0_Dec),
        .imm_1(imm_1_Dec),

        .shift_size_0(shift_size_0_Dec),
        .shift_size_1(shift_size_1_Dec)
    );


    logic imm_en_0_Dec;
    logic imm_en_1_Dec;

    logic rf_write_en_0_Dec;
    logic rf_write_en_1_Dec;

    logic mem_read_en_0_Dec;
    logic mem_read_en_1_Dec;

    logic mem_write_en_0_Dec;
    logic mem_write_en_1_Dec;

    logic [1:0] branch_mode_0_Dec;
    logic [1:0] branch_mode_1_Dec;

    logic JALR_en_0_Dec;
    logic JALR_en_1_Dec;

    logic [1:0] JAL_en_0_Dec;
    logic [1:0] JAL_en_1_Dec;

    logic [1:0] sign_extender_en_0_Dec;
    logic [1:0] sign_extender_en_1_Dec;

    logic [1:0] sign_extender_type_0_Dec;
    logic [1:0] sign_extender_type_1_Dec;

    logic [2:0] load_type_0_Dec;
    logic [2:0] load_type_1_Dec;

    logic [1:0] store_type_0_Dec;
    logic [1:0] store_type_1_Dec;

    logic [3:0] alu_op_0_Dec;
    logic [3:0] alu_op_1_Dec;



    // Çıkış sinyalleri (Control_Unit’ten gelenler)
    logic imm_en_0_Dec;
    logic imm_en_1_Dec;

    logic rf_write_en_0_Dec;
    logic rf_write_en_1_Dec;

    logic mem_read_en_0_Dec;
    logic mem_read_en_1_Dec;

    logic mem_write_en_0_Dec;
    logic mem_write_en_1_Dec;

    logic [1:0] branch_mode_0_Dec;
    logic [1:0] branch_mode_1_Dec;

    logic JALR_en_0_Dec;
    logic JALR_en_1_Dec;

    logic [1:0] JAL_en_0_Dec;
    logic [1:0] JAL_en_1_Dec;

    logic [1:0] sign_extender_en_0_Dec;
    logic [1:0] sign_extender_en_1_Dec;

    logic [1:0] sign_extender_type_0_Dec;
    logic [1:0] sign_extender_type_1_Dec;

    logic [2:0] load_type_0_Dec;
    logic [2:0] load_type_1_Dec;

    logic [1:0] store_type_0_Dec;
    logic [1:0] store_type_1_Dec;

    logic [3:0] alu_op_0_Dec;
    logic [3:0] alu_op_1_Dec;

    // Giriş sinyalleri (Control_Unit’e gidenler)
    logic [4:0] op_code_0;
    logic [4:0] op_code_1;

    logic [3:0] sub_op_code_0;
    logic [3:0] sub_op_code_1;

    // Control_Unit örneklemesi (bağlantılar _Dec sinyallerine)
    Control_Unit control_unit_inst (
        .op_code_0(op_code_0_Dec),
        .op_code_1(op_code_1_Dec),

        .sub_op_code_0(sub_op_code_0),
        .sub_op_code_1(sub_op_code_1),
        .imm_en_0(imm_en_0_Dec),
        .imm_en_1(imm_en_1_Dec),
        .rf_write_en_0(rf_write_en_0_Dec),
        .rf_write_en_1(rf_write_en_1_Dec),
        .mem_read_en_0(mem_read_en_0_Dec),
        .mem_read_en_1(mem_read_en_1_Dec),
        .mem_write_en_0(mem_write_en_0_Dec),
        .mem_write_en_1(mem_write_en_1_Dec),
        .branch_mode_0(branch_mode_0_Dec),
        .branch_mode_1(branch_mode_1_Dec),
        .JALR_en_0(JALR_en_0_Dec),
        .JALR_en_1(JALR_en_1_Dec),
        .JAL_en_0(JAL_en_0_Dec),
        .JAL_en_1(JAL_en_1_Dec),
        .sign_extender_en_0(sign_extender_en_0_Dec),
        .sign_extender_en_1(sign_extender_en_1_Dec),
        .sign_extender_type_0(sign_extender_type_0_Dec),
        .sign_extender_type_1(sign_extender_type_1_Dec),
        .load_type_0(load_type_0_Dec),
        .load_type_1(load_type_1_Dec),
        .store_type_0(store_type_0_Dec),
        .store_type_1(store_type_1_Dec),
        .alu_op_0(alu_op_0_Dec),
        .alu_op_1(alu_op_1_Dec)
    );
    
    //---------------Issue Pipeline------------------------
    //_______________________________________________________

    logic [RS-1:0]rs1_0_I;
    logic [RS-1:0]rs1_1_I;

    logic [RS-1:0]rs2_0_I;
    logic [RS-1:0]rs2_1_I;

    logic [RD-1:0]rd_Branch_I;
    logic [RD-1:0]rd_Memory_I;

    logic [WIDTH-1:0]wd_Branch_I;
    logic [WIDTH-1:0]wd_Memory_I;

    logic [WIDTH-1:0]PC_out_Branch_I;
    logic [WIDTH-1:0]PC_out_Memory_I;
    

    logic write_en_Branch_I;
    logic write_en_Memory_I;

    logic [RD-1:0]rd1_0_I;
    logic [RD-1:0]rd1_1_I;

    logic [RD-1:0]rd2_RF_0_I;
    logic [RD-1:0]rd2_0_I;
    logic [RD-1:0]rd2_RF_1_I;
    logic [RD-1:0]rd2_1_I;


    RF RF(
        .clk(clk),
        .rst(rst),

        .rs1_0(rs1_0_I),
        .rs1_1(rs1_1_I),
        .rs1_0(rs2_0_I),
        .rs2_1(rs2_1_I),

        .rd_Branch(rd_Branch_WB),
        .rd_Memory(rd_Memory_WB),

        .wd_Branch(wd_Branch_WB),
        .wd_Memory(wd_Memory_WB),

        .PC_out_Memory(PC_out_Branch_WB),
        .PC_out_Branch(PC_out_Memory_WB),

        .write_en_Branch(write_en_Branch_WB),
        .write_en_Memory(write_en_Memory_WB),

        .rd1_0(rd1_0_I),
        .rd1_1(rd1_1_I),
        
        .rd2_0(rd2_RF_0_I),
        .rd2_1(rd2_RF_1_I)
    );

    logic [IMM-1:0]Imm_I;
    logic [OPCODE-1:0]op_code_I;

    logic sign_extender_en_I;
    logic sign_extender_type_I;

    logic [IMM-1:0]Imm_SE_I;

    Sign_Extender Sign_Extender (
        .in(Imm_I),
        .op_code(op_code_I),
        .sign_extender_en(sign_extender_en_I),
        .sign_extender_type(sign_extender_type_I),
        .imm_out(Imm_SE_I)
    );

    always_comb
    begin:RD2_MUX
        case()

        endcase

        case()
            
        endcase
    end

    logic rf_write_en_0_I;
    logic rf_write_en_1_I;

    logic mem_read_en_0_I;
    logic mem_read_en_1_I;

    logic mem_write_en_0_I;
    logic mem_write_en_1_I;

    logic branch_mode_0_I;
    logic branch_mode_1_I;

    logic JALR_en_0_I;
    logic JALR_en_1_I;

    logic JAL_en_0_I;
    logic JAL_en_1_I;

    logic sign_extender_en_0_I;
    logic sign_extender_en_1_I;

    logic sign_extender_type_0_I;
    logic sign_extender_type_1_I;

    logic load_type_0_I;
    logic load_type_1_I;

    logic store_type_0_I;
    logic store_type_1_I;

    logic alu_op_0_I;
    logic alu_op_1_I;

    logic shift_size_0_I;
    logic shift_size_1_I;

    logic imm_en_0_I;
    logic imm_en_1_I;

    logic PC_0_I;
    logic PC_1_I;
    
    logic branch_mode_0_I;
    logic branch_mode_1_I;

    logic Branch_Pipeline_rd1_out_I;
    logic Branch_Pipeline_rd2_out_I;
    logic Branch_Pipeline_rd_out_I;
    logic Branch_Pipeline_PC_out_I;
    // logic Branch_Pipeline_imm_out_I;  // Yorum satırıydı, istersen açabilirim
    logic Branch_Pipeline_imm_en_out_I;
    logic Branch_Pipeline_shift_size_out_I;
    logic Branch_Pipeline_ALU_OP_out_I;
    logic Branch_Pipeline_JALR_en_out_I;
    logic Branch_Pipeline_JAL_en_out_I;
    logic Branch_Pipeline_RF_write_en_out_I;

    logic Memory_Pipeline_rd1_out_I;
    logic Memory_Pipeline_rd2_out_I;
    logic Memory_Pipeline_rd_out_I;
    logic Memory_Pipeline_PC_out_I;
    // logic Memory_Pipeline_imm_out_I;  // Yorum satırıydı, istersen açabilirim
    logic Memory_Pipeline_imm_en_out_I;
    logic Memory_Pipeline_shift_size_out_I;
    logic Memory_Pipeline_ALU_OP_out_I;
    logic Memory_Pipeline_Mem_Read_en_out_I;
    logic Memory_Pipeline_Mem_Write_en_out_I;
    logic Memory_Pipeline_JAL_en_out_I;
    logic Memory_Pipeline_JALR_en_out_I;
    logic Memory_Pipeline_RF_write_en_out_I;

    Issue_Unit issue_unit_inst (
        .rd1_Pipeline_1(rd1_0_I),
        .rd1_Pipeline_2(rd1_1_I),
        .rd2_Pipeline_1(rd2_0_I),
        .rd2_Pipeline_2(rd2_1_I),

        .RF_Write_en_0_I(rf_write_en_0_I),
        .RF_Write_en_1_I(rf_write_en_1_I),

        .Mem_Read_en_0_I(mem_read_en_0_I),
        .Mem_Read_en_1_I(mem_read_en_1_I),

        .Mem_Write_en_0_I(mem_write_en_0_I),
        .Mem_Write_en_1_I(mem_write_en_1_I),

        .Sign_Extender_en_0_I(sign_extender_en_0_I),
        .Sign_Extender_en_1_I(sign_extender_en_1_I),

        .ALU_OP_0_I(alu_op_0_I),
        .ALU_OP_1_I(alu_op_1_I),

        .JAL_en_0_I(JAL_en_0_I),
        .JAL_en_1_I(JAL_en_1_I),

        .JALR_en_0_I(JALR_en_0_I),
        .JALR_en_1_I(JALR_en_1_I),

        .Load_Type_0_I(load_type_0_I),
        .Load_Type_1_I(load_type_1_I),

        .Store_Type_0_I(store_type_0_I),
        .Store_Type_1_I(store_type_1_I),

        .Shift_Size_0_I(shift_size_0_I),
        .Shift_Size_1_I(shift_size_1_I),

        .imm_en_0_I(imm_en_0_I),
        .imm_en_1_I(imm_en_1_I),

        .rd_0_I(rd_Branch_I),
        .rd_1_I(rd_memory_I),

        .PC_0_I(PC_0_I),
        .PC_1_I(PC_1_I),

        .Branch_en_0_I(branch_mode_0_I),
        .Branch_en_1_I(branch_mode_1_I),

        .Branch_Pipeline_rd1_out(Branch_Pipeline_rd1_out),
        .Branch_Pipeline_rd2_out(Branch_Pipeline_rd2_out),
        .Branch_Pipeline_rd_out(Branch_Pipeline_rd_out),
        .Branch_Pipeline_PC_out(Branch_Pipeline_PC_out),
        // .Branch_Pipeline_imm_out(),
        .Branch_Pipeline_imm_en_out(Branch_Pipeline_imm_en_out),
        .Branch_Pipeline_shift_size_out(Branch_Pipeline_shift_size_out),
        .Branch_Pipeline_ALU_OP_out(Branch_Pipeline_ALU_OP_out),
        .Branch_Pipeline_JALR_en_out(Branch_Pipeline_JALR_en_out),
        .Branch_Pipeline_JAL_en_out(Branch_Pipeline_JAL_en_out),
        .Branch_Pipeline_RF_write_en_out()Branch_Pipeline_RF_write_en_out,

        .Memory_Pipeline_rd1_out(Memory_Pipeline_rd1_out),
        .Memory_Pipeline_rd2_out(Memory_Pipeline_rd2_out),
        .Memory_Pipeline_rd_out(Memory_Pipeline_rd_out),
        .Memory_Pipeline_PC_out(Memory_Pipeline_PC_out),
        // .Memory_Pipeline_imm_out(),
        .Memory_Pipeline_imm_en_out(Memory_Pipeline_imm_en_out),
        .Memory_Pipeline_shift_size_out(Memory_Pipeline_shift_size_out),
        .Memory_Pipeline_ALU_OP_out(Memory_Pipeline_ALU_OP_out),
        .Memory_Pipeline_Mem_Read_en_out(Memory_Pipeline_Mem_Read_en_out),
        .Memory_Pipeline_Mem_Write_en_out(Memory_Pipeline_Mem_Write_en_out),
        .Memory_Pipeline_JAL_en_out(Memory_Pipeline_JAL_en_out),
        .Memory_Pipeline_JALR_en_out(Memory_Pipeline_JALR_en_out),
        .Memory_Pipeline_RF_write_en_out(Memory_Pipeline_RF_write_en_out)
    );

    Forwarding_MUX  Forwarding_MUX_Branch_1 (
        .Normal           (),  
        .Branch_Execute   (),  
        .Memory_Execute   (),  
        .Branch_Memory    (),  
        .Memory_Memory    (),  
        .Branch_WB        (),  
        .Memory_WB        (),  
        .Control_Signal   (3'b000),  
        .out              ()   
    );

    Forwarding_MUX  Forwarding_MUX_Branch_2 (
        .Normal           (),  
        .Branch_Execute   (),  
        .Memory_Execute   (),  
        .Branch_Memory    (),  
        .Memory_Memory    (),  
        .Branch_WB        (),  
        .Memory_WB        (),   
        .Control_Signal   (3'b000),  
        .out              ()   
    );

    Forwarding_MUX  Forwarding_MUX_Memory_1 (
        .Normal           (),  
        .Branch_Execute   (),  
        .Memory_Execute   (),  
        .Branch_Memory    (),  
        .Memory_Memory    (),  
        .Branch_WB        (),  
        .Memory_WB        (),    
        .Control_Signal   (3'b000),  
        .out              ()   
    );

    Forwarding_MUX  Forwarding_MUX_Memory_2 (
        .Normal           (),  
        .Branch_Execute   (),  
        .Memory_Execute   (),  
        .Branch_Memory    (),  
        .Memory_Memory    (),  
        .Branch_WB        (),  
        .Memory_WB        (),    
        .Control_Signal   (3'b000),  
        .out              ()   
    );
    //---------------Execute Pipeline------------------------
    //_______________________________________________________

    logic Branch_Pipeline_ALU_rd1;
    logic Branch_Pipeline_ALU_rd2;
    logic Branhc_Pipeline_op;
    logic Branhc_Pipeline_shift_size;

    logic Branch_Pipeline_ALU_out;
    logic Branch_Pipeline_Branch_Feedback;

    ALU Branch_ALU(
        .rd1()Branch_Pipeline_ALU_rd1,
        .rd2(Branch_Pipeline_ALU_rd2),
        .op(Branhc_Pipeline_op),
        .shifter_size(Branhc_Pipeline_shift_size),

        .result(Branch_Pipeline_ALU_out),
        .branch_control(Branch_Pipeline_Branch_Feedback) 
    );

    logic Memory_Pipeline_rd1;
    logic Memory_Pipeline_rd2;
    logic Memory_Pipeline_op;
    logic Memory_Pipeline_shifter_size;
    logic Memory_Pipeline_ALU_out;

    ALU Memory_ALU(
        .rd1(Memory_Pipeline_rd1),
        .rd2(Memory_Pipeline_rd2),
        .op(Memory_Pipeline_op),
        .shifter_size(Memory_Pipeline_shifter_size),
        .result(Memory_Pipeline_ALU_out)
    );
    //---------------Memory Pipeline------------------------
    //_______________________________________________________


    logic Memory_Pipeline_ALU_out;
    logic Memory_Pipeline_mem_read_en;
    logic Memory_Pipeline_mem_write_en;

    logic Memory_Pipeline_rd2;
    logic Memory_pipelien_Memory_out;

    Memory Memory(
        .clk(clk),
        .rst(rst),

        .address(Memory_Pipeline_ALU_out),
        .mem_read_en(Memory_Pipeline_mem_read_en),
        .mem_write_en(Memory_Pipeline_mem_write_en),
        .write_data(Memory_Pipeline_rd2),
        .read_data(Memory_pipelien_Memory_out)
    );

    always_comb 
    begin:LOAD_MUX
        case()
        endcase
    end

    
    //---------------Write Back Pipeline------------------------
    //_______________________________________________________

    always_comb
    begin:RF_MUX

    end

endmodule