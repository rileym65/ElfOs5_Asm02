#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      writeextrn

              extrn     address
              extrn     buffer
              extrn     extrnlabel
              extrn     extrntype
              extrn     load_d
              extrn     load_ra
              extrn     load_rd
              extrn     objfildes
              extrn     pass
              extrn     writeln

              hlpr      load_d,pass    ; what pass are we on
              smi       2              ; only output if pass 2
              lbz       pass_2         ; jump if on pass 2
              rtn                      ; otherwise return to caller
pass_2:       push      ra             ; save consumed registers
              push      rd
              push      rf
              mov       rf,buffer      ; point to buffer
              hlpr      load_d,extrntype ; get extrn type
              str       rf             ; store into buffer
              inc       rf
              hlpr      load_ra,extrnlabel ; point to external label
name_lp:      lda       ra             ; get byte from label
              shl                      ; see if final character
              lbdf      name_lst       ; jump if so
              shr                      ; shift back
              str       rf             ; write to output line
              inc       rf
              lbr       name_lp        ; loop until done
name_lst:     shr                      ; shift character back
              str       rf             ; write to output buffer
              inc       rf
              ldi       ' '            ; write a space to the buffer
              str       rf
              inc       rf
              hlpr      load_rd,address ; get current assembly address
              call      f_hexout4      ; conver to ascii
              ldi       0              ; terminate line
              str       rf
              mov       rf,buffer      ; point to reference line
              mov       rd,objfildes   ; point to output fildes
              call      writeln        ; and write
return:       pop       rf             ; recover consumed registers
              pop       rd
              pop       ra
              rtn                      ; and return to caller

              endp
