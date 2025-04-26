`include "Header_File.svh"
module RF
	// #(
	// parameter RS = 5,
	// parameter RD = 32
	
	// )
	(
	input logic clk,
	input logic rst,

	input logic [RS-1:0]rs1[1:0],
	input logic [RS-1:0]rs2[1:0],
	input logic [RS-1:0]rd[1:0],
	input logic [WIDTH-1:0]wd[1:0],
	
	input logic write_en[1:0],
	
	output logic [WIDTH-1:0]rd1[1:0],
	output logic [WIDTH-1:0]rd2[1:0]
	
	);	

	logic [31:0]reg_data[31:0];// first[31:0] refeer to  register
	logic [31:0]temp_reg_data[31:0];// first[31:0] refeer to  register
	
	assign rd1[0] = reg_data[rs1][0];
	assign rd1[1] = reg_data[rs1][1];

	assign rd2[0] = reg_data[rs2][0];
	assign rd2[1] = reg_data[rs2][1];
	
	
	always_ff @(negedge clk , negedge rst) 
	begin
		
		reg_data[0] <= 1'b0;
		
		if(!rst)
		begin
		    integer i;
			for(i=0 ; i<32 ; i=i+1)
			   begin
				   reg_data[i] <= 32'd0;
			   end
		end	
		
		else
		begin
			if(write_en)
			begin
				if(rd == 5'd0)
				begin
					reg_data[0] <= 32'd0;
				end
				else
				begin
					reg_data[rd[0]] <= wd[0];
					reg_data[rd[1]] <= wd[1];
				end
			end    
			
			else  
			begin 
				temp_reg_data <= reg_data;
			end
		end
	end

endmodule