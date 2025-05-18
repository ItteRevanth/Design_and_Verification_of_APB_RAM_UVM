// APB Monitor - Observes the APB bus activity and reports transactions to the scoreboard
class apb_monitor extends uvm_monitor;
  
  // Register the monitor class with the factory
  `uvm_component_utils(apb_monitor)

  // Virtual interface to connect to DUT's APB signals
  virtual ram_if vif;

  // Handle to store the captured transaction
  apb_transaction apb_tr;

  // Analysis port to broadcast transactions to the scoreboard or subscribers
  uvm_analysis_port #(apb_transaction) mon_2_sco;

  // Constructor
  function new(string name="", uvm_component parent=null);
    super.new(name, parent); // Call base class constructor
  endfunction

  // Build phase: fetch the virtual interface and create the analysis port and transaction object
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create analysis port used to send data to scoreboard
    mon_2_sco = new("mon_2_sco", this);

    // Get the virtual interface from the config database
    if (!uvm_config_db#(virtual ram_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_full_name(), "VIF not available!") // Fatal error if VIF is not found

    // Create a transaction object using the factory
    apb_tr = apb_transaction::type_id::create("apb_tr");
  endfunction

  // Run phase: sample the bus and capture transactions
  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.pclk);  // Wait for a rising edge of the clock

      // Detect start of APB transfer: psel = 1 and penable = 0
      if (vif.psel && !vif.penable) begin
        @(posedge vif.pclk); // Wait for setup to access phase

        // ----------- Write Transaction -----------
        if (vif.psel && vif.pwrite && vif.penable) begin
          @(posedge vif.pclk); // Wait for stable data

          // Capture write transaction details
          apb_tr.pwdata   <= vif.pwdata;
          apb_tr.paddr    <= vif.paddr;
          apb_tr.pwrite   <= vif.pwrite;
          apb_tr.pslverr  <= vif.pslverr;
          @(posedge vif.pclk); // Allow data to stabilize

        end
        // ----------- Read Transaction -----------
        else if (vif.psel && !vif.pwrite && vif.penable) begin
          @(posedge vif.pclk); // Wait for read data to appear

          // Capture read transaction details
          apb_tr.prdata   <= vif.prdata;
          apb_tr.paddr    <= vif.paddr;
          apb_tr.pwrite   <= vif.pwrite;
          apb_tr.pslverr  <= vif.pslverr;
          @(posedge vif.pclk); // Allow time for response capture
        end

        // Print the captured transaction
        `uvm_info(get_full_name(),
                  $psprintf("The data received by the monitor is : \n %s", apb_tr.sprint()),
                  UVM_LOW)

        // Send the captured transaction to the analysis port
        mon_2_sco.write(apb_tr);
      end
    end
  endtask

endclass : apb_monitor
