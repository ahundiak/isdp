SRC
$(EXNUC)/trans/ccd

TARGET
$(TARGET)/bin/ccd
$(TARGET)/bin/funcgen
$(TARGET)/bin/showdict
$(TARGET)/bin/srchdict
$(TARGET)/bin/ctd

INCLUDE
$(EXNUC)/include
$(EXNUC)/om/tools
$(EXNUC)/trans/include

DEFINE
CCDEF

SOURCE=ccdlib
parddp.c
parents.l
mem.c

ARCHIVE=ccdlib
$(TARGET)/trans/ccd/ccdlib.a

SOURCE=ccd
ccd.c

DEPLIB=ccd
$(TARGET)/trans/ccd/ccdlib.a

EXEC=ccd
$(TARGET)/bin/ccd

SOURCE=funcgen
func_gen.c

DEPLIB=funcgen
$(TARGET)/trans/ccd/ccdlib.a

EXEC=funcgen
$(TARGET)/bin/funcgen

SOURCE=showdict
showdict.c

EXEC=showdict
$(TARGET)/bin/showdict

SOURCE=srchdict
srchdict.c

EXEC=srchdict
$(TARGET)/bin/srchdict

SOURCE=ctd
ctd.l

EXEC=ctd
$(TARGET)/bin/ctd

POST_SPECIAL
parents.o:
	@echo "\t$(SRC)/parents.l -> parents.o"
	@lex -t $(SRC)/parents.l > parents.c; \
	$(CCDEF) -c parents.c
	@if test "$(COPT)" != "-g"; \
	then \
		echo "\trm parents.c"; \
		rm parents.c; \
	else \
		echo "\tleaving parents.c"; \
	fi
ctd.o:
	@echo "\t$(SRC)/ctd.l -> ctd.o"
	@lex -t $(SRC)/ctd.l > ctd.c; \
	$(CCDEF) -c ctd.c
	@if test "$(COPT)" != "-g"; \
	then \
		echo "\trm ctd.c"; \
		rm ctd.c; \
	else \
		echo "\tleaving ctd.c"; \
	fi
END_SPECIAL
