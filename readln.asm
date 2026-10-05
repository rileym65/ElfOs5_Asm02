#include      macros.inc
#include      bios.inc
#include      kernel.inc

; *************************************
; ***** Read line                 *****
; ***** RF - where to put it      *****
; ***** RD - File descriptor      *****
; ***** Returns: DF=1 - EOF       *****
; *****          DF=0 - Good read *****
; *************************************
              proc      readln

              extrn     helpers
              extrn     save
              extrn     restore

              push      ra             ; save consumed registers
              push      rb
              push      rc
              push      rf
              push      rd             ; save rd
              glo       rd             ; point to readln data
              adi       19
              plo       rd
              ghi       rd
              adci      0
              phi       rd
              lda       rd             ; get bytes remaining
              plo       rc
              lda       rd             ; get buffer position
              phi       rb
              lda       rd
              plo       rb
              pop       rd             ; recover rd
              mov       ra,0           ; keep a count of bytes
loop:         call      nextbyte       ; read next byte
              lbdf      term           ; jump if eof was hit
              lbz       term           ; jump if 0 was hit
              plo       re             ; keep a copy
              smi       10             ; check for LF
              lbz       eol            ; which is end of line
              smi       3              ; check for CR
              lbz       eol            ; which is also end of line
              glo       re             ; recover byte
              str       rf             ; store into output buffer
              inc       rf
              inc       ra             ; increment byte count
              lbr       loop           ; loop back for another byte
term:         ldi       0              ; terminate line
              str       rf
              glo       ra             ; were any bytes read
              str       r2
              ghi       ra
              or
              lbz       trueeof        ; jump if not
              adi       0              ; signal not eof
return:       shlc                     ; save DF
              plo       re
              push      rd             ; save rd
              glo       rd             ; move to readln data
              adi       19
              plo       rd
              ghi       rd
              adci      0
              phi       rd
              glo       rc             ; save data
              str       rd
              inc       rd
              ghi       rb
              str       rd
              inc       rd
              glo       rb
              str       rd
              pop       rd             ; recover rd
              pop       rf             ; recover consumed registers
              pop       rc
              pop       rb
              pop       ra
              glo       re             ; recover DF
              shr
              rtn                      ; and return
trueeof:      smi       0              ; indicate eof
              lbr       return         ; return to caller
eol:          glo       re             ; recover byte
              ani       3              ; keep only low 2 bits
              str       r2             ; set it aside
eolloop:      dec       r2
              call      nextbyte       ; read next byte
              inc       r2
              lbdf      term           ; jump if eof hit
              lbz       term           ; or if byte was zero
              plo       re             ; save a copy
              smi       10             ; check for LF
              lbz       eol2           ; jump if so
              smi       3              ; check for CR
              lbnz      unread         ; not eol
eol2:         glo       re             ; recover character
              ani       3              ; keep only low 2 bits
              and
              lbnz      unread         ; duplicate so unread and then done
              glo       re             ; combine with prior eol char
              ani       3
              or
              str       r2
              lbr       eolloop         ; loop until duplicate or non-eof
unread:       dec       rb             ; put byte back in read buffer
              glo       re
              str       rb
              inc       rc             ; increment byte count
              inc       ra
              lbr       term           ; and finish line




; ********************************************
; ***** Read 80 bytes from input file    *****
; ***** Returns: DF=1 - EOF hit          *****
; *****          DF=0 - good read        *****
; *****            RB - pointer to bytes *****
; *****            RC - Count of bytes   *****
; ********************************************
nextbyte:     glo       rc             ; are there more bytes
              lbz       rdblk          ; jump if not
readbyte:     lda       rb             ; get next byte from buffer
              dec       rc             ; decrement remaining bytes count
              adi       0              ; signal byte was found
              rtn                      ; and return
rdblk:        push      rf             ; save buffer position
              mov       rc,80          ; attempt to read 80 bytes
              glo       rd             ; setup transfer buffer
              adi       22
              plo       rf
              plo       rb
              ghi       rd
              adci      0
              phi       rf
              phi       rb
              sep       scall          ; read next block of bytes
              dw        o_read
              pop       rf             ; recover buffer
              glo       rc             ; see if bytes were read
              lbnz      readbyte       ; now return the byte
eof:          smi       0              ; signal eof
              rtn                      ; and return

              endp

;  00- 18 - Standard FILDES
;      19 - Bytes remaining in buffer
;  20- 21 - Buffer pointer
;  22-101 - Line buffer (80 bytes)
; 101-612 - DTA

