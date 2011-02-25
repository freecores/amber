#!/bin/bash 

#--------------------------------------------------------------#
#                                                              #
#  all.sh                                                      #
#                                                              #
#  This file is part of the Amber project                      #
#  http://www.opencores.org/project,amber                      #
#                                                              #
#  Description                                                 #
#  Runa list of tests from the $AMBER_BASE/hw/tests directory  #
#                                                              #
#  Author(s):                                                  #
#      - Conor Santifort, santifort@opencores.org              #
#                                                              #
#//////////////////////////////////////////////////////////////#
#                                                              #
# Copyright (C) 2010 Authors and OPENCORES.ORG                 #
#                                                              #
# This source file may be used and distributed without         #
# restriction provided that this copyright statement is not    #
# removed from the file and that any derivative work contains  #
# the original copyright notice and the associated disclaimer. #
#                                                              #
# This source file is free software; you can redistribute it   #
# and/or modify it under the terms of the GNU Lesser General   #
# Public License as published by the Free Software Foundation; #
# either version 2.1 of the License, or (at your option) any   #
# later version.                                               #
#                                                              #
# This source is distributed in the hope that it will be       #
# useful, but WITHOUT ANY WARRANTY; without even the implied   #
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      #
# PURPOSE.  See the GNU Lesser General Public License for more #
# details.                                                     #
#                                                              #
# You should have received a copy of the GNU Lesser General    #
# Public License along with this source; if not, download it   #
# from http://www.opencores.org/lgpl.shtml                     #
#                                                              #
#--------------------------------------------------------------#

TEST_LIST="
           add adc sub sbc barrel_shift barrel_shift_rs \
           change_sbits change_mode \
           bl bcc \
           ldr ldr_str_pc strb \
           ldm1 ldm2 ldm3 ldm4 stm1 stm2 ldm_stm_onetwo stm_stream \
           mul mla  \
           swp \
           \
           irq firq swi undefined_ins addr_ex irq_stm \
           \
           cache1 cache2 cache3 cache_swap \
           cacheable_area cache_flush \
           \
           flow1 flow2 flow3 conflict_rd \
           \
           hiboot_mem ddr31 ddr32 ddr33 \
           \
           ethmac_reg ethmac_mem ethmac_tx \
           \
           uart_reg uart_tx uart_rx uart_rxint \
           \
           bic_bug movs_bug flow_bug \
           mlas_bug inflate_bug swp_lock_bug \
           cache_swap_bug \
           "
LOF_FILE=$1

echo "----------------------------------" >> ${LOF_FILE}
date >> ${LOF_FILE}

for i in $TEST_LIST; do
    echo "Run test $i"
    ../tools/run.sh ${i} $2 $3
done

echo "----------------------------------" >> ${LOF_FILE}

