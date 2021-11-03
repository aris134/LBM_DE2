module LBM_DE2	#(GRID_DIM=16*16,
		DATA_WIDTH=32, ADDRESS_WIDTH=$clog2(GRID_DIM), COUNT_WIDTH=$clog2(GRID_DIM/16),
		DATA_WIDTH_F=9*DATA_WIDTH, FRACTIONAL_BITS=24, INTEGER_BITS=DATA_WIDTH-FRACTIONAL_BITS)(
		
		input logic CLOCK_50,
		input logic RESET,
		output logic signed [DATA_WIDTH-1:0] p_mem_data_out,
		output logic signed [DATA_WIDTH-1:0] ux_mem_data_out,
		output logic signed [DATA_WIDTH-1:0] uy_mem_data_out,
		output logic signed [DATA_WIDTH_F-1:0] fin_mem_data_out);
		
//***** BUS LOGIC *****//
// logic [ADDRESS_WIDTH-1:0] address;
logic WE_p_mem;
logic WE_ux_mem;
logic WE_uy_mem;
logic WE_fin_mem;
logic WE_fout_mem;
logic WE_feq_mem;
logic select_p_mem;
logic select_ux_mem;
logic select_uy_mem;
logic [1:0] select_ux_reg;
logic select_uy_reg;
logic select_p_reg;
logic select_fin;
logic count_init_en;

// divider signals
logic div_start;
logic div_busy0;
logic div_busy1;
logic div_valid0;
logic div_valid1;
logic div_valid;

assign div_valid = div_valid0 & div_valid1;

logic dbz0;
logic dbz1;
logic ovf0;
logic ovf1;
logic remainder0;
logic remainder1;

logic [ADDRESS_WIDTH-1:0] count_init;

logic signed [DATA_WIDTH-1:0] pwr;
logic signed [DATA_WIDTH-1:0] gnd;

