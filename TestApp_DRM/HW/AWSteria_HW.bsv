// Copyright (c) 2021 Bluespec, Inc.  All Rights Reserved.
// Author: Rishiyur S. Nikhil

package AWSteria_HW;

// ================================================================
// This package contains a specific AWSteria_Infra app,
// i.e., an mkAWSteria_HW module with AWSteria_HW_IFC interface.

// This specific application contains
// - a 2xN AXI4 fabric, where N = 1,2,3,4 (64b addrs, 512b data):
// - a 1x2 AXI4-Lite switch
// - an AXI4-Lite-to-AXI4 adapter
// - a placeholder 'DRM' module which will eventually contain a
//     DRM-provider's IP.

// The topology is:
//
//   +==AWSteria_HW================================================+
//   |                                           +=AXI4-Fabric=+   |
// AXI4_S----------------------------------------+             +-AXI4_M
//   |                                           |     2xN     |   |
//   |                                       +-AXI4_S          +-AXI4_M
//   |                                       |   +=============+   |
//   |                        +=Adapter=+    |                     |
//   |                    +-AXI4L_S   AXI4_M-+                     |
//   |                    |   +=========+                          |
//   |     +=Switch=+     |                                        |
//   |     |      AXI4L_M-+                                        |
// AXI4L_S-+ 1x2    |                                              |
//   |     |      AXI4L_M-+                    to app              |
//   |     +========+     |                      ^                 |
//   |                    |   +====DRM======+    |                 |
//   |                    +-AXI4L_S       Clock--+                 |
//   |                        +=============+                      |
//   +=============================================================+

// ================================================================
// BSV library imports

import FIFOF       :: *;
import GetPut      :: *;
import Connectable :: *;
// import Clocks      :: *;

// ----------------
// BSV additional libs

import Cur_Cycle  :: *;
import Semi_FIFOF :: *;
import GetPut_Aux :: *;

// ================================================================
// Project imports

import AXI4_Types  :: *;
import AXI4_Fabric :: *;

import AXI4_Lite_Types  :: *;
import AXI4_Lite_Fabric :: *;

import AXI4L_S_to_AXI4_M_Adapter :: *;

import AWSteria_HW_IFC      :: *;
import AWSteria_HW_Platform :: *;

// ================================================================

export mkAWSteria_HW;
export AXI4_16_64_512_0_S_IFC;
export AXI4L_32_32_0_S_IFC;
export AXI4_16_64_512_0_M_IFC;

// ****************************************************************
// Module: synthesized instance of AXI4L_S to AXI4_M adapter

(* synthesize *)
module mkAXI4L_S_to_AXI4_M_Adapter_synth (AXI4L_S_to_AXI4_M_Adapter_IFC #(// AXI4L_S
									  32,    // wd_addr
									  32,    // wd_data
									  0,     // wd_user
									  // AXI4L_M
									  16,    // wd_id
									  64,    // wd_addr
									  512,   // wd_data
									  0));   // wd_user
   let ifc <- mkAXI4L_S_to_AXI4_M_Adapter;
   return ifc;
endmodule

// ****************************************************************
// Module: synthesized instance of AXI4 fabric connecting the host
// AXI4 and (via adapter) AXI4-Lite to the AXI4 DDRs

// ----------------
// Address-Decode function to route requests to appropriate DDR

function Tuple2 #(Bool, Bit #(TLog #(N_DDRs)))  fn_addr_to_ddr_num (Bit #(64) addr);
   if ((ddr_A_base <= addr) && (addr < ddr_A_lim))
      return tuple2 (True, 0);

`ifdef INCLUDE_DDR_B
   else if ((ddr_B_base <= addr) && (addr < ddr_B_lim))
      return tuple2 (True, 1);
`endif

`ifdef INCLUDE_DDR_C
   else if ((ddr_C_base <= addr) && (addr < ddr_C_lim))
      return tuple2 (True, 2);
`endif

`ifdef INCLUDE_DDR_D
   else if ((ddr_D_base <= addr) && (addr < ddr_D_lim))
      return tuple2 (True, 3);
`endif

   else
      return tuple2 (False, 0);

endfunction

// ----------------
// The fabric

typedef AXI4_Fabric_IFC #(2,       // num M ports
			  N_DDRs,  // num S ports
			  16,      // wd_id
			  64,      // wd_addr
			  512,     // wd_data
			  0)
        AXI4_16_64_512_0_Fabric_2_N_IFC;

(* synthesize *)
module mkAXI4_16_64_512_0_Fabric_2_N (AXI4_16_64_512_0_Fabric_2_N_IFC);
   let fabric <- mkAXI4_Fabric (fn_addr_to_ddr_num);
   return fabric;
