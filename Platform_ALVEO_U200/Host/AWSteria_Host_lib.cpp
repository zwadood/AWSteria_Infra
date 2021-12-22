// Copyright (c) 2020-2021 Bluespec, Inc.  All Rights Reserved

// This library implements the AWSteria host-side API routines
// for AWS F1, linking with routines in aws-fpga SDK.

// ================================================================
// C lib includes

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>

// ----------------
// Project includes

#include "AWSteria_Host_lib.h"
#include "experimental/xrt_kernel.h"
#include "experimental/xrt_bo.h"
#include "experimental/xrt++.hpp"
#include "experimental/xrt_ip.h"

// ================================================================

#define DEVICE_BDF "0000:09:00.1"
#define XCLBIN_PATH "../../HW/testapp.xclbin"
#define DDR_A_INDEX 0
#define DDR_B_INDEX 1
#define DDR_C_INDEX 2
#define DDR_D_INDEX 3
const unsigned char XCLBIN_UUID[] = "FEB02EDD-017E-E6BE-AC4C-49AD1FB45295";
const char KERNEL_NAME[] = "mkAWSteria_HW";
typedef struct AWSteria_Host_State_t{
    xrtDeviceHandle device;
    xrtBufferHandle buffer;
    xrtKernelHandle kernel;
    xrtRunHandle    runHandle;
} AWSteria_Host_State;

static int verbosity = 0;

// ================================================================
// Initialization
void *AWSteria_Host_init (void)
{
    if (verbosity > 0)
	fprintf (stdout, "--> %s\n", __FUNCTION__);

    // AWSteria_Host_State *p_state = (AWSteria_Host_State *) malloc (sizeof (AWSteria_Host_State));
    // if (p_state == NULL) {
	// perror ("    malloc AWSteria_Host_State");
	// return NULL;
    // }
    // p_state->device = xrtDeviceOpenByBDF(DEVICE_BDF);
    // if (p_state->device == NULL) {
    // perror ("Unable to open device");
	// return NULL;
    // }
    // if (xrtDeviceLoadXclbinFile(p_state->device,XCLBIN_PATH) != 0) {
    // perror ("Unable to load xclbin");
	// return NULL;
    // }
    // p_state->buffer = xrtBOAlloc(p_state->device,0x40000000,0,1);
    // if (p_state->buffer  == NULL) {
	// perror ("Unable to allocate buffer");
	// return NULL;
    // }
    // p_state->kernel = xrtPLKernelOpenExclusive(p_state->device, XCLBIN_UUID, KERNEL_NAME);
    // if (p_state->kernel  == NULL) {
	// perror ("Unable to open kernel");
	// return NULL;
    // }
    // p_state->runHandle = xrtKernelRun(p_state->kernel);
    // if (p_state->runHandle  == NULL) {
	// perror ("Unable to run kernel");
	// return NULL;
    // }   
    auto dev = xrt::device(DEVICE_BDF);
    auto xclbin_uuid = dev.load_xclbin( "../../HW/testapp.xclbin");
    auto ip = xrt::ip(dev, xclbin_uuid, "mkAWSteria_HW");


    // ----------------
    return NULL;
}

// ================================================================
// These are used to communicate with the host-facing AXI4 port on the HW.
// Return 0 if transfer was ok, non-zero if transfer had error.

int AWSteria_AXI4_write (void *p_state,
			 uint8_t *buffer, const size_t size, const uint64_t address)

{
 //   int rc = xrtBOWrite (((AWSteria_Host_State*)p_state)->buffer, buffer, size, address);

    int rc;
    return rc;
}

int AWSteria_AXI4_read (void *p_state,
			uint8_t *buffer, const size_t size, const uint64_t address)
{
  //  int rc = xrtBORead  (((AWSteria_Host_State*)p_state)->buffer, buffer, size, address);

    int rc;
    return rc;
}

// ================================================================
// These are used to communicate with the host-facing AXI4-Lite port on the HW.
// Return 0 if transfer was ok, non-zero if transfer had error.
// Note: in AWS these invoke 'fpga_pci_{peek,poke}()', respectively.
//     p_state contains a pci_bar_handle_t handle for the two calls.

int AWSteria_AXI4L_write (void *opaque, uint64_t addr, uint32_t data)
{
    assert (opaque != NULL);

//    AWSteria_Host_State *p_state = opaque;

    int rc;
    return rc;
}

int AWSteria_AXI4L_read (void *opaque, uint64_t addr, uint32_t *p_data)
{
    assert (opaque != NULL);

//    AWSteria_Host_State *p_state = opaque;

    int rc;
    return rc;
}

// ================================================================
// Host_shutdown takes pointer to state returned by Host_init
// Return 0 if ok, non-zero if error

int AWSteria_Host_shutdown (void *opaque)
{

    return 0;
}

// ================================================================
