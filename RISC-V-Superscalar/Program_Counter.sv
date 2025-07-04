`include "Header_File.svh"
module PC(
	input logic	clk, 
	input logic rst,
	
	input logic stall_F,
	
	input logic [WIDTH-1:0]PC_in_Pipeline_0,
	input logic [WIDTH-1:0]PC_in_Pipeline_1,

	output logic [WIDTH-1:0]PC_out_Pipeline_0,
	output logic [WIDTH-1:0]PC_out_Pipeline_1
);

	logic [WIDTH-1:0]PC_in[1:0];
	assign PC_in[0] = PC_in_Pipeline_0;
	assign PC_in[1] = PC_in_Pipeline_1;

	logic [WIDTH-1:0]PC_out[1:0]

	always_ff @(posedge clk or negedge rst)
	begin
		
		if(!rst)
		begin
			PC_out[0] <= '{default: 32'd0};
			PC_out[1] <= 32'd4;
		end
		
		else
			// if(stall_F)
			// 	begin
			// 		PC_out <= PC_out;
			// 	end
			// else
			// 	begin
					PC_out <= PC_in;
				// end
	end

	assign PC_out_Pipeline_0 = PC_out[0];
	assign PC_out_Pipeline_1 = PC_out[1];
endmodule