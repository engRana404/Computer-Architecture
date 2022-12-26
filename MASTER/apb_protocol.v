
`include "master.v"
//GPIO
`include "GPIO.v"
//UART
`include "slave2.v"



`timescale 1ns/1ns



module APB_Protocol(
                 input PCLK,PRESETn,transfer,READ_WRITE,
                 input [32:0] get_w_paddr,get_r_paddr,
		 input [31:0] get_w_data_in,
		 output PSLVERR, 
                 output [32:0] send_r_out
          );
       wire [1:0] PSEL;
       wire [32:0]PWDATA,PRDATA,PRDATA1,PRDATA2;
       wire [32:0]PADDR;

       //READY 1 and Reay 2 for slave 1 and 2
       wire PREADY,PREADY1,PREADY2,PENABLE,PWRITE;
    
      //Can't understand#########################

        assign PREADY = PADDR[32] ? PREADY2 : PREADY1 ;
        assign PRDATA = READ_WRITE ? (PADDR[32] ? PRDATA2 : PRDATA1) : 32'dx ;

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
      slave1 dut1(  PCLK,PRESETn, PSEL1,PENABLE,PWRITE, PADDR[7:0],PWDATA, PRDATA1, PREADY1 );

      slave2 dut2(  PCLK,PRESETn, PSEL2,PENABLE,PWRITE, PADDR[7:0],PWDATA, PRDATA2, PREADY2 );
      


endmodule
