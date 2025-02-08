#  LFSR-Based Pseudo-Random Number Generator (PRNG) with RAM Storage
Overview
This project implements a Linear Feedback Shift Register (LFSR) based pseudo-random number generator (PRNG) in Verilog. The generated random numbers are stored in RAM, exported to a text file (TXT), and analyzed for uniqueness.

#  Features
✅ LFSR-based PRNG: Generates (2^n)-1 unique random numbers before repeating.
✅ Clock-based reseeding: Ensures variation by seeding from a counter.
✅ RAM Storage: Stores generated numbers for analysis.
✅ Text File Export: Saves generated numbers for external use.
✅ Data Validation: Checks for duplicate numbers in RAM.

#  Project Structure
lfsr_trng.sv → LFSR-based random number generator.
clock_counter.sv → Clock-based counter for reseeding.
RAM.sv → Memory storage for random numbers.
tb_lfsr_trng.sv → Testbench for verification and logging.
#  How It Works
The LFSR module generates random numbers based on a feedback polynomial.
The clock counter provides an initial seed for LFSR after exhaustion of (2^n)-1 states.
Generated numbers are written to RAM and exported to a TXT file.
The testbench reads, displays, and validates data for uniqueness.
#  Usage
🔹 Run the simulation in Vivado/ModelSim/QuestaSim.
🔹 Check random_data.txt for generated numbers.
🔹 Analyze data distribution in Excel/Python.
