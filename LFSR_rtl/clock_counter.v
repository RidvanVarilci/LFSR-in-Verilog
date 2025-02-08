`timescale 1ns/1ps
module clock_counter #(
    parameter n=32)( // How long do you want to count
    input  clk,
    input  rst,
    output wire [(n-1):0] count 
    );
reg [(n-1):0] count_1;

always@(posedge clk) begin
    if (rst)count_1 <= 32'h0000_0000;
    else count_1 <= count_1 + 1'b1; 
end
assign count = count_1;
endmodule