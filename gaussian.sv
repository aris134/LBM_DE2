/* VELOCITY DISTRIBUTION PARAMETERS
	UY: OFFSET = 32'hFF_FDF3B7, SHIFTAMT = 7
	UX: OFFSET = 32'hFF_FC28F6, SHIFTAMT = 6
*/

module gaussian #(DATA_WIDTH=32, FRACTIONAL_BITS=24, OFFSET=32'hFF_FDF3B7, SHIFTAMT=7)
				 (input logic Clk,
				  input logic Enable,
				  input logic Reset,
				  input logic signed [FRACTIONAL_BITS:0] seed,
				  output logic signed [DATA_WIDTH-1:0] randnum);
				  
logic signed [FRACTIONAL_BITS:0] lfsr_out;
logic signed [FRACTIONAL_BITS:0] scrambled_1;
logic signed [FRACTIONAL_BITS:0] scrambled_2;
logic signed [FRACTIONAL_BITS:0] scrambled_3;
logic signed [FRACTIONAL_BITS:0] rshift_1;
logic signed [FRACTIONAL_BITS:0] rshift_2;
logic signed [FRACTIONAL_BITS:0] rshift_3;
logic signed [FRACTIONAL_BITS:0] rshift_4;
logic signed [FRACTIONAL_BITS:0] sum_1;
logic signed [FRACTIONAL_BITS:0] sum_2;
				  
lfsr_25 lfsr (.Clk(Clk), .Enable(Enable), .Reset(Reset), .seed(seed), .pseudo_rand(lfsr_out));
scrambler1 scram1 (.lfsr_out(lfsr_out), .scramble_out(scrambled_1));
scrambler2 scram2 (.lfsr_out(lfsr_out), .scramble_out(scrambled_2));
scrambler3 scram3 (.lfsr_out(lfsr_out), .scramble_out(scrambled_3));

always @*
begin
	rshift_1 = lfsr_out >> 1;
	rshift_2 = scrambled_1 >> 1;
	rshift_3 = scrambled_2 >> 1;
	rshift_4 = scrambled_3 >> 1;
	sum_1 = rshift_1 + rshift_2;
	sum_2 = rshift_3 + rshift_4;
	randnum = {7'b0000000, (((sum_1 >> 1) + (sum_2 >> 1)) >> SHIFTAMT)} + OFFSET;
end

endmodule

				