#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ***********************************************
; ***** Search a string for another string  *****
; ***** RF - Pointer to string              *****
; ***** RA - Pointer to search string       *****
; ***** Returns: DF=1 - found               *****
; *****            RF - Found position      *****
; *****            RA - after search string *****
; *****            RC - count of bytes      *****
; *****          DF=0 - not found           *****
; ***********************************************
              proc      strstr

              extrn     labelchar

              push      ra             ; save original positions
              push      rf
loop_1:       ldn       rf             ; see if hit end of string
              lbz       failed         ; jump if so
entry:        push      ra             ; save positions
              push      rf
              mov       rc,0           ; clear count
loop_2:       lda       ra             ; get byte from search
              plo       re             ; keep a copy
              smi       '|'            ; is it define separator
              lbz       checkend       ; jump if so
              glo       re             ; get byte for compare
              str       r2             ; store for compare
              lda       rf             ; get byte from string
              sm                       ; and compare
              lbnz      nope           ; jump if no match
              inc       rc             ; increment count
              lbr       loop_2         ; loop until failure or end of define
nope:         pop       rf             ; recover positions
              pop       ra
              inc       rf             ; move to next character
              lbr       loop_1         ; and try search again
checkend:     lda       rf             ; get byte from string
              call      labelchar      ; is it a label character
              lbdf      nope           ; failure if it is
              pop       rf             ; want starting position of match
              irx                      ; remove ra from the stack
              irx
              irx                      ; remove original valus
              irx
              irx
              irx
              smi       0              ; signal found
              rtn                      ; and return to caller
failed:       pop       rf             ; recover registers
              pop       ra
              adi       0              ; signal not found
              rtn                      ; and return

              endp

