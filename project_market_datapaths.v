// let's verilog

// GLOBAL LOW RESET

/* ######################## STORAGE MODULES ############################## */



/* ######################## MARKET SIMULATION MODULES #################### */

module calculate 


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
endmodule





/* ####################### EXTERNAL ANIMATION MODULES ####################### */

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
	


/* ############################ TIMING MODULES ########################### */

module ratedivider(clock_50, rate_select, rate_enable, reset);
	/* This module takes the standard 50MHz FPGA clock
		and modifies its frequency depending on the choice
		of <timer>. Ex. choosing rate_select == 0 gets a clock which outputs
		every 1Hz.*/
	input clock_50; //this should be connected to clock_50
	input reset;
	input [3:0] rate_select;
	output rate_enable;
	
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
		
	assign rate_emable = (count == 0)
endmodule

module clock_counter(clock_50, reset, freeze, clock_value);
	/* A module which is structurally similar to ratedivider.
		Instead of outputting a variable-frequency clock,
		this module outputs the current value of the input clock.
		Due to bus sizes it should be assumed that the clock speed is 
		50MHz maximum. */
	input clock_50; //connect to CLOCK_50.
	input freeze; //freeze the output. Low freeze.
	input reset; //freeze the output to 0. Low reset.
	output [31:0] clock_value;
	
	always @(posedge clock or negedge reset or negedge freeze) begin
		if (!reset)
			count <= 0;
		else if (!freeze)
			count <= count
		else if (count == 8'd49_999_999)
			count <= 0;
		else
			count <= count + 1'b1;
	end		
endmodule

module RNG(clock_50, upper_bound, random_output);
	/* Generates an 8-bit random value <random_output> based on the range allowed to clock.
		The input clock should be 50MHz.
		
		The upper bound specifies the number of digits of random output <in binary>.
		
		If the RNG is invoked multiple times in quick succession, it should 
		generate different outputs. If this functionality is needed,
		we can implement a 'n -random generator' which takes its 'random'
		values from different functions of the clock input.
		
		*/
	input clock_50;
	input [3:0] upper_bound;
	output reg [7:0] random_output;
	
	reg freeze; 
	reg [31:0] clock_value
	
	clock_counter clock(.clock_50(clock_50),
								.reset(1'b1),
								.freeze(freeze),
								.clock_value(.clock_value))
	
	always@(*) begin 
		freeze <= 1'b1
			if (upper_bound < 4'b1001)
				freeze = 1'b0;
			//this is intended as a temporary freeze for the cycle.
			case:(upper_bound)
				4'b0000: random_output = 8'b0000_0000;
				4'b0001: random_output = {7'b0000_000, clock_value[0]};
				4'b0010: random_output = {6'b0000_00, clock_value[1:0]};
				4'b0011: random_output = {5'b0000_0, clock_value[2:0]};
				4'b0100: random_output = {4'b0000, clock_value[3:0]};
				4'b0101: random_output = {3'b000, clock_value[4:0]};
				4'b0110: random_output = {2'b00, clock_value[5:0]};
				4'b0111: random_output = {1'b0, clock_value[6:0]};
				4'b1000: random_output = clock_value[7:0];
				default: random_output = clock_value[7:0]; // no freeze
			endcase
		end	
endmodule

