`include "Header_File.svh"

module RF(
    input logic clk,
    input logic rst,

    input logic [RS-1:0] rs1 [1:0],
    input logic [RS-1:0] rs2 [1:0],

    input logic [RS-1:0] rd_Branch,
    input logic [RS-1:0] rd_Memory,

    input logic [WIDTH-1:0] wd_Branch,
    input logic [WIDTH-1:0] wd_Memory,
    input logic [WIDTH-1:0] PC_out_Memory,
    input logic [WIDTH-1:0] PC_out_Branch,

    input logic [1:0] write_en ,

    output logic [WIDTH-1:0] rd1 [1:0],
    output logic [WIDTH-1:0] rd2 [1:0]
);

    logic [WIDTH-1:0] reg_data [31:0];

    // Read operations
    assign rd1[0] = reg_data[rs1[0]];
    assign rd1[1] = reg_data[rs1[1]];

    assign rd2[0] = reg_data[rs2[0]];
    assign rd2[1] = reg_data[rs2[1]];




    // Write operations
    always_ff @(negedge clk , negedge rst) begin
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
                case(write_en)
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
