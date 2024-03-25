#include      macros.inc

; ***********************************
; ***** 16-bit division         *****
; ***** RC - Numerator          *****
; ***** RD - Denominator        *****
; ***** Returns: RD - result    *****
; *****          RC - remainder *****
; ***********************************
              proc      div16

              extrn     mdnorm16

              call      mdnorm16       ; make both numbers positive
              plo       re             ; save sign 
              glo       rd
              lbnz      div16_1
              ghi       rd
              lbnz      div16_1
              ldi       0              ; set zero as result
              phi       rd
              plo       rd
              rtn                      ; return to caller
div16_1:      push      r8             ; save consdumed registers
              push      r9
              push      rf
              ldi       0     
              phi       rf             ; clear result
              plo       rf
              phi       r8             ; clear bit mask
              plo       r8
              inc       r8             ; set bit mask to 1
d16lp1:       ghi       rd             ; get high bit of numerator
              shl                      ; shift high bit into DF
              lbdf      divst          ; jump if high bit was set
              glo       rd             ; shift denominator left
              shl
              plo       rd
              ghi       rd
              shlc
              phi       rd
              glo       r8             ; shift bit mask left
              shl
              plo       r8
              ghi       r8
              shlc
              phi       r8
              lbr       d16lp1         ; loop until high bit is set
divst:        glo       rd             ; is numerator non-zero
              lbnz      divgo          ; keep dividing if non-zero
              ghi       rd
              lbnz      divgo
divret:       glo       re             ; get sign
              shr                      ; move to DF
              lbnf      divrt          ; positive if signs are the same
              ghi       rf             ; 2s compliment answer
              xri       0ffh
              phi       rf
              glo       rf
              xri       0ffh
              plo       rf
              inc       rf
divrt:        mov       rd,rf          ; move answer to rd
              pop       rf             ; recover consumed registers
              pop       r9
              pop       r8
              rtn                      ; return to caller
divgo:        mov       r9,rc          ; keep a copy of numerator
              glo       rd             ; subtract denominator from numerator
              str       r2
              glo       rc
              sm
              plo       rc
              ghi       rd
              str       r2
              ghi       rc
              smb
              phi       rc
              lbdf      divyes         ; Jump if result was positive
              mov       rc,r9          ; resture original numerator
              lbr       divno
divyes:       glo       r8             ; add bit mask to result
              str       r2
              glo       rf
              add
              plo       rf
              ghi       r8
              str       r2
              ghi       rf
              adc
              phi       rf
divno:        ghi       rd             ; shift denominator right
              shr
              phi       rd
              glo       rd
              shrc
              plo       rd
              ghi       r8             ; shift bitmask right
              shr
              phi       r8
              glo       r8
              shrc
              plo       r8
              lbdf      divret         ; end if bit mask ends up zero
              lbr       divst          ; jump for next itearation

              endp

