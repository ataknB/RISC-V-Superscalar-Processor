`include "Header_File.svh"
module MUX_PC 
	// #(
	// parameter WIDTH = 32
	// )
	(
	input logic [WIDTH-1:0]jump, 
	input logic [WIDTH-1:0]branch, 
	input logic [WIDTH-1:0]normal_F,
	input logic [WIDTH-1:0]normal_EX,
	
	input logic branch_correction,

	//input logic branch_en,
	input logic branch_en_F,
	input logic branch_en_EX,

	input logic [1:0]program_counter_controller,
	
	output logic [WIDTH-1:0]out	
);	
	always_comb
	begin
		if(branch_en_EX)
		begin
			if(branch_correction)
			begin
				out = normal_EX;
			end
			else
			begin
				out = branch;
			end
			
		end

		else if(branch_en_F)
		begin
				out = branch;
		end

		else
		begin
			case({program_counter_controller , branch_en_F})
				3'b010: 	begin  out = normal_F; 	end //normal
				3'b100: 	begin  out = jump; 		end //jump
				default: 	begin  out = normal_F ; 	end //begin  out = 32'd4; 	end
			endcase
		end
	end
endmodule
