// APB Agent: Encapsulates driver, sequencer, and monitor into a reusable unit
class apb_agent extends uvm_agent;

  // Register the agent class with the UVM factory for object creation
  `uvm_component_utils(apb_agent)

  // Sub-components of the agent
  apb_driver apb_drv;       // Drives the interface signals
  apb_monitor apb_mon;      // Monitors and captures transactions from DUT
  apb_sequencer apb_seqr;   // Generates and sequences transactions

  // Constructor
  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase: Instantiate agent sub-components
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // NOTE: Could add conditional creation based on agent configuration
    // (e.g., using uvm_active_passive_enum for active/passive agent control)

    // Create driver, monitor, and sequencer instances using factory
    apb_drv  = apb_driver::type_id::create("apb_drv", this);
    apb_mon  = apb_monitor::type_id::create("apb_mon", this);
    apb_seqr = apb_sequencer::type_id::create("apb_seqr", this);
  endfunction

  // Connect phase: Hook up sequencer to driver
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect the sequencer's output port to the driver's input port
    apb_drv.seq_item_port.connect(apb_seqr.seq_item_export);
  endfunction

endclass : apb_agent
