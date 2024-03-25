#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      dopublics

              extrn     buffer
              extrn     objfildes
              extrn     labels
              extrn     writeln

              mov       ra,labels      ; get address of label table
loop:         ldn       ra             ; see if done
              lbz       return         ; jump if no more labels
              mov       rf,buffer      ; point to buffer
              ldi       '='            ; add equate marker
name_lp:      str       rf
              inc       rf
              lda       ra             ; get byte from symbol name
              shl                      ; see if final character
              lbdf      final          ; jump if so
              shr                      ; shift symbol back
              lbr       name_lp        ; store and continue
final:        shr                      ; shift symbol back
              str       rf             ; store into buffer
              inc       rf
              lda       ra             ; retrieve flags
              ani       2              ; check for public flag
              lbz       notpublic      ; jump if not public
              ldi       ' '            ; add a space
              str       rf
              inc       rf
              lda       ra             ; retrieve symbol value
              phi       rd
              lda       ra
              plo       rd
              call      f_hexout4      ; convert to ascii
              ldi       0              ; terminate line
              str       rf
              mov       rf,buffer      ; point to buffer
              mov       rd,objfildes   ; point to fildes
              call      writeln        ; write out record
              lbr       loop           ; loop for any more labels
notpublic:    inc       ra             ; move past address
              inc       ra
              lbr       loop           ; and check next entry
return:       rtn                      ; return to caller

              endp

