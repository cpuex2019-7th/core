`default_nettype none
`include "def.sv"

module core
  (input wire clk, 
   input wire        rstn,
   output reg [31:0] pc,
   input wire [31:0] instr_raw_from_mem,
  
   // Bus for MMU
   // address read channel
   output reg [31:0] axi_araddr,
   input wire        axi_arready,
   output reg        axi_arvalid,
   output reg [2:0]  axi_arprot, 

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
   output reg [2:0]  axi_awprot, 

   // data write channel
   output reg [31:0] axi_wdata,
   input wire        axi_wready,
   output reg [3:0]  axi_wstrb,
   output reg        axi_wvalid,
  
   // for debug
   output wire [2:0] debug_state,
   output wire [2:0] debug_mem_state);
   
   /////////////////////
    // cpu internals
   /////////////////////
   // TODO: use interface (including csr)
   (* mark_debug = "true" *) reg [2:0]         state;
   assign debug_state = state;   

   localparam mem_r_init = 0;   
   localparam mem_r_waiting_ready = 1;
   localparam mem_r_waiting_data = 2;

   localparam mem_w_init = 0;
   localparam mem_w_waiting_ready = 1;
   localparam mem_w_waiting_data = 2;   
   (* mark_debug = "true" *) reg [2:0]         mem_state;
   assign debug_mem_state = mem_state;      
   
   /////////////////////
   // components
   /////////////////////
   (* mark_debug = "true" *) reg [31:0]        instr_raw;   

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
   reg               reg_write_enabled_delayed;
   reg [4:0]         reg_write_dest_delayed;
   reg [31:0]        reg_write_data_delayed;   
   regf _registers(.clk(clk), 
                   .rstn(rstn),
                   .rs1(rs1_a), .rs2(rs2_a), .rd1(rs1_v), .rd2(rs2_v), 
                   .w_enable(reg_write_enabled_delayed),
                   .w_addr(reg_write_dest_delayed),
                   .w_data(reg_write_data_delayed));
   
   reg [31:0]        pc_instr;
   wire [31:0]       exec_result;
   
   wire              reg_write_enabled;
   wire [4:0]        reg_write_dest;
   
   wire              mem_write_enabled;
   wire              mem_read_enabled;
   
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
                    .mem_write_enabled(mem_write_enabled), .mem_read_enabled(mem_read_enabled),
                    .reg_write_enabled(reg_write_enabled), .reg_write_dest(reg_write_dest), 
                    .is_jump_enabled(is_jump_enabled), .jump_dest(jump_dest));
   
   /////////////////////
   // main
   /////////////////////
   initial begin
      pc <= 0;
      state <= FETCH;
      axi_wvalid <= 0;
      axi_awvalid <= 0;
      
      axi_arvalid <= 0;
      
      axi_bready <= 0;
      axi_rready <= 0;
   end

   always @(posedge clk) begin
      if(rstn) begin
         if (state == FETCH) begin
            instr_raw <= instr_raw_from_mem;
            state <= DECODE;
         end else if (state == DECODE) begin
            pc_instr <= pc;      
            state <= EXEC;
         end else if (state == EXEC) begin
            state <= MEM;
            mem_state <= mem_r_init;
         end else if (state == MEM) begin;
            if (mem_read_enabled) begin
               // if instr is for read from mem
               if (mem_state == mem_r_init) begin               
                  axi_araddr <= {exec_result[31:2], 2'b0}; // rs1+imm, 2'b0 is for alignment
                  axi_arprot <= 3'b000;                  
                  axi_arvalid <= 1;
                  mem_state <= mem_r_waiting_ready;               
               end else if (mem_state == mem_r_waiting_ready) begin
                  if (axi_arready) begin
                     axi_arvalid <= 0;
                     axi_rready <= 1;                  
                     mem_state <= mem_r_waiting_data;                  
                  end
               end else if (mem_state == mem_r_waiting_data) begin
                  if (axi_rvalid) begin
                     axi_rready <= 0;
                     if (instr.lb) begin
                        case(exec_result[1:0])
                          2'b11: reg_write_data_delayed <= {{24{axi_rdata[31]}}, axi_rdata[31:24]};
                          2'b10: reg_write_data_delayed <= {{24{axi_rdata[23]}}, axi_rdata[23:16]};
                          2'b01: reg_write_data_delayed <= {{24{axi_rdata[15]}}, axi_rdata[15:8]};
                          2'b00: reg_write_data_delayed <= {{24{axi_rdata[7]}}, axi_rdata[7:0]};
                          default: reg_write_data_delayed <= 32'b0;                       
                        endcase
                     end else if (instr.lh) begin
                        case(exec_result[1:0])
                          2'b10 : reg_write_data_delayed <= {{16{axi_rdata[31]}}, axi_rdata[31:16]};
                          2'b00 : reg_write_data_delayed <= {{16{axi_rdata[15]}}, axi_rdata[15:0]};
                          default: reg_write_data_delayed <= 32'b0;                       
                        endcase
                     end else if (instr.lw) begin
                        reg_write_data_delayed <= axi_rdata;                     
                     end else if (instr.lbu) begin                     
                        case(exec_result[1:0])
                          2'b11: reg_write_data_delayed <= {24'b0, axi_rdata[31:24]};
                          2'b10: reg_write_data_delayed <= {24'b0, axi_rdata[23:16]};
                          2'b01: reg_write_data_delayed <= {24'b0, axi_rdata[15:8]};
                          2'b00: reg_write_data_delayed <= {24'b0, axi_rdata[7:0]};
                          default: reg_write_data_delayed <= 32'b0;                       
                        endcase
                     end else if (instr.lhu) begin
                        case(exec_result[1:0])
                          2'b10 : reg_write_data_delayed <= {16'b0, axi_rdata[31:16]};
                          2'b00 : reg_write_data_delayed <= {16'b0, axi_rdata[15:0]};
                          default: reg_write_data_delayed <= 32'b0;                       
                        endcase
                     end
                     state <= WRITE;
                     reg_write_enabled_delayed <= 1;
                     reg_write_dest_delayed <= reg_write_dest;                
                  end               
               end
            end else if (mem_write_enabled) begin
               // if instr is for write to memory
               if (mem_state ==  mem_w_init) begin // assert mem_w_init == mem_r_init
                  axi_awaddr <= {exec_result[31:2], 2'b0}; // rs1 + imm
                  axi_awprot <= 3'b000;                  
                  axi_awvalid <= 1;
                  
                  if(instr.sb) begin 
                     case(exec_result[1:0])
                       2'b11 : begin 
                          axi_wstrb <= 4'b1000;
                          axi_wdata <= {rs2_v[7:0], 24'b0};
                       end
                       2'b10 : begin
                          axi_wstrb <= 4'b0100;
                          axi_wdata <= {8'b0, rs2_v[7:0], 16'b0};
                       end
                       2'b01 : begin
                          axi_wstrb <= 4'b0010;
                          axi_wdata <= {16'b0, rs2_v[7:0], 8'b0};
                       end
                       2'b00 : begin
                          axi_wstrb <= 4'b0001;
                          axi_wdata <= {24'b0, rs2_v[7:0]};
                       end
                       default : begin
                          state <= INVALID;                               
                       end
                     endcase	
                  end else if (instr.sh) begin
                     case(exec_result[1:0])
                       2'b10 : begin
                          axi_wstrb <= 4'b1100;
                          axi_wdata <= {rs2_v[15:0], 16'b0};
                       end
                       2'b00 : begin
                          axi_wstrb <= 4'b0011;
                          axi_wdata <= {16'b0, rs2_v[15:0]};
                       end
                       default : begin
                          state <= INVALID;                       
                       end
                     endcase
                  end  else if (instr.sw) begin
                     axi_wstrb <= 4'b1111;
                     axi_wdata <= rs2_v;                  
                  end
                  axi_wvalid <= 1;
                  mem_state <= mem_w_waiting_ready;
               end else if (mem_state == mem_w_waiting_ready) begin
                  if(axi_awready) begin
                     axi_awvalid <= 0;
                  end
                  if(axi_wready) begin
                     axi_wvalid <= 0;
                  end
                  if(!axi_awvalid && !axi_wvalid) begin
                     axi_bready <= 1;
                     mem_state <= mem_w_waiting_data;                  
                  end               
               end else if (mem_state == mem_w_waiting_data) begin
                  if (axi_bvalid) begin
                     axi_bready <= 0;                  
                     state <= WRITE;
                     reg_write_enabled_delayed <= 0;
                  end
               end
            end else begin
               reg_write_enabled_delayed <= reg_write_enabled;
               reg_write_dest_delayed <= reg_write_dest;            
               reg_write_data_delayed <= exec_result;      
               state <= WRITE;
            end          
         end else if (state == WRITE) begin         
            pc <= is_jump_enabled? jump_dest : pc + 4;                       
            state <= FETCH;
         end
      end else begin
        pc <= 0;
        state <= FETCH;
      end
   end
endmodule
`default_nettype wire
