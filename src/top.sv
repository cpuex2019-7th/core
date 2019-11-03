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
   reg [31:0]         pc;
   reg                stalling_for_mem_forwarding;
   
   /////////////////////
   // stages
   /////////////////////
   
   // fetch
   /////////
   // controls
   reg                fetch_enabled;
   reg                fetch_reset;   
   wire               is_fetch_done;

   // pipeline regs
   // None
   
   // stage outputs
   wire [31:0]        pc_fd;
   wire [31:0]        instr_fd;
   
   fetch _fetch(.clk(clk),
                .rstn(rstn && !fetch_reset),
      
                .enabled(fetch_enabled),
                .pc(pc),

                .rom_addr(rom_addr),
                .rom_data(rom_data),

                .completed(is_fetch_done),
                .pc_n(pc_fd),
                .instr_raw(instr_fd));      

   // decode & reg
   /////////
   // control flags
   reg                decode_enabled;
   reg                decode_reset;   
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
                    .rstn(rstn && !decode_reset),                    
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
   regf _fregisters(.clk(clk), 
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
   reg                exec_reset;   
   wire               is_exec_done;
   
   // pipeline regs
   instructions instr_em;   
   regvpair register_em;
   regvpair fregister_em;
   
   // stage outputs
   wire [31:0]        result_em;
   wire               is_jump_chosen_em;
   wire [31:0]        jump_dest_em;   

   fwdregkv forwarding;
   execute _execute(.clk(clk), 
                    .rstn(rstn && !exec_reset),
      
                    .enabled(exec_enabled),
                    .instr(instr_de),
                    .register(register_de),
                    .fregister(fregister_de),
                    .forwarding(forwarding),
      
                    .completed(is_exec_done),
                    .instr_n(instr_em),
                    .register_n(register_em), 
                    .fregister_n(fregister_em),
      
                    .result(result_em), 
                    .is_jump_chosen(is_jump_chosen_em), 
                    .jump_dest(jump_dest_em));

   // mem
   /////////
   // control flags
   reg                mem_enabled;
   reg                mem_reset;   
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
            .rstn(rstn && !mem_reset),
      
            .enabled(mem_enabled),
            .instr(instr_em),
            .register(register_em),
            .fregister(fregister_em),
            .is_jump_chosen(is_jump_chosen_em),

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

            .completed(is_mem_done),
            .instr_n(instr_mw),
            .register_n(register_mw),                    
            .fregister_n(fregister_mw),
      
            .result(result_mw),
            .is_jump_chosen_n(is_jump_chosen_mw));
   
   
   // write
   /////////
   // control flags
   reg                write_enabled;
   reg                write_reset;
   
   wire               is_write_done;   

   // pipeline regs   
   wire               is_jump_chosen_wf;
   wire [31:0]        next_pc_wf;      
   write _write(.clk(clk), 
                .rstn(rstn && !write_reset),
      
                .enabled(write_enabled), 
                .instr(instr_mw),
                .is_jump_chosen(is_jump_chosen_mw),
      
                .data(result_mw),

                .reg_w_enable(reg_w_enable),
                .freg_w_enable(freg_w_enable),

                .reg_w_dest(reg_w_dest),
                .reg_w_data(reg_w_data),

                .completed(is_write_done),
                .is_jump_chosen_n(is_jump_chosen_wf));   

   wire               are_all_stages_completed = (fetch_reset || is_fetch_done) && (decode_reset && is_decode_done) && (exec_reset || is_exec_done) && (mem_reset || is_mem_done) && (write_reset || is_write_done);

   wire               reg_forwarding_required = (instr_de.use_reg 
                                                 && instr_em.writes_to_reg
                                                 && ((instr_de.rs1 != 0 && instr_de.rs1 == instr_em.rd)
                                                     || (instr_de.rs2 != 0 && instr_de.rs2 = instr_em.rd))) ;   
   wire               freg_forwarding_required = (instr_de.use_freg 
                                                  && instr_em.writes_to_freg
                                                  && (instr_de.rs1 == instr_em.rd 
                                                      || instr_de.rs2 = instr_em.rd));
   wire               forwarding_required = reg_forwarding_required || freg_forwarding_required;
   
   
   
   /////////////////////
   // main
   /////////////////////
   initial begin
      pc <= 0;
      
      fetch_enabled <= 1;      
      decode_enabled <= 0;      
      exec_enabled <= 0;      
      mem_enabled <= 0;      
      write_enabled <= 0;

      fetch_reset <= 0;
      decode_reset <= 0;
      exec_reset <= 0;
      mem_reset <= 0;
      write_reset <= 0;      
   end

   always @(posedge clk) begin
      if(rstn) begin
         if (are_all_stages_completed) begin
            // Control stalls
            //////////////////

            // case 00: 
            // mem->exec forwarding occurs when ...
            // 1. current instruction stored in instr_em is a load instruction
            // 2. the instruction stored in instr_de uses instr_em.rd as rs1, rs2, frs1 or frs2.
            // In the step 2, we have to care about the following point(s):
            // - if instr_de uses rs1 and rs2, zero register should not be forwarded.
            // In this case, we need to stall exec stage.

            // case 01:
            // exec->exec forwarding occurs when ...
            // 1. instr_de uses instr_em.rd as rs1, rs2, frs1, or frs2.
            // We have to make sure that zero register is not forwarded.

            // case 02:
            // If the situation does not match with case 00 and case 01, 
            // we do not have to forward any register.

            if (stalling_for_mem_forwarding) begin
               forwarding.enabled <= reg_forwarding_required;
               forwarding.enabled <= freg_forwarding_required;
               forwarding.key <= instr_mw.rd;
               forwarding.value <= result_mw;                              
               stalling_for_mem_forwarding <= 0;

               pc <= pc + 4;               
               
               fetch_enabled <= 1;
               fetch_reset <= 0;
               
               decode_enabled <= 1;
               decode_reset <= 0;
               
               exec_enabled <= 1;            
               exec_reset <= 0;   
            end else if (instr_em.is_load && forwarding_required) begin
               // case 00                  
               stalling_for_mem_forwarding <= 1;
               
               fetch_enabled <= 0;
               fetch_reset <= 0;
               
               decode_enabled <= 0;
               decode_reset <= 0;
               
               exec_enabled <= 0;               
               exec_reset <= 0;
            end else if (is_jump_chosen_em) begin
               pc <= jump_dest_em;
               
               fetch_enabled <= 1;
               fetch_reset <= 0;
               
               decode_enabled <= 0;
               decode_reset <= 1;
               
               exec_enabled <= 0;               
               exec_reset <= 1;
            end else begin
               // case 01 & 02
               forwarding.enabled <= reg_forwarding_required;                  
               forwarding.fenabled <= freg_forwarding_required;                  
               forwarding.key <= instr_em.rd;               
               forwarding.value <= result_em;                  
               stalling_for_mem_forwarding <= 0;
               
               pc <= pc + 4;               
               
               fetch_enabled <= 1;
               fetch_reset <= 0;
               
               decode_enabled <= is_fetch_done;
               decode_reset <= !is_fetch_done;
               
               exec_enabled <= is_decode_done;
               exec_reset <= !is_decode_done;
            end
                        
            mem_enabled <= is_exec_done;
            mem_reset <= !is_exec_done;
            
            write_enabled <= is_mem_done;
            write_reset <= !is_mem_done;
         end else begin
            fetch_enabled <= 0;
            decode_enabled <= 0;
            exec_enabled <= 0;
            mem_enabled <= 0;
            write_enabled <= 0;
         end
      end else begin
         pc <= 0;
      end
   end
endmodule
`default_nettype wire
