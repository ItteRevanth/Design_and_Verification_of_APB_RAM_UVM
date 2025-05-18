// Design of AMBA APB RAM
module apb_ram(
  input pclk, presetn,              // APB clock and active-low reset
  input psel, penable, pwrite,      // APB control signals
  input [31:0] paddr, pwdata,       // APB address and write data
  output reg [31:0] prdata,         // APB read data
  output reg pready, pslverr        // APB ready and error signals
);
  
  // Declare a 32-word memory, each word is 32-bit wide
  reg [31:0] mem[32];
  
  // Define FSM states: idle, setup, access, transfer
  typedef enum{idle=0, setup=1, access=2, transfer=3} state_type;
  state_type state = idle, next_state = idle;
  
  // Main FSM process, triggered on the rising edge of the clock
  always@(posedge pclk) begin
    if(presetn == 0) begin
      // Synchronous reset: clear state and outputs
      state <= idle;
      prdata <= 32'h00000000;
      pready <= 1'b0;
      pslverr <= 1'b0;
      for(int i=0;i<32;i++)
        mem[i] <= 0;                // Clear all memory locations
    end
    else begin
      case(state)
        idle : begin
          // Wait for a valid transaction to start
          prdata <= 32'h00000000;
          pready <= 1'b0;
          pslverr <= 1'b0;
          if((psel==1'b0) && (penable==1'b0))
            state <= setup;        // Move to setup state when idle and bus is not selected
        end

        setup : begin
          // Setup state: check for valid address range
          if((psel==1'b1) && (penable==1'b0)) begin
            if(paddr < 32) begin
              state <= access;     // Proceed if address is within range
              pready <= 1'b1;
            end
            else begin
              state <= access;     // Invalid address, but still move to access
              pready <= 1'b0;
            end
          end
          else
            state <= setup;        // Stay in setup if conditions are not met
        end

        access : begin
          // Access state: perform read or write
          if(psel && pwrite && penable) begin
            // Write operation
            if(paddr < 32) begin
              mem[paddr] <= pwdata;  // Write data to memory
              state <= transfer;
              pslverr <= 1'b0;
            end
            else begin
              // Invalid address on write
              state <= transfer;
              pready <= 1'b1;
              pslverr <= 1'b1;
            end
          end
          else if(psel && !pwrite && penable) begin
            // Read operation
            if(paddr < 32) begin
              prdata <= mem[paddr];  // Read data from memory
              state <= transfer;
              pslverr <= 1'b0;
            end
            else begin
              // Invalid address on read
              prdata <= 32'hxxxxxxxx;
              pready <= 1'b1;
              pslverr <= 1'b1;
              state <= transfer;
            end
          end
        end

        transfer : begin
          // Transfer state: finalize transaction
          state <= setup;          // Go back to setup for next transaction
          pready <= 1'b0;
          pslverr <= 1'b0;
        end

        default : state <= idle;   // Default safety fallback
      endcase
    end
  end
  
endmodule
