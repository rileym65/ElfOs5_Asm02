#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      nextline

              extrn     action
              extrn     adddefine
              extrn     address
              extrn     buffer
              extrn     defreplace
              extrn     dta
              extrn     error
              extrn     finddefine
              extrn     fopen
              extrn     getarg
              extrn     incopy
              extrn     inccount
              extrn     incsp
              extrn     itoa16
              extrn     labelchar
              extrn     line
              extrn     linecount
              extrn     load_d
              extrn     load_r8
              extrn     load_rd
              extrn     load_rf
              extrn     lstbytes
              extrn     lstline
              extrn     lstpos
              extrn     ltrimrf
              extrn     nests
              extrn     numnests
              extrn     readln
              extrn     save_d
              extrn     save_r8
              extrn     save_rf
              extrn     srcfildes
              extrn     srcsector
              extrn     strcasecmpin

loop:         mov       rf,line        ; where to read the line
              mov       rd,srcfildes   ; point to file descriptor
              call      readln         ; call readline
              lbdf      eof            ; jump if eof hit
              hlpr      load_rf,linecount
              inc       rf
              hlpr      save_rf,linecount

              mov       rf,line        ; point to input line
              ldn       rf             ; get first byte of line
              smi       '#'            ; check for pre-processor command
              lbnz      notpre         ; jump if not pre-processor
              hlpr      load_d,action  ; get current action
              plo       re             ; keep a copy
              smi       'I'            ; check for ignore
              lbz       ignore         ; jump if ignore is active
              glo       re             ; recover action

              call      strcasecmpin   ; check for #error
              db        '#error ',0
              lbnf      not_error      ; jump if not
              hlpr      load_d,action  ; get action
              smi       'N'            ; are lines being processed
              lbz       loop           ; ignore if so
              call      ltrimrf        ; move past any spaces
              call      o_msg          ; display error message
              call      o_inmsg
              db        10,13,0
              call      error          ; call error routine
              lbr       loop           ; then back to loop
              

not_error:    call      strcasecmpin   ; check for #include
              db        '#include ',0
              lbnf      not_include    ; jump if not
              hlpr      load_d,action  ; get action
              smi       'N'            ; are lines being processed
              lbz       loop           ; ignore if so
              call      ltrimrf        ; move past any spaces

              push      rf
              mov       rf,incsp       ; point to inc stack pointer
              lda       rf             ; and retrieve it
              phi       r8
              ldn       rf
              plo       r8
              mov       r7,linecount   ; get line counter
              lda       r7
              str       r8             ; store into data
              inc       rd
              lda       r7
              str       r8
              inc       r8
              mov       r7,srcfildes   ; point to source fildes
              ldi       102            ; 102 bytes to copy
              plo       rc
inc_loop:     lda       r7             ; read byte from fildes
              str       r8             ; write into inc stack
              inc       r8
              dec       rc             ; decrement count
              glo       rc             ; see if done
              lbnz      inc_loop       ; loop until all copied
              glo       r8             ; write new stack ponter
              str       rf
              dec       rf
              ghi       r8
              str       rf
              hlpr      load_d,inccount ; get count of include files
              adi       1              ; add 1
              hlpr      save_d,inccount ; and put it back
              pop       rf

              mov       rd,srcfildes   ; point to source fildes
              mov       r7,0           ; set file flags
              call      fopen          ; attempt to open include file
              lbnf      opened
              call      o_inmsg        ; display error
              db        'Error: Could not open include file',10,13,0
              call      error
              lbr       eof            ; backout data from stack
opened:       mov       rf,0           ; clear line counter
              hlpr      save_rf,linecount
              lbr       loop           ; back to reading lines

not_include:  call      strcasecmpin   ; check for #define
              db        '#define ',0
              lbnf      not_define     ; jump if not
              hlpr      load_d,action  ; get action
              smi       'N'            ; are lines being processed
              lbz       loop           ; ignore if so
              call      ltrimrf        ; move past any spaces
              ldn       rf             ; get first character
              call      labelchar      ; must be a label character
              lbnf      preerror       ; jump if error
              mov       r8,buffer      ; point to buffer
              call      getname        ; get name
              call      ltrimrf        ; move past any spaces
              ldn       rf             ; get next byte
              lbz       def_default    ; if eol use default value
              smi       ';'            ; check for remark
              lbz       def_default    ; use default if hit remark
              push      r8             ; save this position in buffer
def_val_lp:   lda       rf             ; get next byte from input
              plo       re             ; keep a copy
              lbz       def_val_dn     ; jump if done with value
              smi       ';'            ; check for semicolon
              lbz       def_val_dn     ; jump if hit remark
              glo       re             ; recover value character
              str       r8             ; store into buffer
              inc       r8
              lbr       def_val_lp     ; loop until full value copied
def_val_dn:   ldi       0              ; terminate value
              str       r8
              pop       r8             ; recover where value starts
              lbr       do_define      ; then perform the define
