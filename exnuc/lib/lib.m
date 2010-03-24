DEFINE
CCDEF

INCLUDE
$(EXNUC)/include

POST_SPECIAL
include $(TARGET)/lib/exnucobjects

ARCHIVE=libexnuc.a

#if defined(CLIX)
$(TARGET)/$(LIBLOC)/$(ARCHIVE): $(objects)
	export ORIG_PN=$(PRODUCT_NAME)
	export PRODUCT_NAME=EXNUC
	$(MAKE) env
	PRODUCT_NAME=EXNUC $(MAKE) applverfile
	rm -f $(TARGET)/$(LIBLOC)/$(ARCHIVE)
	@ar q $(TARGET)/$(LIBLOC)/$(ARCHIVE) $(objects) EXNUCver.o
	@cp $(TARGET)/$(LIBLOC)/$(ARCHIVE) ../../$(OTHERLOC)/$(LIBLOC)/$(ARCHIVE)
	@ls -ls $(TARGET)/$(LIBLOC)/$(ARCHIVE)
	@ls -ls ../../$(OTHERLOC)/$(LIBLOC)/$(ARCHIVE)
	@echo
	export PRODUCT_NAME=$(ORIG_PN)
#elif defined(SUNOS4)
$(TARGET)/lib/$(ARCHIVE): $(objects)
	$(MAKE) env
	$(MAKE) applverfile
	rm -f $(TARGET)/lib/$(ARCHIVE)
	@ar q $(TARGET)/lib/$(ARCHIVE) $(objects) $(PRODUCT_NAME)ver.o
	ranlib $(TARGET)/lib/$(ARCHIVE)
	@ls -ls $(TARGET)/lib/$(ARCHIVE)
	@echo
#elif defined(IRIX) || defined (SUNOS5)
$(TARGET)/lib/$(ARCHIVE): $(objects)
	$(MAKE) env
	$(MAKE) applverfile
	rm -f $(TARGET)/lib/$(ARCHIVE)
	xargs ar q $(TARGET)/lib/$(ARCHIVE) < $(TARGET)/lib/objectlist
	@ls -ls $(TARGET)/lib/$(ARCHIVE)
	@echo
#endif

env:
	@$(EXNUC)/build/checkEnv.sh \
		PRODUCT_NAME	"$(PRODUCT_NAME)" \
		PRODUCT_VERSION	"$(PRODUCT_VERSION)" \
		PRODUCT_DATE	"$(PRODUCT_DATE)"

#if defined(CLIX)
applverfile:
	@echo "\n\tCreating application version id ..."
	$(EXNUC)/bin/version.sh
	$(CCDEF) -c $(PRODUCT_NAME)ver.c
	mcs -a "$(PRODUCT_VERSION) $(PRODUCT_DATE) `date '+(real time %b %d %Y %H:%M)'`" $(PRODUCT_NAME)ver.o
	@echo
#elif defined(SUNOS) || defined(IRIX)
applverfile:
	@echo "\n\tCreating application version id ..."
	$(EXNUC)/bin/version.sh
	$(CCDEF) -c $(PRODUCT_NAME)ver.c
	@echo
#endif


find_objects:
	#
	#	Use this target to validate the object list.
	#
	@for FILE in $(objects); \
	do \
		if test ! -f $$FILE; \
		then \
			echo "$$FILE: not found"; \
		fi; \
	done
END_SPECIAL
