#include      macros.inc
#include      bios.inc
#include      kernel.inc

#define OP_LOW  094h
#define OP_HIGH 093h
#define OP_SGN  092h
#define OP_ABS  091h
#define OP_DOT  080h
#define OP_MUL  070h
#define OP_DIV  071h
#define OP_MOD  072h
#define OP_ADD  060h
#define OP_SUB  061h
#define OP_SHR  050h
#define OP_SHL  051h
#define OP_AND  040h
#define OP_OR   041h
#define OP_XOR  042h
#define OP_NOT  043h
#define OP_EQ   030h
#define OP_NE   031h
#define OP_LT   032h
#define OP_GT   033h
#define OP_LTE  034h
#define OP_GTE  035h
#define OP_LAND 020h
#define OP_LOR  021h
#define OP_CP   010h
#define OP_OP   002h
#define OP_END  001h
#define OP_NUM  000h

              proc      getarg

              extrn     address
              extrn     build
              extrn     convertnum
              extrn     div16
              extrn     error
              extrn     extrntype
              extrn     findlabel
              extrn     isextrn
              extrn     islocal
              extrn     load_d
              extrn     load_ra
              extrn     ltrimrf
              extrn     mul16
              extrn     npush
              extrn     nstack
              extrn     ostack
              extrn     opush_in
              extrn     opush_d
              extrn     pass
              extrn     save_d
              extrn     strcasecmpin
              extrn     writeextrn
              extrn     writelocal

              ldi       '?'            ; set extrn type to 16-bits
              hlpr      save_d,extrntype
              ldi       0              ; clear isextrn flag
              hlpr      save_d,isextrn
              hlpr      save_d,islocal ; clear local flag
              mov       r7,nstack      ; point to number stack
              mov       r8,ostack      ; point to operator stack
              ldi       0              ; clear stack counters
              phi       rb
              plo       rb
mainloop:     ldn       rf             ; get byte from input
              lbz       done           ; jump if end of input
term_loop:    call      ltrimrf        ; move past any spaces
              ldn       rf             ; get byte from input
              lbnz      term_go        ; jump if non zero
              call      o_inmsg        ; display error
              db        'Error: Unexpected end of expression',10,13,0
              call      error          ; call error routine
              smi       0              ; signal error
              rtn                      ; and return to caller

term_go:      ldn       rf             ; get character
              smi       '('            ; check for open parens
              lbnz      term_no1       ; jump if not
              op2       opush_in,OP_OP ; push open parens to operator stack
              inc       rf             ; move past parens
              lbr       term_loop      ; then look for next term

term_no1:     ldn       rf             ; get character
              smi       '~'            ; check for not
              lbnz      term_no1a      ; jump if not
              op2       opush_in,OP_NOT ; push not operator
              inc       rf             ; move past ~
              lbr       term_loop      ; then look for next term

term_no1a:    call      strcasecmpin   ; check for 'abs('
              db        'abs(',0
              lbnf      term_no2       ; jump if not
              op2       opush_in,OP_ABS
              op2       opush_in,OP_OP
              lbr       term_loop      ; keep looking for terms

term_no2:     call      strcasecmpin   ; check for 'sgn('
              db        'sgn(',0
              lbnf      term_no3       ; jump if not
              op2       opush_in,OP_SGN
              op2       opush_in,OP_OP
              lbr       term_loop      ; keep looking for terms

term_no3:     call      strcasecmpin   ; check for 'high '
              db        'high ',0
              lbnf      term_no4       ; jump if not
              op2       opush_in,OP_HIGH
              lbr       term_loop      ; keep looking for terms

term_no4:     call      strcasecmpin   ; check for 'low '
              db        'low ',0
              lbnf      term_no5       ; jump if not
              op2       opush_in,OP_LOW
              lbr       term_loop      ; keep looking for terms

term_no5:     call      strcasecmpin   ; check for [month]
              db        '[month]',0
              lbnf      term_no6
              mov       ra,K_MONTH     ; retrieve build month
              ldn       ra
              plo       ra
              ldi       0
              phi       ra
              op        npush          ; push to numeric stack
              lbr       op_loop        ; have a term

