###  -*-Makefile-*-

# Copyright (c) 2020-2021 Bluespec, Inc.  All Rights Reserved

# ================================================================

.PHONY: help
help:
	@echo "Usage:"
	@echo "    make $(EXE)        create the host-side executable"
	@echo "    make clean         delete temporary files/dirs but keep the executable"
	@echo "    make full_clean    delete temporary files/dirs and delete the executable"

#================================================================

ifndef AWSTERIA_INFRA_REPO
  $(error ERROR: please define AWSTERIA_INFRA_REPO (path to AWSteria_Infra repo))
else
  $(info  INFO: AWSTERIA_INFRA_REPO = $(AWSTERIA_INFRA_REPO))
endif

$(info INFO: Making executable $(EXE) for AWSteria TestApp host side on ALVEO_U200)

# ================================================================
# Source files

# ----------------
# App host side

SRCS_C = $(AWSTERIA_INFRA_REPO)/TestApp/Host/main.cpp

# ----------------
# AWSteria infra

SRCS_H += $(AWSTERIA_INFRA_REPO)/Include_API/AWSteria_Host_lib.h
SRCS_H += $(AWSTERIA_INFRA_REPO)/Platform_ALVEO_U200/Host/AWSteria_Platform.h

SRCS_C += $(AWSTERIA_INFRA_REPO)/Platform_ALVEO_U200/Host/AWSteria_Host_lib.cpp

# ================================================================

CFLAGS += -g -lstdc++ -Wall -lxrt_coreutil -pthread

CFLAGS += -D Platform_ALVEO_U200

CFLAGS += -I $(AWSTERIA_INFRA_REPO)/Include_API 
CFLAGS += -I $(AWSTERIA_INFRA_REPO)/Platform_ALVEO_U200/Host
CFLAGS += -I $(XILINX_XRT)/include 
CFLAGS += -L $(XILINX_XRT)/lib 

CC     = clang $(CFLAGS)

EXE    = exe_Host_ALVEO_U200

# ================================================================
# Top-level target: the executable

$(EXE): $(SRCS_H) $(SRCS_C)
	$(CC) -g  -o $(EXE) $(SRCS_C)
	@echo "INFO: created '$(EXE)'"

# ================================================================

.PHONY: clean
clean:
	rm -f  *.*~  Makefile*~  *.o

.PHONY: full_clean
full_clean:
	rm -f  *.*~  Makefile*~  *.o  exe_*

# ================================================================
