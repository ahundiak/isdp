SOURCE

LIB

SPECIAL
UMS_COMPILE = umscompile

all:\
	messages

END_SPECIAL

POST_SPECIAL

messages: \
	$(XFB)/include/FB.h \
	../FB.msg

$(XFB)/include/FB.h: FB.txt
	@echo
	-$(UMS_COMPILE) -p$(XFB)/include/FB.h -m../FB.msg FB.txt
	@ls -l $(XFB)/include/FB.h ../FB.msg
	@echo

../FB.msg: FB.txt
	@echo
	-$(UMS_COMPILE) -p$(XFB)/include/FB.h -m../FB.msg FB.txt
	@ls -l $(XFB)/include/FB.h ../FB.msg
	@echo

END_SPECIAL

