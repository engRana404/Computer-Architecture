include "Master.v";
//GPIO
include "GPIO.v";
//tri-state buffer
include "tri-state.v";

`timescale 1ns/1ns


module APB_Protocol(
     input PCLK,PRESETn,transfer,READ_WRITE,
     input [32:0] get_w_paddr,get_r_paddr,
   input [31:0] get_w_data_in,
   output PSLVERR, 
   output [31:0] send_r_out,
   input [31:0] i_port,
   output [31:0] o_port,
   input [3:0]PSTRB
          );
	
       wire [32:0] PADDR;
       wire [31:0] PWDATA;
       wire [1:0] PSEL;
       wire [31:0] PRDATA;
       wire [31:0] GPIO_OE;
       wire [31:0] GPIO_O;
       wire [31:0] GPIO_I;
       wire PREADY, PENABLE, PWRITE;
   
	//Using tri-state buffer
	Tri_Buff buff(.enable(GPIO_OE),.data_out(GPIO_O),.i_port(i_port),.o_port(o_port),.data_in(GPIO_I));
	
     //Create object from the master
       master obj_mas(
       get_w_paddr[32:0],get_r_paddr, 
       get_w_data_in,
       PRDATA, 
       PSTRB,  
       PRESETn,
       PCLK,
       PREADY,
       transfer,
       READ_WRITE,
       PENABLE,
       PADDR[32:0],
       PWRITE,
       PWDATA,
       send_r_out,
       PSLVERR,
       PSEL); 

      //Create Objects from our slave
      gpio dut1 (.PCLK(PCLK), .PRESETn(PRESETn), .PADDR(PADDR[3:0]), .PWDATA(PWDATA), .PWRITE(PWRITE), .PSEL(PSEL), .PENABLE(PENABLE), .PSTRB(PSTRB), .PREADY(PREADY), .PRDATA(PRDATA), .PSLVERR(PSLVERR), .IRQ_O(IRQ_O), .GPIO_I(GPIO_I), .GPIO_O(GPIO_O), .GPIO_OE(GPIO_OE));

endmodule