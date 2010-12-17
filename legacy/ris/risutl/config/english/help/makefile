# Makefile for indexing all Help documents

SHELL=/bin/ksh

SUBDIRS=online prgref sqlref utlref

HELPNDX=/usr/ip32/helpdp/bin/helpndx
HELPSTOP=/usr/ip32/helpdp/bin/stopword.stp

index:
	@case $(TARGET) in "c100"|"c400") \
		if [ ! -x $(HELPNDX) ];\
		then\
			echo ;\
			echo "\tNot indexing because no $(HELPNDX)";\
		else\
			for DIR in $(SUBDIRS) ; \
			do \
				echo ;\
				echo "\tCreating Help index for $$DIR"; \
				cd $(RISDEVDIR)/risutl/config/english/help/$$DIR ;\
				$(HELPNDX) -s $(HELPSTOP) HELPFILE;\
			done \
		fi ;; \
	esac

