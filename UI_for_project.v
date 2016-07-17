`timescale 1ns / 1ns // `timescale time_unit/time_precision

//SW[7:0] input signal

//KEY[0] HEX_display toggle
//KEY[1] sell menu toggle
//KEY[2] reset (FSM goes to HEXA)
//SW[8] reset (selected sell quantity goes to 00)
//KEY[3] confirm sell

module sell_menu(stockA_price,
						stockA_qty,
						stockC_price,
						stockC_qty,
						SW,
						KEY,
						CLOCK_50,
						stockA_sold,
						stockC_sold);
	input [11:0] stockA_price;
	input [7:0] stockA_qty;
	input [11:0] stockC_price;
	input [7:0] stockC_qty;
	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;
	output [7:0] stockA_sold;
	output [7:0] stockC_sold;
	
	// wires for ratedivider
	wire two_seconds;
	wire set_half_hertz;
	// wires for sell_qty
	wire stocks_sold;
	
	assign set_half_hertz = 4'b0100;
	
	sell_menus sell(
					.SW(do we need this???),
					.KEY(KEY[3:0]),
					.number(number[15:0]),
					.hex_signal(hex_signal[15:0]),
					.exit(exit)
					);
	
	ratedivider two_seconds(
					.clock_50(CLOCK_50),
					.rate_select(set_rate),
					.rate(two_seconds),
					.reset(do we need this???)
					);
					
	register sell_qty(
					.clock(CLOCK_50),
					.reset_n(SW[9]),
					.toggle(SW[8])
					.d(SW[7:0]),
					.q(stocks_sold)
					);
	
	hex_decoder H5(
					.hex_digit(),
					.segments()
					);
					// use a multiplexer to choose which one to display, depending on the menu you are in
	
	

// FSM portion
module sell_menus(SW, KEY, number, hex_signal, exit);
    input [9:0] SW;
	 // Don't think we actually need SW...
    input [3:0] KEY;
	 input [15:0] number;
    output reg [15:0] hex_signal;
	 output reg exit;
 
    wire w, x, resetn, hex_signal;
    
    reg [1:0] y_Q, Y_D; // y_Q represents current state, Y_D represents next state
    
    localparam A = 4'b0000, B = 4'b0001, C = 4'b0010;
    // A is HEXA (w goes to B), B is HEXC (w goes to C), C is Sell display (w goes to A, x exits FSM)
	 // TODO
	 
    assign w = ~KEY[0];
	 assign x = ~KEY[3];
    assign resetn = ~KEY[2];

    //State table
    //The state table should only contain the logic for state transitions
    //Do not mix in any output logic. The output logic should be handled separately.
    //This will make it easier to read, modify and debug the code.
    always@(*)
    begin: state_table
        case (y_Q)
            A: begin
                   if (!w) Y_D <= A;
                   else Y_D <= B;
               end
            B: begin
                   if(!w) Y_D <= B;
                   else Y_D <= C;
               end
            C: begin
                   if((!w && !x) || (w && x)) Y_D <= C;
						 // I added the (w && x) condition in case someone tries to sell and toggle
						 // at the same time
						 else if (w && !x) Y_D <= A;
                   else Y_D <= ;
						 // set exit = 1
               end
            default: Y_D = A;
        endcase
    end // state_table
    
    // State Registers
    always @(*)
    begin: state_FFs
        if(resetn == 1'b0)
            y_Q <=  A; // Should set reset state to state A
        else
            y_Q <= Y_D;
    end // state_FFS

    // Output passes on the information from register when player decides to sell
    assign hex_signal = number;
endmodule

// This should count 2 seconds using rate_select = 4'b0100
module ratedivider(clock_50, rate_select, rate, reset);
	// we don't need "reset", do we?
	/* Copy of ratedivider from previous lab. */
	input clock_50; //this should be connected to clock_50
	input [3:0] rate_select;
	output rate;
	
	reg [31:0] timer; //up to 4.2 billion roughly
	reg [31:0] count;
	
	always @(*) begin
		case:(rate_select)
		4'b0000: timer = 8'd49_999_999; //1Hz 
		4'b0001: timer = 8'd24_999_999; //2Hz
		4'b0010: timer = 8'd12_499_999; //4Hz
		4'b0011: timer = 1; // approx. 50MHz
		4'b0100: timer = 8'd99_999_999; //0.5Hz
		default:
	end
	
	always @(posedge clock or negedge reset) begin
		if (!reset)
			count <= 0;
		else if (count == timer)
			count <= 0;
		else
			count <= count + 1'b1;
	end		
endmodule

// Register to store quantities to sell
module register(clock, reset_n, toggle, d, q);
	// an 8-bit register. In the implementation of part 2, the clock is manual!!!
	input clock;
	// do we really need clock?
	input reset_n;
	input toggle;
	input d;
	output [15:0] q;

reg [15:0] q;
	
always @(*)
begin
	if (reset_n == 1'b0) //reset is 0 is not d
		q = 0;
	else if ((reset_n == 1'b1) && (toggle == 0))
		[15:8] q = [7:0] d;
		// [15:8] q stores stockA_sold
	else
		[7:0] q = [7:0] d;
		// [7:0] q stores stockC_sold
end
endmodule

// HEX display portion
module hex_decoder(hex_digit, segments);
    input [7:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
				// These read backwards, with the 0'th segment on the right
            8'h00: segments = 7'b100_0000;
            8'h01: segments = 7'b111_1001;
            8'h02: segments = 7'b010_0100;
            8'h03: segments = 7'b011_0000;
            8'h04: segments = 7'b001_1001;
            8'h05: segments = 7'b001_0010;
				// 5 also doubles as "S"
            8'h06: segments = 7'b000_0010;
            8'h07: segments = 7'b111_1000;
            8'h08: segments = 7'b000_0000;
            8'h09: segments = 7'b001_1000;
            8'h0A: segments = 7'b000_1000;
            8'h0B: segments = 7'b000_0011;
            8'h0C: segments = 7'b100_0110;
            8'h0D: segments = 7'b010_0001;
            8'h0E: segments = 7'b000_0110;
            8'h0F: segments = 7'b000_1110;   
				// added line for L
				8'h10: segments = 7'b100_0111;
            default: segments = 7'h7f;
        endcase
endmodule
