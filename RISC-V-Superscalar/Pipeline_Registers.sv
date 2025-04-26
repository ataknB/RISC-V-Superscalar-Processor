`include "Header_File.svh"
module Decode_Register (
    input  logic        clk,                              // Giriş: Saat sinyali
    input  logic        rst,                              // Giriş: Asenkron sıfırlama (negatif kenar)
    
    input  logic [31:0] normal_F [1:0],                  // Giriş: Fetch aşamasından normal veri, iki talimat için dizi [0] ve [1]
    input  logic [31:0] PC_out_F [1:0],                  // Giriş: Fetch aşamasından program sayacı, iki talimat için dizi [0] ve [1]
    input  logic [31:0] InstructionMemory_out_F [1:0],   // Giriş: Fetch aşamasından talimat belleği çıkışı, iki talimat için dizi [0] ve [1]
    input  logic        stall_DE [1:0],                  // Giriş: Decode aşamasında duraklatma sinyali, iki talimat için dizi [0] ve [1]
    input  logic        flush_DE [1:0],                  // Giriş: Decode aşamasında sıfırlama sinyali, iki talimat için dizi [0] ve [1]
    input  logic        BP_decision_F [1:0],             // Giriş: Fetch aşamasından dal tahmini kararı, iki talimat için dizi [0] ve [1]
    input  logic        BP_en_F [1:0],                   // Giriş: Fetch aşamasından dal tahmini aktifleştirici, iki talimat için dizi [0] ve [1]
    
    output logic [31:0] normal_DE [1:0],                 // Çıkış: Decode aşamasına normal veri, iki talimat için dizi [0] ve [1]
    output logic [31:0] PC_out_DE [1:0],                 // Çıkış: Decode aşamasına program sayacı, iki talimat için dizi [0] ve [1]
    output logic [31:0] InstructionMemory_out_DE [1:0],  // Çıkış: Decode aşamasına talimat belleği çıkışı, iki talimat için dizi [0] ve [1]
    output logic        BP_decision_DE [1:0],            // Çıkış: Decode aşamasına dal tahmini kararı, iki talimat için dizi [0] ve [1]
    output logic        BP_en_DE [1:0]                   // Çıkış: Decode aşamasına dal tahmini aktifleştirici, iki talimat için dizi [0] ve [1]
);
    
    integer i; // Döngü değişkeni
    
    always_ff @(posedge clk, negedge rst) begin
        for (i = 0; i < 2; i++) begin // Her iki talimat için ayrı atama yap
            if (!rst || flush_DE[i]) begin // Asenkron sıfırlama veya flush sinyali aktifse
                normal_DE[i] <= 32'd0;                 // Normal veriyi sıfırla
                PC_out_DE[i] <= 32'd0;                 // Program sayacını sıfırla
                InstructionMemory_out_DE[i] <= 32'd0;  // Talimat belleği çıkışını sıfırla
                BP_decision_DE[i] <= 1'b0;             // Dal tahmini kararını sıfırla
                BP_en_DE[i] <= 1'b0;                   // Dal tahmini aktifleştiriciyi sıfırla
            end
            else if (stall_DE[i]) begin // Duraklatma sinyali aktifse
                normal_DE[i] <= normal_DE[i];                 // Mevcut normal veriyi koru
                PC_out_DE[i] <= PC_out_DE[i];                 // Mevcut program sayacını koru
                InstructionMemory_out_DE[i] <= InstructionMemory_out_DE[i]; // Mevcut talimat belleği çıkışını koru
                BP_decision_DE[i] <= BP_decision_DE[i];       // Mevcut dal tahmini kararını koru
                BP_en_DE[i] <= BP_en_DE[i];                   // Mevcut dal tahmini aktifleştiriciyi koru
            end
            else begin // Normal çalışma durumunda
                normal_DE[i] <= normal_F[i];                  // Fetch'ten gelen normal veriyi ata
                PC_out_DE[i] <= PC_out_F[i];                  // Fetch'ten gelen program sayacını ata
                InstructionMemory_out_DE[i] <= InstructionMemory_out_F[i]; // Fetch'ten gelen talimat belleği çıkışını ata
                BP_decision_DE[i] <= BP_decision_F[i];        // Fetch'ten gelen dal tahmini kararını ata
                BP_en_DE[i] <= BP_en_F[i];                    // Fetch'ten gelen dal tahmini aktifleştiriciyi ata
            end
        end
    end

endmodule

module Execute_Register (
    input  logic        clk,                              // Giriş: Saat sinyali
    input  logic        rst,                              // Giriş: Asenkron sıfırlama (negatif kenar)
    
    input  logic [31:0] normal_DE [1:0],                 // Giriş: Decode aşamasından normal veri, iki talimat için dizi [0] ve [1]
    input  logic [31:0] PC_out_DE [1:0],                 // Giriş: Decode aşamasından program sayacı, iki talimat için dizi [0] ve [1]
    input  logic [1:0]  program_counter_controller_DE [1:0], // Giriş: Program sayacı kontrolü, iki talimat için dizi [0] ve [1]
    input  logic [4:0]  shift_size_DE [1:0],             // Giriş: Kaydırma miktarı, iki talimat için dizi [0] ve [1]
    input  logic [4:0]  rd_DE [1:0],                     // Giriş: Hedef register adresi, iki talimat için dizi [0] ve [1]
    input  logic        rf_write_en_DE [1:0],            // Giriş: Register dosyası yazma izni, iki talimat için dizi [0] ve [1]
    input  logic        mem_read_en_DE [1:0],            // Giriş: Bellek okuma izni, iki talimat için dizi [0] ve [1]
    input  logic        mem_write_en_DE [1:0],           // Giriş: Bellek yazma izni, iki talimat için dizi [0] ve [1]
    input  logic [3:0]  alu_op_DE [1:0],                 // Giriş: ALU işlem kontrolü, iki talimat için dizi [0] ve [1]
    input  logic        JALR_en_DE [1:0],                // Giriş: JALR aktifleştirici, iki talimat için dizi [0] ve [1]
    input  logic        JAL_en_DE [1:0],                 // Giriş: JAL aktifleştirici, iki talimat için dizi [0] ve [1]
    input  logic [31:0] imm_sign_extender_out_DE [1:0],  // Giriş: İşaret genişletici çıkışı, iki talimat için dizi [0] ve [1]
    input  logic [31:0] rd1_DE [1:0],                    // Giriş: İlk register verisi, iki talimat için dizi [0] ve [1]
    input  logic [31:0] rd2_DE [1:0],                    // Giriş: İkinci register verisi, iki talimat için dizi [0] ve [1]
    input  logic [4:0]  rs1_DE [1:0],                    // Giriş: İlk kaynak register adresi, iki talimat için dizi [0] ve [1]
    input  logic [4:0]  rs2_DE [1:0],                    // Giriş: İkinci kaynak register adresi, iki talimat için dizi [0] ve [1]
    input  logic        sign_extender_en_DE [1:0],       // Giriş: İşaret genişletici aktifleştirici, iki talimat için dizi [0] ve [1]
    input  logic [2:0]  load_type_DE [1:0],              // Giriş: Yükleme tipi, iki talimat için dizi [0] ve [1]
    input  logic        flush_EX [1:0],                  // Giriş: Execute aşamasında sıfırlama sinyali, iki talimat için dizi [0] ve [1]
    input  logic        BP_decision_DE [1:0],            // Giriş: Decode aşamasından dal tahmini kararı, iki talimat için dizi [0] ve [1]
    input  logic        BP_en_DE [1:0],                  // Giriş: Decode aşamasından dal tahmini aktifleştirici, iki talimat için dizi [0] ve [1]
    
    output logic        sign_extender_en_EX [1:0],       // Çıkış: İşaret genişletici aktifleştirici, iki talimat için dizi [0] ve [1]
    output logic [31:0] normal_EX [1:0],                 // Çıkış: Execute aşamasına normal veri, iki talimat için dizi [0] ve [1]
    output logic [31:0] PC_out_EX [1:0],                 // Çıkış: Execute aşamasına program sayacı, iki talimat için dizi [0] ve [1]
    output logic [1:0]  program_counter_controller_EX [1:0], // Çıkış: Program sayacı kontrolü, iki talimat için dizi [0] ve [1]
    output logic [4:0]  shift_size_EX [1:0],             // Çıkış: Kaydırma miktarı, iki talimat için dizi [0] ve [1]
    output logic [4:0]  rd_EX [1:0],                     // Çıkış: Hedef register adresi, iki talimat için dizi [0] ve [1]
    output logic        rf_write_en_EX [1:0],            // Çıkış: Register dosyası yazma izni, iki talimat için dizi [0] ve [1]
    output logic        mem_read_en_EX [1:0],            // Çıkış: Bellek okuma izni, iki talimat için dizi [0] ve [1]
    output logic        mem_write_en_EX [1:0],           // Çıkış: Bellek yazma izni, iki talimat için dizi [0] ve [1]
    output logic [3:0]  alu_op_EX [1:0],                 // Çıkış: ALU işlem kontrolü, iki talimat için dizi [0] ve [1]
    output logic        JALR_en_EX [1:0],                // Çıkış: JALR aktifleştirici, iki talimat için dizi [0] ve [1]
    output logic        JAL_en_EX [1:0],                 // Çıkış: JAL aktifleştirici, iki talimat için dizi [0] ve [1]
    output logic [31:0] imm_sign_extender_out_EX [1:0],  // Çıkış: İşaret genişletici çıkışı, iki talimat için dizi [0] ve [1]
    output logic [31:0] rd1_EX [1:0],                    // Çıkış: İlk register verisi, iki talimat için dizi [0] ve [1]
    output logic [31:0] rd2_EX [1:0],                    // Çıkış: İkinci register verisi, iki talimat için dizi [0] ve [1]
    output logic [4:0]  rs1_EX [1:0],                    // Çıkış: İlk kaynak register adresi, iki talimat için dizi [0] ve [1]
    output logic [4:0]  rs2_EX [1:0],                    // Çıkış: İkinci kaynak register adresi, iki talimat için dizi [0] ve [1]
    output logic [2:0]  load_type_EX [1:0],              // Çıkış: Yükleme tipi, iki talimat için dizi [0] ve [1]
    output logic        BP_decision_EX [1:0],            // Çıkış: Execute aşamasına dal tahmini kararı, iki talimat için dizi [0] ve [1]
    output logic        BP_en_EX [1:0]                   // Çıkış: Execute aşamasına dal tahmini aktifleştirici, iki talimat için dizi [0] ve [1]
);

    integer i; // Döngü değişkeni

    always_ff @(posedge clk or negedge rst) begin
        for (i = 0; i < 2; i++) begin // Her iki talimat için ayrı atama yap
            if (!rst || flush_EX[i]) begin // Asenkron sıfırlama veya flush sinyali aktifse
                normal_EX[i] <= 32'd0;                    // Normal veriyi sıfırla
                PC_out_EX[i] <= 32'd0;                    // Program sayacını sıfırla
                program_counter_controller_EX[i] <= 2'd0; // Program sayacı kontrolünü sıfırla
                shift_size_EX[i] <= 5'd0;                 // Kaydırma miktarını sıfırla
                rd_EX[i] <= 5'd0;                         // Hedef register adresini sıfırla
                rf_write_en_EX[i] <= 1'b0;                // Register yazma iznini sıfırla
                mem_read_en_EX[i] <= 1'b0;                // Bellek okuma iznini sıfırla
                mem_write_en_EX[i] <= 1'b0;               // Bellek yazma iznini sıfırla
                alu_op_EX[i] <= 4'd0;                     // ALU işlem kontrolünü sıfırla
                JALR_en_EX[i] <= 1'b0;                    // JALR aktifleştiriciyi sıfırla
                JAL_en_EX[i] <= 1'b0;                     // JAL aktifleştiriciyi sıfırla
                imm_sign_extender_out_EX[i] <= 32'd0;     // İşaret genişletici çıkışını sıfırla
                rd1_EX[i] <= 32'd0;                       // İlk register verisini sıfırla
                rd2_EX[i] <= 32'd0;                       // İkinci register verisini sıfırla
                rs1_EX[i] <= 5'd0;                        // İlk kaynak register adresini sıfırla
                rs2_EX[i] <= 5'd0;                        // İkinci kaynak register adresini sıfırla
                sign_extender_en_EX[i] <= 1'b0;           // İşaret genişletici aktifleştiriciyi sıfırla
                load_type_EX[i] <= 3'd0;                  // Yükleme tipini sıfırla
                BP_decision_EX[i] <= 1'b0;                // Dal tahmini kararını sıfırla
                BP_en_EX[i] <= 1'b0;                      // Dal tahmini aktifleştiriciyi sıfırla
            end
            else begin // Normal çalışma durumunda
                normal_EX[i] <= normal_DE[i];                    // Decode'tan gelen normal veriyi ata
                PC_out_EX[i] <= PC_out_DE[i];                    // Decode'tan gelen program sayacını ata
                program_counter_controller_EX[i] <= program_counter_controller_DE[i]; // Decode'tan gelen PC kontrolünü ata
                shift_size_EX[i] <= shift_size_DE[i];            // Decode'tan gelen kaydırma miktarını ata
                rd_EX[i] <= rd_DE[i];                            // Decode'tan gelen hedef register adresini ata
                rf_write_en_EX[i] <= rf_write_en_DE[i];          // Decode'tan gelen yazma iznini ata
                mem_read_en_EX[i] <= mem_read_en_DE[i];          // Decode'tan gelen okuma iznini ata
                mem_write_en_EX[i] <= mem_write_en_DE[i];        // Decode'tan gelen yazma iznini ata
                alu_op_EX[i] <= alu_op_DE[i];                    // Decode'tan gelen ALU kontrolünü ata
                JALR_en_EX[i] <= JALR_en_DE[i];                  // Decode'tan gelen JALR sinyalini ata
                JAL_en_EX[i] <= JAL_en_DE[i];                    // Decode'tan gelen JAL sinyalini ata
                imm_sign_extender_out_EX[i] <= imm_sign_extender_out_DE[i]; // Decode'tan gelen genişletici çıkışını ata
                rd1_EX[i] <= rd1_DE[i];                          // Decode'tan gelen ilk register verisini ata
                rd2_EX[i] <= rd2_DE[i];                          // Decode'tan gelen ikinci register verisini ata
                rs1_EX[i] <= rs1_DE[i];                          // Decode'tan gelen ilk kaynak adresini ata
                rs2_EX[i] <= rs2_DE[i];                          // Decode'tan gelen ikinci kaynak adresini ata
                sign_extender_en_EX[i] <= sign_extender_en_DE[i]; // Decode'tan gelen genişletici sinyalini ata
                load_type_EX[i] <= load_type_DE[i];              // Decode'tan gelen yükleme tipini ata
                BP_decision_EX[i] <= BP_decision_DE[i];          // Decode'tan gelen dal tahmini kararını ata
                BP_en_EX[i] <= BP_en_DE[i];                      // Decode'tan gelen dal tahmini aktifleştiriciyi ata
            end
        end
    end

endmodule

module Memory_Register (
    input  logic        clk,                              // Giriş: Saat sinyali
    input  logic        rst,                              // Giriş: Asenkron sıfırlama (negatif kenar)
    input  logic [31:0] jump_EX [1:0],                   // Giriş: Execute aşamasından atlama adresi, iki talimat için dizi [0] ve [1]
    input  logic [31:0] branch_EX [1:0],                 // Giriş: Execute aşamasından dal adresi, iki talimat için dizi [0] ve [1]
    input  logic        branch_en_EX [1:0],              // Giriş: Execute aşamasından dal aktifleştirici, iki talimat için dizi [0] ve [1]
    input  logic [31:0] normal_EX [1:0],                 // Giriş: Execute aşamasından normal veri, iki talimat için dizi [0] ve [1]
    input  logic [31:0] PC_out_EX [1:0],                 // Giriş: Execute aşamasından program sayacı, iki talimat için dizi [0] ve [1]
    input  logic [1:0]  program_counter_controller_EX [1:0], // Giriş: Program sayacı kontrolü, iki talimat için dizi [0] ve [1]
    input  logic        alu_branch_control_EX [1:0],     // Giriş: ALU dal kontrol sinyali, iki talimat için dizi [0] ve [1]
    input  logic [4:0]  rd_EX [1:0],                     // Giriş: Hedef register adresi, iki talimat için dizi [0] ve [1]
    input  logic        rf_write_en_EX [1:0],            // Giriş: Register dosyası yazma izni, iki talimat için dizi [0] ve [1]
    input  logic        mem_read_en_EX [1:0],            // Giriş: Bellek okuma izni, iki talimat için dizi [0] ve [1]
    input  logic        mem_write_en_EX [1:0],           // Giriş: Bellek yazma izni, iki talimat için dizi [0] ve [1]
    input  logic [31:0] rd2_EX [1:0],                    // Giriş: İkinci register verisi (bellek yazma için), iki talimat için dizi [0] ve [1]
    input  logic [31:0] alu_out_EX [1:0],                // Giriş: ALU çıkışı, iki talimat için dizi [0] ve [1]
    input  logic [2:0]  load_type_EX [1:0],              // Giriş: Yükleme tipi, iki talimat için dizi [0] ve [1]
    
    output logic [31:0] alu_out_MEM [1:0],               // Çıkış: Memory aşamasına ALU çıkışı, iki talimat için dizi [0] ve [1]
    output logic [31:0] jump_MEM [1:0],                  // Çıkış: Memory aşamasına atlama adresi, iki talimat için dizi [0] ve [1]
    output logic [31:0] branch_MEM [1:0],                // Çıkış: Memory aşamasına dal adresi, iki talimat için dizi [0] ve [1]
    output logic        branch_en_MEM [1:0],             // Çıkış: Memory aşamasına dal aktifleştirici, iki talimat için dizi [0] ve [1]
    output logic [31:0] normal_MEM [1:0],                // Çıkış: Memory aşamasına normal veri, iki talimat için dizi [0] ve [1]
    output logic [31:0] PC_out_MEM [1:0],                // Çıkış: Memory aşamasına program sayacı, iki talimat için dizi [0] ve [1]
    output logic [1:0]  program_counter_controller_MEM [1:0], // Çıkış: Program sayacı kontrolü, iki talimat için dizi [0] ve [1]
    output logic        alu_branch_control_MEM [1:0],    // Çıkış: ALU dal kontrol sinyali, iki talimat için dizi [0] ve [1]
    output logic [4:0]  rd_MEM [1:0],                    // Çıkış: Hedef register adresi, iki talimat için dizi [0] ve [1]
    output logic        rf_write_en_MEM [1:0],           // Çıkış: Register dosyası yazma izni, iki talimat için dizi [0] ve [1]
    output logic        mem_read_en_MEM [1:0],           // Çıkış: Bellek okuma izni, iki talimat için dizi [0] ve [1]
    output logic        mem_write_en_MEM [1:0],          // Çıkış: Bellek yazma izni, iki talimat için dizi [0] ve [1]
    output logic [31:0] rd2_MEM [1:0],                   // Çıkış: İkinci register verisi (bellek yazma için), iki talimat için dizi [0] ve [1]
    output logic [2:0]  load_type_MEM [1:0]              // Çıkış: Yükleme tipi, iki talimat için dizi [0] ve [1]
);

    integer i; // Döngü değişkeni

    always_ff @(posedge clk or negedge rst) begin
        for (i = 0; i < 2; i++) begin // Her iki talimat için ayrı atama yap
            if (!rst) begin // Asenkron sıfırlama durumunda
                alu_out_MEM[i] <= 32'd0;                    // ALU çıkışını sıfırla
                jump_MEM[i] <= 32'd0;                       // Atlama adresini sıfırla
                branch_MEM[i] <= 32'd0;                     // Dal adresini sıfırla
                branch_en_MEM[i] <= 1'b0;                   // Dal aktifleştiriciyi sıfırla
                normal_MEM[i] <= 32'd0;                     // Normal veriyi sıfırla
                PC_out_MEM[i] <= 32'd0;                     // Program sayacını sıfırla
                program_counter_controller_MEM[i] <= 2'd0;  // Program sayacı kontrolünü sıfırla
                alu_branch_control_MEM[i] <= 1'b0;          // ALU dal kontrolünü sıfırla
                rd_MEM[i] <= 5'd0;                          // Hedef register adresini sıfırla
                rf_write_en_MEM[i] <= 1'b0;                 // Register yazma iznini sıfırla
                mem_read_en_MEM[i] <= 1'b0;                 // Bellek okuma iznini sıfırla
                mem_write_en_MEM[i] <= 1'b0;                // Bellek yazma iznini sıfırla
                rd2_MEM[i] <= 32'd0;                        // İkinci register verisini sıfırla
                load_type_MEM[i] <= 3'd0;                   // Yükleme tipini sıfırla
            end
            else begin // Normal çalışma durumunda
                alu_out_MEM[i] <= alu_out_EX[i];                    // Execute'tan gelen ALU çıkışını ata
                jump_MEM[i] <= jump_EX[i];                          // Execute'tan gelen atlama adresini ata
                branch_MEM[i] <= branch_EX[i];                      // Execute'tan gelen dal adresini ata
                branch_en_MEM[i] <= branch_en_EX[i];                // Execute'tan gelen dal aktifleştiriciyi ata
                normal_MEM[i] <= normal_EX[i];                      // Execute'tan gelen normal veriyi ata
                PC_out_MEM[i] <= PC_out_EX[i];                      // Execute'tan gelen program sayacını ata
                program_counter_controller_MEM[i] <= program_counter_controller_EX[i]; // Execute'tan gelen PC kontrolünü ata
                alu_branch_control_MEM[i] <= alu_branch_control_EX[i]; // Execute'tan gelen ALU dal kontrolünü ata
                rd_MEM[i] <= rd_EX[i];                              // Execute'tan gelen hedef register adresini ata
                rf_write_en_MEM[i] <= rf_write_en_EX[i];            // Execute'tan gelen yazma iznini ata
                mem_read_en_MEM[i] <= mem_read_en_EX[i];            // Execute'tan gelen okuma iznini ata
                mem_write_en_MEM[i] <= mem_write_en_EX[i];          // Execute'tan gelen yazma iznini ata
                rd2_MEM[i] <= rd2_EX[i];                            // Execute'tan gelen ikinci register verisini ata
                load_type_MEM[i] <= load_type_EX[i];                // Execute'tan gelen yükleme tipini ata
            end
        end
    end

endmodule

module WriteBack_Register (
    input  logic        clk,                              // Giriş: Saat sinyali
    input  logic        rst,                              // Giriş: Asenkron sıfırlama (negatif kenar)
    input  logic        branch_en_MEM [1:0],             // Giriş: Memory aşamasından dal aktifleştirici, iki talimat için dizi [0] ve [1]
    input  logic [3:0]  alu_branch_control_MEM [1:0],    // Giriş: ALU dal kontrol sinyali, iki talimat için dizi [0] ve [1]
    input  logic        mem_write_en_MEM [1:0],          // Giriş: Bellek yazma izni, iki talimat için dizi [0] ve [1]
    input  logic        mem_read_en_MEM [1:0],           // Giriş: Bellek okuma izni, iki talimat için dizi [0] ve [1]
    input  logic [31:0] rd2_MEM [1:0],                   // Giriş: İkinci register verisi, iki talimat için dizi [0] ve [1]
    input  logic [1:0]  program_counter_controller_MEM [1:0], // Giriş: Program sayacı kontrolü, iki talimat için dizi [0] ve [1]
    input  logic [4:0]  rd_MEM [1:0],                    // Giriş: Hedef register adresi, iki talimat için dizi [0] ve [1]
    input  logic        rf_write_en_MEM [1:0],           // Giriş: Register dosyası yazma izni, iki talimat için dizi [0] ve [1]
    input  logic [31:0] wd_MEM [1:0],                    // Giriş: Yazılacak veri, iki talimat için dizi [0] ve [1]
    input  logic [31:0] PC_out_MEM [1:0],                // Giriş: Program sayacı, iki talimat için dizi [0] ve [1]
    input  logic [31:0] normal_MEM [1:0],                // Giriş: Normal veri, iki talimat için dizi [0] ve [1]
    
    output logic [1:0]  program_counter_controller_WB [1:0], // Çıkış: Program sayacı kontrolü, iki talimat için dizi [0] ve [1]
    output logic [4:0]  rd_WB [1:0],                     // Çıkış: Hedef register adresi, iki talimat için dizi [0] ve [1]
    output logic        rf_write_en_WB [1:0],            // Çıkış: Register dosyası yazma izni, iki talimat için dizi [0] ve [1]
    output logic [31:0] wd_WB [1:0],                     // Çıkış: Yazılacak veri, iki talimat için dizi [0] ve [1]
    output logic [31:0] PC_out_WB [1:0],                 // Çıkış: Program sayacı, iki talimat için dizi [0] ve [1]
    output logic [31:0] normal_WB [1:0]                  // Çıkış: Normal veri, iki talimat için dizi [0] ve [1]
);

    integer i; // Döngü değişkeni

    always_ff @(posedge clk or negedge rst) begin
        for (i = 0; i < 2; i++) begin // Her iki talimat için ayrı atama yap
            if (!rst) begin // Asenkron sıfırlama durumunda
                program_counter_controller_WB[i] <= 2'd0;  // Program sayacı kontrolünü sıfırla
                rd_WB[i] <= 5'd0;                         // Hedef register adresini sıfırla
                rf_write_en_WB[i] <= 1'b0;                // Register yazma iznini sıfırla
                wd_WB[i] <= 32'd0;                        // Yazılacak veriyi sıfırla
                PC_out_WB[i] <= 32'd0;                    // Program sayacını sıfırla
                normal_WB[i] <= 32'd0;                    // Normal veriyi sıfırla
            end
            else begin // Normal çalışma durumunda
                program_counter_controller_WB[i] <= program_counter_controller_MEM[i]; // Memory'den gelen PC kontrolünü ata
                rd_WB[i] <= rd_MEM[i];                        // Memory'den gelen hedef register adresini ata
                rf_write_en_WB[i] <= rf_write_en_MEM[i];      // Memory'den gelen yazma iznini ata
                wd_WB[i] <= wd_MEM[i];                        // Memory'den gelen yazılacak veriyi ata
                PC_out_WB[i] <= PC_out_MEM[i];                // Memory'den gelen program sayacını ata
                normal_WB[i] <= normal_MEM[i];                // Memory'den gelen normal veriyi ata
            end
        end
    end

endmodule

