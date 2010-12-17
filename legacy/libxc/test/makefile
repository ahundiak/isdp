.SUFFIXES: .c .o .so

XCLIBS = $(LIB)/libxc.a $(LIB)/libxcmalloc.a

IPATH =  \
	-I$(INC_PVT) \
	-I$(INC_PUB) 

# Main target

TARGET: objtester testdrive DLtest_1.o DLtest_2.o DLtest_2A.o DLtest_2B.o DLtest_3.o DLtest_4.o DLtest_4A.o DLtest_4B.o DLtest_5.o DLtest_5A.o DLtest_5B.o DLtest_6.o

objtester: objtester.o $(XCLIBS)
	$(CC) $(COPT) -o objtester objtester.o $(XCLIBS) $(LINKLIBS)

testdrive: testdrive.o $(XCLIBS)
	$(CC) $(COPT) -o testdrive testdrive.o $(XCLIBS) $(LINKLIBS)

# Dependencies

objtester.o: \
	$(TEST)/objtester.c

testdrive.o: \
	$(TEST)/testdrive.c

# Rules
	
.c.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if [ -z "$(VERBOSE_RULES)" ]; \
	 then \
	     echo "\t$< -> $*.o"; \
	 else \
	     echo "\t$(CC) $(COPT) $(IPATH) $(DOPT) $(DOPT1) -c $*.c"; \
	 fi
	@$(CC) $(COPT) $(IPATH) $(DOPT) $(DOPT1) -c $*.c
	@echo 

.c.so:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if [ -z "$(VERBOSE_RULES)" ]; \
	 then \
	     echo "\t$< -> $*.so"; \
	 else \
	     echo "\t$(CC) $(COPT) $(CCSOFLAGS) $(IPATH) $(DOPT) -c $*.c"; \
	 fi
	@$(CC) $(COPT) $(CCSOFLAGS) $(IPATH) $(DOPT) $(DOPT1) -c $*.c
	@if [ ! -z "$(VERBOSE_RULES)" ]; \
	 then \
	     echo "\t$(LD) $(LDSOFLAGS) -o $*.so $*.o"; \
	 fi
	@$(LD) $(LDSOFLAGS) -o $*.so $*.o
	@echo 
