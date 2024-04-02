#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      directive

              extrn     address
              extrn     addrf
              extrn     andrf
              extrn     error
              extrn     flags
              extrn     load_d
              extrn     load_rf
              extrn     ltrimrf
              extrn     objfildes
              extrn     outaddress
              extrn     pass
              extrn     save_d
              extrn     save_rf
              extrn     strcasecmpin
              extrn     F_1805
              extrn     F_SHOWLIST
              extrn     F_SHOWSYM
              extrn     writeln
              extrn     writeoutput

              call      strcasecmpin   ; check for .1805
              db        '.1805',0
              lbnf      not_1          ; jump if not
              hlpr      load_d,flags   ; get flags
              ori       F_1805         ; set 1805 flag
              hlpr      save_d,flags   ; write flags back
              rtn                      ; and return to caller
not_1:        call      strcasecmpin   ; check for .list
              db        '.list',0
              lbnf      not_2          ; jump if not
              hlpr      load_d,flags   ; get flags
              ori       F_SHOWLIST     ; set show list flag
              hlpr      save_d,flags   ; write flags back
              rtn                      ; and return to caller
not_2:        call      strcasecmpin   ; check for .sym
              db        '.sym',0
              lbnf      not_3          ; jump if not
              hlpr      load_d,flags   ; get flags
              ori       F_SHOWSYM      ; set show list flag
              hlpr      save_d,flags   ; write flags back
              rtn                      ; and return to caller
not_3:        call      strcasecmpin   ; check for .align
              db        '.align',0
              lbnf      not_4          ; jump if not
              call      ltrimrf        ; move past any spaces
              call      writeoutput    ; write any output
              call      strcasecmpin   ; check for word
              db        'word',0
              lbnf      not_word       ; jump if not
              hlpr      load_rf,address ; get current address
              inc       rf             ; add 1
              op2       andrf,0feh     ; and mask with FE
new_addr:     hlpr      save_rf,address ; write new address
              hlpr      save_rf,outaddress ; and output address
              rtn                      ; then return to caller
not_word:     call      strcasecmpin   ; check for dword
              db        'dword',0
              lbnf      not_dword      ; jump if not
              hlpr      load_rf,address ; get address
              op2       addrf,3        ; add 3
              op2       andrf,0fch     ; and then mask with FC
              lbr       new_addr       ; save new address
not_dword:    call      strcasecmpin   ; check for qword
              db        'qword',0
              lbnf      not_qword      ; jump if not
              hlpr      load_rf,address ; get address
              op2       addrf,7        ; add 7
              op2       andrf,0f8h     ; and then mask with F8
              lbr       new_addr       ; save new address
not_qword:    call      strcasecmpin   ; check for para
              db        'para',0
              lbnf      not_para       ; jump if not
              hlpr      load_rf,address ; get address
              op2       addrf,15       ; add 15
              op2       andrf,0f0h     ; and then mask with F0
              lbr       new_addr       ; save new address
not_para:     call      strcasecmpin   ; check for 32 byte boundary
              db        '32',0
              lbnf      not_32         ; jump if not
              hlpr      load_rf,address ; get address
              op2       addrf,31       ; add 31
              op2       andrf,0e0h     ; and then mask with E0
              lbr       new_addr       ; save new address
not_32:       call      strcasecmpin   ; check for 64 byte boundary
              db        '64',0
              lbnf      not_64         ; jump if not
              hlpr      load_rf,address ; get address
              op2       addrf,63       ; add 63
              op2       andrf,0c0h     ; and then mask with C0
              lbr       new_addr       ; save new address
not_64:       call      strcasecmpin   ; check for 128 byte boundary
              db        '128',0
              lbnf      not_128        ; jump if not
              hlpr      load_rf,address ; get address
              op2       addrf,127      ; add 127
              op2       andrf,080h     ; and then mask with 80
              lbr       new_addr       ; save new address
not_128:      call      strcasecmpin   ; check for page boundary
              db        'page',0
              lbnf      not_page       ; jump if not
              hlpr      load_rf,address ; get address
              op2       addrf,255      ; add 255
              op2       andrf,000h     ; and then mask with 00
              lbr       new_addr       ; save new address

not_4:        call      strcasecmpin   ; check for .link
              db        '.link',0
              lbnf      not_5          ; jump if not
              hlpr      load_d,pass    ; get pass
              smi       2              ; check for pass 2
              lbnz      return         ; do nothing on pass 1
              call      ltrimrf         ; move past any spaces
              mov       rd,objfildes   ; point to ojbect fildes
              call      writeln        ; write line for linker
              rtn                      ; and return to caller

not_5:
not_page:     call      o_inmsg        ; display error
              db        'Error: Invalid directive',10,13,0
              call      error
return:       rtn

              endp

