#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      opdw

              extrn     error
              extrn     getarg
              extrn     ltrimrf
              extrn     output

loop:         call      ltrimrf        ; move past any spaces
              ldn       rf             ; get byte from argument
              smi       027h           ; check for single quote
              lbnz      not_sqt        ; jump if not
              call      o_inmsg        ; display error
              db        'Error: Invalid argument',10,13,0
              call      error          ; call error routine
              rtn                      ; and return to caller
not_sqt:      ldn       rf             ; get byte from argument
              smi       '"'            ; check for double quote
              lbnz      not_dqt        ; jump if not
              call      o_inmsg        ; display error
              db        'Error: Invalid argument',10,13,0
              call      error          ; call error routine
              rtn                      ; and return to caller
not_dqt:      call      getarg         ; otherwise get argument
              ghi       r7             ; output argument
              call      output
              glo       r7
              call      output
endentry:     call      ltrimrf        ; move past any spaces
              lda       rf             ; check for comma
              smi       ','
              lbz       loop           ; more entries to process
              rtn                      ; return to caller

              endp

