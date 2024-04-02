#include      macros.inc
#include      bios.inc
#include      kernel.inc

              org       2000h

              extrn     appendext
              extrn     asmpass
              extrn     dopublics
              extrn     initasm
              extrn     itoa16
              extrn     ltrim
              extrn     showsymbols
              extrn     writeoutput

F_SHOWLIST:   equ       1
F_LISTFILE:   equ       2
F_SHOWSYM:    equ       4
F_1805:       equ       8

begin:        br        start
              eever
              db        'Written by Michael H. Riley',0

start:        mov       rf,K_VER       ; get kernel version
              lda       rf
              smi       5              ; must be 5+
              lbdf      start2         ; jump if valid version
              call      o_inmsg        ; display error
              db        'Requires Elf/OS 5+',10,13,0
              ldi       014h           ; set return code
              rtn                      ; return to caller

iaddr:        dw        0
action:       db        0
cldefines:    dw        0
defines:      dw        0
nests:        db        0,0,0,0,0,0,0,0,0,0
numnests:     db        0
flags:        db        0
pass:         db        0
errors:       dw        0
lines:        dw        0
bytes:        dw        0
address:      dw        0
nextlabel:    dw        0
linecount:    dw        0
outbytes:     ds        16
outcount:     db        0
outaddress:   dw        0
startaddr:    dw        0
nstack:       dw        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ostack:       db        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
build:        dw        0
isextrn:      db        0
islocal:      db        0
extrntype:    db        0
extrnlabel:   dw        0
extrnlow:     db        0
scope:        dw        0
label:        ds        32

; ***************************************
; ***** Helper functions tied to R9 *****
; ***************************************
              org       ($+255) & 0ff00h
              sep       r3
helpers:      plo       re             ; save D
              lda       r3             ; get instruction
              plo       r9             ; jump to instruction
save_d:       glo       rf             ; save rf
              stxd
              ghi       rf
              str       r2
              lda       r3             ; set rf to inline address
              phi       rf
              lda       r3
              plo       rf
              glo       re             ; get D
              str       rf             ; and save it
restore_rf:   ldxa                     ; recover rf
              phi       rf
              ldx
              plo       rf
              glo       re             ; recover D
              br        helpers-1      ; and return to caller

load_d:       glo       rf             ; save rf
              stxd
              ghi       rf
              str       r2
              lda       r3             ; set rf to inline address
              phi       rf
              lda       r3
              plo       rf
              ldn       rf             ; get value from address
              plo       re             ; save it
              br        restore_rf     ; and then clean up and return

save_rf:      glo       ra             ; save ra
              stxd
              ghi       ra
              str       r2
              lda       r3             ; get address from inline
              phi       ra
              lda       r3
              plo       ra
              ghi       rf             ; save rf at address
              str       ra
              inc       ra
              glo       rf
              str       ra
restore_ra:   ldxa                     ; restore ra
              phi       ra
              ldx
              plo       ra
              br        helpers-1      ; then return

save_r8:      glo       ra             ; save ra
              stxd
              ghi       ra
              str       r2
              lda       r3             ; get address from inline
              phi       ra
              lda       r3
              plo       ra
              ghi       r8             ; save rf at address
              str       ra
              inc       ra
              glo       r8
              str       ra
              br        restore_ra

save_ra:      glo       rf             ; save rf
              stxd
              ghi       rf
              str       r2
              lda       r3             ; get address from inline
              phi       rf
              lda       r3
              plo       rf
              ghi       ra             ; save rf at address
              str       rf
              inc       rf
              glo       ra
              str       rf
              ldxa
              phi       rf
              ldx
              plo       rf
              br        helpers-1

load_rf:      lda       r3             ; get address
              phi       rf
              lda       r3
              plo       rf
              lda       rf             ; retrieve the value
              plo       re
              lda       rf
              plo       rf
              glo       re
              phi       rf
              br        helpers-1

load_ra:      lda       r3             ; get address
              phi       ra
              lda       r3
              plo       ra
              lda       ra             ; retrieve the value
              plo       re
              lda       ra
              plo       ra
              glo       re
              phi       ra
              br        helpers-1

