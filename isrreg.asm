#include      macros.inc
#include      bios.inc
#include      kernel.inc

; *****************************************************
; ***** Is RF pointing to an R register reference *****
; ***** RF - pointer to text                      *****
; ***** Returns: DF=0 - not pointing to r reg     *****
; *****          DF=1 - Is R reg reference        *****
; *****             D - R register index          *****
; *****            RF - Following R reg ref.      *****
; *****************************************************
              proc      isrreg

              extrn     checkrange
              extrn     labelchar
              extrn     tohex

              push      rf            ; save position
              ldn       rf            ; get first character
              smi       'R'           ; check for uppercase R
              lbz       is_r          ; jump if so
              smi       32            ; check for lowercase r
              lbnz      not_rreg      ; jump if not
is_r:         inc       rf            ; move past R
              ldn       rf            ; get next byte
              smi       '1'           ; check for 1
              lbz       is_1          ; jump if so
              lda       rf            ; recover byte
              call      tohex         ; convert value to hex
              lbdf      not_rreg      ; if not valid hex, not r reg
check_next:   stxd                    ; save this value
              ldn       rf            ; get next character
              call      labelchar     ; check for label character
              irx                     ; recover binary value
              ldx
              lbdf      not_rreg      ; not r register if label character
return:       irx                     ; remove rf from stack
              irx
              smi       0             ; indicate R register reference
              rtn                     ; and return to caller
is_1:         inc       rf            ; move past '1'
              lda       rf            ; get next character
              call      checkrange    ; see if 0 through 5
              db        '0','5'
              lbdf      above_9       ; jump if possible 10-15
              call      labelchar     ; see if a label character
              lbdf      not_rreg      ; not r reg if label character
              dec       rf
              ldi       1             ; result is 1
              lbr       return        ; return to caller
above_9:      smi       38            ; convert to binary
              lbr       check_next    ; then check next character
not_rreg:     pop       rf            ; recover original RF
              adi       0             ; signal not r reg reference
              rtn                     ; and return to caller

              endp

