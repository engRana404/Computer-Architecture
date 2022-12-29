`include "master.v"

`timescale 1ns/1ns



module APB_Protocol(
                 input PCLK,PRESETn,transfer,READ_WRITE,
                 input [32:0] get_w_paddr,get_r_paddr,
		 input [31:0] get_w_data_in,
		 output PSLVERR, 
                 output [32:0] send_r_out
          );
       //wire [1:0] PSEL;
       wire [32:0]PWDATA,PRDATA;
       wire [32:0]PADDR;

       //READY 1 and Reay 2 for slave 1 and 2
       wire PREADY,PENABLE,PWRITE;
    
      //assign Ready and data need to be changed#######################

        assign PREADY = 1 ;
        assign PRDATA =  32'd25;

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

      


endmodule

