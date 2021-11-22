/*

Authors: Aristotle Martin, Adam Krekorian

Description: This is a SystemVerilog implementation
of a Lattice Boltzmann method (LBM) solver for a 2D cavity
flow targeted at the Altera DE2-115 FPGA board. This system
employs Q8.24 fixed-point arithmetic.

This is the top-level
module.

LBM Details:

Grid: D2Q9
	-- 2 spatial dimensions (x,y)
	-- 9 discrete velocities (c0,c1,..c8)
	
BGK single-relaxation model

*/


module LBM_DE2	#(GRID_DIM=16*16, MAX_TIME=100, TIME_COUNT_WIDTH=$clog2(MAX_TIME),
		DATA_WIDTH=32, ADDRESS_WIDTH=$clog2(GRID_DIM), COUNT_WIDTH=$clog2(GRID_DIM/16),
		DATA_WIDTH_F=9*DATA_WIDTH, FRACTIONAL_BITS=24, INTEGER_BITS=DATA_WIDTH-FRACTIONAL_BITS,
		OFFSET_UX=32'hFF_FC28F6, OFFSET_UY=32'hFF_FDF3B7, SHIFTAMT_UX=6, SHIFTAMT_UY=7)
		(input logic CLOCK_50,
		input logic RESET,
		output logic FINISHED);

/***** PORT DESCRIPTION *****/
/*
	*** PARAMETERS ***
	GRID_DIM				:	Lattice grid size
	MAX_TIME				:	Number of iterations
	TIME_COUNT_WIDTH	:	Time step counter word length
	DATA_WIDTH			:	Moment variable word length
	ADDRESS_WIDTH		:	RAM address word length
	COUNT_WIDTH			:	y-coordinate word length
	DATA_WIDTH_F		:	Distribution function word length
	FRACTIONAL_BITS	:  Fixed point fractional part length
	INTEGER_BITS		:	Fixed point integer part length
	
	*** PORTS ***
	// INPUTS
	CLOCK_50				: 50 MHz oscillator on the DE2 board
	RESET					: Reset signal that is asserted at the initiation of the program
	
	// OUTPUTS
	FINISHED 			: Signal asserted by the state machine when algorithm completes
*/

	
/** SIGNAL DECLARATIONS/ASSIGNMENTS **/

/* simulation signals

	These memory variables are used to write
	out the values of the moment variables
	to a text file at the end of the simulation.
	
*/
logic signed [DATA_WIDTH-1:0] p_mem_array [GRID_DIM-1:0];
logic signed [DATA_WIDTH-1:0] ux_mem_array [GRID_DIM-1:0];
logic signed [DATA_WIDTH-1:0] uy_mem_array [GRID_DIM-1:0];

// controller signals
/*
	Write enables for
	the various RAMs
*/
logic WE_p_mem;
logic WE_ux_mem;
logic WE_uy_mem;
logic WE_fin_mem;
logic WE_f_streamed;

/*
	multiplexer selects
*/
logic select_p_mem;
logic [1:0] select_ux_mem;
logic select_uy_mem;
logic [1:0] select_ux_reg;
logic [1:0] select_uy_reg;
logic select_p_reg;
logic [1:0] select_fin_mem;
logic [3:0] select_f_streamed;
logic [3:0] select_fin_addr;
logic select_moment_addr;

/*
	counter enables
*/
logic count_init_en;
logic row_count_en;
logic time_count_en;
logic bc_addr_iter_en;

/*
	register load enables
*/
logic LD_EN_P;
logic LD_EN_PUX;
logic LD_EN_PUY;
logic LD_EN_UX;
logic LD_EN_UY;
logic LD_EN_FEQ0;
logic LD_EN_FEQ1;
logic LD_EN_FEQ2;
logic LD_EN_FEQ3;
logic LD_EN_FEQ4;
logic LD_EN_FEQ5;
logic LD_EN_FEQ6;
logic LD_EN_FEQ7;
logic LD_EN_FEQ8;

logic LD_EN_FOUT0;
logic LD_EN_FOUT1;
logic LD_EN_FOUT2;
logic LD_EN_FOUT3;
logic LD_EN_FOUT4;
logic LD_EN_FOUT5;
logic LD_EN_FOUT6;
logic LD_EN_FOUT7;
logic LD_EN_FOUT8;

logic LD_EN_f_streamed_REG_0;
logic LD_EN_f_streamed_REG_1;
logic LD_EN_f_streamed_REG_2;
logic LD_EN_f_streamed_REG_3;
logic LD_EN_f_streamed_REG_4;
logic LD_EN_f_streamed_REG_5;
logic LD_EN_f_streamed_REG_6;
logic LD_EN_f_streamed_REG_7;
logic LD_EN_f_streamed_REG_8;

logic LD_EN_UX_PRED;
logic LD_EN_UY_PRED;
logic rand_en;
logic FINISH;

assign FINISHED = FINISH;

// moment variable memory data buses
logic signed [DATA_WIDTH-1:0] p_mem_data_out;
logic signed [DATA_WIDTH-1:0] ux_mem_data_out;
logic signed [DATA_WIDTH-1:0] uy_mem_data_out;

// divider module signals
logic div_start;
logic div_busy0;
logic div_busy1;
logic div_valid0;
logic div_valid1;
logic div_valid;

/* this signal tells the controller when the quotient
resulting from fixed point division has completed */
assign div_valid = div_valid0 & div_valid1;

/* divider module signals
that check for overflow/divide by zero */
logic dbz0;
logic dbz1;
logic ovf0;
logic ovf1;
logic signed [DATA_WIDTH-1:0] remainder0;
logic signed [DATA_WIDTH-1:0] remainder1;

/* counter values
	count_init : tracks memory traversal
	time_count : tracks iterations
	wall_address : tracks boundary nodes
*/
logic [ADDRESS_WIDTH-1:0] count_init;
logic [TIME_COUNT_WIDTH:0] time_count;
logic [ADDRESS_WIDTH-1:0] wall_address;

/* streaming unit nets
	stream_addresses: vector of addresses
	pointing to locations in the streaming
	memory where particle populations
	will be dispersed
*/
logic [9*(ADDRESS_WIDTH+1)-1:0] stream_addresses;

/*
	signal break-outs for the stream_addresses vector
	stream_addr(i): streaming memory destination
	for post-collision population f*(i)
*/
logic [ADDRESS_WIDTH:0] stream_addr0;
logic [ADDRESS_WIDTH:0] stream_addr1;
logic [ADDRESS_WIDTH:0] stream_addr2;
logic [ADDRESS_WIDTH:0] stream_addr3;
logic [ADDRESS_WIDTH:0] stream_addr4;
logic [ADDRESS_WIDTH:0] stream_addr5;
logic [ADDRESS_WIDTH:0] stream_addr6;
logic [ADDRESS_WIDTH:0] stream_addr7;
logic [ADDRESS_WIDTH:0] stream_addr8;

assign stream_addr8 = stream_addresses[ADDRESS_WIDTH+1-1:0];
assign stream_addr7 = stream_addresses[2*(ADDRESS_WIDTH+1)-1:ADDRESS_WIDTH+1];
assign stream_addr6 = stream_addresses[3*(ADDRESS_WIDTH+1)-1:2*(ADDRESS_WIDTH+1)];
assign stream_addr5 = stream_addresses[4*(ADDRESS_WIDTH+1)-1:3*(ADDRESS_WIDTH+1)];
assign stream_addr4 = stream_addresses[5*(ADDRESS_WIDTH+1)-1:4*(ADDRESS_WIDTH+1)];
assign stream_addr3 = stream_addresses[6*(ADDRESS_WIDTH+1)-1:5*(ADDRESS_WIDTH+1)];
assign stream_addr2 = stream_addresses[7*(ADDRESS_WIDTH+1)-1:6*(ADDRESS_WIDTH+1)];
assign stream_addr1 = stream_addresses[8*(ADDRESS_WIDTH+1)-1:7*(ADDRESS_WIDTH+1)];
assign stream_addr0 = stream_addresses[9*(ADDRESS_WIDTH+1)-1:8*(ADDRESS_WIDTH+1)];

// power and ground (logic one and zero)
logic signed [DATA_WIDTH-1:0] pwr;
logic signed [DATA_WIDTH-1:0] gnd;

assign pwr = 32'h01_000000;
assign gnd = 32'h00_000000;

/* LBM parameters
	cx: discrete velocity x-component
	cy: discrete velocity y-component
	weights: velocity weightings 
*/
logic signed [DATA_WIDTH_F-1:0] weights;
logic signed [DATA_WIDTH_F-1:0] cx;
logic signed [DATA_WIDTH_F-1:0] cy;