def_default:  ldi       '1'            ; default value is 1
              str       r8
              inc       r8
              ldi       0              ; terminate it
              str       r8
              dec       r8             ; move back
do_define:    push      ra             ; save registers
              push      rf
              mov       ra,r8          ; ra points to value
              mov       rf,buffer      ; rf points to name
              call      adddefine      ; add the define
              pop       rf             ; recover registers
              pop       ra
              lbr       loop           ; then read next line

not_define:   call      strcasecmpin   ; check for #else
              db        '#else',0
              lbnf      not_else       ; jump if not #else
              hlpr      load_d,numnests ; get number of nests
              lbnz      else_good      ; jump if there are nests
              call      o_inmsg        ; display error
              db        'Error: Unmatched #else',10,13,0
              call      error
              lbr       loop           ; read next line
else_good:    smi       1              ; convert index
              adi       nests.0        ; point into nests array
              plo       rc
              ldi       0
              adci      nests.1
              phi       rc
              ldn       rc             ; get current nest value
              smi       'Y'            ; is it yes
              lbz       else_yes       ; jump if so
              ldi       'Y'            ; set to yes
else_cont:    str       rc
              hlpr      save_d,action  ; set current action
              lbr       loop           ; then read next line
else_yes:     ldi       'N'            ; set to no
              lbr       else_cont      ; save new action

not_else:     call      strcasecmpin   ; check for #ifdef
              db        '#ifdef ',0
              lbnf      not_ifdef      ; jump if not
              hlpr      load_d,numnests ; get number of nests
              adi       1              ; add 1 to nest count
              hlpr      save_d,numnests ; write it back
              smi       1              ; back 1
              plo       re             ; keep nests count
              adi       nests.0
              plo       rc
              ldi       0
              adci      nests.1
              phi       rc
              glo       re             ; recover nests count
              lbz       ifdef_go       ; must process if no nests
              hlpr      load_d,action  ; get current action
              smi       'N'            ; is it currently no
              lbnz      ifdef_go       ; jump if not
              ldi       'I'            ; new action is ignore
              str       rc
              hlpr      save_d,action
              lbr       loop           ; read next line
ifdef_go:     call      ltrimrf        ; move past any spaces
              ldn       rf             ; get first character
              call      labelchar      ; must be a label character
              lbnf      preerror       ; jump if error
              mov       r8,buffer      ; point to buffer
              call      getname        ; get name
              mov       rf,buffer      ; point to buffer
              call      finddefine     ; see if define exists
              lbdf      ifdef_fail     ; jump if does not exist
ifdef_pass:   ldi       'Y'            ; action is yes
ifdef_cont:   str       rc             ; store to nests array
              hlpr      save_d,action  ; and current action
              lbr       loop           ; then read next line
ifdef_fail:   ldi       'N'            ; stop processing lines
              lbr       ifdef_cont     ; write it and continue

not_ifdef:    call      strcasecmpin   ; check for #ifndef
              db        '#ifndef ',0
              lbnf      not_ifndef     ; jump if not
              hlpr      load_d,numnests ; get number of nests
              adi       1              ; add 1 to nest count
              hlpr      save_d,numnests ; write it back
              smi       1              ; back 1
              plo       re             ; keep nests count
              adi       nests.0
              plo       rc
              ldi       0
              adci      nests.1
              phi       rc
              glo       re             ; recover nests count
              lbz       ifndef_go      ; must process if no nests
              hlpr      load_d,action  ; get current action
              smi       'N'            ; is it currently no
              lbnz      ifndef_go      ; jump if not
              ldi       'I'            ; new action is ignore
              str       rc
              hlpr      save_d,action
              lbr       loop           ; read next line
ifndef_go:    call      ltrimrf        ; move past any spaces
              ldn       rf             ; get first character
              call      labelchar      ; must be a label character
              lbnf      preerror       ; jump if error
              mov       r8,buffer      ; point to buffer
              call      getname        ; get name
              mov       rf,buffer      ; point to buffer
              call      finddefine     ; see if define exists
              lbnf      ifdef_fail     ; jump if does not exist
              lbr       ifdef_pass


not_ifndef:   call      strcasecmpin   ; check for #if
              db        '#if ',0
              lbnf      not_if         ; jump if not
              hlpr      load_d,numnests ; get number of nests
              adi       1              ; add 1 to nest count
              hlpr      save_d,numnests ; write it back
              smi       1              ; back 1
              plo       re             ; keep nests count
              adi       nests.0
              plo       rc
              ldi       0
              adci      nests.1
              phi       rc
              glo       re             ; recover nests count
              lbz       if_go          ; must process if no nests
              hlpr      load_d,action  ; get current action
              smi       'N'            ; is it currently no
              lbnz      if_go          ; jump if not
              ldi       'I'            ; new action is ignore
              str       rc
              hlpr      save_d,action
              lbr       loop           ; read next line
