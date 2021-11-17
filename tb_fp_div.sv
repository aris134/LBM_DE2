module tb_fp_div();

    parameter CLK_PERIOD = 20;  // 20 ns == 100 MHz
    parameter WIDTH = 32;
    parameter FBITS = 24;

    logic clk;
    logic start;            // start signal
    logic busy;             // calculation in progress
    logic valid;            // quotient and remainder are valid
    logic dbz;              // divide by zero flag
    logic ovf;              // overflow flag (fixed-point only)
    logic signed [WIDTH-1:0] x;    // dividend
    logic signed [WIDTH-1:0] y;    // divisor
    logic signed [WIDTH-1:0] q;    // quotient
    logic signed [WIDTH-1:0] r;    // remainder
	 

    fp_div #(.WIDTH(WIDTH), .FBITS(FBITS)) div_inst (.*);

    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        clk = 0;

        #10     x = 32'h00_800000;// 0.5
                y = 32'h00_080000;// 0.03125
                start = 1;
        #20     start = 0; // need to deassert the start signal


        #1200	$finish;

        // ...
    end
endmodule
