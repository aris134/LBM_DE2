module LBM_DE2	#(GRID_DIM=16*16, MAX_TIME=8, TIME_COUNT_WIDTH=$clog2(MAX_TIME),
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
logic [3:0] select_fin_mem;
logic [3:0] select_fin_addr;
logic count_init_en;
logic row_count_en;
logic time_count_en;

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
logic [TIME_COUNT_WIDTH-1:0] time_count;

logic [9*(ADDRESS_WIDTH+1)-1:0] stream_addresses;

int num_valid_addr;

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

logic signed [DATA_WIDTH-1:0] pwr;
logic signed [DATA_WIDTH-1:0] gnd;

assign pwr = 32'h01_000000;
assign gnd = 32'h00_000000;

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
logic signed [DATA_WIDTH_F-1:0] fout_mem_in;
logic signed [DATA_WIDTH_F-1:0] fout_mem_out;

logic signed [DATA_WIDTH_F-1:0] fin_mem_in;
logic [ADDRESS_WIDTH-1:0] fin_addr_in;

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


logic signed [ADDRESS_WIDTH-1:0] cx0_int;
logic signed [ADDRESS_WIDTH-1:0] cx1_int;
logic signed [ADDRESS_WIDTH-1:0] cx2_int;
logic signed [ADDRESS_WIDTH-1:0] cx3_int;
logic signed [ADDRESS_WIDTH-1:0] cx4_int;
logic signed [ADDRESS_WIDTH-1:0] cx5_int;
logic signed [ADDRESS_WIDTH-1:0] cx6_int;
logic signed [ADDRESS_WIDTH-1:0] cx7_int;
logic signed [ADDRESS_WIDTH-1:0] cx8_int;

logic signed [ADDRESS_WIDTH:0] cx0_int_sext;
logic signed [ADDRESS_WIDTH:0] cx1_int_sext;
logic signed [ADDRESS_WIDTH:0] cx2_int_sext;
logic signed [ADDRESS_WIDTH:0] cx3_int_sext;
logic signed [ADDRESS_WIDTH:0] cx4_int_sext;
logic signed [ADDRESS_WIDTH:0] cx5_int_sext;
logic signed [ADDRESS_WIDTH:0] cx6_int_sext;
logic signed [ADDRESS_WIDTH:0] cx7_int_sext;
logic signed [ADDRESS_WIDTH:0] cx8_int_sext;

logic signed [ADDRESS_WIDTH-1:0] cy0_int;
logic signed [ADDRESS_WIDTH-1:0] cy1_int;
logic signed [ADDRESS_WIDTH-1:0] cy2_int;
logic signed [ADDRESS_WIDTH-1:0] cy3_int;
logic signed [ADDRESS_WIDTH-1:0] cy4_int;
logic signed [ADDRESS_WIDTH-1:0] cy5_int;
logic signed [ADDRESS_WIDTH-1:0] cy6_int;
logic signed [ADDRESS_WIDTH-1:0] cy7_int;
logic signed [ADDRESS_WIDTH-1:0] cy8_int;

logic signed [ADDRESS_WIDTH:0] cy0_int_sext;
logic signed [ADDRESS_WIDTH:0] cy1_int_sext;
logic signed [ADDRESS_WIDTH:0] cy2_int_sext;
logic signed [ADDRESS_WIDTH:0] cy3_int_sext;
logic signed [ADDRESS_WIDTH:0] cy4_int_sext;
logic signed [ADDRESS_WIDTH:0] cy5_int_sext;
logic signed [ADDRESS_WIDTH:0] cy6_int_sext;
logic signed [ADDRESS_WIDTH:0] cy7_int_sext;
logic signed [ADDRESS_WIDTH:0] cy8_int_sext;

assign cx0_int = cx_0[DATA_WIDTH-1:DATA_WIDTH-8];
assign cx1_int = cx_1[DATA_WIDTH-1:DATA_WIDTH-8];
assign cx2_int = cx_2[DATA_WIDTH-1:DATA_WIDTH-8];
assign cx3_int = cx_3[DATA_WIDTH-1:DATA_WIDTH-8];
assign cx4_int = cx_4[DATA_WIDTH-1:DATA_WIDTH-8];
assign cx5_int = cx_5[DATA_WIDTH-1:DATA_WIDTH-8];
assign cx6_int = cx_6[DATA_WIDTH-1:DATA_WIDTH-8];
assign cx7_int = cx_7[DATA_WIDTH-1:DATA_WIDTH-8];
assign cx8_int = cx_8[DATA_WIDTH-1:DATA_WIDTH-8];

