`include "Header_File.svh"
module Instruction_Memory #(
parameter InstLength = 256,
parameter IMemInitFile = "imem.mem" 
    )(
    input  logic [WIDTH-1:0]Program_counter_IM_Pipeline_0,
    input  logic [WIDTH-1:0]Program_counter_IM_Pipeline_1,

    output  logic [WIDTH-1:0]Instruction_IM_Pipeline_0,
    output  logic [WIDTH-1:0]Instruction_IM_Pipeline_1
    //TRAP HANDLING
	/*
    output reg exception_flag_IM,
    output reg [31:0] exception_cause_IM,
    output reg [31:0] exception_value_IM
	
	*/
    );
    
    logic [WIDTH-1:0]Program_counter_IM[1:0];
    assign Program_counter_IM[0] = Program_counter_IM_Pipeline_0;
    assign Program_counter_IM[1] = Program_counter_IM_Pipeline_1;

    logic [WIDTH-1:0]Instruction_IM[1:0];

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

    assign Instruction_IM_Pipeline_0 = Instruction_IM[0];
    assign Instruction_IM_Pipeline_1 = Instruction_IM[1];
	
	
endmodule


