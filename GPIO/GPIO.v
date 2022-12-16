module gpio(
input PCLK, //Clock. The rising edge of PCLK times all transfers on the APB.
input PRESETn, //Reset. The APB reset signal is active LOW
input [2:0] PADDR, // Address. This is the APB address bus.
input [7:0] PWDATA, //Write data. This bus is driven by the peripheral bus bridge unit during write cycles when PWRITE is HIGH.
input PWRITE, //Direction. This signal indicates an APB write access when HIGH and an APB read access when LOW.
input PSEL, // Select. The APB bridge unit generates this signal to each peripheral bus slave. 
input PENABLE, // Enable. This signal indicates the second and subsequent cycles of an APB transfer.
input PREADY, //Ready. The slave uses this signal to extend an APB transfer
output reg [7:0] PRDATA = 0, // Read Data. The selected slave drives this bus during read cycles when PWRITE is LOW
inout  pin1, pin2, pin3, pin4, pin5, pin6, pin7, pin8 //8 pins 
);

//Indicates the current and the next step
reg state, next;
integer i;
//Define the states
localparam IDLE = 2'b00 ,SETUP = 2'b01, WRITE = 2'b10, READ = 2'b11;
reg [7:0] mem[0:7], out = 8'd0, in = 8'd0;

assign pin1 = mem[0][0] ? out[0] : 1'bZ;
assign pin2 = mem[0][1] ? out[1] : 1'bZ;
assign pin3 = mem[0][2] ? out[2] : 1'bZ;
assign pin4 = mem[0][3] ? out[3] : 1'bZ;
assign pin5 = mem[0][4] ? out[4] : 1'bZ;
assign pin6 = mem[0][5] ? out[5] : 1'bZ;
assign pin7 = mem[0][6] ? out[6] : 1'bZ;
assign pin8 = mem[0][7] ? out[7] : 1'bZ;


always @(posedge PCLK)
begin
  //if the reset is on goto the IDLE state
  if(!PRESETn) 
    state <= IDLE;
  else
    state <= next;
end

always @(negedge PCLK or state or PSEL or PREADY)
begin
  next = IDLE;
  case(state)
    //IDLE state
    IDLE:begin
      if(PSEL)
        next = SETUP;
      else
        next = IDLE;
    end
    //SETUP state
    SETUP:begin
      if(!PSEL)
        next = IDLE;
      else if(PWRITE && PENABLE && PSEL)begin      
        next = WRITE;
      end  
      else if(!PWRITE && PENABLE && PSEL)begin        
        next = READ;
      end
      else
        next = SETUP;
    end
    //WRITE State
    WRITE:begin
      mem[3] = out; 
      mem[PADDR] = PWDATA;
      if(!PENABLE)
        next = SETUP;
      else if(!PSEL || PREADY)
        next = IDLE;
      else
        next = WRITE; 
    end
    //READ State
    READ:begin
      mem[4] = in;
      PRDATA = mem[PADDR];
      if(!PENABLE)
        next = SETUP;
      else if(!PSEL || PREADY)
        next = IDLE;
      else
        next = READ;                 
    end
	endcase
end
	

always @(posedge PCLK)
begin
  for(i = 0; i < 8; i = i + 1)begin
    if(mem[0][i])begin
      if(mem[1][i] && !mem[2][i])begin
        out[i] = 1'b1;			
      end
      else if(mem[2][i])begin
        out[i] = 1'b0;
      end		
    end
    if(!mem[0][i]) begin
      if(i == 0)begin
        in[0] = pin1;
      end
      if(i == 1)begin
        in[1] = pin2;
      end  
      if(i == 2)begin
        in[2] = pin3;
      end
      if(i == 3)begin
        in[3] = pin4;
      end
      if(i == 4)begin
        in[4] = pin5;
      end
      if(i == 5)begin
        in[5] = pin6;
      end
      if(i == 6)begin
        in[6] = pin7;
      end
      if(i == 7)begin
        in[7] = pin8;
      end
    end
    if(mem[2][i])
      out[i] = 1'b0;
  end				
end
endmodule