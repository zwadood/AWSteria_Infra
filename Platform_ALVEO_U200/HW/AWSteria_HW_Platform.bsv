// Copyright (c) 2021 Bluespec, Inc.  All Rights Reserved.
// Author: Rishiyur S. Nikhil

package AWSteria_HW_Platform;

// ================================================================
// AWS F1-specific parameters

Bit #(64) ddr_A_base = 'h_400_0000_0000;
Bit #(64) ddr_A_lim  = 'h_500_0000_0000;

Bit #(64) ddr_B_base = 'h_500_0000_0000;
Bit #(64) ddr_B_lim  = 'h_600_0000_0000;

Bit #(64) ddr_C_base = 'h_600_0000_0000;
Bit #(64) ddr_C_lim  = 'h_700_0000_0000;

Bit #(64) ddr_D_base = 'h_700_0000_0000;
Bit #(64) ddr_D_lim  = 'h_800_0000_0000;

// ================================================================

endpackage
