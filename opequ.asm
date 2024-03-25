#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      opequ

              extrn     getarg
              extrn     load_d
              extrn     load_rf
              extrn     nextlabel
              extrn     pass

              hlpr      load_d,pass    ; get pass
              smi       2              ; ignore on pass 2
              lbz       return
              call      getarg         ; get argument
              hlpr      load_rf,nextlabel ; and write new assembly address
              dec       rf             ; move back to msb of value
              dec       rf
              ghi       r7             ; write new value
              str       rf
              inc       rf
              glo       r7
              str       rf
return:       rtn                      ; return to caller

              endp

