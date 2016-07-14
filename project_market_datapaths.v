// let's verilog

// GLOBAL LOW RESET

module led_flash(cue, CLOCK_EXTERNAL, LED, reset);
	/* flash LED when the cue signal is on. cue should be internal to the circuit. */
	input cue;
	input reset;
	input CLOCK_EXTERNAL;
	output [9:0] LED;
	
	always @(*) begin
		if (flash_signal)
			LED <= 10'b1111_1111_11;
		else
			LED <= 10'b0000_0000_00;
	end
	
	wire flash_signal;
	
	ratedivider flash(.clock_50(CLOCK_EXTERNAL),
							.rate_select(4'b0000),
							.rate(flash_signal),
							.reset(reset)
							);
							
	endmodule
	
module ratedivider(clock_50, rate_select, rate, reset)
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
		

module price_gen_datapath(clock, current_price, randomgen, new_price);
	/* generates the price of a stock. */
	
	parameter UPPER_BOUND = 100;
	/* An upper bound on the price. */
	parameter LOWER_BOUND 20;
	/* A lower bound on the price of the stock.*/
	parameter FLUCTUATION = "ONE EIGHTH";
	/* Tells how much the stock is allowed to vary. */
	
	
	/* declare inputs and outputs. */
	input clock;
	input current_price;
	input randomgen;
	output new_price;
	
	reg range = ()
	
	RNG random(.clock(clock),
					.range(),
					.randomgen())

module RNG(clock, range, randomgen);
	/* Generates random value <randomgen> based on the range allowed to clock. */
	input clock;
	input range;
	output randomgen;
	
	reg 
	
	always@(posedge clock)
	begin
	
	end
	
endmodule