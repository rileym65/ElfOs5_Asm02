#include      macros.inc
#include      bios.inc
#include      kernel.inc

; *******************************************
; ***** Find label                      *****
; ***** RF - Pointer to label           *****
; ***** Returns: DF=0 - label found     *****
; *****            RA - Label data      *****
; *****            RF - Following label *****
; *****          DF=1 - Label not found ***** 
; *****            RF - Following label *****
; *****            RA - $0000           *****
; *******************************************
              proc      findlabel

              extrn     extrnlabel
              extrn     labelchar
              extrn     labels
              extrn     load_ra
              extrn     save_ra
              extrn     tolc

              mov       ra,labels      ; get address of label table
loop:         ldn       ra             ; get byte from labels
              lbz       notfound       ; jump if not found
              hlpr      save_ra,extrnlabel ; save label address in case extrn
              push      rf             ; save instruction position
iloop:        lda       rf             ; get byte from source
              call      tolc           ; convert to uppercase
              str       r2             ; store for comparison
              lda       ra             ; get byte from label
              shl                      ; shift high bit to DF
              lbdf      lastchar       ; jump if last character
              shr                      ; shift if back
              sm                       ; compare with source byte
              lbz       iloop          ; jump if still matching
              pop       rf             ; recover source position
tloop:        lda       ra             ; find end of entry
              shl
              lbnf      tloop
skipdata:     inc       ra             ; move past entry data
              inc       ra
              inc       ra
              inc       ra
              inc       ra
              lbr       loop           ; check next entry
              lbnz      loop           ; jump if more entries
notfound:     lda       rf             ; move past label name
              call      labelchar      ; check for valid label character
              lbdf      notfound       ; find end of label
              dec       rf             ; move back to last character
              smi       0              ; signal opcode not found
              ldi       0              ; label value is zero when not found
              phi       ra
              plo       ra
              rtn                      ; and return to caller
lastchar:     shr                      ; shift character back
              sm                       ; compare to source byte
              lbz       maybe          ; maybe good
nope:         pop       rf             ; recover source position
              lbr       skipdata       ; and skip past entry data
maybe:        ldn       rf             ; get next byte from input
              call      tolc           ; convert to lowercase
              call      labelchar      ; see if label character
              lbdf      nope           ; not a match if label character
good:         irx                      ; remove rf from stack
              irx
              adi       0              ; signal label found
              rtn                      ; and return to caller

              endp

; label entry
;       0-n - label name, hit bit set terminates
;       n+1 - label flags
;             bit 0 - external        (1)
;             bit 1 - declared public (2)
;             bit 2 - local label     (4)
;             bit 3 - proc name       (8)
; n+2 - n+3 - Label scope ($0000 for global)
; n+4 - n+5 - Label value

