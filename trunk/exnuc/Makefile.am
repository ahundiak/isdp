## Process this file with automake to produce Makefile.in

ACLOCAL_AMFLAGS = -I m4

SUBDIRS = spec om icob exec message/src igefei version stubs lib app

# Fire off this target after a fresh checkout
setup:
	cd config/english/messages/src; make setup; cd $(abs_top_srcdir)

