#include      macros.inc
#include      bios.inc
#include      kernel.inc
 
; *******************************************************
; ***** Lookup assembly opcode                      *****
; ***** RF - pointer to opcode to search for        *****
; ***** Returns: DF=0 - opcode found                *****
; *****            RF - First character after match *****
; *****            RA - Pointer to opcode data      *****
; *******************************************************
              proc      lookupop

              extrn     opinp
              extrn     opout
              extrn     opequ
              extrn     opds
              extrn     opdb
              extrn     opdw
              extrn     oporg
              extrn     oppop
              extrn     oppush
              extrn     opend
              extrn     opldn
              extrn     oppublic
              extrn     opver
              extrn     opever
              extrn     opeever
              extrn     opextrn
              extrn     tolc

              ldi       insttab.1      ; Point to instruction table
              phi       ra
              ldi       insttab.0
              plo       ra
loop:         push      rf             ; save instruction position
iloop:        lda       rf             ; get byte from source
              call      tolc           ; convert to uppercase
              str       r2             ; store for comparison
              lda       ra             ; get byte from opcode table
              shl                      ; shift high bit to DF
              lbdf      lastchar       ; jump if last character
              shr                      ; shift if back
              sm                       ; compare with source byte
              lbz       iloop          ; jump if still matching
              pop       rf             ; recover source position
tloop:        lda       ra             ; find end of entry
              shl
              lbnf      tloop
skipdata:     inc       ra             ; move past entry data
              inc       ra
              inc       ra
              ldn       ra             ; check for end of table
              lbnz      loop           ; jump if more entries
              smi       0              ; signal opcode not found
              rtn                      ; and return to caller
lastchar:     shr                      ; shift character back
              sm                       ; compare to source byte
              lbz       maybe          ; maybe good
nope:         pop       rf             ; recover source position
              lbr       skipdata       ; and skip past entry data
maybe:        ldn       rf             ; get next byte from input
              smi       33             ; must be space or less
              lbdf      nope           ; nope not a match
              irx                      ; remove rf from stack
              irx
              adi       0              ; signal opcode found
              rtn                      ; and return to caller

; Instruction types (field 2)
; 1 - Single byte instruction, no argument
; 2 - Two byte instruction, single byte argument
; 3 - Three byte instruction, single word argument
; 4 - Special handler
; 5 - Single byte instruction, nybble argument
; 6 - 3 bytes, 2 arguments, 1-nybble, 2-byte address
; 7 - short branch

