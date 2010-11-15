# Do not alter this SPC information: $Revision: 1.1.54.1 $

# Makefile for indexing a single Help document

SHELL=/bin/ksh
HELPNDX=/usr/ip32/helpdp/bin/helpndx
HELPSTOP=/usr/ip32/helpdp/bin/stopword.stp

HELPFILE.cat:	HELPFILE
	@if [ ! -x $(HELPNDX) ];\
	then\
		echo "Not indexing because no $(HELPNDX)";\
	else\
		echo "$(HELPNDX) -s $(HELPSTOP) HELPFILE";\
		$(HELPNDX) -s $(HELPSTOP) HELPFILE;\
	fi