endmodule

// ****************************************************************
// Module: synthesized instance of AXI4-Lite 1x2 fabric connecting
// host AXI4 to DRM (targe 0) and AXI4-Lite adapter (target 1)

// ----------------
// Address-Decode function to route requests to appropriate target

Bit #(32) adapter_addr_min = 'h_0000_0000;    // 0
Bit #(32) adapter_addr_max = 'h_000F_FFFF;    // 1 MB

Bit #(32) drm_addr_min     = 'h_0010_0000;    // 1  MB
Bit #(32) drm_addr_max     = 'h_0010_3FFF;    // 16 KB


function Tuple2 #(Bool, Bit #(1))  fn_addr_to_AXI4L_target_num (Bit #(32) addr);
   if ((drm_addr_min <= addr) && (addr <= drm_addr_max))
      return tuple2 (True, 0);

   else if ((adapter_addr_min <= addr) && (addr <= adapter_addr_max))
      return tuple2 (True, 1);

   else
      return tuple2 (False, ?);
endfunction

// ----------------
// The fabric

typedef AXI4_Lite_Fabric_IFC #(1,     // num M ports
			       2,     // num S ports
			       32,    // wd_addr
			       32,    // wd_data
			       0)
        AXI4L_32_32_0_Fabric_1_2_IFC;

(* synthesize *)
module mkAXI4L_32_32_0_Fabric_1_2 (AXI4L_32_32_0_Fabric_1_2_IFC);
   let fabric <- mkAXI4_Lite_Fabric (fn_addr_to_AXI4L_target_num);
   return fabric;
endmodule

// ****************************************************************
// Module: Dummy DRM module

interface DRM_IFC;
   interface AXI4_Lite_Slave_IFC #(32, 32, 0) axi4L_S;
   method    Bool                             clock_enable;
   interface Clock                            clock_for_app;
endinterface

