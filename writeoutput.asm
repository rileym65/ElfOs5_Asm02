#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ******************************************************
; ***** Write assembler output to destination file *****
; ******************************************************
              proc      writeoutput

              extrn     address
              extrn     load_d
              extrn     load_rd
              extrn     load_rf
              extrn     objfildes
              extrn     outaddress
              extrn     outbytes
              extrn     outcount
              extrn     outline
              extrn     pass
              extrn     save_d
              extrn     save_rf

              push      rf
              hlpr      load_d,pass    ; check for assembly pass
              smi       1              ; no output on pass 1
              lbz       cleanup        ; jump if on pass 1
              hlpr      load_d,outcount ; check if bytes have been output
              lbz       cleanup        ; jump if not
              push      rd             ; save source fildes
              mov       rf,outline     ; point to output line
              ldi       ':'            ; fist character of data line
              str       rf             ; store into line buffer
              inc       rf
              hlpr      load_rd,outaddress ; get address
              call      f_hexout4      ; write address to output line
              mov       r7,outbytes    ; point to output bytes
              hlpr      load_d,outcount ; number of bytes
              plo       rc             ; rc will keep track
loop:         ldi       ' '            ; write a space to the output
              str       rf
              inc       rf
              lda       r7             ; get next output byte
              plo       rd             ; place for conversion
              call      f_hexout2      ; convert and output
              dec       rc             ; decrement count
              glo       rc             ; see if done
              lbnz      loop           ; loop until all bytes have been output
              ldi       10             ; write line terminator
              str       rf
              inc       rf
              ldi       13
              str       rf
              inc       rf
              ldi       0
              str       rf
              mov       rc,outline     ; compute byte count
              glo       rc
              str       r2
              glo       rf
              sm
              plo       rc
              ghi       rc
              str       r2
              ghi       rf
              smb
              phi       rc             ; now have count of bytes to write
              mov       rf,outline     ; point to line to write
              mov       rd,objfildes   ; point to object fildes
              call      o_write        ; write to disk
              pop       rd             ; recover source fildes
cleanup:      ldi       0              ; clear outcount
              hlpr      save_d,outcount
              hlpr      load_rf,address ; set new out address
              hlpr      save_rf,outaddress
              pop       rf
              rtn                      ; return to caller

              endp

