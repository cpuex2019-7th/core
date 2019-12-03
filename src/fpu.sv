`default_nettype none
`include "def.sv"

module fpu
  (input wire        clk,
   input wire        rstn,
   input wire        enabled,
  
   input             instructions instr,
   input             regvpair register,
   input             regvpair fregister,

   output reg        completed,
   output reg [31:0] result);

   
   // connection with modules
   ///////////////
   wire              flw_completed = enabled;
   wire              fsw_completed = enabled;
   
   wire [31:0]       fadd_result;
   wire              fadd_ovf;
   wire              fadd_completed;
   fadd _fadd(.clk(clk), .rstn(rstn),
              .x1(fregister.rs1), .x2(fregister.rs2),
              .enable_in(enabled  && instr.fadd),
              .enable_out(fadd_completed),                
              .y(fadd_result), .ovf(fadd_ovf));
   
   wire [31:0]       fsub_result;
   wire              fsub_ovf;
   wire              fsub_completed;
   fsub _fsub(.clk(clk), .rstn(rstn),
              .x1(fregister.rs1), .x2(fregister.rs2),
              .enable_in(enabled  && instr.fsub),
              .enable_out(fsub_completed),                
              .y(fsub_result), .ovf(fsub_ovf));
   
   wire [31:0]       fmul_result;
   wire              fmul_ovf;
   wire              fmul_completed = enabled;
   fmul _fmul(.x1(fregister.rs1), .x2(fregister.rs2), .y(fmul_result), .ovf(fmul_ovf));
   
   wire [31:0]       fdiv_result;
   wire              fdiv_ovf;
   wire              fdiv_completed;
   fdiv _fdiv(.clk(clk), .rstn(rstn),
              .x1(fregister.rs1), .x2(fregister.rs2),
              .enable_in(enabled  && instr.fdiv),
              .enable_out(fdiv_completed),                
              .y(fdiv_result), .ovf(fdiv_ovf));
   
   wire [31:0]       fsqrt_result;
   wire              fsqrt_ovf;
   wire              fsqrt_completed;
   fsqrt _fsqrt(.clk(clk), .rstn(rstn),
                .x(fregister.rs1),
                .enable_in(enabled && instr.fsqrt),
                .enable_out(fsqrt_completed),                
                .y(fsqrt_result), .exception(fsqrt_ovf));
   
   wire [31:0]       fsgnj_result;
   wire              fsgnj_exception;
   wire              fsgnj_completed = enabled;
   fsgnj _fsgnj(.x1(fregister.rs1), .x2(fregister.rs2), .y(fsgnj_result), .exception(fsgnj_exception));
   
   wire [31:0]       fsgnjn_result;
   wire              fsgnjn_exception;
   wire              fsgnjn_completed = enabled;
   fsgnjn _fsgnjn(.x1(fregister.rs1), .x2(fregister.rs2), .y(fsgnjn_result), .exception(fsgnjn_exception));
   
   wire [31:0]       fsgnjx_result;
   wire              fsgnjx_exception;
   wire              fsgnjx_completed = enabled;
   fsgnjx _fsgnjx(.x1(fregister.rs1), .x2(fregister.rs2), .y(fsgnjx_result), .exception(fsgnjx_exception));

   wire [31:0]       fcvtws_result;
   wire              fcvtws_exception;
   wire              fcvtws_completed = enabled;
   fcvtws _fcvtws(.x(fregister.rs1), .y(fcvtws_result), .exception(fcvtws_exception));

   wire              feq_result;
   wire              feq_exception;
   wire              feq_completed = enabled;
   feq _feq(.x1(fregister.rs1), .x2(fregister.rs2), .y(feq_result), .exception(feq_exception));
   
   wire              fle_result;
   wire              fle_exception;
   wire              fle_completed = enabled;
   fle _fle(.x1(fregister.rs1), .x2(fregister.rs2), .y(fle_result), .exception(fle_exception));
   
   wire [31:0]       fcvtsw_result;
   wire              fcvtsw_completed = enabled;
   fcvtsw _fcvtsw(.x(register.rs1), .y(fcvtsw_result));
   
   wire              fmvxw_completed = enabled;
   wire              fmvwx_completed = enabled;
   
   // implementation
   ///////////////
   wire [31:0]       _result = instr.flw? $signed({1'b0, register.rs1}) + $signed(instr.imm):
                     instr.fsw? $signed({1'b0, register.rs1}) + $signed(instr.imm):
                     instr.fadd? fadd_result: 
                     instr.fsub? fsub_result: 
                     instr.fmul? fmul_result: 
                     instr.fdiv? fdiv_result: 
                     instr.fsqrt? fsqrt_result: 
                     instr.fsgnj? fsgnj_result: 
                     instr.fsgnjn? fsgnjn_result: 
                     instr.fsgnjx? fsgnjx_result: 
                     instr.fcvtws? fcvtws_result: 
                     instr.fmvxw? fregister.rs1: 
                     instr.feq? {31'b0, feq_result}: 
                     instr.fle? {31'b0, fle_result}: 
                     instr.fcvtsw? fcvtsw_result: 
                     instr.fmvwx? register.rs1:                    
                     31'b0;
   
   wire              _completed = (instr.flw? flw_completed:
                                   instr.fsw? fsw_completed:
                                   instr.fadd? fadd_completed: 
                                   instr.fsub? fsub_completed: 
                                   instr.fmul? fmul_completed: 
                                   instr.fdiv? fdiv_completed: 
                                   instr.fsqrt? fsqrt_completed: 
                                   instr.fsgnj? fsgnj_completed: 
                                   instr.fsgnjn? fsgnjn_completed: 
                                   instr.fsgnjx? fsgnjx_completed: 
                                   instr.fcvtws? fcvtws_completed: 
                                   instr.fmvxw? fmvxw_completed: 
                                   instr.feq? feq_completed: 
                                   instr.fle? fle_completed: 
                                   instr.fcvtsw? fcvtsw_completed:
                                   instr.fmvwx? fmvwx_completed:                    
                                   31'b0);
   
   always @(posedge clk) begin
      if (rstn) begin
         if(enabled && !_completed) begin
            completed <= 1'b0;            
         end else if (_completed) begin
            result <= _result;            
            completed <= 1'b1;            
         end
      end else begin
         completed <= 0;         
      end
   end
   
endmodule
`default_nettype wire
