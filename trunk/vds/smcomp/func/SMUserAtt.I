/* $Id: SMUserAtt.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:        SMcomp/SMUserAtt.I
 *
 * Description:
 *      Implementation of SMSetUserAtt() - compartment attributes
 *
 *
 * Revision History:
 *	$Log: SMUserAtt.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/31  21:22:42  pinnacle
# Return values
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *      02/25/93  A. Claude:  Creation Date
 *      06/05/93  A. Claude:  Remove function parameter attr_name
 *      10/31/97  ah          SCI_fileid warning
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

#include "ciexecmacros.h"

#include "AS_status.h"

from ci import is_entry_point, set_value ;

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMSetUserAtt

  Abstract
       The purpose of SMSetUserAtt() is to set a special attribute for an
        compartment defined by some user rules in a PPL file, the format of
        which should be the following :

                struct GRid     EQUIP_ID  ;
                struct GRmd_env EQUIP_ENV ;


                main()
                {
                ...
                return OM_S_SUCCESS ;
                }
  Returns
        OM_S_SUCCESS    for success
        OM_E_ABORT      for failure

 -------------------------------------------------------------------------
*/



long SMSetUserAtt(ppl_name, comp_id, vol_id,comp_env)
	char 		*ppl_name ;       	/* I ppl file name  */
	struct GRid	*comp_id ;		/* I compartment id */
        struct GRid     *vol_id ;               /* I volume id      */
	struct GRmd_env	*comp_env ;		/* I compartment env*/
{
char    	status_field[GR_MAX_CHAR] ;
char    	*entry ;
struct GRid	ppl_id ;
int		rc ;
long 		status ;

#ifdef DEBUG
	printf("Begin of SMSetUserAtt() \n")    ;
#endif

/*
	Load PPL file, and check entry point
 */

ppl_id.osnum = OM_Gw_TransOSnum_0 ;						

status = ci$load(	file_name = ppl_name,
			file_id   = &ppl_id.objid,
			load      = LOAD,
			sender_id = NULL_OBJID) ;

if (!(status & 1)) {
        sprintf(status_field, "Could not load PPL file %s.e", ppl_name) ;
	#ifdef DEBUG
	printf("%s \n", status_field) ;
	#endif
        ex$message(field = 2, in_buff = status_field) ;
	status = OM_E_ABORT ; goto wrapup ;
	}

entry = "main" ;
status = om$send(	msg = message ci.is_entry_point(&rc, entry),
			senderid = NULL_OBJID,
			targetid  = ppl_id.objid,
			targetos  = ppl_id.osnum) ;
if (!(status & rc & 1)){
        sprintf(status_field, "Could not find %s()in %s.e", entry, ppl_name) ;
	#ifdef DEBUG
	printf("%s \n", status_field) ;
	#endif
        ex$message(field = 2, in_buff = status_field) ;
	status = OM_E_ABORT ; goto wrapup ;
	}

/*
	Define COMP_ID, COMP_ENV
 */

status = om$send(	msg = message ci.set_value
		(&rc, "COMP_ID", (char *) comp_id, sizeof(struct GRid)),
			senderid = NULL_OBJID,
			targetid  = ppl_id.objid,
			targetos  = ppl_id.osnum) ; 
as$status(action = GOTO, value = wrapup) ;

status = om$send(	msg = message ci.set_value
		(&rc, "VOL_ID", (char *) vol_id, sizeof(struct GRid)),
			senderid = NULL_OBJID,
			targetid  = ppl_id.objid,
			targetos  = ppl_id.osnum) ; 
as$status(action = GOTO, value = wrapup) ;

status = om$send(	msg = message ci.set_value
		(&rc, "COMP_ENV", (char *) comp_env, sizeof(struct GRmd_env)),
			senderid = NULL_OBJID,
			targetid  = ppl_id.objid,
			targetos  = ppl_id.osnum) ; 
as$status(action = GOTO, value = wrapup) ;

/*
	Run PPL file
 */

status = ci$run(	file_id   = &ppl_id.objid,
			entry     = entry,
			retsize   = sizeof(rc),
			retval    = &rc,
			sender_id = NULL_OBJID) ;
if ( !(status & rc & 1)){
        sprintf(status_field, 
		"Execution of %s() in file %s.e failed", entry, ppl_name) ;
	#ifdef DEBUG
	printf("%s \n", status_field) ;
	#endif
        ex$message(field = 2, in_buff = status_field) ;
	status = OM_E_ABORT ; goto wrapup ;
	}

status = OM_S_SUCCESS ; /* success so far */

wrapup :
if (status != OM_S_SUCCESS) {
	#ifdef DEBUG
	printf("Error => delete ci object \n")    ;
	#endif

	status = om$send(	msg = message Root.delete(0),
				senderid = NULL_OBJID,
				targetid  = ppl_id.objid,
				targetos  = ppl_id.osnum) ; as$status() ;
	status = OM_E_ABORT ; /* don't miss it */
	}

	#ifdef DEBUG
	printf("End of SMSetUserAtt() \n")    ;
	#endif

// To get rid of warning
if (SCI_fileid);

	return status ;
} /* SMSetUserAtt() */



end implementation Root ;
 

