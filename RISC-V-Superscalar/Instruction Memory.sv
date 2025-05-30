`include "Header_File.svh"
module Instruction_Memory #(
parameter InstLength = 256,
parameter IMemInitFile = "imem.mem" 
    )(
    input  logic [WIDTH-1:0]Program_counter_IM[1:0],
    output  logic [WIDTH-1:0]Instruction_IM[1:0]
    //TRAP HANDLING
	/*
    output reg exception_flag_IM,
    output reg [31:0] exception_cause_IM,
    output reg [31:0] exception_value_IM
	
	*/
    );
   
    logic [31:0]Instraction_Memory[InstLength-1:0];
    initial begin
    $readmemh("imem.mem", Instraction_Memory);
    end
    
	logic [WIDTH-1:0]Address_0;
	logic [WIDTH-1:0]Address_1;
	assign Address_0 = {2'b00, Program_counter_IM[0][31:2]};
    assign Address_1 = {2'b00, Program_counter_IM[1][31:2]};


	
	assign Instruction_IM[0] = Instraction_Memory[Address_0];
	assign Instruction_IM[1] = Instraction_Memory[Address_1];
	
	
endmodule


