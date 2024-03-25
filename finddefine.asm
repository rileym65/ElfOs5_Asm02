#include      macros.inc
#include      bios.inc
#include      kernel.inc

; *******************************************
; ***** Find label                      *****
; ***** RF - Pointer to label           *****
; ***** Returns: DF=0 - define found    *****
; *****            RA - Label data      *****
; *****            RF - Following label *****
; *****          DF=1 - Label not found ***** 
; *****            RF - Following label *****
; *******************************************
              proc      finddefine

              extrn     defines
              extrn     labelchar
              extrn     load_ra
              extrn     tolc

              hlpr      load_ra,defines ; get beginning of define table
loop:         ldn       ra             ; get byte from labels
              lbz       notfound       ; jump if not found
              push      rf             ; save position
iloop:        ldn       ra             ; get byte from define table
              smi       '|'            ; check for end of name
              lbz       lastchar       ; jump if end of name
              lda       ra             ; recover character
              call      tolc           ; convert to lowercase
              stxd                     ; store it
              lda       rf             ; get byte from source
              call      tolc           ; convert to lowercase
              irx                      ; point back to table character
              sm                       ; and compare
              lbz       iloop          ; jump if valid
findend:      pop       rf             ; recover source position
notfoundlp:   lda       ra             ; seek end of entry
              lbnz      notfoundlp     ; loop until terminator found
              lbr       loop           ; check next entry
lastchar:     ldn       rf             ; get byte from source
              call      labelchar      ; see if it is a label character
              lbdf      findend        ; jump if not a match
              irx                      ; remove rf from stack
              irx
              inc       ra             ; move past |
              adi       0              ; signal was found
              rtn                      ; and return to caller
notfound:     smi       0              ; signal entry not found
              rtn

              endp

; label entry example
;       db    'definename|definevalue',0
