// APB Sequencer - Coordinates between the sequence and the driver by sending sequence items
class apb_sequencer extends uvm_sequencer#(apb_transaction);
  
  // Register this sequencer class with the UVM factory for automation and configuration
  `uvm_component_utils(apb_sequencer)
  
  // Constructor - calls the base class constructor
  function new(string name = "", uvm_component parent = null);
    super.new(name, parent); // Initialize using the base class constructor
  endfunction

endclass : apb_sequencer