term_no6:     call      strcasecmpin   ; check for [day]
              db        '[day]',0
              lbnf      term_no7
              mov       ra,K_DAY       ; retrieve build day
              ldn       ra
              plo       ra
              ldi       0
              phi       ra
              op        npush          ; push to numeric stack
              lbr       op_loop        ; have a term

term_no7:     call      strcasecmpin   ; check for [year]
              db        '[year]',0
              lbnf      term_no8
              mov       ra,K_YEAR      ; retrieve build day
              ldn       ra
              adi       0b4h           ; add 1972
              plo       ra
              ldi       0
              adci      07h
              phi       ra
              op        npush          ; push to numeric stack
              lbr       op_loop        ; have a term

term_no8:     call      strcasecmpin   ; check for [hour]
              db        '[hour]',0
              lbnf      term_no9
              mov       ra,K_HOUR      ; retrieve build hour
              ldn       ra
              plo       ra
              ldi       0
              phi       ra
              op        npush          ; push to numeric stack
              lbr       op_loop        ; have a term

term_no9:     call      strcasecmpin   ; check for [minute]
              db        '[minute]',0
              lbnf      term_no10
              mov       ra,K_MINUTE    ; retrieve build minute
              ldn       ra
              plo       ra
              ldi       0
              phi       ra
              op        npush          ; push to numeric stack
              lbr       op_loop        ; have a term

term_no10:    call      strcasecmpin   ; check for [second]
              db        '[second]',0
              lbnf      term_no11
              mov       ra,K_SECOND    ; retrieve build second
              ldn       ra
              plo       ra
              ldi       0
              phi       ra
              op        npush          ; push to numeric stack
              lbr       op_loop        ; have a term

term_no11:    call      strcasecmpin   ; check for [build]
              db        '[build]',0
              lbnf      term_no12
              mov       ra,build       ; retrieve build number
              lda       ra
              plo       re
              lda       ra
              plo       ra
              glo       re
              phi       ra
              op        npush          ; push to numeric stack
              lbr       op_loop        ; have a term

term_no12:    push      rb             ; save consumed registers
              push      rc
              call      convertnum     ; attempt converting a number
              pop       rc
              pop       rb
              lbdf      term_no13      ; jump if not a number
              op        npush          ; push number onto numeric stack
              lbr       op_loop        ; done with term

term_no13:    call      findlabel      ; see if term is a label reference
              lbdf      term_no14      ; jump if label not found
              ldn       ra             ; get label flags
              ani       1              ; check for external reference
              lbz       not_extrn      ; jump if not
              hlpr      save_d,isextrn ; signal extern used
not_extrn:    lda       ra             ; recover flags
              ani       0ch            ; check for local reference
              lbz       not_local      ; jump if not local
              hlpr      save_d,islocal ; signal local variable
not_local:    inc       ra             ; move past scope
              inc       ra
              lda       ra             ; retrieve value
              plo       re
              lda       ra
              plo       ra
              glo       re
              phi       ra
              op        npush          ; push to numeric stack
              lbr       op_loop        ; done with term

term_no14:    hlpr      load_d,pass    ; get current pass
              smi       2              ; check for pass 2
              lbz       term_fail      ; jump if failed term
              op        npush          ; push to numeric stack
              lbr       op_loop   

term_fail:    call      o_inmsg        ; display error
              db        'Non-number found',10,13,0
              call      error
              rtn                      ; and return to caller

op_loop:      call      ltrimrf        ; move past any spaces
              ldn       rf             ; Get byte for operation
              lbnz      op_no_1        ; jump if not end of line
              ldi       OP_END         ; is the end
              lbr       do_op          ; perform operation

op_no_1:      call      findop         ; find operation
              lbnf      do_op          ; perform operation
              call      o_inmsg        ; display error
              db        'Error: Invalid OP: ',0
              ldn       rf             ; get byte from op
              call      o_type         ; and display it
              call      o_inmsg
              db        10,13,0
              call      error          ; process error
              rtn                      ; and return to caller

do_op:        stxd                     ; save a copy of the operation
              ani       0f0h           ; keep only high nybble
              str       r2             ; store for comparison
              glo       rb             ; get ostack
              lbz       exec_done      ; jump if no operations stacked
              dec       r8             ; get top of operation stack
              lda       r8
              plo       re             ; save operation
              ani       0f0h           ; keep only high nybble
              sm                       ; see if stacked operation higher priority
              lbnf      exec_done      ; jump if not
              dec       r8             ; decrement ostack pointer
