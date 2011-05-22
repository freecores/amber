
SRC = dhry.c dhry_2.c start.S
TGT = dhry
LDS = sections.lds
USE_MINI_LIBC = 1

LIBC_OBJ         = ../mini-libc/printf.o ../mini-libc/libc_asm.o ../mini-libc/memcpy.o 
DEP             += ../include/amber_registers.h ../mini-libc/stdio.h
TOOLSPATH        = ../tools
AMBER_CROSSTOOL ?= amber-crosstool-not-defined

  AS = $(AMBER_CROSSTOOL)-as
  CC = $(AMBER_CROSSTOOL)-gcc
 CXX = $(AMBER_CROSSTOOL)-g++
  AR = $(AMBER_CROSSTOOL)-ar
  LD = $(AMBER_CROSSTOOL)-ld
  DS = $(AMBER_CROSSTOOL)-objdump
  OC = $(AMBER_CROSSTOOL)-objcopy
 ELF = $(TOOLSPATH)/amber-elfsplitter
 BMF32  = ../tools/amber-memparams32.sh
 BMF128 = ../tools/amber-memparams128.sh

 MMP32  = $(addsuffix _memparams32.v, $(basename $(TGT)))
 MMP128 = $(addsuffix _memparams128.v, $(basename $(TGT)))
 MEM = $(addsuffix .mem, $(basename $(TGT)))
 DIS = $(addsuffix .dis, $(basename $(TGT)))
 
ifdef USE_MINI_LIBC
 OBJ = $(addsuffix .o,   $(basename $(SRC))) $(LIBC_OBJ)
else
 OBJ = $(addsuffix .o,   $(basename $(SRC)))
endif

 
ifdef LDS
    TLDS = -T $(LDS)
else
    TLDS = 
endif

ifndef TGT
    TGT = aout.elf
endif

ifdef MIN_SIZE
    # optimize for size
    OPTIMIZE = -Os
else
    # optimize for speed
    OPTIMIZE = -O3
endif

 MAP = $(addsuffix .map, $(basename $(TGT))) 
 
 ASFLAGS = -I../include 
  CFLAGS = -c $(OPTIMIZE) -march=armv2a -mno-thumb-interwork -ffreestanding -I../include
 DSFLAGS = -C -S -EL
 LDFLAGS = -Bstatic -Map $(MAP) --strip-debug --fix-v4bx


ifdef USE_MINI_LIBC
debug:  mini-libc $(ELF) $(MMP) $(DIS)
else
debug:  $(ELF) $(MMP) $(DIS)
endif

$(MMP): $(MEM)
	$(BMF32) $(MEM) $(MMP32)

$(MEM): $(TGT)
	$(ELF) $(TGT) > $(MEM)

$(TGT): $(OBJ)
	$(LD) $(LDFLAGS) -o $(TGT) $(TLDS) $(OBJ)
	$(OC) -R .comment -R .note $(TGT)

$(OBJ): $(DEP)

mini-libc:
	$(MAKE) -s -C ../mini-libc MIN_SIZE=1

$(ELF):
	$(MAKE) -C $(TOOLSPATH)
        
$(DIS): $(TGT)
	$(DS) $(DSFLAGS) $^ > $@

clean:
	@rm -rfv *.o *.elf *.dis *.map *.mem *.v $(MMP) dhry

