#!/bin/bash 

#--------------------------------------------------------------#
#                                                              #
#  run.sh                                                      #
#                                                              #
#  This file is part of the Amber project                      #
#  http://www.opencores.org/project,amber                      #
#                                                              #
#  Description                                                 #
#  Run a Verilog simulation using Modelsim                     #
#                                                              #
#  Author(s):                                                  #
#      - Conor Santifort, csantifort.amber@gmail.com           #
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

#--------------------------------------------------------
# Defaults
#--------------------------------------------------------
AMBER_LOAD_MAIN_MEM=" "
AMBER_TIMEOUT=0
AMBER_LOG_FILE="tests.log"
SET_G=0
SET_M=0
SET_D=0
SET_T=0
SET_S=0
SET_V=0
SET_A=0
SET_5=0
SET_L=0
SET_NC=0   # no compile
SET_TO=0   # override timeout


# show program usage
show_usage() {
    echo "Usage:"
    echo "run <test_name> [-a] [-g] [-d] [-t] [-s] [-v]"
    echo " -h : Help"
    echo " -a : Run hardware tests (all tests in \$AMBER_BASE/hw/tests)"
    echo " -g : Use Modelsim GUI"
    echo " -d <cycle number to start dumping>: Create vcd file"
    echo " -t <cycle number to start dumping>: Create vcd file and terminate"
    echo " -l : Create wlf dump of complete design"
    echo " -nc: Do not re-compile the Verilog. Starts the simulation more quickly"
    echo " -s : Use Xilinx Spatran6 Libraries (slower sim)"
    echo " -to <timeout value>: Use this timeout value instead of the value in the timeouts.txt file"
    echo " -v : Use Xilinx Virtex6 Libraries (slower sim)"
    echo " -5 : Use Amber25 core instead of Amber23 core"
    echo ""
    exit
}

#--------------------------------------------------------
# Parse command-line options
#--------------------------------------------------------

# Minimum number of arguments needed by this program
MINARGS=1

# show usage if '-h' or  '--help' is the first argument or no argument is given
case $1 in
	""|"-h"|"--help"|"help"|"?") show_usage ;;
esac

# get the number of command-line arguments given
ARGC=$#

# check to make sure enough arguments were given or exit
if [[ $ARGC -lt $MINARGS ]] ; then
 echo "Too few arguments given (Minimum:$MINARGS)"
 echo
 show_usage
fi

# self-sorting argument types LongEquals, ShortSingle, ShortSplit, and ShortMulti
# process command-line arguments
while [ "$1" ]
do
    case $1 in
        -*)  true ;
            case $1 in
                -a)     SET_A=1   # all tests
                        shift ;;
                -s)     SET_S=1   # Xilinx Spartan6 libs
                        shift ;;
                -v)     SET_V=1   # Xilinx Virtex6 libs
                        shift ;;
                -5)     SET_5=1   # Amber25 core (default is Amber23 core)
                        shift ;;
                -g)     SET_G=1   # Bring up GUI
                        shift ;;
                -l)     SET_L=1   # Create wlf wave dump file
                        shift ;;
                -nc)    SET_NC=1  # Don't recompile the Verilog
                        shift ;;
                -to)    SET_TO=1          # Override timeout value in timeout file
                        AMBER_TIMEOUT=$2  # New timeout value
                        shift 2;;
                -d)     SET_D=1         # Enable VCD dump
                        DUMP_START=$2   # Clock cycle to start dumping
                        shift 2;;
                        
                -t)     SET_D=1         # Enable VCD dump
                        SET_T=1         # Terminate test after vcd dump completes
                        DUMP_START=$2   # Clock cycle to start dumping
                        shift 2;;
                        
                -*)
                        echo "Unrecognized argument $1"
                        shift ;;
            esac ;;  
        * ) AMBER_TEST_NAME=$1
            shift ;;
        
    esac
done


#--------------------------------------------------------
# Set comfiguration based on command-line options
#--------------------------------------------------------

if [ $SET_G == 1 ]; then
    RUN_OPTIONS="-do cmd.do"
else    
    if [ $SET_L == 1 ]; then
        RUN_OPTIONS="${RUN_OPTIONS} -c -do run-log.do"
    else    
        RUN_OPTIONS="${RUN_OPTIONS} -c -do run.do"
    fi
