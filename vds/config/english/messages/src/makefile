# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:26 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/config/english/messages/src/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:26  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  16:04:30  pinnacle
# rep bin w/txt
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

.SUFFIXES: .mb .msg .h

ALL:	VDcmd.msg \
	VDmsg.msg \
	SMcmd.msg \
	SMmsg.msg

.mb.msg:
	@rm -f $*.msg $*.h
	@rm -f $(VDS)/include/$*.h
	@rm -f $(VDS)/config/english/messages/$*.msg
	umscompile -m $*.msg -p $*.h $?
	@ln -f $*.h $(VDS)/include; :
	@ln -f $*.msg $(VDS)/config/english/messages; :
	@echo
	@ls -l $(VDS)/include/$*.h $(VDS)/config/english/messages/$*.msg
	@echo

