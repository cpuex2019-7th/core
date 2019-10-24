`default_nettype none
`include "def.sv"

module fpu
  (input wire        clk,
   input wire         rstn,
     
   input              instructions instr,

   input wire [31:0]  pc,
  
   input wire [31:0]  rs1_v,
   input wire [31:0]  rs2_v,
  
   input wire [31:0]  frs1_v,
   input wire [31:0]  frs2_v,
  
   input wire [31:0]  imm,

   output wire [31:0] result);
   
   // connection with modules
   ///////////////
   wire [31:0]        fadd_result;
   wire               fadd_ovf;
   fadd _fadd(.x1(frs1_v), .x2(frs2_v), .y(fadd_result), .ovf(fadd_ovf));   
   
   wire [31:0]        fsub_result;
   wire               fsub_ovf;
   fsub _fsub(.x1(frs1_v), .x2(frs2_v), .y(fsub_result), .ovf(fsub_ovf));
   
   wire [31:0]        fmul_result;
   wire               fmul_ovf;
   fmul _fmul(.x1(frs1_v), .x2(frs2_v), .y(fmul_result), .ovf(fmul_ovf));
   
   wire [31:0]        fdiv_result;
   wire               fdiv_ovf;
   fdiv _fdiv(.x1(frs1_v), .x2(frs2_v), .y(fdiv_result), .ovf(fdiv_ovf));
   
   wire [31:0]        fsqrt_result;
   wire               fsqrt_ovf;
   fsqrt _fsqrt(.x1(frs1_v), .y(fsqrt_result), .exception(fsqrt_ovf));
   
   wire [31:0]        fsgnj_result;
   wire               fsgnj_exception;
   fsgnj _fsgnj(.x1(frs1_v), .x2(frs2_v), .y(fsgnj_result), .exception(fsgnj_exception));
   
   wire [31:0]        fsgnjn_result;
   wire               fsgnjn_exception;
   fsgnjn _fsgnjn(.x1(frs1_v), .x2(frs2_v), .y(fsgnjn_result), .exception(fsgnjn_exception));
   
   wire [31:0]        fsgnjx_result;
   wire               fsgnjx_exception;
   fsgnjx _fsgnjx(.x1(frs1_v), .x2(frs2_v), .y(fsgnjx_result), .exception(fsgnjx_exception));

   wire [31:0]        fcvtws_result;
   wire               fcvtws_exception;
   fcvtws _fcvtws(.x1(frs1_v), .y(fcvtws_result), .exception(fcvtws_exception));

   wire [31:0]        feq_result;
   wire               feq_exception;
   feq _feq(.x1(frs1_v), .x2(frs2_v), .y(feq_result), .exception(feq_exception));
   
   wire [31:0]        fle_result;
   wire               fle_exception;
   fle _fle(.x1(frs1_v), .x2(frs2_v), .y(fle_result), .exception(fle_exception));
   
   wire [31:0]        fcvtsw_result;
   wire               fcvtsw_exception;
   fcvtsw _fcvtsw(.x1(rs1_v), .y(fcvtsw_result), .exception(fcvtsw_exception));
   
   // implementation
   ///////////////
   assign result = instr.flw? $signed({1'b0, rs1_v}) + $signed(imm):
                   instr.sw? $signed({1'b0, rs1_v}) + $signed(imm):
                   instr.fadd? fadd_result: 
                   instr.fsub? fsub_result: 
                   instr.fmul? fmul_result: 
                   instr.fdiv? fdiv_result: 
                   instr.fsqrt? fsqrt_result: 
                   instr.fsgnj? fsgnj_result: 
                   instr.fsgnjn? fsgnjn_result: 
                   instr.fsgnjx? fsgnjx_result: 
                   instr.fcvtws? fcvtws_result: 
                   instr.fmvxw? frs1_v: 
                   instr.feq? feq_result: 
                   instr.fle? fle_result: 
                   instr.fcvtsw? fcvtsw_result: 
                   instr.fmvwx? rs1_v:                    
                   31'b0;      
endmodule
`default_nettype wire
