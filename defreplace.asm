#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      defreplace

              extrn     defines
              extrn     load_ra
              extrn     replace
              extrn     strstr

              push      rf             ; save original position
              hlpr      load_ra,defines ; point to defines table
loop_1:       ldn       ra             ; see if at end of table
              lbz       done           ; jump if no more defines
              push      ra             ; save entry position
              push      rf             ; save line position
              call      strstr         ; Search for current entry in input
              lbnf      notfound       ; jump if not found
              call      replace        ; replace the characters
              pop       rf             ; recover original line
              pop       ra             ; recover entry
              lbr       loop_1         ; and see if more matches
notfound:     pop       rf             ; recover entry
              pop       ra             ; recover original position
loop_2:       lda       ra             ; find end of current entry
              lbnz      loop_2         ; loop until terminator entry found
              lbr       loop_1         ; then search next entry
done:         pop       rf             ; recover original pointer
              rtn                      ; Return to caller

              endp

