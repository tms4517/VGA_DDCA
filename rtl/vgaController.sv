`default_nettype none

module vgaController
  #(parameter int HBP     = 48  // Horizontal back porch.
  , parameter int HACTIVE = 640 // Active pixels per line.
  , parameter int HFP     = 16  // Horizontal front porch.
  , parameter int HSYN    = 96  // Horizontal sync pulse.

  , parameter int VBP     = 32  // Vertical back porch.
  , parameter int VACTIVE = 480 // Number of active lines.
  , parameter int VFP     = 11  // Vertical front porch.
  , parameter int VSYN    = 2   // Vertical sync pulse.
  )
  ( input  var logic i_clk
  , input  var logic i_arst

  , output var logic o_hSync
  , output var logic o_vSync
  , output var logic o_sync_b
  , output var logic o_blank_b

  , output var logic [9:0] o_hCnt
  , output var logic [9:0] o_vCnt
  );

  // Total number of horizontal pixels.
  localparam int HMAX = HBP+HACTIVE+HFP+HSYN;

  // Total number of vertical pixels.
  localparam int VMAX = VBP+VACTIVE+VFP+VSYN;

  // {{{ Counters for horizontal and vertical positions.

  logic [9:0] hCnt_d, hCnt_q;
  logic [9:0] vCnt_d, vCnt_q;

  // Horizontal counter.
  always_ff @(posedge i_clk, posedge i_arst)
    if (i_arst)
      hCnt_q <= '0;
    else
      hCnt_q <= hCnt_d;

  always_comb
    hCnt_d = (hCnt_q == 10'(HMAX)) ? '0 : hCnt_q + 1'b1;

  always_comb
    o_hCnt = hCnt_q;

  // Vertical counter.
  always_ff @(posedge i_clk, posedge i_arst)
    if (i_arst)
      vCnt_q <= '0;
    else
      vCnt_q <= vCnt_d;

  always_comb
    if (vCnt_q == 10'(VMAX))
      vCnt_d = '0;
    else if (hCnt_q == 10'(HMAX))
      vCnt_d = vCnt_q + 1'b1;
    else
      vCnt_d = vCnt_q;

  always_comb
    o_vCnt = vCnt_q;

  // }}} Counters for horizontal and vertical positions.

  // {{{ Drive sync signals.

  always_comb
    o_hSync = !((hCnt_q >= 10'(HACTIVE+HFP)) && (hCnt_q < 10'(HACTIVE+HFP+HSYN)));

  always_comb
    o_vSync = !((vCnt_q >= 10'(VACTIVE+VFP)) && (vCnt_q < 10'(VACTIVE+VFP+VSYN)));

  always_comb
    o_sync_b = 1'b0;

  // {{{ Drive sync signals.

  // Force outputs to black when not writing pixels.
  always_comb
    o_blank_b = (hCnt_q < 10'(HACTIVE)) && (vCnt_q < 10'(VACTIVE));

endmodule

`resetall
