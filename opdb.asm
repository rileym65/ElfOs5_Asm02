#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ********************************************
; ***** OUT instruction, nybble argument *****
; ********************************************
              proc      opdb

              extrn     error
              extrn     getarg
              extrn     ltrimrf
              extrn     output

loop:         call      ltrimrf        ; move past any spaces
              ldn       rf             ; get byte from argument
              smi       027h           ; check for single quote
              lbnz      not_sqt        ; jump if not
              inc       rf             ; move past single quote
              inc       rf             ; check for final single quote
              ldn       rf
              dec       rf             ; move back to character
              smi       027h
              lbnz      sqt_loop
              dec       rf             ; move back to single quote
              lbr       not_sqt
sqt_loop:     lda       rf             ; get byte from input
              plo       re             ; keep a copy
              smi       027h           ; check for end of single quoted text
              lbz       endentry       ; jump if so
              glo       re             ; recover character
              call      output         ; and output it
              lbr       sqt_loop       ; loop until done
not_sqt:      ldn       rf             ; get byte from argument
              smi       '"'            ; check for double quote
              lbnz      not_dqt        ; jump if not
              inc       rf             ; move past single quote
dqt_loop:     lda       rf             ; get byte from input
              plo       re             ; keep a copy
              smi       '"'            ; check for end of single quoted text
              lbz       endentry       ; jump if so
              glo       re             ; recover character
              call      output         ; and output it
              lbr       dqt_loop       ; loop until done
not_dqt:      call      getarg         ; otherwise get argument
              ghi       r7             ; must be a byte
              lbz       db_good
              call      o_inmsg        ; otherwise display error
              db        'Error: Argument out of range',10,13,0
              call      error          ; call error routine
              rtn                      ; then return to caller
db_good:      glo       r7             ; get low byte of value
              call      output         ; and output it
endentry:     call      ltrimrf        ; move past any spaces
              lda       rf             ; check for comma
              smi       ','
              lbz       loop           ; more entries to process
              rtn                      ; return to caller

              endp

