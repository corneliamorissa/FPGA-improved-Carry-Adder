# FPGA-improved-Carry-Adder

This final project university (a team of 2 member) is an echo system with an improved Carry Adder. The system receives 2 operands via
a python script, adds them together and sends them back. The data is received and transmitted
according to the UART protocol. The echo system is only able to add up the operands and no other
operations. The maximum adder width of the echo system is 64 bits and the operands that the adder
receives consist of 512 bits. The final improved carry adder that we implement is Carry Select Adder
using Ripple Carry Adders that could have positive WNS up to 64 bits adder width

The number of cycles for our Carry Select Adder (the latency)
𝑂𝑝𝑒𝑟𝑎𝑛𝑑 𝑤𝑖𝑑𝑡ℎ ÷ 𝐴𝑑𝑑𝑒𝑟 𝑤𝑖𝑑𝑡ℎ = 512 ÷ 64 = 8 𝑐𝑦𝑐𝑙𝑒𝑠
The total delay is given by :
𝑡𝑅𝐶𝐴,8 + 3 × 𝑡𝑀𝑈𝑋 = [3 + (8 − 1) × 2] + 3 × 3 = 26 𝑙𝑜𝑔𝑖𝑐 𝑔𝑎𝑡𝑒 𝑑𝑒𝑙𝑎𝑦𝑠
For a 64-bit RCA would be:
𝑡𝐹𝐴,𝑆𝑈𝑀 + 63 × 𝑡𝐹𝐴,𝐶𝐴𝑅𝑅𝑌 = 3 + 63 × 2 = 129 𝑙𝑜𝑔𝑖𝑐 𝑔𝑎𝑡𝑒 𝑑𝑒𝑙𝑎𝑦𝑠
The delay of the final project is just under 5 times less logic gates than if a regular ripple carry adder
were used instead of our implementation to do 64-bit additions.
