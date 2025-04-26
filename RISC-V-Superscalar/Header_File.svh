parameter int WIDTH = 32;

typedef struct packed{
    logic    
} Forwarding_Signals;

function automatic logic [WIDTH-1:0] Forwarind_MUX (
    input logic [2:0]Control_Signal,

    input logic [WIDTH-1:0] Normal_Data,

    input logic [WIDTH-1:0] Forwarding_From_Branch_Ex,
    input logic [WIDTH-1:0] Forwarding_From_Memory_Ex,

    input logic [WIDTH-1:0] Forwarding_From_Branch_Mem,
    input logic [WIDTH-1:0] Forwarding_From_Memory_Mem,

    input logic [WIDTH-1:0] Forwarding_From_Branch_WB,
    input logic [WIDTH-1:0] Forwarding_From_Memory_WB

    );

    case(Control_Signal)
        3'b000:
        begin
            Forwarding_MUX = Normal_Data;
        end

        3'b001:
        begin
            Forwarding_MUX = Forwarding_From_Branch_Ex;
        end

        3'b010:
        begin
            Forwarding_MUX = Forwarding_From_Memory_Ex;
        end

        3'b011:
        begin
            Forwarding_MUX = Forwarding_From_Branch_Mem;
        end

        3'b100:
        begin
            Forwarding_MUX = Forwarding_From_Memory_Mem;
        end

        3'b101:
        begin
            Forwarding_MUX = Forwarding_From_Branch_WB;
        end

        3'b110:
        begin
            Forwarding_MUX = Forwarding_From_Memory_WB;
        end

        default:
        begin
            Forwarding_MUX = 32'd0;
        end
    endcase
endfunction