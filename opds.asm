#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ********************************************
; ***** OUT instruction, nybble argument *****
; ********************************************
              proc      opds

              extrn     address
              extrn     getarg
              extrn     load_rf
              extrn     outaddress
              extrn     save_rf
              extrn     writeoutput

              call      writeoutput    ; check and write any output
              call      getarg         ; get argument
              hlpr      load_rf,address ; get current assembly address
              glo       r7             ; add in storage
              str       r2
              glo       rf
              add
              plo       rf
              ghi       r7
              str       r2
              ghi       rf
              adc
              phi       rf
              hlpr      save_rf,address ; write new assembly address
              hlpr      save_rf,outaddress ; and new out address
              rtn                      ; return to caller

              endp

