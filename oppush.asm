#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ********************************************
; ***** OUT instruction, nybble argument *****
; ********************************************
              proc      oppush

              extrn     error
              extrn     getarg
              extrn     output

              call      getarg         ; get argument
              ghi       r7             ; high byte should be zero
              lbnz      bad            ; jump if not zero
              glo       r7             ; should be 1-15
              ani       0f0h
              lbz       good           ; jump if in range
bad:          call      o_inmsg        ; display error
              db        'Error: Argument out of range',10,13,0
              call      error          ; call error routine
              rtn                      ; and return to caller
good:         glo       r7             ; get low byte of argument
              stxd
              ori       080h           ; make into GLO
              call      output         ; and output it
              ldi       073h           ; output STXD
              call      output
              irx                      ; recover argument
              ldx
              ori       090h           ; make into GHI
              call      output
              ldi       073h           ; output STXD
              call      output
              rtn                      ; return to caller

              endp