/*
	Tangential flow boundary condition
	at the lid (top) of the cavity
*/
logic signed [DATA_WIDTH-1:0] uLid;
assign uLid = 32'h00_0CCCCC; // ~0.05

// discrete velocity x-components
logic signed [DATA_WIDTH-1:0] cx_0;
logic signed [DATA_WIDTH-1:0] cx_1;
logic signed [DATA_WIDTH-1:0] cx_2;
logic signed [DATA_WIDTH-1:0] cx_3;
logic signed [DATA_WIDTH-1:0] cx_4;
logic signed [DATA_WIDTH-1:0] cx_5;
logic signed [DATA_WIDTH-1:0] cx_6;
logic signed [DATA_WIDTH-1:0] cx_7;
logic signed [DATA_WIDTH-1:0] cx_8;

assign cx_8 = cx[DATA_WIDTH-1:0];
assign cx_7 = cx[2*DATA_WIDTH-1:DATA_WIDTH];
assign cx_6 = cx[3*DATA_WIDTH-1:2*DATA_WIDTH];
assign cx_5 = cx[4*DATA_WIDTH-1:3*DATA_WIDTH];
assign cx_4 = cx[5*DATA_WIDTH-1:4*DATA_WIDTH];
assign cx_3 = cx[6*DATA_WIDTH-1:5*DATA_WIDTH];
assign cx_2 = cx[7*DATA_WIDTH-1:6*DATA_WIDTH];
assign cx_1 = cx[8*DATA_WIDTH-1:7*DATA_WIDTH];
assign cx_0 = cx[9*DATA_WIDTH-1:8*DATA_WIDTH];

// intermediate products for moment calculation
logic signed [DATA_WIDTH-1:0] cx0fin0;
logic signed [DATA_WIDTH-1:0] cx1fin1;
logic signed [DATA_WIDTH-1:0] cx2fin2;
logic signed [DATA_WIDTH-1:0] cx3fin3;
logic signed [DATA_WIDTH-1:0] cx4fin4;
logic signed [DATA_WIDTH-1:0] cx5fin5;
logic signed [DATA_WIDTH-1:0] cx6fin6;
logic signed [DATA_WIDTH-1:0] cx7fin7;
logic signed [DATA_WIDTH-1:0] cx8fin8;

// discrete velocity y-components
logic signed [DATA_WIDTH-1:0] cy_0;
logic signed [DATA_WIDTH-1:0] cy_1;
logic signed [DATA_WIDTH-1:0] cy_2;
logic signed [DATA_WIDTH-1:0] cy_3;
logic signed [DATA_WIDTH-1:0] cy_4;
logic signed [DATA_WIDTH-1:0] cy_5;
logic signed [DATA_WIDTH-1:0] cy_6;
logic signed [DATA_WIDTH-1:0] cy_7;
logic signed [DATA_WIDTH-1:0] cy_8;

assign cy_8 = cy[DATA_WIDTH-1:0];
assign cy_7 = cy[2*DATA_WIDTH-1:DATA_WIDTH];
assign cy_6 = cy[3*DATA_WIDTH-1:2*DATA_WIDTH];
assign cy_5 = cy[4*DATA_WIDTH-1:3*DATA_WIDTH];
assign cy_4 = cy[5*DATA_WIDTH-1:4*DATA_WIDTH];
assign cy_3 = cy[6*DATA_WIDTH-1:5*DATA_WIDTH];
assign cy_2 = cy[7*DATA_WIDTH-1:6*DATA_WIDTH];
assign cy_1 = cy[8*DATA_WIDTH-1:7*DATA_WIDTH];
assign cy_0 = cy[9*DATA_WIDTH-1:8*DATA_WIDTH];

// intermediate products for moment calculation
logic signed [DATA_WIDTH-1:0] cy0fin0;
logic signed [DATA_WIDTH-1:0] cy1fin1;
logic signed [DATA_WIDTH-1:0] cy2fin2;
logic signed [DATA_WIDTH-1:0] cy3fin3;
logic signed [DATA_WIDTH-1:0] cy4fin4;
logic signed [DATA_WIDTH-1:0] cy5fin5;
logic signed [DATA_WIDTH-1:0] cy6fin6;
logic signed [DATA_WIDTH-1:0] cy7fin7;
logic signed [DATA_WIDTH-1:0] cy8fin8;

/* fin distribution values
	fin_out: vector of particle populations
	spanning the discrete velocity set
	
	fin_x: population x (0 <= x <= 8)
*/
logic signed [DATA_WIDTH_F-1:0] fin_out;
logic signed [DATA_WIDTH-1:0] fin_0;
logic signed [DATA_WIDTH-1:0] fin_1;
logic signed [DATA_WIDTH-1:0] fin_2;
logic signed [DATA_WIDTH-1:0] fin_3;
logic signed [DATA_WIDTH-1:0] fin_4;
logic signed [DATA_WIDTH-1:0] fin_5;
logic signed [DATA_WIDTH-1:0] fin_6;
logic signed [DATA_WIDTH-1:0] fin_7;
logic signed [DATA_WIDTH-1:0] fin_8;

/*
	Streaming unit nets
	f_streamed_in: streaming unit input bus
	This will contain the streamed particle
	populations
*/
logic signed [DATA_WIDTH_F-1:0] f_streamed_in;
logic signed [DATA_WIDTH_F-1:0] f_streamed_out;
logic signed [DATA_WIDTH-1:0] f_streamed_0;
logic signed [DATA_WIDTH-1:0] f_streamed_1;
logic signed [DATA_WIDTH-1:0] f_streamed_2;
logic signed [DATA_WIDTH-1:0] f_streamed_3;
logic signed [DATA_WIDTH-1:0] f_streamed_4;
logic signed [DATA_WIDTH-1:0] f_streamed_5;
logic signed [DATA_WIDTH-1:0] f_streamed_6;
logic signed [DATA_WIDTH-1:0] f_streamed_7;
logic signed [DATA_WIDTH-1:0] f_streamed_8;

assign f_streamed_8 = f_streamed_out[DATA_WIDTH-1:0];
assign f_streamed_7 = f_streamed_out[2*DATA_WIDTH-1:DATA_WIDTH];
assign f_streamed_6 = f_streamed_out[3*DATA_WIDTH-1:2*DATA_WIDTH];
assign f_streamed_5 = f_streamed_out[4*DATA_WIDTH-1:3*DATA_WIDTH];
assign f_streamed_4 = f_streamed_out[5*DATA_WIDTH-1:4*DATA_WIDTH];
assign f_streamed_3 = f_streamed_out[6*DATA_WIDTH-1:5*DATA_WIDTH];
assign f_streamed_2 = f_streamed_out[7*DATA_WIDTH-1:6*DATA_WIDTH];
assign f_streamed_1 = f_streamed_out[8*DATA_WIDTH-1:7*DATA_WIDTH];
assign f_streamed_0 = f_streamed_out[9*DATA_WIDTH-1:8*DATA_WIDTH];

/*
	Registers for latching the streaming unit
	data bus values. These are modified by the 
	streaming operation and fed back into the
	streaming unit.
*/
logic signed [DATA_WIDTH-1:0] f_streamed0_reg_out;
logic signed [DATA_WIDTH-1:0] f_streamed1_reg_out;
logic signed [DATA_WIDTH-1:0] f_streamed2_reg_out;
logic signed [DATA_WIDTH-1:0] f_streamed3_reg_out;
logic signed [DATA_WIDTH-1:0] f_streamed4_reg_out;
logic signed [DATA_WIDTH-1:0] f_streamed5_reg_out;
logic signed [DATA_WIDTH-1:0] f_streamed6_reg_out;
logic signed [DATA_WIDTH-1:0] f_streamed7_reg_out;
logic signed [DATA_WIDTH-1:0] f_streamed8_reg_out;

// moment variable register input multiplexers
logic signed [DATA_WIDTH-1:0] pmux_in;
logic signed [DATA_WIDTH-1:0] uxmux_in;
logic signed [DATA_WIDTH-1:0] uymux_in;

// moment register input and output nets
logic signed [DATA_WIDTH-1:0] p_in;
logic signed [DATA_WIDTH-1:0] p_out;
logic signed [DATA_WIDTH-1:0] pux_in;
logic signed [DATA_WIDTH-1:0] pux_out;
logic signed [DATA_WIDTH-1:0] puy_in;
logic signed [DATA_WIDTH-1:0] puy_out;
logic signed [DATA_WIDTH-1:0] ux_in;
logic signed [DATA_WIDTH-1:0] ux_out;
logic signed [DATA_WIDTH-1:0] uy_in;
logic signed [DATA_WIDTH-1:0] uy_out;

