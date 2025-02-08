`timescale 1ns / 1ps
module RAM #(  
    parameter   DATA_WIDTH = 32 ,
                ADDR_WIDTH = 32 ,
                RAM_DEPTH  = 1000
    )(
    input clk_i , // Clock signal
    input we_i , // Write enable
    input rd_i, // Read enable
    input [ADDR_WIDTH-1 : 0] addr_i , // Address input
    input [DATA_WIDTH-1 : 0] data_i , // Data input
    output wire [DATA_WIDTH-1 : 0] data_o  // Data output
    );

// RAM memory array declaration
reg [DATA_WIDTH-1 : 0] RAM [0 : RAM_DEPTH-1] ; 
// Temporary register for data output
reg [DATA_WIDTH-1 : 0] RAM_data = {DATA_WIDTH {1'bz}} ;

always @(posedge clk_i) begin
    if(we_i) begin
        // Write operation: Store data at the given address
        RAM [addr_i] <= data_i ;
        RAM_data <= {DATA_WIDTH {1'bz}}; 
        // If there is no data output, set to high impedance
    end
    else if(rd_i) begin
        // Read operation: Output data from the given address
        RAM_data <= RAM [addr_i] ;
    end else begin 
        // No read/write operation: Set output to high impedance
        RAM_data <= {DATA_WIDTH {1'bz}};
    end
end

// Assign output data
assign data_o = RAM_data;

endmodule
