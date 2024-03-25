#include      macros.inc

; ****************************************************
; ***** Check character for label character      *****
; ***** D - character to check                   *****
; ***** Returns: DF=1 - char is valid label char *****
; *****          DF=0 - Char is not valid        *****
; ****************************************************
              proc      labelchar

              plo       re             ; save original character
              smi       48             ; check if below digits
              lbnf      nope           ; good if not a label character

              smi       10             ; check if in range of numbers
              lbnf      good           ; if number, not valid

              smi       7              ; check if below uppercase
              lbnf      nope           ; if number, not valid

              smi       26             ; check if in range of uppercase
              lbnf      good           ; if number, not valid

              smi       4              ; check for underscore
              lbz       good           ; still a label character

              smi       2              ; check if below lowercase
              lbnf      nope           ; not label character
              smi       26             ; check if in range of letters
              lbdf      nope
good:         smi       0              ; signal is label character
              glo       re             ; recover original character
              rtn                      ; and return
nope:         adi       0              ; clear DF to indicate not label char
              glo       re             ; recover original character
              rtn                      ; and return

              endp

; 0 - 48  $30
; 9 - 57  $39
; 
; A - 65  $41
; Z - 90  $5A
;
; _ - 95  $5F
; 
; a - 97  $61
; z - 122 $7a

