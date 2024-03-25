#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ********************************************
; ***** OUT instruction, nybble argument *****
; ********************************************
              proc      opldn

              extrn     error
              extrn     getarg
              extrn     output

              call      getarg         ; get argument
              ghi       r7             ; high byte should be zero
              lbnz      opldn_bad      ; jump if not zero
              glo       r7             ; should be 1-15
              ani       0f0h
              lbnz      opldn_bad      ; jump if in range
              glo       r7
              lbnz      opldngood      ; jump if 1-15
opldn_bad:    call      o_inmsg        ; display error
              db        'Error: Argument out of range',10,13,0
              call      error          ; call error routine
              rtn                      ; and return to caller
opldngood:    glo       r7             ; get low byte of argument
              call      output         ; and output it
              rtn                      ; return to caller

              endp