// moment variable RAM input bus
logic [ADDRESS_WIDTH-1:0] moment_ram_in;

// constant nets for equilibrium step
logic signed [DATA_WIDTH-1:0] p_product0; // stores p * 2/9
logic signed [DATA_WIDTH-1:0] p_product1; // stores p * 1/18
logic signed [DATA_WIDTH-1:0] p_product2; // stores p * 1/36

logic signed [DATA_WIDTH-1:0] const0;
logic signed [DATA_WIDTH-1:0] const1;
logic signed [DATA_WIDTH-1:0] const2;

assign const0 = 32'h00_38E38E; // 2/9
assign const1 = 32'h00_0E38E3; // 1/18
assign const2 = 32'h00_071C71; // 1/36

// moment RAM input buses
logic signed [DATA_WIDTH-1:0] p_mem_data_in;
logic signed [DATA_WIDTH-1:0] ux_mem_data_in;
logic signed [DATA_WIDTH-1:0] uy_mem_data_in;

// distribution function (fin) read values
assign fin_8 = fin_out[DATA_WIDTH-1:0];
assign fin_7 = fin_out[2*DATA_WIDTH-1:DATA_WIDTH];
assign fin_6 = fin_out[3*DATA_WIDTH-1:2*DATA_WIDTH];
assign fin_5 = fin_out[4*DATA_WIDTH-1:3*DATA_WIDTH];
assign fin_4 = fin_out[5*DATA_WIDTH-1:4*DATA_WIDTH];
assign fin_3 = fin_out[6*DATA_WIDTH-1:5*DATA_WIDTH];
assign fin_2 = fin_out[7*DATA_WIDTH-1:6*DATA_WIDTH];
assign fin_1 = fin_out[8*DATA_WIDTH-1:7*DATA_WIDTH];
assign fin_0 = fin_out[9*DATA_WIDTH-1:8*DATA_WIDTH];

// post-collision distribution (fout) input and output buses
logic signed [DATA_WIDTH_F-1:0] fout_mem_in;
logic signed [DATA_WIDTH_F-1:0] fout_mem_out;

// input data and address buses for fin
logic signed [DATA_WIDTH_F-1:0] fin_mem_in;
logic [ADDRESS_WIDTH-1:0] fin_addr_in;

// discrete velocity integer portion vectors for streaming unit
logic signed [9*(ADDRESS_WIDTH+1)-1:0] cx_int_concat;
logic signed [9*(ADDRESS_WIDTH+1)-1:0] cy_int_concat;

