// let's verilog

// GLOBAL LOW RESET

/* ######################## STORAGE MODULES ############################## */

module global_simulation(in, out);
/* this is the global simulation file. all data is stored in
this simulation file. */

master_control global_control(.

RAM_1port global_RAM(.address(address),
							.data(data),
							.aclr(reset),
							.clock(CLOCK_50),
							.wren(write_enable)
							.q(memory_out)
							);

/* ######################## FARM SIMULATION MODULES ###################### */

module farm_control(things);
endmodule

module calc_crop_yield(en, conditions, cropA_init, cropC_init, cropA_yield, cropC_yield);
	input enable;
	input [3:0] conditions;
	input [7:0] cropA_init;
	input [7:0] cropC_init;
	output [7:0] cropA_yield;
	output [7:0] cropC_yield;
	
	begin initial
	$display("to-do");
	end

endmodule


/* ######################## MARKET SIMULATION MODULES #################### */

module stock_qty_gen_datapath(enable, clock_50, sell_amt, stock_price, qty_init, qty_out, cash_init, cash_out);
	/* generates the leftover stock. must be instantiated twice for each stock in the final design! */
	input enable;
	input clock_50;
	input [7:0] sell_amt;
	input [11:0] stock_price;
	input [7:0] qty_init;
	input [23:0] cash_init;
	output [7:0] qty_out;
	output [23:0] cash_out;
	
	always@(*) begin: calculate
		if (!enable)
			disable calculate; //check this
		else if (sell_amt > qty_init) begin
			cash_out = cash_in;
			qty_out = qty_in;
			end
		else if (sell_amt <= qty_init) begin
			cash_out = cash_in + (sell_amt * stock_price);
			qty_out = qty_in - sell_amt;
			end
		end
	
	
endmodule


module price_gen_datapath(enable, clock_50, price_init, price_out);
	/* generates the price of a stock. must be instantiated twice for each stock in the final design!*/
	
	parameter UPPER_BOUND = 2'hFF;
	/* An upper bound on the price. */
	parameter LOWER_BOUND 2'h00;
	/* A lower bound on the price of the stock.*/
	parameter FLUCTUATION = 4'b0101;
	/* Tells how much the stock is allowed to vary. Corresponds to upper bound in RNG module.
		DO NOT MAKE FLUCTUATION == 8 */
	
	
	/* declare inputs and outputs. */
	input enable; //fix this
	input clock_50;
	input [11:0] price_init;
	output reg [11:0] price_out;
	
	reg [7:0] price_adjustment;
	
	RNG random_ngen(.clock_50(clock_50),
				 .upper_bound(FLUCTUATION),
				 .random_output(price_adjustment)
				 );
	
	assign bounded = (price_init <= UPPER_BOUND) & (price_init >= LOWER_BOUND)
	assign neg_sign = price_adjustment[FLUCTUATION + 1'b1]
	
	always @(*) begin: get_price
		if (!enable)
			disable get_price; // check to make sure that the 'disable' command works.
		if (bounded) begin
			if (neg_sign)
				price_out = price_init - price_adjustment[FLUCTUATION:0];
			else
				price_out = price_init + price_adjustment[FLUCTUATION:0];
			end
		else begin
			if (price_init > UPPER_BOUND)
				price_out = price_init - (price_adjustment[FLUCTUATION:0] << 1);
			else if (price_init < LOWER_BOUND)
				price_out = price_init - (price_adjustment[FLUCTUATION:0] << 1);
				
	end
	
	
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

