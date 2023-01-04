module test;
 //Creating signals that will be send to the master and slaves
  reg PCLK,PRESETn,transfer,READ_WRITE;
  reg [32:0] get_w_paddr,get_r_paddr;
  reg [31:0]get_w_data_in;
  wire [31:0]PWDATA;
  wire [32:0]send_r_out;
  wire PSLVERR;
  reg [32:0]data;
  wire [31:0] gpioIO;


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
			PWDATA
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
    
                          PRESETn<=0; transfer<=0; READ_WRITE =0;
               @(posedge PCLK)      PRESETn = 1;                                     //no write address available but request for write operation
               @(posedge PCLK)      transfer = 1;
     repeat(2) @(posedge PCLK);
               @(negedge PCLK)      WriteGPIO(33'd1,32'd9);        // write operation

  
     $finish;
  end


  task WriteGPIO( [32:0] address, [31:0] d);
     begin
	
	get_w_paddr = address;
	get_w_data_in = d;
   
     end
endtask


   
  task ReadGPIO;
   
      begin 
 for (j = 0;  j< 32; j= j+1)
        begin
 repeat(2)@(negedge PCLK)
          begin   
   data = j; 
   get_r_paddr = {1'b0,data};
     
         end
        end
      end
  endtask





 endmodule
