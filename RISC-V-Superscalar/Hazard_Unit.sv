`include "Header_File.svh"
module Hazard_Unit(
	input logic 	[4:0]rs1_Dec_Branch_Pipeline,
	input logic 	[4:0]rs1_Dec_Memory_Pipeline,

	input logic 	[4:0]rs1_Issue_Branch_Pipeline,
	input logic 	[4:0]rs1_Issue_Memory_Pipeline,

	input logic 	[4:0]rs1_Ex_Branch_Pipeline,
	input logic 	[4:0]rs1_Ex_Memory_Pipeline,
	
	input logic 	[4:0]rs2_Dec_Branch_Pipeline,
	input logic 	[4:0]rs2_Dec_Memory_Pipeline,

	input logic 	[4:0]rs2_Issue_Branch_Pipeline,
	input logic 	[4:0]rs2_Issue_Memory_Pipeline,

	input logic 	[4:0]rs2_Ex_Branch_Pipeline,
	input logic 	[4:0]rs2_Ex_Memory_Pipeline,
	
	input logic 	[4:0]rd_Issue_Branch_Pipeline,
	input logic 	[4:0]rd_Issue_Memory_Pipeline,

	input logic 	[4:0]rd_Ex_Branch_Pipeline,
	input logic 	[4:0]rd_Ex_Memory_Pipeline,

	input logic 	[4:0]rd_Mem_Branch_Pipeline,
	input logic 	[4:0]rd_Mem_Memory_Pipeline,

	input logic 	[4:0]rd_Wb_Branch_Pipeline,
	input logic 	[4:0]rd_Wb_Memory_Pipeline,
//--------------------------------------------------------
	input logic 	[1:0]program_counter_controller_EX,
	input logic 	[1:0]Mem_read_en_Ex,
	
    input logic     [1:0]Branch_en,
	input logic     [2:0]Load_Type_Issue[1:0],
    input logic     [1:0]Store_Type_Issue[1:0],

	input logic 	[1:0]Branch_Pipeline_RF_Write_en_Ex,
	input logic 	[1:0]Memory_Pipeline_RF_Write_en_Ex,

	input logic 	[1:0]Branch_Pipeline_RF_Write_en_Mem,
	input logic 	[1:0]Memory_Pipeline_RF_Write_en_Mem,

	input logic 	[1:0]Branch_Pipeline_RF_Write_en_WB,
	input logic 	[1:0]Memory_Pipeline_RF_Write_en_WB,
	
	input logic 	[1:0]branch_control,
	input logic 	[1:0]branch_decision,
	
	output logic 	[2:0]Forwarding_Mode_rs1_Branch_Pipeline,
	output logic 	[2:0]Forwarding_Mode_rs2_Branch_Pipeline,

	output logic 	[2:0]Forwarding_Mode_rs1_Memory_Pipeline,
	output logic 	[2:0]Forwarding_Mode_rs2_Memory_Pipeline,

	/*
		000 : normal input
		001 : from Branch Execute Stage
		010 : from Memory Execute Stage
		
		011 : from Branch Memory Stage
		100 : from Memory Memory Stage
		
		101 : from Branch WB Stage
		110 : from Memory WB Stage
	*/

	output logic Branch_Correction,

	output logic Stall_Fetch,
	output logic Stall_Dec,
	output logic Stall_Issue_Branch_Pipeline,
	output logic Stall_Issue_Memory_Pipeline,
	
	output logic Flush_Ex,
	output logic Flush_Dec
);
	
	logic   [1:0]Store_en;
    assign  Store_en[0] = {Store_Type_Issue[0][0] ||Store_Type_Issue[0][1] };
    assign  Store_en[1] = {Store_Type_Issue[1][1] || Store_Type_Issue[1][0]};

    logic   [1:0]Load_en;
    assign 	Load_en[0] = |Load_Type_Issue[0][2:0];
    assign  Load_en[1] = |Load_Type_Issue[1][2:0];

    logic   [1:0]temp_mem;
    assign  temp_mem[0] = Store_en[0] || Load_en[0]; 
    assign  temp_mem[1] = Store_en[1] || Load_en[1]; 

	always_comb
	begin
		//Aynı anda iki tane load, store  veya branch varsa stall yap
		if((|Store_en[1:0] && |Load_en[1:0]) || (&Store_en[1:0]) || (&Load_en[1:0]) || &Branch_en[1:0])
		begin
			Stall_Issue_Branch_Pipeline = 1'd1; // Stall Issue Stage
			Stall_Issue_Memory_Pipeline = 1'd0;
			Stall_Fetch = 1'd1; //Memory  Stall Fetch Stage
			Stall_Dec = 1'd1; //Memory Stall Decode Stage
		end

		else if(rs1_Issue_Branch_Pipeline == rd_Issue_Memory_Pipeline || 
				rs1_Issue_Memory_Pipeline == rd_Issue_Branch_Pipeline || 
				rs2_Issue_Branch_Pipeline == rd_Issue_Memory_Pipeline || 
				rs2_Issue_Memory_Pipeline == rd_Issue_Branch_Pipeline)
		begin
			Stall_Issue_Memory_Pipeline = 1'd1; // Stall Issue Stage
			Stall_Issue_Branch_Pipeline = 1'd0;
			Stall_Fetch = 1'd1; // Stall Fetch Stage
			Stall_Dec = 1'd1; // Stall Decode Stage
		end

		else 
		begin
			//BRANCH PIPELINE FORWARDING
			if((rs1_Issue_Branch_Pipeline == rd_Mem_Branch_Pipeline) && Branch_Pipeline_RF_Write_en_Mem )
			begin
				Forwarding_Mode_rs1_Branch_Pipeline = 3'b011; // Branch Memory forwarding
			end
			else if((rs1_Issue_Branch_Pipeline == rd_Wb_Branch_Pipeline) && Branch_Pipeline_RF_Write_en_WB )
			begin
				Forwarding_Mode_rs1_Branch_Pipeline = 3'b101; // Branch Writeback forwarding
			end
			else if((rs1_Issue_Branch_Pipeline == rd_Ex_Branch_Pipeline) && Branch_Pipeline_RF_Write_en_Ex )
			begin
				Forwarding_Mode_rs1_Branch_Pipeline = 3'b001; // Branch Execute Stage forwarding
			end	
			//---------------------------------------------------------
			else if(rs1_Issue_Branch_Pipeline == rd_Mem_Memory_Pipeline && Branch_Pipeline_RF_Write_en_Mem )
			begin
				Forwarding_Mode_rs1_Branch_Pipeline = 3'b100; //Memory Memory Forwarding
			end

			else if(rs1_Issue_Branch_Pipeline == rd_Wb_Memory_Pipeline && Branch_Pipeline_RF_Write_en_WB )
			begin
				Forwarding_Mode_rs1_Branch_Pipeline = 3'b110; //Memory Writeback Forwarding
			end

			else if(rs1_Issue_Branch_Pipeline == rd_Ex_Memory_Pipeline && Branch_Pipeline_RF_Write_en_Ex )
			begin
				Forwarding_Mode_rs1_Branch_Pipeline = 3'b010; //Memory Execute Stage Forwarding
			end

			else 
			begin
				Forwarding_Mode_rs1_Branch_Pipeline = 3'b000; // Normal case
			end

			//---------------------------------------------------------

			if((rs2_Issue_Branch_Pipeline == rd_Mem_Branch_Pipeline) && Branch_Pipeline_RF_Write_en_Mem )
			begin
				Forwarding_Mode_rs2_Branch_Pipeline = 3'b011; // Branch Memory forwarding
			end
			else if((rs2_Issue_Branch_Pipeline == rd_Wb_Branch_Pipeline) && Branch_Pipeline_RF_Write_en_WB )
			begin
				Forwarding_Mode_rs2_Branch_Pipeline = 3'b101; // Branch Writeback forwarding
			end
			else if((rs2_Issue_Branch_Pipeline == rd_Ex_Branch_Pipeline) && Branch_Pipeline_RF_Write_en_Ex )
			begin
				Forwarding_Mode_rs2_Branch_Pipeline = 3'b001; // Branch Execute Stage forwarding
			end	
			//---------------------------------------------------------
			else if(rs2_Issue_Branch_Pipeline == rd_Mem_Memory_Pipeline && Branch_Pipeline_RF_Write_en_Mem )
			begin
				Forwarding_Mode_rs2_Branch_Pipeline = 3'b100; //Memory Memory Forwarding
			end

			else if(rs2_Issue_Branch_Pipeline == rd_Wb_Memory_Pipeline && Branch_Pipeline_RF_Write_en_WB )
			begin
				Forwarding_Mode_rs2_Branch_Pipeline = 3'b110; //Memory Writeback Forwarding
			end

			else if(rs2_Issue_Branch_Pipeline == rd_Ex_Memory_Pipeline && Branch_Pipeline_RF_Write_en_Ex )
			begin
				Forwarding_Mode_rs2_Branch_Pipeline = 3'b010; //Memory Execute Stage Forwarding
			end

			else 
			begin
				Forwarding_Mode_rs2_Branch_Pipeline = 3'b000; // Normal case
			end

			//MEMORY PIPELINE FORWARDING
			//---------------------------------------------------------
			if((rs1_Issue_Memory_Pipeline == rd_Mem_Branch_Pipeline) && Memory_Pipeline_RF_Write_en_Ex )
			begin
				Forwarding_Mode_rs1_Memory_Pipeline = 3'b011; // Branch Memory forwarding
			end
			else if((rs1_Issue_Memory_Pipeline == rd_Wb_Branch_Pipeline) && Memory_Pipeline_RF_Write_en_WB )
			begin
				Forwarding_Mode_rs1_Memory_Pipeline = 3'b101; // Branch Writeback forwarding
			end
			else if((rs1_Issue_Memory_Pipeline == rd_Ex_Branch_Pipeline) && Memory_Pipeline_RF_Write_en_Ex )
			begin
				Forwarding_Mode_rs1_Memory_Pipeline = 3'b001; // Branch Execute Stage forwarding
			end	
			else if(rs1_Issue_Memory_Pipeline == rd_Mem_Memory_Pipeline && Memory_Pipeline_RF_Write_en_Mem )
			begin
				Forwarding_Mode_rs1_Memory_Pipeline = 3'b100; //Memory Memory Forwarding
			end

			else if(rs1_Issue_Memory_Pipeline == rd_Wb_Memory_Pipeline && Memory_Pipeline_RF_Write_en_WB )
			begin
				Forwarding_Mode_rs1_Memory_Pipeline = 3'b110; //Memory Writeback Forwarding
			end

			else if(rs1_Issue_Memory_Pipeline == rd_Ex_Memory_Pipeline && Memory_Pipeline_RF_Write_en_Ex )
			begin
				Forwarding_Mode_rs1_Memory_Pipeline = 3'b010; //Memory Execute Stage Forwarding
			end

			else 
			begin
				Forwarding_Mode_rs1_Memory_Pipeline = 3'b000; // Normal case
			end

			//---------------------------------------------------------

			if((rs2_Issue_Memory_Pipeline == rd_Mem_Branch_Pipeline) && RF_Write_en_Mem )
			begin
				Forwarding_Mode_rs2_Memory_Pipeline = 3'b011; // Branch Memory forwarding
			end
			else if((rs2_Issue_Memory_Pipeline == rd_Wb_Branch_Pipeline) && RF_Write_en_WB )
			begin
				Forwarding_Mode_rs2_Memory_Pipeline = 3'b101; // Branch Writeback forwarding
			end
			else if((rs2_Issue_Memory_Pipeline == rd_Ex_Branch_Pipeline) && RF_Write_en_Ex )
			begin
				Forwarding_Mode_rs2_Memory_Pipeline = 3'b001; // Branch Execute Stage forwarding
			end	
			else if(rs2_Issue_Memory_Pipeline == rd_Mem_Memory_Pipeline && RF_Write_en_Mem )
			begin
				Forwarding_Mode_rs2_Memory_Pipeline = 3'b100; //Memory Memory Forwarding
			end

			else if(rs2_Issue_Memory_Pipeline == rd_Wb_Memory_Pipeline && RF_Write_en_Mem )
			begin
				Forwarding_Mode_rs2_Memory_Pipeline = 3'b110; //Memory Writeback Forwarding
			end

			else if(rs2_Issue_Memory_Pipeline == rd_Ex_Memory_Pipeline && RF_Write_en_Mem )
			begin
				Forwarding_Mode_rs2_Memory_Pipeline = 3'b010; //Memory Execute Stage Forwarding
			end

			else 
			begin
				Forwarding_Mode_rs2_Memory_Pipeline = 3'b000; // Normal case
			end
		end

		//Flush
		if(	(Load_en[0] || Load_en[1]) &&
		 	rs1_Issue_Branch_Pipeline == rd_Ex_Branch_Pipeline && rs1_Issue_Branch_Pipeline != 5'd0 ||
			rs2_Issue_Branch_Pipeline == rd_Ex_Branch_Pipeline && rs2_Issue_Branch_Pipeline != 5'd0 ||
			rs1_Issue_Memory_Pipeline == rd_Ex_Branch_Pipeline && rs1_Issue_Memory_Pipeline != 5'd0 ||
			rs2_Issue_Memory_Pipeline == rd_Ex_Branch_Pipeline && rs2_Issue_Memory_Pipeline != 5'd0)			
		begin
			Stall_Fetch = 1'd1; // Stall Fetch Stage
			Stall_Dec = 1'd1; // Stall Decode Stage
			Stall_Issue_Branch_Pipeline = 1'd1; // Stall Issue Stage
			Stall_Issue_Memory_Pipeline = 1'd1; // Stall Issue Stage
			Flush_Ex = 1'd1;

		end

		if(Load_en[0] && rs1_Issue_Branch_Pipeline == rd_Ex_Branch_Pipeline)
		begin
			
		end




		else 
		begin
			Stall_Fetch = 1'd0; // Stall Fetch Stage
			Stall_Dec = 1'd0; // Stall Decode Stage
			Stall_Issue_Branch_Pipeline = 1'd0; // Stall Issue Stage
			Stall_Issue_Memory_Pipeline = 1'd0; // Stall Issue Stage
			Flush_Ex = 1'd0;
		end	
		
		//Birbirlerine bağımlı komutlar varsa
		if(rs1_Issue_Branch_Pipeline == rd_Issue_Memory_Pipeline ||
			rs2_Issue_Branch_Pipeline == rd_Issue_Memory_Pipeline ||
			rs1_Issue_Memory_Pipeline == rd_Issue_Branch_Pipeline ||
			rs2_Issue_Memory_Pipeline == rd_Issue_Branch_Pipeline)
		begin
			Stall_Fetch = 1'd1; // Stall Fetch Stage
			Stall_Dec = 1'd1; // Stall Decode Stage
			Stall_Issue_Branch_Pipeline = 1'd0; // Stall Issue Stage
			Stall_Issue_Memory_Pipeline = 1'd1; // Stall Issue Stage
			Flush_Ex = 1'd0;

		end

		else 
		begin
			Stall_Fetch = 1'd0; // Stall Fetch Stage
			Stall_Dec = 1'd0; // Stall Decode Stage
			Stall_Issue_Branch_Pipeline = 1'd0; // Stall Issue Stage
			Stall_Issue_Memory_Pipeline = 1'd0; // Stall Issue Stage
			Flush_Ex = 1'd0;
		end
	end

	//Branch Correction
	//if()
	

endmodule