#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ********************************************
; ***** String compare to inline         *****
; ***** RF - pointer to string           *****
; *****      comparison string is inline *****
; ***** Returns: DF=1 - match            *****
; *****            RF - follows match    *****
; *****          DF=0 - no match         *****
; *****            RF - original value   *****
; ********************************************
              proc      strcasecmpin

              extrn     tolc

              push      rf             ; save original position
loop:         lda       r6             ; get next byte from inline
              lbz       done           ; jump if end of string
              call      tolc           ; convert to lowercase
              stxd                     ; save it
              lda       rf             ; get byte from string
              call      tolc           ; convert to lowercase
              irx                      ; point back to inline character
              sm                       ; and compare
              lbz       loop           ; loop until terinator or fail
fail_lp:      lda       r6             ; find inline terminator
              lbnz      fail_lp
              pop       rf             ; recover original value
              adi       0              ; signal no match
              rtn                      ; and return
done:         smi       0              ; signal match
              irx                      ; remove rf from stack
              irx
              rtn                      ; and return

              endp

