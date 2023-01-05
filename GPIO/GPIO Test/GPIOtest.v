`timescale 1ns/1ns

module test;
 //Creating signals that will be send to the master and slaves
  reg PCLK,PRESETn,transfer,READ_WRITE;
  reg [32:0] get_w_paddr,get_r_paddr;
  reg [31:0]get_w_data_in;
  wire [32:0]send_r_out;
  wire PSLVERR;
  reg [32:0]data;
  wire [31:0] gpioIO;
  reg [3:0]PSTRB;



  APB_Protocol obj_Apb(  PCLK,
                         PRESETn,
                        transfer,
                        READ_WRITE,
                         get_w_paddr,
                        get_r_paddr,
                        get_w_data_in,
                        PSLVERR, 
                        send_r_out,
			gpioIO,
			PSTRB
                      );
  integer i,j;
  //initialize the clock
  initial
   begin
    PCLK <= 0;
    forever #5 PCLK = ~PCLK;
   end




    initial
    begin
                              PRESETn<=0; transfer<=0; READ_WRITE =0; PSTRB =4'b1111;
               @(posedge PCLK)      PRESETn = 1;                                     //no write address available but request for write operation
               @(posedge PCLK)      transfer = 1;
     repeat(2) @(posedge PCLK);
               @(negedge PCLK)      get_w_paddr=0; get_w_data_in=32'h0;    // write operation

		#3
                               PRESETn<=0; transfer<=0; READ_WRITE =0; PSTRB =4'b1111;
               @(posedge PCLK)      PRESETn = 1;                                     //no write address available but request for write operation
               @(posedge PCLK)      transfer = 1;
     repeat(2) @(posedge PCLK);
               @(negedge PCLK)     get_w_paddr=33'd1; get_w_data_in=32'hFFFFFFFF;        // write operation

		#3
    
                          PRESETn<=0; transfer<=0; READ_WRITE =0; PSTRB =4'b1111;
               @(posedge PCLK)      PRESETn = 1;                                     //no write address available but request for write operation
               @(posedge PCLK)      transfer = 1;
     repeat(2) @(posedge PCLK);
               @(negedge PCLK)     get_w_paddr=33'd2; get_w_data_in=32'd31;   // write operation


  		#3
                 PRESETn<=0; transfer<=0; READ_WRITE =0; PSTRB =4'b1111;
               @(posedge PCLK)      PRESETn = 1;                                     //no write address available but request for write operation
               @(posedge PCLK)      transfer = 1;
     repeat(2) @(posedge PCLK);
               @(negedge PCLK)      get_w_paddr=0; get_w_data_in=32'h0;    // Mode Push-Pull

		#3

                               PRESETn<=0; transfer<=0; READ_WRITE =0; PSTRB =4'b1111;
               @(posedge PCLK)      PRESETn = 1;                                     //no write address available but request for write operation
               @(posedge PCLK)      transfer = 1;
     repeat(2) @(posedge PCLK);
               @(negedge PCLK)     get_w_paddr=33'd1; get_w_data_in=32'h0;        // Direction to Read

		#3
    
                          PRESETn<=0; transfer<=0; READ_WRITE =0; PSTRB =4'b1111;
               @(posedge PCLK)      PRESETn = 1;                                     //no write address available but request for write operation
               @(posedge PCLK)      transfer = 1;
     repeat(2) @(posedge PCLK);
               @(negedge PCLK)     get_w_paddr=33'd4; get_w_data_in=32'hFFFFFFFF;   //Trigger type:Edge 
  		#3

                          PRESETn<=0; transfer<=0; READ_WRITE =0; PSTRB =4'b1111;
               @(posedge PCLK)      PRESETn = 1;                                     //no write address available but request for write operation
               @(posedge PCLK)      transfer = 1;
     repeat(2) @(posedge PCLK);
               @(negedge PCLK)     get_w_paddr=33'd6; get_w_data_in=32'hFFFFFFFF;   // Rising edge triggering 
  		#3

          PRESETn<=0; transfer<=0; READ_WRITE =1; PSTRB =4'b1111;
               @(posedge PCLK)      PRESETn = 1;                                     //no write address available but request for write operation
               @(posedge PCLK)      transfer = 1;
     repeat(2) @(posedge PCLK);
		@(negedge PCLK)     gpioIO = 4'd5;
               @(posedge PCLK)      get_r_paddr=33'd3;   // read address
  		#3


     $finish;
  end


 endmodule
