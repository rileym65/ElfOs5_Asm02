#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      writelocal

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
              plo       re             ; save a copy
              smi       '?'            ; check for 16-bit
              lbnz      not_qm         ; jump if not
              ldi       '+'            ; change to local 16-bit
              lbr       writetype      ; and write type
not_qm:       glo       re             ; recover type
              smi       '/'            ; check for high byte
              lbnz      not_hi         ; jump if not
              ldi       '^'            ; change for local
              lbr       writetype
not_hi:       glo       re             ; recover type
              smi       '\'            ; check for low
              lbnz      writetype
              ldi       'v'
writetype:    str       rf             ; store into buffer
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
