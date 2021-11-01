module LBM_DE2	#(GRID_DIM=16*16,
		DATA_WIDTH=32, ADDRESS_WIDTH=$clog2(GRID_DIM),
		DATA_WIDTH_F=9*DATA_WIDTH)(
		
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

logic [ADDRESS_WIDTH-1:0] count_init;

logic signed [DATA_WIDTH-1:0] pwr;
logic signed [DATA_WIDTH-1:0] gnd;

assign pwr = {{DATA_WIDTH-1{1'b0}}, 1'b1};
assign gnd = {{DATA_WIDTH{1'b0}}};

logic signed [DATA_WIDTH_F-1:0] weights;
logic signed [DATA_WIDTH_F-1:0] cx;
logic signed [DATA_WIDTH_F-1:0] cy;

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
logic LD_EN_P;

assign fin_mem_data_out = fin_out;
assign fin_0 = fin_out[DATA_WIDTH-1:0];
assign fin_1 = fin_out[2*DATA_WIDTH-1:DATA_WIDTH];
assign fin_2 = fin_out[3*DATA_WIDTH-1:2*DATA_WIDTH];
assign fin_3 = fin_out[4*DATA_WIDTH-1:3*DATA_WIDTH];
assign fin_4 = fin_out[5*DATA_WIDTH-1:4*DATA_WIDTH];
assign fin_5 = fin_out[6*DATA_WIDTH-1:5*DATA_WIDTH];
assign fin_6 = fin_out[7*DATA_WIDTH-1:6*DATA_WIDTH];
assign fin_7 = fin_out[8*DATA_WIDTH-1:7*DATA_WIDTH];
assign fin_8 = fin_out[9*DATA_WIDTH-1:8*DATA_WIDTH];


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
																															  .LD_EN_P(LD_EN_P));

																					  
// weights register
weights_reg #(.WIDTH(DATA_WIDTH_F)) w_reg (.Reset(RESET),
													    .Data_Out(weights));
														 
// cx register

// cy register


// memories	
moment_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)) p_ram (.address(count_init),
																															 .Clk(CLOCK_50),
																															 .WE(WE_p_mem),
																															 .data_in(pwr),
																															 .data_out(p_mem_data_out));
																															 
moment_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)) ux_ram (.address(count_init),
																															  .Clk(CLOCK_50),
																															  .WE(WE_ux_mem),
																															  .data_in(gnd),
																															  .data_out(ux_mem_data_out));
																															  
moment_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)) uy_ram (.address(count_init),
																															  .Clk(CLOCK_50),
																															  .WE(WE_uy_mem),
																															  .data_in(gnd),
																															  .data_out(uy_mem_data_out));
																															  
distribution_ram #(.DEPTH(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH_F)) fin_ram (.address(count_init),
                                                                                                        .Clk(CLOCK_50),
																																		  .WE(WE_fin_mem),
																																		  .data_in(weights),
																																		  .data_out(fin_out));

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
													 
cx_reg #(.WIDTH(DATA_WIDTH_F)) reg_cx (.Reset(RESET),
											  .Data_Out(cx));
											  
cy_reg #(.WIDTH(DATA_WIDTH_F)) reg_cy (.Reset(RESET),
											  .Data_Out(cy));
																																		  
endmodule
