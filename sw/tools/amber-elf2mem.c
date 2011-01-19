/*----------------------------------------------------------------
//                                                              //
//  amber-elf2mem.c                                             //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Read in a binary elf file and write it out in               //
//  in Verilig readmem format. No ELF format conversion is      // 
//  done.                                                       //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
----------------------------------------------------------------*/

/*
ELF File Structure
A single segment usually consist of several sections. E.g., a loadable 
read-only segment could contain sections for executable code, read-only 
data, and symbols for the dynamic linker. Relocatable files have section 
header tables. Executable files have program header tables. Shared object 
files have both. Sections are intended for further processing by a linker, 
while the segments are intended to be mapped into memory.
*/


#include <stdio.h>
#include <stdlib.h>
#include "../boot-loader/boot-loader.h"


int fsize(FILE *f);


int main(int argc,char *argv[])
{
   FILE *infile;
   char filename_mem[80], filename_nopath[80];
   unsigned char *buf;
   FILE *file_mem;
   int infile_size, buf_size, i, j;
   
   if (argc<2){
      printf("%s ERROR: no input file specified. Quitting\n", argv[0]);
      exit(1);
      }

   infile=fopen(argv[1],"rb");
   if(infile==NULL) {
      printf("%s ERROR: Can't open %s. Quitting\n", argv[0], argv[1]);
      exit(1);
   }
   infile_size = fsize(infile);
   
   buf=(unsigned char*)malloc(infile_size);
   buf_size=fread(buf,1,infile_size,infile);
   fclose(infile);

   if ( buf_size != infile_size ) {
      fprintf(stderr, "%s ERROR: Input %s file length is %d bytes long, buffer read buf_size %d\n", 
      argv[0], argv[1], infile_size, buf_size);
      exit(1);
      }
      
      
   if ( infile_size > 0x1000000 ) {
      fprintf(stderr, "%s WARNING: Input %s file length is %d bytes long, greater than boot-loader can handle \n", 
      argv[0], argv[1], infile_size);
      }
      
   for (i=0;i<buf_size;i+=4) {
        printf("@%08x %02x%02x%02x%02x\n", FILE_LOAD_BASE + i, 
                       buf[i+3], buf[i+2], buf[i+1], buf[i+0]);
        }
   
   free(buf);

   return 0;
}



/* Return the buf_size of a file in bytes */
int fsize( FILE *f )
{
    int end;

    /* Set current position at end of file */
    fseek( f, 0, SEEK_END );

    /* File buf_size in bytes */
    end = ftell( f );

    /* Set current position at start of file */
    fseek( f, 0, SEEK_SET );

    return end;
}