assign pwr = {{DATA_WIDTH-1{1'b0}}, 1'b1};
assign gnd = {{DATA_WIDTH{1'b0}}};

logic signed [DATA_WIDTH_F-1:0] weights;
logic signed [DATA_WIDTH_F-1:0] cx;
logic signed [DATA_WIDTH_F-1:0] cy;

logic signed [DATA_WIDTH-1:0] uLid;
assign uLid = 32'h00_0CCCCC;

logic signed [DATA_WIDTH-1:0] cx_0;
logic signed [DATA_WIDTH-1:0] cx_1;
logic signed [DATA_WIDTH-1:0] cx_2;
logic signed [DATA_WIDTH-1:0] cx_3;
logic signed [DATA_WIDTH-1:0] cx_4;
logic signed [DATA_WIDTH-1:0] cx_5;
logic signed [DATA_WIDTH-1:0] cx_6;
logic signed [DATA_WIDTH-1:0] cx_7;
logic signed [DATA_WIDTH-1:0] cx_8;

logic signed [DATA_WIDTH-1:0] cx0fin0;
logic signed [DATA_WIDTH-1:0] cx1fin1;
logic signed [DATA_WIDTH-1:0] cx2fin2;
logic signed [DATA_WIDTH-1:0] cx3fin3;
logic signed [DATA_WIDTH-1:0] cx4fin4;
logic signed [DATA_WIDTH-1:0] cx5fin5;
logic signed [DATA_WIDTH-1:0] cx6fin6;
logic signed [DATA_WIDTH-1:0] cx7fin7;
logic signed [DATA_WIDTH-1:0] cx8fin8;

logic signed [DATA_WIDTH-1:0] cy_0;
logic signed [DATA_WIDTH-1:0] cy_1;
logic signed [DATA_WIDTH-1:0] cy_2;
logic signed [DATA_WIDTH-1:0] cy_3;
logic signed [DATA_WIDTH-1:0] cy_4;
logic signed [DATA_WIDTH-1:0] cy_5;
logic signed [DATA_WIDTH-1:0] cy_6;
logic signed [DATA_WIDTH-1:0] cy_7;
logic signed [DATA_WIDTH-1:0] cy_8;

logic signed [DATA_WIDTH-1:0] cy0fin0;
logic signed [DATA_WIDTH-1:0] cy1fin1;
logic signed [DATA_WIDTH-1:0] cy2fin2;
logic signed [DATA_WIDTH-1:0] cy3fin3;
logic signed [DATA_WIDTH-1:0] cy4fin4;
logic signed [DATA_WIDTH-1:0] cy5fin5;
logic signed [DATA_WIDTH-1:0] cy6fin6;
logic signed [DATA_WIDTH-1:0] cy7fin7;
logic signed [DATA_WIDTH-1:0] cy8fin8;

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


logic signed [DATA_WIDTH-1:0] pmux_in;
logic signed [DATA_WIDTH-1:0] uxmux_in;
logic signed [DATA_WIDTH-1:0] uymux_in;

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

logic signed [DATA_WIDTH-1:0] p_product0;
logic signed [DATA_WIDTH-1:0] p_product1;
logic signed [DATA_WIDTH-1:0] p_product2;

logic signed [DATA_WIDTH-1:0] const0;
logic signed [DATA_WIDTH-1:0] const1;
logic signed [DATA_WIDTH-1:0] const2;

assign const0 = 32'h00_38E38E; // 2/9
assign const1 = 32'h00_0E38E3; // 1/18
assign const2 = 32'h00_071C71; // 1/36

logic signed [DATA_WIDTH-1:0] p_mem_data_in;
logic signed [DATA_WIDTH-1:0] ux_mem_data_in;
logic signed [DATA_WIDTH-1:0] uy_mem_data_in;

logic LD_EN_P;
logic LD_EN_PUX;
logic LD_EN_PUY;
logic LD_EN_FEQ0;
logic LD_EN_FEQ1;
logic LD_EN_FEQ2;
logic LD_EN_FEQ3;
logic LD_EN_FEQ4;
logic LD_EN_FEQ5;
logic LD_EN_FEQ6;
logic LD_EN_FEQ7;
logic LD_EN_FEQ8;

assign fin_mem_data_out = fin_out;
assign fin_8 = fin_out[DATA_WIDTH-1:0];
assign fin_7 = fin_out[2*DATA_WIDTH-1:DATA_WIDTH];
assign fin_6 = fin_out[3*DATA_WIDTH-1:2*DATA_WIDTH];
assign fin_5 = fin_out[4*DATA_WIDTH-1:3*DATA_WIDTH];
assign fin_4 = fin_out[5*DATA_WIDTH-1:4*DATA_WIDTH];
assign fin_3 = fin_out[6*DATA_WIDTH-1:5*DATA_WIDTH];
assign fin_2 = fin_out[7*DATA_WIDTH-1:6*DATA_WIDTH];
assign fin_1 = fin_out[8*DATA_WIDTH-1:7*DATA_WIDTH];
assign fin_0 = fin_out[9*DATA_WIDTH-1:8*DATA_WIDTH];

logic signed [DATA_WIDTH_F-1:0] feq_in;


logic signed [DATA_WIDTH_F-1:0] feq_out;

assign cx_8 = cx[DATA_WIDTH-1:0];
assign cx_7 = cx[2*DATA_WIDTH-1:DATA_WIDTH];
assign cx_6 = cx[3*DATA_WIDTH-1:2*DATA_WIDTH];
assign cx_5 = cx[4*DATA_WIDTH-1:3*DATA_WIDTH];
assign cx_4 = cx[5*DATA_WIDTH-1:4*DATA_WIDTH];
assign cx_3 = cx[6*DATA_WIDTH-1:5*DATA_WIDTH];
assign cx_2 = cx[7*DATA_WIDTH-1:6*DATA_WIDTH];
assign cx_1 = cx[8*DATA_WIDTH-1:7*DATA_WIDTH];
assign cx_0 = cx[9*DATA_WIDTH-1:8*DATA_WIDTH];

assign cy_8 = cy[DATA_WIDTH-1:0];
assign cy_7 = cy[2*DATA_WIDTH-1:DATA_WIDTH];
assign cy_6 = cy[3*DATA_WIDTH-1:2*DATA_WIDTH];
assign cy_5 = cy[4*DATA_WIDTH-1:3*DATA_WIDTH];
assign cy_4 = cy[5*DATA_WIDTH-1:4*DATA_WIDTH];
assign cy_3 = cy[6*DATA_WIDTH-1:5*DATA_WIDTH];
assign cy_2 = cy[7*DATA_WIDTH-1:6*DATA_WIDTH];
assign cy_1 = cy[8*DATA_WIDTH-1:7*DATA_WIDTH];
assign cy_0 = cy[9*DATA_WIDTH-1:8*DATA_WIDTH];


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


logic signed [DATA_WIDTH-1:0] one;
assign one = 32'h01_000000;

logic signed [DATA_WIDTH-1:0] six;
assign six = 32'h06_000000;

logic signed [DATA_WIDTH-1:0] neg_six;
assign neg_six = 32'hFA_000000;

logic signed [DATA_WIDTH-1:0] three;
assign three = 32'h03_000000;

logic signed [DATA_WIDTH-1:0] neg_three;
assign neg_three = 32'hFB_000000;

logic signed [DATA_WIDTH-1:0] two;
assign two = 32'h02_000000;

logic signed [DATA_WIDTH-1:0] neg_uy;
assign neg_uy = ~uy_out + 1;

logic signed [DATA_WIDTH-1:0] nine;
assign nine = 32'h09_000000;

logic signed [DATA_WIDTH-1:0] neg_nine;
assign neg_nine = 32'hF7_000000;

logic signed [DATA_WIDTH-1:0] feq0_in;
logic signed [DATA_WIDTH-1:0] feq1_in;
logic signed [DATA_WIDTH-1:0] feq2_in;
logic signed [DATA_WIDTH-1:0] feq3_in;
logic signed [DATA_WIDTH-1:0] feq4_in;
logic signed [DATA_WIDTH-1:0] feq5_in;
logic signed [DATA_WIDTH-1:0] feq6_in;
logic signed [DATA_WIDTH-1:0] feq7_in;
logic signed [DATA_WIDTH-1:0] feq8_in;

logic signed [DATA_WIDTH-1:0] feq0_out;
logic signed [DATA_WIDTH-1:0] feq1_out;
logic signed [DATA_WIDTH-1:0] feq2_out;
logic signed [DATA_WIDTH-1:0] feq3_out;
logic signed [DATA_WIDTH-1:0] feq4_out;
logic signed [DATA_WIDTH-1:0] feq5_out;
logic signed [DATA_WIDTH-1:0] feq6_out;
logic signed [DATA_WIDTH-1:0] feq7_out;
logic signed [DATA_WIDTH-1:0] feq8_out;

logic [COUNT_WIDTH-1:0] y_pos; // rows
logic [ADDRESS_WIDTH-1:0] x_pos; // columns

logic LID;
logic BOTTOM_WALL;
logic LEFT_WALL;
logic RIGHT_WALL;

assign x_pos = count_init % 16;


assign feq_in = {feq0_out,feq1_out,feq2_out,feq3_out,feq4_out,feq5_out,feq6_out,feq7_out,feq8_out};

//***** MODULE INSTANTIATIONS *****//


// initialization counter
counter_init #(.GRID_DIM(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH)) init_counter (.Clk(CLOCK_50),
																									  .Reset(RESET),
																									  .Enable(count_init_en),
																									  .Data_out(count_init));

																									 
// row counter

row_counter #(.GRID_DIM(GRID_DIM), .INIT_COUNT_WIDTH(ADDRESS_WIDTH), .COUNT_WIDTH(COUNT_WIDTH)) row_cnter (.Clk(CLOCK_50),
																										  .Reset(RESET),
																										  .Enable(count_init_en),
																										  .count_init(count_init),
																										  .Data_out(y_pos));																									  
																									  
// controller
controller fsm (.Clk(CLOCK_50),
																															  .Reset(RESET),
																															  .count_init(count_init),
																															  .div_valid(div_valid),
																															  .LID(LID),
																															  .BOTTOM_WALL(BOTTOM_WALL),
																															  .LEFT_WALL(LEFT_WALL),
																															  .RIGHT_WALL(RIGHT_WALL),
																															  .WE_p_mem(WE_p_mem),
																															  .WE_ux_mem(WE_ux_mem),
																															  .WE_uy_mem(WE_uy_mem),
																															  .WE_fin_mem(WE_fin_mem),
																															  .WE_fout_mem(WE_fout_mem),
																															  .WE_feq_mem(WE_feq_mem),
																															  .select_p_mem(select_p_mem),
																															  .select_ux_mem(select_ux_mem),
																															  .select_uy_mem(select_uy_mem),
																															  .select_ux_reg(select_ux_reg),
																															  .select_uy_reg(select_uy_reg),
																															  .select_p_reg(select_p_reg),
																															  .select_fin(select_fin),
																															  .count_init_en(count_init_en),
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
																															  .LD_EN_FEQ8(LD_EN_FEQ8));


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
moment_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)) p_ram (.address(count_init),
																															 .Clk(CLOCK_50),
																															 .WE(WE_p_mem),
																															 .data_in(p_mem_data_in),
																															 .data_out(p_mem_data_out));
																															 
moment_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)) ux_ram (.address(count_init),
																															  .Clk(CLOCK_50),
																															  .WE(WE_ux_mem),
																															  .data_in(ux_mem_data_in),
																															  .data_out(ux_mem_data_out));
																															  
