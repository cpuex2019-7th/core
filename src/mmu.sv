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
   reg                       selector;
   wire                      forread_axi_araddr = assign selector? mem_axi_araddr : core_axi_araddr;
   wire                      forread_axi_arready = assign selector? mem_axi_arready : core_axi_arready;
   wire                      forread_axi_arvalid = assign selector? mem_axi_arvalid : core_axi_arvalid;

   wire                      forread_axi_bready = assign selector? mem_axi_bready : core_axi_bready;
   wire                      forread_axi_bresp = assign selector? mem_axi_bresp : core_axi_bresp;
   wire                      forread_axi_bvalid = assign selector? mem_axi_bvalid : core_axi_bvalid;

   wire                      forread_axi_rdata = assign selector? mem_axi_rdata : core_axi_rdata;
   wire                      forread_axi_rready = assign selector? mem_axi_rready : core_axi_rready;
   wire                      forread_axi_rresp = assign selector? mem_axi_rresp : core_axi_rresp;
   wire                      forread_axi_rvalid = assign selector? mem_axi_rvalid : core_axi_rvalid;

   wire                      forread_axi_awaddr = assign selector? mem_axi_awaddr : core_axi_awaddr;
   wire                      forread_axi_awready = assign selector? mem_axi_awready : core_axi_awready;
   wire                      forread_axi_awvalid = assign selector? mem_axi_awvalid : core_axi_awvalid;

   wire                      forread_axi_wdata = assign selector? mem_axi_wdata : core_axi_wdata;
   wire                      forread_axi_wready = assign selector? mem_axi_wready : core_axi_wready;
   wire                      forread_axi_wstrb = assign selector? mem_axi_wstrb : core_axi_wstrb;
   wire                      forread_axi_wvalid = assign selector? mem_axi_wvalid : core_axi_wvalid;
   

   // Read
   localparam r_waiting_ready = 0;   
   localparam r_writin_ready = 1;   
   localparam r_waiting_data = 2;   
   localparam r_writing_data = 3;   
   localparam r_waiting_status = 4;   
   localparam r_waiting_bresp = 4;   
   localparam r_writing_bresp = 4;   
   reg [2:0]                 reading_state;
   initial begin
      selector <= 1;
      reading_state <= r_waiting_ready;      
   end
   always @(posedge clk) begin
      if (reading_state == r_waiting_ready) begin
         if (core_axi_arvalid) begin
            core_axi_arready <= 1;
            state <= r_writing_ready;            
            if (core_axi_araddr[31:24] == 8'hFF) begin
               // UART
               uart_axi_arvalid <= 1;
               uart_axi_araddr <= 0;

               uart_axi_rready <= 1;
               selector <= 1;               
            end else begin
               // Mem
               mem_axi_arvalid <= 1;
               mem_axi_araddr <= core_axi_araddr;
               
               selector <= 0;
            end
         end
      end else if (reading_state == r_writing_ready) begin
         if(forread_axi_arready) begin
            forread_axi_arvalid <= 0;
            forread_axi_rready <= 1;
            reading_state <= r_waiting_data;
         end
      end if (reading_state == r_waiting_data) begin
         if (forread_axi_rvalid) begin
            forread_axi_rready <= 0;
            
            core_axi_wdata <= forread_axi_rdata;
            core_axi_wstrb <= 4'b0001;                             
            core_axi_wvalid <= 1;
            reading_state <= r_writing_data;            
         end
      end if (reading_state == r_writing_data) begin
         if(core_axi_wready) begin
            forread_axi_wvalid <= 0;
         end
         if(core_axi_awready) begin
            forread_axi_awvalid <= 0;
         end

         if (!forread_axi_wvalid && !forread_axi_wvalid) begin
            reading_state <= r_waiting_bresp;
            forread_axi_bready <= 1;            
         end
      end if (reading_state == r_waiting_bresp) begin
         if(forread_axi_bvalid) begin
            forread_axi_bready <= 0;
            core_axi_bresp <= forread_axi_bresp;
            core_axi_bvalid <= 1;
            reading_state <= r_writing_bresp;            
         end
      end if (reading_state == r_writing_bresp) begin
         if(forread_axi_bready) begin
            core_axi_bvalid <= 0;
            reading_state <= r_waiting_ready;            
         end
      end
   end


   // Write
   reg                       write_selector;
   wire                      forwrt_axi_araddr = assign write_selector? mem_axi_araddr : core_axi_araddr;
   wire                      forwrt_axi_arready = assign write_selector? mem_axi_arready : core_axi_arready;
   wire                      forwrt_axi_arvalid = assign write_selector? mem_axi_arvalid : core_axi_arvalid;

   wire                      forwrt_axi_bready = assign write_selector? mem_axi_bready : core_axi_bready;
   wire                      forwrt_axi_bresp = assign write_selector? mem_axi_bresp : core_axi_bresp;
   wire                      forwrt_axi_bvalid = assign write_selector? mem_axi_bvalid : core_axi_bvalid;

   wire                      forwrt_axi_rdata = assign write_selector? mem_axi_rdata : core_axi_rdata;
   wire                      forwrt_axi_rready = assign write_selector? mem_axi_rready : core_axi_rready;
   wire                      forwrt_axi_rresp = assign write_selector? mem_axi_rresp : core_axi_rresp;
   wire                      forwrt_axi_rvalid = assign write_selector? mem_axi_rvalid : core_axi_rvalid;

   wire                      forwrt_axi_awaddr = assign write_selector? mem_axi_awaddr : core_axi_awaddr;
   wire                      forwrt_axi_awready = assign write_selector? mem_axi_awready : core_axi_awready;
   wire                      forwrt_axi_awvalid = assign write_selector? mem_axi_awvalid : core_axi_awvalid;

   wire                      forwrt_axi_wdata = assign write_selector? mem_axi_wdata : core_axi_wdata;
   wire                      forwrt_axi_wready = assign write_selector? mem_axi_wready : core_axi_wready;
   wire                      forwrt_axi_wstrb = assign write_selector? mem_axi_wstrb : core_axi_wstrb;
   wire                      forwrt_axi_wvalid = assign write_selector? mem_axi_wvalid : core_axi_wvalid;

   localparam w_waiting_valid = 0;   
   localparam w_waiting_ready = 1;   
   localparam w_waiting_bready = 2;   
   localparam w_waiting_bresp = 3;   
   reg [2:0]                 writing_state;
   
   initial begin
      selector <= 1;
      writing_state <= w_waiting_valid;      
      core_axi_awready <= 1;
      core_axi_wready <= 1;      
   end
   
   always @(posedge clk) begin
      if (waiting_state == w_waiting_valid) begin       
         if(core_axi_awvalid) begin
            core_axi_awready <= 0;            
            if (core_axi_awaddr[31:24] == 8'hFF) begin               
               // UART
               write_selector <= 0;
               uart_axi_awaddr <= 4;
            end else begin               
               write_selector <= 1;
               mem_axi_awaddr <= core_axi_awaddr;               
            end
         end
         if(core_axi_wvalid) begin
            core_axi_wready <= 0;
            mem_axi_wdata <= core_axi_wdata;
            uart_axi_wdata <= core_axi_wdata;            
         end

         if (!core_axi_awready && !core_axi_wready) begin            
            forwrt_axi_awvalid <= 1;
            forwrt_axi_wvalid <= 1;
            writing_state <= w_waiting_ready;            
         end
      end if (waiting_state == w_waiting_ready) begin
         if (forwrt_axi_awready) begin
            forwrt_axi_awvalid <= 0;
         end
         if (forwrt_axi_wready) begin
            forwrt_axi_wvalid <= 0;
         end

         if (!forwrt_axi_wvalid && !forwrt_axi_awvalid) begin
            forwrt_axi_bready <= 1;            
            writing_state <= w_waiting_bresp;            
         end
      end if (waiting_state == w_waiting_bready) begin
         if (forwrt_axi_bvalid) begin
            forwrt_axi_bready <= 0;
            
            core_axi_bresp <= forwrt_axi_bresp;
            core_axi_bvalid <= 1;
            writing_state <= w_writing_bresp
         end
      end if (waiting_state == w_writing_bresp) begin
         if(core_axi_bready) begin
            forwrt_axi_bvalid <= 0;
            
            core_axi_awready <= 1;
            core_axi_wready <= 1;
            writing_state <= w_waiting_valid;
         end
      end        
   end
endmodule
