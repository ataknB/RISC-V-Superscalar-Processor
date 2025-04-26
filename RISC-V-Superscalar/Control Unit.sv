`include "Header_File.svh"
module Control_Unit (
    input  logic [4:0] op_code [1:0],      // Giriş: 5-bit op_code, iki talimat için dizi [0] ve [1]
    input  logic [3:0] sub_op_code [1:0],  // Giriş: 4-bit sub_op_code, iki talimat için dizi [0] ve [1]
    
    output logic       imm_en [1:0],       // Çıkış: Immediate değeri seçici, 1-bit, 2 elemanlı
    output logic       rf_write_en [1:0],  // Çıkış: Register dosyası yazma izni, 1-bit, 2 elemanlı
    output logic       mem_read_en [1:0],  // Çıkış: Bellek okuma izni, 1-bit, 2 elemanlı
    output logic       mem_write_en [1:0], // Çıkış: Bellek yazma izni, 1-bit, 2 elemanlı
    output logic [1:0] branch_mode [1:0],  // Çıkış: Program sayacı kontrolü, 2-bit (01: normal, 10: jump, 11: branch, 00: NA), 2 elemanlı
    output logic       JALR_en [1:0],      // Çıkış: JALR komutu aktifleştirici, 1-bit, 2 elemanlı
    output logic       JAL_en [1:0],       // Çıkış: JAL komutu aktifleştirici, 1-bit, 2 elemanlı
    output logic       sign_extender_en [1:0],    // Çıkış: İşaret genişletici aktifleştirici, 1-bit, 2 elemanlı
    output logic       sign_extender_type [1:0],  // Çıkış: İşaret genişletici tipi (1: unsigned, 0: signed), 1-bit, 2 elemanlı
    output logic [2:0] load_type [1:0],    // Çıkış: Yükleme tipi (000: NA, 001: lb, 010: lbu, 011: lh, 100: lhu, 101: lw), 3-bit, 2 elemanlı
    output logic [1:0] store_type [1:0],   // Çıkış: Depolama tipi (00: NA, 01: sb, 10: sh, 11: sw), 2-bit, 2 elemanlı
    output logic [3:0] alu_op [1:0]        // Çıkış: ALU işlem kontrolü, 4-bit, 2 elemanlı
);

    integer i; // Döngü değişkeni

    always_comb 
	begin
        for (i = 0; i < 2; i = i + 1) begin // Her iki talimat için (op_code[0] ve op_code[1]) kontrol sinyalleri hesapla
            casex (op_code[i])
                5'b01101: // LUI: Üst immediate yükleme
                begin
                    imm_en[i]            = 1'b1;  // Immediate değeri kullan
                    rf_write_en[i]       = 1'b1;  // Register dosyasına yaz
                    mem_read_en[i]       = 1'b0;  // Bellek okuması yok
                    mem_write_en[i]      = 1'b0;  // Bellek yazması yok
                    sign_extender_en[i]  = 1'b1;  // İşaret genişleticiyi etkinleştir
                    sign_extender_type[i]= 1'b0;  // Signed genişletme
                    branch_mode[i]       = 2'b01; // Normal PC artışı
                    JAL_en[i]            = 1'b0;  // JAL devre dışı
                    JALR_en[i]           = 1'b0;  // JALR devre dışı
                    load_type[i]         = 3'b000;// Yükleme yok
                    store_type[i]        = 2'b00; // Depolama yok
                    alu_op[i]            = 4'd0;  // ALU işlemi yok
                end
                
                5'b00101: // AUIPC: PC ile immediate toplama
                begin
                    imm_en[i]            = 1'b1;  // Immediate değeri kullan
                    rf_write_en[i]       = 1'b1;  // Register dosyasına yaz
                    mem_read_en[i]       = 1'b0;  // Bellek okuması yok
                    mem_write_en[i]      = 1'b0;  // Bellek yazması yok
                    sign_extender_en[i]  = 1'b1;  // İşaret genişleticiyi etkinleştir
                    sign_extender_type[i]= 1'b0;  // Signed genişletme
                    branch_mode[i]       = 2'b01; // Normal PC artışı
                    JAL_en[i]            = 1'b0;  // JAL devre dışı
                    JALR_en[i]           = 1'b0;  // JALR devre dışı
                    load_type[i]         = 3'b000;// Yükleme yok
                    store_type[i]        = 2'b00; // Depolama yok
                    alu_op[i]            = 4'd0;  // ALU işlemi yok
                end

                5'b00100: // I-Type: Immediate ile işlemler (addi, slti, xori, vb.)
                begin
                    imm_en[i]            = 1'b1;  // Immediate değeri kullan
                    rf_write_en[i]       = 1'b1;  // Register dosyasına yaz
                    mem_read_en[i]       = 1'b0;  // Bellek okuması yok
                    mem_write_en[i]      = 1'b0;  // Bellek yazması yok
                    sign_extender_en[i]  = 1'b1;  // İşaret genişleticiyi etkinleştir
                    sign_extender_type[i]= (sub_op_code[i][2:0] == 3'b011) ? 1'b1 : 1'b0; // sltiu için unsigned
                    branch_mode[i]       = 2'b01; // Normal PC artışı
                    JAL_en[i]            = 1'b0;  // JAL devre dışı
                    JALR_en[i]           = 1'b0;  // JALR devre dışı
                    load_type[i]         = 3'b000;// Yükleme yok
                    store_type[i]        = 2'b00; // Depolama yok
                    
                    casex (sub_op_code[i]) // I-Type için ALU işlemlerini belirle
                        4'bx000: // addi
                            alu_op[i] = 4'b0000; // Toplama
                        4'bx010: // slti/sltiu
                            alu_op[i] = 4'b1101; // Küçüktür karşılaştırması
                        4'bx011: // sltiu (tekrar eden bit için x)
                            alu_op[i] = 4'b1101; // Küçüktür karşılaştırması
                        4'bx100: // xori
                            alu_op[i] = 4'b0110; // XOR işlemi
                        4'bx110: // ori
                            alu_op[i] = 4'b0111; // OR işlemi
                        4'bx111: // andi
                            alu_op[i] = 4'b1000; // AND işlemi
                        4'b0001: // slli
                            alu_op[i] = 4'b0010; // Sola kaydırma
                        4'b0101: // srli
                            alu_op[i] = 4'b0100; // Sağa kaydırma (unsigned)
                        4'b1101: // srai
                            alu_op[i] = 4'b0101; // Sağa kaydırma (signed)
                        default:
                            alu_op[i] = 4'd0;    // Varsayılan: ALU işlemi yok
                    endcase
                end
                
                5'b01100: // R-Type: Register-register işlemleri (add, sub, sll, vb.)
                begin
                    imm_en[i]            = 1'b0;  // Immediate kullanılmaz
                    rf_write_en[i]       = 1'b1;  // Register dosyasına yaz
                    mem_read_en[i]       = 1'b0;  // Bellek okuması yok
                    mem_write_en[i]      = 1'b0;  // Bellek yazması yok
                    sign_extender_en[i]  = 1'b0;  // İşaret genişletici devre dışı
                    sign_extender_type[i]= 1'b0;  // İşaret tipi önemli değil
                    branch_mode[i]       = 2'b01; // Normal PC artışı
                    JAL_en[i]            = 1'b0;  // JAL devre dışı
                    JALR_en[i]           = 1'b0;  // JALR devre dışı
                    load_type[i]         = 3'b000;// Yükleme yok
                    store_type[i]        = 2'b00; // Depolama yok
                    
                    casex (sub_op_code[i]) // R-Type için ALU işlemlerini belirle
                        4'b0000: // add
                            alu_op[i] = 4'b0000; // Toplama
                        4'b1000: // sub
                            alu_op[i] = 4'b0001; // Çıkarma
                        4'bx001: // sll
                            alu_op[i] = 4'b0010; // Sola kaydırma
                        4'bx010: // slt
                            alu_op[i] = 4'b1101; // Küçüktür karşılaştırması
                        4'bx011: // sltu
                            alu_op[i] = 4'b1101; // Küçüktür karşılaştırması (unsigned)
                        4'bx100: // xor
                            alu_op[i] = 4'b0110; // XOR işlemi
                        4'bx101: // srl/sra
                            alu_op[i] = sub_op_code[i][3] ? 4'b0101 : 4'b0100; // Sağa kaydırma (signed/unsigned)
                        4'bx110: // or
                            alu_op[i] = 4'b0111; // OR işlemi
                        4'bx111: // and
                            alu_op[i] = 4'b1000; // AND işlemi
                        default:
                            alu_op[i] = 4'd0;    // Varsayılan: ALU işlemi yok
                    endcase
                end
                
                5'b00000: // Load Type: Bellekten yükleme (lb, lbu, lh, lhu, lw)
                begin
                    imm_en[i]            = 1'b1;  // Immediate değeri kullan
                    rf_write_en[i]       = 1'b1;  // Register dosyasına yaz
                    mem_read_en[i]       = 1'b1;  // Bellekten oku
                    mem_write_en[i]      = 1'b0;  // Bellek yazması yok
                    sign_extender_en[i]  = 1'b1;  // İşaret genişleticiyi etkinleştir
                    sign_extender_type[i]= 1'b0;  // Signed genişletme (lbu/lhu hariç)
                    branch_mode[i]       = 2'b01; // Normal PC artışı
                    JAL_en[i]            = 1'b0;  // JAL devre dışı
                    JALR_en[i]           = 1'b0;  // JALR devre dışı
                    store_type[i]        = 2'b00; // Depolama yok
                    alu_op[i]            = 4'd0;  // ALU işlemi yok (adres hesaplama için toplama varsayılan)
                    
                    casex (sub_op_code[i]) // Yükleme tipini belirle
                        4'b0000: // lb
                            load_type[i] = 3'b001;
                        4'b0100: // lbu
                            load_type[i] = 3'b010;
                        4'b0001: // lh
                            load_type[i] = 3'b011;
                        4'b0101: // lhu
                            load_type[i] = 3'b100;
                        4'b0010: // lw
                            load_type[i] = 3'b101;
                        default:
                            load_type[i] = 3'b000; // Varsayılan: Yükleme yok
                    endcase
                end
                
                5'b01000: // Store Type: Belleğe depolama (sb, sh, sw)
                begin
                    imm_en[i]            = 1'b1;  // Immediate değeri kullan
                    rf_write_en[i]       = 1'b0;  // Register dosyasına yazma yok
                    mem_read_en[i]       = 1'b0;  // Bellek okuması yok
                    mem_write_en[i]      = 1'b1;  // Belleğe yaz
                    sign_extender_en[i]  = 1'b1;  // İşaret genişleticiyi etkinleştir
                    sign_extender_type[i]= 1'b0;  // Signed genişletme
                    branch_mode[i]       = 2'b01; // Normal PC artışı
                    JAL_en[i]            = 1'b0;  // JAL devre dışı
                    JALR_en[i]           = 1'b0;  // JALR devre dışı
                    load_type[i]         = 3'b000;// Yükleme yok
                    alu_op[i]            = 4'd0;  // ALU işlemi yok (adres hesaplama için toplama varsayılan)
                    
                    casex (sub_op_code[i]) // Depolama tipini belirle
                        4'bx000: // sb
                            store_type[i] = 2'b01;
                        4'bx001: // sh
                            store_type[i] = 2'b10;
                        4'bx010: // sw
                            store_type[i] = 2'b11;
                        default:
                            store_type[i] = 2'b00; // Varsayılan: Depolama yok
                    endcase
                end
                
                5'b11011: // JAL: Jump and Link
                begin
                    imm_en[i]            = 1'b1;  // Immediate değeri kullan
                    rf_write_en[i]       = 1'b1;  // Register dosyasına yaz (PC+4)
                    mem_read_en[i]       = 1'b0;  // Bellek okuması yok
                    mem_write_en[i]      = 1'b0;  // Bellek yazması yok
                    sign_extender_en[i]  = 1'b1;  // İşaret genişleticiyi etkinleştir
                    sign_extender_type[i]= 1'b0;  // Signed genişletme
                    branch_mode[i]       = 2'b10; // Jump modu
                    JAL_en[i]            = 1'b1;  // JAL aktif
                    JALR_en[i]           = 1'b0;  // JALR devre dışı
                    load_type[i]         = 3'b000;// Yükleme yok
                    store_type[i]        = 2'b00; // Depolama yok
                    alu_op[i]            = 4'd0;  // ALU işlemi yok
                end
                
                5'b11001: // JALR: Jump and Link Register
                begin
                    imm_en[i]            = 1'b1;  // Immediate değeri kullan
                    rf_write_en[i]       = 1'b1;  // Register dosyasına yaz (PC+4)
                    mem_read_en[i]       = 1'b0;  // Bellek okuması yok
                    mem_write_en[i]      = 1'b0;  // Bellek yazması yok
                    sign_extender_en[i]  = 1'b1;  // İşaret genişleticiyi etkinleştir
                    sign_extender_type[i]= 1'b0;  // Signed genişletme
                    branch_mode[i]       = 2'b10; // Jump modu
                    JAL_en[i]            = 1'b0;  // JAL devre dışı
                    JALR_en[i]           = 1'b1;  // JALR aktif
                    load_type[i]         = 3'b000;// Yükleme yok
                    store_type[i]        = 2'b00; // Depolama yok
                    alu_op[i]            = 4'd0;  // ALU işlemi yok
                end
                
                5'b11000: // Branch Type: Dallanma komutları (beq, bne, blt, vb.)
                begin
                    imm_en[i]            = 1'b1;  // Immediate değeri kullan
                    rf_write_en[i]       = 1'b0;  // Register dosyasına yazma yok
                    mem_read_en[i]       = 1'b0;  // Bellek okuması yok
                    mem_write_en[i]      = 1'b0;  // Bellek yazması yok
                    sign_extender_en[i]  = 1'b1;  // İşaret genişleticiyi etkinleştir
                    branch_mode[i]       = 2'b11; // Branch modu
                    JAL_en[i]            = 1'b0;  // JAL devre dışı
                    JALR_en[i]           = 1'b0;  // JALR devre dışı
                    load_type[i]         = 3'b000;// Yükleme yok
                    store_type[i]        = 2'b00; // Depolama yok
                    
                    casex (sub_op_code[i]) // Dallanma tipini ve ALU işlemini belirle
                        4'bx000: // beq
                        begin
                            sign_extender_type[i] = 1'b0; // Signed genişletme
                            alu_op[i] = 4'b1001; // Eşitlik karşılaştırması
                        end
                        4'bx001: // bne
                        begin
                            sign_extender_type[i] = 1'b0; // Signed genişletme
                            alu_op[i] = 4'b1010; // Eşit değil karşılaştırması
                        end
                        4'bx100: // blt
                        begin
                            sign_extender_type[i] = 1'b0; // Signed genişletme
                            alu_op[i] = 4'b1011; // Küçüktür karşılaştırması
                        end
                        4'bx101: // bge
                        begin
                            sign_extender_type[i] = 1'b1; // Unsigned genişletme
                            alu_op[i] = 4'b1100; // Büyük veya eşit karşılaştırması
                        end
                        4'bx110: // bltu
                        begin
                            sign_extender_type[i] = 1'b1; // Unsigned genişletme
                            alu_op[i] = 4'b1011; // Küçüktür karşılaştırması (unsigned)
                        end
                        4'bx111: // bgeu
                        begin
                            sign_extender_type[i] = 1'b1; // Unsigned genişletme
                            alu_op[i] = 4'b1100; // Büyük veya eşit karşılaştırması (unsigned)
                        end
                        default:
                        begin
                            sign_extender_type[i] = 1'b0; // Varsayılan: Signed
                            alu_op[i] = 4'd0; // Varsayılan: ALU işlemi yok
                        end
                    endcase
                end
                
                default: // Geçersiz veya tanımlanmamış op_code
                begin
                    imm_en[i]            = 1'b0;  // Immediate devre dışı
                    rf_write_en[i]       = 1'b0;  // Register yazma devre dışı
                    mem_read_en[i]       = 1'b0;  // Bellek okuma devre dışı
                    mem_write_en[i]      = 1'b0;  // Bellek yazma devre dışı
                    sign_extender_en[i]  = 1'b0;  // İşaret genişletici devre dışı
                    sign_extender_type[i]= 1'b0;  // İşaret tipi önemli değil
                    branch_mode[i]       = 2'b00; // PC kontrolü yok
                    JAL_en[i]            = 1'b0;  // JAL devre dışı
                    JALR_en[i]           = 1'b0;  // JALR devre dışı
                    load_type[i]         = 3'b000;// Yükleme yok
                    store_type[i]        = 2'b00; // Depolama yok
                    alu_op[i]            = 4'd0;  // ALU işlemi yok
                end
            endcase
        end
    end

endmodule