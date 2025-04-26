module Issue_Unit #(
    parameter WIDTH = 32,
    parameter LOAD_TYPE = 3
    )(
    //[0] önce gelen komut

    input logic    [WIDTH-1:0]rs1[1:0],
    input logic    [WIDTH-1:0]rs2[1:0],

    input logic     [1:0]RF_Write_en_Issue,
    input logic     [1:0]Mem_Read_en_Issue,
    input logic     [1:0]Mem_Write_en_Issue,
    input logic     [1:0]Sign_Extender_en_Issue,
    input logic     [ALU_OP-1:0]ALU_OP_Issue[1:0],
    input logic     [1:0]JAL_en_Issue,
    input logic     [1:0]JALR_en_Issue,
    input logic     [LOAD_TYPE-1:0]Load_Type_Issue[1:0],
    input logic     [1:0]Store_Type_Issue[1:0],
    input logic     [4:0]Shift_Size[1:0],
    input logic     [WIDTH-1:0]Imm[1:0],
    input logic     [WIDTH-1:0]rd[1:0],
    input logic     [WIDTH-1:0]PC[1:0],

    input logic     [2:0]Forwarding_Mode_rs1_Branch_Pipeline,
    input logic     [2:0]Forwarding_Mode_rs2_Branch_Pipeline,

    input logic     [2:0]Forwarding_Mode_rs1_Memory_Pipeline,
    input logic     [2:0]Forwarding_Mode_rs2_Memory_Pipeline,

    input logic     [1:0]Branch_en,

    input logic     [WIDTH-1:0]Forwarding_From_Branch_Ex,
    input logic     [WIDTH-1:0]Forwarding_From_Memory_Ex,

    input logic    [WIDTH-1:0]Forwarding_From_Branch_Mem,
    input logic    [WIDTH-1:0]Forwarding_From_Memory_Mem,

    input logic    [WIDTH-1:0]Forwarding_From_Branch_WB,
    input logic    [WIDTH-1:0]Forwarding_From_Memory_WB,

    output logic    [WIDTH-1:0]Branch_Pipeline_rs1_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_rs2_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_rd_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_PC_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_imm_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_shift_size_out,
    output logic    [WIDTH-1:0]Branch_Pipeline_ALU_OP_out,

    output logic    [WIDTH-1:0]Memory_Pipeline_rs1_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_rs2_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_rd_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_PC_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_imm_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_shift_size_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_ALU_OP_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_Mem_Read_en_out,
    output logic    [WIDTH-1:0]Memory_Pipeline_Mem_Write_en_out



    );
    
    logic    [WIDTH-1:0]Branch_Pipeline_rs1;
    logic    [WIDTH-1:0]Branch_Pipeline_rs2;
    logic    [WIDTH-1:0]Branch_Pipeline_rd;
    logic    [WIDTH-1:0]Branch_Pipeline_PC;
    logic    [WIDTH-1:0]Branch_Pipeline_imm;
    logic    [WIDTH-1:0]Branch_Pipeline_shift_size;
    logic    [WIDTH-1:0]Branch_Pipeline_ALU_OP;

    logic    [WIDTH-1:0]Memory_Pipeline_rs1;
    logic    [WIDTH-1:0]Memory_Pipeline_rs2;
    logic    [WIDTH-1:0]Memory_Pipeline_rd;
    logic    [WIDTH-1:0]Memory_Pipeline_PC;
    logic    [WIDTH-1:0]Memory_Pipeline_imm;
    logic    [WIDTH-1:0]Memory_Pipeline_shift_size;
    logic    [WIDTH-1:0]Memory_Pipeline_ALU_OP;
    logic    [WIDTH-1:0]Memory_Pipeline_Mem_Read_en;
    logic    [WIDTH-1:0]Memory_Pipeline_Mem_Write_en;

    logic   [1:0]Store_en;
    assign  Store_en[0] = {|Store_Type_Issue[0][1:0]};
    assign  Store_en[1] = {|Store_Type_Issue[1][1:0]};

    logic   [1:0]Load_en;
    assign  Load_en[0] = {|Load_Type_Issue[0][2:0]};
    assign  Load_en[1] = {|Load_Type_Issue[1][2:0]};

    logic   [1:0]temp_mem;
    assign  temp_mem[0] = Store_en[0] || Load_en[0];
    assign  temp_mem[1] = Store_en[1] || Load_en[1];
    
    logic   [1:0]Priority_bit; //0. bit 1 ise Branch pipeındaki en taze olanıdır.


    always_comb
    begin
        
        if(Store_en[0] || Store_en[1] || Load_en[0] || Load_en[1])
        begin
            case(temp_mem)
            2'b00 , 2'b10 , 2'b11: //İki tarafta da yok
            begin
                Branch_Pipeline_rs1 = rs1[0];
                Branch_Pipeline_rs2 = rs2[0];

                Branch_Pipeline_rd = rd[0];
                Branch_Pipeline_imm = Imm[0];
                Branch_Pipeline_shift_size = Shift_Size[0];
                Branch_Pipeline_ALU_OP = ALU_OP_Issue[0];

                Branch_Pipeline_PC = PC[0];

                Memory_Pipeline_rs1 = rs1[1];
                Memory_Pipeline_rs2 = rs2[1];
                Memory_Pipeline_rd = rd[1];
                Memory_Pipeline_imm = Imm[1];
                Memory_Pipeline_shift_size = Shift_Size[1];
                Memory_Pipeline_ALU_OP = ALU_OP_Issue[1];
                Memory_Pipeline_PC = PC[1];
                Memory_Pipeline_Mem_Read_en = Mem_Read_en_Issue[1];
                Memory_Pipeline_Mem_Write_en = Mem_Write_en_Issue[1];
                Memory_Pipeline_PC = PC[1];

                Priority_bit = 2'b10;
            end

            2'b01: //Birinci tarafta var ikinci tarafta yok
            begin
                Branch_Pipeline_rs1 = rs1[1];
                Branch_Pipeline_rs2 = rs2[1];

                Branch_Pipeline_rd = rd[1];
                Branch_Pipeline_imm = Imm[1];
                Branch_Pipeline_shift_size = Shift_Size[1];
                Branch_Pipeline_ALU_OP = ALU_OP_Issue[1];

                Branch_Pipeline_PC = PC[1];

                Memory_Pipeline_rs1 = rs1[0];
                Memory_Pipeline_rs2 = rs2[0];
                Memory_Pipeline_rd = rd[0];
                Memory_Pipeline_imm = Imm[0];
                Memory_Pipeline_shift_size = Shift_Size[0];
                Memory_Pipeline_ALU_OP = ALU_OP_Issue[0];
                Memory_Pipeline_PC = PC[0];
                Memory_Pipeline_Mem_Read_en = Mem_Read_en_Issue[0];
                Memory_Pipeline_Mem_Write_en = Mem_Write_en_Issue[0];
                Memory_Pipeline_PC = PC[0];

                Priority_bit = 2'b01;
            end

            default:
            begin
                Branch_Pipeline_rs1 = 32'd0;
                Branch_Pipeline_rs2 = 32'd0;

                Branch_Pipeline_rd = 32'd0;
                Branch_Pipeline_imm = 32'd0;
                Branch_Pipeline_shift_size = 32'd0;
                Branch_Pipeline_ALU_OP = 32'd0;

                Branch_Pipeline_PC = 32'd0;

                Memory_Pipeline_rs1 = 32'd0;
                Memory_Pipeline_rs2 = 32'd0;
                Memory_Pipeline_rd = 32'd0;
                Memory_Pipeline_imm = 32'd0;
                Memory_Pipeline_shift_size = 32'd0;
                Memory_Pipeline_ALU_OP = 32'd0;
                Memory_Pipeline_PC = 32'd0;
                Memory_Pipeline_Mem_Read_en = 32'd0;
                Memory_Pipeline_Mem_Write_en = 32'd0;
                Memory_Pipeline_PC = 32'd0;

                Priority_bit = 2'b00;
            end
        endcase
        end

        else if(Branch_en[0] || Branch_en[1])
        begin
            case(temp_mem)
            2'b00 , 2'b01 , 2'b11: //İki tarafta da yok
            begin
                Branch_Pipeline_rs1 = rs1[0];
                Branch_Pipeline_rs2 = rs2[0];

                Branch_Pipeline_rd = rd[0];
                Branch_Pipeline_imm = Imm[0];
                Branch_Pipeline_shift_size = Shift_Size[0];
                Branch_Pipeline_ALU_OP = ALU_OP_Issue[0];

                Branch_Pipeline_PC = PC[0];

                Memory_Pipeline_rs1 = rs1[1];
                Memory_Pipeline_rs2 = rs2[1];
                Memory_Pipeline_rd = rd[1];
                Memory_Pipeline_imm = Imm[1];
                Memory_Pipeline_shift_size = Shift_Size[1];
                Memory_Pipeline_ALU_OP = ALU_OP_Issue[1];
                Memory_Pipeline_PC = PC[1];
                Memory_Pipeline_Mem_Read_en = Mem_Read_en_Issue[1];
                Memory_Pipeline_Mem_Write_en = Mem_Write_en_Issue[1];
                Memory_Pipeline_PC = PC[1];

                Priority_bit = 2'b10;
            end

            2'b10: //Birinci tarafta var ikinci tarafta yok
            begin
                Branch_Pipeline_rs1 = rs1[1];
                Branch_Pipeline_rs2 = rs2[1];

                Branch_Pipeline_rd = rd[1];
                Branch_Pipeline_imm = Imm[1];
                Branch_Pipeline_shift_size = Shift_Size[1];
                Branch_Pipeline_ALU_OP = ALU_OP_Issue[1];

                Branch_Pipeline_PC = PC[1];

                Memory_Pipeline_rs1 = rs1[0];
                Memory_Pipeline_rs2 = rs2[0];
                Memory_Pipeline_rd = rd[0];
                Memory_Pipeline_imm = Imm[0];
                Memory_Pipeline_shift_size = Shift_Size[0];
                Memory_Pipeline_ALU_OP = ALU_OP_Issue[0];
                Memory_Pipeline_PC = PC[0];
                Memory_Pipeline_Mem_Read_en = Mem_Read_en_Issue[0];
                Memory_Pipeline_Mem_Write_en = Mem_Write_en_Issue[0];
                Memory_Pipeline_PC = PC[0];

                Priority_bit = 2'b01;
            end

            default:
            begin
                Branch_Pipeline_rs1 = 32'd0;
                Branch_Pipeline_rs2 = 32'd0;

                Branch_Pipeline_rd = 32'd0;
                Branch_Pipeline_imm = 32'd0;
                Branch_Pipeline_shift_size = 32'd0;
                Branch_Pipeline_ALU_OP = 32'd0;

                Branch_Pipeline_PC = 32'd0;

                Memory_Pipeline_rs1 = 32'd0;
                Memory_Pipeline_rs2 = 32'd0;
                Memory_Pipeline_rd = 32'd0;
                Memory_Pipeline_imm = 32'd0;
                Memory_Pipeline_shift_size = 32'd0;
                Memory_Pipeline_ALU_OP = 32'd0;
                Memory_Pipeline_PC = 32'd0;
                Memory_Pipeline_Mem_Read_en = 32'd0;
                Memory_Pipeline_Mem_Write_en = 32'd0;
                Memory_Pipeline_PC = 32'd0;

                Priority_bit = 2'b00;
            end
        endcase
        end

        else
        begin
            Branch_Pipeline_rs1 = 32'd0;
            Branch_Pipeline_rs2 = 32'd0;

            Branch_Pipeline_rd = 32'd0;
            Branch_Pipeline_imm = 32'd0;
            Branch_Pipeline_shift_size = 32'd0;
            Branch_Pipeline_ALU_OP = 32'd0;

            Branch_Pipeline_PC = 32'd0;

            Memory_Pipeline_rs1 = 32'd0;
            Memory_Pipeline_rs2 = 32'd0;
            Memory_Pipeline_rd = 32'd0;
            Memory_Pipeline_imm = 32'd0;
            Memory_Pipeline_shift_size = 32'd0;
            Memory_Pipeline_ALU_OP = 32'd0;
            Memory_Pipeline_PC = 32'd0;
            Memory_Pipeline_Mem_Read_en = 32'd0;
            Memory_Pipeline_Mem_Write_en = 32'd0;
            Memory_Pipeline_PC = 32'd0;
        end
    end



    always_comb
    begin

        Branch_Pipeline_rs1_out = Branch_Pipeline_rs1;
        Branch_Pipeline_rs2_out = Branch_Pipeline_rs2;
        Branch_Pipeline_rd_out = Branch_Pipeline_rd;
        Branch_Pipeline_PC_out = Branch_Pipeline_PC;

        Branch_Pipeline_imm_out = Branch_Pipeline_imm;
        Branch_Pipeline_shift_size_out = Branch_Pipeline_shift_size;
        Branch_Pipeline_ALU_OP_out = Branch_Pipeline_ALU_OP;

        Branch_Pipeline_PC_out = Branch_Pipeline_PC;

        Memory_Pipeline_rs1_out = Memory_Pipeline_rs1;
        Memory_Pipeline_rs2_out = Memory_Pipeline_rs2;
        Memory_Pipeline_rd_out = Memory_Pipeline_rd;
        Memory_Pipeline_PC_out = Memory_Pipeline_PC;
        Memory_Pipeline_imm_out = Memory_Pipeline_imm;
        Memory_Pipeline_shift_size_out = Memory_Pipeline_shift_size;
        Memory_Pipeline_ALU_OP_out = Memory_Pipeline_ALU_OP;
        Memory_Pipeline_Mem_Read_en_out = Memory_Pipeline_Mem_Read_en;
        Memory_Pipeline_Mem_Write_en_out = Memory_Pipeline_Mem_Write_en;
        Memory_Pipeline_PC_out = Memory_Pipeline_PC;

        // Branch_Pipeline_rs1_out = Forwarding_MUX(
        //     Forwarding_Mode_rs1_Branch_Pipeline,
        //     Branch_Pipeline_rs1,
        //     Forwarding_From_Branch_Ex,
        //     Forwarding_From_Memory_Ex,
        //     Forwarding_From_Branch_Mem,
        //     Forwarding_From_Memory_Mem,
        //     Forwarding_From_Branch_WB,
        //     Forwarding_From_Memory_WB
        // );
        // Branch_Pipeline_rs2_out = Forwarding_MUX(
        //     Forwarding_Mode_rs2_Branch_Pipeline,
        //     Branch_Pipeline_rs2,
        //     Forwarding_From_Branch_Ex,
        //     Forwarding_From_Memory_Ex,
        //     Forwarding_From_Branch_Mem,
        //     Forwarding_From_Memory_Mem,
        //     Forwarding_From_Branch_WB,
        //     Forwarding_From_Memory_WB
        // );

        // Memory_Pipeline_rs1_out = Forwarding_MUX(
        //     Forwarding_Mode_rs1_Memory_Pipeline,
        //     Memory_Pipeline_rs1,
        //     Forwarding_From_Branch_Ex,
        //     Forwarding_From_Memory_Ex,
        //     Forwarding_From_Branch_Mem,
        //     Forwarding_From_Memory_Mem,
        //     Forwarding_From_Branch_WB,
        //     Forwarding_From_Memory_WB
        // );

        // Memory_Pipeline_rs2_out = Forwarding_MUX(
        //     Forwarding_Mode_rs2_Memory_Pipeline,
        //     Memory_Pipeline_rs2,
        //     Forwarding_From_Branch_Ex,
        //     Forwarding_From_Memory_Ex,
        //     Forwarding_From_Branch_Mem,
        //     Forwarding_From_Memory_Mem,
        //     Forwarding_From_Branch_WB,
        //     Forwarding_From_Memory_WB
        // );
    end

endmodule