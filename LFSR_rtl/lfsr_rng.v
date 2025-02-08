`timescale 1ns/1ps
module lfsr_rng #(
    parameter n=32,
    parameter DATA_WIDTH = 32 ,          
    parameter ADDR_WIDTH = 32 ,
    parameter RAM_DEPTH  = 100
    )(
    input  clk,
    input  rst,
    input  request, // Starts number generation
    //output wire error,  // optional
    output wire [31:0] rnd // 32-bit random number
    );

  localparam idle = 1'b0; 
  localparam generate_number = 1'b1; 
  reg state = idle; 
  
  reg [31:0] lfsr;         // LFSR shift register
  reg [31:0] max_length;  // Resets when max number is generated
  reg [31:0] buffer_mem; // Prevents the first number from being zero
  wire [(n-1):0] counter;
  
// RAM Instantiate
  RAM #(  
     .DATA_WIDTH (DATA_WIDTH),
     .ADDR_WIDTH (ADDR_WIDTH),
     .RAM_DEPTH  (RAM_DEPTH)
     )RAM_mem(
     .clk_i  (clk),
     .we_i   (),
     .rd_i   (),
     .addr_i (),
     .data_i (rnd),
     .data_o ()
     );
  
  // Clock counter Instantiate
  clock_counter #(
     .n(n)
     )counting(
     .clk(clk),
     .rst(rst),
     .count(counter)
     );

always@(posedge clk or posedge rst) begin
    if (rst) begin
        buffer_mem <= counter;
        lfsr <= 32'hz; // On reset and idle state, output should be in high-impedance state (Z)
        max_length <= 32'h0000_0000;
    end else begin 
        case(state)
            idle: begin
               lfsr <= 32'hz;
               buffer_mem <= counter;
               if (request) begin 
                   if(buffer_mem != 32'hFFFF_FFFF) begin // Prevent lock-up state - all-ones state
                        lfsr <= buffer_mem;
                        max_length <= 32'h0000_0000;
                        state <= generate_number;
                    end else begin
                        // error <= 1'b1 ; // Optional error signal
                        buffer_mem <= 32'h97AF_C3D0; // Reset to a value or use error signal
                    end
                end else begin
                   state <= idle;
                end
            end
            generate_number: begin
                if(request) begin
                   max_length <= max_length + 1;
                   if (max_length == 32'hFFFF_FFFF) begin
                       max_length <= 32'h0000_0000;
                       lfsr <= counter;
                   end
                   lfsr <= {lfsr[30:0], lfsr[31] ~^ lfsr[21] ~^ lfsr[1] ~^ lfsr[0]}; 
				   // LFSR update using XNOR taps
                end else begin
                   lfsr <= 32'hz;
                   state <= idle;
                end
            end
            default: begin 
            lfsr <= 32'hz;
            state <= idle;
            end
        endcase 
    end
end
assign rnd = lfsr;
endmodule
