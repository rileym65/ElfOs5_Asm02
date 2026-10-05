#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ***********************************
; ***** Output an assembed byte *****
; ***** D - byte to output      *****
; ***********************************
              proc      output

              extrn     address
              extrn     bytes
              extrn     flags
              extrn     incopy
              extrn     line
              extrn     load_d
              extrn     load_rf
              extrn     lstbytes
              extrn     lstline
              extrn     lstpos
              extrn     outbytes
              extrn     outcount
              extrn     pass
              extrn     save_d
              extrn     save_rf
              extrn     writeoutput
              extrn     writelstfile
              extrn     F_SHOWLIST
              extrn     F_LISTFILE
              extrn     helpers
              extrn     save
              extrn     restore

              op2       save,r7_+rf_
              mov       r9,helpers
;              push      r7             ; save consumed register
;              push      rf
              glo       re
              stxd                     ; save byte to write
              hlpr      load_d,outcount ; get current byte count
              str       r2             ; store for add
              ldi       outbytes.0     ; find where byte needs to go
              add
              plo       r7
              ldi       outbytes.1
              adci      0
              phi       r7             ; r7 now pointing where byte needs to go
              irx                      ; recover byte
              ldx
              str       r7             ; and write to output buffer

              plo       rd             ; store for hex conversion
              hlpr      load_d,pass    ; get current pass
              smi       1              ; skip if on pass 1
              lbz       pass_1
              hlpr      load_d,flags   ; get flags
              str       r2
              ani       F_SHOWLIST
              lbnz      do_lst
              ldx
              ani       F_LISTFILE
              lbz       pass_1         ; jump if no list options
do_lst:       hlpr      load_rf,lstpos ; get list position
              ldi       ' '            ; write hex value to lst line
              str       rf
              inc       rf
              call      f_hexout2
              ldi       0
              str       rf
              hlpr      save_rf,lstpos
              hlpr      load_d,lstbytes ; get list bytes
              adi       1              ; increment it
              hlpr      save_d,lstbytes ; and put it back
              plo       re             ; keep a copy
              smi       4              ; check for exactly 4
              lbnz      lst_not4       ; jump if not
              op        incopy
              db        '  ',0
              mov       rd,rf          ; point to end of line
              mov       rf,line        ; point to input line
              call      f_strcpy       ; append input line
              lbr       show_list
lst_not4:     glo       re
              ani       3              ; see if 4 bytes have been output
              lbnz      pass_1         ; jump if not
show_list:    hlpr      load_d,flags   ; get flags
              ani       F_SHOWLIST     ; see if show list
              lbz       check_lst      ; jump if not
disp_list:    mov       rf,lstline     ; point to list line
              call      o_msg          ; and display it
              call      o_inmsg
              db        10,13,0
check_lst:    hlpr      load_d,flags   ; recover flags
              ani       F_LISTFILE     ; see if list file requested
              lbz       no_listfile    ; jump if not
              call      writelstfile   ; otherwise write list file
no_listfile:  mov       rf,lstline     ; point back to list line
              op        incopy         ; set initial of secondary lines
              db        '             ',0
              hlpr      save_rf,lstpos ; save lst position



pass_1:       hlpr      load_rf,bytes  ; increment byte count
              inc       rf
              hlpr      save_rf,bytes
              hlpr      load_rf,address ; get assembly address
              inc       rf             ; add 1
              hlpr      save_rf,address ; and put it back
              hlpr      load_d,outcount ; get outcount
              adi       1              ; increment it
              hlpr      save_d,outcount ; nad put it back
              smi       16             ; see if 16 bytes have been output
              lbnz      return         ; jump if not
              call      writeoutput    ; output the current bytes
;return:       pop       rf             ; recover consumed register
;              pop       r7
return:       op2       restore,r7_+rf_
              mov       r9,helpers
              rtn                      ; return to caller

              endp
