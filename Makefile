PROJECT = asm02
INCDIR=../../Include
LIBDIR=../../Lib
INSTDIR=../../Image/bin
OBJS = \
	adddefine.prg \
	addlabel.prg \
	appendext.prg \
	asmpass.prg \
	check1805.prg \
	checkeom.prg \
	checkrange.prg \
	convertnum.prg \
	defreplace.prg \
	directive.prg \
	div16.prg \
	dopublics.prg \
	error.prg \
	final.prg \
	finddefine.prg \
	findlabel.prg \
	fopen.prg \
	getarg.prg \
	initasm.prg \
	isrreg.prg \
	itoa16.prg \
	labelchar.prg \
	ltrim.prg \
	ltrimrf.prg \
	lookupop.prg \
	mdnorm16.prg \
	mul16.prg \
	nextline.prg \
	opdb.prg \
	opds.prg \
	opdw.prg \
	opend.prg \
	opendp.prg \
	opequ.prg \
	opeever.prg \
	opever.prg \
	opextrn.prg \
	opinp.prg \
	opldn.prg \
	oporg.prg \
	opout.prg \
	oppop.prg \
	opproc.prg \
	oppublic.prg \
	oppush.prg \
	output.prg \
	opver.prg \
	readln.prg \
	replace.prg \
	showsymbols.prg \
	strcasecmpin.prg \
	strcmpin.prg \
	strstr.prg \
	tobcd16.prg \
	tohex.prg \
	tolc.prg\
	touc.prg \
	writeextrn.prg \
	writelocal.prg \
	writeln.prg \
	writelstfile.prg \
	writeoutput.prg \
	main.prg

.SUFFIXES: .asm .prg

$(PROJECT).bin: $(OBJS)
	asm02 -l -L -I$(INCDIR) main.asm
	link02 -s -S symbols.sym -e @link.lnk -o $(PROJECT).bin

.asm.prg:
	asm02 -l -L -I$(INCDIR) $<

clean:
	-rm *.prg
	-rm *.bin
	-rm *.lst
	-rm symbols.sym

lists:
	adjlst adddefine.lst adddefine
	adjlst addlabel.lst addlabel
	adjlst asmpass.lst asmpass
	adjlst check1805.lst check1805
	adjlst convertnum.lst convertnum
	adjlst defreplace.lst defreplace
	adjlst directive.lst directive
	adjlst final.lst final
	adjlst finddefine.lst finddefine
	adjlst fopen.lst fopen
	adjlst getarg.lst getarg
	adjlst initasm.lst initasm
	adjlst labelchar.lst labelchar
	adjlst nextline.lst nextline
	adjlst opend.lst opend
	adjlst oporg.lst oporg
	adjlst opproc.lst opproc
	adjlst output.lst output
	adjlst readln.lst readln
	adjlst replace.lst replace

install: $(PROJECT).bin
	cp $(PROJECT).bin $(INSTDIR)

