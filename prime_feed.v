`timescale 1ns / 1ps

module prime_feed 
#(
	parameter       WIDTH 	= 512
)(
	input aclk,    // Clock
	input aresetn,  // Asynchronous reset active low

	input wire             next,
	
	output reg             pqrs_ready,
	output reg [WIDTH-1:0] p, 
	output reg [WIDTH-1:0] q,
	output reg [WIDTH-1:0] r,
	output reg [WIDTH-1:0] s


);
//----------------------------------------------------------------
// Parameters.
//----------------------------------------------------------------

localparam STATE_INIT    = 3'd0;       
localparam STATE_ROUND   = 3'd1;       
localparam STATE_NEXT_01 = 3'd2;        
localparam STATE_NEXT_02 = 3'd3;     
localparam STATE_DONE    = 3'd4;      
	

//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------
reg             init_round; 
reg [WIDTH-1:0] pqrs [3:0]; 
reg [2:0]       Internal_counter;
wire 			fifo_empty;
reg 			fifo_rd_en;
reg [WIDTH-1:0] fifo_dout;

reg [3:0]       state;
//----------------------------------------------------------------
// assignments for ports.
//----------------------------------------------------------------
assign fifo_empty = 1'b0;//simulation
//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
always @(*) begin 
	p = pqrs[2'd0];
	q = pqrs[2'd1];
	r = pqrs[2'd2];
	s = pqrs[2'd3];
end
//check init_round
always @(posedge aclk) begin 
	if(!aresetn) begin
		init_round <= 1'b1;
	end else begin
		case (state)

			STATE_NEXT_01  :
			begin
				if (Internal_counter == 3'd3) begin
					init_round <= 1'b0;
				end 
			end
			
			default : /* default */;
		endcase
	end
end



always @(posedge aclk) begin 
	if(!aresetn) begin
		state <= STATE_INIT;
	end else begin
		case (state)
			STATE_INIT :
			begin
				if (next) begin
					state <= STATE_ROUND;
				end
			end
			STATE_ROUND :
			begin
				if (!fifo_empty && init_round) begin //initial round set p,q,r,s
					state <= STATE_NEXT_01;
				end else if (!fifo_empty&& !init_round) begin// set pqrs one per each round
					state <= STATE_NEXT_02;
				end
				
			end
			STATE_NEXT_01  :
			begin
				if (Internal_counter == 3'd3) begin
				    state <= STATE_DONE;
				end else begin
					state <= STATE_ROUND;
				end
			end
			STATE_NEXT_02  :
			begin
				state <= STATE_DONE;
			end
			STATE_DONE  :
			begin
				state <= STATE_INIT;
		    end 
			
		
			default : /* default */;
		endcase
	end
end
//fifo rd_en
always @(posedge aclk) begin 
	if(!aresetn) begin
		fifo_rd_en <= 1'b0;
	end else begin
		case (state)

			STATE_ROUND :
			begin
				fifo_rd_en <= 1'b0;
			end
			STATE_NEXT_01  :
			begin
				fifo_rd_en <= 1'b1;
			end
			STATE_NEXT_02  :
			begin
				fifo_rd_en <= 1'b1;
			end
			STATE_DONE  :
			begin
				fifo_rd_en <= 1'b0;
		    end 
			
		
			default : /* default */;
		endcase
	end
end
//set p,q,r,s
always @(posedge aclk) begin 
	if(!aresetn) begin
		pqrs[2'd0] <= 512'b0;
		pqrs[2'd1] <= 512'b0;
		pqrs[2'd2] <= 512'b0;
		pqrs[2'd3] <= 512'b0;
	end else begin
		case (state)
		/*	STATE_INIT :
			begin
				pqrs[2'd0] <= 512'b0;
				pqrs[2'd1] <= 512'b0;
				pqrs[2'd2] <= 512'b0;
				pqrs[2'd3] <= 512'b0;
			end
	*/
			STATE_NEXT_01  :
			begin
				//pqrs [Internal_counter] <= fifo_dout;
                pqrs [Internal_counter] <= prime_array_temp[Internal_counter+1];//prime_array_temp[$urandom%65];//$urandom%99;//for simulation

			end
			STATE_NEXT_02  :
			begin
				//pqrs [Internal_counter] <= fifo_dout;
				pqrs [Internal_counter] <= prime_array_temp[Internal_counter+1];//prime_array_temp[$urandom%65];//$urandom%99;//for simulation
			end
		
			default : /* default */;
		endcase
	end
end


//Internal_counter <= 3'b0;
always @(posedge aclk) begin 
	if(!aresetn) begin
		Internal_counter <= 3'b0;
	end else begin
		case (state)
			/*STATE_INIT :
			begin
				Internal_counter <= 3'b0;
			end
		*/
			STATE_NEXT_01  :
			begin
				Internal_counter <= Internal_counter + 1'b1; 
				if (Internal_counter == 3'd3) begin
					Internal_counter <= 3'b0;
				end 
			end
			STATE_NEXT_02  :
			begin
				Internal_counter <= (Internal_counter+1'b1)%3'd4;
			end
		
			default : /* default */;
		endcase
	end
end

//pqrs ready
always @(posedge aclk) begin 
	if(!aresetn) begin
		pqrs_ready <= 1'b0;
	end else begin
		case (state)
			STATE_INIT :
			begin
				pqrs_ready <= 1'b0;
			end
	
			STATE_DONE  :
			begin
				pqrs_ready <= 1'b1;
		    end 
			
		
			default : /* default */;
		endcase
	end
end

/////////////////////////////////////////////////////////////////////////////
wire [9:0] prime_array_temp  [65:0];

assign prime_array_temp[0] =  10'd2;
assign prime_array_temp[1] =  10'd3;
assign prime_array_temp[2] =  10'd5;
assign prime_array_temp[3] =  10'd7;
assign prime_array_temp[4] =  10'd11;
assign prime_array_temp[5] =  10'd13;
assign prime_array_temp[6] =  10'd17;
assign prime_array_temp[7] =  10'd19;
assign prime_array_temp[8] =  10'd23;
assign prime_array_temp[9] =  10'd29;
assign prime_array_temp[10] = 10'd31;
assign prime_array_temp[11] = 10'd37;
assign prime_array_temp[12] = 10'd41;
assign prime_array_temp[13] = 10'd43;
assign prime_array_temp[14] = 10'd47;
assign prime_array_temp[15] = 10'd53;
assign prime_array_temp[16] = 10'd59;
assign prime_array_temp[17] = 10'd61;
assign prime_array_temp[18] = 10'd67;
assign prime_array_temp[19] = 10'd71;
assign prime_array_temp[20] = 10'd73;
assign prime_array_temp[21] = 10'd79;
assign prime_array_temp[22] = 10'd83;
assign prime_array_temp[23] = 10'd89;
assign prime_array_temp[24] = 10'd97;
assign prime_array_temp[25] = 10'd101;
assign prime_array_temp[26] = 10'd103;
assign prime_array_temp[27] = 10'd107;
assign prime_array_temp[28] = 10'd109;
assign prime_array_temp[29] = 10'd113;
assign prime_array_temp[30] = 10'd121;
assign prime_array_temp[31] = 10'd127;
assign prime_array_temp[32] = 10'd131;
assign prime_array_temp[33] = 10'd137;
assign prime_array_temp[34] = 10'd139;
assign prime_array_temp[35] = 10'd143;
assign prime_array_temp[36] = 10'd149;
assign prime_array_temp[37] = 10'd151;
assign prime_array_temp[38] = 10'd157;
assign prime_array_temp[39] = 10'd163;
assign prime_array_temp[40] = 10'd167;
assign prime_array_temp[41] = 10'd169;
assign prime_array_temp[42] = 10'd173;
assign prime_array_temp[43] = 10'd179;
assign prime_array_temp[44] = 10'd181;
assign prime_array_temp[45] = 10'd187;
assign prime_array_temp[46] = 10'd191;
assign prime_array_temp[47] = 10'd193;
assign prime_array_temp[48] = 10'd197;
assign prime_array_temp[49] = 10'd199;
assign prime_array_temp[50] = 10'd209;
assign prime_array_temp[51] = 10'd211;
assign prime_array_temp[52] = 10'd221;
assign prime_array_temp[53] = 10'd223;
assign prime_array_temp[54] = 10'd227;
assign prime_array_temp[55] = 10'd229;
assign prime_array_temp[56] = 10'd233;
assign prime_array_temp[57] = 10'd239;
assign prime_array_temp[58] = 10'd241;
assign prime_array_temp[59] = 10'd247;
assign prime_array_temp[60] = 10'd251;
assign prime_array_temp[61] = 10'd253;
assign prime_array_temp[62] = 10'd257;
assign prime_array_temp[63] = 10'd263;
assign prime_array_temp[64] = 10'd269;

endmodule //prime_feed
