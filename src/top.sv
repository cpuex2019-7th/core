`default_nettype none

module core
  (input wire clk, 
   input wire rstn);

   /////////////////////
   // constants 
   /////////////////////
   // states
   localparam [2:0] FETCH = 3'b000;
   localparam [2:0] DECODE = 3'b001;
   localparam [2:0] EXEC = 3'b010;
   localparam [2:0] WRITE = 3'b011;

   reg [2:0]  state;
   
   /////////////////////
   // cpu internals
   /////////////////////
   // TODO: use interface (including csr)
   reg [31:0] pc;

   /////////////////////
   // pipeline registers
   /////////////////////   
   // fetch-decode
   reg [31:0] instr_raw;   

   // decode-exec
   input instructions instr;
   reg [4:0]  rd;
   reg [31:0] rs1_v;
   reg [31:0] rs2_v;   
   reg [31:0] imm;

   reg [31:0] pc_instr;
   
   // exec-write
   reg        mem_write_enable;
   reg [5:0]  mem_write_dest;
   reg        reg_write_enable;
   reg [5:0]  reg_write_dest;
   reg [31:0] data;
   
   reg        is_jump_enabled;
   reg [31:0] jump_dest;      
   
   /////////////////////
   // components
   /////////////////////
   regf _registers(clk, rstn,
                   rs1_o, rs2_o, rs1_vo, rs2_vo, 
                   reg_write_enable, reg_write_dest, data);   
   
   fetch _fetch(clk, rstn, 
                pc, instr_o);
   
   decoder _decoder(clk, rstn, 
                    instr_raw, 
                    rd_o, rs1_o, rs2_o, imm_o, instr_o);
   
   execute _execute(clk, rstn, 
                    pc_instr, instr, rd, rs1, rs2, imm, 
                    data_o, mem_write_enable_o, mem_write_dest_o, reg_write_enable_o, reg_write_dest_o, 
                    is_jump_enabled_o, jump_dest_o);
   
   /////////////////////
   // main
   /////////////////////
   always @(posedge clk) begin
      if (state == FETCH) begin
         instr_raw <= instr_o;
         
         state <= DECODE;
      end else if (state == DECODE) begin
         rd <= rd_o;
         rs1_v <= rs1_vo;
         rs2_v <= rs2_vo;
         imm <= imm_o;
         instr <= instr_o;

         pc_instr <= pc;         
         
         state <= EXEC;
      end else if (state == EXEC) begin
         mem_write_enable <= mem_write_enable_o;
         mem_write_enable <= mem_write_enable_o;
         reg_write_enable <= reg_write_enable_o;
         reg_write_enable <= reg_write_enable_o;
         data <= data_o;

         is_jump_enabled <= is_jump_enabled_o;
         jump_dest <= jump_dest_o;         
         
         state <= WRITE;         
      end else if (state == WRITE) begin
         mem_write_enable <= 0;
         reg_write_enable <= 0;

         // TODO :thinking_face:
         pc <= is_jump_enabled ? jump_dest : pc + 4;                       
         state <= FETCH;
      end
   end
endmodule
