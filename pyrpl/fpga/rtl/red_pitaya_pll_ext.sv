/**
 * @brief Red Pitaya PLL module.
 *
 * @Author Matej Oblak, Iztok Jeras
 *
 * (c) Red Pitaya  http://www.redpitaya.com
 *
 * This part of code is written in Verilog hardware description language (HDL).
 * Please visit http://en.wikipedia.org/wiki/Verilog
 * for more details on the language used herein.
 */

module red_pitaya_pll_ext (
  // inputs
  input  logic clk       ,  // clock
  input  logic rstn      ,  // reset - active low
  // output clocks
  output logic clk_adc  // ADC clock
);

logic clk_fb;

MMCME2_ADV #(
   .BANDWIDTH            ("OPTIMIZED"),
   .COMPENSATION         ("ZHOLD"    ),
   .DIVCLK_DIVIDE        ( 1         ),
   .CLKFBOUT_MULT_F      ( 64        ),
   .CLKFBOUT_PHASE       ( 0.000     ),
   .CLKOUT0_DIVIDE_F     ( 32        ),
   .CLKOUT0_PHASE        ( 0.000     ),
   .CLKOUT0_DUTY_CYCLE   ( 0.5       ),
   .CLKIN1_PERIOD        ( 100.000   ),
   .REF_JITTER1          ( 0.010     )
) pll_ext (
   // Output clocks
   .CLKFBOUT     (clk_fb    ),
   .CLKOUT0      (clk_adc   ),
   .CLKIN1       (clk       ),
   .CLKIN2       (1'b0      ),
   // Tied to always select the primary input clock
   .CLKINSEL     (1'b1 ),
   // Ports for dynamic reconfiguration
   .DADDR        (7'h0 ),
   .DCLK         (1'b0 ),
   .DEN          (1'b0 ),
   .DI           (16'h0),
   .DO           (     ),
   .DRDY         (     ),
   .DWE          (1'b0 ),
   // Other control and status signals
   .LOCKED       (pll_locked),
   .PWRDWN       (1'b0      ),
   .RST          (!rstn     )
);

endmodule: red_pitaya_pll_ext
