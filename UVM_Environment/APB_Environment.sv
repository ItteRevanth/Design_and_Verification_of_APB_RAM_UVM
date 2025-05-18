// APB Environment: Top-level UVM environment that instantiates and connects the APB agent and scoreboard
class apb_environment extends uvm_env;
  
  // Register the environment class with the UVM factory for object creation
  `uvm_component_utils(apb_environment)
  
  // Sub-components of the environment
  apb_agent apb_agt;          // APB agent containing driver, sequencer, and monitor
  apb_scoreboard apb_sco;     // Scoreboard for checking correctness of transactions
  
  // Constructor
  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // Build phase: Instantiate sub-components of the environment
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Create the APB agent and scoreboard using the UVM factory
    apb_agt = apb_agent::type_id::create("apb_agt", this);
    apb_sco = apb_scoreboard::type_id::create("apb_sco", this);
    
    // NOTE: Could use configuration DB (e.g., env_cfg) here to enable/disable agents or configure environment
  endfunction
  
  // Connect phase: Connect analysis ports between components
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // Connect the monitor’s analysis port to the scoreboard's analysis export
    // This allows transactions monitored from the DUT to be forwarded to the scoreboard for checking
    apb_agt.apb_mon.mon_2_sco.connect(apb_sco.recv_mon);
  endfunction
  
endclass : apb_environment
