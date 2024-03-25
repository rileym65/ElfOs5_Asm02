#include      macros.inc
#include      bios.inc
#include      kernel.inc

; *******************************************
; ***** Add label                       *****
; ***** RF - pointer to define name     *****
; ***** RA - pointer to define value    *****
; ***** Returns: DF=0 - label added     *****
; *****          DF=1 - duplicate label *****
; *******************************************
              proc      adddefine

              extrn     defines
              extrn     error
              extrn     finddefine
              extrn     load_r8
              extrn     save_r8

              push      r7
              push      ra             ; save positions
              push      rf
              call      finddefine     ; see if define already exists
              pop       rf             ; recover positions
              pop       ra
              lbdf      notfound       ; jump if define does not exist
              call      o_inmsg        ; display error
              db        'Error: Duplicate define',10,13,0
              call      error
              smi       1              ; signal duplicate define
              pop       r7
              rtn                      ; and return
notfound:     mov       rc,2           ; size starts at 2
              mov       r7,rf          ; point to define name
loop_1:       lda       r7             ; get byte from define name
              lbz       done_1         ; jump if done with name
              inc       rc             ; increment size
              lbr       loop_1         ; loop until end of name
done_1:       mov       r7,ra          ; point to value
loop_2:       lda       r7             ; get byte from value
              lbz       done_2         ; jump if done
              inc       rc             ; increment count
              lbr       loop_2         ; loop until done with value
done_2:       hlpr      load_r8,defines ; get start of defines table
              glo       rc             ; subtract count
              str       r2
              glo       r8
              sm
              plo       r8
              ghi       rc
              str       r2
              ghi       r8
              smb
              phi       r8
              hlpr      save_r8,defines ; save new start
copy_1:       lda       rf              ; get byte from name
              lbz       copy_1dn        ; jump if end of name
              str       r8              ; store into table
              inc       r8
              lbr       copy_1          ; loop until name copied
copy_1dn:     ldi       '|'             ; add separator
              str       r8
              inc       r8
copy_2:       lda       ra              ; copy value into define table
              lbz       copy_2dn        ; jump if done
              str       r8
              inc       r8
              lbr       copy_2          ; loop until value copied
copy_2dn:     ldi       0               ; terminate entry
              str       r8
              adi       0               ; indicate success
              pop       r7
              rtn                       ; and return to caller

              endp

