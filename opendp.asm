#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      opendp

              extrn     buffer
              extrn     addlabel
              extrn     dopublics
              extrn     labelchar
              extrn     load_d
              extrn     ltrimrf
              extrn     objfildes
              extrn     pass
              extrn     save_ra
              extrn     scope
              extrn     writeln
              extrn     writeoutput

              call      writeoutput    ; write any remaining output
              hlpr      load_d,pass    ; get pass
              smi       1              ; check for pass 1
              lbz       return         ; jump if pass 1
              call      dopublics      ; write public symbols for proc
              mov       ra,buffer      ; point to buffer
              ldi       '}'            ; write proc marker
              str       ra
              inc       ra
              ldi       0              ; terminate name
              str       ra
              mov       rf,buffer      ; point to buffer
              mov       rd,objfildes   ; point to fildes
              call      writeln        ; write out record
              mov       ra,0           ; clear scope
              hlpr      save_ra,scope
return:       rtn                      ; then return to caller

              endp

