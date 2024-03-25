#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      asmpass

              extrn     action
              extrn     addlabel
              extrn     address
              extrn     bytes
              extrn     check1805
              extrn     cldefines
              extrn     defines
              extrn     directive
              extrn     error
              extrn     flags
              extrn     fopen
              extrn     getarg
              extrn     iaddr
              extrn     incopy
              extrn     inccount
              extrn     incstack
              extrn     incsp
              extrn     label
              extrn     labelchar
              extrn     line
              extrn     linecount
              extrn     lines
              extrn     load_d
              extrn     load_ra
              extrn     load_rb
              extrn     load_rf
              extrn     lookupop
              extrn     lstbytes
              extrn     lstline
              extrn     lstpos
              extrn     ltrimrf
              extrn     nextline
              extrn     numnests
              extrn     outaddress
              extrn     outcount
              extrn     output
              extrn     pass
              extrn     save_d
              extrn     save_rf
              extrn     srcfile
              extrn     srcfildes
              extrn     startaddr
              extrn     writelstfile
              extrn     F_SHOWLIST
              extrn     F_LISTFILE

              mov       rf,srcfile     ; point to source filename
              mov       rd,srcfildes   ; point to source fildes
              mov       r7,0           ; open file flags
              call      fopen          ; open the file
              lbnf      opened         ; jump if file opened
              call      o_inmsg        ; display error message
              db        'Error: Could not open source file',10,13,0
              smi       0              ; set DF
              rtn                      ; and return to caller
opened:       mov       rf,0           ; clear initial values
              hlpr      save_rf,lines  ; line counter
              hlpr      save_rf,bytes  ; bytes output counter
              hlpr      save_rf,address ; initial assembly address
              hlpr      save_rf,outaddress
              hlpr      save_rf,linecount
              hlpr      load_rf,cldefines ; get address of cl defines
              hlpr      save_rf,defines ; and set pass defines
              mov       rf,incstack    ; set inc stack pointer
              hlpr      save_rf,incsp
              ldi       0ffh           ; set start address to -1
              phi       rf
              plo       rf
              hlpr      save_rf,startaddr
              ldi       'Y'            ; set line processor to yes
              hlpr      save_d,action
              ldi       0
              hlpr      save_d,outcount
              hlpr      save_d,numnests ; set nesting level to zero
              hlpr      save_d,inccount ; set include stack count to zero
fileloop:     hlpr      load_rf,address
              hlpr      save_rf,iaddr
              call      nextline       ; get next source line
              lbdf      done
              ldn       rf             ; get first byte of line
              lbz       endofline      ; jump if empty line
              call      f_isalpha      ; is first character a letter
              lbnf      nolabel        ; jump if no label
              mov       r7,label       ; point to label name storage
labelcopy:    lda       rf             ; read byte from input
              call      labelchar      ; check for valid label char
              lbnf      labeldone      ; jump when not valid label char
              str       r7             ; store into label name
              inc       r7
              lbr       labelcopy      ; loop until non-valid character
labeldone:    plo       re             ; save last byte
              ldi       0              ; terminate label name
              str       r7
              glo       re             ; recover character
              smi       ':'            ; check end of label character
              lbz       labelgood      ; jump if label is good
              call      o_inmsg        ; display duplicate error
              db        'Error: Invalid label: ',0
              push      rf             ; save rf
              mov       rf,label       ; point to label name
              call      o_msg          ; display label
              call      o_inmsg        ; followed by cr/lf
              db        10,13,0
              pop       rf             ; recover rf
              call      error          ; call error routine
              lbr       nolabel        ; then proceed as if no label
labelgood:    push      rf             ; save current line position
              mov       rf,label       ; point to label name
              hlpr      load_ra,address ; get current asembly address
              ldi       0              ; label is local
              plo       rb
              call      addlabel       ; add label
              pop       rf             ; recover line position
nolabel:      lda       rf             ; move past any whitespace
              lbz       endofline      ; if terminator, end of lie
              smi       9              ; check for tab
              lbz       nolabel        ; skip tabls
              smi       23             ; check for space
              lbz       nolabel        ; skip spaces
              dec       rf             ; move back to non-whitespace
              ldn       rf             ; check for comment line
              smi       ';'
              lbz       endofline      ; jump if so
              ldn       rf             ; get first character
              smi       '.'            ; check for directove
              lbnz      notdirect      ; jump if not a directive
              call      directive      ; otherwise process directive
              lbr       endofline      ; then end of line
notdirect:    ldn       rf             ; retrieve first character
              call      f_isalpha      ; must be alpha for opcode
              lbdf      hasopcode      ; jump if valid
opcodeerr:    call      o_inmsg        ; display error
              db        'Error: Invalid opcode',10,13,0
              call      error          ; call error routine
              lbr       endofline      ; then end of line
hasopcode:    call      lookupop       ; lookup the opcode
              lbdf      opcodeerr      ; jump if opcode not found
