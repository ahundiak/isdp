/* $Id: VDppl.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $ */
/* -------------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdmisc/ VDppl.I
 *
 * Description:
 *      Functions to call PPL files and functions
 *
 * Revision History:
 *	$Log: VDppl.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:57  cvs
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
# Revision 1.1  1995/08/30  20:01:16  pinnacle
# Created: vdmisc/VDppl.I by tlbriggs for vds.240
#
 *
 * History:
 *      08/28/95  tlb  	creation  - generalizes smcomp/func/SMUserAtt.I
 * -------------------------------------------------------------------------
 */

class implementation Root ;

#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "go.h"

#include "msdef.h"
#include "msmacros.h"
#include "VDmem.h"

#include "ciexecmacros.h"
#include "AS_status.h"

from ci 	import is_entry_point;

/* -------------------------------------------------------------------------*/
/* Load a ppl file and check entry point before execution
 *	returns: TRUE, FALSE
 */

int
VD_pplLoad(
	char 		*ppl_name,       	/* I: ppl file name  */
	char    	*entry,			/* I: entry point name */
	struct GRid	*ppl_id)		/* O: ppl objid */
{
	char    	status_field[GR_MAX_CHAR] ;
	long 		status;
	int		rc ;

	/* Load PPL file */
	ppl_id->osnum = OM_Gw_TransOSnum_0 ;
	ppl_id->objid = NULL_OBJID;
	status = ci$load(file_name = ppl_name,
			 file_id   = &(ppl_id->objid),
			 load      = LOAD,
			 sender_id = NULL_OBJID) ;
	if (!(status & 1)) {
        	sprintf(status_field, "Could not load PPL file %s.e", ppl_name);
        	ex$message(field = 2, in_buff = status_field) ;
		goto wrapup;
		}

	/* check entry point */
	status = om$send(msg = message ci.is_entry_point(&rc, entry),
			senderid = NULL_OBJID,
			targetid  = ppl_id->objid,
			targetos  = ppl_id->osnum) ;
	if (!(status & rc & 1)){
        	sprintf(status_field, "Could not find %s() in %s.e", 
							entry, ppl_name) ;
        	ex$message(field = 2, in_buff = status_field) ;
		VD_pplDelete (ppl_name, entry, *ppl_id);
		}
wrapup:
	return status & rc & 1;
}

/*------------------------------------------------------------------*/
int
VD_pplRun(
	char 		*ppl_name,       	/* I: ppl file name  */
	char    	*entry,			/* I: entry point name */
	struct GRid	ppl_id,			/* I: loaded ppl objid */
	int		*val)			/* O: value returned */
{
	char    	status_field[GR_MAX_CHAR] ;
	long 		status;

	/* Run PPL file */

	status = ci$run(	
			file_id   = &ppl_id.objid,
			entry     = entry,
			retsize   = sizeof(val),
			retval    = val,
			sender_id = NULL_OBJID) ;

	if ( !(status & 1)){
        	sprintf(status_field,
			"Execution of %s() in file %s.e failed", 
							entry, ppl_name) ;
        	ex$message(field = 2, in_buff = status_field) ;
		}

	return status & 1;
}
/*------------------------------------------------------------------*/
int
VD_pplSRun(
	char 		*ppl_name,       	/* I: ppl file name  */
	char    	*entry,			/* I: entry point name */
	struct GRid	ppl_id,			/* I: loaded ppl objid */
	int		buf_size,
	char		*buf)			/* O: value returned */
{
	char    	status_field[GR_MAX_CHAR] ;
	long 		status;

	/* Run PPL file */

	status = ci$run(	
			file_id   = &ppl_id.objid,
			entry     = entry,
			retsize   = buf_size,
			retval    = buf,
			sender_id = NULL_OBJID) ;

	if ( !(status & 1)){
        	sprintf(status_field,
			"Execution of %s() in file %s.e failed", 
							entry, ppl_name) ;
        	ex$message(field = 2, in_buff = status_field) ;
		}

	return status & 1;
}

/*------------------------------------------------------------------*/
/* Push arguments on list */
int
VD_pplPushArgs ( int	num,		/* I: number of arguments */
		void 	**addr,		/* I: list of argument addresses */
		int 	*size		/* I: list of argument sizes */
		)
{
	long		status = OM_S_SUCCESS;
	int		msg = MSSUCC;
	int		i;
	CIpushlist	*plist;


	/* no args - no work */
	if (!num) return TRUE;
		
	/* allocate list */
	plist = _MALLOC ( num, CIpushlist);
	_CheckMem (plist, status, msg, wrapup);

	/* create ci push list */
	for (i=0; i<num ; i++) {
		plist[i].addr = addr[i];
		plist[i].size = size[i];
		}
	/* push arguments */
	status = ci$push (argc = num, argv = plist );

wrapup:
 	_FREE (plist);
	return status & 1;
}

/*------------------------------------------------------------------*/
/* Delete a loaded ppl object */
int
VD_pplDelete( struct GRid	ppl_id)		/* I: loaded ppl objid */
{
	long 		status;

	status = ci$delete (file_id = ppl_id);

/*
	om$send(	msg = message Root.delete(0),
				senderid = NULL_OBJID,
				targetid  = ppl_id.objid,
				targetos  = ppl_id.osnum) ; 
	as$status() ;
*/
	return status & 1;
}

end implementation Root ;
