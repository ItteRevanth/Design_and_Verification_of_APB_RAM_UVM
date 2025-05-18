// Define a sequence class for generating APB transactions
class apb_sequence extends uvm_sequence#(apb_transaction);
  
  // Register the sequence with the UVM factory
  `uvm_object_utils(apb_sequence)
  
  // Optional macro to declare the sequencer handle if needed
  // `uvm_declare_p_sequencer(seqr) 
  // Useful if you want to access sequencer's config_db or other handles

  // Handle for the APB transaction
  apb_transaction apb_tr;
  
  // Constructor: calls base class constructor with optional name
  function new(string name="apb_sequence");
    super.new(name);
  endfunction
  
  // Main body task where sequence execution happens
  virtual task body();
    
    // Create an instance of the transaction using factory
    apb_tr = apb_transaction::type_id::create("apb_tr");
    
    // Generate 20 random transactions
    repeat(20) begin
      start_item(apb_tr);                       // Request control of sequencer
      assert(apb_tr.randomize());              // Randomize the transaction (check for success)
      `uvm_info(
        get_full_name(),                       // Full hierarchical name of the sequence
        $psprintf("The data sent to the driver is : \n %s", apb_tr.sprint()), // Print transaction content
        UVM_LOW                                // Message verbosity level
      )
      finish_item(apb_tr);                     // Send the transaction to the driver
    end  

    // Notes:
    // Instead of start_item/finish_item, the following alternatives can be used:
    // - create, wait_for_grant, send_request, wait_for_item_done, get_response
    // - `uvm_do(req) macro for simplicity
    // - `uvm_create(req), assert(req.randomize()), `uvm_send(req)
    
  endtask
  
endclass : apb_sequence
