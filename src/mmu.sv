// mmu modoki

module mmu(
	       input wire        clk,
	       input wire        rstn,

	       // Bus for RAM
           ////////////
           // address read channel
	       output reg [31:0] mem_axi_araddr,
	       input wire        mem_axi_arready,
	       output reg        mem_axi_arvalid,

           // response channel
	       output reg        mem_axi_bready,
	       input wire [1:0]  mem_axi_bresp,
	       input wire        mem_axi_bvalid,

           // read data channel
	       input wire [31:0] mem_axi_rdata,
	       output reg        mem_axi_rready,
	       input wire [1:0]  mem_axi_rresp,
	       input wire        mem_axi_rvalid,

           // address write channel
	       output reg [31:0] mem_axi_awaddr,
	       input wire        mem_axi_awready,
	       output reg        mem_axi_awvalid,

           // data write channel
	       output reg [31:0] mem_axi_wdata,
	       input wire        mem_axi_wready,
	       output reg [3:0]  mem_axi_wstrb,
	       output reg        mem_axi_wvalid,

	       // Bus for Core
           ////////////
	       input wire [31:0] core_axi_araddr,
	       output reg        core_axi_arready,
	       input wire        core_axi_arvalid,

	       input wire        core_axi_bready,
	       output reg [1:0]  core_axi_bresp,
	       output reg        core_axi_bvalid,

	       output reg [31:0] core_axi_rdata,
	       input wire        core_axi_rready,
	       output reg [1:0]  core_axi_rresp,
	       output reg        core_axi_rvalid,

	       input wire [31:0] core_axi_awaddr,
	       output reg        core_axi_awready,
	       input wire        core_axi_awvalid,

	       input wire [31:0] core_axi_wdata,
	       output reg        core_axi_wready,
	       input wire [3:0]  core_axi_wstrb,
	       input wire        core_axi_wvalid,

           // Bus for UART
           ////////////
	       output reg [31:0] uart_axi_araddr,
	       input wire        uart_axi_arready,
	       output reg        uart_axi_arvalid,

           // response channel
	       output reg        uart_axi_bready,
	       input wire [1:0]  uart_axi_bresp,
	       input wire        uart_axi_bvalid,

           // read data channel
	       input wire [31:0] uart_axi_rdata,
	       output reg        uart_axi_rready,
	       input wire [1:0]  uart_axi_rresp,
	       input wire        uart_axi_rvalid,

           // address write channel
	       output reg [31:0] uart_axi_awaddr,
	       input wire        uart_axi_awready,
	       output reg        uart_axi_awvalid,

           // data write channel
	       output reg [31:0] uart_axi_wdata,
	       input wire        uart_axi_wready,
	       output reg [3:0]  uart_axi_wstrb,
	       output reg        uart_axi_wvalid);

   /*
    // bypass all the signals.
    // NOTE: those assignments will be deleted in the future XD
    assign mem_axi_araddr = core_axi_araddr;
    assign mem_axi_arready = core_axi_arready;
    assign mem_axi_arvalid = core_axi_arvalid;
    
    assign mem_axi_bready = core_axi_bready;
    assign mem_axi_bresp = core_axi_bresp;
    assign mem_axi_bvalid = core_axi_bvalid;
    
    assign mem_axi_rdata = core_axi_rdata;
    assign mem_axi_rready = core_axi_rready;
    assign mem_axi_rresp = core_axi_rresp;
    assign mem_axi_rvalid = core_axi_rvalid;
    
    assign mem_axi_awaddr = core_axi_awaddr;
    assign mem_axi_awready = core_axi_awready;
    assign mem_axi_awvalid = core_axi_awvalid;
    
    assign mem_axi_wdata = core_axi_wdata;
    assign mem_axi_wready =  core_axi_wready;
    assign mem_axi_wstrb = core_axi_wstrb;
    assign mem_axi_wvalid = core_axi_wvalid ;   
    */
   
   // 1 for mem, 0 for UART
   reg                       read_selector;

   // Read
   localparam r_waiting_ready = 0;   
   localparam r_writing_ready = 1;   
   localparam r_waiting_data = 2;   
   localparam r_writing_data = 3;   
   localparam r_waiting_status = 4;   
   localparam r_waiting_bresp = 4;   
   localparam r_writing_bresp = 4;   
   reg [2:0]                 reading_state;
   
   initial begin
      read_selector <= 1;
      reading_state <= r_waiting_ready;      
   end
   
   always @(posedge clk) begin
      if (reading_state == r_waiting_ready) begin
         if (core_axi_arvalid) begin
            core_axi_arready <= 0;
            
            if (core_axi_araddr[31:24] == 8'hFF) begin
               // UART
               uart_axi_arvalid <= 1;
               uart_axi_araddr <= 0;
               read_selector <= 1;               
            end else begin
               // Mem
               mem_axi_arvalid <= 1;
               mem_axi_araddr <= core_axi_araddr;               
               read_selector <= 0;
            end

            state <= r_writing_ready;
         end
      end else if (reading_state == r_writing_ready) begin
         if (read_selector) begin
            if(uart_axi_arready) begin
               uart_axi_arvalid <= 0;            
               uart_axi_rready <= 1;            
               reading_state <= r_waiting_data;
            end
         end else begin         
            if(mem_axi_arready) begin
               mem_axi_arvalid <= 0;            
               mem_axi_rready <= 1;            
               reading_state <= r_waiting_data;
            end
         end
      end if (reading_state == r_waiting_data) begin
         if (read_selector) begin
            if (uart_axi_rvalid) begin
               uart_axi_rready <= 0;
               core_axi_rvalid <= 1;
               core_axi_rdata <= uart_axi_rdata;
               core_axi_rresp <= 2'b0; // TODO               
               reading_state <= r_writing_data;            
            end
         end else begin
            if (mem_axi_rvalid) begin
               mem_axi_rready <= 0;
               core_axi_rvalid <= 1;
               core_axi_rdata <= mem_axi_rdata;
               core_axi_rresp <= 2'b0; // TODO               
               reading_state <= r_writing_data;            
            end
         end
      end if (reading_state == r_writing_data) begin
         if(core_axi_rready) begin
            core_axi_rvalid <= 0;
            // for next loop
            core_axi_arready <= 1;
            reading_state <= r_waiting_ready;
         end
      end
   end


   // Write
   reg                       write_selector;

   localparam w_waiting_valid = 0;   
   localparam w_waiting_ready = 1;   
   localparam w_waiting_bready = 2;   
   localparam w_waiting_bresp = 3;   
   localparam w_writing_bresp = 3;   
   reg [2:0]                 writing_state;
   
   initial begin
      write_selector <= 1;
      writing_state <= w_waiting_valid;      
      core_axi_awready <= 1;
      core_axi_wready <= 1;      
   end
   
   always @(posedge clk) begin
      if (writing_state == w_waiting_valid) begin       
         if(core_axi_awvalid) begin
            core_axi_awready <= 0;
            if (core_axi_awaddr[31:24] == 8'hFF) begin               
               // UART
               write_selector <= 0;
               uart_axi_awaddr <= 4;
            end else begin       
               // Mem        
               write_selector <= 1;
               mem_axi_awaddr <= core_axi_awaddr;               
            end
         end
         
         if(core_axi_wvalid) begin
            core_axi_wready <= 0;
            mem_axi_wdata <= core_axi_wdata;
            uart_axi_wdata <= core_axi_wdata;            
         end

         // here write_selector should be already set!
         if (!core_axi_awready && !core_axi_wready) begin
            if (write_selector) begin               
               uart_axi_awvalid <= 1;
               uart_axi_wvalid <= 1;
            end else begin
               mem_axi_awvalid <= 1;
               mem_axi_wvalid <= 1;
            end
            
            writing_state <= w_waiting_ready;            
         end
      end if (writing_state == w_waiting_ready) begin
         if (write_selector) begin               
            if (uart_axi_awready) begin
               uart_axi_awvalid <= 0;
            end
            if (uart_axi_wready) begin
               uart_axi_wvalid <= 0;
            end

            if (!uart_axi_awvalid && !uart_axi_wvalid) begin
               uart_axi_bready <= 1;            
               writing_state <= w_waiting_bresp;            
            end
         end else begin
            if (mem_axi_awready) begin
               mem_axi_awvalid <= 0;
            end
            if (mem_axi_wready) begin
               mem_axi_wvalid <= 0;
            end

            if (!mem_axi_awvalid && !mem_axi_wvalid) begin
               mem_axi_bready <= 1;            
               writing_state <= w_waiting_bresp;            
            end
         end
      end if (writing_state == w_waiting_bready) begin
         if (write_selector) begin            
            if (uart_axi_bvalid) begin
               uart_axi_bready <= 0;
               
               core_axi_bresp <= uart_axi_bresp;
               core_axi_bvalid <= 1;
               writing_state <= w_writing_bresp;            
            end
         end else begin
            if (mem_axi_bvalid) begin
               mem_axi_bready <= 0;
               
               core_axi_bresp <= mem_axi_bresp;
               core_axi_bvalid <= 1;
               writing_state <= w_writing_bresp;            
            end
         end
      end if (writing_state == w_writing_bresp) begin
         if(core_axi_bready) begin
            if (write_selector) begin
               uart_axi_bvalid <= 0;
            end else begin
               mem_axi_bvalid <= 0;
            end
            
            core_axi_awready <= 1;
            core_axi_wready <= 1;

            writing_state <= w_waiting_valid;
         end
      end        
   end
endmodule