exec_op:      ghi       rb             ; decrement nstack
              smi       1
              phi       rb
              glo       rb             ; decrement ostack
              smi       1
              plo       rb
              glo       re             ; recover operation
              smi       OP_ADD         ; check for add
              lbz       opr_add
              glo       re             ; recover operation
              smi       OP_SUB         ; check for subtract
              lbz       opr_sub
              glo       re             ; recover operation
              smi       OP_MUL         ; check for multiply
              lbz       opr_mul
              glo       re             ; recover operation
              smi       OP_DIV         ; check for division
              lbz       opr_div
              glo       re             ; recover operation
              smi       OP_MOD         ; check for modulo
              lbz       opr_mod
              glo       re             ; recover operation
              smi       OP_SHL         ; check for shift left
              lbz       opr_shl
              glo       re             ; recover operation
              smi       OP_SHR         ; check for shift right
              lbz       opr_shr
              glo       re             ; recover operation
              smi       OP_AND         ; check for and
              lbz       opr_and
              glo       re             ; recover operation
              smi       OP_OR          ; check for or
              lbz       opr_or
              glo       re             ; recover operation
              smi       OP_NOT         ; check for not
              lbz       opr_not
              glo       re             ; recover operation
              smi       OP_LAND        ; check for logical and
              lbz       opr_land
              glo       re             ; recover operation
              smi       OP_LOR         ; check for logical or
              lbz       opr_lor
              glo       re             ; recover operation
              smi       OP_XOR         ; check for xor
              lbz       opr_xor
              glo       re             ; recover operation
              smi       OP_EQ          ; check for equal
              lbz       opr_eq
              glo       re             ; recover operation
              smi       OP_NE          ; check for not equal
              lbz       opr_ne
              glo       re             ; recover operation
              smi       OP_LT          ; check for less than
              lbz       opr_lt
              glo       re             ; recover operation
              smi       OP_LTE         ; check for less than or equal
              lbz       opr_lte
              glo       re             ; recover operation
              smi       OP_GT          ; check for greater than
              lbz       opr_gt
              glo       re             ; recover operation
              smi       OP_GTE         ; check for greater than or equal
              lbz       opr_gte
              glo       re             ; recover operation
              smi       OP_ABS         ; check for absolute value
              lbz       opr_abs
              glo       re             ; recover operation
              smi       OP_HIGH        ; check for high
              lbz       opr_high
              glo       re             ; recover operation
              smi       OP_LOW         ; check for low
              lbz       opr_low
              glo       re             ; recover operation
              smi       OP_DOT         ; check for .
              lbz       opr_dot
              glo       re             ; recover operation
              smi       OP_SGN         ; check for sgn
              lbz       opr_sgn
              call      o_inmsg        ; display error
              db        'Error: Unknown operation',10,13,0
              call      error
              rtn                      ; return to caller

opr_abs:      ghi       rb             ; increment nstack
              adi       1
              phi       rb
              dec       r7             ; move to msb of nstack
              dec       r7
              lda       r7             ; retrieve it
              inc       r7             ; leave r7 at original location
              shl                      ; check sign bit
              lbnf      opr_done       ; if positive, nothing to do
              dec       r7             ; 2s compliment number
              ldn       r7
              xri       0ffh
              adi       1
              str       r7
              dec       r7
              ldn       r7
              xri       0ffh
              adci      0
              str       r7
              inc       r7             ; put r7 back
              inc       r7
              lbr       opr_done       ; and done
              
opr_add:      dec       r7             ; move to lsb of nstack
              ldn       r7             ; retrieve it
              str       r2             ; store for add
              dec       r7             ; move to lsb of nstack-1
              dec       r7
              ldn       r7             ; retrieve it
              add                      ; add
              str       r7             ; and store back
              inc       r7             ; move to msb of nstack
              ldn       r7             ; retrieve it
              str       r2             ; store for add
              dec       r7             ; move to msb of nstack-1
              dec       r7
              ldn       r7             ; retrieve it
              adc                      ; and add
              str       r7             ; put it back
              inc       r7             ; put r7 back to nstack
              inc       r7
              lbr       opr_done       ; then done

