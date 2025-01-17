###  -*-Makefile-*-

# Copyright (c) 2020-2023 Bluespec, Inc.  All Rights Reserved

# ================================================================

.PHONY: help
help:
	@echo "Usage:"
	@echo "    make $(EXE)        create the host-side executable"
	@echo "    make clean         delete temporary files/dirs but keep the executable"
	@echo "    make full_clean    delete temporary files/dirs and delete the executable"
	@echo "  Please define TARGET=VCU118 or TARGET=AWSF1 for proper DDR setup"

#================================================================

ifndef AWSTERIA_INFRA_REPO
  $(error ERROR: please define AWSTERIA_INFRA_REPO (path to AWSteria_Infra repo))
else
  $(info  INFO: AWSTERIA_INFRA_REPO = $(AWSTERIA_INFRA_REPO))
endif

# Default target
TARGET ?= VCU118

# ================================================================
# Source files

# ----------------
# App host side

SRCS_C = $(AWSTERIA_INFRA_REPO)/TestApp/Host/main.c

# ----------------
# AWSteria infra

SRCS_H += \
	$(AWSTERIA_INFRA_REPO)/Include_API/AWSteria_Host_lib.h \
	$(AWSTERIA_INFRA_REPO)/Platform_Sim/Host/AWSteria_Platform.h \
	$(AWSTERIA_INFRA_REPO)/Platform_Sim/Host/Bytevec.h \
	$(AWSTERIA_INFRA_REPO)/Platform_Sim/Host/TCP_Client_Lib.h

SRCS_C += \
	$(AWSTERIA_INFRA_REPO)/Platform_Sim/Host/AWSteria_Host_lib.c \
	$(AWSTERIA_INFRA_REPO)/Platform_Sim/Host/Bytevec.c \
	$(AWSTERIA_INFRA_REPO)/Platform_Sim/Host/TCP_Client_Lib.c

# ================================================================
# Config AWSteria_Infra simulation for different targets

ifeq ($(TARGET),VCU118)

  CFLAGS += -D SIM_FOR_VCU118
  $(info  INFO: TARGET is VCU118 (has DDR A and B))

else ifeq ($(TARGET),AWSF1)

  CFLAGS += -D SIM_FOR_AWSF1
  $(info  INFO: TARGET is AWSF1 (has DDR A, B, C and D))

else
  $(error ERROR: please define TARGET=VCU118 or TARGET=AWSF1 for proper DDR setup)
endif

# ================================================================
# C compilation

CFLAGS += -std=gnu11 -g -Wall -Werror

CFLAGS += -I $(AWSTERIA_INFRA_REPO)/Include_API
CFLAGS += -I $(AWSTERIA_INFRA_REPO)/Platform_Sim/Host

CC     = gcc $(CFLAGS)

EXE    = exe_Host_sim

# ================================================================
# Top-level target: the executable

$(EXE): $(SRCS_H) $(SRCS_C)
	$(CC) -g  -o $(EXE) $(SRCS_C)
	@echo "INFO: Created host-side executable $(EXE)"

# ================================================================

.PHONY: clean
clean:
	rm -r -f  *.*~  Makefile*~  *.o

.PHONY: full_clean
full_clean:
	rm -r -f  *.*~  Makefile*~  *.o  exe_*

# ================================================================