load_rb:      lda       r3             ; get address
              phi       rb
              lda       r3
              plo       rb
              lda       rb             ; retrieve the value
              plo       re
              lda       rb
              plo       rb
              glo       re
              phi       rb
              br        helpers-1

load_rc:      lda       r3             ; get address
              phi       rc
              lda       r3
              plo       rc
              lda       rc             ; retrieve the value
              plo       re
              lda       rc
              plo       rc
              glo       re
              phi       rc
              br        helpers-1

load_rd:      lda       r3             ; get address
              phi       rd
              lda       r3
              plo       rd
              lda       rd             ; retrieve the value
              plo       re
              lda       rd
              plo       rd
              glo       re
              phi       rd
              br        helpers-1

load_r8:      lda       r3             ; get address
              phi       r8
              lda       r3
              plo       r8
              lda       r8             ; retrieve the value
              plo       re
              lda       r8
              plo       r8
              glo       re
              phi       r8
              br        helpers-1

load_r7:      lda       r3             ; get address
              phi       r7
              lda       r3
              plo       r7
              lda       r7             ; retrieve the value
              plo       re
              lda       r7
              plo       r7
              glo       re
              phi       r7
              br        helpers-1

opush_in:     lda       r3
opush:        str       r8
              inc       r8
              glo       rb
              adi       1
              plo       rb
              br        helpers-1

opush_d:      glo       re
              br        opush
           
npush:        ghi       ra
              str       r7
              inc       r7
              glo       ra
              str       r7
              inc       r7
              ghi       rb
              adi       1
              phi       rb
              br        helpers-1
              
incopy:       lda       r3
              str       rf
              inc       rf
              bnz       incopy
              dec       rf
              br        helpers-1

addrf:        lda       r3
              str       r2
              glo       rf
              add
              plo       rf
              ghi       rf
              adci      0
              phi       rf
              br        helpers-1

andrf:        lda       r3
              str       r2
              glo       rf
              and
              plo       rf
              br        helpers-1

; ***************************************


start2:       call      initasm        ; initialize
              lbnf      initgood       ; jump if initialization was good
              ldi       09h            ; set return code
              rtn                      ; and return to caller
initgood:     ldn       ra             ; get byte from cl
              lbnz      havename       ; jump if name given
              call      o_inmsg        ; display usage message
              db        'asm [options] srcname',10,13,0
              ldi       0ah            ; set return code
              rtn                      ; and return to caller
havename:     mov       r7,srcfile     ; point to filenames
              mov       r8,objfile
              mov       rb,lstfile
fnloop:       lda       ra             ; get next byte from cl
              plo       re             ; keep a copy
              smi       33             ; must be 33 or higher
              lbnf      donenames      ; jump if done with names
              glo       re
              str       r7             ; store byte into names
              str       r8
              str       rb
              inc       r7             ; increment pointers
              inc       r8
              inc       rb
              lbr       fnloop         ; loop until done copying name
donenames:    ldi       0              ; terminate names
              str       r7
              str       r8
              str       rb
              mov       rf,objfile     ; point to output file
              call      appendext      ; append .obj
              db        '.obj',0
              mov       rf,lstfile     ; point to list file
              call      appendext      ; append .lst
              db        '.lst',0

              call      o_inmsg
              db        'File: ',0
              mov       rf,srcfile
              call      o_msg
              call      o_inmsg
              db        10,13,10,13,0

              ldi       1
              hlpr      save_d,pass    ; set assembly pass
              call      asmpass        ; assembly pass

              hlpr      load_rf,errors ; need to see if errors in pass 1
              glo       rf
              str       r2
              ghi       rf
              or
              lbz       do_pass2       ; do pass 2 if no errors in pass 1
              call      o_inmsg        ; display abort message
              db        'Aborting due to errors in pass 1',10,13,0
              ldi       0ffh           ; set error return
              rtn                      ; and return to os
             
do_pass2:     mov       rf,objfile
              mov       rd,objfildes
              mov       r7,3
              call      o_open
              hlpr      load_d,flags   ; get flags
              ani       F_LISTFILE     ; check for list file
              lbz       nolstfile      ; jump if no lst file
              mov       rf,lstfile     ; point to lst filename
              mov       rd,lstfildes   ; point to lst fildes
              mov       r7,3           ; create/truncate
              call      o_open

