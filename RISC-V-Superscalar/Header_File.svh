//=========================================================
//  Project: RISC-V Superscalar Processor
//  File   : Header_File.svh
//  Author : [İsmini Yazabilirsin]
//  Note   : Global definitions, parameters, macros, types
//=========================================================

`ifndef HEADER_FILE_SVH
`define HEADER_FILE_SVH

//---------------------------------------------------------
// Global Parameters
//---------------------------------------------------------

parameter int WIDTH          = 32;  // Data width (ALU, Register File, Memory Bus)
parameter int RS             = 5;   // Source register address width
parameter int RD             = 5;   // Destination register address width
parameter int IMM            = 32;  // Immediate value width
parameter int SUB_OPCODE     = 4;   // ALU sub operation width
parameter int OPCODE     = 5;   // ALU sub operation width
parameter int LOAD_TYPE      = 3;   // Load type encoding width
parameter int ALU_OP         = 4;   // ALU operation encoding width
parameter int FORWARD_MODE   = 3;   // Forwarding control width

//---------------------------------------------------------
// Macro Definitions
//---------------------------------------------------------

// Useful macros
`define ZERO32 32'd0
`define ZERO5  5'd0
`define NOP_INSTRUCTION 32'h00000013 // ADDI x0, x0, 0

//---------------------------------------------------------
// Type Definitions
//---------------------------------------------------------

// Load instruction types
typedef enum logic [LOAD_TYPE-1:0] {
    LOAD_BYTE     = 3'b000,
    LOAD_HALF     = 3'b001,
    LOAD_WORD     = 3'b010,
    LOAD_BYTE_U   = 3'b100,
    LOAD_HALF_U   = 3'b101
} load_type_e;

// Forwarding Mode Types
typedef enum logic [FORWARD_MODE-1:0] {
    FORWARD_NORMAL           = 3'b000,
    FORWARD_BRANCH_EX        = 3'b001,
    FORWARD_MEMORY_EX        = 3'b010,
    FORWARD_BRANCH_MEM       = 3'b011,
    FORWARD_MEMORY_MEM       = 3'b100,
    FORWARD_BRANCH_WB        = 3'b101,
    FORWARD_MEMORY_WB        = 3'b110
} forward_mode_e;

// ALU Main Operation Types
typedef enum logic [ALU_OP-1:0] {
    ALU_ADD    = 4'd0,
    ALU_SUB    = 4'd1,
    ALU_SLL    = 4'd2,
    ALU_SLT    = 4'd3,
    ALU_SLTU   = 4'd4,
    ALU_XOR    = 4'd5,
    ALU_SRL    = 4'd6,
    ALU_SRA    = 4'd7,
    ALU_OR     = 4'd8,
    ALU_AND    = 4'd9
} alu_op_e;

//---------------------------------------------------------
// Global Functions
//---------------------------------------------------------

// Forwarding MUX function
function automatic logic [WIDTH-1:0] Forwarding_MUX (
    input logic [FORWARD_MODE-1:0] Control_Signal,
    input logic [WIDTH-1:0] Normal_Data,
    input logic [WIDTH-1:0] Forwarding_From_Branch_Ex,
    input logic [WIDTH-1:0] Forwarding_From_Memory_Ex,
    input logic [WIDTH-1:0] Forwarding_From_Branch_Mem,
    input logic [WIDTH-1:0] Forwarding_From_Memory_Mem,
    input logic [WIDTH-1:0] Forwarding_From_Branch_WB,
    input logic [WIDTH-1:0] Forwarding_From_Memory_WB
);
    case (Control_Signal)
        FORWARD_NORMAL:        Forwarding_MUX = Normal_Data;
        FORWARD_BRANCH_EX:     Forwarding_MUX = Forwarding_From_Branch_Ex;
        FORWARD_MEMORY_EX:     Forwarding_MUX = Forwarding_From_Memory_Ex;
        FORWARD_BRANCH_MEM:    Forwarding_MUX = Forwarding_From_Branch_Mem;
        FORWARD_MEMORY_MEM:    Forwarding_MUX = Forwarding_From_Memory_Mem;
        FORWARD_BRANCH_WB:     Forwarding_MUX = Forwarding_From_Branch_WB;
        FORWARD_MEMORY_WB:     Forwarding_MUX = Forwarding_From_Memory_WB;
        default:               Forwarding_MUX = `ZERO32;
    endcase
endfunction

//---------------------------------------------------------
`endif // HEADER_FILE_SVH
