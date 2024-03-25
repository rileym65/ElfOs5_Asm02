#include      macros.inc

; ******************************************************
; ***** 16-bit multiply                            *****
; ***** RC - first number                          *****
; ***** RD - second number                         *****
; ***** Returns: RC - result                       *****
; ******************************************************
              proc    mul16

              extrn   mdnorm16

              push    rf               ; save consumed register
              call    mdnorm16         ; Make both numbers positive
              plo     re               ; save sign difference for now
              ldi     0                ; clear result in RF
              phi     rf
              plo     rf
mulloop:      glo     rd               ; check if multiplier is zero
              lbnz    mulcont          ; jump if not
              ghi     rd               ; check high byte too
              lbnz    mulcont          ; if zero, then multiply is done
              glo     re               ; retrieve sign difference
              shr                      ; shift into DF
              lbnf    mulexit          ; if like signs then all done
              glo     rf               ; otherwise 2's comp. the result
              xri     0ffh
              plo     rf
              ghi     rf
              xri     0ffh
              phi     rf
              inc     rf
mulexit:      mov     rc,rf            ; move answer to rc
              pop     rf               ; recover consumed register
              rtn                      ; and return to caller
mulcont:      ghi     rd               ; shift multiplier to the right
              shr
              phi     rd
              glo     rd
              shrc
              plo     rd
              lbnf    mulcont2         ; if low bit was 0, then no add
              glo     rc               ; otherwise add multiplicand to result
              str     r2
              glo     rf
              add
              plo     rf
              ghi     rc
              str     r2
              ghi     rf
              adc
              phi     rf
mulcont2:     glo     rc               ; shift multiplicand left
              shl
              plo     rc
              ghi     rc
              shlc
              phi     rc
              lbr     mulloop          ; then loop back for next bit

              endp