(* synthesize *)
module mkDRM (DRM_IFC);
   // Instantiate slave transactor
   AXI4_Lite_Slave_Xactor_IFC #(32, 32, 0) axi4L_S_xactor <- mkAXI4_Lite_Slave_Xactor;

   Reg #(Bit #(32)) rg_data   <- mkReg (0);

   // GatedClockIfc gated_clock <- mkGatedClockFromCC (False);

   // ================================================================
   // Write transactions

   rule rl_wr_xaction;
      let wra <- pop_o (axi4L_S_xactor.o_wr_addr);
      let wrd <- pop_o (axi4L_S_xactor.o_wr_data);

      $display ("DRM: WR xaction:\n  ", fshow (wra), "\n  ", fshow (wrd));

      AXI4_Lite_Resp resp = (  ((wra.awaddr & 'h3) == 0)
			     ? AXI4_LITE_OKAY
			     : AXI4_LITE_SLVERR);

      if (resp == AXI4_LITE_OKAY) begin
	 $display ("  rg_data old %0x", rg_data);
	 $display ("  rg_data new %0x", wrd.wdata);
	 rg_data <= wrd.wdata;

	 if ((rg_data[0] == 1'b0)  &&  (wrd.wdata[0] == 1'b1))
	    $display ("  Enabling clock");
	 if ((rg_data[0] == 1'b1)  &&  (wrd.wdata[0] == 1'b0))
	    $display ("  Disabling clock");

	 // gated_clock.setGateCond (wrd.wdata != 0);
      end

      let wrr = AXI4_Lite_Wr_Resp {bresp: resp,
				   buser: wra.awuser};

      axi4L_S_xactor.i_wr_resp.enq (wrr);
      $display ("  ", fshow (wrr));
   endrule

   // ================================================================
   // Read transactions

   rule rl_rd_xaction;
      let rda <- pop_o (axi4L_S_xactor.o_rd_addr);

      $display ("DRM: RD xaction:\n  ", fshow (rda));

      AXI4_Lite_Resp resp = (  ((rda.araddr & 'h3) != 0)
			     ? AXI4_LITE_SLVERR
			     : AXI4_LITE_OKAY);

      let rdd = AXI4_Lite_Rd_Data {rresp: resp,
				   rdata: (  (resp == AXI4_LITE_OKAY)
					   ? rg_data
					   : 32'h_89AB_CDEF),
				   ruser: rda.aruser};

      axi4L_S_xactor.i_rd_data.enq (rdd);
      $display ("  ", fshow (rdd));
   endrule

   // ================================================================
   // INTERFACE

   interface axi4L_S       = axi4L_S_xactor.axi_side;
   method    clock_enable  = (rg_data [0] == 1);
   interface clock_for_app = noClock;    // gated_clock.new_clk;
endmodule

// ****************************************************************
// Module: synthesized instance of AWSteria HW-side top-level (the DUT)

// For host_AXI4_S interface (wd_id, wd_addr, wd_data, wd_user)
typedef AXI4_Slave_IFC #(16, 64, 512, 0)  AXI4_16_64_512_0_S_IFC;

// For host_AXI4L_S interface (wd_addr, wd_data, wd_user)
typedef AXI4_Lite_Slave_IFC #(32, 32, 0)  AXI4L_32_32_0_S_IFC;

// For each DDR connection
typedef AXI4_Master_IFC #(16, 64, 512, 0)  AXI4_16_64_512_0_M_IFC;

(* synthesize *)
module mkAWSteria_HW #(Clock b_CLK, Reset b_RST_N)
   (AWSteria_HW_IFC #(AXI4_Slave_IFC #(16, 64, 512, 0),
		      AXI4_Lite_Slave_IFC #(32, 32, 0),
		      AXI4_Master_IFC #(16, 64, 512, 0)));

   // ----------------
   // DRM
   DRM_IFC drm <- mkDRM;
   // AXI4-Lite 1x2 switch
   AXI4L_32_32_0_Fabric_1_2_IFC axi4L_switch <- mkAXI4L_32_32_0_Fabric_1_2;

   // ----------------
   // AXI4-Lite to AXI4 adapter
   AXI4L_S_to_AXI4_M_Adapter_IFC #(32,    // wd_addr_AXI4L_S
				   32,    // wd_data_AXI4L_S
				   0,     // wd_user_AXI4L_S
				   16,      // wd_id_AXI4_M
				   64,    // wd_addr_AXI4_M
				   512,   // wd_data_AXI4_M
				   0)     // wd_user_AXI4_M)
       adapter_AXI4L_S_to_AXI4_M <- mkAXI4L_S_to_AXI4_M_Adapter_synth;

   // AXI4 Fabric
   AXI4_16_64_512_0_Fabric_2_N_IFC  fabric <- mkAXI4_16_64_512_0_Fabric_2_N;

   // Regs for control/status signals
   Reg #(Bool)      rg_env_ready <- mkReg (False);
   Reg #(Bit #(64)) rg_glcount   <- mkReg (0);
   Reg #(Bool)      rg_halted    <- mkReg (False);    // For simulation shutdown

   // ================================================================
   // BEHAVIOR

   // Connect AXI4-Lite switch to AXI4-Lite-to-AXI4-adapter and DRM
   mkConnection (axi4L_switch.v_to_slaves [0], drm.axi4L_S);
   mkConnection (axi4L_switch.v_to_slaves [1], adapter_AXI4L_S_to_AXI4_M.ifc_AXI4L_S);

   // Connect AXI4-Lite-to-AXI4-adapter to AXI4 fabric
   mkConnection (adapter_AXI4L_S_to_AXI4_M.ifc_AXI4_M,
		 fabric.v_from_masters [1]);

   // Tie off DDR B if not included
`ifndef INCLUDE_DDR_B
   AXI4_Slave_IFC #(16,64,512,0) dummy_ddr_S = dummy_AXI4_Slave_ifc;

   mkConnection (fabric.v_to_slaves [1], dummy_ddr_S);
`endif

   // ================================================================
   // INTERFACE

   AXI4_16_64_512_0_M_IFC dummy_ddr_master = dummy_AXI4_Master_ifc;

   // Facing Host
   interface AXI4_Slave_IFC      host_AXI4_S  = fabric.v_from_masters [0];
   interface AXI4_Lite_Slave_IFC host_AXI4L_S = axi4L_switch.v_from_masters [0];

   // Facing DDR
   interface AXI4_Master_IFC ddr_A_M = fabric.v_to_slaves [0];

`ifdef INCLUDE_DDR_B
   interface AXI4_Master_IFC ddr_B_M = fabric.v_to_slaves [1];
`endif

`ifdef INCLUDE_DDR_C
   interface AXI4_Master_IFC ddr_C_M = dummy_ddr_master;
`endif

`ifdef INCLUDE_DDR_D
   interface AXI4_Master_IFC ddr_D_M = dummy_ddr_master;
`endif

   // ================
   // Status signals

   // The AWSteria environment asserts this to inform the DUT that it is ready
   method Action m_env_ready (Bool env_ready);
      rg_env_ready <= env_ready;
   endmethod

   // The DUT asserts this to inform the AWSteria environment that it has "halted"
   method Bool m_halted = rg_halted;

   // ================
   // Real-time counter (in AWS and VCU118: 4ns period, irrespective of DUT clock)

   method Action m_glcount (Bit #(64) glcount);
      rg_glcount <= glcount;
   endmethod
endmodule

// ================================================================

endpackage