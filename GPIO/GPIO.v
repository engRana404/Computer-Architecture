
//   Reset Strategy      : external asynchronous active low; PRESETn
//   Clock Domains       : PCLK, rising edge

/*
 * address  description         comment
 * ------------------------------------------------------------------
 * 0x0      mode register       0=push-pull
 *                              1=open-drain
 * 0x1      direction register  0=input
 *                              1=output
 * 0x2      output register     mode-register=0? 0=drive pad low
 *                                               1=drive pad high
 *                              mode-register=1? 0=drive pad low
 *                                               1=open-drain
 * 0x3      input register      returns data at pad
 * 0x4      trigger type        0=level
 *                              1=edge
 * 0x5      trigger level/edge0 trigger-type=0? 0=no trigger when low
 *                                              1=trigger when low
 *                              trigger-type=1? 0=no trigger on falling edge
 *                                              1=trigger on falling edge
 * 0x6      trigger level/edge1 trigger-type=0? 0=no trigger when high
 *                                              1=trigger when high
 *                              trigger-type=1? 0=no trigger on rising edge
 *                                              1=trigger on rising edge
 * 0x7      trigger status      0=no trigger detected/irq pending
                                1=trigger detected/irq pending
 * 0x8      irq enable          0=disable irq generation
 *                              1=enable irq generation
 */

