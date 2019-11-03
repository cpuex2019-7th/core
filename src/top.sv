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
   wire [31:0]        pc_fd_out;
   wire [31:0]        instr_fd_out;
   
   fetch _fetch(.clk(clk),
                .rstn(rstn && !fetch_reset),
      
                .enabled(fetch_enabled),
                .pc(pc),

                .rom_addr(rom_addr),
                .rom_data(rom_data),

                .completed(is_fetch_done),
                .pc_n(pc_fd_out),
                .instr_raw(instr_fd_out));      

   // decode & reg
   /////////
   // control flags
   reg                decode_enabled;
   reg                decode_reset;   
   wire               is_decode_done;
   
   // pipeline regs
   // None
   
   // stage input
   reg [31:0]        pc_fd_in;
   reg [31:0]        instr_fd_in;
   task set_fd;      
      begin
         pc_fd_in <= pc_fd_out;
         instr_fd_in <= instr_fd_out;         
     end
   endtask
   
   // stage outputs
   instructions instr_de_out;   
   regvpair register_de_out;
   regvpair fregister_de_out;
   
   wire [4:0]         rs1_a;
   wire [4:0]         rs2_a;
   decoder _decoder(.clk(clk), 
                    .rstn(rstn && !decode_reset),                    
                    .enabled(decode_enabled),
                    
                    .pc(pc_fd_in),      
                    .instr_raw(instr_fd_in),                    
      
                    .completed(is_decode_done),
                    .instr(instr_de_out),
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
      
                   .register(register_de_out));   
   
   wire               freg_w_enable;   
   regf _fregisters(.clk(clk), 
                    .rstn(rstn),
                    .r_enabled(decode_enabled),
      
                    .w_enable(freg_w_enable),
                    .w_addr(reg_w_dest),
                    .w_data(reg_w_data),

                    .rs1(rs1_a),
                    .rs2(rs2_a),
      
                    .register(fregister_de_out));
   
   
   // exec
   /////////
   // control flags
   reg                exec_enabled;
   reg                exec_reset;   
   wire               is_exec_done;
   wire               is_exec_available = is_exec_done && !exec_reset;   
      
   // stage input
   instructions instr_de_in;   
   regvpair register_de_in;
   regvpair fregister_de_in;
   task set_de;      
      begin
         instr_de_in <= instr_de_out;
         register_de_in <= register_de_out;
         fregister_de_in <= fregister_de_out;         
     end
   endtask
   
   // stage outputs
   instructions instr_em_out;   
   regvpair register_em_out;
   regvpair fregister_em_out;
   wire [31:0]        result_em_out;
   wire               is_jump_chosen_em_out;
   wire [31:0]        jump_dest_em_out;   

   fwdregkv onestep_forwarding;
   fwdregkv twostep_forwarding;
   execute _execute(.clk(clk), 
                    .rstn(rstn && !exec_reset),
      
                    .enabled(exec_enabled),
                    .instr(instr_de_in),
                    .register(register_de_in),
                    .fregister(fregister_de_in),                    
                    .onestep_forwarding(onestep_forwarding),
                    .twostep_forwarding(twostep_forwarding),
      
                    .completed(is_exec_done),
                    
                    .instr_n(instr_em_out),
                    .register_n(register_em_out), 
                    .fregister_n(fregister_em_out),      
                    .result(result_em_out), 
                    .is_jump_chosen(is_jump_chosen_em_out), 
                    .jump_dest(jump_dest_em_out));

   // mem
   /////////
   // control flags
   reg                mem_enabled;
   reg                mem_reset;   
   wire               is_mem_done;

   // stage inputs
   instructions instr_em_in;   
   regvpair register_em_in;
   regvpair fregister_em_in;
   reg [31:0]        result_em_in;
   task set_em;      
      begin
         instr_em_in <= instr_em_out;
         register_em_in <= register_em_out;
         fregister_em_in <= fregister_em_out;
         result_em_in <= result_em_out;         
     end
   endtask
   
   // stage outputs
   instructions instr_mw_out;   
   wire [31:0]        result_mw_out;
   
   mem _mem(.clk(clk), 
            .rstn(rstn && !mem_reset),
      
            .enabled(mem_enabled),
            .instr(instr_em_in),
            .register(register_em_in),
            .fregister(fregister_em_in),
            .addr(result_em_in),

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
            
            .instr_n(instr_mw_out),
            .result(result_mw_out));
   
   
   
   // write
   /////////
   // control flags
   reg                write_enabled;
   reg                write_reset;
   
   wire               is_write_done;   

   // stage input
   instructions instr_mw_in;   
   reg [31:0]        result_mw_in;
   task set_mw;      
      begin
         instr_mw_in <= instr_mw_out;
         result_mw_in <= result_mw_out;         
     end
   endtask

   // there is no stage output
      
   write _write(.clk(clk), 
                .rstn(rstn && !write_reset),
      
                .enabled(write_enabled), 
                .instr(instr_mw_in),      
                .data(result_mw_in),

                .reg_w_enable(reg_w_enable),
                .freg_w_enable(freg_w_enable),

                .reg_w_dest(reg_w_dest),
                .reg_w_data(reg_w_data),

                .completed(is_write_done));
   

   wire               are_all_stages_completed = (fetch_reset || is_fetch_done) && (decode_reset || is_decode_done) && (exec_reset || is_exec_done) && (mem_reset || is_mem_done) && (write_reset || is_write_done);

   wire               reg_onestep_forwarding_required = (instr_de_out.uses_reg 
                                                 && instr_em_out.writes_to_reg
                                                 && ((instr_de_out.rs1 != 0 && instr_de_out.rs1 == instr_em_out.rd)
                                                     || (instr_de_out.rs2 != 0 && instr_de_out.rs2 == instr_em_out.rd))) ;   
   wire               freg_onestep_forwarding_required = (instr_de_out.uses_freg_as_rv32f 
                                                  && instr_em_out.writes_to_freg_as_rv32f
                                                  && (instr_de_out.rs1 == instr_em_out.rd 
                                                      || instr_de_out.rs2 == instr_em_out.rd));
   
   wire               reg_twostep_forwarding_required = (instr_de_out.uses_reg 
                                                 && instr_mw_out.writes_to_reg
                                                 && ((instr_de_out.rs1 != 0 && instr_de_out.rs1 == instr_mw_out.rd)
                                                     || (instr_de_out.rs2 != 0 && instr_de_out.rs2 == instr_mw_out.rd))) ;   
   wire               freg_twostep_forwarding_required = (instr_de_out.uses_freg_as_rv32f 
                                                  && instr_mw_out.writes_to_freg_as_rv32f
                                                  && (instr_de_out.rs1 == instr_mw_out.rd 
                                                      || instr_de_out.rs2 == instr_mw_out.rd));
   wire               onestep_forwarding_required = reg_onestep_forwarding_required || freg_onestep_forwarding_required;
   
   
   
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
      decode_reset <= 1;
      exec_reset <= 1;
      mem_reset <= 1;
      write_reset <= 1;      
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
               twostep_forwarding.enabled <= reg_twostep_forwarding_required;
               twostep_forwarding.enabled <= freg_twostep_forwarding_required;
               twostep_forwarding.key <= instr_mw_out.rd;
               twostep_forwarding.value <= result_mw_out;                              
               stalling_for_mem_forwarding <= 0;

               pc <= pc + 4;               
               
               fetch_enabled <= 1;
               fetch_reset <= 0;
               
               decode_enabled <= 1;
               decode_reset <= 0;
               set_fd();
               
               exec_enabled <= 1;            
               exec_reset <= 0;
               set_de();               
            end else if (instr_em_out.is_load && onestep_forwarding_required && is_exec_available) begin
               // case 00
               // here i use twostep_forwarding intendedly.
               onestep_forwarding.enabled <= reg_twostep_forwarding_required;                  
               onestep_forwarding.fenabled <= freg_twostep_forwarding_required;                  
               onestep_forwarding.key <= instr_mw_out.rd;               
               onestep_forwarding.value <= result_mw_out;
               stalling_for_mem_forwarding <= 1;
               
               fetch_enabled <= 0;
               fetch_reset <= 0;
               
               decode_enabled <= 0;
               decode_reset <= 0;
               // no set_fd();
               
               exec_enabled <= 0;               
               exec_reset <= 0;
               // no set_de();
            end else if (is_jump_chosen_em_out && is_exec_available) begin
               // when the branch prediction failed
               pc <= jump_dest_em_out;
               
               fetch_enabled <= 1;
               fetch_reset <= 0;
               
               decode_enabled <= 0;
               decode_reset <= 1;
               // no set_fd();
               
               exec_enabled <= 0;               
               exec_reset <= 1;
               // no set_de();
            end else begin
               // case 01 & 02
               onestep_forwarding.enabled <= reg_onestep_forwarding_required;                  
               onestep_forwarding.fenabled <= freg_onestep_forwarding_required;                  
               onestep_forwarding.key <= instr_em_out.rd;               
               onestep_forwarding.value <= result_em_out;
               
               twostep_forwarding.enabled <= reg_twostep_forwarding_required;                  
               twostep_forwarding.fenabled <= freg_twostep_forwarding_required;                  
               twostep_forwarding.key <= instr_mw_out.rd;               
               twostep_forwarding.value <= result_mw_out;                  
               stalling_for_mem_forwarding <= 0;
               
               pc <= pc + 4;               
               
               fetch_enabled <= 1;
               fetch_reset <= 0;
               
               decode_enabled <= is_fetch_done;
               decode_reset <= !is_fetch_done;
               set_fd();              
               
               exec_enabled <= is_decode_done;
               exec_reset <= !is_decode_done;
               set_de();              
            end
                        
            mem_enabled <= is_exec_done;
            mem_reset <= !is_exec_done;
            set_em();              
            
            write_enabled <= is_mem_done;
            write_reset <= !is_mem_done;
            set_mw();              
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