opr_and:      dec       r7             ; move to lsb of nstack
              ldn       r7             ; retrieve it
              str       r2             ; store for add
              dec       r7             ; move to lsb of nstack-1
              dec       r7
              ldn       r7             ; retrieve it
              and                      ; and
              str       r7             ; and store back
              inc       r7             ; move to msb of nstack
              ldn       r7             ; retrieve it
              str       r2             ; store for add
              dec       r7             ; move to msb of nstack-1
              dec       r7
              ldn       r7             ; retrieve it
              and                      ; and
              str       r7             ; put it back
              inc       r7             ; put r7 back to nstack
              inc       r7
              lbr       opr_done       ; then done

opr_cmp:      dec       r7             ; get nstack - nstack-1
              ldn       r7
              str       r2
              dec       r7
              dec       r7
              lda       r7
              sm
              plo       ra
              ldn       r7
              str       r2
              dec       r7
              dec       r7
              lda       r7
              smb
              phi       ra
              inc       r7
              rtn

opr_div:      push      rc             ; save registers
              push      rd
              dec       r7             ; retrieve second value
              ldn       r7
              plo       rd
              dec       r7
              ldn       r7
              phi       rd
              dec       r7
              ldn       r7             ; retrieve first value
              plo       rc
              dec       r7
              ldn       r7
              phi       rc
              call      div16          ; perform division
              ghi       rd             ; write result
              str       r7
              inc       r7
              glo       rd
              str       r7
              inc       r7
              pop       rd
              pop       rc
              lbr       opr_done

opr_dot:      ghi       rb
              smi       1
              phi       rb
              dec       r7             ; get lsb of nstack
              ldn       r7
              dec       r7             ; then move to msb
              shr                      ; shift low bit into DF
              lbnf      opr_low        ; if zero then same as LOW
              lbr       opr_high       ; if nonzero then same as HIGH

opr_eq:       call      opr_cmp        ; get comparison
              glo       ra             ; check for zero
              lbnz      opr_false      ; false if not
              ghi       ra
              lbnz      opr_false
              lbr       opr_true

opr_ne:       call      opr_cmp        ; get comparison
              glo       ra             ; check for zero
              lbnz      opr_true       ; true if not
              ghi       ra
              lbnz      opr_true
              lbr       opr_false

opr_lt:       call      opr_cmp        ; get comparison
              ghi       ra             ; need sign bit
              shl
              lbdf      opr_true       ; true if negative
              lbr       opr_false      ; otherwise false

opr_lte:      call      opr_cmp        ; get comparison
              glo       ra             ; perform zero check
              str       r2
              ghi       ra
              or
              lbz       opr_true       ; true if zero
              ghi       ra             ; need sign bit
              shl
              lbdf      opr_true       ; true if negative
              lbr       opr_false      ; otherwise false

opr_gt:       call      opr_cmp        ; get comparison
              glo       ra             ; perform zero check
              str       r2
              ghi       ra
              or
              lbz       opr_false      ; false if zero
              ghi       ra             ; need sign bit
              shl
              lbdf      opr_false      ; false if negative
              lbr       opr_true       ; otherwise true

opr_gte:      call      opr_cmp        ; get comparison
              glo       ra             ; perform zero check
              str       r2
              ghi       ra
              or
              lbz       opr_true       ; true if zero
              ghi       ra             ; need sign bit
              shl
              lbdf      opr_false      ; false if negative
              lbr       opr_true       ; otherwise true

opr_false:    dec       r7             ; move to msb
              dec       r7
              ldi       0              ; set to zero
              str       r7
              inc       r7
              str       r7
              inc       r7
              lbr       opr_done       ; then done

opr_true:     dec       r7             ; move to msb
              dec       r7
              ldi       0ffh           ; set to -1
              str       r7
              inc       r7
              str       r7
              inc       r7
              lbr       opr_done       ; then done
           
opr_high:     dec       r7             ; move to msb of nstack
              dec       r7
              ldn       r7             ; retrieve it
              plo       re             ; set aside
              ldi       0              ; high byte needs to be zero
              str       r7
              inc       r7
              glo       re             ; set lsb to msb
              str       r7
              inc       r7
              ghi       rb             ; increment nstack
              adi       1
              phi       rb
              ldi       '/'            ; set extrn type to high
              hlpr      save_d,extrntype
              lbr       opr_done       ; then done