module gpio #(
    // parameters
    parameter GPIO_PINS  = 32, // Must be a multiple of 8
    parameter PADDR_SIZE = 4,
    parameter STAGES = 2   // Stages to add more stability to inputs
) 
(
   // ports
   input  PCLK,                               // Clock. The rising edge of PCLK times all transfers on the APB
   input  PRESETn,                            // Reset. The APB reset signal is active LOW
   input  [PADDR_SIZE - 1:0] PADDR,           // Address. This is the APB address bus      
   input  [GPIO_PINS - 1:0] PWDATA,           // Write data. This bus is driven by the peripheral bus bridge unit during write cycles when PWRITE is HIGH   
   input  PWRITE,                             // Direction. This signal indicates an APB write access when HIGH and an APB read access when LOW   
   input  PSEL,                               // Select. The APB bridge unit generates this signal to each peripheral bus slave
   input  PENABLE,                            // Enable. This signal indicates the second and subsequent cycles of an APB transfer 
   input  [GPIO_PINS/8-1:0] PSTRB,            // Write strobes. This signal indicates which byte lanes to update during a write transfer
   
   output  PREADY,                            // Ready. The slave uses this signal to extend an APB transfer
   output  reg [GPIO_PINS-1:0] PRDATA = 0,    // Read Data. The selected slave drives this bus during read cycles when PWRITE is LOW
   output  PSLVERR,                           // This signal indicates a transfer failure.
   output  reg IRQ_O = 0,                         // IRQ_O is a single bit output which is asserted (?1?) when a valid interrupt is triggered on GPIO I  
   
   input  reg [GPIO_PINS-1:0]   GPIO_I,       //GPIO_I is the input bus  
   output reg [GPIO_PINS-1:0]   GPIO_O = 0,   //GPIO_O is the output bus
                                GPIO_OE = 0   //GPIO_OE is an active-high Output Enable bus
);

   localparam MODE      = 0,
              DIRECTION = 1,
              OUTPUT    = 2,
              INPUT     = 3,
              TR_TYPE   = 4,
              TR_LVL0   = 5,
              TR_LVL1   = 6,
              TR_STAT   = 7,
              IRQ_EN    = 8;
              
   
   // CONTROL REGISTERS
   reg  [GPIO_PINS-1:0] gpio_mode=0,
                         gpio_direction=0,
                         gpio_output=0,
                         gpio_input=0,
                         gpio_tr_type=0,
                         gpio_tr_lvl0=0,
                         gpio_tr_lvl1=0,
                         gpio_tr_stat=0,
                         gpio_irq_en=0;

  // Trigger registers 
   reg  [GPIO_PINS-1:0] tr_rising,
                         tr_falling,
                         tr_status,
                         tr_dly;

    // Input registers to prevent metastability
   reg [GPIO_PINS-1:0] input_reg_stages [STAGES:0];
 
    assign PSLVERR = 1'b0;
    assign PREADY  = 1'b1;
    
    // FUNCTIONS DEFINATION
    integer n;
  
    // valid write to given adress
    // adress is argument
    function automatic write_valid_to_adr(input [PADDR_SIZE-1:0] address);
     return (PENABLE & PWRITE & PSEL & (PADDR == address)) ;  
    endfunction
    
    // Decides what data to write and what to mask
    // Handles PSTRB //Takes current value of register as input
    function automatic [GPIO_PINS-1:0] select_write_bytes(input [GPIO_PINS-1:0] current_value);     
      for (n = 0; n < GPIO_PINS/8 ; n = n + 1 )
      select_write_bytes[n*8 +: 8] = PSTRB[n] ? PWDATA[n*8 +: 8] : current_value[n*8 +: 8] ;        //PSTRB[n] corresponds to PWDATA[(8n + 7):(8n)]
    endfunction
    
    // CLear when write 1
    function automatic [GPIO_PINS-1:0] clear_when_write (input [GPIO_PINS-1:0] current_value);
      for(n = 0; n < GPIO_PINS/8; n = n + 1)
      clear_when_write[n*8 +: 8] = PSTRB[n] ? current_value[n*8 +: 8] & ~PWDATA[n*8 +: 8] : current_value[n*8 +: 8];
    endfunction


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// MODULE BODY
/////
/////
    always @(posedge PCLK , negedge PRESETn) begin
        if(  !PRESETn                      )begin
          
          gpio_mode      <= {GPIO_PINS{1'b0}};
          gpio_output    <= {GPIO_PINS{1'b0}};
          gpio_irq_en    <= {GPIO_PINS{1'b0}};
          gpio_direction <= {GPIO_PINS{1'b0}};
          gpio_tr_type   <= {GPIO_PINS{1'b0}};
          gpio_tr_lvl0   <= {GPIO_PINS{1'b0}};
          gpio_tr_lvl1   <= {GPIO_PINS{1'b0}};
          gpio_tr_stat   <= {GPIO_PINS{1'b0}};
        
        end  
        
        else if (write_valid_to_adr(MODE))begin
          gpio_mode      <= select_write_bytes(gpio_mode);
        end
        else if (write_valid_to_adr(DIRECTION))begin
          gpio_direction <= select_write_bytes(gpio_direction);
        end
        else if (write_valid_to_adr(OUTPUT) || write_valid_to_adr(INPUT))begin
          gpio_output <= select_write_bytes(gpio_output);
        end
        else if (write_valid_to_adr(IRQ_EN))begin
          gpio_irq_en <= select_write_bytes(gpio_irq_en);
        end
        else if (write_valid_to_adr(TR_TYPE))begin
          gpio_tr_type <= select_write_bytes(gpio_tr_type);
        end
        else if (write_valid_to_adr(TR_LVL0))begin
          gpio_tr_lvl0 <= select_write_bytes(gpio_tr_lvl0);
        end
        else if (write_valid_to_adr(TR_LVL1))begin
          gpio_tr_lvl1 <= select_write_bytes(gpio_tr_lvl1);
        end
        else if (write_valid_to_adr(TR_STAT))begin
          gpio_tr_stat <= clear_when_write(gpio_tr_stat) | tr_status;
        end
        else
          gpio_tr_stat <= gpio_tr_stat | tr_status;

    end
    always @(*) begin
        if(~PWRITE & PENABLE & PSEL) begin
          case(PADDR)
            MODE     : PRDATA <= gpio_mode;
            DIRECTION: PRDATA <= gpio_direction;
            OUTPUT   : PRDATA <= gpio_output;
            INPUT    : PRDATA <= gpio_input;
            TR_TYPE  : PRDATA <= gpio_tr_type;
            TR_LVL0  : PRDATA <= gpio_tr_lvl0;
            TR_LVL1  : PRDATA <= gpio_tr_lvl1;
            TR_STAT  : PRDATA <= gpio_tr_stat;
            IRQ_EN   : PRDATA <= gpio_irq_en;
            default  : PRDATA <= {GPIO_PINS{1'b0}};
          endcase
        end
    end
   //  mode
   //  0 = push-pull  drive output register value to the gpio if output is enabled
   //  1 = open-drain always drive '0' on gpio if output is enabled
    always @(posedge PCLK) begin
      for (n = 0; n < GPIO_PINS; n = n + 1) begin
        GPIO_O[n] <= gpio_mode[n] ? 1'b0 : gpio_output[n];
      end      
    end

   // direction  mode  
   // 0=input    0=push-pull         gpio_oe =   zero                 input enabled
   // 1=output   0=push-pull         gpio_oe =   always high          output enabled
   // 0=input    1=open-drain        gpio_oe =   zero                 input enabled
   // 1=output   1=open-drain        gpio_oe =   not(gpio_output_reg) no connection 
   always @(posedge PCLK) begin
     for (n = 0; n<GPIO_PINS; n = n + 1) begin
       GPIO_OE[n] <= gpio_direction[n] & ~(gpio_mode[n] ? gpio_output[n] : 1'b0);
     end
   end

    // Staging logic
    always @(posedge PCLK) begin
      for (n = 0; n < STAGES; n = n + 1) begin
       if(n==0) input_reg_stages[n] <= GPIO_I;
       else     input_reg_stages[n] <= input_reg_stages[n-1];
      end     
    end
    
    // last stage is assigned to the input register
    always @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn)
    gpio_input     <= {GPIO_PINS{1'b0}};
    else
    gpio_input <= input_reg_stages[STAGES-1];
    end
   
   // Trigger logics
   // delay input register
    always @(posedge PCLK) begin
     tr_dly <= gpio_input; 
    end
    //  rising edge detection
    always @(posedge PCLK , negedge PRESETn) begin
     if(!PRESETn) tr_rising <= {GPIO_PINS{1'b0}};
     else       tr_rising <= ~tr_dly & gpio_input;
    end
    //  Falling edge detection
    always @(posedge PCLK , negedge PRESETn) begin
     if(!PRESETn) tr_falling <= {GPIO_PINS{1'b0}};
     else       tr_falling <= tr_dly & ~gpio_input;
    end

    // Trigger status
    always @(*) begin
      for (n = 0; n<GPIO_PINS; n = n + 1) begin
        case(gpio_tr_type[n])          
          1'b0 : tr_status[n] = (gpio_tr_lvl0[n] & ~gpio_input[n]) | (gpio_tr_lvl1[n] &  gpio_input[n]);
          1'b1 : tr_status[n] = (gpio_tr_lvl0[n] &  tr_falling[n]) | (gpio_tr_lvl1[n] &  tr_rising [n]);           
        endcase
      end
    end
    
    
    always @(posedge PCLK, negedge PRESETn) begin
      if(!PRESETn) 
        IRQ_O <= 1'b0;
      else       
        IRQ_O <= |(gpio_irq_en & gpio_tr_stat);
    end

endmodule