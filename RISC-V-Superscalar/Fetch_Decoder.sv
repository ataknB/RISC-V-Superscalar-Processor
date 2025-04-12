module Fetch_Decoder(
	input logic  [31:0]inst[1:0],
	
    output logic branch_en[1:0],
    output logic [31:0]imm_out[1:0]
	
	);

    logic [31:0]imm[1:0];
    logic [4:0]sub_op_code[1:0];
    logic sign_extender_type[1:0];

	always_comb
	begin
            if(inst[6:2][0] == 5'b11000)
            begin
                branch_en[0]       = 1'b1;
                sub_op_code[0] 	= 	{1'b0 , inst[14:12]};
                imm[0]             = {inst[31]/*12*/, inst[7]/*11*/, inst[30:25]/*10:5*/, inst[11:8]/*4:1*/, 1'b0};

               // imm				=	{19'd0 , inst[31] , inst[7] , inst[30] , inst[29]  , inst[28]  , inst[27]  , inst[26]  , inst[25]  , inst[11] ,   inst[10] , inst[9]  , inst[8] , 1'b0};
                
                casex(sub_op_code)
                    4'bx000: // beq
                    begin
                        sign_extender_type[0]	=	1'b0;
                    end	
                    
                    
                    4'bx001: // bne
                    begin
                        sign_extender_type[0]	=	1'b0;
                    end	
                    
                    
                    4'bx100: // blt
                    begin
                        sign_extender_type[0]	=	1'b0;
                    end	
                    
                    4'bx101: // bge
                    begin
                        sign_extender_type[0]	=	1'b1;
                    end	
                
                    4'bx110: // bltu
                    begin
                        sign_extender_type[0]	=	1'b1;
                    end	
                    
                    4'bx111: // bgeu
                    begin
                        sign_extender_type[0]	=	1'b1;
                    end	
                    
                    default:
                    begin
                        sign_extender_type[0]	=	1'b0;
                    end
                endcase
            end
            
            else
            begin
                branch_en[1] = 1'b0;
                sub_op_code[1] 	= 	4'd0;
                imm[1] = 32'd0;
                sign_extender_type[1]	=	1'b0;
            end

            if(inst[6:2][1] == 5'b11000)
            begin
                branch_en[1]       = 1'b1;
                sub_op_code[1] 	= 	{1'b0 , inst[14:12]};
                imm[1]             = {inst[31]/*12*/, inst[7]/*11*/, inst[30:25]/*10:5*/, inst[11:8]/*4:1*/, 1'b0};

               // imm				=	{19'd0 , inst[31] , inst[7] , inst[30] , inst[29]  , inst[28]  , inst[27]  , inst[26]  , inst[25]  , inst[11] ,   inst[10] , inst[9]  , inst[8] , 1'b0};
                
                casex(sub_op_code)
                    4'bx000: // beq
                    begin
                        sign_extender_type[1]	=	1'b0;
                    end	
                    
                    
                    4'bx001: // bne
                    begin
                        sign_extender_type[1]	=	1'b0;
                    end	
                    
                    
                    4'bx100: // blt
                    begin
                        sign_extender_type[1]	=	1'b0;
                    end	
                    
                    4'bx101: // bge
                    begin
                        sign_extender_type[1]	=	1'b1;
                    end	
                
                    4'bx110: // bltu
                    begin
                        sign_extender_type[1]	=	1'b1;
                    end	
                    
                    4'bx111: // bgeu
                    begin
                        sign_extender_type[1]	=	1'b1;
                    end	
                    
                    default:
                    begin
                        sign_extender_type[1]	=	1'b0;
                    end
                endcase
            end
            
            else
            begin
                branch_en[1] = 1'b0;
                sub_op_code[1] 	= 	4'd0;
                imm[1] = 32'd0;
                sign_extender_type[1]	=	1'b0;
            end
	end   

    Sign_Extender Sign_Extender_0(
        .in(imm[0]),
        
        .op_code(5'b11000),
        .sign_extender_en(1'b1),
        .sign_extender_type(sign_extender_type[0]),

        .imm_out(imm_out[0])
    );

    Sign_Extender Sign_Extender_1(
        .in(imm[1]),
        
        .op_code(5'b11000),
        .sign_extender_en(1'b1),
        .sign_extender_type(sign_extender_type[1]),

        .imm_out(imm_out[1])
    );


endmodule
