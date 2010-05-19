/* $Id: imp.m,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/parser / imp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: imp.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/07/30  20:25:22  pinnacle
# Replaced: vdpocket/parser/imp.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/01/23  15:20:26  pinnacle
# Replaced: vdpocket/parser/imp.m by tlbriggs r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	
 *	01/13/95	TLB		add test_query, 
 *					change myquery_ to qy_
 *
 * -------------------------------------------------------------------*/

SOURCE
sql.y

LIB
$(VDS)/lib/vdisql.o

INCLUDE
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(VDS)/include
$(VDS)/vdinclude

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(VDS)/spec

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp

POST_SPECIAL
$(yacc_objects) :
	@if [ "$(WHY)" ]; then echo "\t$(SRC)/sql.y : $?"; fi
	@echo "\t$(SRC)/sql.y -> sql.c"
	@yacc  -t -v $(SRC)/sql.y
	@sed "s/yy/qy_yy/g" y.tab.c | sed "s/YY/qy_YY/g" > sql.c
	@echo "\tsql.c -> sql.o"
	@$(CC) -c $(COPT) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) sql.c
	@rm y.tab.c 
	@echo 
END_SPECIAL
