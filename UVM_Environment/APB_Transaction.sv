// Define a transaction class for the APB interface
class apb_transaction extends uvm_sequence_item;

  // Define the type of operation as an enumerated type
  typedef enum {write = 0, read = 1, random = 2, error = 3} oper_type;
  randc oper_type oper;           // Random-cyclic generation of operation type (non-repeating until all used)

  // ---------------- Control Information ----------------
  rand bit psel;                  // APB select signal
  rand bit pwrite;                // Write enable signal
  rand bit penable;               // Enable signal for APB

  // ---------------- Data Information ----------------
  rand bit [31:0] paddr;          // Address bus (randomizable)
  rand bit [31:0] pwdata;         // Write data (randomizable)

  // ---------------- Analysis (Output) Information ----------------
  bit [31:0] prdata;              // Read data (driven by DUT, not randomized)
  bit pslverr;                    // Error signal from DUT
  bit pready;                     // Ready signal from DUT

  // ---------------- UVM Macros for Automation ----------------
  `uvm_object_utils_begin(apb_transaction)   // Register the class with factory and provide field automation
    `uvm_field_int(psel,    UVM_ALL_ON)      // Enable automation for psel
    `uvm_field_int(pwrite,  UVM_ALL_ON)      // Enable automation for pwrite
    `uvm_field_int(penable, UVM_ALL_ON)      // Enable automation for penable
    `uvm_field_int(paddr,   UVM_ALL_ON)      // Enable automation for paddr
    `uvm_field_int(pwdata,  UVM_ALL_ON)      // Enable automation for pwdata
    `uvm_field_int(prdata,  UVM_ALL_ON)      // Enable automation for prdata
    `uvm_field_int(pslverr, UVM_ALL_ON)      // Enable automation for pslverr
    `uvm_field_int(pready,  UVM_ALL_ON)      // Enable automation for pready
  `uvm_object_utils_end                  // End of field automation macro

  // Constructor: allows naming the transaction object
  function new(string name = "");
    super.new(name);                     // Call the base class constructor
  endfunction

  // ---------------- Constraints ----------------
  constraint wdata_c {
    this.pwdata > 1;                     // Constraint: write data must be greater than 1
    this.pwdata < 10;                    // Constraint: write data must be less than 10
  };

  constraint paddr_c {
    this.paddr > 1;                      // Constraint: address must be greater than 1
    this.paddr < 5;                      // Constraint: address must be less than 5
  };

endclass : apb_transaction             // End of the transaction class
