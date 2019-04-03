// -------------------------------------------------------------
//
// Module: filter_tb
// Generated by MATLAB(R) 9.5 and Filter Design HDL Coder 3.1.4.
// Generated on: 2019-03-25 17:33:50
// -------------------------------------------------------------

// -------------------------------------------------------------
// HDL Code Generation Options:
//
// TargetDirectory: C:\Users\vladimir\Documents\GitHub\OFDM_Modem\filter
// TargetLanguage: Verilog
// TestBenchStimulus: impulse 
//
// Filter Settings:
//
// Discrete-Time FIR Filter (real)
// -------------------------------
// Filter Structure  : Direct-Form FIR
// Filter Length     : 20
// Stable            : Yes
// Linear Phase      : Yes (Type 2)
// Arithmetic        : fixed
// Numerator         : s16,16 -> [-5.000000e-01 5.000000e-01)
// Input             : s16,15 -> [-1 1)
// Filter Internals  : Full Precision
//   Output          : s33,31 -> [-2 2)  (auto determined)
//   Product         : s31,31 -> [-5.000000e-01 5.000000e-01)  (auto determined)
//   Accumulator     : s33,31 -> [-2 2)  (auto determined)
//   Round Mode      : No rounding
//   Overflow Mode   : No overflow
// -------------------------------------------------------------
`timescale 1 ns / 1 ns 

module filter_tb;

// Function definitions
   function signed [32:0] abs;
   input signed [32:0] arg;
   begin
     abs = arg > 0 ? arg : -arg;
   end
   endfunction // function abs

  task filter_in_data_log_task; 
    input         clk;
    input         reset;
    input         rdenb;
    inout  [5:0]  addr;
    output        done;
  begin

    // Counter to generate the address
    if (reset == 1) 
      addr = 0;
    else begin
      if (rdenb == 1) begin
        if (addr == 39)
          addr = addr; 
        else
          addr =  addr + 1; 
      end
    end

    // Done Signal generation.
    if (reset == 1)
      done = 0; 
    else if (addr == 39)
      done = 1; 
    else
      done = 0; 

  end
  endtask // filter_in_data_log_task

  task filter_out_task; 
    input         clk;
    input         reset;
    input         rdenb;
    inout  [5:0]  addr;
    output        done;
  begin

    // Counter to generate the address
    if (reset == 1) 
      addr = 0;
    else begin
      if (rdenb == 1) begin
        if (addr == 39)
          addr = addr; 
        else
          addr = #1  addr + 1; 
      end
    end

    // Done Signal generation.
    if (reset == 1)
      done = 0; 
    else if (addr == 39)
      done = 1; 
    else
      done = 0; 

  end
  endtask // filter_out_task

 // Constants
 parameter clk_high                         = 5;
 parameter clk_low                          = 5;
 parameter clk_period                       = 10;
 parameter clk_hold                         = 2;
// -------------------------------------------------------------
//
// Module: filter_tb_data
// Generated by MATLAB(R) 9.5 and Filter Design HDL Coder 3.1.4.
// Generated on: 2019-03-25 17:33:50
// -------------------------------------------------------------

 reg  signed [15:0] filter_in_data_log_force [0:39];
 reg  signed [32:0] filter_out_expected [0:39];


// **************************************
 initial //Input & Output data
 begin

 // Input data for filter_in_data_log
 filter_in_data_log_force[ 0] <= 16'h7fff;
 filter_in_data_log_force[ 1] <= 16'h0000;
 filter_in_data_log_force[ 2] <= 16'h0000;
 filter_in_data_log_force[ 3] <= 16'h0000;
 filter_in_data_log_force[ 4] <= 16'h0000;
 filter_in_data_log_force[ 5] <= 16'h0000;
 filter_in_data_log_force[ 6] <= 16'h0000;
 filter_in_data_log_force[ 7] <= 16'h0000;
 filter_in_data_log_force[ 8] <= 16'h0000;
 filter_in_data_log_force[ 9] <= 16'h0000;
 filter_in_data_log_force[10] <= 16'h0000;
 filter_in_data_log_force[11] <= 16'h0000;
 filter_in_data_log_force[12] <= 16'h0000;
 filter_in_data_log_force[13] <= 16'h0000;
 filter_in_data_log_force[14] <= 16'h0000;
 filter_in_data_log_force[15] <= 16'h0000;
 filter_in_data_log_force[16] <= 16'h0000;
 filter_in_data_log_force[17] <= 16'h0000;
 filter_in_data_log_force[18] <= 16'h0000;
 filter_in_data_log_force[19] <= 16'h0000;
 filter_in_data_log_force[20] <= 16'h0000;
 filter_in_data_log_force[21] <= 16'h0000;
 filter_in_data_log_force[22] <= 16'h0000;
 filter_in_data_log_force[23] <= 16'h0000;
 filter_in_data_log_force[24] <= 16'h0000;
 filter_in_data_log_force[25] <= 16'h0000;
 filter_in_data_log_force[26] <= 16'h0000;
 filter_in_data_log_force[27] <= 16'h0000;
 filter_in_data_log_force[28] <= 16'h0000;
 filter_in_data_log_force[29] <= 16'h0000;
 filter_in_data_log_force[30] <= 16'h0000;
 filter_in_data_log_force[31] <= 16'h0000;
 filter_in_data_log_force[32] <= 16'h0000;
 filter_in_data_log_force[33] <= 16'h0000;
 filter_in_data_log_force[34] <= 16'h0000;
 filter_in_data_log_force[35] <= 16'h0000;
 filter_in_data_log_force[36] <= 16'h0000;
 filter_in_data_log_force[37] <= 16'h0000;
 filter_in_data_log_force[38] <= 16'h0000;
 filter_in_data_log_force[39] <= 16'h0000;

 // Output data for filter_out
 filter_out_expected[ 0] <= 33'h00033ff98;
 filter_out_expected[ 1] <= 33'h000a07ebf;
 filter_out_expected[ 2] <= 33'h000917edd;
 filter_out_expected[ 3] <= 33'h1febb8289;
 filter_out_expected[ 4] <= 33'h1faf60a14;
 filter_out_expected[ 5] <= 33'h1f8358f95;
 filter_out_expected[ 6] <= 33'h1fbb60894;
 filter_out_expected[ 7] <= 33'h008606f3f;
 filter_out_expected[ 8] <= 33'h01a3acb8a;
 filter_out_expected[ 9] <= 33'h02768312f;
 filter_out_expected[10] <= 33'h02768312f;
 filter_out_expected[11] <= 33'h01a3acb8a;
 filter_out_expected[12] <= 33'h008606f3f;
 filter_out_expected[13] <= 33'h1fbb60894;
 filter_out_expected[14] <= 33'h1f8358f95;
 filter_out_expected[15] <= 33'h1faf60a14;
 filter_out_expected[16] <= 33'h1febb8289;
 filter_out_expected[17] <= 33'h000917edd;
 filter_out_expected[18] <= 33'h000a07ebf;
 filter_out_expected[19] <= 33'h00033ff98;
 filter_out_expected[20] <= 33'h000000000;
 filter_out_expected[21] <= 33'h000000000;
 filter_out_expected[22] <= 33'h000000000;
 filter_out_expected[23] <= 33'h000000000;
 filter_out_expected[24] <= 33'h000000000;
 filter_out_expected[25] <= 33'h000000000;
 filter_out_expected[26] <= 33'h000000000;
 filter_out_expected[27] <= 33'h000000000;
 filter_out_expected[28] <= 33'h000000000;
 filter_out_expected[29] <= 33'h000000000;
 filter_out_expected[30] <= 33'h000000000;
 filter_out_expected[31] <= 33'h000000000;
 filter_out_expected[32] <= 33'h000000000;
 filter_out_expected[33] <= 33'h000000000;
 filter_out_expected[34] <= 33'h000000000;
 filter_out_expected[35] <= 33'h000000000;
 filter_out_expected[36] <= 33'h000000000;
 filter_out_expected[37] <= 33'h000000000;
 filter_out_expected[38] <= 33'h000000000;
 filter_out_expected[39] <= 33'h000000000;

 end // Input & Output data
//************************************


  parameter MAX_ERROR_COUNT = 40; //uint32


 // Signals
  reg  clk; // boolean
  reg  clk_enable; // boolean
  reg  reset; // boolean
  reg  signed [15:0] filter_in; // sfix16_En15
  wire signed [32:0] filter_out; // sfix33_En31

  reg  tb_enb; // boolean
  wire srcDone; // boolean
  wire snkDone; // boolean
  wire testFailure; // boolean
  reg  tbenb_dly; // boolean
  reg  [4:0] counter; // ufix5
  wire phase_1; // boolean
  wire rdEnb_phase_1; // boolean
  wire filter_in_data_log_rdenb; // boolean
  reg  [5:0] filter_in_data_log_addr; // ufix6
  reg  filter_in_data_log_done; // boolean
  reg  signed [15:0] holdData_filter_in; // sfix16_En15
  reg  filter_out_testFailure; // boolean
  integer filter_out_errCnt; // uint32
  wire delayLine_out; // boolean
  wire expected_ce_out; // boolean
  reg  int_delay_pipe [0:39] ; // boolean
  wire filter_out_rdenb; // boolean
  reg  [5:0] filter_out_addr; // ufix6
  reg  filter_out_done; // boolean
  wire signed [32:0] filter_out_ref; // sfix33_En31
  wire signed [32:0] filter_out_dataTable; // sfix33_En31
  wire signed [32:0] filter_out_refTmp; // sfix33_En31
  reg  signed [32:0] regout; // sfix33_En31
  reg  check1_Done; // boolean

 // Module Instances
  filter u_filter
    (
    .clk(clk),
    .clk_enable(clk_enable),
    .reset(reset),
    .filter_in(filter_in),
    .filter_out(filter_out)
    );


 // Block Statements
  // -------------------------------------------------------------
  // Driving the test bench enable
  // -------------------------------------------------------------

  always @(reset, snkDone)
  begin
    if (reset == 1'b1)
      tb_enb <= 1'b0;
    else if (snkDone == 1'b0 )
      tb_enb <= 1'b1;
    else begin
    # (clk_period * 2);
      tb_enb <= 1'b0;
    end
  end

  always @(posedge clk or posedge reset) // completed_msg
  begin
    if (reset) begin 
       // Nothing to reset.
    end 
    else begin 
      if (snkDone == 1) begin
        if (testFailure == 0)
              $display("**************TEST COMPLETED (PASSED)**************");
        else
              $display("**************TEST COMPLETED (FAILED)**************");
      end
    end
  end // completed_msg;

  // -------------------------------------------------------------
  // System Clock (fast clock) and reset
  // -------------------------------------------------------------

  always  // clock generation
  begin // clk_gen
    clk <= 1'b1;
    # clk_high;
    clk <= 1'b0;
    # clk_low;
    if (snkDone == 1) begin
      clk <= 1'b1;
      # clk_high;
      clk <= 1'b0;
      # clk_low;
      $stop;
    end
  end  // clk_gen

  initial  // reset block
  begin // reset_gen
    reset <= 1'b1;
    # (clk_period * 2);
    @ (posedge clk);
    # (clk_hold);
    reset <= 1'b0;
  end  // reset_gen

  // -------------------------------------------------------------
  // Testbench clock enable
  // -------------------------------------------------------------

  always @ (posedge clk or posedge reset)
    begin: tb_enb_delay
      if (reset == 1'b1) begin
        tbenb_dly <= 1'b0;
      end
      else begin
        if (tb_enb == 1'b1) begin
          tbenb_dly <= tb_enb;
        end
      end
    end // tb_enb_delay

  // -------------------------------------------------------------
  // Slow Clock (clkenb)
  // -------------------------------------------------------------

  always @ (posedge clk or posedge reset)
    begin: slow_clock_enable
      if (reset == 1'b1) begin
        counter <= 5'b00001;
      end
      else begin
        if (tbenb_dly == 1'b1) begin
          if (counter >= 5'b10011) begin
            counter <= 5'b00000;
          end
          else begin
            counter <= counter + 5'b00001;
          end
        end
      end
    end // slow_clock_enable

  assign  phase_1 = (counter == 5'b00001 && tbenb_dly == 1'b1) ? 1'b1 : 1'b0;

      assign rdEnb_phase_1 = phase_1;

  // -------------------------------------------------------------
  // Read the data and transmit it to the DUT
  // -------------------------------------------------------------

  always @(posedge clk or posedge reset)
  begin
    filter_in_data_log_task(clk,reset,
                            filter_in_data_log_rdenb,filter_in_data_log_addr,
                            filter_in_data_log_done);
  end

  assign filter_in_data_log_rdenb = rdEnb_phase_1;

  always @ (posedge clk or posedge reset)
  begin // stimuli_filter_in_data_log_filter_in_reg
    if (reset) begin 
      holdData_filter_in <=  16'bx;
    end
    else begin
      holdData_filter_in <= filter_in_data_log_force[filter_in_data_log_addr];
    end
  end

  always @ (filter_in_data_log_rdenb, filter_in_data_log_addr)
  begin // stimuli_filter_in_data_log_filter_in
    if (filter_in_data_log_rdenb == 1) begin
      filter_in <= # clk_hold filter_in_data_log_force[filter_in_data_log_addr];
    end
    else begin 
      filter_in <= # clk_hold holdData_filter_in;
    end
  end // stimuli_filter_in_data_log_filter_in

  // -------------------------------------------------------------
  // Create done signal for Input data
  // -------------------------------------------------------------

  assign srcDone = filter_in_data_log_done;


  always @( posedge clk or posedge reset)
    begin: ceout_delayLine
      if (reset == 1'b1) begin
        int_delay_pipe[0] <= 1'b0;
        int_delay_pipe[1] <= 1'b0;
        int_delay_pipe[2] <= 1'b0;
        int_delay_pipe[3] <= 1'b0;
        int_delay_pipe[4] <= 1'b0;
        int_delay_pipe[5] <= 1'b0;
        int_delay_pipe[6] <= 1'b0;
        int_delay_pipe[7] <= 1'b0;
        int_delay_pipe[8] <= 1'b0;
        int_delay_pipe[9] <= 1'b0;
        int_delay_pipe[10] <= 1'b0;
        int_delay_pipe[11] <= 1'b0;
        int_delay_pipe[12] <= 1'b0;
        int_delay_pipe[13] <= 1'b0;
        int_delay_pipe[14] <= 1'b0;
        int_delay_pipe[15] <= 1'b0;
        int_delay_pipe[16] <= 1'b0;
        int_delay_pipe[17] <= 1'b0;
        int_delay_pipe[18] <= 1'b0;
        int_delay_pipe[19] <= 1'b0;
        int_delay_pipe[20] <= 1'b0;
        int_delay_pipe[21] <= 1'b0;
        int_delay_pipe[22] <= 1'b0;
        int_delay_pipe[23] <= 1'b0;
        int_delay_pipe[24] <= 1'b0;
        int_delay_pipe[25] <= 1'b0;
        int_delay_pipe[26] <= 1'b0;
        int_delay_pipe[27] <= 1'b0;
        int_delay_pipe[28] <= 1'b0;
        int_delay_pipe[29] <= 1'b0;
        int_delay_pipe[30] <= 1'b0;
        int_delay_pipe[31] <= 1'b0;
        int_delay_pipe[32] <= 1'b0;
        int_delay_pipe[33] <= 1'b0;
        int_delay_pipe[34] <= 1'b0;
        int_delay_pipe[35] <= 1'b0;
        int_delay_pipe[36] <= 1'b0;
        int_delay_pipe[37] <= 1'b0;
        int_delay_pipe[38] <= 1'b0;
        int_delay_pipe[39] <= 1'b0;
      end
      else begin
        if (clk_enable == 1'b1) begin
        int_delay_pipe[0] <= rdEnb_phase_1;
        int_delay_pipe[1] <= int_delay_pipe[0];
        int_delay_pipe[2] <= int_delay_pipe[1];
        int_delay_pipe[3] <= int_delay_pipe[2];
        int_delay_pipe[4] <= int_delay_pipe[3];
        int_delay_pipe[5] <= int_delay_pipe[4];
        int_delay_pipe[6] <= int_delay_pipe[5];
        int_delay_pipe[7] <= int_delay_pipe[6];
        int_delay_pipe[8] <= int_delay_pipe[7];
        int_delay_pipe[9] <= int_delay_pipe[8];
        int_delay_pipe[10] <= int_delay_pipe[9];
        int_delay_pipe[11] <= int_delay_pipe[10];
        int_delay_pipe[12] <= int_delay_pipe[11];
        int_delay_pipe[13] <= int_delay_pipe[12];
        int_delay_pipe[14] <= int_delay_pipe[13];
        int_delay_pipe[15] <= int_delay_pipe[14];
        int_delay_pipe[16] <= int_delay_pipe[15];
        int_delay_pipe[17] <= int_delay_pipe[16];
        int_delay_pipe[18] <= int_delay_pipe[17];
        int_delay_pipe[19] <= int_delay_pipe[18];
        int_delay_pipe[20] <= int_delay_pipe[19];
        int_delay_pipe[21] <= int_delay_pipe[20];
        int_delay_pipe[22] <= int_delay_pipe[21];
        int_delay_pipe[23] <= int_delay_pipe[22];
        int_delay_pipe[24] <= int_delay_pipe[23];
        int_delay_pipe[25] <= int_delay_pipe[24];
        int_delay_pipe[26] <= int_delay_pipe[25];
        int_delay_pipe[27] <= int_delay_pipe[26];
        int_delay_pipe[28] <= int_delay_pipe[27];
        int_delay_pipe[29] <= int_delay_pipe[28];
        int_delay_pipe[30] <= int_delay_pipe[29];
        int_delay_pipe[31] <= int_delay_pipe[30];
        int_delay_pipe[32] <= int_delay_pipe[31];
        int_delay_pipe[33] <= int_delay_pipe[32];
        int_delay_pipe[34] <= int_delay_pipe[33];
        int_delay_pipe[35] <= int_delay_pipe[34];
        int_delay_pipe[36] <= int_delay_pipe[35];
        int_delay_pipe[37] <= int_delay_pipe[36];
        int_delay_pipe[38] <= int_delay_pipe[37];
        int_delay_pipe[39] <= int_delay_pipe[38];
        end
      end
    end // ceout_delayLine

  assign delayLine_out = int_delay_pipe[39];

  assign expected_ce_out =  delayLine_out & clk_enable;

  // -------------------------------------------------------------
  //  Checker: Checking the data received from the DUT.
  // -------------------------------------------------------------

  always @(posedge clk or posedge reset)
  begin
    filter_out_task(clk,reset,
                    filter_out_rdenb,filter_out_addr,
                    filter_out_done);
  end

  assign filter_out_rdenb = expected_ce_out;

  assign # clk_hold filter_out_dataTable = filter_out_expected[filter_out_addr];

// ---- Bypass Register ----
  always @ (posedge clk or posedge reset)
    begin: DataHoldRegister_temp_process2
      if (reset == 1'b1) begin
        regout <= 0;
      end
      else begin
        if (expected_ce_out == 1'b1) begin
          regout <= filter_out_dataTable;
        end
      end
    end // DataHoldRegister_temp_process2

  assign filter_out_refTmp = (expected_ce_out == 1'b1) ? filter_out_dataTable :
                       regout;


  assign filter_out_ref = filter_out_refTmp;



  always @ (posedge clk or posedge reset) // checker_filter_out
  begin
    if (reset == 1) begin
      filter_out_testFailure <= 0;
      filter_out_errCnt <= 0;
    end 
    else begin 
      if (filter_out_rdenb == 1 ) begin 
        if (filter_out !== filter_out_expected[filter_out_addr]) begin
           filter_out_errCnt <= filter_out_errCnt + 1;
           filter_out_testFailure <= 1;
               $display("ERROR in filter_out at time %t : Expected '%h' Actual '%h'", 
                    $time, filter_out_expected[filter_out_addr], filter_out);
           if (filter_out_errCnt >= MAX_ERROR_COUNT) 
             $display("Warning: Number of errors for filter_out have exceeded the maximum error limit");
        end

      end
    end
  end // checker_filter_out

  always @ (posedge clk or posedge reset) // checkDone_1
  begin
    if (reset == 1)
      check1_Done <= 0;
    else if ((check1_Done == 0) && (filter_out_done == 1) && (filter_out_rdenb == 1))
      check1_Done <= 1;
  end

  // -------------------------------------------------------------
  // Create done and test failure signal for output data
  // -------------------------------------------------------------

  assign snkDone = check1_Done;

  assign testFailure = filter_out_testFailure;

  // -------------------------------------------------------------
  // Global clock enable
  // -------------------------------------------------------------
  always @(snkDone, tbenb_dly)
  begin
    if (snkDone == 0)
      # clk_hold clk_enable <= tbenb_dly;
    else
      # clk_hold clk_enable <= 0;
  end

 // Assignment Statements



endmodule // filter_tb