insttab:      db        'ad',('d'+80h),1,0f4h,0
              db        'ad',('c'+80h),1,074h,0
              db        'adc',('i'+80h),2,07ch,0
              db        'ad',('i'+80h),2,0fch,0
              db        'an',('d'+80h),1,0f2h,0
              db        'an',('i'+80h),2,0fah,0
              db        'b',('1'+80h),7,034h,0
              db        'b',('2'+80h),7,035h,0
              db        'b',('3'+80h),7,036h,0
              db        'b',('4'+80h),7,037h,0
              db        'bd',('f'+80h),7,033h,0
              db        'bn',('1'+80h),7,03ch,0
              db        'bn',('2'+80h),7,03dh,0
              db        'bn',('3'+80h),7,03eh,0
              db        'bn',('4'+80h),7,03fh,0
              db        'bn',('f'+80h),7,03bh,0
              db        'bn',('q'+80h),7,039h,0
              db        'b',('q'+80h),7,031h,0
              db        'b',('r'+80h),7,030h,0
              db        'b',('z'+80h),7,032h,0
              db        'bn',('z'+80h),7,03ah,0
              db        'de',('c'+80h),5,020h,0
              db        'di',('s'+80h),1,071h,0
              db        'gh',('i'+80h),5,090h,0
              db        'gl',('o'+80h),5,080h,0
              db        'id',('l'+80h),1,000h,0
              db        'in',('c'+80h),5,010h,0
              db        'in',('p'+80h),4
              dw             opinp
              db        'ir',('x'+80h),1,060h,0
              db        'lbd',('f'+80h),3,0c3h,0
              db        'lbn',('f'+80h),3,0cbh,0
              db        'lbn',('q'+80h),3,0c9h,0
              db        'lbn',('z'+80h),3,0cah,0
              db        'lb',('q'+80h),3,0c1h,0
              db        'lb',('r'+80h),3,0c0h,0
              db        'lb',('z'+80h),3,0c2h,0
              db        'ld',('a'+80h),5,040h,0
              db        'ld',('i'+80h),2,0f8h,0
              db        'ld',('n'+80h),4
              dw             opldn
              db        'ld',('x'+80h),1,0f0h,0
              db        'ldx',('a'+80h),1,072h,0
              db        'lsd',('f'+80h),1,0cfh,0
              db        'lsi',('e'+80h),1,0cch,0
              db        'lsk',('p'+80h),1,0c2h,0
              db        'lsn',('f'+80h),1,0c7h,0
              db        'lsn',('q'+80h),1,0c5h,0
              db        'lsn',('z'+80h),1,0c6h,0
              db        'ls',('q'+80h),1,0cdh,0
              db        'ls',('z'+80h),1,0ceh,0
              db        'mar',('k'+80h),1,079h,0
              db        'nb',('r'+80h),1,038h,0
              db        'nlb',('r'+80h),1,0c8h,0
              db        'no',('p'+80h),1,0c4h,0
              db        'o',('r'+80h),1,0f1h,0
              db        'or',('i'+80h),2,0f9h,0
              db        'ou',('t'+80h),4
              dw             opout
              db        'ph',('i'+80h),5,0b0h,0
              db        'pl',('o'+80h),5,0a0h,0
              db        're',('t'+80h),1,070h,0
              db        're',('q'+80h),1,07ah,0
              db        's',('d'+80h),1,0f5h,0
              db        'sa',('v'+80h),1,078h,0
              db        'sd',('b'+80h),1,075h,0
              db        'sdb',('i'+80h),2,07dh,0
              db        'sd',('i'+80h),2,0fdh,0
              db        'se',('p'+80h),5,0d0h,0
              db        'se',('q'+80h),1,07bh,0
              db        'se',('x'+80h),5,0e0h,0
              db        'sh',('l'+80h),1,0feh,0
              db        'sh',('r'+80h),1,0f6h,0
              db        'shl',('c'+80h),1,07eh,0
              db        'shr',('c'+80h),1,076h,0
              db        'sk',('p'+80h),1,038h,0
              db        's',('m'+80h),1,0f7h,0
              db        'sm',('b'+80h),1,077h,0
              db        'smb',('i'+80h),2,07fh,0
              db        'sm',('i'+80h),2,0ffh,0
              db        'st',('r'+80h),5,050h,0
              db        'stx',('d'+80h),1,073h,0
              db        'xo',('r'+80h),1,0f3h,0
              db        'xr',('i'+80h),2,0fbh,0
              db        'en',('d'+80h),4
              dw             opend
              db        'or',('g'+80h),4
              dw             oporg
              db        'd',('b'+80h),4
              dw             opdb
              db        'd',('w'+80h),4
              dw             opdw
              db        'd',('s'+80h),4
              dw             opds
              db        'eq',('u'+80h),4
              dw             opequ
              db        've',('r'+80h),4
              dw             opver
              db        'eve',('r'+80h),4
              dw             opever
              db        'eeve',('r'+80h),4
              dw             opeever
              db        'publi',('c'+80h),4
              dw             oppublic
              db        'extr',('n'+80h),4
              dw             opextrn
              db        'rld',('i'+80h),6,068h,0c0h
              db        'rlx',('a'+80h),5,068h,060h
              db        'rsx',('d'+80h),5,068h,0a0h
              db        'dbn',('z'+80h),6,068h,020h
              db        'rn',('x'+80h),5,068h,0b0h
              db        'dad',('d'+80h),1,068h,0f4h
              db        'dad',('i'+80h),2,068h,0fch
              db        'dad',('c'+80h),1,068h,074h
              db        'dac',('i'+80h),2,068h,07ch
              db        'ds',('m'+80h),1,068h,0f7h
              db        'dsm',('i'+80h),2,068h,0ffh
              db        'dsm',('b'+80h),1,068h,077h
              db        'dsb',('i'+80h),2,068h,07fh
              db        'bc',('i'+80h),7,068h,03eh
              db        'bx',('i'+80h),7,068h,03fh
              db        'ld',('c'+80h),1,068h,006h
              db        'ge',('c'+80h),1,068h,008h
              db        'stp',('c'+80h),1,068h,000h
              db        'dt',('c'+80h),1,068h,001h
              db        'st',('m'+80h),1,068h,007h
              db        'scm',('1'+80h),1,068h,005h
              db        'scm',('2'+80h),1,068h,003h
              db        'spm',('1'+80h),1,068h,004h
              db        'spm',('2'+80h),1,068h,002h
              db        'et',('q'+80h),1,068h,009h
              db        'xi',('e'+80h),1,068h,00ah
              db        'xi',('d'+80h),1,068h,00bh
              db        'ci',('e'+80h),1,068h,00ch
              db        'ci',('d'+80h),1,068h,00dh
              db        'dsa',('v'+80h),1,068h,076h
              db        'sca',('l'+80h),6,068h,080h
              db        'sre',('t'+80h),5,068h,090h
extended:     db        'cal',('l'+80h),3,0d4h,0
              db        'rt',('n'+80h),1,0d5h,0
              db        'pus',('h'+80h),4
              dw             oppush
              db        'po',('p'+80h),4
              dw             oppop
              db        0

              endp

