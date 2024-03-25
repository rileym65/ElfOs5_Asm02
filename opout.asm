#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ********************************************
; ***** OUT instruction, nybble argument *****
; ********************************************
              proc      opout

              extrn     error
              extrn     getarg
              extrn     output

              call      getarg         ; get argument
              ghi       r7             ; high byte should be zero
              lbnz      opout_bad      ; jump if not zero
              glo       r7             ; should be 0-7
              ani       0f8h
              lbnz      opout_bad      ; jump if in range
              glo       r7
              ani       7
              lbnz      opoutgood      ; jump if 1-7
opout_bad:    call      o_inmsg        ; display error
              db        'Error: Argument out of range',10,13,0
              call      error          ; call error routine
              rtn                      ; and return to caller
opoutgood:    glo       r7             ; get low byte of argument
              ani       7              ; create OUT instruction
              ori       060h
              call      output         ; and output it
              rtn                      ; return to caller

              endp

