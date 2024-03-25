#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ****************************************************
; ***** Write text line, appending cr/lf to file *****
; ***** RF - pointer to line to write            *****
; ***** RD - File descriptor to write to         *****
; ****************************************************
              proc      writeln

              push      rf             ; save position
              mov       rc,2           ; count starts with 2
count_lp:     lda       rf             ; get byte from line
              lbz       count_dn       ; jump if reached end of line
              inc       rc             ; increment count
              lbr       count_lp       ; keep counting
count_dn:     dec       rf             ; move back to terminator
              ldi       10             ; write cr/lf to line
              str       rf
              inc       rf
              ldi       13
              str       rf
              pop       rf             ; recover original value
              call      o_write        ; write line to file
              rtn                      ; return to caller

              endp