fi

if [ $SET_S == 1 ]; then
    FPGA="+define+XILINX_SPARTAN6_FPGA +define+XILINX_FPGA"
    RUN_OPTIONS="${RUN_OPTIONS} -t ps  +notimingchecks -L unisims_ver -L secureip"
else    
    if [ $SET_V == 1 ]; then
        FPGA="+define+XILINX_VIRTEX6_FPGA +define+XILINX_FPGA"
        RUN_OPTIONS="${RUN_OPTIONS} -t ps  +notimingchecks"
    else    
        FPGA=" "
    fi
fi


if [ $SET_D == 1 ]; then
    AMBER_DUMP_VCD="+define+AMBER_DUMP_VCD +define+AMBER_DUMP_START=$DUMP_START"
else    
    AMBER_DUMP_VCD=" "
fi

if [ $SET_5 == 1 ]; then
    AMBER_CORE="+define+AMBER_A25_CORE"
else    
    AMBER_CORE=" "
fi

if [ $SET_T == 1 ]; then
    AMBER_TERMINATE="+define+AMBER_TERMINATE"
else    
    AMBER_TERMINATE=" "
fi

if [ $SET_A == 1 ]; then
    if [ $SET_S == 1 ]; then
        TECH="-s"
    elif [ $SET_V == 1 ]; then
        TECH="-v"
    else    
        TECH=" "
    fi        

    if [ $SET_5 == 1 ]; then
        CORE="-5"
    else    
        CORE=" "
    fi
    
    ../tools/all.sh ${AMBER_LOG_FILE} ${TECH} ${CORE}
    exit
fi

#--------------------------------------------------------
# Compile the test
#--------------------------------------------------------

# First check if its an assembly test
if [ -f ../tests/${AMBER_TEST_NAME}.S ]; then
    # hw-test
    TEST_TYPE=1
elif [ ${AMBER_TEST_NAME} == vmlinux ]; then
    TEST_TYPE=3
elif [ ${AMBER_TEST_NAME} == hello-world ]; then
    TEST_TYPE=4
elif [ -d ../../sw/${AMBER_TEST_NAME} ]; then
    # Does this test type need the boot-loader ?
    if [ -e ../../sw/${AMBER_TEST_NAME}/sections.lds ]; then
        grep 80000 ../../sw/${AMBER_TEST_NAME}/sections.lds > /dev/null
        if [ $? == 0 ]; then
            # Needs boot loader, starts at 0x80000
            TEST_TYPE=3
        else
            TEST_TYPE=2
        fi
    else
        TEST_TYPE=2
    fi    
else    
    echo "Test ${AMBER_TEST_NAME} not found"
    exit
fi

echo "Test ${AMBER_TEST_NAME}, type $TEST_TYPE"

# Now compile the test
if [ $TEST_TYPE == 1 ]; then
    # hw assembly test
    echo "Compile ../tests/${AMBER_TEST_NAME}.S"
    pushd ../tests > /dev/null
    make --quiet TEST=${AMBER_TEST_NAME}
    MAKE_STATUS=$?
    
    if [ $SET_NC == 1 ]; then
        rm add.mem
        ln -s ${AMBER_TEST_NAME}.mem add.mem
    fi
        
    popd > /dev/null
    BOOT_MEM_FILE="../tests/${AMBER_TEST_NAME}.mem"
    
    if [ $SET_5 == 1 ]; then
        BOOT_MEM_PARAMS_FILE="../tests/${AMBER_TEST_NAME}_memparams128.v"
    else
        BOOT_MEM_PARAMS_FILE="../tests/${AMBER_TEST_NAME}_memparams32.v"
    fi
    
elif [ $TEST_TYPE == 2 ]; then
    # sw Stand-alone C test
    pushd ../../sw/${AMBER_TEST_NAME} > /dev/null
    make
    MAKE_STATUS=$?
    popd > /dev/null
    BOOT_MEM_FILE="../../sw/${AMBER_TEST_NAME}/${AMBER_TEST_NAME}.mem"
    if [ $SET_5 == 1 ]; then
        BOOT_MEM_PARAMS_FILE="../../sw/${AMBER_TEST_NAME}/${AMBER_TEST_NAME}_memparams128.v"
    else
        BOOT_MEM_PARAMS_FILE="../../sw/${AMBER_TEST_NAME}/${AMBER_TEST_NAME}_memparams32.v"
    fi

