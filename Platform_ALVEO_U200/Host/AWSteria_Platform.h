#pragma once

// Copyright (c) 2020-2021 Bluespec, Inc.  All Rights Reserved
// Author: Rishiyur S. Nikhil

// ================================================================
// AWS F1-specific parameters

// ================================================================

#define DDR_A_BASE           0x4000000000llu
#define DDR_A_LIM            0x5000000000llu

#define DDR_B_BASE           0x5000000000llu
#define DDR_B_LIM            0x6000000000llu

#define DDR_C_BASE           0x6000000000llu
#define DDR_C_LIM            0x7000000000llu

#define DDR_D_BASE           0x7000000000llu
#define DDR_D_LIM            0x8000000000llu

// ----------------
// An addr beyond the last DDR
#define OUT_OF_BOUNDS_ADDR  DDR_D_LIM
