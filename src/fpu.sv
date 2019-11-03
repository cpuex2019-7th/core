`default_nettype none
`include "def.sv"

module fpu
  (input wire        clk,
   input wire         rstn,
     
   input              instructions instr,
   input              regvpair register,
   input              regvpair fregister,
   input              fwdregkv forwarding,

   output reg         completed,
   output wire [31:0] result);

   wire [31:0]        frs1 = forwarding.fenabled && forwarding.key == instr.rs1? forwarding.value : fregister.rs1;
   wire [31:0]        frs2 = forwarding.fenabled && forwarding.key == instr.rs2? forwarding.value : fregister.rs2;
   wire [31:0]        rs1 = forwarding.enabled && forwarding.key == instr.rs1? forwarding.value : register.rs1;
   wire [31:0]        rs2 = forwarding.enabled && forwarding.key == instr.rs2? forwarding.value : register.rs2;
      
   // connection with modules
   ///////////////
   wire [31:0]        fadd_result;
   wire               fadd_ovf;
   fadd _fadd(.x1(frs1), .x2(frs2), .y(fadd_result), .ovf(fadd_ovf));   
   
   wire [31:0]        fsub_result;
   wire               fsub_ovf;
   fsub _fsub(.x1(frs1), .x2(frs2), .y(fsub_result), .ovf(fsub_ovf));
   
   wire [31:0]        fmul_result;
   wire               fmul_ovf;
   fmul _fmul(.x1(frs1), .x2(frs2), .y(fmul_result), .ovf(fmul_ovf));
   
   wire [31:0]        fdiv_result;
   wire               fdiv_ovf;
   fdiv _fdiv(.x1(frs1), .x2(frs2), .y(fdiv_result), .ovf(fdiv_ovf));
   
   wire [31:0]        fsqrt_result;
   wire               fsqrt_ovf;
   fsqrt _fsqrt(.x(frs1), .y(fsqrt_result), .exception(fsqrt_ovf));
   
   wire [31:0]        fsgnj_result;
   wire               fsgnj_exception;
   fsgnj _fsgnj(.x1(frs1), .x2(frs2), .y(fsgnj_result), .exception(fsgnj_exception));
   
   wire [31:0]        fsgnjn_result;
   wire               fsgnjn_exception;
   fsgnjn _fsgnjn(.x1(frs1), .x2(frs2), .y(fsgnjn_result), .exception(fsgnjn_exception));
   
   wire [31:0]        fsgnjx_result;
   wire               fsgnjx_exception;
   fsgnjx _fsgnjx(.x1(frs1), .x2(frs2), .y(fsgnjx_result), .exception(fsgnjx_exception));

   wire [31:0]        fcvtws_result;
   wire               fcvtws_exception;
   fcvtws _fcvtws(.x(frs1), .y(fcvtws_result), .exception(fcvtws_exception));

   wire               feq_result;
   wire               feq_exception;
   feq _feq(.x1(frs1), .x2(frs2), .y(feq_result), .exception(feq_exception));
   
   wire               fle_result;
   wire               fle_exception;
   fle _fle(.x1(frs1), .x2(frs2), .y(fle_result), .exception(fle_exception));
   
   wire [31:0]        fcvtsw_result;
   fcvtsw _fcvtsw(.x(rs1), .y(fcvtsw_result));
   
   // implementation
   ///////////////
   assign result = instr.flw? $signed({1'b0, rs1}) + $signed(instr.imm):
                   instr.fsw? $signed({1'b0, rs1}) + $signed(instr.imm):
                   instr.fadd? fadd_result: 
                   instr.fsub? fsub_result: 
                   instr.fmul? fmul_result: 
                   instr.fdiv? fdiv_result: 
                   instr.fsqrt? fsqrt_result: 
                   instr.fsgnj? fsgnj_result: 
                   instr.fsgnjn? fsgnjn_result: 
                   instr.fsgnjx? fsgnjx_result: 
                   instr.fcvtws? fcvtws_result: 
                   instr.fmvxw? frs1: 
                   instr.feq? {31'b0, feq_result}: 
                   instr.fle? {31'b0, fle_result}: 
                   instr.fcvtsw? fcvtsw_result: 
                   instr.fmvwx? rs1:                    
                   31'b0;
   
   always @(posedge clk) begin
      completed <= 1;      
   end
   
endmodule
`default_nettype wire
