`default_nettype none

module execute
  (input wire clk,
   input wire         rstn,

   input wire [31:0]  pc,
   input              instructions instr,
   
   input wire [5:0]   rd,
   input wire [31:0]  rs1_v,
   input wire [31:0]  rs2_v,
   input wire [31:0]  imm,

   output wire [31:0] data,
   output reg         mem_write_enabled,
   output reg [31:0]  mem_write_dest,
   output reg         reg_write_enabled,
   output reg [5:0]   reg_write_dest,

   output reg         is_jump_enabled,
   output reg [31:0]  jump_dest);   

   always @(posedge clk) begin
      is_jump_enabled <= 0;
      mem_write_enabled <= 0;
      if(instr.addi) begin
         reg_write_enabled <= 1;
         reg_write_dest <= rd;
         data <= rs1_v + imm;
      end
   end
   
   always @(posedge clk) begin
      is_jump_enabled <= 0;      
      mem_write_enabled <= 0;     
      if(instr.add) begin
         reg_write_enabled <= 1;
         reg_write_dest <= rd;
         data <= rs1_v + rs2_v;
      end
   end

   always @(posedge clk) begin      
      mem_write_enabled <= 0;
      reg_write_enabled <= 0;      
      if(instr.beq) begin
         if (rs1_v == rs2_v) begin
            is_jump_enabled <= 1;            
         end else begin
            is_jump_enabled <= 0;            
         end         
      end
   end  

   always @(posedge clk) begin
      mem_write_enabled <= 0;
      if(instr.jal) begin
         reg_write_enabled <= 1;
         // TODO: when rd 
         reg_write_dest <= rd;         
         data <= pc + 4;

         is_jump_enabled <= 1;
         jump_dest <= pc + imm;         
      end
   end  
endmodule // execute
