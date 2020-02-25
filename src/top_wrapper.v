`default_nettype none

module core_wrapper
  (input wire clk, 
   input wire                  rstn,
     
   // Bus for instr ROM
   output wire [31:0]          rom_addr,
   input wire [31:0]           rom_data,
  
   // Bus for RAM
   ////////////
   output wire [MEM_WIDTH-1:0] ram_addr,
   output wire                 ram_clka,
   output wire [31:0]          ram_dina,
   input wire [31:0]           ram_douta,
   output wire                 ram_ena,
   output wire                 ram_rsta,
   output wire [3:0]           ram_wea,
  
   // Bus for UART buffer
   // address read channel
   output wire [31:0]          uart_axi_araddr,
   input wire                  uart_axi_arready,
   output wire                 uart_axi_arvalid,
   output wire [2:0]           uart_axi_arprot, 

   // response channel
   output wire                 uart_axi_bready,
   input wire [1:0]            uart_axi_bresp,
   input wire                  uart_axi_bvalid,

   // read data channel
   input wire [31:0]           uart_axi_rdata,
   output wire                 uart_axi_rready,
   input wire [1:0]            uart_axi_rresp,
   input wire                  uart_axi_rvalid,

   // address write channel
   output wire [31:0]          uart_axi_awaddr,
   input wire                  uart_axi_awready,
   output wire                 uart_axi_awvalid,
   output wire [2:0]           uart_axi_awprot, 

   // data write channel
   output wire [31:0]          uart_axi_wdata,
   input wire                  uart_axi_wready,
   output wire [3:0]           uart_axi_wstrb,
   output wire                 uart_axi_wvalid);
   
   
   core _core(.clk(clk), 
              .rstn(rstn),

              .rom_addr(rom_addr),
              .rom_data(rom_data),

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
              .uart_axi_wvalid(uart_axi_wvalid));   
endmodule

`default_nettype wire