assign cx_int_concat = {9'b0_0000_0000, 9'b0_0000_0001, 9'b0_0000_0000, 9'b1_1111_1111, 9'b0_0000_0000, 9'b0_0000_0001, 9'b1_1111_1111, 9'b1_1111_1111, 9'b0_0000_0001};
assign cy_int_concat = {9'b0_0000_0000, 9'b0_0000_0000, 9'b0_0000_0001, 9'b0_0000_0000, 9'b1_1111_1111, 9'b0_0000_0001, 9'b0_0000_0001, 9'b1_1111_1111, 9'b1_1111_1111};

// intermediate values for equlibrium calculation
logic signed [DATA_WIDTH-1:0] ux2;
logic signed [DATA_WIDTH-1:0] u2_3;
logic signed [DATA_WIDTH-1:0] u2_neg3;
logic signed [DATA_WIDTH-1:0] uy2;
logic signed [DATA_WIDTH-1:0] ux2_9;
logic signed [DATA_WIDTH-1:0] uy2_9;
logic signed [DATA_WIDTH-1:0] u2;
logic signed [DATA_WIDTH-1:0] uxuy;
logic signed [DATA_WIDTH-1:0] uxuy_9;
logic signed [DATA_WIDTH-1:0] uxuy_neg9;
logic signed [DATA_WIDTH-1:0] ux_plus_uy;
logic signed [DATA_WIDTH-1:0] ux_minus_uy;
logic signed [DATA_WIDTH-1:0] ux_6;
logic signed [DATA_WIDTH-1:0] ux_neg_6;
logic signed [DATA_WIDTH-1:0] uy_6;
logic signed [DATA_WIDTH-1:0] uy_neg_6;
logic signed [DATA_WIDTH-1:0] ux_minus_uy_3;
logic signed [DATA_WIDTH-1:0] ux_minus_uy_neg3;
logic signed [DATA_WIDTH-1:0] ux_plus_uy_3;
logic signed [DATA_WIDTH-1:0] ux_plus_uy_neg3;

// adder nets for intermediate values
logic signed [DATA_WIDTH-1:0] add0_out;
logic signed [DATA_WIDTH-1:0] add1_out;
logic signed [DATA_WIDTH-1:0] add2_out;
logic signed [DATA_WIDTH-1:0] add3_out;
logic signed [DATA_WIDTH-1:0] add4_out;
logic signed [DATA_WIDTH-1:0] add5_out;
logic signed [DATA_WIDTH-1:0] add6_out;
logic signed [DATA_WIDTH-1:0] add7_out;
logic signed [DATA_WIDTH-1:0] add8_out;
logic signed [DATA_WIDTH-1:0] add9_out;
logic signed [DATA_WIDTH-1:0] add10_out;
logic signed [DATA_WIDTH-1:0] add11_out;
logic signed [DATA_WIDTH-1:0] add12_out;
logic signed [DATA_WIDTH-1:0] add13_out;
logic signed [DATA_WIDTH-1:0] add14_out;
logic signed [DATA_WIDTH-1:0] add15_out;
logic signed [DATA_WIDTH-1:0] add16_out;
logic signed [DATA_WIDTH-1:0] add17_out;
logic signed [DATA_WIDTH-1:0] add18_out;
logic signed [DATA_WIDTH-1:0] add19_out;
logic signed [DATA_WIDTH-1:0] add20_out;
logic signed [DATA_WIDTH-1:0] add21_out;
logic signed [DATA_WIDTH-1:0] add22_out;
logic signed [DATA_WIDTH-1:0] add23_out;
logic signed [DATA_WIDTH-1:0] add24_out;

// fixed point constants used frequently in
// intermediate calculations for equilibrium distribution
logic signed [DATA_WIDTH-1:0] one;
assign one = 32'h01_000000;

logic signed [DATA_WIDTH-1:0] six;
assign six = 32'h06_000000;

logic signed [DATA_WIDTH-1:0] neg_six;
assign neg_six = 32'hFA_000000;

logic signed [DATA_WIDTH-1:0] three;
assign three = 32'h03_000000;

logic signed [DATA_WIDTH-1:0] neg_three;
assign neg_three = 32'hFD_000000;

logic signed [DATA_WIDTH-1:0] two;
assign two = 32'h02_000000;

logic signed [DATA_WIDTH-1:0] neg_uy;
assign neg_uy = ~uy_out + 1;

logic signed [DATA_WIDTH-1:0] nine;
assign nine = 32'h09_000000;

logic signed [DATA_WIDTH-1:0] neg_nine;
assign neg_nine = 32'hF7_000000;

// equilibrium distribution components
// input buses
logic signed [DATA_WIDTH-1:0] feq0_in;
logic signed [DATA_WIDTH-1:0] feq1_in;
logic signed [DATA_WIDTH-1:0] feq2_in;
logic signed [DATA_WIDTH-1:0] feq3_in;
logic signed [DATA_WIDTH-1:0] feq4_in;
logic signed [DATA_WIDTH-1:0] feq5_in;
logic signed [DATA_WIDTH-1:0] feq6_in;
logic signed [DATA_WIDTH-1:0] feq7_in;
logic signed [DATA_WIDTH-1:0] feq8_in;

// output buses
logic signed [DATA_WIDTH-1:0] feq0_out;
logic signed [DATA_WIDTH-1:0] feq1_out;
logic signed [DATA_WIDTH-1:0] feq2_out;
logic signed [DATA_WIDTH-1:0] feq3_out;
logic signed [DATA_WIDTH-1:0] feq4_out;
logic signed [DATA_WIDTH-1:0] feq5_out;
logic signed [DATA_WIDTH-1:0] feq6_out;
logic signed [DATA_WIDTH-1:0] feq7_out;
logic signed [DATA_WIDTH-1:0] feq8_out;

// equilibrium distribution (feq) input and output buses
logic signed [DATA_WIDTH_F-1:0] feq_out;

assign feq_out = {feq0_out,feq1_out,feq2_out,feq3_out,feq4_out,feq5_out,feq6_out,feq7_out,feq8_out};


// intermediate calculation nets for collision step
logic signed [DATA_WIDTH-1:0] coll_prod_feq0;
logic signed [DATA_WIDTH-1:0] coll_prod_feq1;
logic signed [DATA_WIDTH-1:0] coll_prod_feq2;
logic signed [DATA_WIDTH-1:0] coll_prod_feq3;
logic signed [DATA_WIDTH-1:0] coll_prod_feq4;
logic signed [DATA_WIDTH-1:0] coll_prod_feq5;
logic signed [DATA_WIDTH-1:0] coll_prod_feq6;
logic signed [DATA_WIDTH-1:0] coll_prod_feq7;
logic signed [DATA_WIDTH-1:0] coll_prod_feq8;

logic signed [DATA_WIDTH-1:0] coll_prod_fin0;
logic signed [DATA_WIDTH-1:0] coll_prod_fin1;
logic signed [DATA_WIDTH-1:0] coll_prod_fin2;
logic signed [DATA_WIDTH-1:0] coll_prod_fin3;
logic signed [DATA_WIDTH-1:0] coll_prod_fin4;
logic signed [DATA_WIDTH-1:0] coll_prod_fin5;
logic signed [DATA_WIDTH-1:0] coll_prod_fin6;
logic signed [DATA_WIDTH-1:0] coll_prod_fin7;
logic signed [DATA_WIDTH-1:0] coll_prod_fin8;

// post collision population register nets
logic signed [DATA_WIDTH-1:0] fout0_in;
logic signed [DATA_WIDTH-1:0] fout1_in;
logic signed [DATA_WIDTH-1:0] fout2_in;
logic signed [DATA_WIDTH-1:0] fout3_in;
logic signed [DATA_WIDTH-1:0] fout4_in;
logic signed [DATA_WIDTH-1:0] fout5_in;
logic signed [DATA_WIDTH-1:0] fout6_in;
logic signed [DATA_WIDTH-1:0] fout7_in;
logic signed [DATA_WIDTH-1:0] fout8_in;

logic signed [DATA_WIDTH-1:0] fout0_out;
logic signed [DATA_WIDTH-1:0] fout1_out;
logic signed [DATA_WIDTH-1:0] fout2_out;
logic signed [DATA_WIDTH-1:0] fout3_out;
logic signed [DATA_WIDTH-1:0] fout4_out;
logic signed [DATA_WIDTH-1:0] fout5_out;
logic signed [DATA_WIDTH-1:0] fout6_out;
logic signed [DATA_WIDTH-1:0] fout7_out;
logic signed [DATA_WIDTH-1:0] fout8_out;

/* input bus to post-collision distribution (fout) ram.
	Vector format: {fout_i, fout_i+1, ...}
*/
assign fout_mem_in = {fout0_out,fout1_out,fout2_out,fout3_out,fout4_out,fout5_out,fout6_out,fout7_out,fout8_out};

// Grid values (x -> columns, y -> rows, with x increasing to the "right" and y increasing "up" the grid)
logic [COUNT_WIDTH-1:0] y_pos;
logic [ADDRESS_WIDTH-1:0] x_pos;
// zero-extended x and y values
logic signed [ADDRESS_WIDTH:0] x_pos_zext;
logic signed [ADDRESS_WIDTH:0] y_pos_zext;

assign x_pos_zext = {1'b0,x_pos};
assign y_pos_zext = {{ADDRESS_WIDTH+1-COUNT_WIDTH{1'b0}}, y_pos};

// wall detection signals
logic LID;
logic BOTTOM_WALL;
logic LEFT_WALL;
logic RIGHT_WALL;

// BGK relaxation parameters used for collision
logic signed [DATA_WIDTH-1:0] omega; // delta(t)/tau
logic signed [DATA_WIDTH-1:0] omega_prime; // 1-delta(t)/tau

assign omega = 32'h01_E88CB3;//C92909C6; // w = 250/131 (relaxation parameter) VERY IMPORTANT: THIS IS A FUNCTION OF THE GRID SIZE!!!
assign omega_prime = 32'hFF_17734C;//36D6F63B; // 1 - w

// calculating the row from the grid counter
// the counter name has the "init" part in it
// because it is also used to (init)ialize the RAMs
// at the beginning
assign x_pos = count_init % 16;

// gaussian distributed random number predictions
logic signed [DATA_WIDTH-1:0] ux_pred;
logic signed [DATA_WIDTH-1:0] uy_pred;

logic signed [DATA_WIDTH-1:0] ux_pred_buff_out;
logic signed [DATA_WIDTH-1:0] uy_pred_buff_out;


logic signed [DATA_WIDTH-1:0] ux_pred_out;
logic signed [DATA_WIDTH-1:0] uy_pred_out;

// seed for random number generation
logic signed [FRACTIONAL_BITS:0] seed;
assign seed = 25'b1110111001011000000000000;

// prediction constraint
logic signed [DATA_WIDTH-1:0] epsilon;
assign epsilon = 32'h00_004189; // ~0.0001
logic can_pred;
logic tog;

//***** MODULE INSTANTIATIONS *****//
// Everything past this point represents the actual digital hardware that are all connected together
// via the buses/nets defined in the above section. This mostly follows the block diagram
// with additional multiplexers for selecting values to feed into registers, logic for
// boundary conditions, streaming, etc.

// initialization counter
counter_init #(.GRID_DIM(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH)) init_counter (.Clk(CLOCK_50),
																									  .Reset(RESET),
																									  .Enable(count_init_en),
																									  .Data_out(count_init));

																									 
// row counter
row_counter #(.GRID_DIM(GRID_DIM), .INIT_COUNT_WIDTH(ADDRESS_WIDTH), .COUNT_WIDTH(COUNT_WIDTH)) row_cnter (.Clk(CLOCK_50),
																										  .Reset(RESET),
																										  .Enable(row_count_en), 
																										  .count_init(count_init),
																										  .Data_out(y_pos));																									  

// time step counter
time_step_counter #(.MAX_TIME(MAX_TIME), .TIME_COUNT_WIDTH(TIME_COUNT_WIDTH)) timer (.Clk(CLOCK_50), .Reset(RESET), .Enable(time_count_en), .Data_out(time_count));


// boundary conditon counter
bc_addr_iter #(.GRID_DIM(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH)) bc_addr
				  (.Clk(CLOCK_50),
				   .Reset(RESET),
					.Enable(bc_addr_iter_en),
					.address(wall_address));

// controller instantiation
controller fsm (.Clk(CLOCK_50),
					  .Reset(RESET),
					  .count_init(count_init),
					  .time_count(time_count),
					  .wall_address(wall_address),
					  .div_valid(div_valid),
					  .LID(LID),
					  .BOTTOM_WALL(BOTTOM_WALL),
					  .LEFT_WALL(LEFT_WALL),
					  .RIGHT_WALL(RIGHT_WALL),
					  .stream_addr0(stream_addr0),
					  .stream_addr1(stream_addr1),
					  .stream_addr2(stream_addr2),
					  .stream_addr3(stream_addr3),
					  .stream_addr4(stream_addr4),
					  .stream_addr5(stream_addr5),
					  .stream_addr6(stream_addr6),
					  .stream_addr7(stream_addr7),
					  .stream_addr8(stream_addr8),
					  .p_mem_array(p_mem_array),
					  .ux_mem_array(ux_mem_array),
					  .uy_mem_array(uy_mem_array),
					  .epsilon(epsilon),
					  .can_pred(can_pred),
					  .toggle_out(toggle_out),
					  .WE_p_mem(WE_p_mem),
					  .WE_ux_mem(WE_ux_mem),
					  .WE_uy_mem(WE_uy_mem),
					  .WE_fin_mem(WE_fin_mem),
					  .WE_f_streamed(WE_f_streamed),
					  .select_p_mem(select_p_mem),
					  .select_ux_mem(select_ux_mem),
					  .select_uy_mem(select_uy_mem),
					  .select_ux_reg(select_ux_reg),
					  .select_fin_addr(select_fin_addr),
					  .select_uy_reg(select_uy_reg),
					  .select_p_reg(select_p_reg),
					  .select_fin_mem(select_fin_mem),
					  .select_f_streamed(select_f_streamed),
					  .select_moment_addr(select_moment_addr),
					  .count_init_en(count_init_en),
					  .row_count_en(row_count_en),
					  .time_count_en(time_count_en),
					  .bc_addr_iter_en(bc_addr_iter_en),
					  .div_start(div_start),
					  .LD_EN_P(LD_EN_P),
					  .LD_EN_PUX(LD_EN_PUX),
					  .LD_EN_PUY(LD_EN_PUY),
					  .LD_EN_UX(LD_EN_UX),
					  .LD_EN_UY(LD_EN_UY),
					  .LD_EN_FEQ0(LD_EN_FEQ0),
					  .LD_EN_FEQ1(LD_EN_FEQ1),
					  .LD_EN_FEQ2(LD_EN_FEQ2),
					  .LD_EN_FEQ3(LD_EN_FEQ3),
					  .LD_EN_FEQ4(LD_EN_FEQ4),
					  .LD_EN_FEQ5(LD_EN_FEQ5),
					  .LD_EN_FEQ6(LD_EN_FEQ6),
					  .LD_EN_FEQ7(LD_EN_FEQ7),
					  .LD_EN_FEQ8(LD_EN_FEQ8),
					  .LD_EN_FOUT0(LD_EN_FOUT0),
					  .LD_EN_FOUT1(LD_EN_FOUT1),
					  .LD_EN_FOUT2(LD_EN_FOUT2),
					  .LD_EN_FOUT3(LD_EN_FOUT3),
					  .LD_EN_FOUT4(LD_EN_FOUT4),
					  .LD_EN_FOUT5(LD_EN_FOUT5),
					  .LD_EN_FOUT6(LD_EN_FOUT6),
					  .LD_EN_FOUT7(LD_EN_FOUT7),
					  .LD_EN_FOUT8(LD_EN_FOUT8),
					  .LD_EN_UX_PRED(LD_EN_UX_PRED),
					  .LD_EN_UY_PRED(LD_EN_UY_PRED),
					  .LD_EN_f_streamed_REG_0(LD_EN_f_streamed_REG_0),
					  .LD_EN_f_streamed_REG_1(LD_EN_f_streamed_REG_1),
					  .LD_EN_f_streamed_REG_2(LD_EN_f_streamed_REG_2),
					  .LD_EN_f_streamed_REG_3(LD_EN_f_streamed_REG_3),
					  .LD_EN_f_streamed_REG_4(LD_EN_f_streamed_REG_4),
					  .LD_EN_f_streamed_REG_5(LD_EN_f_streamed_REG_5),
					  .LD_EN_f_streamed_REG_6(LD_EN_f_streamed_REG_6),
					  .LD_EN_f_streamed_REG_7(LD_EN_f_streamed_REG_7),
					  .LD_EN_f_streamed_REG_8(LD_EN_f_streamed_REG_8),
					  .rand_en(rand_en),
					  .tog(tog),
					  .FINISH(FINISH));


// wall detector
wall_detector #(.GRID_DIM(GRID_DIM), .INIT_COUNT_WIDTH(ADDRESS_WIDTH), .COUNT_WIDTH(COUNT_WIDTH)) wall_det (.x(x_pos),
																																			   .y(y_pos),
																																				.LID(LID),
																																				.BOTTOM_WALL(BOTTOM_WALL),
																																				.LEFT_WALL(LEFT_WALL),
																																				.RIGHT_WALL(RIGHT_WALL));										
										
// weights register
weights_reg #(.WIDTH(DATA_WIDTH_F)) w_reg (.Reset(RESET),
													    .Data_Out(weights));


// memories	
moment_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)) p_ram (.address(moment_ram_in),
																															 .Clk(CLOCK_50),
																															 .WE(WE_p_mem),
																															 .data_in(p_mem_data_in),
																															 .data_out(p_mem_data_out),
																															 .mem_array(p_mem_array));
																															 
