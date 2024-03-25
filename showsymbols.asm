#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      showsymbols

              extrn     buffer
              extrn     labels

              call      o_inmsg        ; Display header
              db        'Symbols:',10,13,0
              mov       r7,labels      ; point to labels
loop:         ldn       r7             ; get byte from labels
              lbz       done           ; jump if all done
              call      o_inmsg        ; indent
              db        '  ',0
              mov       rc,20          ; 20 bytes per label
nameloop:     lda       r7             ; get byte from name
              shl                      ; get high bit
              lbdf      namedone       ; jump if done with name
              shr                      ; shift back for display
              call      o_type         ; display character
              dec       rc             ; decrement count
              lbr       nameloop       ; loop until done
namedone:     shr                      ; shift back to display last character
              call      o_type         ; display it
padloop:      glo       rc             ; see if enough characters displayed
              lbz       paddone        ; jump if done with padding
              ldi       ' '            ; display a space
              call      o_type
              dec       rc             ; decrement count
              lbr       padloop        ; loop until 20 characters displayed
paddone:      inc       r7             ; move past symbol flags
              lda       r7             ; retrieve symbol value
              phi       rd
              lda       r7
              plo       rd
              mov       rf,buffer      ; where to put translation
              call      f_hexout4      ; conver to hex
              ldi       0              ; terminate it
              str       rf
              mov       rf,buffer      ; point to ASCII hex
              call      o_msg          ; and display it
              call      o_inmsg        ; display cr/lf
              db        10,13,0
              lbr       loop           ; loop until all labels shown
done:         call      o_inmsg        ; display cr/lf
              db        10,13,0
              rtn                      ; then return to caller

              endp

