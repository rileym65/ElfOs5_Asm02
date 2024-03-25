#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ********************************
; ***** Initialize assembler *****
; ********************************
              proc      initasm

              extrn     adddefine
              extrn     buffer
              extrn     bytes
              extrn     cldefines
              extrn     defines
              extrn     errors
              extrn     flags
              extrn     helpers
              extrn     labelchar
              extrn     labels
              extrn     lines
              extrn     load_rf
              extrn     ltrimrf
              extrn     nextlabel
              extrn     save_rf
              extrn     strcmpin
              extrn     F_SHOWLIST
              extrn     F_LISTFILE
              extrn     F_SHOWSYM
              extrn     F_1805

              call      o_inmsg        ; display banner
              db        'Asm/02-lite v0.1',10,13
              db        'by Michael H. Riley',10,13,10,13,0
              mov       r9,helpers
              mov       r8,k_himem     ; point to hi memory pointer
              lda       r8             ; retrieve it
              phi       rf
              lda       r8
              plo       rf
              ldi       0              ; terminate define table
              str       rf
              hlpr      save_rf,defines ; set defines table start
              mov       rf,ra          ; point rf to arguments
              ldi       0              ; clear flags
              plo       r7
swloop:       call      ltrimrf        ; move past any spaces
              call      strcmpin       ; check for -l
              db        '-l',0
              lbnf      not_lcl        ; jump if not -l
              glo       r7             ; set show list flag
              ori       F_SHOWLIST
              plo       r7
              lbr       swloop         ; look for more switches
not_lcl:      call      strcmpin       ; check for -L
              db        '-L',0
              lbnf      not_ucl        ; jump if not
              glo       r7             ; set list file flag
              ori       F_LISTFILE
              plo       r7
              lbr       swloop         ; look for more switches
not_ucl:      call      strcmpin       ; check for -s
              db        '-s',0
              lbnf      not_s          ; jump if not
              glo       r7             ; set show symbols flag
              ori       F_SHOWSYM
              plo       r7
              lbr       swloop         ; look for more switches
not_s:        call      strcmpin       ; check for -1805
              db        '-1805',0
              lbnf      not_1805       ; jump if not
              glo       r7             ; set 1805 flag
              ori       F_1805
              plo       r7
              lbr       swloop         ; look for more switches
not_1805:     ldn       rf             ; get byte from input
              smi       '-'            ; check for switch
              lbnz      swdone         ; jump if done with switches
              inc       rf             ; move past switch
              ldn       rf             ; get switch
              smi       'D'            ; check for define
              lbnz      not_d          ; jump if not
              inc       rf             ; move past D
              mov       rb,buffer      ; point to buffer
def_name:     lda       rf             ; get next byte
              call      labelchar      ; see if label character
              lbnf      def_named      ; jump if done with name
              str       rb             ; store into buffer
              inc       rb
              lbr       def_name       ; loop until full name copied
def_named:    dec       rf             ; move back to last character
              ldi       0              ; terminate name
              str       rb
              inc       rb
              mov       ra,rb          ; remember this position
              ldn       rf             ; get next byte
              smi       '='            ; check for equals sign
              lbz       hasvalue       ; jump if value provided
              ldi       '1'            ; if no value specified, then value is 1
              str       rb
              inc       rb
def_term:     ldi       0              ; terminate define value
              str       rb
              push      rf             ; save position
              mov       rf,buffer      ; point to name
              call      adddefine      ; add the define
              pop       rf             ; recover position
              lbnf      swloop         ; continue processing switches
              call      o_inmsg        ; display error
              db        'Error: Duplicate define',10,13,0
              smi       0              ; indicate an error
              rtn                      ; and return to caller
hasvalue:     inc       rf             ; move past equals
value_lp:     lda       rf             ; get next byte
              lbz       value_dn       ; jump if done with value
              plo       re             ; save character
              smi       ' '            ; check for space
              lbz       value_dn       ; jump if done
              glo       re             ; recover character
              str       rb             ; store into value entry
              inc       rb
              lbr       value_lp       ; loop until done with value
value_dn:     dec       rf             ; move back to last character
              lbr       def_term       ; done with define value

not_d:
              call      o_inmsg        ; display error
              db        'Error: Invalid switch',10,13,0
              smi       0              ; indicate an error
              rtn                      ; and return to caller
swdone:       mov       rc,flags       ; point to flags
              glo       r7             ; save flags
              str       rc
              mov       ra,rf          ; reset ra after switches
              mov       r9,helpers     ; point to helper routines
              mov       rf,0           ; need 0
              hlpr      save_rf,errors ; clear error count
              hlpr      save_rf,lines  ; clear line count
              hlpr      save_rf,bytes  ; clear byte count
              hlpr      load_rf,defines ; get position of command line defines
              hlpr      save_rf,cldefines ; and save this position
              mov       rf,labels      ; point to label storage
              hlpr      save_rf,nextlabel
              call      f_getdev       ; get system devices
              glo       rf             ; see if RTC is installed
              ani       010h
              lbz       no_rtc         ; jump if not
              mov       rf,k_month     ; get current date/time
              call      f_gettod
no_rtc:       adi       0              ; signal no errors
              rtn                      ; return to caller

              endp

