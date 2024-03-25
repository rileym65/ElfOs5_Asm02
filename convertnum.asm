#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ********************************************
; ***** Convert number to binary         *****
; ***** RF - Pointer to ASCII number     *****
; ***** Returns: DF=0 - success          *****
; *****            RA - Numeric value    *****
; *****            RF - Following number *****
; *****          DF=1 - Failure          *****
; *****            RF - Original pointer *****
; ********************************************
              proc      convertnum

              extrn     address
              extrn     checkrange
              extrn     iaddr
              extrn     isrreg
              extrn     labelchar
              extrn     load_ra
              extrn     tohex

              push      rf             ; save pointer
              ldi       0              ; clear negative flag
              phi       rc
              plo       rc             ; clear hex flag
              ldn       rf             ; get first character
              smi       '-'            ; check for negative
              lbnz      not_neg        ; jump if not
              ldi       1              ; set negative flag
              phi       rc
              inc       rf             ; move past negative sign
; **********************************
; ***** check for single quote *****
; **********************************
not_neg:      ldn       rf             ; get first byte
              smi       27h            ; check for single quote
              lbnz      not_sq         ; jump if not a single quote
              inc       rf             ; move past quote marker
              lda       rf             ; get value
              plo       ra             ; set return value
              ldi       0              ; high value is zero
              phi       ra
              lda       rf             ; get next character
              smi       27h            ; must be 27
              lbnz      failed         ; jump if not
good:         irx                      ; remove rf from stack
              irx
              ghi       rc             ; get negative flag
              lbz       positive       ; jump if positive
              glo       ra             ; 2s compliment number
              xri       0ffh
              plo       ra
              ghi       ra
              xri       0ffh
              phi       ra
              inc       ra
positive:     adi       0              ; signal success
              rtn                      ; and return
failed:       pop       rf             ; recover pointer
              smi       0              ; signal failure
              rtn                      ; and return
; **********************************
; ***** check for double quote *****
; **********************************
not_sq:       ldn       rf             ; get first character again
              smi       '"'            ; check for double quote
              lbnz      not_dq         ; jump if not
              inc       rf             ; move past quote
              lda       rf             ; get character value
              plo       ra             ; put into result
              ldi       0              ; high byte is zero
              phi       ra
              lda       rf             ; get following character
              smi       '"'            ; must be double quote
              lbnz      failed         ; jump if not
              lbr       good           ; otherwise good
; **********************************
; ***** check for binary (%)   *****
; **********************************
not_dq:       ldn       rf             ; recover first character
              smi       '%'            ; check for binary marker
              lbnz      not_bin        ; jump if not binary
              ldi       0              ; clear result
              phi       ra
              plo       ra
binary_lp:    inc       rf             ; move to next character
              ldn       rf             ; get character
              smi       '_'            ; check for underscore
              lbz       binary_lp      ; skip underscore
              ldn       rf             ; recover character
              smi       '0'            ; check if below 0
              lbnf      good           ; jump if done
              smi       2              ; check if above range
              lbdf      good           ; jump if non binary character
              ldn       rf             ; recover character
              ani       1              ; keep only low bit
              shr                      ; shift it into DF
              glo       ra             ; shift value left
              shlc
              plo       ra
              ghi       ra
              shlc
              phi       ra
              lbr       binary_lp      ; loop until no more binary
; ********************************
; ***** Check for R-register *****
; ********************************
not_bin:      call      isrreg         ; see if pointing to an r register
              lbnf      not_r          ; not an r register
              plo       ra             ; put into result
              ldi       0              ; high value is 0
              phi       ra
              lbr       good           ; return value
; ******************************
; ***** Check for $ values *****
; ******************************
not_r:        ldn       rf             ; recover character
              smi       '$'            ; check for dollar sign
              lbnz      not_dollar     ; jump if not
              inc       rf             ; move past dollar
              ldn       rf             ; retrieve value
              call      f_ishex        ; it it valid hex character
              lbdf      is_hex         ; jump if is hex
              hlpr      load_ra,iaddr  ; get current address
              lbr       good           ; then good
is_hex:       ldi       1              ; mark as hex value
              plo       rc
; ****************************************
; ***** Process as if it is a number *****
; ****************************************
not_dollar:   ldn       rf             ; recover character
              call      checkrange     ; see if 0 through 9
              db        '0','9'
              lbdf      do_number      ; jump if so
              glo       rc             ; get hex flag
              lbz       failed         ; not a valid number
              ldn       rf             ; recover character
              call      checkrange     ; see if a through f
              db        'a','f'
              lbdf      do_number      ; process number
              call      checkrange     ; see if A through F
              db        'A','F'
              lbnf      failed         ; fail if not
do_number:    mov       ra,0           ; clear decimal value
              mov       rb,0           ; clear hex value
num_loop:     ldn       rf             ; get next character
              smi       'H'            ; check for H for hex
              lbz       done_hex       ; jump if done
              smi       32             ; check for lowercase h
              lbz       done_hex       ; jump if done
              ldn       rf             ; recover character
              call      f_ishex        ; is it a valid hex character
              lbnf      num_done       ; done with number processing
; ***********************************
; ***** Multiply RB (hex) by 16 *****
; ***********************************
              ldi       4              ; need 4 shifts
              plo       re
loop_16:      glo       rb             ; shift rb
              shl
              plo       rb
              ghi       rb
              shlc
              phi       rb
              dec       re             ; decrement count
              glo       re             ; see if done
              lbnz      loop_16        ; loop until all 4 shifts done
; ***************************************
; ***** Multiply RA (decimal) by 10 *****
; ***************************************
              glo       ra             ; multiply by 2
              shl
              plo       ra
              ghi       ra
              shlc
              phi       ra
              stxd                     ; keep a copy
              glo       ra
              str       r2
              glo       ra             ; multiply by 4
              shl
              plo       ra
              ghi       ra
              shlc
              phi       ra
              glo       ra             ; multiply by 8
              shl
              plo       ra
              ghi       ra
              shlc
              phi       ra
              glo       ra             ; multiply by 10
              add
              plo       ra
              ghi       ra
              irx
              adc
              phi       ra
              lda       rf             ; recover character
              call      tohex          ; convert to binary
              str       r2             ; save for addition
              glo       rb             ; add to hex value
              or 
              plo       rb
              ldx                      ; recover value
              smi       10             ; see if 10 or higher
              lbdf      num_loop       ; loop for next character
              glo       ra             ; add value to decimal total
              add
              plo       ra
              ghi       ra
              adci      0
              phi       ra
              lbr       num_loop       ; loop for next character
done_hex:     inc       rf             ; move past h
              ldi       1              ; set hex flag
              plo       rc
num_done:     ldn       rf             ; get character following number
              call      labelchar      ; check for label character
              lbdf      failed         ; if so, then fails
              glo       rc             ; get hex flag
              lbz       good           ; jump if not hex
              mov       ra,rb          ; move computed hex value to result
              lbr       good           ; then finish up

              endp

; Rc.1 - Negative marker
; Rc.0 - Hex marker
