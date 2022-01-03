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
#define IP_NAME "mkAWSteria_HW"
typedef struct AWSteria_Host_State_t{
    xrt::ip  ip;
    xrt::bo  buffer;
} AWSteria_Host_State;

static int verbosity = 0;

// ================================================================
// Initialization
void *AWSteria_Host_init (void)
{
    if (verbosity > 0)
	fprintf (stdout, "--> %s\n", __FUNCTION__);

    AWSteria_Host_State *p_state = (AWSteria_Host_State *) malloc (sizeof (AWSteria_Host_State));
     if (p_state == NULL) {
	 perror ("    malloc AWSteria_Host_State");
	 return NULL;
    }
    auto dev = xrt::device(DEVICE_BDF);
    auto xclbin_uuid = dev.load_xclbin(XCLBIN_PATH);
    p_state->ip = xrt::ip(dev, xclbin_uuid, IP_NAME);
    p_state->buffer = xrt::bo(dev, 0x10000,1);
    printf("Buffer device address = 0x%llx\n", p_state->buffer.address() );
    return p_state;
}

// ================================================================
// These are used to communicate with the host-facing AXI4 port on the HW.
// Return 0 if transfer was ok, non-zero if transfer had error.

int AWSteria_AXI4_write (void *p_state,
			 uint8_t *buffer, const size_t size, const uint64_t address)

{
    assert (p_state != NULL);
    assert ((((AWSteria_Host_State*)p_state)->buffer.address() <= address) && (((AWSteria_Host_State*)p_state)->buffer.address() +(((AWSteria_Host_State*)p_state)->buffer.size() >= address)));

    uint64_t buffer_offset = address - ((AWSteria_Host_State*)p_state)->buffer.address();
    ((AWSteria_Host_State*)p_state)->buffer.write(buffer, size, buffer_offset);
    ((AWSteria_Host_State*)p_state)->buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    return 0;
}

int AWSteria_AXI4_read (void *p_state,
			uint8_t *buffer, const size_t size, const uint64_t address)
{
    assert (p_state != NULL);
    assert ((((AWSteria_Host_State*)p_state)->buffer.address() <= address) && (((AWSteria_Host_State*)p_state)->buffer.address() +(((AWSteria_Host_State*)p_state)->buffer.size() >= address)));
    uint64_t buffer_offset = address -((AWSteria_Host_State*)p_state)->buffer.address();
    ((AWSteria_Host_State*)p_state)->buffer.read(buffer, size, buffer_offset);
    ((AWSteria_Host_State*)p_state)->buffer.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
    return 0;
}

// ================================================================
// These are used to communicate with the host-facing AXI4-Lite port on the HW.

int AWSteria_AXI4L_write (void *p_state, uint64_t addr, uint32_t data)
{
    assert (p_state != NULL);
    ((AWSteria_Host_State*)p_state)->ip.write_register(addr,0xCD);
    return 0;
}

int AWSteria_AXI4L_read (void *p_state, uint64_t addr, uint32_t *p_data)
{
    assert (p_state != NULL);
    *p_data = ((AWSteria_Host_State*)p_state)->ip.read_register(addr);
    return 0;
}

// ================================================================
// Host_shutdown takes pointer to state returned by Host_init
// Return 0 if ok, non-zero if error

int AWSteria_Host_shutdown (void *p_state)
{
    free(p_state);

    return 0;
}

// ================================================================