assign cy0_int = cy_0[DATA_WIDTH-1:DATA_WIDTH-8];
assign cy1_int = cy_1[DATA_WIDTH-1:DATA_WIDTH-8];
assign cy2_int = cy_2[DATA_WIDTH-1:DATA_WIDTH-8];
assign cy3_int = cy_3[DATA_WIDTH-1:DATA_WIDTH-8];
assign cy4_int = cy_4[DATA_WIDTH-1:DATA_WIDTH-8];
assign cy5_int = cy_5[DATA_WIDTH-1:DATA_WIDTH-8];
assign cy6_int = cy_6[DATA_WIDTH-1:DATA_WIDTH-8];
assign cy7_int = cy_7[DATA_WIDTH-1:DATA_WIDTH-8];
assign cy8_int = cy_8[DATA_WIDTH-1:DATA_WIDTH-8];

logic signed [9*(ADDRESS_WIDTH+1)-1:0] cx_int_concat;
logic signed [9*(ADDRESS_WIDTH+1)-1:0] cy_int_concat;

assign cx_int_concat = {cx0_int_sext, cx1_int_sext, cx2_int_sext, cx3_int_sext, cx4_int_sext, cx5_int_sext, cx6_int_sext, cx7_int_sext, cx8_int_sext};
/*assign cy_int_concat = {-cy0_int_sext, ~cy1_int_sext+1, ~cy2_int_sext+1, ~cy3_int_sext+1,
							   ~cy4_int_sext+1, ~cy5_int_sext+1, ~cy6_int_sext+1, ~cy7_int_sext+1, ~cy8_int_sext+1};*/
								
assign cy_int_concat = {9'b0_0000_0000, 9'b0_0000_0000, 9'b1_1111_1111, 9'b0_0000_0000, 9'b0_0000_0001, 9'b1_1111_1111, 9'b1_1111_1111, 9'b0_0000_0001, 9'b0_0000_0001};


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

assign fout_mem_in = {fout0_out,fout1_out,fout2_out,fout3_out,fout4_out,fout5_out,fout6_out,fout7_out,fout8_out};

logic [COUNT_WIDTH-1:0] y_pos; // rows
logic [ADDRESS_WIDTH-1:0] x_pos; // columns
logic signed [ADDRESS_WIDTH:0] x_pos_zext;
logic signed [ADDRESS_WIDTH:0] y_pos_zext;

assign x_pos_zext = {1'b0,x_pos};
assign y_pos_zext = {{ADDRESS_WIDTH+1-COUNT_WIDTH{1'b0}}, y_pos};

logic LID;
logic BOTTOM_WALL;
logic LEFT_WALL;
logic RIGHT_WALL;

logic signed [DATA_WIDTH-1:0] omega; // delta(t)/tau
logic signed [DATA_WIDTH-1:0] omega_prime; // 1-delta(t)/tau

assign omega = 32'h01_71F133; // w (relaxation parameter)
assign omega_prime = 32'hFF_8E0ECD; // 1 - w

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
																										  .Enable(row_count_en), // wrong enable
																										  .count_init(count_init),
																										  .Data_out(y_pos));																									  

// time step counter

time_step_counter #(.MAX_TIME(MAX_TIME), .TIME_COUNT_WIDTH(TIME_COUNT_WIDTH)) timer (.Clk(CLOCK_50), .Reset(RESET), .Enable(time_count_en), .Data_out(time_count));
																									  
// controller
controller fsm (.Clk(CLOCK_50),
					  .Reset(RESET),
					  .count_init(count_init),
					  .time_count(time_count),
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
					  .select_fin_addr(select_fin_addr),
					  .select_uy_reg(select_uy_reg),
					  .select_p_reg(select_p_reg),
					  .select_fin_mem(select_fin_mem),
					  .count_init_en(count_init_en),
					  .row_count_en(row_count_en),
					  .time_count_en(time_count_en),
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
					  .LD_EN_FOUT8(LD_EN_FOUT8));


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
																															  
distribution_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH_F)) fin_ram (.address(fin_addr_in),
                                                                                                        .Clk(CLOCK_50),
																																		  .WE(WE_fin_mem),
																																		  .data_in(fin_mem_in),
																																		  .data_out(fin_out));

distribution_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH_F)) feq_ram (.address(count_init),
                                                                                                        .Clk(CLOCK_50),
																																		  .WE(WE_feq_mem),
																																		  .data_in(feq_in),
																																		  .data_out(feq_out));
																																		  
