module LBM_DE2	#(GRID_DIM=16*16,
		DATA_WIDTH=32, ADDRESS_WIDTH=$clog2(GRID_DIM),
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
logic select_p;
logic select_ux;
logic select_uy;
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

logic signed [DATA_WIDTH-1:0] p_mem_data_in;
logic signed [DATA_WIDTH-1:0] ux_mem_data_in;
logic signed [DATA_WIDTH-1:0] uy_mem_data_in;

logic LD_EN_P;
logic LD_EN_PUX;
logic LD_EN_PUY;

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


//***** MODULE INSTANTIATIONS *****//


// initialization counter
counter_init #(.GRID_DIM(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH)) init_counter (.Clk(CLOCK_50),
																									  .Reset(RESET),
																									  .Enable(count_init_en),
																									  .Data_out(count_init));


// controller
controller fsm (.Clk(CLOCK_50),
																															  .Reset(RESET),
																															  .count_init(count_init),
																															  .div_valid(div_valid),
																															  .WE_p_mem(WE_p_mem),
																															  .WE_ux_mem(WE_ux_mem),
																															  .WE_uy_mem(WE_uy_mem),
																															  .WE_fin_mem(WE_fin_mem),
																															  .WE_fout_mem(WE_fout_mem),
																															  .WE_feq_mem(WE_feq_mem),
																															  .select_p(select_p),
																															  .select_ux(select_ux),
																															  .select_uy(select_uy),
																															  .select_fin(select_fin),
																															  .count_init_en(count_init_en),
																															  .div_start(div_start),
																															  .LD_EN_P(LD_EN_P),
																															  .LD_EN_PUX(LD_EN_PUX),
																															  .LD_EN_PUY(LD_EN_PUY),
																															  .LD_EN_UX(LD_EN_UX),
																															  .LD_EN_UY(LD_EN_UY));

																					  
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
																																		  
// memory data bus multiplexers

mux2 #(.DATA_WIDTH(DATA_WIDTH)) p_mem_mux (.Din0(pwr),
														 .Din1(p_out),
														 .select(select_p),
														 .Dout(p_mem_data_in));
														 
mux2 #(.DATA_WIDTH(DATA_WIDTH)) ux_mem_mux (.Din0(gnd),
														 .Din1(ux_out),
														 .select(select_ux),
														 .Dout(ux_mem_data_in));

mux2 #(.DATA_WIDTH(DATA_WIDTH)) uy_mem_mux (.Din0(gnd),
														 .Din1(uy_out),
														 .select(select_uy),
														 .Dout(uy_mem_data_in));														 

// moment calculation hardware
adder9 #(.DATA_WIDTH(DATA_WIDTH)) adder0 (.Din0(fin_0),
														.Din1(fin_1),
														.Din2(fin_2),
														.Din3(fin_3),
														.Din4(fin_4),
														.Din5(fin_5),
														.Din6(fin_6),
														.Din7(fin_7),
														.Din8(fin_8),
														.Dout(p_in));

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

adder9 #(.DATA_WIDTH(DATA_WIDTH)) adder1 (.Din0(cx0fin0),
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

adder9 #(.DATA_WIDTH(DATA_WIDTH)) adder2 (.Din0(cy0fin0),
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
																				  .q(ux_in),
																				  .r(remainder0));

fp_div #(.WIDTH(DATA_WIDTH), .FBITS(FRACTIONAL_BITS)) div_uy (.clk(CLOCK_50),
																			     .start(div_start),
																				  .busy(div_busy1),
																				  .valid(div_valid1),
																				  .dbz(dbz1),
																				  .ovf(ovf1),
																				  .x(puy_out),
																				  .y(p_out),
																				  .q(uy_in),
																				  .r(remainder1));
													
													
endmodule
