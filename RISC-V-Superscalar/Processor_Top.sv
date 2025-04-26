module Core_Top #(
	parameter WIDTH = 32,
	parameter RS = 5,
	parameter IMM = 32,
	parameter SUB_OPCODE = 4,
	parameter LOAD_TYPE  = 3,
	parameter ALU_OP = 4
	parameter FORWARD_MODE = 2

	)(
	input logic clk,
	input logic rst,
	);

	logic [WIDTH-1:0] Jump_Addr_Ex;
	logic [WIDTH-1:0] Jump_Addr_Mem;

	logic [WIDTH-1:0] Branch_Addr_Ex;
	logic [WIDTH-1:0] Branch_Addr_Mem;

	logic [WIDTH-1:0] Normal_Addr_Fetch;
	logic [WIDTH-1:0] Normal_Addr_Dec;
	logic [WIDTH-1:0] Normal_Addr_Issue;
	logic [WIDTH-1:0] Normal_Addr_Ex;
	logic [WIDTH-1:0] Normal_Addr_Mem;

	logic [WIDTH-1:0]PC_in;

	logic [WIDTH-1:0]PC_out_Fetch;
	logic [WIDTH-1:0]PC_out_Dec;
	logic [WIDTH-1:0]PC_out_EX;
	logic [WIDTH-1:0]PC_out_Issue;
	logic [WIDTH-1:0]PC_out_Mem;
	logic [WIDTH-1:0]PC_out_Wb;

	logic [1:0]PC_MUX_Controller;

	//DATA HAZARD SIGNALS
	logic [1:0]Stall_Fetch;
	logic [1:0]Stall_Dec;
	logic [1:0]Stall_Issue;
	logic [1:0]Flush_Ex;

	logic Stall_Issue_Branch_Pipeline;
	logic Stall_Issue_Memory_Pipeline;

	logic Forwarding_Mode_rs1_Branch_Pipeline;
	logic Forwarding_Mode_rs1_Memory_Pipeline;

	logic Forwarding_Mode_rs2_Branch_Pipeline;
	logic Forwarding_Mode_rs2_Memory_Pipeline;

	//BP SIGNALS
	logic [1:0]BP_en_Fetch;
	logic BP_en_Dec;
	logic BP_en_Issue;
	logic BP_en_Ex;

	logic BP_Decision_Fetch;
	logic BP_Decision_Dec;
	logic BP_Decision_Issue;
	logic BP_Decision_Ex;

	logic [WIDTH-1:0]BP_imm;

	logic Branch_Predictor_Feedback;

	logic [WIDTH-1:0]BP_Address;
	logic Branch_en_Ex;
	logic Branch_En;

	logic ALU_Branch_Decision_Ex;
	logic ALU_Branch_Decision_Mem;

	logic Loop_Detector_en;
	logic Loop_Decision;

	logic Branch_Correction



	Kogge_Stone PC_Incrementor(
		.in0(PC_out_Fetch),
		.in1(32'd4),
		.sub_en(1'b0),
		.out(Normal_Addr_Fetch)
	);

	MUX_PC MUX_PC(
		.jump(Jump_Addr_Ex),
		.branch(BP_Address),//branch_MEM
		.normal_F(Normal_Addr_Fetch),
		.normal_EX(Normal_Addr_Ex),
		
		.branch_correction(Branch_Correction),

		.program_counter_controller(PC_MUX_Controller),
		.branch_en_F(BP_Decision_Fetch),
		.branch_en_EX(Branch_en_Ex),
		
		.out(PC_in)
	);

	PC PC(
		.clk(clk),
		.rst(rst),
		
		.stall_F(stall_Fetch),
		
		.PC_in(PC_in),
		.PC_out(etch)
	);

	logic [WIDTH-1:0]InstructionMemory_out_Fetch[1:0];
	logic [WIDTH-1:0]InstructionMemory_out_Dec[1:0];


	//Her zaman Instruction 1 En son Instructiondir.
	Instruction_Memory Instruction_Memory(
        .Program_counter_IM(PC_out_Fetch),          
        .Instruction_IM(InstructionMemory_out_Fetch)     
    );

	Fetch_Decoder Fetch_Decoder(
		.inst(InstructionMemory_out_Fetch),
		.branch_en(BP_en_Fetch),
		.imm_out(BP_imm)
	);

	Kogge_Stone Branch_Address_Calculator(
		.in0(PC_out_Fetch),
		.in1(BP_imm),
		.sub_en(1'b0),
		.out(BP_Address)
	);

	Gshare_BP Gshare(
		.clk(clk),
		.rst(rst),

		.branch_en_F(BP_en_Fetch),
		.branch_en_EX(BP_en_Ex),

		.PC_F(PC_out_Fetch[13:0]),
		.PC_EX(PC_out_Ex[13:0]),

		.branch_result(Branch_Predictor_Feedback),
		.BP_decision(BP_Decision_Fetch)

	);

	LoopDetector LoopDetector(
		.clk(clk),
		.rst(rst),

		.PC_F(PC_out_Fetch),
		.PC_EX(PC_out_Ex),
		.PC_destination(BP_Address),

		.branch_en_F(BP_en_Fetch),
		.branch_en_EX(BP_en_Ex),

		.feedback_from_ALU(Branch_Predictor_Feedback),

		.loop_decision(Loop_Decision),
		.LD_en(Loop_Detector_en)
	);

	//-----------DECODE PIPELINE STAGE------------------//
	//--------------------------------------------------//

	//Decoder Signals
	logic [RS-1:0]OP_Code[1:0];
	logic [SUB_OPCODE-1:0]Sub_OP_Code[1:0];

	logic [WIDTH-1:0]Imm_Decoded[1:0];

	logic [RS-1:0]Shift_Size_Dec[1:0];
	logic [RS-1:0]Shift_Size_Issue[1:0];
	logic [RS-1:0]Shift_Size_Ex[1:0];

	logic [RS-1:0]rs1_Dec[1:0];
	logic [RS-1:0]rs2_Dec[1:0];
	logic [RS-1:0]rd_Dec[1:0];

	logic [RS-1:0]rs1_Issue[1:0];
	logic [RS-1:0]rs2_Issue[1:0];
	logic [RS-1:0]rd_Issue[1:0];

	logic [RS-1:0]rs1_Ex[1:0];
	logic [RS-1:0]rs2_Ex[1:0];

	logic [RS-1:0]rd_Ex[1:0];
	logic [RS-1:0]rd_Mem[1:0];
	logic [RS-1:0]rd_WB[1:0];

	Decoder Decoder(
		.inst(InstructionMemory_out_Dec),
        
        .op_code(OP_Code),
        .sub_op_code(Sub_OP_Code),
        
        .rs1(rs1_Dec), 
        .rs2(rs2_Dec),
        .rd(rd_Dec),
        
        .imm(Imm_Decoded),
        .shift_size(Shift_Size_Dec)
    );


	//Control Signals
	logic Imm_en;

	logic [1:0]RF_Write_en_Dec;
	logic [1:0]RF_Write_en_Issue;
	logic [1:0]RF_Write_en_Ex;
	logic [1:0]RF_Write_en_Mem;
	logic [1:0]RF_Write_en_Wb;

	logic [1:0]Mem_Read_en_Dec;
	logic [1:0]Mem_Read_en_Issue;
	logic [1:0]Mem_Read_en_Ex;
	logic [1:0]Mem_Read_en_Mem;

	logic [1:0]Mem_Write_en_Dec;
	logic [1:0]Mem_Write_en_Issue;
	logic [1:0]Mem_Write_en_Ex;
	logic [1:0]Mem_Write_en_Mem;

	logic [1:0]Sign_Extender_en_Dec;
	logic [1:0]Sign_Extender_en_Issue;
	logic [1:0]Sign_Extender_en_Ex;

	logic [1:0]Sign_Extender_Type;

	logic [ALU_OP-1:0]ALU_OP_Dec[1:0];
	logic [ALU_OP-1:0]ALU_OP_Issue[1:0];
	logic [ALU_OP-1:0]ALU_OP_Ex[1:0];

	logic [1:0]JAL_en_De;
	logic [1:0]JAL_en_Issue;
	logic [1:0]JAL_en_Ex;
	
	logic [1:0]JALR_en_De;
	logic [1:0]JALR_en_Issue;
	logic [1:0]JALR_en_Ex;

	logic [LOAD_TYPE-1:0]Load_Type_Dec[1:0];
	logic [LOAD_TYPE-1:0]Load_Type_Issue[1:0];
	logic [LOAD_TYPE-1:0]Load_Type_Ex[1:0];
	logic [LOAD_TYPE-1:0]Load_Type_Mem[1:0];

	logic[1:0]Store_Type[1:0];
	logic Branch_en_Dec[1:0];
	logic Branch_en_Issue[1:0];
	logic Branch_en_Ex[1:0];

	Control_Unit Control_Unit(
        .op_code(OP_Code),
        .sub_op_code(Sub_OP_Code),
		
		.load_type(Load_Type_Dec),
		.store_type(Store_Type),
		
		.JAL_en(JAL_en_Dec),
		.JALR_en(JALR_en_Dec),
        .imm_en(Imm_en),
        .rf_write_en(RF_Write_en_Dec),
        .mem_read_en(Mem_Read_en_Dec),
        .mem_write_en(Mem_Write_en_Dec),
        .branch_mode(Branch_en_Dec),
        .sign_extender_en(Sign_Extender_en_Dec),
        .sign_extender_type(Sign_Extender_Type),
        .alu_op(ALU_OP_Dec)
    );

	logic [1:0]Store_en;
    assign Store_en[0] = {||Store_Type[0][1:0]};
    assign Store_en[1] = {||Store_Type[1][1:0]};

    logic [1:0]Load_en;
    assign Load_en[0] = {||Load_Type_Issue[0][2:0]};
    assign Load_en[1] = {||Load_Type_Issue[1][2:0]}; 

	logic [WIDTH-1:0]Imm_Sign_Extended_Dec[1:0];
	logic [WIDTH-1:0]Imm_Sign_Extended_Issue[1:0];
	logic [WIDTH-1:0]Imm_Sign_Extended_Ex[1:0];

	Sign_Extender Sign_Extender(
		.in(Imm_Decoded),
		.sign_extender_en(Sign_Extender_en_Dec),
		.sign_extender_type(Sign_Extender_Type),
		.out(Imm_Sign_Extended_Dec)
	);

	//-----------ISSUE PIPELINE STAGE------------------//
	//-------------------------------------------------//
	

	logic [WIDTH-1:0]rd1[1:0];
	logic [WIDTH-1:0]rd1_Dec[1:0];
	logic [WIDTH-1:0]rd1_Issue[1:0];
	logic [WIDTH-1:0]rd1_Ex[1:0];

	logic [WIDTH-1:0]rd2[1:0];
	logic [WIDTH-1:0]rd2_Dec[1:0];
	logic [WIDTH-1:0]rd2_Issue[1:0];
	logic [WIDTH-1:0]rd2_Ex[1:0];
	logic [WIDTH-1:0]rd2_Mem[1:0];

	Logic [WIDTH-1:0]wd_Mem[1:0];
	logic [WIDTH-1:0]wd_WB[1:0];

	

	RF RF(
        .rs1(rs1_Issue),
        .rs2(rs2_Issue),
        .rd(rd_WB),
        .wd(wd_WB),
		
        .clk(clk),
        .rst(rst),
		
        .write_en(RF_Write_en_Wb),
        .rd1(rd1),
        .rd2(rd2)
    );

	logic [WIDTH-1:0]ALU_in_1_Branch_Issue;
	logic [WIDTH-1:0]ALU_in_1_Branch_Ex;

	logic [WIDTH-1:0]ALU_in_2_Branch_Issue;
	logic [WIDTH-1:0]ALU_in_2_Branch_Ex;

	logic [WIDTH-1:0]ALU_Branch_Shift_Size_Issue;
	logic [WIDTH-1:0]ALU_Branch_Shift_Size_Ex;

	logic [ALU_OP-1:0]ALU_Branch_Op_Issue;
	logic [ALU_OP-1:0]ALU_Branch_Op_Ex;


	logic [WIDTH-1:0]ALU_in_1_Memory_Issue;
	logic [WIDTH-1:0]ALU_in_1_Memory_Ex;

	logic [WIDTH-1:0]ALU_in_2_Memory_Issue;
	logic [WIDTH-1:0]ALU_in_2_Memory_Ex;

	logic [WIDTH-1:0]ALU_Memory_Shift_Size_Issue;
	logic [WIDTH-1:0]ALU_Memory_Shift_Size_Ex;

	logic [ALU_OP-1:0]ALU_Memory_Op_Issue;
	logic [ALU_OP-1:0]ALU_Memory_Op_Ex;

	 Issue_Unit Issue_Unit(
        .rs1(rs1_Issue),
        .rs2(rs2_Issue),
        .RF_Write_en_Issue(RF_Write_en_Issue),
        .Mem_Read_en_Issue(Mem_Read_en_Issue),
        .Mem_Write_en_Issue(Mem_Write_en_Issue),
        .Sign_Extender_en_Issue(Sign_Extender_en_Issue),
        .ALU_OP_Issue(ALU_OP_Issue),
        .JAL_en_Issue(JAL_en_Issue),
        .JALR_en_Issue(JALR_en_Issue),
        .Load_Type_Issue(Load_Type_Issue),
        .Store_Type_Issue(Store_Type_Issue),
        .Shift_Size(Shift_Size_Issue),
        .Imm(Imm_Sign_Extended_Issue),
        .rd(rd_Issue),
        .PC(PC_out_Issue),

        // .Forwarding_Mode_rs1_Branch_Pipeline(Forwarding_Mode_rs1_Branch_Pipeline),
        // .Forwarding_Mode_rs2_Branch_Pipeline(Forwarding_Mode_rs2_Branch_Pipeline),
        // .Forwarding_Mode_rs1_Memory_Pipeline(Forwarding_Mode_rs1_Memory_Pipeline),
        // .Forwarding_Mode_rs2_Memory_Pipeline(Forwarding_Mode_rs2_Memory_Pipeline),

        .Branch_en(Branch_en_Issue),

        // .Forwarding_From_Branch_Ex(Forwarding_From_Branch_Ex),
        // .Forwarding_From_Memory_Ex(Forwarding_From_Memory_Ex),
        // .Forwarding_From_Branch_Mem(Forwarding_From_Branch_Mem),
        // .Forwarding_From_Memory_Mem(Forwarding_From_Memory_Mem),
        // .Forwarding_From_Branch_WB(Forwarding_From_Branch_WB),
        // .Forwarding_From_Memory_WB(Forwarding_From_Memory_WB),

        .Branch_Pipeline_rs1_out(Branch_Pipeline_rs1),
        .Branch_Pipeline_rs2_out(Branch_Pipeline_rs2),
        .Branch_Pipeline_rd_out(Branch_Pipeline_rd),
        .Branch_Pipeline_PC_out(Branch_Pipeline_PC),
        .Branch_Pipeline_imm_out(Branch_Pipeline_imm),
        .Branch_Pipeline_shift_size_out(Branch_Pipeline_shift_size),
        .Branch_Pipeline_ALU_OP_out(Branch_Pipeline_ALU_OP),

        .Memory_Pipeline_rs1_out(Memory_Pipeline_rs1),
        .Memory_Pipeline_rs2_out(Memory_Pipeline_rs2),
        .Memory_Pipeline_rd_out(Memory_Pipeline_rd),
        .Memory_Pipeline_PC_out(Memory_Pipeline_PC),
        .Memory_Pipeline_imm_out(Memory_Pipeline_imm),
        .Memory_Pipeline_shift_size_out(Memory_Pipeline_shift_size),
        .Memory_Pipeline_ALU_OP_out(Memory_Pipeline_ALU_OP),
        .Memory_Pipeline_Mem_Read_en_out(Memory_Pipeline_Mem_Read_en),
        .Memory_Pipeline_Mem_Write_en_out(Memory_Pipeline_Mem_Write_en)
    );
	

	Forwarding_MUX Forwarding_MUX_Branch_rd1(
		.Control_Signal(Forwarding_Mode_rs1_Branch_Pipeline),
		.Normal_Data(Branch_Pipeline_rs1),

		.Forwarding_From_Branch_Ex(ALU_in_1_Branch_Ex),
		.Forwarding_From_Memory_Ex(ALU_in_1_Memory_Ex),

		.Forwarding_From_Branch_Mem(ALU_in_1_Branch_Mem),
		.Forwarding_From_Memory_Mem(ALU_in_1_Memory_Mem),

		.Forwarding_From_Branch_WB(ALU_in_1_Branch_Wb),
		.Forwarding_From_Memory_WB(ALU_in_1_Memory_Wb)
	);

	Forwarding_MUX Forwarding_MUX_Branch_rd2(
		.Control_Signal(Forwarding_Mode_rs2_Branch_Pipeline),
		.Normal_Data(Branch_Pipeline_rs2),

		.Forwarding_From_Branch_Ex(ALU_in_2_Branch_Ex),
		.Forwarding_From_Memory_Ex(ALU_in_2_Memory_Ex),

		.Forwarding_From_Branch_Mem(ALU_in_2_Branch_Mem),
		.Forwarding_From_Memory_Mem(ALU_in_2_Memory_Mem),

		.Forwarding_From_Branch_WB(ALU_in_2_Branch_Wb),
		.Forwarding_From_Memory_WB(ALU_in_2_Memory_Wb)
	);

	Forwarding_MUX Forwarding_MUX_Memory_rd1(
		.Control_Signal(Forwarding_Mode_rs1_Memory_Pipeline),
		.Normal_Data(Memory_Pipeline_rs1),

		.Forwarding_From_Branch_Ex(ALU_in_1_Branch_Ex),
		.Forwarding_From_Memory_Ex(ALU_in_1_Memory_Ex),

		.Forwarding_From_Branch_Mem(ALU_in_1_Branch_Mem),
		.Forwarding_From_Memory_Mem(ALU_in_1_Memory_Mem),

		.Forwarding_From_Branch_WB(ALU_in_1_Branch_Wb),
		.Forwarding_From_Memory_WB(ALU_in_1_Memory_Wb)
	);

	Forwarding_MUX Forwarding_MUX_Memory_rd2(
		.Control_Signal(Forwarding_Mode_rs2_Memory_Pipeline),
		.Normal_Data(Memory_Pipeline_rs2),

		.Forwarding_From_Branch_Ex(ALU_in_2_Branch_Ex),
		.Forwarding_From_Memory_Ex(ALU_in_2_Memory_Ex),

		.Forwarding_From_Branch_Mem(ALU_in_2_Branch_Mem),
		.Forwarding_From_Memory_Mem(ALU_in_2_Memory_Mem),

		.Forwarding_From_Branch_WB(ALU_in_2_Branch_Wb),
		.Forwarding_From_Memory_WB(ALU_in_2_Branch_Wb)
	);

	//-----------EXECUTE PIPELINE STAGE------------------//
	//---------------------------------------------------//

	logic [WIDTH-1:0]ALU_Branch_Result_Ex;
	logic [WIDTH-1:0]ALU_Branch_Result_Mem;
	logic [WIDTH-1:0]ALU_Branch_Result_Wb;

	logic [WIDTH-1:0]ALU_Memory_Result_Ex;
	logic [WIDTH-1:0]ALU_Memory_Result_Mem;
	logic [WIDTH-1:0]ALU_Memory_Result_Wb;

	ALU ALU_Branch(
        .rs1(ALU_in_1_Branch_Ex),
        .rs2(ALU_in_2_Branch_Ex),
		.shifter_size(ALU_Branch_Shift_Size_Ex),
        .op(ALU_Branch_Op_Ex),
		
        .result(ALU_Branch_Result_Ex),
        .branch_control(Branch_Predictor_Feedback)
    );

	ALU ALU_Memory(
        .rs1(ALU_in_1_Memory_Ex),
        .rs2(ALU_in_2_Memory_Ex),
		.shifter_size(ALU_Memory_Shift_Size_Ex),
        .op(ALU_Memory_Op_Ex),
		
        .result(ALU_Memory_Result_Ex),
    );

	//-----------MEMORY PIPELINE STAGE------------------//
	//--------------------------------------------------//

	logic [WIDTH-1:0]Memory_Out_Mem;
	logic [WIDTH-1:0]Memory_Out;

	Memory Memory_(
		.clk(clk),
		.rst(rst),

		.mem_read_en(Mem_Read_en_Mem),
		.mem_write_en(Mem_Write_en_Mem),
		
		.address(ALU_Memory_Result_Mem),
		.write_data(rd2_Mem),
		.read_data(Memory_Out)
	);	


	//-----------WRITEBACK PIPELINE STAGE------------------//
	//-----------------------------------------------------//

	 

	Hazard_Unit hazard_unit_inst (
        .rs1_Dec_Branch_Pipeline(rs1_Dec[0]),
        .rs1_Dec_Memory_Pipeline(rs1_Dec[1]),
        .rs1_Issue_Branch_Pipeline(),
        .rs1_Issue_Memory_Pipeline(),
        .rs1_Ex_Branch_Pipeline(rs1_Ex[0]),
        .rs1_Ex_Memory_Pipeline(rs1_Ex[1]),

        .rs2_Dec_Branch_Pipeline(rs2_Dec[0]),
        .rs2_Dec_Memory_Pipeline(rs2_Dec[1]),
        .rs2_Issue_Branch_Pipeline(),
        .rs2_Issue_Memory_Pipeline(),
        .rs2_Ex_Branch_Pipeline(rs2_Ex[0]),
        .rs2_Ex_Memory_Pipeline(rs2_Ex[1]),

        .rd_Issue_Branch_Pipeline(),
        .rd_Issue_Memory_Pipeline(),
        .rd_Ex_Branch_Pipeline(rd_Ex[0]),
        .rd_Ex_Memory_Pipeline(rd_Ex[1]),
        .rd_Mem_Branch_Pipeline(rd_mem[0]),
        .rd_Mem_Memory_Pipeline(rd_Mem[1]),
        .rd_Wb_Branch_Pipeline(rd_WB[0]),
        .rd_Wb_Memory_Pipeline(rd_WB[1]),

        .program_counter_controller_EX(PC_MUX_Controller),
        .Mem_read_en_Ex(Mem_Read_en_Ex),
        .Branch_en(Branch_en_Issue),
        .Load_Type_Issue(Load_Type_Issue),
        .Store_Type_Issue(Store_Type_Issue),
        .RF_Write_en_Ex(RF_Write_en_Ex),
        .RF_Write_en_Mem(RF_Write_en_Mem),
        .RF_Write_en_WB(RF_Write_en_Wb),
        .branch_control(),
        .branch_decision(),
        .Forwarding_Mode_rs1_Branch_Pipeline(Forwarding_Mode_rs1_Branch_Pipeline),
        .Forwarding_Mode_rs2_Branch_Pipeline(Forwarding_Mode_rs2_Branch_Pipeline),
        .Forwarding_Mode_rs1_Memory_Pipeline(Forwarding_Mode_rs1_Memory_Pipeline),
        .Forwarding_Mode_rs2_Memory_Pipeline(Forwarding_Mode_rs2_Memory_Pipeline),
        .Branch_Correction(Branch_Correction),
        .Stall_Fetch(Stall_Fetch),
        .Stall_Dec(Stall_Dec),
        .Stall_Issue_Branch_Pipeline(Stall_Issue_Branch_Pipeline),
        .Stall_Issue_Memory_Pipeline(Stall_Issue_Memory_Pipeline),
        .Flush_Ex(Flush_Ex),
        .Flush_Dec(Flush_Dec)
    );

endmodule



