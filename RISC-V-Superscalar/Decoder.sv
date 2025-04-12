module Decoder#(
	parameter FUNC = 3,
	parameter RS = 5,
	parameter RD = 5
	
	)(
	input logic  [31:0]inst[1:0],
	
	output logic [4:0]op_code[1:0],
	output logic [3:0]sub_op_code[1:0],
	
	output logic [RS-1:0]rs1[1:0], 
	output logic [RS-1:0]rs2[1:0],
	output logic [RD-1:0]rd[1:0],
	
	output logic [31:0]imm[1:0],
	output logic [4:0]shift_size[1:0]
	);
	
	integer i;

	always_comb
	begin
		for(i=0; i<2; i=i+1)
		begin
			case(inst[6:2][i])
				5'b01101: //lui 
				begin
						op_code[i]		    = 	inst[6:2][i];
						sub_op_code[i]		= 	{inst[30][i] , inst[14:12][i]};
						shift_size[i]	    =	5'd0;					
						imm[i] 				= 	{inst[31:12][i] , 12'd0};
						rs1[i]				=	5'd0;
						rs2[i]				=	5'd0;
						rd[i] 				= 	{inst[11:7][i]};
				end
			
				5'b00101: //auipc
				begin
						op_code[i]		    = 	inst[6:2][i];
						sub_op_code[i] 		= 	{inst[30][i] , inst[14:12][i]};
						shift_size[i]	    =	5'd0;					
						imm[i] 				= 	{inst[31:12][i] , 12'd0};
						rs1[i]				=	5'd0;
						rs2[i]				=	5'd0;
						rd[i]				= 	{inst[11:7][i]};
				end
				
				5'b00100: // I Type
				begin
						op_code[i]		    = 	inst[6:2][i];
						sub_op_code[i] 		= 	{inst[30][i] , inst[14:12][i]};
						shift_size[i]	    =	inst[24:20][i];
						imm[i]				=	{20'd0 , inst[31:20][i]};
						rs1[i]				=	inst[19:15][i];
						rs2[i]				=	5'd0;
						rd[i]				=	inst[11:7][i];	
						
				end
				
				5'b01100: //R Type
				begin
						op_code[i]		    = 	inst[6:2][i];
						sub_op_code[i] 		= 	{inst[30][i] , inst[14:12][i]};
						shift_size[i]	    =	inst[24:20][i];
						imm[i]				=	32'd0;
						rs1[i]				=	inst[19:15][i]; 
						rs2[i]				=	inst[24:20][i];
						rd[i]				=	inst[11:7][i];
				end
				
				5'b00000: // Load Type
				begin
						op_code[i]		    = 	inst[6:2][i];
						sub_op_code[i] 		= 	{inst[30][i] , inst[14:12][i]};
						shift_size[i]	    =	5'd0;
						imm[i]				=	{20'd0 , inst[31:20][i]};
						rs1[i]				=	inst[19:15][i]; 
						rs2[i]				=	5'd0;
						rd[i]				=	inst[11:7][i];
				end
				
				5'b01000: // Store Type
				begin
						op_code[i]		    = 	inst[6:2][i];
						sub_op_code[i] 		= 	{inst[30][i] , inst[14:12][i]};
						shift_size[i]	    =	5'd0;
						imm[i]				=	{{20{inst[31][i]}} , inst[31:25][i] , inst[11:7][i]};
						rs1[i]				=	inst[19:15][i];
						rs2[i]				=	inst[24:20][i];
						rd[i]				=	5'd0;
				end			

				5'b11011: // Jump and Link
				begin
						op_code[i]		    = 	inst[6:2][i];
						sub_op_code[i] 		= 	4'b1111;
						shift_size[i]	    =	inst[24:20][i];
						imm[i]				=	{{13{inst[31][i]}} , inst[19:12][i] , inst[20][i] , inst[30:21][i] , 1'b0};
						rs1[i]				=	5'd0;
						rs2[i]				=	5'd0;
						rd[i]				=	inst[11:7][i];
				end			
		
				5'b11001: // Jump and Link Register
				begin
						op_code[i]		    = 	inst[6:2][i];
						sub_op_code[i]		= 	4'd0;
						shift_size[i]	    =	5'd0;
						imm[i]				=	{{20{inst[31][i]}} , inst[31:20][i]};
						rs1[i]				=	inst[19:15][i];
						rs2[i]				=	5'd0;
						rd[i]				=	inst[11:7][i];
				end	

				5'b11000: // Branch Type
				begin
						op_code[i]		    = 	inst[6:2][i];
						sub_op_code[i] 		= 	{inst[30][i] , inst[14:12][i]};
						shift_size[i]	    =	5'd0;
						imm[i]				=	{19'd0 , inst[31][i] , inst[7][i] , inst[30:25][i] , inst[11:8][i] , 1'b0};
						rs1[i]				=	inst[19:15][i];
						rs2[i]				=	inst[24:20][i];
						rd[i]				=	5'd0;
				end
				
				default:
				begin
						op_code[i]		    = 	5'd0;
						sub_op_code[i] 		= 	4'd0;
						shift_size[i]	    =	5'd0;
						imm[i]				=	32'd0;
						rs1[i]				=	5'd0;
						rs2[i]				=	5'd0;
						rd[i]				=	5'd0;			
				end
		
			endcase
		end	
		end
		
endmodule	