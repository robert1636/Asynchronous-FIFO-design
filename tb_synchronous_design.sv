//`include "design_v3_synthesis_unsigned.sv"
//`include "synchronous_design.sv"
`include "synchronous_design_gates_new.v"
//`include "design_v3_unsigned_synthesis_gates.v"		//netlist
						
//`timescale 1ns/1ps

module tb(
	output reg [31:0] data_out,
	output reg wr_req,
	output reg rd_req,
	output reg p_clk,
	output reg rst,
	output reg s_clk,
	input [27:0] data_in,
	input valid,
	input full,
	input empty
);

// Instantion of the design
design_dut dut(
		.p_clk(p_clk),
		.s_clk(s_clk),
		.rst(rst),
		.data_in(data_out),
		.data_out(data_in),
		.valid(valid),
		.w_req(wr_req),
		.r_req(rd_req),
		.full(full),
		.empty(empty)
);

//Processor clock generation
initial begin
	s_clk = 0;
	forever s_clk = #10 ~s_clk;
end

//Slave clock generation
initial begin
	p_clk = 1'b0;
	forever p_clk = #5 ~p_clk;
end

initial begin
	rst = 0;
	data_out = 32'b000_00000000001000_00000000001000_0;		
	wr_req = 0;
	rd_req = 0;
	#12 rst = 1;
//	#1 $display("wr_ptr = %b", dut.wr_ptr);
//	   $display("rd_ptr = %b", dut.rd_ptr);
	#10 wr_req = 1;
	    data_out = 32'b000_00000000001000_00000000001000_0;		//ADD: 8+8 = 16
	#10 data_out = 32'b001_00000000001001_00000000000101_0;		//SUB: 9-5 = 4
	#10 data_out = 32'b010_00000000001001_00000000000101_0; 	//AND: 9 & 5 = 1
	#10 data_out = 32'b011_00000000001001_00000000000101_0;		//OR: 9 | 5 = 13
	#10 data_out = 32'b100_00000000001001_00000000000101_0;		//MUL: 9 * 5 = 45
	#10 data_out = 32'b101_00000000001001_00000000000101_0;		//SLT: 9 < 5 = 0
	#10 data_out = 32'b110_00000000001001_00000000000101_0;		//SGT: 9 > 5 = 1
	#10 data_out = 32'b111_00000000001001_00000000000101_0;		//XOR: 9 ^ 5 = 12
	#10 rd_req = 1;
/*	$monitor("fifo[0] = %b", dut.fifo[6'b00_0000]);
	$monitor("fifo[1] = %b", dut.fifo[6'b00_0001]);
	$monitor("fifo[2] = %b", dut.fifo[6'b00_0010]);
	$monitor("fifo[3] = %b", dut.fifo[6'b00_0011]);
	$monitor("fifo[4] = %b", dut.fifo[6'b00_0100]);
	$monitor("fifo[5] = %b", dut.fifo[6'b00_0101]);
	$monitor("fifo[6] = %b", dut.fifo[6'b00_0110]);
	$monitor("fifo[7] = %b", dut.fifo[6'b00_0111]);
//	$monitor("fifo[8] = %b", dut.fifo[6'b00_0010]);
	$monitor("wr_ptr = %b", dut.wr_ptr);		*/
	#200 $finish;
end

//Waveform
initial begin
//	$dumpfile("synchronous_design.vcd");
	$dumpfile("synchronous_design_gates_new.vcd");
	$dumpvars;
end
endmodule

