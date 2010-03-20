SOURCE

LIB

SPECIAL
UMS_COMPILE = umscompile

all:\
	messages

END_SPECIAL

POST_SPECIAL

messages: \
	$(XMB)/include/XMB.h \
	../XMB.msg

$(XMB)/include/XMB.h: XMB.txt
	@echo
	-$(UMS_COMPILE) -p$(XMB)/include/XMB.h -m../XMB.msg XMB.txt
	@ls -l $(XMB)/include/XMB.h ../XMB.msg
	@echo

../XMB.msg: XMB.txt
	@echo
	-$(UMS_COMPILE) -p$(XMB)/include/XMB.h -m../XMB.msg XMB.txt
	@ls -l $(XMB)/include/XMB.h ../XMB.msg
	@echo

END_SPECIAL

