`include "Header_File.svh"
module Sign_Extender (
    input  logic [31:0] in [1:0],                 // Giriş: 32-bit immediate değeri, iki talimat için dizi [0] ve [1]
    input  logic [4:0]  op_code [1:0],           // Giriş: 5-bit op_code, iki talimat için dizi [0] ve [1]
    input  logic [1:0]  sign_extender_en ,   // Giriş: İşaret genişletici aktifleştirici, 1-bit, iki talimat için dizi [0] ve [1]
    input  logic [1:0]  sign_extender_type [1:0], // Giriş: İşaret genişletici tipi (0: signed, 1: unsigned), 1-bit, iki talimat için dizi [0] ve [1]
    
    output logic [31:0] imm_out [1:0]            // Çıkış: Genişletilmiş 32-bit immediate değeri, iki talimat için dizi [0] ve [1]
);

    integer i; // Döngü değişkeni

    always_comb 
	begin
        for (i = 0; i < 2; i = i + 1) begin // Her iki talimat için (in[0] ve in[1]) işaret genişletme işlemini yap
            if (sign_extender_en[i]) begin // İşaret genişletici etkinse
                casex (op_code[i]) // op_code'a göre genişletme tipini belirle
                    5'bxx101: // LUI ve AUIPC (01101 ve 00101)
                    begin
                        imm_out[i] = in[i]; // Girişi doğrudan çıkışa aktar (genişletme yok)
                    end
                    
                    5'b00100: // I-Type: Immediate ile işlemler (addi, slti, vb.)
                    begin
                        imm_out[i] = (sign_extender_type[i]) ? {20'd0, in[i][11:0]} : {{20{in[i][11]}}, in[i][11:0]}; // 12-bit immediate, unsigned veya signed genişletme
                    end
                    
                    5'b00000: // Load Type: Bellekten yükleme (lb, lbu, lh, lhu, lw)
                    begin
                        imm_out[i] = (sign_extender_type[i]) ? {20'd0, in[i][11:0]} : {{20{in[i][11]}}, in[i][11:0]}; // 12-bit immediate, unsigned veya signed genişletme
                    end
                    
                    5'b01000: // Store Type: Belleğe depolama (sb, sh, sw)
                    begin
                        imm_out[i] = in[i]; // Girişi doğrudan çıkışa aktar (genişletme yok)
                    end
                    
                    5'b110x1: // JAL ve JALR (11011 ve 11001)
                    begin
                        imm_out[i] = in[i]; // Girişi doğrudan çıkışa aktar (genişletme yok)
                    end
                    
                    5'b11000: // Branch Type: Dallanma komutları (beq, bne, blt, vb.)
                    begin
                        imm_out[i] = (sign_extender_type[i]) ? {19'd0, in[i][12:0]} : {{19{in[i][12]}}, in[i][12:0]}; // 13-bit immediate, unsigned veya signed genişletme
                    end
                    
                    default: // Geçersiz veya tanımlanmamış op_code
                    begin
                        imm_out[i] = 32'd0; // Çıkışı sıfırla
                    end
                endcase
            end
            else begin
                imm_out[i] = 32'd0; // İşaret genişletici devre dışıysa çıkışı sıfırla
            end
        end
    end

endmodule