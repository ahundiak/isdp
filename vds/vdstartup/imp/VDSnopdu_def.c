/* $Id: VDSnopdu_def.c,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdstartup/imp / VDSnopdu_def.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSnopdu_def.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/****************************************************************************

NOTE:

	The file was written in VDS 2.2.1 in the directory VDSno_pdu.
	The .o file VDSnopud_def.o was send to etc/pdu_dload and 
	further not used anywere.

	Therefor put as source file in this directory as obsolete file.

	Regards Ad.
	==========


      VDSnopdu_def.c - Definitions for non PDU version of VDS

      Written 92-11-10 by Roger Malmgren

****************************************************************************/
#include        "MEMstruct.h"
#include	"PDUerror.h"
#include	"PDUstr.h"
#include	"PDUuser.h"

struct PDUrefresh *refresh = NULL;
struct PDUuser *user = NULL;

void PDUload_exec_structure(p1,p2,p3,p4,p5,p6,p7,p8,p9)
char *p1,*p2,*p3,*p4,*p5,*p6,*p7;
long p8,p9;
{
   printf("ERROR: Obsolete function PDUload_exec_structure called\n");
}

int PDUvalid_catalog(p1,p2)
char *p1,*p2;
{
   printf("ERROR: Obsolete function PDUvalid_catalog called\n");
   return PDM_E_FAILURE;
}

int PDMpost_to_database(p1,p2,p3,p4,p5)
MEMptr p1,p2,p3,p4,p5;
{
   printf("ERROR: Obsolete function PDMpost_to_database called\n");
   return PDM_E_FAILURE;
}

void PDUppl_checkout_part(p1,p2,p3,p4,p5)
int  *p1,p5;
char *p2,*p3,*p4;
{
   printf("ERROR: Obsolete function PDUppl_checkout_part called\n");
}

void PDUppl_checkin_part(p1,p2,p3,p4)
int  *p1;
char *p2,*p3,*p4;
{
   printf("ERROR: Obsolete function PDUppl_checkin_part called\n");
}


