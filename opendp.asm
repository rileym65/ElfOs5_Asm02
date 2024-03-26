#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      opendp

              extrn     buffer
              extrn     addlabel
              extrn     labelchar
              extrn     load_d
              extrn     ltrimrf
              extrn     objfildes
              extrn     pass
              extrn     writeln
              extrn     writeoutput

              call      writeoutput    ; write any remaining output
              mov       ra,buffer      ; point to buffer
              ldi       '}'            ; write proc marker
              str       ra
              inc       ra
              ldi       0              ; terminate name
              str       ra
              hlpr      load_d,pass    ; get pass
              smi       1              ; check for pass 1
              lbz       return         ; jump if pass 1
              mov       rf,buffer      ; point to buffer
              mov       rd,objfildes   ; point to fildes
              call      writeln        ; write out record
return:       rtn                      ; then return to caller

              endp

