`timescale 1ns / 1ps

module top#(  // parameters
  parameter  GPIO_PINS  = 32, // Must be a multiple of 8
  parameter  PADDR_SIZE = 4,
  parameter  STAGES     = 2   // Steges to add more stability to input)(
 )
 ( output reg HCLK=0,
  output reg HRESETn=0);
 
        always begin : clk_gen
            #10 HCLK = ~HCLK;
        end
        initial begin
            #20 HRESETn = 1'b1;
        
        end
    
        wire [GPIO_PINS-1:0]   gpio_i;
        wire                   PSEL;
        wire                   PENABLE;
        wire [PADDR_SIZE-1:0]  PADDR;
        wire                   PWRITE;
        wire [GPIO_PINS-1:0]   PWDATA;
        wire [GPIO_PINS/8-1:0] PSTRB;
        
        wire                    PREADY;
        wire [GPIO_PINS-1:0]    PRDATA;
        wire                    PSLVERR;
        wire                    irq_o;
        wire [GPIO_PINS-1:0]    gpio_o,
                                        gpio_oe;
                                    
        gpio #(
        .GPIO_PINS(GPIO_PINS),
        .PADDR_SIZE(PADDR_SIZE),
        .STAGES(STAGES)
        ) dut (
        
        .PCLK(CLK),
        .PRESETn(HRESETn),                
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PSTRB(PSTRB),
        .PREADY(PREADY),
        .PRDATA(PRDATA),
        .PSLVERR(PSLVERR),
        .IRQ_O(irq_o),
        .GPIO_I(gpio_i),
        .GPIO_O(gpio_o),
        .GPIO_OE(gpio_oe)
        
        );    
        gpio_testbench #(.GPIO_PINS(GPIO_PINS),
            .PADDR_SIZE(PADDR_SIZE),
            .STAGES(STAGES)  )
        tb(.*);                           
                                        
    endmodule