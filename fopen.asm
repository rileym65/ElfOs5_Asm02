#include      macros.inc
#include      bios.inc
#include      kernel.inc

; *******************************************
; ***** Open file                       *****
; ***** RF - Filename                   *****
; ***** RD - File descriptor            *****
; ***** R7 - File flags                 *****
; ***** Returns: DF=0 - File was opened *****
; *****          DF=1 - Failed          *****
; *******************************************
              proc      fopen

              push      r7             ; save consumed registers
              push      r8
              glo       rd             ; point to FILDES
              adi       102
              plo       r8
              ghi       rd
              adci      0
              phi       r8
              inc       rd             ; move to DTA field
              inc       rd
              inc       rd
              inc       rd
              ghi       r8             ; write DTA address
              str       rd
              inc       rd
              glo       r8
              str       rd
              inc       rd
              inc       rd             ; move past EOF
              inc       rd
              ldi       0              ; clear flags
              str       rd
              glo       rd             ; move RD back
              smi       8
              plo       rd
              ghi       rd
              smbi      0
              phi       rd
              call      o_open         ; open the file
              lbnf      opened         ; jump if good
              plo       re
return:       pop       r8             ; recover consumed registers
              pop       r7
              glo       re
              rtn                      ; and return to caller
opened:       glo       rd             ; need to point to readln data
              adi       19
              plo       r7
              plo       r8
              ghi       rd
              adci      0
              phi       r7
              phi       r8
              inc       r8             ; buffer is 3 higher
              inc       r8
              inc       r8
              ldi       0              ; indicate no bytes remaining
              str       r7
              inc       r7
              ghi       r8             ; store buffer address
              str       r7
              inc       r7
              glo       r8
              str       r7
              lbr       return         ; then return to caller

              endp

;  00- 18 - Standard FILDES
;      19 - Bytes remaining in buffer
;  20- 21 - Buffer pointer
;  22-101 - Line buffer (80 bytes)
; 102-613 - DTA

