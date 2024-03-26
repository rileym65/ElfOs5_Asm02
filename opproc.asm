#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      opproc

              extrn     address
              extrn     buffer
              extrn     addlabel
              extrn     labelchar
              extrn     load_d
              extrn     load_r8
              extrn     ltrimrf
              extrn     nextlabel
              extrn     objfildes
              extrn     outaddress
              extrn     pass
              extrn     save_r8
              extrn     save_rf
              extrn     scope
              extrn     writeln

              call      ltrimrf        ; move past any spaces
              mov       ra,buffer      ; point to buffer
              ldi       '{'            ; write proc marker
              str       ra
              inc       ra
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
              inc       rf
              ldi       12             ; label flag is proc/local
              plo       rb
              hlpr      load_r8,nextlabel ; get address of next label
              hlpr      save_r8,scope  ; set scrope
              ldi       0              ; proc address is zero
              phi       ra
              plo       ra
              call      addlabel       ; add the label
              ldi       0              ; set address to zero
              phi       rf
              plo       rf
              hlpr      save_rf,address
              hlpr      save_rf,outaddress
              hlpr      load_d,pass    ; get pass
              smi       1              ; check for pass 1
              lbz       return         ; jump if pass 1
              mov       rf,buffer      ; point to buffer
              mov       rd,objfildes   ; point to fildes
              call      writeln        ; write out record
return:       rtn                      ; then return to caller

              endp