moment_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)) ux_ram (.address(moment_ram_in),
																															  .Clk(CLOCK_50),
																															  .WE(WE_ux_mem),
																															  .data_in(ux_mem_data_in),
																															  .data_out(ux_mem_data_out),
																															  .mem_array(ux_mem_array));
																															  
moment_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)) uy_ram (.address(moment_ram_in),
																															  .Clk(CLOCK_50),
																															  .WE(WE_uy_mem),
																															  .data_in(uy_mem_data_in),
																															  .data_out(uy_mem_data_out),
																															  .mem_array(uy_mem_array));
																															  
distribution_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH_F)) fin_ram (.address(fin_addr_in),
                                                                                                        .Clk(CLOCK_50),
																																		  .WE(WE_fin_mem),
																																		  .data_in(fin_mem_in),
																																		  .data_out(fin_out));
											  
distribution_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH_F)) f_streamed (.address(fin_addr_in),
                                                                                                        .Clk(CLOCK_50),
																																		  .WE(WE_f_streamed),
																																		  .data_in(f_streamed_in),
																																		  .data_out(f_streamed_out));
																																		  
										  

mux2 #(.DATA_WIDTH(ADDRESS_WIDTH)) moment_addr_mux (.Din0(count_init),
																 .Din1(wall_address),
																 .select(select_moment_addr),
																 .Dout(moment_ram_in));
// moment reg multiplexers

mux2 #(.DATA_WIDTH(DATA_WIDTH)) p_in_mux (.Din0(pmux_in),
														.Din1(one),
														.select(select_p_reg),
														.Dout(p_in));

mux4 #(.DATA_WIDTH(DATA_WIDTH)) ux_in_mux (.Din0(uxmux_in),
														 .Din1(uLid),
														 .Din2(gnd),
														 .Din3(ux_pred_buff_out),
														 .select(select_ux_reg),
														 .Dout(ux_in));

mux3 #(.DATA_WIDTH(DATA_WIDTH)) uy_in_mux (.Din0(uymux_in),
														 .Din1(gnd),
														 .Din2(uy_pred_buff_out),
														 .select(select_uy_reg),
														 .Dout(uy_in));																																		  																																  
// memory data bus multiplexers

mux2 #(.DATA_WIDTH(DATA_WIDTH)) p_mem_mux (.Din0(pwr),
														 .Din1(p_out),
														 .select(select_p_mem),
														 .Dout(p_mem_data_in));
													 
mux3 #(.DATA_WIDTH(DATA_WIDTH)) ux_mem_mux (.Din0(gnd), ////////////
														 .Din1(ux_out),
														 .Din2(uLid),
														 .select(select_ux_mem),
														 .Dout(ux_mem_data_in));

mux2 #(.DATA_WIDTH(DATA_WIDTH)) uy_mem_mux (.Din0(gnd),
														 .Din1(uy_out),
														 .select(select_uy_mem),
														 .Dout(uy_mem_data_in));
														 
	
// fin_mem multiplexer
// **********************************												
mux3 #(.DATA_WIDTH(DATA_WIDTH_F)) fin_mem_mux (.Din0(weights),
															   .Din1(feq_out),
																.Din2(f_streamed_out),
																.select(select_fin_mem),
																.Dout(fin_mem_in));	
															
// f_streamed multiplexer
mux12 #(.DATA_WIDTH(DATA_WIDTH_F)) f_streamed_mux (.Din0(weights),
															   .Din1(weights), // replace fout_mem_out with fout reg's
																.Din2({fout0_out, f_streamed1_reg_out, f_streamed2_reg_out, f_streamed3_reg_out, f_streamed4_reg_out, f_streamed5_reg_out, f_streamed6_reg_out, f_streamed7_reg_out, f_streamed8_reg_out}), // actually f_streamed with f_streamed0 replaced with fout0
																.Din3({f_streamed0_reg_out, fout1_out, f_streamed2_reg_out, f_streamed3_reg_out, f_streamed4_reg_out, f_streamed5_reg_out, f_streamed6_reg_out, f_streamed7_reg_out, f_streamed8_reg_out}), // f_streamed with f1 replaced with fout1
																.Din4({f_streamed0_reg_out, f_streamed1_reg_out, fout2_out, f_streamed3_reg_out, f_streamed4_reg_out, f_streamed5_reg_out, f_streamed6_reg_out, f_streamed7_reg_out, f_streamed8_reg_out}), // etc.
																.Din5({f_streamed0_reg_out, f_streamed1_reg_out, f_streamed2_reg_out, fout3_out, f_streamed4_reg_out, f_streamed5_reg_out, f_streamed6_reg_out, f_streamed7_reg_out, f_streamed8_reg_out}),
																.Din6({f_streamed0_reg_out, f_streamed1_reg_out, f_streamed2_reg_out, f_streamed3_reg_out, fout4_out, f_streamed5_reg_out, f_streamed6_reg_out, f_streamed7_reg_out, f_streamed8_reg_out}),
																.Din7({f_streamed0_reg_out, f_streamed1_reg_out, f_streamed2_reg_out, f_streamed3_reg_out, f_streamed4_reg_out, fout5_out, f_streamed6_reg_out, f_streamed7_reg_out, f_streamed8_reg_out}),
																.Din8({f_streamed0_reg_out, f_streamed1_reg_out, f_streamed2_reg_out, f_streamed3_reg_out, f_streamed4_reg_out, f_streamed5_reg_out, fout6_out, f_streamed7_reg_out, f_streamed8_reg_out}),
																.Din9({f_streamed0_reg_out, f_streamed1_reg_out, f_streamed2_reg_out, f_streamed3_reg_out, f_streamed4_reg_out, f_streamed5_reg_out, f_streamed6_reg_out, fout7_out, f_streamed8_reg_out}),
																.Din10({f_streamed0_reg_out, f_streamed1_reg_out, f_streamed2_reg_out, f_streamed3_reg_out, f_streamed4_reg_out, f_streamed5_reg_out, f_streamed6_reg_out, f_streamed7_reg_out, fout8_out}),
																.Din11(feq_out), // don't need this anymore
																.select(select_f_streamed),
																.Dout(f_streamed_in));	

