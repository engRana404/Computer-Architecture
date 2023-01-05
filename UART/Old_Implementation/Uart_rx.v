//1 start_bit + 8 data_bits + 1 stop_bit
module Uart_rx
#(
    parameter DBITS=8
)
(clk,reset,s_tick,rx_start,rx_done,rx_dout);
input          clk, s_tick; 
input          rx_start; 
input          reset;
output reg     rx_done;
output [DBITS-1:0]      rx_dout;

reg  [3:0]      OS_count, OS_count_next;//oversampling counter max:15
reg  [3:0]      data_count, data_count_next; //d0:d8-->8 data bits
 
reg  [DBITS-1:0] ShiftReg, ShiftReg_next;
reg  [1:0]      state, nextstate;

//FSM
parameter      IDLE        = 2'b00;
parameter      START       = 2'b01;
parameter      RX_DATA     = 2'b10;
parameter      STOP        = 2'b11;
// state to nextstate with clk in this block.
always@(posedge clk or negedge reset)begin
    if(!reset) begin
        state <= IDLE;
        OS_count<=0;
        data_count<=0;
        ShiftReg<=0;
    end
    else begin
        state <= nextstate;
        OS_count<=OS_count_next;
        data_count<=data_count_next;
        ShiftReg<=ShiftReg_next;
    end
end

// nextstate transform
always@(*) begin
  nextstate=state;
  OS_count_next=OS_count;
  data_count_next=data_count;
  ShiftReg_next=ShiftReg;
  rx_done=1'b0;
    case(state)
    IDLE: begin
        if(rx_start==0) begin
            OS_count_next=0;
            nextstate = START;
        end
    end
    START: begin
      if(s_tick) 

        if(OS_count==7) //OS_count==7
        begin
            OS_count_next=0;
            data_count_next=0;
            nextstate = RX_DATA;
        end
        else 
          OS_count_next=OS_count+1; 
    end
    RX_DATA: begin
      
if(s_tick)
        if(OS_count == 15) begin
          OS_count_next=0;
          ShiftReg_next= {rx_start, ShiftReg[7:1]};
          if(data_count==(DBITS-1))     
              nextstate = STOP;
          else  
            data_count_next=data_count+1; 
        end
        else 
            OS_count_next=OS_count+1;  
    end
    
    STOP: begin
        if(OS_count==15) begin
            rx_done=1'b1;
            nextstate = IDLE;
        end
        else 
          OS_count_next=OS_count+1;     
    end
    endcase
end
    assign rx_dout=ShiftReg;
endmodule
