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

# ---- Environment Variables ----

check_defined = \
		    $(strip $(foreach 1,$1, \
		            $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
		      $(if $(value $1),, \
		            $(error Undefined $1$(if $2, ($2))))

$(call check_defined, PDK_ROOT CARAVEL_PICO_ROOT CARAVEL_ROOT,export or define them)

PDK_PATH = $(PDK_ROOT)/sky130A
VERILOG_PATH = $(CARAVEL_PICO_ROOT)/verilog
VIP_PATH = $(VERILOG_PATH)/dv/vip
FIRMWARE_PATH = $(VERILOG_PATH)/dv/firmware

# ---- Caravel Integration Information ----

CARAVEL_VERILOG_PATH = $(CARVEL_ROOT)/verilog


# ---- Compiler Information ----

# GCC_PATH
# GCC_PREFIX?=riscv32-unknown-linux-gnu
$(call check_defined, GCC_PATH GCC_PREFIX, are missing export or define them)





