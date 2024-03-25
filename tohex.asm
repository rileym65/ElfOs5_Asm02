#include      macros.inc
#include      bios.inc
#include      kernel.inc

; *****************************************
; ***** Convert ASCII hex to binary   *****
; ***** D - ASCII hex digit           *****
; ***** Returns: DF=0 - valid digit   *****
; *****             D - binary value  *****
; *****          DF=1 - invalid digit *****
; *****************************************
              proc      tohex

              extrn     checkrange

              call      checkrange     ; check '0' through '9'
              db        '0','9'
              lbnf      notnumeral     ; jump if not numeral
              smi       '0'            ; convert to binary
good:         adi       0              ; signal valid digit
              rtn                      ; and return
notnumeral:   call      checkrange     ; check 'A' through 'F'
              db        'A','F'
              lbnf      not_uc         ; jump if not uppercase
              smi       55             ; conver to binary
              lbr       good           ; and return with good result
not_uc:       call      checkrange     ; check 'a' through 'f'
              db        'a','f'
              lbnf      not_hex        ; jump if not hex digit
              smi       87             ; convert to binary
              lbr       good           ; and return with good result
not_hex:      smi       0              ; indicate invalid digit
              rtn                      ; and return

              endp
