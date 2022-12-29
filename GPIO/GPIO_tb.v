`timescale 1ns / 1ps

module gpio_testbench#(
    // parameters
   parameter GPIO_PINS  = 32, // Must be a multiple of 8
   parameter PADDR_SIZE = 4,
   parameter STAGES     = 2   // Steges to add more stability to inputs
) (
   // ports
   input                      CLK,
   input                      HRESETn,
   output  reg                   PSEL=0,
   output  reg                   PENABLE=0,
   output  reg [PADDR_SIZE-1:0]  PADDR=0,
   output  reg                   PWRITE=0,
   output  reg [GPIO_PINS-1:0]   PWDATA=0,
   output  reg [GPIO_PINS/8-1:0] PSTRB=4'b1111,
   
   input                       PREADY,
   input    [GPIO_PINS-1:0]    PRDATA,
   input                       PSLVERR,
   input                       irq_o,
   
   output reg [GPIO_PINS-1:0]   gpio_i=0,   
   input   [GPIO_PINS-1:0]    gpio_o,
                             gpio_oe
);

    // Adresses for configuration registers
     parameter MODE = 4'd0;
     parameter DIRECTION = 4'd1;
     parameter OUTPUT = 4'd2;
     parameter INPUT = 4'd3;
     parameter TR_TYPE = 4'd4;
     parameter TR_LVL0 = 4'd5;
     parameter TR_LVL1 = 4'd6;
     parameter TR_STAT = 4'd7;
     parameter IRQ_EN = 4'd8; 

                
    reg [GPIO_PINS - 1 : 0]   actual_data     = 32'd0,       // Actual data register 
                                expected_data   = 32'd0,      // Expected data register
                                expected_data_d = 32'd0,    // delay expected data register
                                expected_data_1 = 32'd0,    // delay expected data register
                                errors          = 32'd0,           // Mismatch count register
                                Output_data     = 32'd0,
                                Output_enable   = 32'd0;

        task automatic reset_all();                  // Reset default value functions
            @(posedge CLK) begin
                PSEL      = 1'b0;
                PENABLE   = 1'b0;
                PADDR     = 'h0;
                PWDATA    = 'h0;
                PWRITE    = 'h0;
            end
        endtask
        
        task automatic write (                          // Write data function
                input [PADDR_SIZE  -1:0] address,
                input [GPIO_PINS   -1:0] data
        );
            @(posedge CLK) begin
                PSEL       = 1'b1;
                PENABLE    = 1'b1;
                PADDR      = address;
                PWDATA     = data;
                PWRITE     = 1'b1;
                expected_data <= data; 
            end
        endtask
  
        function  reg [ GPIO_PINS -1 : 0] read_data(   // read data function
            input  [PADDR_SIZE -1:0] address
        );begin
        
            PSEL         = 1'b1;
            PADDR        = address;
            PWDATA       = {32{1'b0}};
            PWRITE       = 1'b0;
            read_data    = PRDATA;
            PENABLE      = 1'b1;
          end
        endfunction


        task automatic  clear_gpio(   // GPIO clear Task 
        );begin
            write(MODE,0);
            reset_all();
            write(DIRECTION,0);
            reset_all();
            write(OUTPUT,0);
            reset_all();
            write(TR_TYPE,0);
            reset_all();
            write(TR_LVL0,0);
            reset_all();
            write(TR_LVL1,0);
            reset_all();
            write(IRQ_EN,0);
            reset_all();
          end
        endtask



        task automatic Welcome_screen();begin  // Welcome Screen
            $display("...................................Testbench Initiated...............................");           
            $display("....................................................................................."); 
          end
        endtask 
        task finish_text_PASSED(); //  Test pass message function
            begin
                $display ("------------------------------------------------------------");
                $display (" TEST PASSED Testbench finished successfully " );
                $display ("------------------------------------------------------------");
            end
        endtask
    
        task finish_text_FAILED(); //  Test fail message function
            begin
                $display ("------------------------------------------------------------");
               $display (" TEST FAILED Testbench finished successfully ");
                $display ("------------------------------------------------------------");
            end
        endtask
        
        integer seed = 0 ,x = 0;
    
        task randomized_stimulus(input seed);begin
            write(MODE,32'd0);  // Setting Mode register to zero for Enabling Push pull mode for All gpios
            reset_all(); // Reseting all signals to default values
            actual_data = read_data(MODE);
            if(actual_data !== expected_data_d) begin // comparing actual data and delayed expected data
                errors = errors + 1;
            end
    //        Output_enable = 32'hFFFF_FFFF;
            Output_enable = $urandom(seed+100); 
            write(DIRECTION,Output_enable);
            reset_all();
            actual_data = read_data(DIRECTION);
            if(actual_data !== expected_data_d) begin
                errors = errors + 1;
            end
            //Output_data = 32'b0000_0000_0000_0000_0000_0000_1000_1000; // Data state for all GPIO pins
            Output_data = $urandom(seed);
            write(OUTPUT,Output_data);
            reset_all();
            actual_data = read_data(OUTPUT);
            if(actual_data !== expected_data_d) begin
                errors = errors + 1;
            end
            write(TR_TYPE,32'b1111_1111_1111_1111_1111_1111_1111_1111);
            reset_all();
            actual_data = read_data(TR_TYPE);
            if(actual_data !== expected_data_d) begin
                errors = errors + 1;
            end
            write(TR_LVL0,32'd0);
            reset_all();
            actual_data = read_data(TR_LVL0);
            if(actual_data !== expected_data_d) begin
                errors = errors + 1;
            end
            write(TR_LVL1,32'd0);
            reset_all();
            actual_data = read_data(TR_LVL1);
            if(actual_data !== expected_data_d) begin
                errors = errors + 1;
            end
            write(IRQ_EN,32'd0);
            reset_all();
            actual_data = read_data(IRQ_EN);
            
            if(actual_data !== expected_data_d) begin
                errors = errors + 1;
            end

            
            if ((gpio_o & gpio_oe) !== (Output_data & Output_enable)) begin
            errors = errors + 1;
            end

            clear_gpio();
          end
        endtask
    
        initial begin
            
            reset_all();
            Welcome_screen();

            while (x<=10000) begin
                randomized_stimulus(x);
                x = x + 1;
            end           

            if(errors == 0 ) begin
                finish_text_PASSED();
            end
            else begin
                finish_text_FAILED();
            end
            $finish();
        end
        
        always @(posedge CLK) begin // Delaying signal one clock cycle for making right comparison
            expected_data_1 <= expected_data;
            expected_data_d <= expected_data_1;
        end 
      
    endmodule

