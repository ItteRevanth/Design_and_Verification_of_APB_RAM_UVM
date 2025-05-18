// APB Scoreboard: Compares DUT output against expected values
class apb_scoreboard extends uvm_scoreboard;

  // Register the scoreboard with the factory
  `uvm_component_utils(apb_scoreboard)

  // Analysis implementation to receive transactions from monitor
  uvm_analysis_imp #(apb_transaction, apb_scoreboard) recv_mon;

  // Handle for received transaction
  apb_transaction tr_recv;

  // Simple memory model to track expected write data
  reg [31:0] pwdata[32]; // Simulated internal memory for checking reads
  reg [31:0] prdata;     // Temporary variable to compare read data

  // Constructor
  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase: create analysis implementation and transaction object
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create the analysis implementation and register callback
    recv_mon = new("recv_mon", this);

    // Allocate transaction object via factory
    tr_recv = apb_transaction::type_id::create("tr_recv");
  endfunction

  // Called automatically by analysis port (monitor → scoreboard)
  virtual function void write(apb_transaction tr);
    // Store received transaction into internal handle
    tr_recv = tr;

    // ----------- Write Operation -----------
    if ((tr_recv.pwrite == 1'b1) && (tr_recv.pslverr == 1'b0)) begin
      pwdata[tr_recv.paddr] = tr_recv.pwdata; // Store expected data
      `uvm_info(get_full_name(),
                $psprintf("Data written at %0d as %0d", tr_recv.paddr, tr_recv.pwdata),
                UVM_LOW)
    end

    // ----------- Read Operation -----------
    else if ((tr_recv.pwrite == 1'b0) && (tr_recv.pslverr == 1'b0)) begin
      prdata = pwdata[tr_recv.paddr]; // Get expected data

      if (prdata == tr_recv.prdata)
        `uvm_info(get_full_name(), "Read data matched!", UVM_LOW)
      else
        `uvm_error(get_full_name(), "Read Failed!") // Mismatch detected
    end

    // ----------- Slave Error -----------
    else if (tr_recv.pslverr == 1'b1)
      `uvm_error(get_full_name(), "Slave error detected!") // Report protocol error
  endfunction

endclass : apb_scoreboard
