/* Rotated data-processing immediates must supply the shifter carry. */
#include "amber_registers.h"
#include "amber_macros.h"

        .text
        .globl main
main:
        mov     r0, #0
        cmp     r0, #1
        movs    r1, #0x90000002
        adc     r2, r0, #0
        mov     r3, pc
        mov     r3, r3, lsr #28
        expect  r2, 1, __LINE__
        expect  r3, 10, __LINE__

        @ A nonzero rotation also clears an incoming C=1.
        cmp     r0, r0
        movs    r1, #0x40000000
        adc     r2, r0, #0
        expect  r2, 0, __LINE__

        @ Zero rotation preserves either incoming carry value.
        cmp     r0, r0
        movs    r1, #2
        adc     r2, r0, #0
        expect  r2, 1, __LINE__
        cmp     r0, #1
        movs    r1, #2
        adc     r2, r0, #0
        expect  r2, 0, __LINE__

        @ Force the noncanonical encoding MOVS r1, #0, ROR #2.
        cmp     r0, r0
        .word   0xe3b01100
        adc     r2, r0, #0
        mov     r3, pc
        mov     r3, r3, lsr #28
        expect  r2, 0, __LINE__
        expect  r3, 4, __LINE__

        @ A failed predicate preserves the destination and flags.
        mov     r1, #0x55
        cmp     r0, #1
        movseq  r1, #0x90000002
        adc     r2, r0, #0
        mov     r3, pc
        mov     r3, r3, lsr #28
        expect  r1, 0x55, __LINE__
        expect  r2, 0, __LINE__
        expect  r3, 8, __LINE__

        @ S=0 must not update flags.
        cmp     r0, #1
        mov     r1, #0x90000002
        adc     r2, r0, #0
        expect  r2, 0, __LINE__
        b       testpass

testfail:
        ldr     r11, AdrTestStatus
        str     r10, [r11]
        b       testfail
testpass:
        ldr     r11, AdrTestStatus
        mov     r10, #17
        str     r10, [r11]
        b       testpass
AdrTestStatus: .word ADR_AMBER_TEST_STATUS