if_go:        call      ltrimrf        ; move past any spaces
              push      rc
              call      defreplace     ; perform define replacements
              call      getarg         ; evaluate expression
              pop       rc
              glo       r7             ; check result
              str       r2
              ghi       r7
              or
              lbz       ifdef_fail     ; fail if expression was zero
              lbr       ifdef_pass
not_if:

ignore:       call      strcasecmpin   ; check for #endif
              db        '#endif',0
              lbnf      preerror       ; error if not
              hlpr      load_d,numnests ; get number of nests
              lbnz      havenests      ; jump if have nests
              call      o_inmsg        ; display error
              db        'Error: Unmatched #endif',10,13,0
              call      error
              lbr       loop
havenests:    smi       1              ; subtract number of nests
              hlpr      save_d,numnests ; and save back
              lbz       no_nests       ; jump if no more nests
              adi       nests.0        ; need to get current nest
              plo       rc
              ldi       0
              adci      nests.1
              phi       rc
              ldn       rc             ; get next nesting action
              hlpr      save_d,action  ; and write to action
              lbr       loop           ; then read next line
no_nests:     ldi       'Y'            ; continue processing lines
              hlpr      save_d,action
              lbr       loop


preerror:     call      o_inmsg        ; display error
              db        'Error: Invalid pre-processor command',10,13,0
              call      error
              lbr       loop           ; read next line

notpre:       hlpr      load_d,action  ; get current action
              smi       'Y'            ; are we processing lines
              lbnz      loop           ; jump if not
              mov       rf,line
              call      defreplace     ; perform define replacements
              hlpr      load_rf,linecount
              mov       rc,rf          ; move line count
              mov       rd,buffer      ; point to list line
              call      itoa16         ; convert to ascii
              mov       rd,buffer      ; point to buffer
              mov       rc,5           ; need 5 digits
lenloop:      lda       rd             ; get byte from buffer
              lbz       lendone        ; jump if end found
              dec       rc             ; decrement rc
              lbr       lenloop        ; loop to find end
lendone:      mov       rf,lstline     ; point to list line
              hlpr      load_d,inccount
              lbz       no_inc_1       ; jump if main file
              op        incopy
              db        '<',0
              lbr       zerolp
no_inc_1:     op        incopy
              db        '[',0
zerolp:       glo       rc             ; see if enough leading zeroes
              lbz       zerodone       ; jump if no more needed
              op        incopy
              db        '0',0
              dec       rc             ; decrement count
              lbr       zerolp         ; loop until enough leading zeroes
zerodone:     mov       rd,buffer      ; point to converted number
numloop:      lda       rd             ; read from converted number
              lbz       numdone        ; jump if done with number
              str       rf             ; store to line
              inc       rf
              lbr       numloop        ; loop until done copying
numdone:      hlpr      load_d,inccount ; get inc count
              lbz       no_inc_2       ; jump if main file
              op        incopy
              db        '> ',0
              lbr       numdone_2
no_inc_2:     op        incopy
              db        '] ',0
numdone_2:    hlpr      load_rd,address ; get current address
              call      f_hexout4      ; and write to list line
              op        incopy
              db        ':',0
              str       rf
              hlpr      save_rf,lstpos ; save position
              ldi       0              ; clear lst bytes
              hlpr      save_d,lstbytes

              mov       rf,line        ; point to line
              adi       0              ; signal good read
              rtn                      ; and return

eof:          hlpr      load_d,inccount ; get include count
              lbz       return         ; jump if no include files
              smi       1              ; decrement include count
              hlpr      save_d,inccount
              hlpr      load_r8,incsp  ; get stack pointer
              glo       r8             ; subtract 104
              smi       104
              plo       r8
              ghi       r8
              smbi      0
              phi       r8
              hlpr      save_r8,incsp  ; write new stack pointer
              mov       r7,linecount   ; point to line count
              lda       r8             ; set to prior line counter
              str       r7
              inc       r7
              lda       r8
              str       r7
              mov       r7,srcfildes   ; point to source fildes
              ldi       102            ; need to copy 102 bytes
              plo       rc
eof_lp:       lda       r8             ; read byte from stack
              str       r7             ; store into fildes
              inc       r7
              dec       rc             ; decrement count
              glo       rc             ; see if done
              lbnz      eof_lp         ; loop until all data copied
              mov       rf,srcsector   ; retrieve sector from prior file
              lda       rf
              phi       r8
              lda       rf
              plo       r8
              lda       rf
              phi       r7
              lda       rf
              plo       r7
              mov       rf,dta         ; point to dta
              call      d_ideread      ; read sector
              lbr       loop           ; now read next line

return:       rtn                      ; return to caller

getname:      lda       rf             ; get byte from line
              call      labelchar      ; check for label character
              lbnf      getname_dn     ; jump if done
              str       r8             ; store into buffer
              inc       r8
              lbr       getname        ; loop until full name read
getname_dn:   ldi       0              ; terminate name
              str       r8
              inc       r8
              dec       rf             ; move back to non label character
              rtn                      ; and return to caller


              endp

