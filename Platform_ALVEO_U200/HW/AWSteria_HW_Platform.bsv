// Copyright (c) 2021 Bluespec, Inc.  All Rights Reserved.
// Author: Rishiyur S. Nikhil

package AWSteria_HW_Platform;

// ================================================================
// AWS F1-specific parameters

Bit #(64) ddr_A_base = 'h_40_0000_0000;
Bit #(64) ddr_A_lim  = 'h_44_0000_0000;

Bit #(64) ddr_B_base = 'h_50_0000_0000;
Bit #(64) ddr_B_lim  = 'h_54_0000_0000;

Bit #(64) ddr_C_base = 'h_60_0000_0000;
Bit #(64) ddr_C_lim  = 'h_64_0000_0000;

Bit #(64) ddr_D_base = 'h_70_0000_0000;
Bit #(64) ddr_D_lim  = 'h_74_0000_0000;

// ================================================================

endpackage
