#include      macros.inc
#include      bios.inc
#include      kernel.inc

; **************************************
; ***** Check if D within a range  *****
; ***** D - value to check         *****
; ***** Range is inline, low first *****
; ***** Returns: DF=1 is in range  *****
; *****          DF=0 not in range *****
; **************************************
              proc      checkrange

              plo       re             ; save D
              lda       r6             ; get low range
              str       r2             ; store for compare
              glo       re             ; get D
              sm                       ; and compare
              lbnf      nope1          ; jump if below range
              lda       r6             ; get high range
              adi       1              ; plus 1
              str       r2             ; store for compare
              glo       re             ; recover D
              sm                       ; and compare
              lbdf      nope2          ; jump if D is too high
              smi       0              ; indicate value in range
              glo       re             ; recover D
              rtn                      ; and return
nope1:        inc       r6             ; move past high range
nope2:        adi       0              ; indicate not in range
              glo       re             ; recover D
              rtn                      ; and return

              endp

