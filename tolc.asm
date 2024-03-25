#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      tolc

              plo       re             ; save character
              smi       'A'            ; check for below uppercase
              lbnf      done           ; jump if not
              smi       26             ; see if above uppercase
              lbdf      done           ; jump if so
              glo       re             ; recover character
              adi       32             ; convert to lc
              rtn                      ; and return
done:         glo       re             ; recover character
              rtn                      ; and return

              endp

