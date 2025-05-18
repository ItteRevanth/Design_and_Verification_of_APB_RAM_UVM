//Interface
interface ram_if();
  logic pclk, presetn;
  logic psel, pwrite, penable;
  logic [31:0] paddr, pwdata;
  logic [31:0] prdata;
  logic pslverr, pready;
endinterface
