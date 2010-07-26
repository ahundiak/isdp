include $(TARGET)/lib/exnucobjects

SLFILE=$(EXNUC)/shlib/libexnuc.sl
MKSHLIB=mkshlib -q
SHLIB=libexnuc_s
CC=cc -ga

$(TARGET)/shlib/$(SHLIB): $(objects) $(TARGET)/exec/shexec/exnucimport.o $(SLFILE)
	$(MAKE) env
	$(MAKE) slverfile
	$(MAKE) applverfile
	$(MAKE) slfile
	rm -f $(TARGET)/shlib/$(SHLIB) $(TARGET)/shlib/$(SHLIB).a
	$(MKSHLIB) -s temp.sl -t $(SHLIB) -h $(SHLIB).a
	$(BASE)/bin/slver -t $(SHLIB) -h $(SHLIB).a -i exnucimport.o
	touch $(SHLIB)

env:
	@$(EXNUC)/checkEnv.sh \
		PRODUCT_NAME	"$(PRODUCT_NAME)" \
		PRODUCT_VERSION	"$(PRODUCT_VERSION)" \
		PRODUCT_DATE	"$(PRODUCT_DATE)" \
		PRODUCT_SHLIB_VERSION "$(PRODUCT_SHLIB_VERSION)"

slverfile:
	@echo "\n\tCreating slver global data ..."
	@echo "char libexnuc_ver_info[128]=\"$(PRODUCT_SHLIB_VERSION)\";" >libexnuc.c
	$(CC) -c libexnuc.c

applverfile:
	@echo "\n\tCreating application version id ..."
	$(EXNUC)/bin/version.sh
	$(CC) -c -I$(EXNUC)/include $(PRODUCT_NAME)ver.c
	mcs -a "$(PRODUCT_VERSION) $(PRODUCT_DATE) `date '+(real time %b %d %Y %H:%M)'`" $(PRODUCT_NAME)ver.o

slfile:
	@echo "\n\tCreating shared library specification file temp.sl ..."
	@echo "\tCreating #objects list ..."
	@$(MAKE) objects
	@echo "\tCreating #ident ..."
	@echo "#ident \"$$PRODUCT_VERSION $$PRODUCT_DATE `date '+(real time %b %d %Y %H:%M)'`\"" > temp.sl
	@echo "\tSplitting $(SLFILE) ..."
	@csplit -f sl $(SLFILE) /##objects/
	@echo "\tConcatenating new sl file ..."
	@cat sl00 >> temp.sl
	@cat objects >> temp.sl
	@echo "#init $(TARGET)/exec/shexec/exnucimport.o" >> temp.sl
	@cat sl01 >> temp.sl
	@rm -f sl00 sl01
	@echo

objects: $(TARGET)/lib/exnucobjects
	@echo "#objects" > objects
	@echo "\t$(TARGET)/shlib/libexnuc.o" >> objects
	@echo "\t$(TARGET)/shlib/$(PRODUCT_NAME)ver.o" >> objects
	@echo "\t$(TARGET)/exec/shexec/exnucimport.o" >> objects
	@for NAME in $(objects); \
	do \
		echo "\t$$NAME"; \
	done >> objects