nolstfile:    ldi       2
              hlpr      save_d,pass    ; set assembly pass
              call      asmpass        ; assembly pass
              call      writeoutput    ; output any remaining bytes

              call      dopublics      ; output any defined publics

              hlpr      load_rf,startaddr ; get start address
              ghi       rf             ; check for -1
              smi       0ffh
              lbnz      write_start    ; write start if not -1
              glo       rf
              smi       0ffh
              lbz       no_start
write_start:  mov       rf,buffer      ; point to buffer
              ldi       '@'            ; write start record
              str       rf
              inc       rf
              hlpr      load_rd,startaddr
              call      f_hexout4
              ldi       10
              str       rf
              inc       rf
              ldi       13
              str       rf
              mov       rf,buffer,
              mov       rc,7
no_start:     mov       rd,objfildes
              call      o_write
              call      o_close

              hlpr      load_d,flags   ; get flags
              ani       F_LISTFILE     ; what there a .lst file
              lbz       nolstclose     ; jump if no need to close lst file
              mov       rd,lstfildes   ; point to .lst fildes
              call      o_close        ; and close it

nolstclose:   call      o_inmsg
              db        10,13,'Lines Assembled   : ',0
              hlpr      load_rc,lines
              mov       rd,buffer
              call      itoa16
              mov       rf,buffer
              call      o_msg

              call      o_inmsg
              db        10,13,'Code Generated    : ',0
              hlpr      load_rc,bytes
              mov       rd,buffer
              call      itoa16
              mov       rf,buffer
              call      o_msg

              call      o_inmsg
              db        10,13,'Errors            : ',0
              hlpr      load_rc,errors
              mov       rd,buffer
              call      itoa16
              mov       rf,buffer
              call      o_msg
              call      o_inmsg
              db        10,13,10,13,0
              ldi       0

              hlpr      load_d,flags   ; get flags
              ani       F_SHOWSYM      ; see if symbols were requested
              lbz       return         ; jump if not
              call      showsymbols    ; otherwise display symbols

return:       rtn
              
buffer:       ds        64
srcfile:      ds        128
objfile:      ds        128
lstfile:      ds        128
line:         ds        256
lstline:      ds        256
outline:      ds        256
srcfildes:    dw        0,0             ; file pointer
srcdta:       dw        0               ; dta
              dw        0               ; eof
              db        0               ; flags
              dw        0,0             ; dir sector
              dw        0               ; dir offset
srcsector:    dw        0,0             ; current sector
              db        0               ; readln bytes remaining
              dw        0               ; readln buffer pointer
              ds        80              ; readln buffer
dta:          ds        512
objfildes:    db        0,0,0,0
              dw        objdta
              ds        13
objdta:       ds        512
lstfildes:    db        0,0,0,0
              dw        lstdta
              ds        13
lstdta:       ds        512
incstack:     ds        104*4
incsp:        dw        0
inccount:     db        0
lstpos:       dw        0
lstbytes:     db        0

              public    action
              public    address
              public    addrf
              public    andrf
              public    buffer
              public    build
              public    bytes
              public    cldefines
              public    defines
              public    dta
              public    errors
              public    extrnlabel
              public    extrnlow
              public    extrntype
              public    flags
              public    helpers
              public    iaddr
              public    incstack
              public    incsp
              public    inccount
              public    incopy
              public    isextrn
              public    islocal
              public    label
              public    load_d
              public    load_r7
              public    load_r8
              public    load_ra
              public    load_rb
              public    load_rd
              public    load_rf
              public    line
              public    lines
              public    linecount
              public    lstbytes
              public    lstfildes
              public    lstdta
              public    lstline
              public    lstpos
              public    nests
              public    nextlabel
              public    npush
              public    nstack
              public    numnests
              public    objfildes
              public    objdta
              public    opush_in
              public    opush_d
              public    ostack
              public    outaddress
              public    outbytes
              public    outcount
              public    outline
              public    pass
              public    save_d
              public    save_r8
              public    save_ra
              public    save_rf
              public    scope
              public    srcfile
              public    srcfildes
              public    srcsector
              public    startaddr
              public    F_1805
              public    F_LISTFILE
              public    F_SHOWLIST
              public    F_SHOWSYM

              end       begin



