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
  output logic clk_adc   ,  // ADC clock
  output logic clk_dac_1x,  // DAC clock
  output logic clk_dac_2x,  // DAC clock
  output logic clk_dac_2p,  // DAC clock
  output logic clk_ser   ,  // fast serial clock
  output logic clk_pwm   ,  // PWM clock
  // status outputs
  output logic pll_locked
);

logic clk_fb;
wire double_clk_out;
wire double_clk_in;
BUFG bufg_souble_clk    (.O (double_clk_out   ), .I (double_clk_in   ));


MMCME2_ADV #(
   .BANDWIDTH            ("OPTIMIZED"),
   .COMPENSATION         ("ZHOLD"    ),
   .DIVCLK_DIVIDE        ( 1         ),
   .CLKFBOUT_MULT_F      ( 60      ),
   .CLKOUT0_PHASE        ( 0.000     ),
   .CLKFBOUT_PHASE       ( 0.000     ),
   
   
   .CLKOUT0_DIVIDE_F       ( 30         ),
   .CLKOUT0_DUTY_CYCLE   ( 0.5       ),
   /*.CLKOUT1_DIVIDE       ( 6         ),
   .CLKOUT1_PHASE        ( 0.000     ),
   .CLKOUT1_DUTY_CYCLE   ( 0.5       ),
   .CLKOUT2_DIVIDE       ( 3         ),
   .CLKOUT2_PHASE        ( 0.000     ),
   .CLKOUT2_DUTY_CYCLE   ( 0.5       ),
   .CLKOUT3_DIVIDE       ( 3         ),
   .CLKOUT3_PHASE        (-45.000    ),
   .CLKOUT3_DUTY_CYCLE   ( 0.5       ),
   .CLKOUT4_DIVIDE       ( 3         ),  // 4->250MHz, 2->500MHz
   .CLKOUT4_PHASE        ( 0.000     ),
   .CLKOUT4_DUTY_CYCLE   ( 0.5       ),
   .CLKOUT5_DIVIDE       ( 3         ),
   .CLKOUT5_PHASE        ( 0.000     ),
   .CLKOUT5_DUTY_CYCLE   ( 0.5       ),*/
   .CLKIN1_PERIOD        ( 100.000     ),
   .REF_JITTER1          ( 0.010     )
) double (
   // Output clocks
   //.CLKFBOUT     (clk_fb    ),
   .CLKOUT0      (double_clk_in),
   /*.CLKOUT1      (clk_dac_1x),
   .CLKOUT2      (clk_dac_2x),
   .CLKOUT3      (clk_dac_2p),
   .CLKOUT4      (clk_ser   ),
   .CLKOUT5      (clk_pwm   ),*/
   // Input clock control
   //.CLKFBIN      (clk_fb    ),
   .CLKIN1       (clk),
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
   .PSCLK        (     ),
   .PSEN         (     ),
   .PSINCDEC     (     ),
   // Other control and status signals
   //.LOCKED       (pll_locked),
   .PWRDWN       (1'b0      ),
   .RST          (!rstn     )
);

MMCME2_ADV #(
   .BANDWIDTH            ("OPTIMIZED"),
   .COMPENSATION         ("ZHOLD"    ),
   .DIVCLK_DIVIDE        ( 1         ),
   .CLKFBOUT_MULT_F      ( 37.5      ),
   .CLKOUT0_PHASE        ( 0.000     ),
   .CLKFBOUT_PHASE       ( 0.000     ),
   
   
   .CLKOUT0_DIVIDE_F       ( 6         ),
   .CLKOUT0_DUTY_CYCLE   ( 0.5       ),
   .CLKOUT1_DIVIDE       ( 6         ),
   .CLKOUT1_PHASE        ( 0.000     ),
   .CLKOUT1_DUTY_CYCLE   ( 0.5       ),
   .CLKOUT2_DIVIDE       ( 3         ),
   .CLKOUT2_PHASE        ( 0.000     ),
   .CLKOUT2_DUTY_CYCLE   ( 0.5       ),
   .CLKOUT3_DIVIDE       ( 3         ),
   .CLKOUT3_PHASE        (-45.000    ),
   .CLKOUT3_DUTY_CYCLE   ( 0.5       ),
   .CLKOUT4_DIVIDE       ( 3         ),  // 4->250MHz, 2->500MHz
   .CLKOUT4_PHASE        ( 0.000     ),
   .CLKOUT4_DUTY_CYCLE   ( 0.5       ),
   .CLKOUT5_DIVIDE       ( 3         ),
   .CLKOUT5_PHASE        ( 0.000     ),
   .CLKOUT5_DUTY_CYCLE   ( 0.5       ),
   .CLKIN1_PERIOD        ( 50.000     ),
   .REF_JITTER1          ( 0.010     )
) mmcm (
   // Output clocks
   .CLKFBOUT     (clk_fb    ),
   .CLKOUT0      (clk_adc   ),
   .CLKOUT1      (clk_dac_1x),
   .CLKOUT2      (clk_dac_2x),
   .CLKOUT3      (clk_dac_2p),
   .CLKOUT4      (clk_ser   ),
   .CLKOUT5      (clk_pwm   ),
   // Input clock control
   .CLKFBIN      (clk_fb    ),
   .CLKIN1       (double_clk_out),
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
