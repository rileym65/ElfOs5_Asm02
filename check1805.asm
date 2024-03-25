#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ******************************************
; ***** Check if 1805 flag is active   *****
; ***** Returns: DF=1 1805 allowed     *****
; *****          DF=0 1805 not allowed *****
; ******************************************
              proc      check1805

              extrn     F_1805
              extrn     flags
              extrn     load_d

              hlpr      load_d,flags   ; get flags
              ani       F_1805         ; keep only 1805 flag
              lbnz      yes            ; jump if allowed
              adi       0              ; signal not allowed
              rtn                      ; and return
yes:          smi       0              ; signal allowed
              rtn                      ; and return

              endp

