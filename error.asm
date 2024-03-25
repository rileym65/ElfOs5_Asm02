#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      error

              extrn     buffer
              extrn     errors
              extrn     itoa16
              extrn     line
              extrn     linecount
              extrn     load_rf
              extrn     save_rf

              hlpr      load_rf,errors ; get error count
              inc       rf             ; increment error count
              hlpr      save_rf,errors ; and put it back
              call      o_inmsg
              db        '[',0
              hlpr      load_rf,linecount
              mov       rc,rf          ; move line count
              mov       rd,buffer      ; point to list line
              call      itoa16         ; convert to ascii
              ldi       0              ; terminate conversion
              mov       rf,buffer      ; display line number
              call      o_msg
              call      o_inmsg
              db        '] -->',0
              mov       rf,line        ; point to input line
              call      o_msg          ; and display it
              call      o_inmsg
              db        10,13,10,13,0
              rtn                      ; return to caller

              endp