arloop:       lda       rf             ; move to argument, if any
              smi       9
              lbz       arloop
              smi       23
              lbz       arloop
              dec       rf             ; move to first byte of argument
              lda       ra             ; get opcode type
              smi       1              ; check for type 1
              lbz       type1          ; jump if so
              smi       1              ; check for type 2
              lbz       type2          ; jump if so
              smi       1              ; check for type 3
              lbz       type3          ; jump if so
              smi       1              ; check for type 4
              lbz       type4          ; jump if so
              smi       1              ; check for type 5
              lbz       type5          ; jump if so
              smi       1              ; check for type 6
              lbz       type6          ; jump if so
              lbr       type7          ; otherwise type 7

; *******************************************
; ***** Type 1 instruction, no argument *****
; *******************************************
type1:        ldn       ra             ; get first byte of opcode
              smi       068h           ; check for 1805 instruction
              lbnz      type1go        ; jump if good to go
              call      check1805      ; see if 1805 instructions allowed
              lbdf      type1go        ; jump if they are
              call      o_inmsg        ; display error
              db        'Error: 1805 opcode encountered in non-1805 mode',10,13,0
              call      error          ; call error routine
              lbr       endofline      ; then end of line
type1go:      ldn       ra             ; recover opcode
              call      output         ; and output it
              lda       ra             ; recover opcode
              smi       068h           ; see if 1805 instruction
              lbnz      endofline      ; jump if not
              ldn       ra             ; get second byte
              call      output         ; and output it
              lbr       endofline      ; done with line

; *********************************************
; ***** Type 2 instruction, byte argument *****
; *********************************************
type2:        ldn       ra             ; get first byte of opcode
              smi       068h           ; check for 1805 instruction
              lbnz      type2go        ; jump if good to go
              call      check1805      ; see if 1805 instructions allowed
              lbdf      type2go        ; jump if they are
              call      o_inmsg        ; display error
              db        'Error: 1805 opcode encountered in non-1805 mode',10,13,0
              call      error          ; call error routine
              lbr       endofline      ; then end of line
type2go:      ldn       ra             ; recover opcode
              call      output         ; and output it
              lda       ra             ; recover opcode
              smi       068h           ; see if 1805 instruction
              lbnz      type2arg       ; jump if not
              ldn       ra             ; get second byte
              call      output         ; and output it
type2arg:     call      getarg         ; get argument
              ghi       r7             ; make sure it is a byte
              lbz       type2good      ; jump if so
              smi       0ffh           ; check for single byte negative
              lbz       type2good      ; jump if so
              call      o_inmsg        ; display error
              db        'Error: Argument out of range',10,13,0
              call      error          ; call error routine
              lbr       endofline      ; then jump end of line
type2good:    glo       r7             ; get low byte of argument
              call      output         ; and output it
              lbr       endofline      ; then done

; *********************************************
; ***** Type 3 instruction, word argument *****
; *********************************************
type3:        ldn       ra             ; get first byte of opcode
              smi       068h           ; check for 1805 instruction
              lbnz      type3go        ; jump if good to go
              call      check1805      ; see if 1805 instructions allowed
              lbdf      type3go        ; jump if they are
              call      o_inmsg        ; display error
              db        'Error: 1805 opcode encountered in non-1805 mode',10,13,0
              call      error          ; call error routine
              lbr       endofline      ; then end of line
type3go:      ldn       ra             ; recover opcode
              call      output         ; and output it
              lda       ra             ; recover opcode
              smi       068h           ; see if 1805 instruction
              lbnz      type3arg       ; jump if not
              ldn       ra             ; get second byte
              call      output         ; and output it
type3arg:     call      getarg         ; get argument
              ghi       r7             ; get high byte of argument
              call      output         ; and output it
              glo       r7             ; get low byte of argument
              call      output         ; and output it
              lbr       endofline      ; then done

; **********************************************
; ***** Type 4 instruction special handler *****
; **********************************************
type4:        ldi       jump.1         ; point to jump fector
              phi       r8
              ldi       jump.0
              plo       r8
              lda       ra             ; get routine address
              str       r8             ; and set jump vector
              inc       r8
              lda       ra
              str       r8
              sep       r4             ; call the special handler
jump:         dw        0
              lbr       endofline      ; then end of line

; ***********************************************
; ***** Type 5 instruction, nybble argument *****
; ***********************************************
type5:        ldn       ra             ; get first byte of opcode
              smi       068h           ; check for 1805 instruction
              lbnz      type5go        ; jump if good to go
              call      check1805      ; see if 1805 instructions allowed
              lbdf      type5_1805     ; jump if they are
              call      o_inmsg        ; display error
              db        'Error: 1805 opcode encountered in non-1805 mode',10,13,0
              call      error          ; call error routine
              lbr       endofline      ; then end of line
type5_1805:   ldi       068h           ; output 1805 prefix
              call      output
              inc       ra             ; move past prefix
type5go:      push      ra
              call      getarg         ; get argument
              pop       ra
              ghi       r7             ; high byte should be zero
              lbnz      type5_bad      ; jump if not zero
              glo       r7             ; should be 0-15
              ani       0f0h
              lbz       type5good      ; jump if in range
