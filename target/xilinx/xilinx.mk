# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>

PROJECT      ?= zcu102
# Board in {genesys2, zcu104, zcu102, pynq-z1}
BOARD          = zcu102
XILINX_PORT  ?= 3121
XILINX_HOST  ?= imodium.polito.it

BENDER ?= bender


ifeq ($(BOARD),genesys2)
	XILINX_PART  ?= xc7k325tffg900-2
	XILINX_BOARD ?= digilentinc.com:genesys2:part0:1.1
	ips-names    := xlnx_mig_7_ddr3 xlnx_clk_wiz xlnx_vio
	FPGA_PATH    ?= xilinx_tcf/Digilent/200300A8C60DB
endif
ifeq ($(BOARD),zcu104)
	XILINX_PART  = xczu7ev-ffvc1156-2-e
	XILINX_BOARD = xilinx.com:zcu104:part0:1.1
	# ips-names      := xlnx_mig_ddr4 xlnx_clk_wiz xlnx_vio
	ips := xlnx_mig_ddr4.xci
endif
ifeq ($(BOARD),zcu102)
	XILINX_PART  = xczu9eg-ffvb1156-2-e
	XILINX_BOARD = xilinx.com:zcu102:part0:3.4
	FPGA_PATH    ?= xilinx_tcf/Digilent/210308A5F4C8
	# ips := xlnx_mig_ddr4.xci
endif
ifeq ($(BOARD),pynq-z1)
	XILINX_PART = xc7z020clg400-1
	XILINX_BOARD = www.digilentinc.com:pynq-z1:part0:1.0
endif

# Location of ip outputs
# ips := $(addprefix $(CAR_XIL_DIR)/,$(addsuffix .xci ,$(basename $(ips-names))))

SOC := cheshire_top_xilinx_wrapper

out := out
bit := $(out)/${SOC}.bit
mcs := $(out)/${SOC}.mcs
BIT ?= $(bit)

VIVADOENV ?=  PROJECT=$(PROJECT)            \
              BOARD=$(BOARD)                \
              XILINX_PART=$(XILINX_PART)    \
              XILINX_BOARD=$(XILINX_BOARD)  \
              PORT=$(XILINX_PORT)           \
              HOST=$(XILINX_HOST)           \
              FPGA_PATH=$(FPGA_PATH)        \
              BIT=$(BIT)

# select IIS-internal tool commands if we run on IIS machines
ifneq (,$(wildcard /etc/iis.version))
	VIVADO ?= vivado
else
	VIVADO ?= vivado
endif

VIVADOFLAGS ?= -nojournal -mode batch

ip-dir  := xilinx

all: $(bit)

$(bit): $(ips)
	@mkdir -p $(out)
	$(BENDER) script vivado -t fpga -t cv64a6_imafdcsclic_sv39 -t cva6 > scripts/add_sources.tcl
	# $(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/prologue.tcl -source scripts/run.tcl
	 $(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source ips/ILA/run.tcl -source scripts/prologue.tcl -source scripts/run.tcl
	cp $(PROJECT).runs/impl_1/cheshire_top_xilinx_wrapper* ./$(out)

$(ips):
	@echo "Generating IP $(basename $@)" 
	cd $(ip-dir)/$(basename $@) && $(MAKE) clean && $(VIVADOENV) VIVADO="$(VIVADO)" $(MAKE)
	cp $(ip-dir)/$(basename $@)/$(basename $@).srcs/sources_1/ip/$(basename $@)/$@ $@


gui:
	@echo "Starting $(VIVADO) GUI"
	@$(VIVADOENV) $(VIVADO) -nojournal -mode gui $(PROJECT).xpr &

program:
	@echo "Programming board $(BOARD) ($(XILINX_PART))"
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/program.tcl

program-ILA:
	@echo "Programming board $(BOARD) ($(XILINX_PART))"
	$(VIVADOENV) $(VIVADO) -nojournal -mode gui -source scripts/programwithILA.tcl

clean:
	rm -rf *.log *.jou *.str *.mif *.xci *.xpr .Xil/ $(out) $(PROJECT).cache $(PROJECT).hw $(PROJECT).ioplanning $(PROJECT).ip_user_files $(PROJECT).runs $(PROJECT).gen $(PROJECT).srcs $(PROJECT).sim reports/ ./ips/ILA/ila_0.*

.PHONY: clean
