// APB Driver Class - Responsible for driving APB transactions onto the virtual interface
class apb_driver extends uvm_driver#(apb_transaction); // Specify the transaction type for the driver
  `uvm_component_utils(apb_driver)  // Register the component with the UVM factory for automation

  // Constructor
  function new(string name="", uvm_component parent=null);
    super.new(name, parent);       // Call base class constructor
  endfunction

  // Virtual Interface to connect with DUT signals
  virtual ram_if vif;

  // Handle for the current transaction
  apb_transaction apb_tr;

  // Optional analysis port to send transactions to scoreboard or other components
  // uvm_analysis_port #(apb_transaction) drv_2_sco;

  // Build phase: get configuration objects and initialize variables
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Get virtual interface handle from config DB
    if (!uvm_config_db#(virtual ram_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO VIF", {"virtual interface must be set for ", get_full_name(), ".vif"});

    // Create transaction using factory
    apb_tr = apb_transaction::type_id::create("apb_tr");
  endfunction

  // Run phase: continuously wait for and execute incoming transactions
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(apb_tr);  // Get the next transaction from the sequencer

      phase.raise_objection(this);          // Raise objection to keep simulation running during this task
      drive_apb_bus();                      // Call task to drive signals onto APB bus
      phase.drop_objection(this);           // Drop objection once task is done

      seq_item_port.item_done();            // Inform sequencer that item has been processed

      // Display the transaction data
      `uvm_info(get_full_name(),
                $psprintf("The data sent by the driver is : \n %s", apb_tr.sprint()),
                UVM_LOW)
    end
  endtask

  // Task to drive the APB bus based on the transaction operation
  virtual task drive_apb_bus();
    if (apb_tr.oper == 0) begin // ----------- Write Operation -----------
      @(posedge vif.pclk);
      vif.psel    <= 1'b1;
      vif.penable <= 1'b0;
      vif.pwrite  <= 1'b1;
      vif.paddr   <= apb_tr.paddr;
      vif.pwdata  <= apb_tr.pwdata;
      @(posedge vif.pclk);
      vif.penable <= 1'b1;
      repeat(2) @(posedge vif.pclk); // Simulate wait state
      vif.psel    <= 1'b0;
      vif.penable <= 1'b0;
      vif.pwrite  <= 1'b0;

    end else if (apb_tr.oper == 1) begin // ----------- Read Operation -----------
      @(posedge vif.pclk);
      vif.psel    <= 1'b1;
      vif.penable <= 1'b0;
      vif.pwrite  <= 1'b0;
      vif.paddr   <= apb_tr.paddr;
      vif.pwdata  <= apb_tr.pwdata;  // Typically not required for read, but assigned here
      @(posedge vif.pclk);
      vif.penable <= 1'b1;
      repeat(2) @(posedge vif.pclk);
      vif.psel    <= 1'b0;
      vif.penable <= 1'b0;
      vif.pwrite  <= 1'b0;

    end else if (apb_tr.oper == 2) begin // ----------- Random Operation -----------
      @(posedge vif.pclk);
      vif.psel    <= 1'b1;
      vif.penable <= 1'b0;
      vif.pwrite  <= apb_tr.pwrite;
      vif.paddr   <= apb_tr.paddr;
      vif.pwdata  <= apb_tr.pwdata;
      @(posedge vif.pclk);
      vif.penable <= 1'b1;
      repeat(2) @(posedge vif.pclk);
      vif.psel    <= 1'b0;
      vif.penable <= 1'b0;
      vif.pwrite  <= 1'b0;

    end else if (apb_tr.oper == 3) begin // ----------- SLV_ERR Operation -----------
      // Purposely generate an out-of-range address to trigger slave error
      @(posedge vif.pclk);
      vif.psel    <= 1'b1;
      vif.penable <= 1'b0;
      vif.pwrite  <= apb_tr.pwrite;
      vif.paddr   <= $urandom_range(32,100); // Invalid address to simulate error
      vif.pwdata  <= apb_tr.pwdata;
      @(posedge vif.pclk);
      vif.penable <= 1'b1;
      repeat(2) @(posedge vif.pclk);
      vif.psel    <= 1'b0;
      vif.penable <= 1'b0;
      vif.pwrite  <= 1'b0;
    end
  endtask : drive_apb_bus

endclass : apb_driver
