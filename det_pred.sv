module det_pred #(DATA_WIDTH=32)
	(input logic signed [DATA_WIDTH-1:0] epsilon,
	 input logic signed [DATA_WIDTH-1:0] ux,
	 input logic signed [DATA_WIDTH-1:0] uy,
	 input logic signed [DATA_WIDTH-1:0] ux_pred,
	 input logic signed [DATA_WIDTH-1:0] uy_pred,
	 output logic can_pred);
	 
logic signed [DATA_WIDTH-1:0] ux_diff;
logic signed [DATA_WIDTH-1:0] uy_diff;
logic signed [DATA_WIDTH-1:0] ux_abs_diff;
logic signed [DATA_WIDTH-1:0] uy_abs_diff;
assign ux_diff = ux - ux_pred;
assign uy_diff = uy - uy_pred;

abs #(.DATA_WIDTH(DATA_WIDTH)) abs_ux_diff (.non_abs(ux_diff), .abs(ux_abs_diff));
abs #(.DATA_WIDTH(DATA_WIDTH)) abs_uy_diff (.non_abs(uy_diff), .abs(uy_abs_diff));
	
always @*
begin
	can_pred = (ux_abs_diff < epsilon && uy_abs_diff < epsilon) ? 1'b1 : 1'b0;
end

endmodule

	
	 
	