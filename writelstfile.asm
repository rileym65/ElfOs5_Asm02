#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      writelstfile

              extrn     incopy
              extrn     lstfildes
              extrn     lstline

              mov       rf,lstline     ; point to list line
              mov       rc,0           ; need to count bytes
countloop:    lda       rf             ; get byte from line
              lbz       countdone      ; jump if done with count
              inc       rc             ; increment count
              lbr       countloop      ; count until terminator found
countdone:    dec       rf             ; move back to terminator
              op        incopy         ; add cr/lf
              db        10,13,0
              inc       rc             ; account for cr/lf in length
              inc       rc
              mov       rf,lstline     ; point  back to lst line
              mov       rd,lstfildes   ; point to lst fildes
              call      o_write        ; and write to file
              rtn                      ; return to caller

              endp

