#include      macros.inc
#include      kernel.inc

; *******************************************
; ***** Add label                       *****
; ***** RF - pointer to label name      *****
; ***** RA - label value                *****
; ***** RB.0 - label flags              *****
; *****        bit 1 - external         *****
; *****        bit 2 - public           *****
; ***** Returns: DF=0 - label added     *****
; *****          DF=1 - duplicate label *****
; *******************************************
              proc      addlabel

              extrn     checkeom
              extrn     error
              extrn     findlabel
              extrn     load_d
              extrn     nextlabel
              extrn     pass

              hlpr      load_d,pass    ; get current pass
              smi       2              ; do not add in pass 2
              lbz       return
              push      ra             ; save registers
              push      rb
              push      rf
              call      findlabel      ; see if label exists
              pop       rf             ; recover registers
              pop       rb
              pop       ra
              lbnf      duplicate      ; jump if duplicate label
              mov       r7,nextlabel   ; need to end of label table
              lda       r7             ; retrieve it
              phi       r8
              ldn       r7
              plo       r8
copy_name:    lda       rf             ; get byte from name
              str       r8             ; store into table
              inc       r8
              lbnz      copy_name      ; loop until terminator copied
              dec       r8             ; point to terminator
              dec       r8             ; point to last character
              ldn       r8             ; retrieve last character
              ori       080h           ; set high bit
              str       r8             ; and put it back
              inc       r8
              glo       rb             ; save label flags
              str       r8
              inc       r8
              ghi       ra             ; store label value
              str       r8
              inc       r8
              glo       ra
              str       r8
              inc       r8
              ldi       0              ; write new table terminator
              str       r8
              glo       r8             ; write new table end
              str       r7
              dec       r7
              ghi       r8
              str       r7
return:       lbr       checkeom       ; check for out of memory
duplicate:    call      o_inmsg        ; display duplicate error
              db        'Error: Duplicate label: ',0
              call      o_msg          ; display label
              call      o_inmsg        ; followed by cr/lf
              db        10,13,0
              lbr       error          ; jump to error routine

              endp