// moment calculation hardware
adder9 #(.DATA_WIDTH(DATA_WIDTH)) fin_sum (.Din0(fin_0),
														.Din1(fin_1),
														.Din2(fin_2),
														.Din3(fin_3),
														.Din4(fin_4),
														.Din5(fin_5),
														.Din6(fin_6),
														.Din7(fin_7),
														.Din8(fin_8),
														.Dout(pmux_in));

reg32 #(.WIDTH(DATA_WIDTH)) p_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_P),
													 .Data_In(p_in),
													 .Data_Out(p_out));

reg32 #(.WIDTH(DATA_WIDTH)) pux_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_PUX),
													 .Data_In(pux_in),
													 .Data_Out(pux_out));

reg32 #(.WIDTH(DATA_WIDTH)) puy_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_PUY),
													 .Data_In(puy_in),
													 .Data_Out(puy_out));														 
													 
reg32 #(.WIDTH(DATA_WIDTH)) ux_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_UX),
													 .Data_In(ux_in),
													 .Data_Out(ux_out));
													 
reg32 #(.WIDTH(DATA_WIDTH)) uy_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_UY),
													 .Data_In(uy_in),
													 .Data_Out(uy_out));													 
													 
cx_reg #(.WIDTH(DATA_WIDTH_F)) reg_cx (.Reset(RESET),
											  .Data_Out(cx));
											  
cy_reg #(.WIDTH(DATA_WIDTH_F)) reg_cy (.Reset(RESET),
											  .Data_Out(cy));
											  
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cx0fin0 (.Din0(cx_0),
																																				 .Din1(fin_0),
																																				 .Dout(cx0fin0));
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cx1fin1 (.Din0(cx_1),
																																				 .Din1(fin_1),
																																				 .Dout(cx1fin1));
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cx2fin2 (.Din0(cx_2),
																																				 .Din1(fin_2),
																																				 .Dout(cx2fin2));
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cx3fin3 (.Din0(cx_3),
																																				 .Din1(fin_3),
																																				 .Dout(cx3fin3));
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cx4fin4 (.Din0(cx_4),
																																				 .Din1(fin_4),
																																				 .Dout(cx4fin4));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cx5fin5 (.Din0(cx_5),
																																				 .Din1(fin_5),
																																				 .Dout(cx5fin5));
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cx6fin6 (.Din0(cx_6),
																																				 .Din1(fin_6),
																																				 .Dout(cx6fin6));
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cx7fin7 (.Din0(cx_7),
																																				 .Din1(fin_7),
																																				 .Dout(cx7fin7));
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cx8fin8 (.Din0(cx_8),
																																				 .Din1(fin_8),
																																				 .Dout(cx8fin8));

adder9 #(.DATA_WIDTH(DATA_WIDTH)) cxfin_sum (.Din0(cx0fin0),
														.Din1(cx1fin1),
														.Din2(cx2fin2),
														.Din3(cx3fin3),
														.Din4(cx4fin4),
														.Din5(cx5fin5),
														.Din6(cx6fin6),
														.Din7(cx7fin7),
														.Din8(cx8fin8),
														.Dout(pux_in));

														
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cy0fin0 (.Din0(cy_0),
																																				 .Din1(fin_0),
																																				 .Dout(cy0fin0));
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cy1fin1 (.Din0(cy_1),
																																				 .Din1(fin_1),
																																				 .Dout(cy1fin1));
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cy2fin2 (.Din0(cy_2),
																																				 .Din1(fin_2),
																																				 .Dout(cy2fin2));
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cy3fin3 (.Din0(cy_3),
																																				 .Din1(fin_3),
																																				 .Dout(cy3fin3));
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cy4fin4 (.Din0(cy_4),
																																				 .Din1(fin_4),
																																				 .Dout(cy4fin4));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cy5fin5 (.Din0(cy_5),
																																				 .Din1(fin_5),
																																				 .Dout(cy5fin5));
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cy6fin6 (.Din0(cy_6),
																																				 .Din1(fin_6),
																																				 .Dout(cy6fin6));
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cy7fin7 (.Din0(cy_7),
																																				 .Din1(fin_7),
																																				 .Dout(cy7fin7));
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_cy8fin8 (.Din0(cy_8),
																																				 .Din1(fin_8),
																																				 .Dout(cy8fin8));

adder9 #(.DATA_WIDTH(DATA_WIDTH)) cyfin_sum (.Din0(cy0fin0),
														.Din1(cy1fin1),
														.Din2(cy2fin2),
														.Din3(cy3fin3),
														.Din4(cy4fin4),
														.Din5(cy5fin5),
														.Din6(cy6fin6),
														.Din7(cy7fin7),
														.Din8(cy8fin8),
														.Dout(puy_in));
														


fp_div #(.WIDTH(DATA_WIDTH), .FBITS(FRACTIONAL_BITS)) div_ux (.clk(CLOCK_50),
																				  .start(div_start),
																				  .busy(div_busy0),
																				  .valid(div_valid0),
																				  .dbz(dbz0),
																				  .ovf(ovf0),
																				  .x(pux_out),
																				  .y(p_out),
																				  .q(uxmux_in),
																				  .r(remainder0));

fp_div #(.WIDTH(DATA_WIDTH), .FBITS(FRACTIONAL_BITS)) div_uy (.clk(CLOCK_50),
																			     .start(div_start),
																				  .busy(div_busy1),
																				  .valid(div_valid1),
																				  .dbz(dbz1),
																				  .ovf(ovf1),
																				  .x(puy_out),
																				  .y(p_out),
																				  .q(uymux_in),
																				  .r(remainder1));
													
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_ux2 (.Din0(ux_out),
																																				 .Din1(ux_out),
																																				 .Dout(ux2));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_uy2 (.Din0(uy_out),
																																				 .Din1(uy_out),
																																				 .Dout(uy2));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_uxuy (.Din0(ux_out),
																																				 .Din1(uy_out),
																																				 .Dout(uxuy));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_6ux (.Din0(ux_out),
																																				 .Din1(six),
																																				 .Dout(ux_6));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_neg6ux (.Din0(ux_out),
																																				 .Din1(neg_six),
																																				 .Dout(ux_neg_6));


fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_6uy (.Din0(uy_out),
																																				 .Din1(six),
																																				 .Dout(uy_6));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_neg6uy (.Din0(uy_out),
																																				 .Din1(neg_six),
																																				 .Dout(uy_neg_6));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) sum_ux_uy (.Din0(ux_out),
											  .Din1(uy_out),
											  .Dout(ux_plus_uy));

											  
adder2 #(.DATA_WIDTH(DATA_WIDTH)) diff_ux_uy (.Din0(ux_out),
											  .Din1(neg_uy),
											  .Dout(ux_minus_uy));	///////////////////////////////////////

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_3_ux_minus_uy (.Din0(ux_minus_uy),
																																				 .Din1(three),
																																				 .Dout(ux_minus_uy_3));
																								
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_neg3_ux_minus_uy (.Din0(ux_minus_uy),
																																				 .Din1(neg_three),
																																				 .Dout(ux_minus_uy_neg3));	
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_3_ux_plus_uy (.Din0(ux_plus_uy),
																																				 .Din1(three),
																																				 .Dout(ux_plus_uy_3));
																								
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_neg3_ux_plus_uy (.Din0(ux_plus_uy),
																																				 .Din1(neg_three),
																																				 .Dout(ux_plus_uy_neg3));
																									
adder2 #(.DATA_WIDTH(DATA_WIDTH)) sum_u2 (.Din0(ux2),
														.Din1(uy2),
														.Dout(u2));


fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_9_ux2 (.Din0(ux2),
																																				 .Din1(nine),
																																				 .Dout(ux2_9));
																							
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_9_uy2 (.Din0(uy2),
																																				 .Din1(nine),
																																				 .Dout(uy2_9));
														
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_3_u2 (.Din0(u2),
																																				 .Din1(three),
																																				 .Dout(u2_3));
																							
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_neg3_u2 (.Din0(u2),
																																				 .Din1(neg_three),
																																				 .Dout(u2_neg3));
														
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_uxuy_9 (.Din0(uxuy),
																																				 .Din1(nine),
																																				 .Dout(uxuy_9));
																							
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_uxuy_neg9 (.Din0(uxuy),
																																				 .Din1(neg_nine),
																																				 .Dout(uxuy_neg9));
													
