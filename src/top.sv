module core
  (input wire clk, 
   input wire  rstn,
   output wire test);

   /////////////////////
   // constants 
   /////////////////////
   // states
   localparam [2:0] FETCH = 3'b000;
   localparam [2:0] DECODE = 3'b001;
   localparam [2:0] EXEC = 3'b010;
   localparam [2:0] WRITE = 3'b011;

   reg [2:0]   state;
   
   /////////////////////
   // cpu internals
   /////////////////////
   // TODO: use interface (including csr)
   reg [31:0]  pc;

   /////////////////////
   // components
   /////////////////////
   wire [31:0] instr_raw;   
   fetch _fetch(clk, rstn, 
                pc, instr_raw);

   wire [4:0]  rd_a;
   wire [4:0]  rs1_a;
   wire [4:0]  rs2_a;
   wire [31:0] imm;   
   instructions instr;   
   decoder _decoder(.clk(clk), 
                    .rstn(rstn), 
                    .instr_raw(instr_raw),
                    .instr(instr),
                    .rd(rd_a), .rs1(rs1_a), .rs2(rs2_a), .imm(imm));
   
   wire [31:0] rs1_v;
   wire [31:0] rs2_v;
   wire        reg_write_enabled;
   wire [4:0]  reg_write_dest;
   wire [31:0] data;   
   regf _registers(.clk(clk), 
                   .rstn(rstn),
                   .rs1(rs1_a), .rs2(rs2_a), .rd1(rs1_v), .rd2(rs2_v), 
                   .w_enable(reg_write_enabled), .w_addr(reg_write_dest), .w_data(data));

   reg [31:0]  pc_instr;   
   wire        mem_write_enabled;
   wire [31:0] mem_write_dest;
   wire        is_jump_enabled;
   wire [31:0] jump_dest;   
   execute _execute(.clk(clk), .rstn(rstn), 
                    .pc(pc_instr), .instr(instr), 
                    .rd(rd_a),
                    .rs1(rs1_a), .rs1_v(rs1_v), 
                    .rs2(rs2_a), .rs2_v(rs2_v), 
                    .imm(imm), 
                    .result(data), 
                    .mem_write_enabled(mem_write_enabled), .mem_write_dest(mem_write_dest), 
                    .reg_write_enabled(reg_write_enabled), .reg_write_dest(reg_write_dest), 
                    .is_jump_enabled(is_jump_enabled), .jump_dest(jump_dest));
   
   /////////////////////
   // main
   /////////////////////
   initial begin
      pc <= 0;
      state <= FETCH;
   end 
   
   always @(posedge clk) begin
      if (state == FETCH) begin
         state <= DECODE;
      end else if (state == DECODE) begin
         pc_instr <= pc;         
         state <= EXEC;
      end else if (state == EXEC) begin
         state <= WRITE;         
      end else if (state == WRITE) begin         
         // TODO :thinking_face:
         pc <= is_jump_enabled ? jump_dest : pc + 4;                       
         state <= FETCH;
      end
   end
endmodule
