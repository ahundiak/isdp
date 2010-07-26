SRC
$(EXNUC)/package/src

INCLUDE
$(EXNUC)/package/include

TARGET
$(TARGET)/package/bin/addbuild
$(TARGET)/package/bin/bulkLoad.sh
$(TARGET)/package/bin/column
$(TARGET)/package/bin/listtosh
$(TARGET)/package/bin/packex.sh
$(TARGET)/package/bin/prepack
$(TARGET)/package/bin/row
$(TARGET)/package/bin/rowtosh
$(TARGET)/package/bin/strip_head
$(TARGET)/package/bin/support.sh
$(TARGET)/package/bin/tabletolist

POST_SPECIAL
$(TARGET)/package/bin/bulkLoad.sh: $(EXNUC)/package/src/bulkLoad.sh
	cp $(EXNUC)/package/src/$(@F) $(TARGET)/package/bin
	chmod 755 $(TARGET)/package/bin/$(@F)
$(TARGET)/package/bin/packex.sh: $(EXNUC)/package/src/packex.sh
	cp $(EXNUC)/package/src/$(@F) $(TARGET)/package/bin
	chmod 755 $(TARGET)/package/bin/$(@F)
$(TARGET)/package/bin/support.sh: $(EXNUC)/package/src/support.sh
	cp $(EXNUC)/package/src/$(@F) $(TARGET)/package/bin
	chmod 755 $(TARGET)/package/bin/$(@F)
END_SPECIAL

 ############################################################
EXEC=addbuild
$(TARGET)/package/bin/addbuild

DEPLIB=addbuild
$(TARGET)/package/lib/package.a

SOURCE=addbuild
addbuild.c
 ############################################################
EXEC=row
$(TARGET)/package/bin/row

SOURCE=row
row.c
 ############################################################
EXEC=column
$(TARGET)/package/bin/column

SOURCE=column
column.c
 ############################################################
EXEC=tabletolist
$(TARGET)/package/bin/tabletolist

SOURCE=tabletolist
tabletolist.c

DEPLIB=tabletolist
$(TARGET)/package/lib/package.a
 ############################################################
EXEC=strip_head
$(TARGET)/package/bin/strip_head

DEPLIB=strip_head
$(TARGET)/package/lib/package.a

SOURCE=strip_head
strip_head.c
 ############################################################
EXEC=listtosh
$(TARGET)/package/bin/listtosh

DEPLIB=listtosh
$(TARGET)/package/lib/package.a

SOURCE=listtosh
listtosh.c
 ############################################################
EXEC=rowtosh
$(TARGET)/package/bin/rowtosh

DEPLIB=rowtosh
$(TARGET)/package/lib/package.a

SOURCE=rowtosh
rowtosh.c
 ############################################################
EXEC=prepack
$(TARGET)/package/bin/prepack

DEPLIB=prepack
$(TARGET)/package/lib/package.a

SOURCE=prepack
prepack.c
 ############################################################
