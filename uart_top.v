//Engineer: Cornelia Morissa Untung

`timescale 1ns / 1ps

module uart_top #(
    parameter   OPERAND_WIDTH = 512,
    parameter   ADDER_WIDTH   = 32,
    parameter   NBYTES        = OPERAND_WIDTH / 8,
    // values for the UART (in case we want to change them)
    parameter   CLK_FREQ      = 125_000_000,
    parameter   BAUD_RATE     = 115_200
  )  
  (
    input   wire   iClk, iRst,
    input   wire   iRx,
    output  wire   oTx
  );
  
  // Buffer to exchange data between Pynq-Z2 and laptop
  reg [NBYTES*8-1:0] rA;
  reg [NBYTES*8-1:0] rB;
  reg [(NBYTES+1)*8-1:0] rRes; //+1 byte to include carry bits
  wire [OPERAND_WIDTH:0] wRes;

  reg rStart;
  
  wire wDone;
  
  // State definition  
  localparam s_IDLE         = 3'b000;
  localparam s_WAIT_RX      = 3'b001;
  localparam s_TX           = 3'b010;
  localparam s_WAIT_TX      = 3'b011;
  localparam s_DONE         = 3'b100;
  localparam s_RX           = 3'b101;
  localparam s_ADDER        = 3'b110;
  
  // Command definition
  localparam c_ADDITION = 1'hA;

   
  // Declare all variables needed for the finite state machine 
  // -> the FSM state
  reg [2:0]   rFSM;  
  reg [2:0] rCalculator;
  
  // Connection to UART TX (inputs = registers, outputs = wires)
  reg         rTxStart;
  reg [7:0]   rTxByte;
  wire        wTxBusy;
  wire        wTxDone;
  
      
  uart_tx #(  .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) )
  UART_TX_INST
    (.iClk(iClk),
     .iRst(iRst),
     .iTxStart(rTxStart),
     .iTxByte(rTxByte),
     .oTxSerial(oTx),
     .oTxBusy(wTxBusy),
     .oTxDone(wTxDone)
     );
  // Connection to UART RX (inputs = registers, outputs = wires)
    wire [7:0]   wRxByte;
    wire        wRxDone;


   uart_rx #(  .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) )
  UART_RX_INST
    (.iClk(iClk),
     .iRst(iRst),
     .iRxSerial(iRx),
     .oRxByte(wRxByte),
     .oRxDone(wRxDone)
     );  
     
mp_adder #(.OPERAND_WIDTH(OPERAND_WIDTH), .ADDER_WIDTH(ADDER_WIDTH) )MP_ADDER_INST
    (.iClk(iClk),
     .iRst(iRst),
     .iStart(rStart),
     .iOpA(rA),
     .iOpB(rB),
     .oRes(wRes),
     .oDone(wDone)
     ); 
     
     
  
  reg [$clog2(NBYTES):0] rCnt;
  reg [$clog2(NBYTES):0] rBufferCnt, rBDone;
  
  


  always @(posedge iClk)
  begin
  
  // reset all registers upon reset
  if (iRst == 1 ) 
    begin
      rFSM <= s_IDLE;
      rTxStart <= 0;
      rCnt <= 0;
      rTxByte <= 0;
      rStart <= 0;
      rRes <= 0;
      rA <= 0;
      rB <= 0;
      rBDone <=0;
    end 
  else 
    begin
      case (rFSM)
   
        s_IDLE :
          begin
            rFSM <= s_WAIT_RX;
            rCnt <= 0;
              rTxByte <= 0;
              rStart <= 0;
              rRes <= 0;
              rA <= 0;
              rB <= 0;
              rBDone <= 0;
          end
          
          
        s_WAIT_RX :
          begin
//          if((rCnt == 0) && (wRxDone == 1) && (rBDone ==0))
//          begin
//            rFSM <= s_WAIT_RX;
//            rCnt <= 0;
//            if(wRxByte == "+")
//            begin
//                rCalculator <= 3'b110; //for ADDER
//            end
//          end
//          else 
          if ((rCnt < NBYTES) && (wRxDone == 1) && (rBDone ==0) ) 
          begin
            rFSM <= s_WAIT_RX;
            rA <= {rA[NBYTES*8-9:0] , wRxByte}; // 
            rCnt <= rCnt + 1;
          end
           else if ((rCnt >= NBYTES) &&(rCnt < (NBYTES*2)-1) && (wRxDone == 1) && (rBDone ==0) ) 
              begin
                rFSM <= s_WAIT_RX;
                rB <= {rB[NBYTES*8-9:0] , wRxByte}; // 
                rCnt <= rCnt + 1;
                rA<= rA;
              end
           else if((rCnt == (NBYTES*2)-1) && (wRxDone == 1) && (rBDone ==0))
           begin
                rFSM <= s_WAIT_RX;
                rB <= {rB[NBYTES*8-9:0] , wRxByte}; // 
                rCnt <= 0;
                rA<=rA;
                rBDone <= 1;
           end
 
          else if ((rCnt == 0) && (rBDone == 1))
               begin
               rStart <= 1;
               rFSM <= s_ADDER;
               rCnt <= 0;
               rRes <= 0;
               rA <= rA;
               rB <= rB;
               end
               
          else
          begin
            rFSM <= s_WAIT_RX;
            rA<=rA;
            rB<=rB;
          end
          
          end 
        
        s_ADDER:
           begin
           if(wDone == 0)
                begin
                rFSM <= s_ADDER;
                end
           else
               begin
                rRes <= wRes;  
                rFSM <= s_TX;
               end
           end
             
        s_TX :
          begin
            if ( (rCnt < NBYTES + 1) && (wTxBusy ==0) ) 
              begin
                rFSM <= s_WAIT_TX;
                rStart <= 0;
                rTxStart <= 1;          // we send the uppermost byte
                rTxByte <= rRes[(NBYTES+1)*8-1:(NBYTES+1)*8-8];            // we send the uppermost byte
                rRes <= {rRes[(NBYTES+1)*8-9:0] , 8'b0000_0000};    // we shift from right to left
                rCnt <= rCnt + 1;
              end 
            else 
              begin
                rFSM <= s_IDLE;
                rTxStart <= 0;
                rTxByte <= 0;
                rCnt <= 0;
              end
            end 
            
            s_WAIT_TX :
              begin
                if (wTxDone) 
                begin
                  rFSM <= s_TX;
                end 
                else 
                begin
                  rFSM <= s_WAIT_TX;
                  rTxStart <= 0;                   
                end
              end 
              
            s_DONE :
              begin
                rFSM <= s_IDLE;
                
              end 
              

            default :
              begin
              rFSM <= s_IDLE;
              rStart <= 0;
              rRes <= 0;
              end
             
          endcase
      end
    end       
endmodule