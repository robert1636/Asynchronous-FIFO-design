`timescale 1ns/1ps
module design_dut(
	output reg [27:0] data_out,
	output reg valid,
	output full,
	output empty,
	input w_req,
	input [31:0] data_in,
	input r_req,
	input p_clk,
	input s_clk,
	input rst
);

reg [27:0] fifo [31:0]; 	//FIFO modelling
reg [31:0] temp;		//temporary register for the co-processor
reg [27:0] result;
reg [5:0] wr_ptr;
reg [5:0] rd_ptr;
reg [13:0] source1, source2;
//reg signed [30:0] source1_32, source2_32;


assign empty = (wr_ptr == rd_ptr)?1'b1:1'b0;					//	Since the given library does not have MUX in it
assign full = ((wr_ptr[4:0] == rd_ptr[4:0]) && (wr_ptr[5] != rd_ptr[5]))?1'b1:1'b0;

/*always @(wr_ptr or rd_ptr) begin
	if (wr_ptr == rd_ptr) begin
		empty = 1'b1;	
	end
	else begin
		empty = 1'b0;	
	end
	if ((wr_ptr[4:0] == rd_ptr[4:0]) && (wr_ptr[5] != rd_ptr[5])) begin
		full = 1'b1;	
	end
	else begin
		full = 1'b0;	
	end
end	*/


always @ (posedge p_clk or negedge rst) begin
	if (!rst) begin
		temp = 32'b0;
	end 
	else if (w_req) begin
		temp = data_in;	
		source1 = temp[28:15];
		source2 = temp[14:1];

		if (temp[31:29] == 3'b000) begin		//ADD
			result = source1 + source2;
		end
		else if (temp[31:29] == 3'b001) begin		//SUB
			result = source1 - source2;
		end
		else if (temp[31:29] == 3'b010) begin		//AND
			result = source1 & source2;
		end
		else if (temp[31:29] == 3'b011) begin		//OR
			result = source1 | source2;
		end
		else if (temp[31:29] == 3'b100) begin		//MUL
			result = source1 * source2;
		end
		else if (temp[31:29] == 3'b101) begin		//SLT
			if (source1 < source2) begin
				result = 28'b1;
			end
			else begin
				result = 28'b0;
			end
		end
		else if (temp[31:29] == 3'b110) begin		//SGT
			if (source1 > source2) begin
				result = 28'b1;
			end
			else begin
				result = 28'b0;
			end
		end
		else if (temp[31:29] == 3'b111) begin		//XOR
			result = source1 ^ source2;
		end
	end
end


/*always @ (temp) begin
	source1 = temp[28:15];
	source2 = temp[14:1];

	if (temp[31:29] == 3'b000) begin		//ADD
		result = source1 + source2;
	end
	else if (temp[31:29] == 3'b001) begin		//SUB
		result = source1 - source2;
	end
	else if (temp[31:29] == 3'b010) begin		//AND
		result = source1 & source2;
	end
	else if (temp[31:29] == 3'b011) begin		//OR
		result = source1 | source2;
	end
	else if (temp[31:29] == 3'b100) begin		//MUL
		result = source1 * source2;
	end
	else if (temp[31:29] == 3'b101) begin		//SLT
		if (source1 < source2) begin
			result = 28'b1;
		end
		else begin
			result = 28'b0;
		end
	end
	else if (temp[31:29] == 3'b110) begin		//SGT
		if (source1 > source2) begin
			result = 28'b1;
		end
		else begin
			result = 28'b0;
		end
	end
	else if (temp[31:29] == 3'b111) begin		//XOR
		result = source1 ^ source2;
	end
end	*/

//Writing the data after its processed into the FIFO at the negedge of clock
always @(negedge p_clk or negedge rst) begin		
	if (!rst) begin			//Reset is low
		wr_ptr <= 6'b0;	
		fifo[00_0000] <= 28'b0;
		fifo[00_0001] <= 28'b0;
		fifo[00_0010] <= 28'b0;
		fifo[00_0011] <= 28'b0;
		fifo[00_0100] <= 28'b0;
		fifo[00_0101] <= 28'b0;
		fifo[00_0110] <= 28'b0;
		fifo[00_0111] <= 28'b0;
		fifo[00_1000] <= 28'b0;
		fifo[00_1001] <= 28'b0;
		fifo[00_1010] <= 28'b0;
		fifo[00_1011] <= 28'b0;
		fifo[00_1100] <= 28'b0;
		fifo[00_1101] <= 28'b0;
		fifo[00_1110] <= 28'b0;
		fifo[00_1111] <= 28'b0;
		fifo[01_0000] <= 28'b0;
		fifo[01_0001] <= 28'b0;
		fifo[01_0010] <= 28'b0;
		fifo[01_0011] <= 28'b0;
		fifo[01_0100] <= 28'b0;
		fifo[01_0101] <= 28'b0;
		fifo[01_0110] <= 28'b0;
		fifo[01_0111] <= 28'b0;
		fifo[01_1000] <= 28'b0;
		fifo[01_1001] <= 28'b0;
		fifo[01_1010] <= 28'b0;
		fifo[01_1011] <= 28'b0;
		fifo[01_1100] <= 28'b0;
		fifo[01_1101] <= 28'b0;
		fifo[01_1110] <= 28'b0;
		fifo[01_1111] <= 28'b0;
	end
	else if (w_req==1'b1) begin	//Reset is high and w_req is high
		fifo[wr_ptr] <= result;
		wr_ptr <= wr_ptr + 1;
	end
end
//-----------------------------------------

//Slave request check
always @ (posedge s_clk or negedge rst) begin
	if (!rst) begin
		data_out <= 28'b0;
		rd_ptr <= 6'b0;
		valid <= 1'b0;	
	end

	else if (r_req) begin
		data_out <= fifo[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		valid <= 1'b1;				
	end
	else begin
		valid <= 1'b0;
	end
end

endmodule