opr_land:     dec       r7             ; move to lsb of nstack
              ldn       r7             ; retrieve it
              str       r2             ; store for add
              dec       r7             ; move to lsb of nstack-1
              dec       r7
              ldn       r7             ; retrieve it
              and                      ; and
              str       r7             ; and store back
              inc       r7             ; move to msb of nstack
              ldn       r7             ; retrieve it
              str       r2             ; store for add
              dec       r7             ; move to msb of nstack-1
              dec       r7
              ldn       r7             ; retrieve it
              and                      ; and
              str       r7             ; put it back
              inc       r7             ; put r7 back to nstack
              inc       r7
              lbr       opr_done       ; then done

opr_lor:      dec       r7             ; move to lsb of nstack
              ldn       r7             ; retrieve it
              str       r2             ; store for add
              dec       r7             ; move to lsb of nstack-1
              dec       r7
              ldn       r7             ; retrieve it
              or                       ; or
              str       r7             ; and store back
              inc       r7             ; move to msb of nstack
              ldn       r7             ; retrieve it
              str       r2             ; store for add
              dec       r7             ; move to msb of nstack-1
              dec       r7
              ldn       r7             ; retrieve it
              or                       ; or
              str       r7             ; put it back
              inc       r7             ; put r7 back to nstack
              inc       r7
              lbr       opr_done       ; then done

opr_low:      dec       r7             ; move to msb of nstack
              dec       r7
              ldi       0              ; zero it
              str       r7
              inc       r7             ; and move back
              inc       r7
              ghi       rb             ; increment nstack
              adi       1
              phi       rb
              ldi       '\'            ; set extrn type to low
              hlpr      save_d,extrntype
              lbr       opr_done

opr_mod:      push      rc             ; save registers
              push      rd
              dec       r7             ; retrieve second value
              ldn       r7
              plo       rd
              dec       r7
              ldn       r7
              phi       rd
              dec       r7
              ldn       r7             ; retrieve first value
              plo       rc
              dec       r7
              ldn       r7
              phi       rc
              call      div16          ; perform division
              ghi       rc             ; write remainder
              str       r7
              inc       r7
              glo       rc
              str       r7
              inc       r7
              pop       rd
              pop       rC
              lbr       opr_done

opr_mul:      push      rc             ; save registers
              push      rd
              dec       r7             ; retrieve second value
              ldn       r7
              plo       rd
              dec       r7
              ldn       r7
              phi       rd
              dec       r7
              ldn       r7             ; retrieve second value
              plo       rc
              dec       r7
              ldn       r7
              phi       rc
              call      mul16          ; perform multiplication
              ghi       rc             ; write result
              str       r7
              inc       r7
              glo       rc
              str       r7
              inc       r7
              pop       rd
              pop       rc
              lbr       opr_done

opr_not:      dec       r7             ; move to lsb of nstack
              ldn       r7             ; retrieve it
              xri       0ffh           ; invert the bits
              str       r7             ; and put it back
              dec       r7             ; move to msb
              ldn       r7             ; retrieve it
              xri       0ffh           ; invert the bits
              str       r7             ; and put it back
              inc       r7             ; retstore r7
              inc       r7
              ghi       rb             ; increment nstack
              adi       1
              phi       rb
              lbr       opr_done       ; then done

opr_or:       dec       r7             ; move to lsb of nstack
              ldn       r7             ; retrieve it
              str       r2             ; store for add
              dec       r7             ; move to lsb of nstack-1
              dec       r7
              ldn       r7             ; retrieve it
              or                       ; or
              str       r7             ; and store back
              inc       r7             ; move to msb of nstack
              ldn       r7             ; retrieve it
              str       r2             ; store for add
              dec       r7             ; move to msb of nstack-1
              dec       r7
              ldn       r7             ; retrieve it
              or                       ; or
              str       r7             ; put it back
              inc       r7             ; put r7 back to nstack
              inc       r7
              lbr       opr_done       ; then done

opr_shl:      dec       r7             ; retrieve shift count
              ldn       r7
              plo       rc
              dec       r7
              ldn       r7
              phi       rc
              dec       r7             ; get number to shift
              ldn       r7
              plo       ra
              dec       r7
              ldn       r7
              phi       ra
