`include "Header_File.svh"

module RF(
    input logic clk,
    input logic rst,

    input logic [RS-1:0] rs1_0,
    input logic [RS-1:0] rs1_1,
    input logic [RS-1:0] rs2_0,
    input logic [RS-1:0] rs2_1,

    input logic [RS-1:0] rd_Branch,
    input logic [RS-1:0] rd_Memory,

    input logic [WIDTH-1:0] wd_Branch,
    input logic [WIDTH-1:0] wd_Memory,
    input logic [WIDTH-1:0] PC_out_Memory,
    input logic [WIDTH-1:0] PC_out_Branch,

    input logic write_en_Memory,
    input logic write_en_Branch,

    output logic [WIDTH-1:0] rd1_0,
    output logic [WIDTH-1:0] rd1_1,
    output logic [WIDTH-1:0] rd2_0,
    output logic [WIDTH-1:0] rd2_1
);
    logic [RS-1:0] rs1 [1:0],
    logic [RS-1:0] rs2 [1:0],

    assign rs1[0] = rs1_0;
    assign rs1[1] = rs1_1;

    assign rs2[0] = rs2_0;
    assign rs2[1] = rs2_1;

    logic [WIDTH-1:0] reg_data [31:0];

    // Read operations
    assign rd1_0 = reg_data[rs1[0]];
    assign rd1_1 = reg_data[rs1[1]];

    assign rd2_0 = reg_data[rs2[0]];
    assign rd2_1 = reg_data[rs2[1]];


    

    // Write operations
    always_ff @(negedge clk , negedge rst)
    begin
        reg_data[0] <= 32'd0; // x0 is always zero

        if (!rst) 
        begin
                reg_data <= '{default: 32'd0};
        end

        else 
        begin
            if(rd_Branch == rd_Memory)
            begin
                if(PC_out_Branch < PC_out_Memory)
                begin
                    reg_data[rd_Memory] <= wd_Memory;
                end

                else
                begin
                    reg_data[rd_Branch] <= wd_Branch;
                end
            end

            else
            begin
                case({write_en_Memory, write_en_Branch})
                    2'b01: reg_data[rd_Branch] <= wd_Branch;
                    2'b10: reg_data[rd_Memory] <= wd_Memory;
                    2'b11: 
                    begin
                        reg_data[rd_Memory] <= wd_Memory;
                        reg_data[rd_Branch] <= wd_Branch;
                    end
                    default: reg_data <= reg_data;
                endcase
            end
        end
    end

endmodule
