# Do not alter this SPC information: $Revision: 1.1.54.1 $
BASE_NAME=edit
UNUSED_EXCEPTIONS=\
	makefile\
	makefile.nt\
	makefile.dos\
	makeout\
	nonfuncs\
	mk_term\
	editor\
	edtmain.c


include ../build/maketplt

EDIT_OBJECTS=\
	$(OBJDIR)/edt*.o

EDIT_LIBS=\
	$(RISDEVDIR)/riscom/lib/$(LIBDIR)/riscom.a\
	$(RISDEVDIR)/risutl/lib/$(LIBDIR)/risuco.a

EDIT_IPATH=\
	-I../internal \
	-Iprt \
	-I../../riscom/common/prt

editor: edtmain.c ../internal/edit.h $(EDIT_OBJECTS)
	$(CC) $(COPT) $(EDIT_IPATH) -o editor edtmain.c $(EDIT_OBJECTS) $(EDIT_LIBS)
