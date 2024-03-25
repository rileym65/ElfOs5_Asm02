#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      ltrim

              lda       ra             ; get byte from command line
              smi       9              ; check for tab character
              lbz       ltrim          ; jump if so
              smi       23             ; check for space
              lbz       ltrim          ; jump if so
              dec       ra             ; move back to non-space
              rtn                      ; and return to caller

              endp

      
