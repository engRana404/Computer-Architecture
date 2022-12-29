//1 start_bit + 8 data_bits + 1 stop_bit
module Uart_rx
#(
    parameter DBITS = 8 
)
(clk,rx_done,rx_dout);
input           clk; 
output reg     rx_done;
output [DBITS-1:0]      rx_dout;
reg  [3:0]      OS_count;//oversampling counter max:15
reg  [3:0]      data_count; //d0:d8-->8 data bits
reg             rx_start;  
reg  [DBITS-1:0] ShiftReg;
reg  [2:0]      state;
reg  [2:0]      nextstate;

//FSM
parameter      IDLE        = 2'b00;
parameter      START       = 2'b01;
parameter      RX_DATA     = 2'b10;
parameter      STOP        = 2'b11;
// nextstate transform
always@(*) begin
  data_count=4'd0;
    case(state)
    IDLE: begin
        if(rx_start==4'd0) begin
            OS_count=0;
            nextstate = START;
        end
        else begin
            nextstate = IDLE;
        end
    end
    START: begin
        if(OS_count==4'd7) //OS_count==7
        begin
            OS_count=0;
            nextstate = RX_DATA;
        end
        else begin
            OS_count=OS_count+1;
            nextstate = START;
        end
    end
    RX_DATA: begin
        if(OS_count == 4'd15) begin
          OS_count=0;
          ShiftReg= rx_start|(ShiftReg>>1);
          if(data_count==(DBITS-1)) begin    
                nextstate = STOP;
            end
          else begin
            data_count=data_count+1;
            nextstate = RX_DATA;
          end
        end 
        else begin
            OS_count=OS_count+1;
            nextstate = RX_DATA;    
        end
    end
    
    STOP: begin
        if(OS_count==4'd7) begin
            rx_done=1;
            nextstate = IDLE;
        end
        else begin
          OS_count=OS_count+1;
          nextstate = STOP; 
        end
    end
    endcase
end
    assign rx_dout=ShiftReg;
endmodule
