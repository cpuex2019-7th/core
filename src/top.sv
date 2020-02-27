`default_nettype none
`include "def.sv"

module core
  (input wire clk, 
   input wire           rstn,

   // Bus for instr ROM
   output wire [31:0]   rom_addr,
   input wire [31:0]    rom_data,
  
   // Bus for RAM
   ////////////
   output wire [19-1:0] ram_addr,
   output wire          ram_clka,
   output wire [31:0]   ram_dina,
   input wire [31:0]    ram_douta,
   output wire          ram_ena,
   output wire          ram_rsta,
   output wire [3:0]    ram_wea,
  
   // Bus for UART buffer
   // address read channel
   output wire [31:0]   uart_axi_araddr,
   input wire           uart_axi_arready,
   output wire          uart_axi_arvalid,
   output wire [2:0]    uart_axi_arprot, 

   // response channel
   output wire          uart_axi_bready,
   input wire [1:0]     uart_axi_bresp,
   input wire           uart_axi_bvalid,

   // read data channel
   input wire [31:0]    uart_axi_rdata,
   output wire          uart_axi_rready,
   input wire [1:0]     uart_axi_rresp,
   input wire           uart_axi_rvalid,

   // address write channel
   output wire [31:0]   uart_axi_awaddr,
   input wire           uart_axi_awready,
   output wire          uart_axi_awvalid,
   output wire [2:0]    uart_axi_awprot, 

   // data write channel
   output wire [31:0]   uart_axi_wdata,
   input wire           uart_axi_wready,
   output wire [3:0]    uart_axi_wstrb,
   output wire          uart_axi_wvalid);
   
   
   /////////////////////
  // internals
   /////////////////////
   // TODO: use interface (including csr)
   reg [31:0]           pc;
   reg                  stalling_for_mem_forwarding;
   
   /////////////////////
   // stages
   /////////////////////
   
   // fetch
   /////////
   // controls
   reg                  fetch_enabled;
   reg                  fetch_reset;   
   wire                 is_fetch_done;

   // pipeline regs
   // None
   
   // stage outputs
   wire [31:0]          pc_fd_out;
   wire [31:0]          instr_fd_out;
   
   fetch _fetch(.clk(clk),
                .rstn(rstn && !fetch_reset),
      
                .enabled(fetch_enabled),
                .pc(pc),

                .rom_addr(rom_addr),
                .rom_data(rom_data),

                .completed(is_fetch_done),
                .pc_n(pc_fd_out),
                .instr_raw(instr_fd_out),
                .is_jump_predicted(is_jump_predicted_fd_out),
                .next_pc(next_pc_fd_out));      

   // decode & reg
   /////////
   // control flags
   reg                  decode_enabled;
   reg                  decode_reset;   
   wire                 is_decode_done;
   wire                 is_decode_available = is_decode_done && !decode_reset;   
   
   // pipeline regs
   // None
   
   // stage input
   reg [31:0]           pc_fd_in;
   reg [31:0]           instr_fd_in;
   
   // stage outputs
   instructions instr_de_out;   
   regvpair register_de_out;
   regvpair fregister_de_out;
   
   wire [4:0]           rs1_a;
   wire [4:0]           rs2_a;
   decoder _decoder(.clk(clk), 
                    .rstn(rstn && !decode_reset),                    
                    .enabled(decode_enabled),
      
                    .pc(pc_fd_in),      
                    .instr_raw(instr_fd_in),
                    .is_jump_predicted(is_jump_predicted_fd_in),
      
                    .completed(is_decode_done),
                    .instr(instr_de_out),
                    .rs1(rs1_a), .rs2(rs2_a));

   // registers
   wire [4:0]           reg_w_dest;
   wire [31:0]          reg_w_data;
   
   wire                 reg_w_enable;   
   regf _registers(.clk(clk), 
                   .rstn(rstn),
                   .r_enabled(decode_enabled),
      
                   .rs1(rs1_a),
                   .rs2(rs2_a),
      
                   .w_enable(reg_w_enable),
                   .w_addr(reg_w_dest),
                   .w_data(reg_w_data),
      
                   .register(register_de_out));   
   
   wire                 freg_w_enable;   
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
   reg                  exec_enabled;
   reg                  exec_reset;   
   wire                 is_exec_done;
   wire                 is_exec_available = is_exec_done && !exec_reset;   
   
   // stage input
   instructions instr_de_in;   
   regvpair register_de_in;
   regvpair fregister_de_in;
   
   // stage outputs
   instructions instr_em_out;   
   regvpair register_em_out;
   regvpair fregister_em_out;
   wire [31:0]          result_em_out;
   wire                 is_jump_chosen_em_out;
   wire [31:0]          jump_dest_em_out;   

   execute _execute(.clk(clk), 
                    .rstn(rstn && !exec_reset),
      
                    .enabled(exec_enabled),
                    .instr(instr_de_in),
                    .register(register_de_in),
                    .fregister(fregister_de_in),                    
      
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
   reg                  mem_enabled;
   reg                  mem_reset;   
   wire                 is_mem_done;
   wire                 is_mem_available = is_mem_done && !mem_reset;   

   // stage inputs
   instructions instr_em_in;   
   regvpair register_em_in;
   regvpair fregister_em_in;
   reg [31:0]           result_em_in;
   
   // stage outputs
   instructions instr_mw_out;   
   wire [31:0]          result_mw_out;
   
   mem _mem(.clk(clk), 
            .rstn(rstn && !mem_reset),
      
            .enabled(mem_enabled),
            .instr(instr_em_in),
            .register(register_em_in),
            .fregister(fregister_em_in),
            .addr(result_em_in),

            .ram_addr(ram_addr),
            .ram_clka(ram_clka),
            .ram_dina(ram_dina),
            .ram_douta(ram_douta),
            .ram_ena(ram_ena),
            .ram_rsta(ram_rsta),
            .ram_wea(ram_wea),
      
            .uart_axi_araddr(uart_axi_araddr), 
            .uart_axi_arready(uart_axi_arready), 
            .uart_axi_arvalid(uart_axi_arvalid),
            .uart_axi_arprot(uart_axi_arprot),
      
            .uart_axi_bready(uart_axi_bready),
            .uart_axi_bresp(uart_axi_bresp), 
            .uart_axi_bvalid(uart_axi_bvalid),
      
            .uart_axi_rdata(uart_axi_rdata), 
            .uart_axi_rready(uart_axi_rready), 
            .uart_axi_rresp(uart_axi_rresp),
            .uart_axi_rvalid(uart_axi_rvalid), 

            .uart_axi_awaddr(uart_axi_awaddr), 
            .uart_axi_awready(uart_axi_awready), 
            .uart_axi_awvalid(uart_axi_awvalid),
            .uart_axi_awprot(uart_axi_awprot),
      
            .uart_axi_wdata(uart_axi_wdata), 
            .uart_axi_wready(uart_axi_wready), 
            .uart_axi_wstrb(uart_axi_wstrb),
            .uart_axi_wvalid(uart_axi_wvalid),

            .completed(is_mem_done),
      
            .instr_n(instr_mw_out),
            .result(result_mw_out));
   
   // write
   /////////
   // control flags
   reg                  write_enabled;
   reg                  write_reset;   
   wire                 is_write_done;   

   // stage input
   instructions instr_mw_in;   
   reg [31:0]           result_mw_in;

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
   

   // forwarding flags
   /////////
   wire                 are_all_stages_completed = (fetch_reset || is_fetch_done) && (decode_reset || is_decode_done) && (exec_reset || is_exec_done) && (mem_reset || is_mem_done) && (write_reset || is_write_done);

   wire                 reg_onestep_forwarding_required = (instr_de_out.uses_reg 
                                                           && instr_em_out.writes_to_reg
                                                           && ((instr_de_out.rs1 != 0 && instr_de_out.rs1 == instr_em_out.rd)
                                                               || (instr_de_out.rs2 != 0 && instr_de_out.rs2 == instr_em_out.rd))) ;   
   wire                 freg_onestep_forwarding_required = (instr_de_out.uses_freg_as_rv32f 
                                                            && instr_em_out.writes_to_freg_as_rv32f
                                                            && (instr_de_out.rs1 == instr_em_out.rd 
                                                                || instr_de_out.rs2 == instr_em_out.rd));
   
   wire                 reg_twostep_forwarding_required = (instr_de_out.uses_reg 
                                                           && instr_mw_out.writes_to_reg
                                                           && ((instr_de_out.rs1 != 0 && instr_de_out.rs1 == instr_mw_out.rd)
                                                               || (instr_de_out.rs2 != 0 && instr_de_out.rs2 == instr_mw_out.rd))) ;   
   wire                 freg_twostep_forwarding_required = (instr_de_out.uses_freg_as_rv32f 
                                                            && instr_mw_out.writes_to_freg_as_rv32f
                                                            && (instr_de_out.rs1 == instr_mw_out.rd 
                                                                || instr_de_out.rs2 == instr_mw_out.rd));
   
   wire                 onestep_forwarding_required = reg_onestep_forwarding_required || freg_onestep_forwarding_required;

   reg [128:0]          total_executed_instrs;
   
   // branch prediction   
   /////////
   // TODO: this is conservative!
   reg [1:0]            branch_predict_buffer;
   reg                  last_predict_result;   
   wire                 branch_prediction_succeeded = (is_exec_available && (instr_em_out.jalr
                                                                             || instr_em_out.jal
                                                                             || (instr_em_out.is_conditional_jump 
                                                                                 && last_predict_result == is_jump_chosen_em_out)));
   
   wire                 is_branch_prediction_available = (is_decode_available &&
                                                          (instr_de_out.jal | instr_de_out.jalr || instr_de_out.is_conditional_jump));
   

   wire [31:0]          predicted_pc = (instr_de_out.jal ? instr_de_out.pc + $signed(instr_de_out.imm):
                                        instr_de_out.jalr? ((reg_onestep_forwarding_required 
                                                             && is_exec_available 
                                                             && instr_em_out.rd == instr_de_out.rs1)? result_em_out:
                                                            (reg_twostep_forwarding_required 
                                                             && is_mem_available 
                                                             && instr_mw_out.rd == instr_de_out.rs1)? result_mw_out:
                                                            register_de_out.rs1) + $signed(instr_de_out.imm):
                                        instr_de_out.is_conditional_jump? (branch_predict_buffer[1]? instr_de_out.pc + $signed(instr_de_out.imm):
                                                                           instr_de_out.pc + 4):
                                        32'b0);   
   wire [31:0]          predict_result = (instr_de_out.jal ? 1'b1:
                                          instr_de_out.jalr? 1'b1:
                                          instr_de_out.is_conditional_jump? branch_predict_buffer[1]:
                                          1'b0);   

   
   /////////////////////
   // tasks
   /////////////////////
   task init;
      begin
         pc <= 0;
         stalling_for_mem_forwarding <= 0;
         branch_predict_buffer <= 2'b00;
         
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

         total_executed_instrs  <= 0;         
      end
   endtask; 

   task set_fd;      
      begin
         pc_fd_in <= pc_fd_out;
         instr_fd_in <= instr_fd_out;
         is_jump_predicted_fd_in <= is_jump_predicted_fd_out;         
      end
   endtask

   task set_de;      
      begin
         instr_de_in <= instr_de_out;
         register_de_in.rs1 <= (reg_onestep_forwarding_required 
                                && is_exec_available 
                                && instr_em_out.rd == instr_de_out.rs1)? result_em_out:
                               (reg_twostep_forwarding_required 
                                && is_mem_available 
                                && instr_mw_out.rd == instr_de_out.rs1)? result_mw_out:
                               register_de_out.rs1;
         register_de_in.rs2 <= (reg_onestep_forwarding_required  
                                && is_exec_available 
                                && instr_em_out.rd == instr_de_out.rs2)? result_em_out:
                               (reg_twostep_forwarding_required 
                                && is_mem_available 
                                && instr_mw_out.rd == instr_de_out.rs2)? result_mw_out:
                               register_de_out.rs2;
         fregister_de_in.rs1 <= (freg_onestep_forwarding_required 
                                 && is_exec_available 
                                 && instr_em_out.rd == instr_de_out.rs1)? result_em_out:
                                (freg_twostep_forwarding_required 
                                 && is_mem_available 
                                 && instr_mw_out.rd == instr_de_out.rs1)? result_mw_out:
                                fregister_de_out.rs1;
         fregister_de_in.rs2 <= (freg_onestep_forwarding_required  
                                 && is_exec_available
                                 && instr_em_out.rd == instr_de_out.rs2)? result_em_out:
                                (freg_twostep_forwarding_required
                                 && is_mem_available
                                 && instr_mw_out.rd == instr_de_out.rs2)? result_mw_out:
                                fregister_de_out.rs2;
      end
   endtask
   
   task set_em;      
      begin
         instr_em_in <= instr_em_out;
         register_em_in <= register_em_out;
         fregister_em_in <= fregister_em_out;
         result_em_in <= result_em_out;         
      end
   endtask
   
   task set_mw;      
      begin
         instr_mw_in <= instr_mw_out;
         result_mw_in <= result_mw_out;         
      end
   endtask

   /////////////////////
   // main
   /////////////////////   
   initial begin
      init();      
   end

   always @(posedge clk) begin
      if(rstn) begin
         if (are_all_stages_completed) begin
            // Control stalls
            //////////////////
            
            // update branch predict buffer
            if (is_exec_available 
                && (instr_em_out.jalr || instr_em_out.jal || instr_em_out.is_conditional_jump)) begin
               case(branch_predict_buffer)
                 2'b00: begin
                    if (is_jump_chosen_em_out) begin
                       branch_predict_buffer <= 2'b01;                                              
                    end
                 end
                 2'b01: begin
                    if (is_jump_chosen_em_out) begin
                       branch_predict_buffer <= 2'b10;                                              
                    end else begin
                       branch_predict_buffer <= 2'b00;                                              
                    end
                 end
                 2'b10: begin
                    if (is_jump_chosen_em_out) begin
                       branch_predict_buffer <= 2'b11;                                              
                    end else begin
                       branch_predict_buffer <= 2'b01;                                              
                    end
                 end
                 2'b11: begin
                    if (!is_jump_chosen_em_out) begin
                       branch_predict_buffer <= 2'b10;                                              
                    end
                 end
               endcase
            end

            // update pc
            if (stalling_for_mem_forwarding) begin               
               stalling_for_mem_forwarding <= 0;
               
               if (is_branch_prediction_available && predict_result) begin
                  pc <= predicted_pc;
                  last_predict_result <= 1'b1;               

                  fetch_enabled <= 1;
                  fetch_reset <= 0;
                  
                  decode_enabled <= 0;               
                  decode_reset <= 1;               
                  // no set_fd(); fetch result will not used.
                  
                  exec_enabled <= 1;               
                  exec_reset <= 0;               
                  set_de();
               end else begin
                  pc <= pc + 4;               
                  last_predict_result <= 1'b0;               
                  
                  fetch_enabled <= 1;
                  fetch_reset <= 0;
                  
                  decode_enabled <= 1;
                  decode_reset <= 0;
                  set_fd();
                  
                  exec_enabled <= 1;            
                  exec_reset <= 0;
                  set_de();     
               end
            end else if (instr_em_out.is_load && onestep_forwarding_required && is_exec_available) begin
               // need to stall.
               stalling_for_mem_forwarding <= 1;
               
               fetch_enabled <= 0;
               fetch_reset <= 0; // this result will be used in next round
               
               decode_enabled <= 1;
               decode_reset <= 0;
               // no set_fd();
               
               exec_enabled <= 0;               
               exec_reset <= 1; // this result won't be used in the future anymore.
               // no set_de(); because decode stage should be done once more before set_de
            end else if ((instr_em_out.jalr || instr_em_out.jal || instr_em_out.is_conditional_jump)
                         && is_exec_available
                         && !branch_prediction_succeeded) begin
               // failed to predict branch!
               pc <= jump_dest_em_out;
               
               fetch_enabled <= 1;
               fetch_reset <= 0;
               
               decode_enabled <= 0;
               decode_reset <= 1;
               // no set_fd();
               
               exec_enabled <= 0;               
               exec_reset <= 1;
               // no set_de(); because there's no need to move
            end else if (is_branch_prediction_available && predict_result) begin
               // when we hit a branch instruction, we have to predict where to go...
               pc <= predicted_pc;
               last_predict_result <= 1'b1;               

               fetch_enabled <= 1;
               fetch_reset <= 0;
               
               decode_enabled <= 0;               
               decode_reset <= 1;               
               // no set_fd(); fetch result will not used.
               
               exec_enabled <= 1;               
               exec_reset <= 0;               
               set_de();
            end else begin
               pc <= pc + 4;
               last_predict_result <= 1'b0;              
               
               fetch_enabled <= 1;
               fetch_reset <= 0;
               
               decode_enabled <= is_fetch_done;
               decode_reset <= !is_fetch_done;
               set_fd();              
               
               exec_enabled <= is_decode_done;
               exec_reset <= !is_decode_done;
               set_de();
            end
            
            mem_enabled <= is_exec_available;            
            mem_reset <= !is_exec_available;
            set_em();              
            
            write_enabled <= is_mem_done;
            write_reset <= !is_mem_done;
            set_mw();

            if(is_write_done && !write_reset) begin
               total_executed_instrs <= total_executed_instrs + 1;               
            end      
            
            total_executed_instrs <=  total_executed_instrs + 1;     
         end else begin
            fetch_enabled <= 0;
            decode_enabled <= 0;
            exec_enabled <= 0;
            mem_enabled <= 0;
            write_enabled <= 0;
         end
      end else begin
         init();
      end
   end
endmodule
`default_nettype wire
