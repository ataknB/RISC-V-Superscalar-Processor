module Forwarding_MUX (
	input logic [WIDTH-1:0]Normal,
	input logic [WIDTH-1:0]Branch_Execute,
	input logic [WIDTH-1:0]Memory_Execute,

	input logic [WIDTH-1:0]Branch_Memory,
	input logic [WIDTH-1:0]Memory_Memory,

	input logic [WIDTH-1:0]Branch_WB,
	input logic [WIDTH-1:0]Memory_WB,

	input logic [2:0]Forwarding_Mode,

	output logic [WIDTH-1:0]out
	);

	always_comb
	begin
		case(Forwarding_Mode)
			3'b000: out = Normal; // Normal case
			3'b001: out = Branch_Execute; // From Branch Execute Stage
			3'b010: out = Memory_Execute; // From Memory Execute Stage
			3'b011: out = Branch_Memory; // From Branch Memory Stage
			3'b100: out = Memory_Memory; // From Memory Memory Stage
			3'b101: out = Branch_WB; // From Branch WB Stage
			3'b110: out = Memory_WB; // From Memory WB Stage
			default: out = 32'd0; // Default case (should not happen)
		endcase
	end


endmodule