moment_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)) uy_ram (.address(count_init),
																															  .Clk(CLOCK_50),
																															  .WE(WE_uy_mem),
																															  .data_in(uy_mem_data_in),
																															  .data_out(uy_mem_data_out));
																															  
distribution_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH_F)) fin_ram (.address(count_init),
                                                                                                        .Clk(CLOCK_50),
																																		  .WE(WE_fin_mem),
																																		  .data_in(weights),
																																		  .data_out(fin_out));

distribution_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH_F)) feq_ram (.address(count_init),
                                                                                                        .Clk(CLOCK_50),
																																		  .WE(WE_feq_mem),
																																		  .data_in(feq_in),
																																		  .data_out(feq_out));

// moment reg multiplexers

mux2 #(.DATA_WIDTH(DATA_WIDTH)) p_in_mux (.Din0(pmux_in),
														.Din1(one),
														.select(select_p_reg),
														.Dout(p_in));

mux3 #(.DATA_WIDTH(DATA_WIDTH)) ux_in_mux (.Din0(uxmux_in),
														 .Din1(uLid),
														 .Din2(gnd),
														 .select(select_ux_reg),
														 .Dout(ux_in));

mux2 #(.DATA_WIDTH(DATA_WIDTH)) uy_in_mux (.Din0(uymux_in),
														 .Din1(gnd),
														 .select(select_uy_reg),
														 .Dout(uy_in));																																		  																																  
// memory data bus multiplexers

mux2 #(.DATA_WIDTH(DATA_WIDTH)) p_mem_mux (.Din0(pwr),
														 .Din1(p_out),
														 .select(select_p_mem),
														 .Dout(p_mem_data_in));
														 
mux2 #(.DATA_WIDTH(DATA_WIDTH)) ux_mem_mux (.Din0(gnd),
														 .Din1(ux_out),
														 .select(select_ux_mem),
														 .Dout(ux_mem_data_in));

mux2 #(.DATA_WIDTH(DATA_WIDTH)) uy_mem_mux (.Din0(gnd),
														 .Din1(uy_out),
														 .select(select_uy_mem),
														 .Dout(uy_mem_data_in));														 

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
											  .Dout(ux_minus_uy));	

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
													
// adder array for equil calculation (top-down)
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
endmodule
