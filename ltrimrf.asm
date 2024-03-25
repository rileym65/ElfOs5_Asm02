#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      ltrimrf

              lda       rf             ; get byte from command line
              smi       9              ; check for tab character
              lbz       ltrimrf        ; jump if so
              smi       23             ; check for space
              lbz       ltrimrf        ; jump if so
              dec       rf             ; move back to non-space
              rtn                      ; and return to caller

              endp

      
