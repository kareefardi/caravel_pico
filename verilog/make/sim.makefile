# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0



SIM_DEFINES = -DFUNCTIONAL -DSIM

SIM?=RTL
SIMS = RTL GL GL_SDF

VCDS = RTL.vcd GL.vcd
VVPS = $(foreach i,$(SIMS),$(i).vvp)
ALL: GL_SDF RTL GL

%.elf: %.c $(LINKER_SCRIPT) $(SOURCE_FILES) 
	${GCC_PATH}/${GCC_PREFIX}-gcc -I$(FIRMWARE_PATH) -march=rv32imc -mabi=ilp32 \
	-Wl,-Bstatic,-T,$(LINKER_SCRIPT),--strip-debug \
	-ffreestanding -nostdlib -o $@ $(SOURCE_FILES) $<

%.hex: %.elf
	${GCC_PATH}/${GCC_PREFIX}-objcopy -O verilog $< $@ 
	# to fix flash base address
	sed -i 's/@10000000/@00000000/g' $@

%.bin: %.elf
	${GCC_PATH}/${GCC_PREFIX}-objcopy -O binary $< /dev/stdout | tail -c +1048577 > $@

.PHONY: RTL
.PHONY: RTL.vcd 
RTL.vcd : $(BLOCKS)_tb.v $(BLOCKS).hex
	# this is RTL
	iverilog -Ttyp $(SIM_DEFINES) -I $(VIP_PATH) \
		-I $(PDK_PATH) -I $(VERILOG_PATH)/common -I $(VERILOG_PATH)/rtl  -I $(CARAVEL_VERILOG_PATH)/rtl \
		$< -o $@ 

.PHONY: GL
.PHONY: GL.vcd 
GL.vcd : $(BLOCKS)_tb.v $(BLOCKS).hex
	# this is GL
	iverilog -Ttyp $(SIM_DEFINES) -DGL -I $(VIP_PATH) \
		-I $(PDK_PATH) -I $(VERILOG_PATH)/common -I $(VERILOG_PATH)  -I $(CARAVEL_VERILOG_PATH) -I $(CARAVEL_VERILOG_PATH)/rtl  \
		$< -o $@ 

.PHONY: GL_SDF
.PHONY: GL_SDF.vvp
GL_SDF.vvp : $(BLOCKS)_tb.v $(BLOCKS).hex
	# this is GL_SDF
	$(eval VIP_PATH := $(shell realpath --relative-to=$(shell pwd) $(VIP_PATH)))
	$(eval COMMON_ABSOLUTE_PATH := $(shell realpath --relative-to=$(shell pwd) $(VERILOG_PATH)/common))
	$(eval PDK_ABSOLUTE_PATH := $(shell realpath --relative-to=$(shell pwd) $(PDK_PATH)))
	$(eval RTL_ABSOLUTE_PATH := $(shell realpath --relative-to=$(shell pwd) $(VERILOG_PATH)/rtl))
	$(eval VERILOG_ABSOLUTE_PATH := $(shell realpath --relative-to=$(shell pwd) $(VERILOG_PATH)))
	$(eval CARAVEL_VERILOG_ABSOLUTE_PATH := $(shell realpath --relative-to=$(shell pwd) $(CARAVEL_VERILOG_PATH)))
	$(eval CURRENT_DIRECTORY := $(shell pwd))
	
	cvc +interp +incdir+$(COMMON_ABSOLUTE_PATH)+$(VIP_PATH)+$(VERILOG_ABSOLUTE_PATH)+$(RTL_ABSOLUTE_PATH)+$(CARAVEL_VERILOG_ABSOLUTE_PATH)+$(CARAVEL_VERILOG_ABSOLUTE_PATH)/rtl+$(PDK_ABSOLUTE_PATH)+$(CURRENT_DIRECTORY) \
	    +define+FUNCTIONAL +define+SIM +define+GL +define+USE_POWER_PINS +define+ENABLE_SDF +change_port_type +dump2fst $< | tee @.log

GL_SDF : % : %.vvp
	# GL_SDF done simulation $(BLOCKS)
	

RTL GL : % : %.vvp
	# RTL GL done simulating $(BLOCKS)


RTL.vvp GL.vvp : %.vvp : %.vcd
	vvp $< | tee $<.log


# ---- Clean ----

clean:
	rm -f *.elf *.hex *.bin *.vvp *.vcd *.log

.PHONY: clean hex all



