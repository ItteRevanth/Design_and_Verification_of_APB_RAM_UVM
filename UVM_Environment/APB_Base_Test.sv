// Base APB Test class: 
// This serves as a foundational test from which other specialized tests can be derived.
class apb_test extends uvm_test;

  // Register the test class with UVM factory for object creation
  `uvm_component_utils(apb_test)
  
  // Environment instance
  apb_environment apb_env;
  
  // Sequence instance to generate stimulus
  apb_sequence apb_seq;
  
  // Constructor
  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // Build phase: Create environment and sequence instances
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Instantiate the environment using the factory
    apb_env = apb_environment::type_id::create("apb_env", this);
    
    // Instantiate the APB sequence which will generate transactions
    apb_seq = apb_sequence::type_id::create("apb_seq");
    
    // NOTE: Configuration settings like agt_cfg, env_cfg, etc., 
    // can be set here via uvm_config_db::set() calls if needed
  endfunction
  
  // End of elaboration phase: Useful for printing or final setup checks
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    
    // Print the UVM component hierarchy topology for debugging
    uvm_top.print_topology();
  endfunction
  
  // Run phase: Starts the sequence on the environment’s sequencer
  virtual task run_phase(uvm_phase phase);
    // Raise objection to prevent test from ending prematurely
    phase.raise_objection(this);
    
    // Start the APB sequence on the APB sequencer inside the agent
    apb_seq.start(apb_env.apb_agt.apb_seqr);
    
    // Optional delay to allow sequence to run before dropping objection
    #5ns;
    
    // Drop objection signaling end of this test’s run phase
    phase.drop_objection(this);
  endtask
  
endclass : apb_test
