/* $Id: VDRAPdefs.h,v 1.1 2001/03/05 15:08:31 hans Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDRAPdefs.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDRAPdefs.h,v $
 *	Revision 1.1  2001/03/05 15:08:31  hans
 *	Adapted from GRNUC: RAPdefs.h
 *	
 *
 * History:
 *	MM/DD/YYYY	AUTHOR		DESCRIPTION
 *	03/05/2001	HF		Creation
 *					Adapted from GRNUC "start and record"
 *
 * -------------------------------------------------------------------*/

#define ERROR_CHK if(!(sts & 0x00000001))				       \
	{ printf("\n\nRAP: error at line %d in \"%s\"\n",__LINE__,__FILE__);   \
	  om$report_error(sts=sts);					       \
	  return(OM_S_SUCCESS); }

#define RAP_EOF		-1
#define CREATE           1

#define DEFAULT_FILE	".isdp_journal.u"

#define NOD_NAME	"ISDP_nod"
#define LISTENER_NAME	"ISDP_listener"

/*
#define RAP_DEBUG
*/
