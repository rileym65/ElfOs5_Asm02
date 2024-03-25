#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ********************************************
; ***** OUT instruction, nybble argument *****
; ********************************************
              proc      oppop

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
              ldi       060h           ; outpu IRX
              call      output
              ldi       072h           ; output LDXA
              call      output
              irx                      ; recover argument
              ldx
              stxd                     ; keep on stack
              ori       0b0h           ; make into PHI
              call      output
              ldi       0f0h           ; output LDX
              call      output
              irx                      ; recover argument
              ldx
              ori       0a0h           ; make into PLO
              call      output         ; and output it
              rtn                      ; return to caller

              endp

