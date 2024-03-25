#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      opextrn

              extrn     buffer
              extrn     addlabel
              extrn     labelchar
              extrn     ltrimrf

              call      ltrimrf        ; move past any spaces
              mov       ra,buffer      ; point to buffer
name_lp:      lda       rf             ; get byte from name
              call      labelchar      ; is it a label character
              lbnf      name_dn        ; jump if done with name
              str       ra             ; store into buffer
              inc       ra
              lbr       name_lp        ; loop until name copied
name_dn:      ldi       0              ; terminate name
              str       ra
              phi       ra             ; set label value to zero
              plo       ra
              mov       rf,buffer      ; point to label name
              ldi       1              ; label flag is external
              plo       rb
              call      addlabel       ; add the label
              rtn                      ; then return to caller

              endp

