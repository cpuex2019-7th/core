`default_nettype none
`include "def.sv"

module core
  (input wire clk, 
   input wire         rstn,

   // Bus for instr ROM
   output wire [31:0] rom_addr,
   input wire [31:0]  rom_data,
  
   // Bus for MMU
   // address read channel
   output reg [31:0]  axi_araddr,
   input wire         axi_arready,
   output reg         axi_arvalid,
   output reg [2:0]   axi_arprot, 

   // response channel
   output reg         axi_bready,
   input wire [1:0]   axi_bresp,
   input wire         axi_bvalid,

   // read data channel
   input wire [31:0]  axi_rdata,
   output reg         axi_rready,
   input wire [1:0]   axi_rresp,
   input wire         axi_rvalid,

   // address write channel
   output reg [31:0]  axi_awaddr,
   input wire         axi_awready,
   output reg         axi_awvalid,
   output reg [2:0]   axi_awprot, 

   // data write channel
   output reg [31:0]  axi_wdata,
   input wire         axi_wready,
   output reg [3:0]   axi_wstrb,
   output reg         axi_wvalid);
   
   
   /////////////////////
  // internals
   /////////////////////
   // TODO: use interface (including csr)
   reg [2:0]          state;
   assign debug_state = state;   
   reg [31:0]         pc;

   
   /////////////////////
   // stages
   /////////////////////
   
   // fetch
   /////////
   // controls
   reg                fetch_enabled;   
   wire               is_fetch_done;

   // pipeline regs
   // None
   
   // stage outputs
   wire [31:0]        pc_fd;
   wire [31:0]        instr_fd;
   
   fetch _fetch(.clk(clk),
                .rstn(rstn),
      
                .enabled(fetch_enabled),
                .pc(pc),

                .rom_addr(rom_addr)
                .rom_data(rom_data)

                .completed(is_fetch_done),
                .pc_n(pc_fd)
                .instr_raw(instr_fd));      

   // decode & reg
   /////////
   // control flags
   reg                decode_enabled;   
   wire               is_decode_done;
   
   // pipeline regs
   // None
   
   // stage outputs
   instructions instr_de;   
   regvpair register_de;
   regvpair fregister_de;
   
   wire [4:0]         rs1_a;
   wire [4:0]         rs2_a;
   decoder _decoder(.clk(clk), 
                    .rstn(rstn),                    
                    .enabled(decode_enabled),
                    .pc(pc_fd),
      
                    .instr_raw(instr_fd),                    
      
                    .completed(is_decode_done),
                    .instr(instr_de),
                    .rs1(rs1_a), .rs2(rs2_a));

   // registers
   wire [4:0]         reg_w_dest;
   wire [31:0]        reg_w_data;
   
   wire               reg_w_enable;   
   regf _registers(.clk(clk), 
                   .rstn(rstn),
                   .r_enabled(decode_enabled),
      
                   .rs1(rs1_a),
                   .rs2(rs2_a),
      
                   .w_enable(reg_w_enable),
                   .w_addr(reg_w_dest),
                   .w_data(reg_w_data),
      
                   .register(register_de));   
   
   wire               freg_w_enable;   
   regf _registers(.clk(clk), 
                   .rstn(rstn),
                   .r_enabled(decode_enabled),
      
                   .w_enable(freg_w_enable),
                   .w_addr(reg_w_dest),
                   .w_data(reg_w_data),

                   .rs1(rs1_a),
                   .rs2(rs2_a),
      
                   .register(fregister_de));
   
   
   // exec
   /////////
   // control flags
   reg                exec_enabled;
   wire               is_exec_done;
   
   // pipeline regs
   instructions instr_em;   
   regvpair register_em;
   regvpair fregister_em;
   
   // stage outputs
   wire [31:0]        result_em;
   wire               is_jump_chosen_em;
   wire [31:0]        next_pc_em;
   
   execute _execute(.clk(clk), 
                    .rstn(rstn),
      
                    .enabled(exec_enabled),
                    .instr(instr_de),
                    .register(regsiter_de),
                    .fregister(fregsiter_de),
      
                    .completed(is_exec_done),
                    .instr_n(instr_em),
                    .register_n(regsiter_em), 
                    .fregister_n(fregsiter_em),
      
                    .result(result_em), 
                    .is_jump_chosen(is_jump_chosen_em), 
                    .next_pc(next_pc_em));

   // mem
   /////////
   // control flags
   reg                mem_enabled;
   wire               is_mem_done;

   // pipeline regs
   instructions instr_mw;   
   regvpair register_mw;
   regvpair fregister_mw;
   wire               is_jump_chosen_mw;
   wire [31:0]        next_pc_mw;

   // stage outputs
   wire [31:0]        result_mw;
   
   mem _mem(.clk(clk), 
            .rstn(rstn),
      
            .enabled(mem_enabled),
            .instr(instr_em),
            .register(regsiter_em),
            .fregister(fregsiter_em),
            .is_jump_chosen(is_jump_chosen_em),
            .next_pc(next_pc_em),

            .addr(result_em),

            .axi_araddr(axi_araddr), 
            .axi_arready(axi_arready), 
            .axi_arvalid(axi_arvalid), 
            .axi_arprot(axi_arprot),
      
            .axi_bready(axi_bready), 
            .axi_bresp(axi_bresp), 
            .axi_bvalid(axi_bvalid),
      
            .axi_rdata(axi_rdata), 
            .axi_rready(axi_rready),
            .axi_rresp(axi_rresp), 
            .axi_rvalid(axi_rvalid),
      
            .axi_awaddr(axi_awaddr), 
            .axi_awready(axi_awready), 
            .axi_awvalid(axi_awvalid), 
            .axi_awprot(axi_awprot), 

            .axi_wdata(axi_wdata), 
            .axi_wready(axi_wready), 
            .axi_wstrb(axi_wstrb), 
            .axi_wvalid(axi_wvalid),

            .completed(is_mem_done);
            .instr_n(instr_mw),
            .register_n(regsiter_mw),                    
            .fregister_n(fregsiter_mw),
      
            .result(result_mw),
            .is_jump_chosen_n(is_jump_chosen_mw), 
            .next_pc_n(next_pc_mw));
   
   // write
   /////////
   // control flags
   reg                write_enabled;   
   wire               is_write_done;

   // pipeline regs   
   wire               is_jump_chosen_wf;
   wire [31:0]        next_pc_wf;      
   write _write(.clk(clk), 
                .rstn(rstn),
      
                .enabled(write_enabled), 
                .instr(instr_mw),
                .is_jump_chosen(is_jump_chosen_mw),
                .next_pc(next_pc_mw),
      
                .result(result_mw),

                .reg_w_enable(reg_w_enable),
                .freg_w_enable(freg_w_enable),

                .reg_w_dest(reg_w_dest),
                .reg_w_data(reg_w_data),

                .completed(is_write_done),
                .is_jump_chosen_n(is_jump_chosen_wf), 
                .next_pc_n(next_pc_wf));
   
   /////////////////////
   // main
   /////////////////////
   initial begin
      pc <= 0;
      state <= FETCH;
      fetch_enabled <= 1;      
   end

   always @(posedge clk) begin
      if(rstn) begin
         if (state == FETCH) begin
            fetch_enabled <= 0;            
            if (is_fetch_done) begin
               state <= DECODE;
               decode_enabled <= 1;
            end
         end else if (state == DECODE) begin
            decode_enabled <= 0;            
            if (is_decode_done) begin
               state <= EXEC;
               exec_enabled <= 1;
            end
         end else if (state == EXEC) begin
            exec_enabled <= 0;            
            if (is_exec_done) begin            
               state <= MEM;
               mem_enabled <= 1;
            end
         end else if (state == MEM) begin;
            mem_enabled <= 0;            
            if (is_mem_done) begin
               state <= WRITE;
               write_enabled <= 1;
            end
         end else if (state == WRITE) begin
            write_enabled <= 0;            
            if (is_write_done) begin
               pc <= next_pc_wf;
               state <= FETCH;
               fetch_enabled <= 1;
            end
         end
      end else begin
         pc <= 0;
         state <= FETCH;
         fetch_enabled <= 1;         
      end
   end
endmodule
`default_nettype wire