shl_loop:     ghi       rc             ; see if done
              str       r2
              glo       rc
              or
              lbz       shl_done       ; jump if so
              glo       ra             ; otherwise shift number
              shl
              plo       ra
              ghi       ra
              shlc
              phi       ra
              dec       rc             ; decrement count
              lbr       shl_loop       ; loop until done
shl_done:     ghi       ra             ; store result
              str       r7
              inc       r7
              glo       ra
              str       r7
              inc       r7
              lbr       opr_done       ; then done

opr_sgn:      ghi       rb             ; increment nstack
              adi       1
              phi       rb
              dec       r7             ; move to lsb
              ldn       r7             ; retrieve it
              str       r2             ; store for zero check
              dec       r7             ; move to msb
              ldn       r7             ; retreive it
              or                       ; zero check
              lbz       opr_sgn_0      ; jump if zeron
              ldn       r7             ; retrieve msb
              shl                      ; shift sign bit to DF
              lbnf      opr_sgn_1      ; jump if positive
              ldi       0ffh           ; set value to -1
              str       r7
              inc       r7
              str       r7
              inc       r7
              lbr       opr_done       ; then done
opr_sgn_1:    ldi       0              ; set value to 1
              str       r7
              inc       r7
              ldi       1
              str       r7
              inc       r7
              lbr       opr_done
opr_sgn_0:    inc       r7             ; restore r7
              inc       r7
              lbr       opr_done       ; then done

opr_shr:      dec       r7             ; retrieve shift count
              ldn       r7
              plo       rc
              dec       r7
              ldn       r7
              phi       rc
              dec       r7             ; get number to shift
              ldn       r7
              plo       ra
              dec       r7
              ldn       r7
              phi       ra
shr_loop:     ghi       rc             ; see if done
              str       r2
              glo       rc
              or
              lbz       shr_done       ; jump if so
              ghi       ra             ; otherwise shift number
              shr
              phi       ra
              glo       ra
              shrc
              plo       ra
              dec       rc             ; decrement count
              lbr       shr_loop       ; loop until done
shr_done:     ghi       ra             ; store result
              str       r7
              inc       r7
              glo       ra
              str       r7
              inc       r7
              lbr       opr_done       ; then done
              
opr_sub:      dec       r7             ; move to lsb of nstack
              ldn       r7             ; retrieve it
              str       r2             ; store for add
              dec       r7             ; move to lsb of nstack-1
              dec       r7
              ldn       r7             ; retrieve it
              sm                       ; subtract
              str       r7             ; and store back
              inc       r7             ; move to msb of nstack
              ldn       r7             ; retrieve it
              str       r2             ; store for add
              dec       r7             ; move to msb of nstack-1
              dec       r7
              ldn       r7             ; retrieve it
              smb                      ; and subtract
              str       r7             ; put it back
              inc       r7             ; put r7 back to nstack
              inc       r7
              lbr       opr_done       ; then done

opr_xor:      dec       r7             ; move to lsb of nstack
              ldn       r7             ; retrieve it
              str       r2             ; store for add
              dec       r7             ; move to lsb of nstack-1
              dec       r7
              ldn       r7             ; retrieve it
              xor                      ; xor
              str       r7             ; and store back
              inc       r7             ; move to msb of nstack
              ldn       r7             ; retrieve it
              str       r2             ; store for add
              dec       r7             ; move to msb of nstack-1
              dec       r7
              ldn       r7             ; retrieve it
              xor                      ; xor
              str       r7             ; put it back
              inc       r7             ; put r7 back to nstack
              inc       r7
              lbr       opr_done       ; then done
opr_done:     irx                      ; recover current op
              ldx
              lbr       do_op          ; loop back to see if more to execute
exec_done:    irx                      ; recover current op
              ldx
              plo       re             ; keep a copy
              smi       OP_END         ; check for end
              lbz       done           ; jump if finished with expression
              glo       re             ; recover operation
              smi       OP_CP          ; check for close parens
              lbnz      done_notcp     ; jump if not
              dec       r8             ; next operation on ostack
              ldn       r8             ; retrieve it
              smi       OP_OP          ; must be open parens
              lbz       done_isop      ; jump if it is
              call      o_inmsg        ; display error
              db        'Error: Expression error, ) without (',10,13,0
              call      error
              rtn                      ; and return to caller
