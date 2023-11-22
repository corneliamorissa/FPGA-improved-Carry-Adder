`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Cornelia Morissa Untung
// 
// Create Date: 19.02.2023 21:23:15
// Design Name: 
// Module Name: full_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module full_adder(
    input wire iA, iB, iCarry,
    output wire oSum,oCarry
    );
    
    wire w1, w2, w3;
    
    //XOR A and B
    assign w1 = iA^iB;
    
    //XOR for oSum
    assign oSum = w1 ^ iCarry;
    
    //AND for w2 between w1 & iCarry
    assign w2 = w1 & iCarry;
    
    //oCarry = w2 | w3
    assign w3 = iB & iA;
    assign oCarry = w2 | w3;
    
endmodule
