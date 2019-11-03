module write(
             input wire         clk,
             input wire         rstn,
             input wire         enabled,
             input wire         is_jump_chosen,

             input              instructions instr,
             input wire [31:0]  data,

             output wire        reg_w_enable,
             output wire        freg_w_enable,

             output wire [4:0]  reg_w_dest,
             output wire [31:0] reg_w_data,

             output reg         completed,
             output reg         is_jump_chosen_n);
   
  
   reg [1:0]                    state;
   
   assign reg_w_enable = enabled &&  instr.writes_to_reg;   
   assign freg_w_enable = enabled && instr.writes_to_freg_as_rv32f;

   assign reg_w_dest = instr.rd;
   assign reg_w_data = data;   

   initial begin
      state <= 0;
      completed <= 1;      
   end
   
   always @(posedge clk) begin
      if (rstn) begin
         if(enabled) begin
            is_jump_chosen_n <= is_jump_chosen;
            completed <= 1;
         end
      end else begin
         state <= 0;
         completed <= 0;         
      end
   end
   
endmodule
