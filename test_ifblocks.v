module test(in, out);
	input in;
	output reg out;
	
	always @(*) begin
		if (in == 1) begin
			out <= 1;
			$display("this is the first message");
			end
		else if (in == 0)
			out <= 0;
		else if (in > 1'b1)
			$display("print to system if in is %b and more than one if/elif block runs \
						in an always block", in);
	end
endmodule

module test_case_blocks(in, out);
	// tests multiline case blocks.
	input in;
	output reg out;
	
	always @(*) begin
		case(in)
			1'b1: begin 
				out <= 1;
				$display("display the first message");
				$display("display the second message");
				end
			1'b0: begin 
				out <= 0;
				$display("display the third message");
				end
			default: out <= 0;
		endcase
	end
endmodule
