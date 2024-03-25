#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      appendext

              lda       rf             ; need to find . or terminator
              lbz       found          ; jump if terminator
              smi       '.'            ; check for dot
              lbnz      appendext      ; loop until found
found:        dec       rf             ; move back
copyext:      lda       r6             ; read byte from inline extension
              str       rf             ; write to filename
              inc       rf
              lbnz      copyext        ; loop until terminator copied
              rtn                      ; return to caller

              endp

