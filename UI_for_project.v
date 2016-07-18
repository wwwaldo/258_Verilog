`timescale 1ns / 1ns // `timescale time_unit/time_precision

//SW[7:0] input signal

//KEY[0] HEX_display toggle
//KEY[1] sell menu toggle
//KEY[2] reset (FSM goes to HEXA)
//SW[8] reset (selected sell quantity goes to 00)
//KEY[3] confirm sell
//IMPLEMENT "Error" for case where player sells too much
//IMPLEMENT pretty letters like "L" and "r" and "o" and " " (blank letter)

module sell_menu(enter,
						stockA_price,
						stockA_qty,
						stockC_price,
						stockC_qty,
						SW,
						KEY,
						CLOCK_50,
						stockA_sold,
						stockC_sold,
						exit,
						HEX5,
						HEX4,
						HEX3,
						HEX2,
						HEX1,
						HEX0,
						current_cash);
	input enter;
	input [11:0] stockA_price;
	input [7:0] stockA_qty;
	input [11:0] stockC_price;
	input [7:0] stockC_qty;
	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;
	input [23:0] current_cash;
	output [7:0] stockA_sold;
	output [7:0] stockC_sold;
	output exit;
	output [6:0] HEX5;
	output [6:0] HEX4;
	output [6:0] HEX3;
	output [6:0] HEX2;
	output [6:0] HEX1;
	output [6:0] HEX0;
	
	// wires for ratedivider
	wire two_seconds;
	// wires for sell_qty
	wire stocks_sold;
	
	sell_display sell(
					.enter(enter),
					.SW(9'b0),
					.KEY(KEY[3:0]),
					.stockA_price(stockA_price[11:0]),
					.stockA_qty(stockA_qty[7:0]),
					.stockC_price(stockC_price[11:0]),
					.stockC_qty(stockC_qty[7:0]),
					.hex_signal(hex_signal[23:0]),
					.exit(exit)
					);

					
	register sell_qty(
					.clock(CLOCK_50),
					.reset_n(SW[9]),
					.toggle(SW[8])
					.d(SW[7:0]),
					.q(stocks_sold)
					);
	
	hex_decoder H5(
					.hex_digit(hex_signal[23:20]),
					.segments(HEX5)
					);
	
	hex_decoder H4(
					.hex_digit(hex_signal[19:16]),
					.segments(HEX4)
					);

	hex_decoder H3(
					.hex_digit(hex_signal[15:12]),
					.segments(HEX3)
					);

	hex_decoder H2(
					.hex_digit(hex_signal[11:8]),
					.segments(HEX2)
					);

	hex_decoder H1(
					.hex_digit(hex_signal[7:4]),
					.segments(HEX1)
					);

	hex_decoder H0(
					.hex_digit(hex_signal[3:0]),
					.segments(HEX0)
					);					
endmodule
					
// FSM portion
module sell_display(enter, SW, KEY, stockA_price, clock_50,
					stockA_qty, stockC_price, stockC_qty, hex_signal, exit);
    input enter;
	 input [9:0] SW;
	 // set [9:0] SW always low
    input [3:0] KEY;
	 input [11:0] stockA_price;
	 input [7:0] stockA_qty;
	 input [11:0] stockC_price;
	 input [7:0] stockC_qty;
    output reg [23:0] hex_signal;
	 output reg exit;
 
    wire w, x, resetn, hex_signal;
    
    reg [1:0] current_state, next_state; // y_Q represents current state, Y_D represents next state
    
    // now let's change localparam to something that actually works
	 // localparam Z = 6'hA = 4'b0000, B = 4'b0001, C = 4'b0010;
    // A is HEXA (w goes to B), B is HEXC (w goes to C), C is Sell display (w goes to A, x exits FSM)
	 // TODO
	 
    assign w = ~KEY[0];
	 assign x = ~KEY[3];
    assign resetn = ~KEY[2];

    //State table
    //The state table should only contain the logic for state transitions
    //Do not mix in any output logic. The output logic should be handled separately.
    //This will make it easier to read, modify and debug the code.
	 
	 wire two_seconds;
	 ratedivider two_seconds(
					.clock_50(clock_50),
					.rate_select(4'b0100),
					.rate(two_seconds),
					.reset(1'b1)
					);
	 
	 reg [1:0] timer = 2'b10;
	 reg sell_out_menu; 
	 always@(*)
		begin
		sell_out_menu = 0;
		if (timer == 0)
			sell_out_menu = 1;
		if (two_seconds)
			timer = timer - 1;
		end
	 
    always@(*)
    begin: state_table
		  exit = 1'b0;
		  if (!resetn)
		      next_state <= Z;
		  else begin
            case (current_state)
				    Z: begin
					     if (!enter) next_state = Z;
					  	  else next_state = A;
                   end
					 A: begin
                    if (!w) next_state <= A;
                    else next_state <= B;
                   end
                B: begin
                    if(!w) next_state <= B;
                    else next_state <= C;
                   end
                C: begin
                    if((!w && !x) || (w && x)) next_state <= C;
						  // I added the (w && x) condition in
						  // case someone tries to sell and toggle
						  // at the same time
						  else if (w && !x) next_state <= A;
						  else
						      begin
						      exit = 1'b1;
						      next_state <= D;
								end
						  // set exit = 1
					     begin
					 D: begin
					     if (sell_out_menu)
							   next_state <= E;
						  else
							   next_state <= D;
                   end
					 E: next_state <= E;
					 // this will have next_state assigned to the next year,
					 // instead of E. But we end here for week 1.
            default: next_state = Z;
            endcase
        end
    end // state_table
   
	 always @(*)
	 begin: enable_signals
	     // By default make all our signals 0
		  // hex_signal = 23b'0;
		  exit = 1'b0;
		  case (current_state)
		      Z: begin
				    end
				A: begin
				    hex_signal [23:12] = stockA_price [11:0];
					 hex_signal [11:8] = 8'h0A;
					 hex_signal [7:0] = stockA_qty [7:0];
				    end
				B: begin
				    hex_signal [23:12] = stockC_price [11:0];
					 hex_signal [11:8] = 8'h0C;
					 hex_signal [7:0] = stockC_qty [7:0];
				    end
				C: begin
				    hex_signal [23:20] = 4'hA;
					 hex_signal [11:8] = 4'hC;
					 if (SW[8] == 0)
						  begin
					     cropA_digit1 [3:0] = SW[7:4];
						  cropA_digit2 [3:0] = SW[3:0];
						  hex_signal [19:16] = cropA_digit1[3:0];
						  hex_signal [15:12] = cropA_digit2[3:0];
						  stockA_sold = hex_signal [19:12];
					     stockC_sold = hex_signal [11:4];
						  end
					 else if (SW[8] == 1)
					     begin
					     cropC_digit1 [3:0] = SW[7:4];
						  cropC_digit2 [3:0] = SW[3:0];
						  hex_signal [7:4] = cropC_digit1[3:0];
						  hex_signal [3:0] = cropC_digit2[3:0];
						  stockA_sold = hex_signal [19:12];
					     stockC_sold = hex_signal [11:4];
						  end
				    // This is where the player decides how much to sell
					 end
				D: begin
					 hex_signal [23:20] = 4'h5;
					 hex_signal [19:16] = 4'h0;
					 hex_signal [15:12] = 4'h0;
					 hex_signal [11:8] = 4'h0;
					 hex_signal [7:4] = 4'h1;
					 hex_signal [3:0] = 4'hD;
				   end
				E: begin
				    hex_signal [23:20] = current_cash [23:20];
					 hex_signal [19:16] = current_cash [19:16];
					 hex_signal [15:12] = current_cash [15:12];
					 hex_signal [11:8] = current_cash [11:8];
					 hex_signal [7:4] = current_cash [7:4];
					 hex_signal [3:0] = current_cash [3:0];
				   end
					 
    // State Registers
    always @(posedge clock_50)
    begin: state_FFs
        if(resetn == 1'b0)
            current_state <= Z; // Should set reset state to state Z
        else
            current_state <= next_state;
    end // state_FFS
endmodule

// This should count 2 seconds using rate_select = 4'b0100
module ratedivider(clock_50, rate_select, rate, reset);
	/* Copy of ratedivider from previous lab. */
	input clock_50; //this should be connected to clock_50
	input [3:0] rate_select;
	input reset; // just set this to high always
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
	// set clock always 0
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
            default: segments = 7'h7f;
        endcase
endmodule
