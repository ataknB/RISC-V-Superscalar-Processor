`include "Header_File.svh"
module Core_Top (
	input logic clk,
	input logic rst
	);

	logic [WIDTH-1:0] PC_in [1:0];
	logic [WIDTH-1:0] Normal_F[1:0];
	

	Kogge_Stone PC_Incrementer_0(
		.in0(PC_out_F[0]),
		.in1(32'd4),
		.sub_en(1'b0),

		.out(Normal_F[0])
	);

    Kogge_Stone PC_Incremente_1(
		.in0(PC_out_F[0]),
		.in1(32'd8),
		.sub_en(1'b0),

		.out(Normal_F[1])
	);


	logic [WIDTH-1:0] PC_out_F[1:0];
    
    logic [1:0]temp_PC_MUX_controller;
    assign temp_PC_MUX_controller = 2'd0;


    always_comb 
    begin 
        case(temp_PC_MUX_controller)
            2'b00: PC_in = Normal_F;

            default: PC_in = '{default: 32'd0}; // Default case to avoid latches
        endcase    
    end

	PC PC(
		.clk(clk),
		.rst(rst),
		
		.PC_in(PC_in),
		.PC_out(PC_out_F)
	);

	logic [WIDTH-1:0]InstructionMemory_out_F[1:0];

	Instruction_Memory Instruction_Memory(
        .Program_counter_IM(PC_out_F),          
        .Instruction_IM(InstructionMemory_out_F)     
    );

	logic [WIDTH-1:0] Normal_De[1:0];
	logic [WIDTH-1:0] PC_out_De[1:0];
	logic [WIDTH-1:0] InstructionMemory_out_De[1:0];

	//////////////////////////////////////////////////		
	Decode_Register Decode_Reg(
        .clk                    (clk),
        .rst                    (rst),

        .Normal_F               (Normal_F),
        .PC_out_F               (PC_out_F),
        .InstructionMemory_out_F(InstructionMemory_out_F),

        .Normal_De              (Normal_De),
        .PC_out_De              (PC_out_De),
        .InstructionMemory_out_De(InstructionMemory_out_De)
    );
	//////////////////////////////////////////////////

	logic [OPCODE-1:0] op_code[1:0];
	logic [SUB_OPCODE-1:0] sub_op_code[1:0];
	logic [RS-1:0] rs1_De[1:0];
	logic [RS-1:0] rs2_De[1:0];
	logic [RD-1:0] rd_De[1:0];
	logic [WIDTH-1:0] imm_De[1:0];
	logic [4:0] shift_size_De[1:0];

	Decoder Decoder(
		.inst(InstructionMemory_out_De),
        
        .op_code(op_code),
        .sub_op_code(sub_op_code),
        
        .rs1(rs1_De), 
        .rs2(rs2_De),
        .rd(rd_De),
        
        .imm(imm_De),
        .shift_size(shift_size_De)
	);

	logic [LOAD_TYPE-1:0]load_type_De[1:0];
	logic [1:0]store_type_De[1:0];
	logic [1:0]imm_en_De;
	logic [1:0]rf_write_en_De;
	logic [1:0]mem_read_en_De;
	logic [1:0]mem_write_en_De;

	logic [1:0]sign_extender_en_De;
	logic [1:0]sign_extender_type_De[1:0];
	logic [ALU_OP-1:0]alu_op_De[1:0];
    logic [1:0]Branch_en_De[1:0];

    logic [1:0]JAL_en_De;
    logic [1:0]JALR_en_De;

	Control_Unit Control_Unit(
        .op_code(op_code),
        .sub_op_code(sub_op_code),
		
		.load_type(load_type_De),
		.store_type(store_type_De),

		.JAL_en(JAL_en_De),
		.JALR_en(JALR_en_De),
        .imm_en(imm_en_De),
        .rf_write_en(rf_write_en_De),
        .mem_read_en(mem_read_en_De),
        .mem_write_en(mem_write_en_De),
        .branch_mode(Branch_en_De),
        .sign_extender_en(sign_extender_en_De),
        .sign_extender_type(sign_extender_type_De),
        .alu_op(alu_op_De)
    );

    logic [RS-1:0] rs1_Issue[1:0];
    logic [RS-1:0] rs2_Issue[1:0];
    logic [RD-1:0] rd_Issue[1:0];
    logic [31:0]   imm_Issue[1:0];
    logic [4:0] shift_size_Issue[1:0];

    logic [LOAD_TYPE-1:0] load_type_Issue[1:0];
    logic [1:0] store_type_Issue[1:0];
    logic [1:0] rf_write_en_Issue;
    logic [1:0] mem_read_en_Issue;
    logic [1:0] mem_write_en_Issue;
    logic [1:0] sign_extender_en_Issue;
    logic [1:0] sign_extender_type_Issue[1:0];
    logic [3:0] alu_op_Issue[1:0];
    logic [OPCODE-1:0]op_code_Issue[1:0];
    logic [WIDTH-1:0] PC_out_Issue[1:0];

    logic [1:0]Branch_en_Issue[1:0];  
    logic [1:0]temp_Branch_en_Issue;  
     

    logic [1:0]imm_en_Issue;

    logic [1:0]JAL_en_Issue;
    logic [1:0]JALR_en_Issue;

	///////////////////////////////////////
	Issue_Register Issue_Register (
        .clk(clk),
        .rst(rst),

        .Normal_De(Normal_De),
        .PC_out_De(PC_out_De),

        .rs1_De(rs1_De),
        .rs2_De(rs2_De),
        .rd_De(rd_De),
        .imm_De(imm_De),
        .imm_en_De(imm_en_De),
        .shift_size_De(shift_size_De),
        .load_type_De(load_type_De),
        .store_type_De(store_type_De),
        .rf_write_en_De(rf_write_en_De),
        .mem_read_en_De(mem_read_en_De),
        .mem_write_en_De(mem_write_en_De),
        .sign_extender_en_De(sign_extender_en_De),
        .sign_extender_type_De(sign_extender_type_De),
        .alu_op_De(alu_op_De),
        .op_code_De(op_code),

        .Branch_en_De(Branch_en_De),

        .JAL_en_De(JAL_en_De),
        .JALR_en_De(JALR_en_De),


        .Branch_en_Issue(Branch_en_Issue),

        .PC_out_Issue(PC_out_Issue),
        .rs1_Issue(rs1_Issue),
        .rs2_Issue(rs2_Issue),
        .rd_Issue(rd_Issue),
        .imm_Issue(imm_Issue),
        .imm_en_Issue(imm_en_Issue),
        .shift_size_Issue(shift_size_Issue),
        .load_type_Issue(load_type_Issue),
        .store_type_Issue(store_type_Issue),
        .rf_write_en_Issue(rf_write_en_Issue),
        .mem_read_en_Issue(mem_read_en_Issue),
        .mem_write_en_Issue(mem_write_en_Issue),
        .sign_extender_en_Issue(sign_extender_en_Issue),
        .sign_extender_type_Issue(sign_extender_type_Issue),
        .op_code_Issue(op_code_Issue),
        .alu_op_Issue(alu_op_Issue),

        .JAL_en_Issue(JAL_en_Issue),
        .JALR_en_Issue(JALR_en_Issue)
    );
	///////////////////////////////////////

    logic [WIDTH-1:0]rd1_Issue[1:0];
    logic [WIDTH-1:0]rd2_Issue[1:0];
    
    logic [WIDTH-1:0]ALU_Branch_Out_Mem;
    logic [4:0] Memory_Pipeline_rd_WB;
    logic Memory_Pipeline_RF_en_WB;
    logic [WIDTH-1:0] Memory_Pipeline_PC_WB;
    logic Memory_Read_en_WB;

    logic [WIDTH-1:0] ALU_Branch_Out_WB;
    logic [4:0] Branch_Pipeline_rd_WB;
    logic [WIDTH-1:0] Branch_Pipeline_PC_WB;
    logic Branch_Pipeline_RF_en_WB;
    logic [WIDTH-1:0]RF_wd_Memory_in_WB;

    RF RF(
        .clk(clk),
        .rst(rst),

        .rs1(rs1_Issue),
        .rs2(rs2_Issue),

        .rd_Branch(Branch_Pipeline_rd_WB),
        .rd_Memory(Memory_Pipeline_rd_WB),

        .wd_Branch(ALU_Branch_Out_WB),
        .wd_Memory(RF_wd_Memory_in_WB),

        .PC_out_Memory(Memory_Pipeline_PC_WB),
        .PC_out_Branch(Branch_Pipeline_PC_WB),

        .write_en_Branch(Branch_Pipeline_RF_en_WB),
        .write_en_Memory(Memory_Pipeline_RF_en_WB),

        .rd1(rd1_Issue),
        .rd2(rd2_Issue)
    );


    logic [WIDTH-1:0] Branch_Pipeline_rs1_out_Issue;
    logic [WIDTH-1:0] Branch_Pipeline_rs2_out_Issue;
    logic [WIDTH-1:0] Branch_Pipeline_rd_out_Issue;
    logic [WIDTH-1:0] Branch_Pipeline_PC_out_Issue;
    logic [WIDTH-1:0] Branch_Pipeline_imm_out_Issue;
    logic [1:0] Branch_Pipeline_imm_en_out_Issue;
    logic [WIDTH-1:0] Branch_Pipeline_shift_size_out_Issue;
    logic [WIDTH-1:0] Branch_Pipeline_ALU_OP_out_Issue;
    logic [WIDTH-1:0] Branch_Pipeline_JALR_en_out_Issue;
    logic [WIDTH-1:0] Branch_Pipeline_JAL_en_out_Issue;
    logic Branch_Pipeline_RF_write_en_out_Issue;

    logic [WIDTH-1:0] Memory_Pipeline_rs1_out_Issue;
    logic [WIDTH-1:0] Memory_Pipeline_rs2_out_Issue;
    logic [WIDTH-1:0] Memory_Pipeline_rd_out_Issue;
    logic [WIDTH-1:0] Memory_Pipeline_PC_out_Issue;
    logic [WIDTH-1:0] Memory_Pipeline_imm_out_Issue;
    logic [1:0] Memory_Pipeline_imm_en_out_Issue;
    logic [WIDTH-1:0] Memory_Pipeline_shift_size_out_Issue;
    logic [WIDTH-1:0] Memory_Pipeline_ALU_OP_out_Issue;
    logic [WIDTH-1:0] Memory_Pipeline_Mem_Read_en_out_Issue;
    logic [WIDTH-1:0] Memory_Pipeline_Mem_Write_en_out_Issue;
    logic [WIDTH-1:0] Memory_Pipeline_JAL_en_out_Issue;
    logic [WIDTH-1:0] Memory_Pipeline_JALR_en_out_Issue;
    logic Memory_Pipeline_RF_write_en_out_Issue;

    logic [WIDTH-1:0]imm_out[1:0];

    Sign_Extender Sign_Extender (
        .in(imm_Issue),
        .op_code(op_code_Issue),
        .sign_extender_en(sign_extender_en_Issue),
        .sign_extender_type(sign_extender_type_Issue),
        .imm_out(imm_out)
    );

    Issue_Unit Issue_Unit(
        .rs1(rd1_Issue),
        .rs2(rd2_Issue),
        .RF_Write_en_Issue(rf_write_en_Issue),
        .Mem_Read_en_Issue(mem_read_en_Issue),
        .Mem_Write_en_Issue(mem_write_en_Issue),
        .Sign_Extender_en_Issue(sign_extender_en_Issue),
        .ALU_OP_Issue(alu_op_Issue),

        .JAL_en_Issue(JAL_en_Issue),
        .JALR_en_Issue(JALR_en_Issue),

        .Load_Type_Issue(load_type_Issue),
        .Store_Type_Issue(store_type_Issue),
        .Shift_Size(shift_size_Issue),
        .Imm(imm_out),
        .imm_en(imm_en_Issue),
        .rd(rd_Issue),
        .PC(PC_out_Issue),

        .Branch_en(Branch_en_Issue),

        .Branch_Pipeline_rs1_out(Branch_Pipeline_rs1_out_Issue),
        .Branch_Pipeline_rs2_out(Branch_Pipeline_rs2_out_Issue),
        .Branch_Pipeline_rd_out(Branch_Pipeline_rd_out_Issue),
        .Branch_Pipeline_PC_out(Branch_Pipeline_PC_out_Issue),
        .Branch_Pipeline_imm_out(Branch_Pipeline_imm_out_Issue),
        .Branch_Pipeline_imm_en_out(Branch_Pipeline_imm_en_out_Issue),
        .Branch_Pipeline_shift_size_out(Branch_Pipeline_shift_size_out_Issue),
        .Branch_Pipeline_ALU_OP_out(Branch_Pipeline_ALU_OP_out_Issue),
        .Branch_Pipeline_JALR_en_out(Branch_Pipeline_JALR_en_out_Issue),
        .Branch_Pipeline_JAL_en_out(Branch_Pipeline_JAL_en_out_Issue),
        .Branch_Pipeline_RF_write_en_out(Branch_Pipeline_RF_write_en_out_Issue),

        .Memory_Pipeline_rs1_out(Memory_Pipeline_rs1_out_Issue),
        .Memory_Pipeline_rs2_out(Memory_Pipeline_rs2_out_Issue),
        .Memory_Pipeline_rd_out(Memory_Pipeline_rd_out_Issue),
        .Memory_Pipeline_PC_out(Memory_Pipeline_PC_out_Issue),
        .Memory_Pipeline_imm_out(Memory_Pipeline_imm_out_Issue),
        .Memory_Pipeline_imm_en_out(Memory_Pipeline_imm_en_out_Issue),
        .Memory_Pipeline_shift_size_out(Memory_Pipeline_shift_size_out_Issue),
        .Memory_Pipeline_ALU_OP_out(Memory_Pipeline_ALU_OP_out_Issue),
        .Memory_Pipeline_Mem_Read_en_out(Memory_Pipeline_Mem_Read_en_out_Issue),
        .Memory_Pipeline_Mem_Write_en_out(Memory_Pipeline_Mem_Write_en_out_Issue),
        .Memory_Pipeline_JAL_en_out(Memory_Pipeline_JAL_en_out_Issue),
        .Memory_Pipeline_JALR_en_out(Memory_Pipeline_JALR_en_out_Issue),
        .Memory_Pipeline_RF_write_en_out(Memory_Pipeline_RF_write_en_out_Issue)
    );
    //hem ımmediate değeri hem de rs2 değeri gidiyor mux execute da olcak 

    logic [WIDTH-1:0]Branch_Pipeline_ALU_in1;
    logic [WIDTH-1:0]Branch_Pipeline_ALU_in2;

    logic [WIDTH-1:0]Memory_Pipeline_ALU_in1;
    logic [WIDTH-1:0]Memory_Pipeline_ALU_in2;
    
    logic [WIDTH-1:0]RF_wd_Memory_in_Mem;
	Forwarding_MUX  Forwarding_MUX_Branch_1 (
        .Normal           (Branch_Pipeline_rs1_out_Issue),  
        .Branch_Execute   (Branch_ALU_out),  
        .Memory_Execute   (Memory_ALU_out),  
        .Branch_Memory    (ALU_Branch_Out_Mem),  
        .Memory_Memory    (RF_wd_Memory_in_Mem),  
        .Branch_WB        (ALU_Branch_Out_WB),  
        .Memory_WB        (RF_wd_Memory_in_WB),  
        .Control_Signal   (3'b000),  
        .out              (Branch_Pipeline_ALU_in1)   
    );

    Forwarding_MUX  Forwarding_MUX_Branch_2 (
        .Normal           (Branch_Pipeline_rs2_out_Issue),  
        .Branch_Execute   (Branch_ALU_out),  
        .Memory_Execute   (Memory_ALU_out),  
        .Branch_Memory    (ALU_Branch_Out_Mem),  
        .Memory_Memory    (RF_wd_Memory_in_Mem),  
        .Branch_WB        (ALU_Branch_Out_WB),  
        .Memory_WB        (RF_wd_Memory_in_WB),   
        .Control_Signal   (3'b000),  
        .out              (Branch_Pipeline_ALU_in2)   
    );

    Forwarding_MUX  Forwarding_MUX_Memory_1 (
        .Normal           (Memory_Pipeline_rs1_out_Issue),  
        .Branch_Execute   (Branch_ALU_out),  
        .Memory_Execute   (Memory_ALU_out),  
        .Branch_Memory    (ALU_Branch_Out_Mem),  
        .Memory_Memory    (RF_wd_Memory_in_Mem),  
        .Branch_WB        (ALU_Branch_Out_WB),  
        .Memory_WB        (RF_wd_Memory_in_WB),    
        .Control_Signal   (3'b000),  
        .out              (Memory_Pipeline_ALU_in1)   
    );

    Forwarding_MUX  Forwarding_MUX_Memory_2 (
        .Normal           (Memory_Pipeline_rs2_out_Issue),  
        .Branch_Execute   (Branch_ALU_out),  
        .Memory_Execute   (Memory_ALU_out),  
        .Branch_Memory    (ALU_Branch_Out_Mem),  
        .Memory_Memory    (RF_wd_Memory_in_Mem),  
        .Branch_WB        (ALU_Branch_Out_WB),  
        .Memory_WB        (RF_wd_Memory_in_WB),    
        .Control_Signal   (3'b000),  
        .out              (Memory_Pipeline_ALU_in2)   
    );

    logic [WIDTH-1:0] Branch_Pipeline_rs1_out_Execute;
    logic [WIDTH-1:0] Branch_Pipeline_rs2_out_Execute;
    logic [4:0]       Branch_Pipeline_rd_out_Execute;
    logic [WIDTH-1:0] Branch_Pipeline_PC_out_Execute;
    logic [WIDTH-1:0] Branch_Pipeline_Imm_out_Execute;
    logic [1:0]       Branch_Pipeline_imm_en_out_Execute;
    logic [4:0]       Branch_Pipeline_shift_size_out_Execute;
    logic [WIDTH-1:0] Branch_Pipeline_ALU_out_out_Execute;
    logic [WIDTH-1:0] Branch_Pipeline_ALU_OP_out_Execute;
    logic Branch_Pipeline_RF_write_en_out_Execute;

    logic [WIDTH-1:0] Memory_Pipeline_rs1_out_Execute;
    logic [WIDTH-1:0] Memory_Pipeline_rs2_out_Execute;
    logic [4:0]       Memory_Pipeline_rd_out_Execute;
    logic [WIDTH-1:0] Memory_Pipeline_PC_out_Execute;
    logic [WIDTH-1:0] Memory_Pipeline_Imm_out_Execute;
    logic [1:0]       Memory_Pipeline_imm_en_out_Execute;
    logic [4:0]       Memory_Pipeline_shift_size_out_Execute;
    logic [WIDTH-1:0] Memory_Pipeline_ALU_out_out_Execute;
    logic [WIDTH-1:0] Memory_Pipeline_ALU_OP_out_Execute;
    logic [WIDTH-1:0] Memory_Pipeline_Mem_Read_en_out_Execute;
    logic [WIDTH-1:0] Memory_Pipeline_Mem_Write_en_out_Execute;
    logic Memory_Pipeline_RF_write_en_out_Execute;

    ///////////////////////////////////
    Execute_Register Execute_Register (
        .clk(clk),
        .rst(rst),

        .Branch_Pipeline_rs1_Issue(Branch_Pipeline_ALU_in1),
        .Branch_Pipeline_rs2_Issue(Branch_Pipeline_ALU_in2),
        .Branch_Pipeline_rd_Issue(Branch_Pipeline_rd_out_Issue),
        .Branch_Pipeline_PC_Issue(Branch_Pipeline_PC_out_Issue),
        .Branch_Pipeline_Imm_Issue(Branch_Pipeline_imm_out_Issue),
        .Branch_Pipeline_imm_en_Issue(Branch_Pipeline_imm_en_out_Issue),
        .Branch_Pipeline_shift_size_Issue(Branch_Pipeline_shift_size_out_Issue),
        //.Branch_Pipeline_ALU_out_Issue(Branch_Pipeline_ALU_out_ExecuteReg),
        .Branch_Pipeline_ALU_OP_Issue(Branch_Pipeline_ALU_OP_out_Issue),
        .Branch_Pipeline_RF_write_en_out_Issue(Branch_Pipeline_RF_write_en_out_Issue),

        .Memory_Pipeline_rs1_Issue(Memory_Pipeline_ALU_in1),
        .Memory_Pipeline_rs2_Issue(Memory_Pipeline_ALU_in2),
        .Memory_Pipeline_rd_Issue(Memory_Pipeline_rd_out_Issue),
        .Memory_Pipeline_PC_Issue(Memory_Pipeline_PC_out_Issue),
        .Memory_Pipeline_Imm_Issue(Memory_Pipeline_imm_out_Issue),
        .Memory_Pipeline_imm_en_Issue(Memory_Pipeline_imm_en_out_Issue),
        .Memory_Pipeline_ALU_OP_Issue(Memory_Pipeline_ALU_OP_out_Issue),
        .Memory_Pipeline_Mem_Read_en_Issue(Memory_Pipeline_Mem_Read_en_out_Issue),
        .Memory_Pipeline_Mem_Write_en_Issue(Memory_Pipeline_Mem_Write_en_out_Issue),
        .Memory_Pipeline_shift_size_Issue(Memory_Pipeline_shift_size_out_Issue),
        //.Memory_Pipeline_ALU_out_Issue(Memory_Pipeline_ALU_out_ExecuteReg),
        .Memory_Pipeline_RF_write_en_out_Issue(Memory_Pipeline_RF_write_en_out_Issue),

        .Branch_Pipeline_rs1_Execute(Branch_Pipeline_rs1_out_Execute),
        .Branch_Pipeline_rs2_Execute(Branch_Pipeline_rs2_out_Execute),
        .Branch_Pipeline_rd_Execute(Branch_Pipeline_rd_out_Execute),
        .Branch_Pipeline_PC_Execute(Branch_Pipeline_PC_out_Execute),
        .Branch_Pipeline_Imm_Execute(Branch_Pipeline_Imm_out_Execute),
        .Branch_Pipeline_imm_en_Execute(Branch_Pipeline_imm_en_out_Execute),
        .Branch_Pipeline_shift_size_Execute(Branch_Pipeline_shift_size_out_Execute),
        .Branch_Pipeline_ALU_out_Execute(Branch_Pipeline_ALU_out_out_Execute),
        .Branch_Pipeline_ALU_OP_Execute(Branch_Pipeline_ALU_OP_out_Execute),
        .Branch_Pipeline_RF_write_en_out_Execute(Branch_Pipeline_RF_write_en_out_Execute),

        .Memory_Pipeline_rs1_Execute(Memory_Pipeline_rs1_out_Execute),
        .Memory_Pipeline_rs2_Execute(Memory_Pipeline_rs2_out_Execute),
        .Memory_Pipeline_rd_Execute(Memory_Pipeline_rd_out_Execute),
        .Memory_Pipeline_PC_Execute(Memory_Pipeline_PC_out_Execute),
        .Memory_Pipeline_Imm_Execute(Memory_Pipeline_Imm_out_Execute),
        .Memory_Pipeline_imm_en_Execute(Memory_Pipeline_imm_en_out_Execute),
        .Memory_Pipeline_shift_size_Execute(Memory_Pipeline_shift_size_out_Execute),
        .Memory_Pipeline_ALU_out_Execute(Memory_Pipeline_ALU_out_out_Execute),
        .Memory_Pipeline_ALU_OP_Execute(Memory_Pipeline_ALU_OP_out_Execute),
        .Memory_Pipeline_Mem_Read_en_Execute(Memory_Pipeline_Mem_Read_en_out_Execute),
        .Memory_Pipeline_Mem_Write_en_Execute(Memory_Pipeline_Mem_Write_en_out_Execute),
        .Memory_Pipeline_RF_write_en_out_Execute(Memory_Pipeline_RF_write_en_out_Execute)
    );
    ///////////////////////////////////

    logic [WIDTH-1:0]Branch_ALU_out_Execute;
    logic [WIDTH-1:0]Memory_ALU_out_Execute;

    logic Branch_Feeadback_out_Execute;

    logic [WIDTH-1:0]Branch_ALU_rs2;
    logic [WIDTH-1:0]Memory_ALU_rs2;

    logic [WIDTH-1:0]Memory_ALU_out;
    logic [WIDTH-1:0]Branch_ALU_out;

    always_comb
    begin
        if(Memory_Pipeline_imm_en_out_Execute == 1'b1)
        begin
            Memory_ALU_rs2 = Memory_Pipeline_Imm_out_Execute;
        end
        else
        begin
            Memory_ALU_rs2 = Memory_Pipeline_rs2_out_Execute;
        end

        if(Branch_Pipeline_imm_en_out_Execute == 1'b1)
        begin
            Branch_ALU_rs2 = Branch_Pipeline_Imm_out_Execute;
        end
        else
        begin
            Branch_ALU_rs2 = Branch_Pipeline_rs2_out_Execute;
        end
    end

    ALU Branch_ALU(
        .rs1(Branch_Pipeline_rs1_out_Execute),
        .rs2(Branch_ALU_rs2),
        .op(Branch_Pipeline_ALU_OP_out_Execute),
        .shifter_size(Branch_Pipeline_shift_size_out_Execute),

        .result(Branch_ALU_out),
        .branch_control(Branch_Feeadback_out_Execute) 
    );

    ALU Memory_ALU(
        .rs1(Memory_Pipeline_rs1_out_Execute),
        .rs2(Memory_ALU_rs2),
        .op(Memory_Pipeline_ALU_OP_out_Execute),
        .shifter_size(Memory_Pipeline_shift_size_out_Execute),
        .result(Memory_ALU_out)
    );

    logic [WIDTH-1:0]ALU_Memory_Out_Memory_Mem;
    logic [WIDTH-1:0]ALU_Branch_Out_Memory_Mem;
    logic [4:0]Memory_Pipeline_rd_Mem;
    logic Memory_Write_en_Mem;
    logic Memory_Read_en_Mem;
    logic [WIDTH-1:0]Memory_Pipeline_rs2_Mem;
    logic [WIDTH-1:0]Memory_Pipeline_PC_Mem;

    
    logic [4:0]Branch_Pipeline_rd_Mem;
    logic [WIDTH-1:0]Branch_Pipeline_PC_Mem;

    ///////////////////////////////////
    logic Branch_Pipeline_RF_write_en_out_Mem;
    logic Memory_Pipeline_RF_write_en_out_Mem;

     Memory_Register Memory_Register (
        .clk                        (clk),
        .rst                        (rst),

        .ALU_Memory_Out_Execute     (Memory_ALU_out),
        .Memory_Pipeline_rd_Execute (Memory_Pipeline_rd_out_Execute),
        .Memory_Write_en_Execute    (Memory_Pipeline_Mem_Write_en_out_Execute),
        .Memory_Read_en_Execute     (Memory_Pipeline_Mem_Read_en_out_Execute),
        .Memory_Pipeline_rs2_Execute(Memory_Pipeline_rs2_out_Execute),
        .Memory_Pipeline_PC_Execute (Memory_Pipeline_PC_out_Execute),
        .Memory_Pipeline_RF_write_en_out_Execute(Memory_Pipeline_RF_write_en_out_Execute),

        .ALU_Branch_Out_Execute     (Branch_ALU_out),
        .Branch_Pipeline_rd_Execute (Branch_Pipeline_rd_out_Execute),
        .Branch_Pipeline_PC_Execute (Branch_Pipeline_PC_out_Execute),
        .Branch_Pipeline_RF_write_en_out_Execute(Branch_Pipeline_RF_write_en_out_Execute),

        .ALU_Memory_Out_Mem         (ALU_Memory_Out_Memory_Mem),
        .Memory_Pipeline_rd_Mem     (Memory_Pipeline_rd_Mem),
        .Memory_Write_en_Mem        (Memory_Write_en_Mem),
        .Memory_Read_en_Mem         (Memory_Read_en_Mem),
        .Memory_Pipeline_rs2_Mem    (Memory_Pipeline_rs2_Mem),
        .Memory_Pipeline_PC_Mem     (Memory_Pipeline_PC_Mem),
        .Memory_Pipeline_RF_write_en_out_Mem(Memory_Pipeline_RF_write_en_out_Mem),

        .ALU_Branch_Out_Mem         (ALU_Branch_Out_Mem),
        .Branch_Pipeline_rd_Mem     (Branch_Pipeline_rd_Mem),
        .Branch_Pipeline_PC_Mem     (Branch_Pipeline_PC_Mem),
        .Branch_Pipeline_RF_write_en_out_Mem(Branch_Pipeline_RF_write_en_out_Mem)
    );

    //////////////////////////////////
    logic [WIDTH-1:0] Memory_Data_Out;

    Memory Memory(
        .clk(clk),
        .rst(rst),

        .address(ALU_Memory_Out_Memory_Mem),
        .mem_read_en(Memory_Read_en_Mem),
        .mem_write_en(Memory_Write_en_Mem),
        .write_data(Memory_Pipeline_rs2_Mem),
        .read_data(Memory_Data_Out)
    );
    
    
    

    always_comb
    begin 
        if(Memory_Read_en_Mem)    
        begin
            RF_wd_Memory_in_Mem = Memory_Data_Out;
        end

        else 
        begin
            RF_wd_Memory_in_Mem = ALU_Memory_Out_Memory_Mem;
        end
    end

    ///////////////////////////////////

    logic [WIDTH-1:0] ALU_Memory_Out_WB;
    logic [WIDTH-1:0] Memory_Data_WB;

    WriteBack_Register WriteBack_Register (
        .clk(clk),
        .rst(rst),

        .RF_wd_Memory_in_Mem        (RF_wd_Memory_in_Mem),
        .Memory_Pipeline_rd_Mem    (Memory_Pipeline_rd_Mem),
        .Memory_Pipeline_RF_en_Mem (Memory_Pipeline_RF_write_en_out_Mem),
        .Memory_Pipeline_PC_Mem    (Memory_Pipeline_PC_Mem),
        .Memory_Read_en_Mem         (Memory_Read_en_Mem),

        .ALU_Branch_Out_Mem        (ALU_Branch_Out_Mem),
        .Branch_Pipeline_rd_Mem    (Branch_Pipeline_rd_Mem),
        .Branch_Pipeline_RF_en_Mem (Branch_Pipeline_RF_write_en_out_Mem),
        .Branch_Pipeline_PC_Mem    (Branch_Pipeline_PC_Mem),

        .RF_wd_Memory_in_WB         (RF_wd_Memory_in_WB),
        .Memory_Pipeline_rd_WB     (Memory_Pipeline_rd_WB),
        .Memory_Pipeline_RF_en_WB  (Memory_Pipeline_RF_en_WB),
        .Memory_Pipeline_PC_WB     (Memory_Pipeline_PC_WB),
        .Memory_Read_en_WB         (Memory_Read_en_WB),

        .ALU_Branch_Out_WB         (ALU_Branch_Out_WB),
        .Branch_Pipeline_rd_WB     (Branch_Pipeline_rd_WB),
        .Branch_Pipeline_RF_en_WB  (Branch_Pipeline_RF_en_WB),
        .Branch_Pipeline_PC_WB     (Branch_Pipeline_PC_WB)
    );
    ///////////////////////////////////

    Hazard_Unit Hazard_Unit(
        .rs1_Dec_Branch_Pipeline(rs1_De[0]),
        .rs1_Dec_Memory_Pipeline(rs1_De[1]),

        .rs1_Issue_Branch_Pipeline(rs1_Issue[0]),
        .rs1_Issue_Memory_Pipeline(rs1_Issue[1]),

        .rs2_Dec_Branch_Pipeline(rs2_De[0]),
        .rs2_Dec_Memory_Pipeline(rs2_De[1]),

        .rs2_Issue_Branch_Pipeline(rs2_Issue[0]),
        .rs2_Issue_Memory_Pipeline(rs2_Issue[1]),

        .rd_Issue_Branch_Pipeline(rd_Issue[0]),
        .rd_Issue_Memory_Pipeline(rd_Issue[1]),

        .rd_Ex_Branch_Pipeline(Branch_Pipeline_rd_out_Execute),
        .rd_Ex_Memory_Pipeline(Memory_Pipeline_rd_out_Execute),

        .rd_Mem_Branch_Pipeline(Branch_Pipeline_rd_out_Execute),
        .rd_Mem_Memory_Pipeline(Memory_Pipeline_rd_out_Execute),

        .rd_Wb_Branch_Pipeline(Branch_Pipeline_rd_Mem),
        .rd_Wb_Memory_Pipeline(Memory_Pipeline_rd_Mem),

        //.program_counter_controller_EX(),
        //.Mem_read_en_Ex(),

        .Branch_en(Branch_en_Issue),
        .Load_Type_Issue(Load_Type_Issue),
        .Store_Type_Issue(Store_Type_Issue),

        .Branch_Pipeline_RF_Write_en_Ex(Branch_Pipeline_RF_write_en_out_Execute),
        .Memory_Pipeline_RF_Write_en_Ex(Memory_Pipeline_RF_write_en_out_Execute),

        .Branch_Pipeline_RF_Write_en_Mem(Branch_Pipeline_RF_write_en_out_Mem),
        .Memory_Pipeline_RF_Write_en_Mem(Memory_Pipeline_RF_write_en_out_Mem),

        .Branch_Pipeline_RF_Write_en_WB(Branch_Pipeline_RF_en_WB),
        .Memory_Pipeline_RF_Write_en_WB(Memory_Pipeline_RF_en_WB),

        //.branch_control(branch_control),
        //.branch_decision(branch_decision),

        .Forwarding_Mode_rs1_Branch_Pipeline(),
        .Forwarding_Mode_rs2_Branch_Pipeline(),
        .Forwarding_Mode_rs1_Memory_Pipeline(),
        .Forwarding_Mode_rs2_Memory_Pipeline(),

        //.Branch_Correction(Branch_Correction),

        .Stall_Fetch(Stall_Fetch),
        .Stall_Dec(Stall_Dec),
        .Stall_Issue_Branch_Pipeline(Stall_Issue_Branch_Pipeline),
        .Stall_Issue_Memory_Pipeline(Stall_Issue_Memory_Pipeline),

        .Flush_Ex(Flush_Ex),
        .Flush_Dec(Flush_Dec)
    );
    








endmodule