// adder array for equilibrium calculation (top-down)
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add0 (.Din0(one),
													 .Din1(ux_minus_uy_3),
													 .Dout(add0_out));
													 
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add1 (.Din0(one),
													 .Din1(ux_minus_uy_neg3),
													 .Dout(add1_out));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add2 (.Din0(one),
													 .Din1(ux_plus_uy_3),
													 .Dout(add2_out));													 

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add3 (.Din0(one),
													 .Din1(ux_plus_uy_neg3),
													 .Dout(add3_out));
	
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add4 (.Din0(add0_out),
													 .Din1(uxuy_neg9),
													 .Dout(add4_out));
													
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add5 (.Din0(add1_out),
													 .Din1(uxuy_neg9),
													 .Dout(add5_out));
	
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add6 (.Din0(add2_out),
													 .Din1(uxuy_9),
													 .Dout(add6_out));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add7 (.Din0(add3_out),
													 .Din1(uxuy_9),
													 .Dout(add7_out));
													
												
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add8 (.Din0(add4_out),
													 .Din1(u2_3),
													 .Dout(add8_out));
													
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add9 (.Din0(add5_out),
													 .Din1(u2_3),
													 .Dout(add9_out));
													
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add10 (.Din0(add6_out),
                                         .Din1(u2_3),
													  .Dout(add10_out));
													 
adder2 #(.DATA_WIDTH(DATA_WIDTH)) ad11 (.Din0(add7_out),
												    .Din1(u2_3),
													 .Dout(add11_out));
													
// p multipliers
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_p29 (.Din0(const0),
																																				 .Din1(p_out),
																																				 .Dout(p_product0));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_p118 (.Din0(const1),
																																				 .Din1(p_out),
																																				 .Dout(p_product1));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_p136 (.Din0(const2),
																																				 .Din1(p_out),
																																				 .Dout(p_product2));

// feq registers
reg32 #(.WIDTH(DATA_WIDTH)) feq0_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FEQ0),
													 .Data_In(feq0_in),
													 .Data_Out(feq0_out));	

reg32 #(.WIDTH(DATA_WIDTH)) feq1_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FEQ1),
													 .Data_In(feq1_in),
													 .Data_Out(feq1_out));

reg32 #(.WIDTH(DATA_WIDTH)) feq2_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FEQ2),
													 .Data_In(feq2_in),
													 .Data_Out(feq2_out));

reg32 #(.WIDTH(DATA_WIDTH)) feq3_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FEQ3),
													 .Data_In(feq3_in),
													 .Data_Out(feq3_out));	
	
reg32 #(.WIDTH(DATA_WIDTH)) feq4_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FEQ4),
													 .Data_In(feq4_in),
													 .Data_Out(feq4_out));
													
reg32 #(.WIDTH(DATA_WIDTH)) feq5_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FEQ5),
													 .Data_In(feq5_in),
													 .Data_Out(feq5_out));
	
reg32 #(.WIDTH(DATA_WIDTH)) feq6_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FEQ6),
													 .Data_In(feq6_in),
													 .Data_Out(feq6_out));
													
reg32 #(.WIDTH(DATA_WIDTH)) feq7_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FEQ7),
													 .Data_In(feq7_in),
													 .Data_Out(feq7_out));
	
reg32 #(.WIDTH(DATA_WIDTH)) feq8_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FEQ8),
													 .Data_In(feq8_in),
													 .Data_Out(feq8_out));
													
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_feq8 (.Din0(add8_out),
																																				 .Din1(p_product2),
																																				 .Dout(feq8_in));	
																																				 
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_feq6 (.Din0(add9_out),
																																				 .Din1(p_product2),
																																				 .Dout(feq6_in));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_feq5 (.Din0(add10_out),
																																				 .Din1(p_product2),
																																				 .Dout(feq5_in));	
	
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_feq7 (.Din0(add11_out),
																																				 .Din1(p_product2),
																																				 .Dout(feq7_in));
																																				
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_feq0 (.Din0(add24_out),
																																				 .Din1(p_product0),
																																				 .Dout(feq0_in));	
		
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_feq1 (.Din0(p_product1),
																																				 .Din1(add20_out),
																																				 .Dout(feq1_in));	
																																				
																																				
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_feq3 (.Din0(p_product1),
																																				 .Din1(add21_out),
																																				 .Dout(feq3_in));
	
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_feq2 (.Din0(p_product1),
																																				 .Din1(add22_out),
																																				 .Dout(feq2_in));
																																				
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_feq4 (.Din0(p_product1),
																																				 .Din1(add23_out),
																																				 .Dout(feq4_in));																																				
// adder array for bottom section
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add12 (.Din0(two),
                                         .Din1(ux_6),
													  .Dout(add12_out));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add13 (.Din0(two),
                                         .Din1(ux_neg_6),
													  .Dout(add13_out));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add14 (.Din0(two),
                                         .Din1(uy_6),
													  .Dout(add14_out));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add15 (.Din0(two),
                                         .Din1(uy_neg_6),
													  .Dout(add15_out));	
	
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add16 (.Din0(uy2_9),
                                         .Din1(add14_out),
													  .Dout(add16_out));
													  
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add17 (.Din0(uy2_9),
                                         .Din1(add15_out),
													  .Dout(add17_out));
													  
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add18 (.Din0(ux2_9),
                                         .Din1(add12_out),
													  .Dout(add18_out));
													  
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add19 (.Din0(ux2_9),
                                         .Din1(add13_out),
													  .Dout(add19_out));
	
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add20 (.Din0(u2_neg3),
                                         .Din1(add18_out),
													  .Dout(add20_out));
													 
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add21 (.Din0(u2_neg3),
                                         .Din1(add19_out),
													  .Dout(add21_out));		
			
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add22 (.Din0(u2_neg3),
                                         .Din1(add16_out),
													  .Dout(add22_out));	
													
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add23 (.Din0(u2_neg3),
                                         .Din1(add17_out),
													  .Dout(add23_out));
			
adder2 #(.DATA_WIDTH(DATA_WIDTH)) add24 (.Din0(two),
                                         .Din1(u2_neg3),
													  .Dout(add24_out));
													

// COLLISION
													
// feq0_out * w, feq1_out * w,  ...

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_feq0 (.Din0(omega),
																																				 .Din1(feq0_out),
																																				 .Dout(coll_prod_feq0));
																																				
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_feq1 (.Din0(omega),
																																				 .Din1(feq1_out),
																																				 .Dout(coll_prod_feq1));																																				

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_feq2 (.Din0(omega),
																																				 .Din1(feq2_out),
																																				 .Dout(coll_prod_feq2));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_feq3 (.Din0(omega),
																																				 .Din1(feq3_out),
																																				 .Dout(coll_prod_feq3));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_feq4 (.Din0(omega),
																																				 .Din1(feq4_out),
																																				 .Dout(coll_prod_feq4));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_feq5 (.Din0(omega),
																																				 .Din1(feq5_out),
																																				 .Dout(coll_prod_feq5));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_feq6 (.Din0(omega),
																																				 .Din1(feq6_out),
																																				 .Dout(coll_prod_feq6));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_feq7 (.Din0(omega),
																																				 .Din1(feq7_out),
																																				 .Dout(coll_prod_feq7));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_feq8 (.Din0(omega),
																																				 .Din1(feq8_out),
																																				 .Dout(coll_prod_feq8));																																				 
// fin_0 * w_prime, fin_1 * w_prime, ...	

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_fin0 (.Din0(omega_prime),
																																				 .Din1(fin_0),
																																				 .Dout(coll_prod_fin0));
																																				
fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_fin1 (.Din0(omega_prime),
																																				 .Din1(fin_1),
																																				 .Dout(coll_prod_fin1));																																				

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_fin2 (.Din0(omega_prime),
																																				 .Din1(fin_2),
																																				 .Dout(coll_prod_fin2));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_fin3 (.Din0(omega_prime),
																																				 .Din1(fin_3),
																																				 .Dout(coll_prod_fin3));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_fin4 (.Din0(omega_prime),
																																				 .Din1(fin_4),
																																				 .Dout(coll_prod_fin4));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_fin5 (.Din0(omega_prime),
																																				 .Din1(fin_5),
																																				 .Dout(coll_prod_fin5));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_fin6 (.Din0(omega_prime),
																																				 .Din1(fin_6),
																																				 .Dout(coll_prod_fin6));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_fin7 (.Din0(omega_prime),
																																				 .Din1(fin_7),
																																				 .Dout(coll_prod_fin7));

fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) prod_coll_fin8 (.Din0(omega_prime),
																																				 .Din1(fin_8),
																																				 .Dout(coll_prod_fin8));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add25 (.Din0(coll_prod_feq0),
                                         .Din1(coll_prod_fin0),
													  .Dout(fout0_in));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add26 (.Din0(coll_prod_feq1),
                                         .Din1(coll_prod_fin1),
													  .Dout(fout1_in));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add27 (.Din0(coll_prod_feq2),
                                         .Din1(coll_prod_fin2),
													  .Dout(fout2_in));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add28 (.Din0(coll_prod_feq3),
                                         .Din1(coll_prod_fin3),
													  .Dout(fout3_in));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add29 (.Din0(coll_prod_feq4),
                                         .Din1(coll_prod_fin4),
													  .Dout(fout4_in));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add30 (.Din0(coll_prod_feq5),
                                         .Din1(coll_prod_fin5),
													  .Dout(fout5_in));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add31 (.Din0(coll_prod_feq6),
                                         .Din1(coll_prod_fin6),
													  .Dout(fout6_in));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add32 (.Din0(coll_prod_feq7), 
                                         .Din1(coll_prod_fin7),
													  .Dout(fout7_in));

adder2 #(.DATA_WIDTH(DATA_WIDTH)) add33 (.Din0(coll_prod_feq8),
                                         .Din1(coll_prod_fin8),
													  .Dout(fout8_in));

// fout registers

reg32 #(.WIDTH(DATA_WIDTH)) fout0_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FOUT0),
													 .Data_In(fout0_in),
													 .Data_Out(fout0_out));	

reg32 #(.WIDTH(DATA_WIDTH)) fout1_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FOUT1),
													 .Data_In(fout1_in),
													 .Data_Out(fout1_out));

reg32 #(.WIDTH(DATA_WIDTH)) fout2_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FOUT2),
													 .Data_In(fout2_in),
													 .Data_Out(fout2_out));

reg32 #(.WIDTH(DATA_WIDTH)) fout3_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FOUT3),
													 .Data_In(fout3_in),
													 .Data_Out(fout3_out));	
	
reg32 #(.WIDTH(DATA_WIDTH)) fout4_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FOUT4),
													 .Data_In(fout4_in),
													 .Data_Out(fout4_out));
													
reg32 #(.WIDTH(DATA_WIDTH)) fout5_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FOUT5),
													 .Data_In(fout5_in),
													 .Data_Out(fout5_out));
	
reg32 #(.WIDTH(DATA_WIDTH)) fout6_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FOUT6),
													 .Data_In(fout6_in),
													 .Data_Out(fout6_out));
													
reg32 #(.WIDTH(DATA_WIDTH)) fout7_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FOUT7),
													 .Data_In(fout7_in),
													 .Data_Out(fout7_out));
	
reg32 #(.WIDTH(DATA_WIDTH)) fout8_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_FOUT8),
													 .Data_In(fout8_in),
													 .Data_Out(fout8_out));	

// Streaming

reg32 #(.WIDTH(DATA_WIDTH)) f_streamed0_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_f_streamed_REG_0),
													 .Data_In(f_streamed_0),
													 .Data_Out(f_streamed0_reg_out));	

reg32 #(.WIDTH(DATA_WIDTH)) f_streamed1_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_f_streamed_REG_1),
													 .Data_In(f_streamed_1),
													 .Data_Out(f_streamed1_reg_out));

reg32 #(.WIDTH(DATA_WIDTH)) f_streamed2_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_f_streamed_REG_2),
													 .Data_In(f_streamed_2),
													 .Data_Out(f_streamed2_reg_out));

reg32 #(.WIDTH(DATA_WIDTH)) f_streamed3_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_f_streamed_REG_3),
													 .Data_In(f_streamed_3),
													 .Data_Out(f_streamed3_reg_out));	
	
reg32 #(.WIDTH(DATA_WIDTH)) f_streamed4_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_f_streamed_REG_4),
													 .Data_In(f_streamed_4),
													 .Data_Out(f_streamed4_reg_out));
													
reg32 #(.WIDTH(DATA_WIDTH)) f_streamed5_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_f_streamed_REG_5),
													 .Data_In(f_streamed_5),
													 .Data_Out(f_streamed5_reg_out));

reg32 #(.WIDTH(DATA_WIDTH)) f_streamed6_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_f_streamed_REG_6),
													 .Data_In(f_streamed_6),
													 .Data_Out(f_streamed6_reg_out));
													
reg32 #(.WIDTH(DATA_WIDTH)) f_streamed7_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_f_streamed_REG_7),
													 .Data_In(f_streamed_7),
													 .Data_Out(f_streamed7_reg_out));
	
reg32 #(.WIDTH(DATA_WIDTH)) f_streamed8_reg (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_f_streamed_REG_8),
													 .Data_In(f_streamed_8),
													 .Data_Out(f_streamed8_reg_out));	

streaming_unit #(.GRID_DIM(GRID_DIM), .SIDE_LENGTH(GRID_DIM/16), .ADDRESS_WIDTH(ADDRESS_WIDTH+1)) streamer (.x(x_pos_zext),
																								.y(y_pos_zext),
																								.cx(cx_int_concat),
																								.cy(cy_int_concat),
																								.write_addresses(stream_addresses));
											
fin_addr_mux #(.ADDRESS_WIDTH(ADDRESS_WIDTH)) mux_fin_addr
				  (.Din0(count_init),
				  .Din1(stream_addr0[ADDRESS_WIDTH-1:0]),
				  .Din2(stream_addr1[ADDRESS_WIDTH-1:0]),
				  .Din3(stream_addr2[ADDRESS_WIDTH-1:0]),
				  .Din4(stream_addr3[ADDRESS_WIDTH-1:0]),
				  .Din5(stream_addr4[ADDRESS_WIDTH-1:0]),
				  .Din6(stream_addr5[ADDRESS_WIDTH-1:0]),
				  .Din7(stream_addr6[ADDRESS_WIDTH-1:0]),
				  .Din8(stream_addr7[ADDRESS_WIDTH-1:0]),
				  .Din9(stream_addr8[ADDRESS_WIDTH-1:0]),
				  .Din10(wall_address),
				  .select(select_fin_addr),
				  .Dout(fin_addr_in));
				  
// PREDICTORS

// random number generators (gaussian distribution)
gaussian #(.DATA_WIDTH(DATA_WIDTH), .FRACTIONAL_BITS(FRACTIONAL_BITS),
		     .OFFSET(OFFSET_UX), .SHIFTAMT(SHIFTAMT_UX)) ux_predictor
			(.Clk(CLOCK_50),
			 .Enable(rand_en),
			 .Reset(RESET),
			 .seed(seed),
			 .randnum(ux_pred));

 gaussian #(.DATA_WIDTH(DATA_WIDTH), .FRACTIONAL_BITS(FRACTIONAL_BITS),
  .OFFSET(OFFSET_UY), .SHIFTAMT(SHIFTAMT_UY)) uy_predictor
			(.Clk(CLOCK_50),
			 .Enable(rand_en),
			 .Reset(RESET),
			 .seed(seed),
			 .randnum(uy_pred));
			 
det_pred #(.DATA_WIDTH(DATA_WIDTH)) pred_constrainer 
(.epsilon(epsilon),
 .ux(ux_out),
 .uy(uy_out),
 .ux_pred(ux_pred_out),
 .uy_pred(uy_pred_out),
 .can_pred(can_pred));
 

 mux2 #(.DATA_WIDTH(DATA_WIDTH)) pred_mux_x (.Din0(ux_pred),
																 .Din1(ux_pred_buff_out),
																 .select(toggle_out),
																 .Dout(ux_pred_out));
																 
 mux2 #(.DATA_WIDTH(DATA_WIDTH)) pred_mux_y (.Din0(uy_pred),
																 .Din1(uy_pred_buff_out),
																 .select(toggle_out),
																 .Dout(uy_pred_out));																 
 
reg32 #(.WIDTH(DATA_WIDTH)) ux_pred_buff (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_UX_PRED),
													 .Data_In(ux_pred),
													 .Data_Out(ux_pred_buff_out));

reg32 #(.WIDTH(DATA_WIDTH)) uy_pred_buff (.Clk(CLOCK_50),
													 .Reset(RESET),
													 .LD_EN(LD_EN_UY_PRED),
													 .Data_In(uy_pred),
													 .Data_Out(uy_pred_buff_out));	

tflipflop toggle (.Clk(CLOCK_50), .Reset(RESET), .T(tog), .Dout(toggle_out));															 

endmodule
