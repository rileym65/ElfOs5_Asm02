#include      macros.inc
#include      bios.inc
#include      kernel.inc

; *************************************************
; ***** Replace string with another           *****
; ***** RF - pointing to point of replacement *****
; ***** RC - count of characters to replace   *****
; ***** RA - New string                       *****
; *************************************************
              proc      replace

              extrn     outline

              push      rf             ; save original position
              glo       rc             ; find next position
              str       r2
              glo       rf
              add
              plo       rf
              ghi       rc
              str       r2
              ghi       rf
              adc
              phi       rf
              mov       rb,outline     ; will use this buffer
copy_lp1:     lda       ra             ; get byte from replacement
              str       rb             ; write to buffer
              inc       rb
              lbnz      copy_lp1       ; loop until terminator copied
              dec       rb             ; move back to terminator character
copy_lp2:     lda       rf             ; now copy rest of string
              str       rb
              inc       rb
              lbnz      copy_lp2       ; loop until terminator copied
              pop       rf             ; recover original position
              push      rf             ; and keep on stack
              mov       rb,outline     ; point to newly constructed string
copy_lp3:     lda       rb             ; copy string
              str       rf
              inc       rf
              lbnz      copy_lp3       ; copy until terminator copied
              pop       rf             ; recover original position
              rtn                      ; and return to caller

              endp

