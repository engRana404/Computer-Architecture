  module test;
 //Creating signals that will be send to the master and slaves
  reg PCLK,PRESETn,transfer,READ_WRITE;
  reg [32:0] get_w_paddr,get_r_paddr;
  reg [31:0]get_w_data_in;
  wire [32:0]send_r_out;
  wire PSLVERR;
  reg [32:0]data;


  APB_Protocol obj_Apb(  PCLK,
	               PRESETn,
		       transfer,
		       READ_WRITE,
                       get_w_paddr,
		       get_r_paddr,
		       get_w_data_in,
		       PSLVERR, 
                       send_r_out
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
               @(negedge PCLK)      Write;        // write operation

     repeat(3) @(posedge PCLK);                                
               @(posedge PCLK);    get_w_paddr = 32'd526;  get_w_data_in = 32'd9;  
     repeat(2) @(posedge PCLK);    get_w_paddr = 32'd22; get_w_data_in = 32'd35;
     repeat(2) @(posedge PCLK);
               @(posedge PCLK)     READ_WRITE =1; PRESETn<=0; transfer<=0; 
               @(posedge PCLK)     PRESETn = 1;
     repeat(3) @(posedge PCLK)     transfer = 1;                             // no read address available but request for read operation
	    repeat(2) @(posedge PCLK)     Read;                             //read operation task

     repeat(3) @(posedge PCLK);   get_r_paddr = 32'd45;                 //data not inserted in write operation but requested for read operation
     repeat(4) @(posedge PCLK);
     $finish;
  end

  task Write;

     begin
 	
	for (i = 0; i < 32; i=i+1) begin
	repeat(2)@(negedge PCLK)
        begin  
	        data = i;
		get_w_paddr = {1'b0,data};
		get_w_data_in = i;
	

	 end 
	end
   
     end
endtask


		 
  task Read;
   
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
