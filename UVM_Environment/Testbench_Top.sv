`include "uvm_macros.svh"
import uvm_pkg::*;

// Top-level testbench module for the APB RAM design
module tb_top;

  // Instantiate the virtual interface for RAM signals
  ram_if vif();

  // Instantiate the Device Under Test (DUT) - APB RAM module
  // Connect the DUT ports to the signals of the virtual interface
  apb_ram dut(
    .presetn(vif.presetn),
    .pclk(vif.pclk),
    .psel(vif.psel),
    .pwrite(vif.pwrite),
    .penable(vif.penable),
    .paddr(vif.paddr),
    .pwdata(vif.pwdata),
    .prdata(vif.prdata),
    .pslverr(vif.pslverr),
    .pready(vif.pready)
  );
  
  // Initialize the clock signal to zero at start
  initial begin
    vif.pclk <= 1'b0;
  end
  
  // Generate clock: toggle every 10ns => 50 MHz clock period
  always #10ns vif.pclk <= ~vif.pclk;
  
  // Initial block to configure UVM and start the test
  initial begin
    // Set the virtual interface in the UVM config DB for all components under apb_agent
    uvm_config_db#(virtual ram_if)::set(null, "uvm_test_top.apb_env.apb_agt.*", "vif", vif);
    
    // Run the UVM test named "apb_test"
    run_test("apb_test");
  end
  
  // Initial block to dump waveform for debugging
  initial begin
    $dumpfile("apb_test.vcd");  // Specify VCD file name
    $dumpvars(0, tb_top);       // Dump all signals in tb_top hierarchy
  end
  
endmodule
