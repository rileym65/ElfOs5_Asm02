#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ********************************************
; ***** OUT instruction, nybble argument *****
; ********************************************
              proc      opver

              extrn     output

              mov       r8,k_month     ; point to build month
              lda       r8             ; read month
              call      output         ; and output it
              lda       r8             ; get day
              call      output         ; and output it
              lda       r8             ; get year
              adi       0b4h           ; add 1972
              plo       r7
              ldi       0
              adci      07h
              call      output         ; output high byte of year
              glo       r7             ; then output low byte
              call      output
              rtn                      ; then return to caller

              endp

