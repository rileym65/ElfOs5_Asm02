#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      oppublic

              extrn     error
              extrn     findlabel
              extrn     ltrimrf

              call      ltrimrf        ; move past any spaces
              call      findlabel      ; search for specified label
              lbnf      found          ; jump if label was found
              call      o_inmsg        ; display error
              db        'Error: Label not found',10,13,0
              call      error
              rtn                      ; return to caller
found:        ldn       ra             ; retrieve flags
              ori       2              ; set public flag
              str       ra             ; and put it back
              rtn                      ; return to caller

              endp

