/* USER INTERFACE STUFF
/ 3) Implement basic menu (UI) to display current stock quantities and stock prices
	-We'll call this stock_A, stock_b, displaying price and quantity info for either
	stock, with the HEX displaying showing things as follows (0 on right-most):
	stock_A:
	-HEX[5:3]: stock A price
	-HEX2: displays "A"
	-HEX[1:0]: Max amount of stock 1 to sell
	stock_b:
	-HEX[5:3]: stock b price
	-HEX2: displays "b"	
	-HEX[1:0]: Max amount of stock b sell
	-Implementation of stock quantities and prices from RNG
4) Implement sell menu with call to datapath upon user input
	-We'll call this sell_menu, where displays are as follows:
	-HEX5: Displays "A"
	-HEX[4:3]: Amount of stock A user wants to sell
		-Default display is "00", over HEX4, HEX3
	-HEX2: Displays "b"
	-HEX[1:0]: Amount of stock b2 user wants to sell
		-Default display is "00", over HEX1, HEX0
	-Toggle between stock_A, stock_b, and sell_menu using KEY[0], choices are destroyed
	when toggling
	-Toggle between selecting amount to sell for stock A and stock b using KEY[1]
	-User input on SW[7:4] for larger digit, SW[3:0] for smaller digit when selling
	(update as user inputs)
	-Confirm sell on KEY[3], display "SOLd" on HEX[3:0] for 2 seconds
	-Display current cash "C$$$$$" after selling on HEX[5:0]
5) Terminate user input and initiate next time cycle, call datapath to generate new
   market prices
	-Datapath to calculate current price
*/



module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
				// These read backwards, with the 0'th segment on the right
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
				// 5 also doubles as "S"
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
				// added line for L
				4'hL: segments = 7'b100_0111;
            default: segments = 7'h7f;
        endcase
endmodule
