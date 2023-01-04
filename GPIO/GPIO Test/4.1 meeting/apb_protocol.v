include "Master.v";
//GPIO
include "GPIO.v";




`timescale 1ns/1ns



module APB_Protocol(
     input PCLK,PRESETn,transfer,READ_WRITE,
     input [32:0] get_w_paddr,get_r_paddr,
   input [31:0] get_w_data_in,
   output PSLVERR, 
   output [32:0] send_r_out,
   inout   [31:0] gpioIO,
   output [31:0] PWDATA
          );
       wire [1:0] PSEL;
       wire [32:0] PRDATA, PRDATA1;
       wire [32:0]PADDR;
       wire [31:0] GPIO_OE;
       wire [31:0] GPIO_O;
       reg [31:0] GPIO_I,IO;
	

       //READY 1 and Reay 2 for slave 1 and 2
       wire PREADY, PENABLE, PWRITE;

      //#########################
//to be checked later
        assign PRDATA = READ_WRITE ? PRDATA1 : 32'dx;

integer i;
always @(*)
begin	 
for (i = 0;  i< 32; i= i+1)
        begin
	if(GPIO_OE[i]==1'b1) 
	begin 
	   GPIO_I[i] = gpioIO[i];
	end

	else 
	begin
	 IO[i] = GPIO_O[i];
	end

	end
end

assign gpioIO = IO;

     //Create object from the master
       master obj_mas(
       get_w_paddr,get_r_paddr, 
       get_w_data_in,
       PRDATA, 
       PSTRB,  
       PRESETn,
       PCLK,
       PREADY,
       transfer,
       READ_WRITE,
       PENABLE,
       PADDR,
       PWRITE,
       PWDATA,
       send_r_out,
       PSLVERR,
       PSEL
                ); 

      //Create Objects from our two slaves
      gpio dut1(PCLK, PRESETn, PADDR[3:0], PWDATA, PWRITE, PSEL[0], PENABLE, PSTRB, PREADY, PRDATA1, PSLVERR, IRQ_O, GPIO_I, GPIO_O, GPIO_OE);

endmodule