done_isop:    glo       rb             ; decrement ostack
              smi       1
              plo       rb
              lbr       op_loop        ; then look for next operation

done_notcp:   glo       re             ; recover operation
              str       r8             ; write to operation stack
              inc       r8
              glo       rb             ; increment ostack
              adi       1
              plo       rb
              lbr       mainloop       ; then back to look for next term

done:         ghi       rb             ; get nstack
              lbnz      done_nz        ; jump if not zero
              call      o_inmsg        ; display error
              db        'Error: nstack empty',10,13,0
              call      error
              rtn                      ; and return
done_nz:      smi       1              ; should be only 1 term left
              lbz       done_1         ; jump if so
              call      o_inmsg        ; display error
              db        'Error: Did not reduce to 1 term',10,13,0
              call      error
              rtn                      ; and return
done_1:       dec       r7             ; retrieve final result
              ldn       r7
              plo       re
              dec       r7
              ldn       r7
              phi       r7
              glo       re
              plo       r7
              hlpr      load_d,isextrn ; was an external used
              lbz       notextrn       ; jump if not
              call      writeextrn     ; otherwise write external reference
              lbr       return         ; cannot be local if extrnal reference
notextrn:     hlpr      load_d,islocal ; check for local used
              ani       4              ; check for local variable
              lbz       return         ; jump if not
              call      writelocal     ; otherwise write local reference
return:       rtn                      ; and return to caller

; *******************************************
; ***** Find operation                  *****
; ***** RF - pointer to expression      *****
; ***** Returns: DF=0 - operation found *****
; *****             D - Operation code  *****
; *****          DF=1 - Not found       *****
; *******************************************
findop:       ldi       ops.1
              phi       rc
              ldi       ops.0
              plo       rc
findlp:       push      rf             ; save pointer
findlp2:      ldn       rc             ; get byte from op table
              ani       07fh           ; strip high bit
              str       r2             ; store for compare
              ldn       rf             ; get byte from input
              sm                       ; see if match
              lbnz      findno         ; jump if no match
              inc       rf             ; bump pointer
              lda       rc             ; get byte from ops table
              shl                      ; check for final byte
              lbnf      findlp2        ; loop until final byte
              irx                      ; remove rf from stack
              irx
              ldn       rc             ; get op value
              smi       OP_END         ; check for end
              lbz       findend        ; jump if OP_END
finddone:     ldn       rc             ; get op value
              adi       0              ; signal op found
              rtn                      ; nd return
findend:      dec       rf             ; point back to ending character
              lbr       finddone
findno:       pop       rf             ; recover pointer
findnolp:     lda       rc             ; get byte from ops table
              shl                      ; need high bit
              lbnf      findnolp       ; loop until final byte found
              inc       rc             ; move past op value
              ldn       rc             ; check for end of table
              lbnz      findlp         ; jump if more entries
              smi       0              ; signal not found
              rtn                      ; and return to caller

ops:          db        ','+080h,OP_END
              db        ';'+080h,OP_END
              db        '.'+080h,OP_DOT
              db        '*'+080h,OP_MUL
              db        '/'+080h,OP_DIV
              db        '%'+080h,OP_MOD
              db        '+'+080h,OP_ADD
              db        '-'+080h,OP_SUB
              db        '^'+080h,OP_XOR
              db        ')'+080h,OP_CP
              db        '&','&'+080h,OP_LAND
              db        '&'+080h,OP_AND
              db        '|','|'+080h,OP_LOR
              db        '|'+080h,OP_OR
              db        '=','='+080h,OP_EQ
              db        '='+080h,OP_EQ
              db        '!','='+080h,OP_NE
              db        '<','<'+080h,OP_SHL
              db        '<','>'+080h,OP_NE
              db        '<','='+080h,OP_LTE
              db        '<'+080h,OP_LT
              db        '>','>'+080h,OP_SHR
              db        '>','='+080h,OP_GTE
              db        '>'+080h,OP_GT
              db        0


              endp

; R7 - number stack
; R8 - operator stack
; RB.1 - nstack size
; RB.0 - ostack size
