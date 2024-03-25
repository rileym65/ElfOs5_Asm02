#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ********************************************
; ***** ever version informaton          *****
; ********************************************
              proc      opever

              extrn     build
              extrn     output

              mov       r8,k_month     ; point to build month
              lda       r8             ; read month
              ori       080h           ; mark as extended ver data
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
              mov       r8,build       ; point to build number
              lda       r8             ; output build information
              call      output
              lda       r8
              call      output
              rtn                      ; then return to caller

              endp