elif [ $TEST_TYPE == 3 ] || [ $TEST_TYPE == 4 ]; then
    # sw test using boot loader
    pushd ../../sw/boot-loader > /dev/null
    make
    MAKE_STATUS=$?
    popd > /dev/null
    if [ $MAKE_STATUS != 0 ]; then
        echo "Error compiling boot-loader"
        exit 1
    fi
    
    pushd ../../sw/${AMBER_TEST_NAME} > /dev/null
    if [ -e Makefile ]; then
        make
    fi
    MAKE_STATUS=$?
    popd > /dev/null
    
    BOOT_MEM_FILE="../../sw/boot-loader/boot-loader.mem"
    if [ $SET_5 == 1 ]; then
        BOOT_MEM_PARAMS_FILE="../../sw/boot-loader/boot-loader_memparams128.v"
    else
        BOOT_MEM_PARAMS_FILE="../../sw/boot-loader/boot-loader_memparams32.v"
    fi
    MAIN_MEM_FILE="../../sw/${AMBER_TEST_NAME}/${AMBER_TEST_NAME}.mem"
    AMBER_LOAD_MAIN_MEM="+define+AMBER_LOAD_MAIN_MEM"

else
    echo "Error unrecognized test type"
fi

if [ $MAKE_STATUS != 0 ]; then
    echo "Failed " $AMBER_TEST_NAME " compile error" >> $AMBER_LOG_FILE
    exit
fi


# Set timeout and testname in the .mem file
if [ $SET_TO == 0 ]; then
    AMBER_TIMEOUT=`../tools/get_timeout.sh ${AMBER_TEST_NAME}`      
fi   


#--------------------------------------------------------
# Modelsim
#--------------------------------------------------------
if [ ! -d work ]; then
    vlib work
    if [ $? != 0 ]; then exit; fi
fi

if [ $SET_NC == 0 ]; then
    vlog +libext+.v \
         +incdir+../vlog/amber23+../vlog/amber25+../vlog/system+../vlog/tb+../vlog/ethmac \
         +incdir+../vlog/lib+../vlog/xs6_ddr3+../vlog/xv6_ddr3 \
         -y ../vlog/amber23 -y ../vlog/amber25 -y ../vlog/system  -y ../vlog/tb -y ../vlog/ethmac \
         -y ../vlog/lib   -y ../vlog/xs6_ddr3 -y ../vlog/xv6_ddr3  \
         -y $XILINX/verilog/src/unisims \
         -y $XILINX/verilog/src \
         ../vlog/tb/tb.v \
         $XILINX/verilog/src/glbl.v \
         +define+BOOT_MEM_FILE=\"$BOOT_MEM_FILE\" \
         +define+BOOT_MEM_PARAMS_FILE=\"$BOOT_MEM_PARAMS_FILE\" \
         +define+MAIN_MEM_FILE=\"$MAIN_MEM_FILE\" \
         +define+AMBER_LOG_FILE=\"$AMBER_LOG_FILE\" \
         +define+AMBER_TEST_NAME=\"$AMBER_TEST_NAME\" \
         +define+AMBER_SIM_CTRL=$TEST_TYPE \
         +define+AMBER_TIMEOUT=$AMBER_TIMEOUT \
         ${FPGA} \
         $AMBER_CORE \
         $AMBER_DUMP_VCD \
         $AMBER_TERMINATE \
         $AMBER_LOAD_MAIN_MEM
    if [ $? != 0 ]; then exit; fi
fi
               
vsim -voptargs="+acc=rnpc" tb ${RUN_OPTIONS}
if [ $? != 0 ]; then exit; fi
         
# Set a timeout value for the test if it passed
if [ $TEST_TYPE == 1 ]; then
    tail -1 < ${AMBER_LOG_FILE} | grep Passed > /dev/null
    if [ $? == 0 ]; then 
        TICKS=`tail -1 < ${AMBER_LOG_FILE} | awk '{print $3}'`
        TOTICKS=$(( $TICKS * 4 + 1000 ))
        ../tools/set_timeout.sh ${AMBER_TEST_NAME} $TOTICKS
    fi
fi



