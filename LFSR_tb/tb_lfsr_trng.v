`timescale 1ns/1ps
module tb_lfsr_trng;
  
  parameter n=32;
  parameter DATA_WIDTH = 32;
  parameter ADDR_WIDTH = 32;
  parameter RAM_DEPTH  = 100; // how many numbers going to generate
  reg clk;
  reg rst;
  reg request;
  reg we_i;
  reg rd_i;
  reg [ADDR_WIDTH-1 : 0] addr_i;
  wire [DATA_WIDTH-1 : 0] data_o;
  wire [31:0] rnd;
  wire [n-1 : 0] counter;
  
  // Instantiate RAM module
  RAM #(  
     .DATA_WIDTH (DATA_WIDTH),
     .ADDR_WIDTH (ADDR_WIDTH),
     .RAM_DEPTH  (RAM_DEPTH)
     )uut_1(
     .clk_i  (clk),
     .we_i   (we_i),
     .rd_i   (rd_i),
     .addr_i (addr_i),
     .data_i (rnd),
     .data_o (data_o)
     );
  
  // Instantiate LFSR-based RNG module
  lfsr_rng #(
    .n(n),                   
    .DATA_WIDTH(DATA_WIDTH),        
    .ADDR_WIDTH(ADDR_WIDTH),
    .RAM_DEPTH  (RAM_DEPTH)
    )uut_2(
    .clk(clk),
    .rst(rst),
    .request(request),
    .rnd(rnd)
    );
  
  // Instantiate clock counter module
  clock_counter #(
   .n(n)
   )counting(
   .clk(clk),
   .rst(rst),
   .count(counter)
   );

  integer file; // File descriptor for writing TXT file
  integer i, j; // Loop counters for comparison
  reg [DATA_WIDTH-1:0] values [0:RAM_DEPTH-1]; 
  // Array to store RAM contents for comparison
  integer copy_count = 0; // Counter for duplicate values

// Clock generation
initial begin
clk = 1;
forever #5 clk = ~clk;
end

// Testbench execution
initial begin
    file = $fopen("C:/Users/........./random_data.txt", "w"); // Open file
     if (file == 0) begin // If file opening fails, print an error
        $display("ERROR: Failed to open file!");
        $finish;
      end
      
    // Initialize signals
    we_i = 0;
    rd_i = 0;
    request = 0;
    addr_i = 0;
    rst = 1;
    #20 rst = 0;
    #1000;

// Generate numbers
    request = 1;
    we_i = 1; // Enable writing to RAM
    repeat (RAM_DEPTH) begin
      #10; // Wait one clock cycle
      $fwrite(file, "%d\n", rnd); // Write generated values to TXT file
      $display("Random Number %d: %d", addr_i, rnd); // Print to console
      addr_i <= addr_i + 1; // Increment address counter
    end
    we_i <= 0;
    addr_i <= 0;
    request = 0;

// Try generating a number while request is 0
    repeat (3) begin
      #10; // Wait a few clock cycles
      $display("Random Number: %d", rnd);
      $fwrite(file, "%d\n", rnd);
    end

// Read numbers stored in RAM and print them
    #1000; 
    $display("                         READING DATA");
    rd_i <= 1;
    #10; // Wait for first data retrieval
    for(addr_i = 0; addr_i < RAM_DEPTH; addr_i = addr_i + 1) begin
      #10;
      $display("Data At Address %d: %d", addr_i, data_o);
    end
    rd_i <= 0;

// Generate new numbers
    request = 1;
    we_i = 1;
    addr_i <= 0;
    repeat (RAM_DEPTH) begin
      #10; // Wait a few clock cycles
      $fwrite(file, "%d\n", rnd); // Write to TXT file
      addr_i <= addr_i + 1;
    end
    we_i <= 0;
    addr_i <= 0;
    request = 0;
    $fclose(file); // Close file

// Compare stored values to detect duplicates
    $display("                         COMPARING DATA");
    // Read all values from RAM and store in array
    for (i = 0; i <= RAM_DEPTH; i = i + 1) begin
        addr_i = i;
        rd_i = 1;
        values[i] = data_o;
        #10;
    end
    rd_i = 0;

    // Compare all values to find duplicates
    for (i = 0; i < RAM_DEPTH; i = i + 1) begin // Loop over all stored numbers
        for (j = 0; j < RAM_DEPTH ; j = j + 1) begin // Compare i-th number with others
            if (i != j) begin // Skip comparing the number with itself
                if (values[i] == values[j]) begin
                    $display("COPY FOUND! Value: %d at addresses %d and %d", values[i], i, j);
                    // Print duplicate value
                    copy_count = copy_count + 1; // Increment duplicate counter
                end
            end
        end
    end

    // Display results
    if (copy_count == 0) begin // No duplicates found
        $display("All values are unique!");
    end else begin // Duplicates found, display count
        $display("WARNING: %d COPY(s) found in RAM!", copy_count);
    end
    #1000;
    $stop;
end
endmodule