distribution_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH_F)) fout_ram (.address(count_init),
                                                                                                        .Clk(CLOCK_50),
																																		  .WE(WE_fout_mem),
																																		  .data_in(fout_mem_in),
																																		  .data_out(fout_mem_out));
											  
																																		  
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
	
// fin_mem multiplexer
													
mux11 #(.DATA_WIDTH(DATA_WIDTH_F)) fin_mem_mux (.Din0(weights),
															   .Din1(feq_in),
																.Din2({fout_mem_out[9*DATA_WIDTH-1:8*DATA_WIDTH], fin_1, fin_2, fin_3, fin_4, fin_5, fin_6, fin_7, fin_8}), // actually fin with fin0 replaced with fout0
																.Din3({fin_0, fout_mem_out[8*DATA_WIDTH-1:7*DATA_WIDTH], fin_2, fin_3, fin_4, fin_5, fin_6, fin_7, fin_8}), // fin with f1 replaced with fout1
																.Din4({fin_0, fin_1, fout_mem_out[7*DATA_WIDTH-1:6*DATA_WIDTH], fin_3, fin_4, fin_5, fin_6, fin_7, fin_8}), // etc.
																.Din5({fin_0, fin_1, fin_2, fout_mem_out[6*DATA_WIDTH-1:5*DATA_WIDTH], fin_4, fin_5, fin_6, fin_7, fin_8}),
																.Din6({fin_0, fin_1, fin_2, fin_3, fout_mem_out[5*DATA_WIDTH-1:4*DATA_WIDTH], fin_5, fin_6, fin_7, fin_8}),
																.Din7({fin_0, fin_1, fin_2, fin_3, fin_4, fout_mem_out[4*DATA_WIDTH-1:3*DATA_WIDTH], fin_6, fin_7, fin_8}),
																.Din8({fin_0, fin_1, fin_2, fin_3, fin_4, fin_5, fout_mem_out[3*DATA_WIDTH-1:2*DATA_WIDTH], fin_7, fin_8}),
																.Din9({fin_0, fin_1, fin_2, fin_3, fin_4, fin_5, fin_6, fout_mem_out[2*DATA_WIDTH-1:DATA_WIDTH], fin_8}),
																.Din10({fin_0, fin_1, fin_2, fin_3, fin_4, fin_5, fin_6, fin_7, fout_mem_out[DATA_WIDTH-1:0]}),
																.select(select_fin_mem),
																.Dout(fin_mem_in));		

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

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext0 (.Data_In(cx0_int),
																											  .Data_Out(cx0_int_sext));
																											  
sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext1 (.Data_In(cx1_int),
																											  .Data_Out(cx1_int_sext));

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext2 (.Data_In(cx2_int),
																											  .Data_Out(cx2_int_sext));

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext3 (.Data_In(cx3_int),
																											  .Data_Out(cx3_int_sext));

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext4 (.Data_In(cx4_int),
																											  .Data_Out(cx4_int_sext));

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext5 (.Data_In(cx5_int),
																											  .Data_Out(cx5_int_sext));

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext6 (.Data_In(cx6_int),
																											  .Data_Out(cx6_int_sext));

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext7 (.Data_In(cx7_int),
																											  .Data_Out(cx7_int_sext));

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext8 (.Data_In(cx8_int),
																											  .Data_Out(cx8_int_sext));

//

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext9 (.Data_In(cy0_int),
																											  .Data_Out(cy0_int_sext));
																											  
sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext10 (.Data_In(cy1_int),
																											  .Data_Out(cy1_int_sext));

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext11 (.Data_In(cy2_int),
																											  .Data_Out(cy2_int_sext));

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext12 (.Data_In(cy3_int),
																											  .Data_Out(cy3_int_sext));

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext13 (.Data_In(cy4_int),
																											  .Data_Out(cy4_int_sext));

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext14 (.Data_In(cy5_int),
																											  .Data_Out(cy5_int_sext));

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext15 (.Data_In(cy6_int),
																											  .Data_Out(cy6_int_sext));

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext16 (.Data_In(cy7_int),
																											  .Data_Out(cy7_int_sext));

sign_extender #(.INPUT_WIDTH(ADDRESS_WIDTH), .OUTPUT_WIDTH(ADDRESS_WIDTH+1)) sext17 (.Data_In(cy8_int),
																											  .Data_Out(cy8_int_sext));
	

streaming_unit #(.GRID_DIM(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH+1)) streamer (.x(x_pos_zext),
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
				  .select(select_fin_addr),
				  .Dout(fin_addr_in));
endmodule
