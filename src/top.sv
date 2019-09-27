`include "def.sv"

module core
  (input wire clk, 
   input wire        rstn,

   // Bus for MMU
   // address read channel
   output reg [31:0] axi_araddr,
   input wire        axi_arready,
   output reg        axi_arvalid,

   // response channel
   output reg        axi_bready,
   input wire [1:0]  axi_bresp,
   input wire        axi_bvalid,

   // read data channel
   input wire [31:0] axi_rdata,
   output reg        axi_rready,
   input wire [1:0]  axi_rresp,
   input wire        axi_rvalid,

   // address write channel
   output reg [31:0] axi_awaddr,
   input wire        axi_awready,
   output reg        axi_awvalid,

   // data write channel
   output reg [31:0] axi_wdata,
   input wire        axi_wready,
   output reg [3:0]  axi_wstrb,
   output reg        axi_wvalid);
   
   /////////////////////
  // cpu internals
   /////////////////////
   // TODO: use interface (including csr)
   reg [31:0]        pc;
   reg [2:0]         state;

   /////////////////////
   // components
   /////////////////////
   wire [31:0]       instr_raw;   
   fetch _fetch(.clk(clk), 
                .rstn(rstn), 
                .pc(pc), 
                .state(state),
                .data(instr_raw));

   wire [4:0]        rd_a;
   wire [4:0]        rs1_a;
   wire [4:0]        rs2_a;
   wire [31:0]       imm;   
   instructions instr;   
   decoder _decoder(.clk(clk), 
                    .rstn(rstn),
                    .state(state),
                    .instr_raw(instr_raw),
                    .instr(instr),
                    .rd(rd_a), .rs1(rs1_a), .rs2(rs2_a), .imm(imm));
   
   wire [31:0]       rs1_v;
   wire [31:0]       rs2_v;
   wire              reg_write_enabled_delayed;
   wire [4:0]        reg_write_dest_delayed;
   wire [31:0]       reg_write_data_delayed;   
   regf _registers(.clk(clk), 
                   .rstn(rstn),
                   .rs1(rs1_a), .rs2(rs2_a), .rd1(rs1_v), .rd2(rs2_v), 
                   .w_enable(reg_write_enabled_delayed),
                   .w_addr(reg_write_dest_delayed),
                   .w_data(reg_write_data_delayed));
   
   reg [31:0]        pc_instr;
   wire [31:0]       exec_result;
   
   wire              mem_write_enabled;
   wire              mem_read_enabled;
   wire [31:0]       mem_target;
   
   wire              is_jump_enabled;
   wire [31:0]       jump_dest;   
   execute _execute(.clk(clk), .rstn(rstn), 
                    .state(state),
                    .pc(pc_instr), .instr(instr), 
                    .rd(rd_a),
                    .rs1(rs1_a), .rs1_v(rs1_v), 
                    .rs2(rs2_a), .rs2_v(rs2_v), 
                    .imm(imm), 
                    .result(exec_result), 
                    .mem_write_enabled(mem_write_enabled), .mem_read_enabled(mem_read_enabled), .mem_target(mem_target), 
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
      reg_write_enabled_delayed <= reg_write_enabled;
      reg_write_dest_delayed <= reg_write_dest;
      
      // TODO: select from mem read or mem write
      reg_write_data_delayed <= mem_read_enabled?  mem_input : exec_result;      
   end
   
   always @(posedge clk) begin
      if (state == FETCH) begin
         state <= DECODE;
      end else if (state == DECODE) begin
         pc_instr <= pc;         
         state <= EXEC;
      end else if (state == EXEC) begin
         state <= MEM;
      end else if (state == MEM) begin;
         // TODO: memory control
         
         if (is_jump_enabled) begin
            pc <= jump_dest;
            state <= FETCH;
         end else begin
            state <= WRITE;
         end          
      end else if (state == WRITE) begin         
         // TODO :thinking_face:
         pc <= pc + 4;                       
         state <= FETCH;
      end
   end
endmodule