type5_bad:    call      o_inmsg        ; display error
              db        'Error: Argument out of range',10,13,0
              call      error          ; call error routine
              lbr       endofline      ; then jump end of line
type5good:    glo       r7             ; get low byte of argument
              str       r2
              ldn       ra             ; recover opcode
              or                       ; combine with argument
              call      output         ; and output it
              lbr       endofline      ; then done

; *************************************************************
; ****** Type 6 instruction, 1 nybble and 1 word argument *****
; *************************************************************
type6:        call      check1805      ; be sure 1805 allowed
              lbdf      type6_ok       ; jump if so
              call      o_inmsg        ; display error
              db        'Error: 1805 opcode encountered in non-1805 mode',10,13,0
              call      error          ; call error routine
              lbr       endofline      ; then end of line
type6_ok:     ldi       068h           ; write prefix byte
              call      output
              inc       ra             ; move to second byte
              push      ra
              call      getarg         ; get first argument
              pop       ra
              ghi       r7             ; high byte should be zero
              lbnz      type6_bad      ; jump if not zero
              glo       r7             ; should be 0-15
              ani       0f0h
              lbz       type6good      ; jump if in range
type6_bad:    call      o_inmsg        ; display error
              db        'Error: Argument out of range',10,13,0
              call      error          ; call error routine
              lbr       endofline      ; then jump end of line
type6good:    glo       r7             ; get low byte of argument
              str       r2
              ldn       ra             ; recover opcode
              or                       ; combine with argument
              call      output         ; and output it
              call      ltrimrf        ; move past any whitespace
              lda       rf             ; get next byte
              smi       ','            ; must be a comma
              lbz       type6_2nd      ; jump if so
              call      o_inmsg        ; display error
              db        'Error: Syntax error',10,13,0
              call      error          ; call error routine
              lbr       endofline      ; then end of line
type6_2nd:    call      ltrimrf        ; move past any whitespace
              call      getarg         ; and get second arg
              ghi       r7             ; write arg to output
              call      output
              glo       r7
              call      output
              lbr       endofline      ; then done

; ********************************************
; ***** Type 7 instruction, short branch *****
; ********************************************
type7:        ldn       ra             ; get first byte of opcode
              smi       068h           ; check for 1805 instruction
              lbnz      type7go        ; jump if good to go
              call      check1805      ; see if 1805 instructions allowed
              lbdf      type7go        ; jump if they are
              call      o_inmsg        ; display error
              db        'Error: 1805 opcode encountered in non-1805 mode',10,13,0
              call      error          ; call error routine
              lbr       endofline      ; then end of line
type7go:      ldn       ra             ; recover opcode
              call      output         ; and output it
              lda       ra             ; recover opcode
              smi       068h           ; see if 1805 instruction
              lbnz      type7arg       ; jump if not
              ldn       ra             ; get second byte
              call      output         ; and output it
type7arg:     call      getarg         ; get argument
              hlpr      load_d,pass    ; get current pass
              smi       1              ; ignore paging if on pass 1
              lbz       type7good
              hlpr      load_rb,address ; get current address
              ghi       r7             ; make sure same page
              str       r2
              ghi       rb
              sm
              lbz       type7good      ; jump if so
              call      o_inmsg        ; display error
              db        'Error: Short branch out of page',10,13,0
              call      error          ; call error routine
              lbr       endofline      ; then jump end of line
type7good:    glo       r7             ; get low byte of argument
              call      output         ; and output it
              lbr       endofline      ; then done

endofline:    hlpr      load_rf,lines  ; update lines assembled
              inc       rf
              hlpr      save_rf,lines
              hlpr      load_d,pass    ; get current pass
              smi       1              ; check for pass 1
              lbz       fileloop       ; read and process next line

              hlpr      load_rf,lstpos ; point to end of line
              hlpr      load_d,lstbytes ; get number of lst bytes
              plo       r8             ; keep a copy
              phi       r8
              lbz       pad_zero       ; need padding if no bytes output
pad_loop:     glo       r8             ; get bytes
              ani       3              ; see if padding needed
              lbz       pad_done       ; jump if done with padding
pad_zero:     op        incopy         ; add padding
              db        '   ',0
              inc       r8             ; increment count
              lbr       pad_loop       ; loop until 4 bytes added
pad_done:     ghi       r8             ; see if source line already printed
              ani       0fch
              lbnz      now_show       ; jump if so
              op        incopy         ; space since final bytes
              db        '  ',0
              mov       rd,rf          ; set destination
              mov       rf,line        ; point to source line
              call      f_strcpy       ; and copy line onto list line
now_show:     hlpr      load_d,flags   ; get flags
              ani       F_SHOWLIST     ; see if -l was specified
              lbz       no_showlist    ; jump if not
              mov       rf,lstline
              call      o_msg
              call      o_inmsg
              db        10,13,0
no_showlist:  hlpr      load_d,flags   ; get flags
              ani       F_LISTFILE     ; see if list file specified
              lbz       no_listfile    ; jump if not
              call      writelstfile   ; write list file
no_listfile:  lbr       fileloop


done:         call      o_close        ; close source file
              rtn

              endp

