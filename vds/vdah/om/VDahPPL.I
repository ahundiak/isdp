/* $Id: VDahPPL.I,v 1.3 2001/01/11 16:34:31 art Exp $ */
/* -------------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdah/VDahPPL.I
 *
 * Description:
 *      Functions to call PPL files and functions
 *      I added some slightly different calling stuff
 *      To help with assembly tree stuff
 *
 * Revision History:
 *	$Log: VDahPPL.I,v $
 *	Revision 1.3  2001/01/11 16:34:31  art
 *	sp merge
 *	
 *	Revision 1.1  2001/01/11 16:20:58  art
 *	s merge
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  1999/04/10  16:18:26  pinnacle
# ah
#
# Revision 1.2  1999/02/04  19:52:16  pinnacle
# spades
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/02/15  15:47:22  pinnacle
# PPL Routines
#
 *
 * History:
 * 02/13/98  ah  Creation
 * 02/04/98  ah  Fixed IsEntryDefined problem
 * 04/10/99  ah  Touched up rc initting
 * -------------------------------------------------------------------------
 */

class implementation Root ;

#include "VDtypedef.h"
#include "VDppl1.h"

#include "ciexecmacros.h"

from ci import is_entry_point;
from ci import set_value;
from ci import get_value;

/* -----------------------------------------------------------------------
 * Load a ppl file 
 *
 */
IGRstat VDahPPL_Load(
  IGRchar *pplName,   // I - PPL File Name
  TGRid   *pplID      // O - PPL objid
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  /* Load PPL file */
  pplID->osnum = OM_Gw_TransOSnum_0 ;
  pplID->objid = NULL_OBJID;
  sts = ci$load(
                file_name = pplName,
                file_id   = &pplID->objid,
                load      = LOAD,
	        sender_id = NULL_OBJID
  );
  if (!(sts & 1)) {
    pplID->objid = NULL_OBJID;
    goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Verifies function is in ppl
 */
IGRstat VDahPPL_IsEntryDefined(
  TGRid   *pplID,     // I - PPL objid (Existing)
  IGRchar *pplEntry   // I - PPL Function Name
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  rc = 0;

  // Arg Check
  if ((pplID == NULL) || (pplID->objid == NULL_OBJID)) goto wrapup;

  // Find It
  sts = om$send(
                msg = message ci.is_entry_point(&rc, pplEntry),
                senderid = NULL_OBJID,
                targetid = pplID->objid,
                targetos = pplID->osnum
  );
  if (!(sts & rc & 1)) goto wrapup;
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Runs a specific function
 * The name is just for formating error messages or traces
 */
IGRstat VDahPPL_Run(
  TGRid   *pplID,     // I - PPL objid (Existing)
  IGRchar *pplEntry,  // I - PPL Function Name
  IGRint  *pplVAL     // O - Return Value
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  /* NULL is ok, just means ppl is not loaded */
  if ((pplID == NULL) || (pplID->objid == NULL_OBJID)) {
    retFlag = 3;
    goto wrapup;
  }

  // Run It
  sts = ci$run(	
                file_id   = &pplID->objid,
                entry     =  pplEntry,
                retsize   =  sizeof(pplVAL),
                retval    =  pplVAL,
                sender_id =  NULL_OBJID
  );
  if (!(sts & 1)) {
    goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Sets PPL Global
 */
IGRstat VDahPPL_SetValue(
  TGRid   *pplID,          // I - PPL objid (Existing)
  IGRchar *pplValueName,   // I - PPL Variable Name
  IGRint   pplValueSize,   // I - PPL Variable Size
  IGRchar *pplValuePtr     // I - PPL Variable Value
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  rc = 0;

  /* NULL is ok, just means ppl is not loaded */
  if ((pplID == NULL) || (pplID->objid == NULL_OBJID)) {
    goto wrapup;
  }
  if ((pplValueName == NULL) || (pplValuePtr == NULL)) {
    goto wrapup;
  }

  // Set It
  sts = om$send( 
    msg = message ci.set_value (
      &rc, pplValueName, pplValuePtr, pplValueSize 
    ),
    senderid = pplID->objid,
    targetid = pplID->objid,
    targetos = pplID->osnum  
  );
  if (!(sts & rc & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Gets PPL Global
 * Upto calling routine to allocate and init ptr
 */
IGRstat VDahPPL_GetValue(
  TGRid   *pplID,          // I - PPL objid (Existing)
  IGRchar *pplValueName,   // I - PPL Variable Name
  IGRint   pplValueSize,   // I - PPL Variable Size
  IGRchar *pplValuePtr     // O - PPL Variable Value
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  rc = 0;

  /* NULL is ok, just means ppl is not loaded */
  if ((pplID == NULL) || (pplID->objid == NULL_OBJID)) {
    goto wrapup;
  }
  if ((pplValueName == NULL) || (pplValuePtr == NULL)) {
    goto wrapup;
  }

  // Get it
  sts = om$send( 
    msg = message ci.get_value (
      &rc, pplValueName, pplValuePtr, pplValueSize 
    ),
    senderid = pplID->objid,
    targetid = pplID->objid,
    targetos = pplID->osnum  
  );
  if (!(sts & rc & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

#if 0
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
#endif

/*------------------------------------------------------------------
 * Delete a loaded ppl object 
 */
IGRstat VDahPPL_Delete(
  TGRid *pplID   // I: Existing PPL Object
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  // Null is ok
  if ((pplID == NULL) || (pplID->objid == NULL_OBJID)) {
    retFlag = 1;
    goto wrapup;
  }

  // Delete it
  sts = ci$delete (file_id = &pplID);

  if (sts & 1) retFlag = 1;

  // Stupid static error message
  if (SCI_fileid);

wrapup:
  return retFlag;
}

end implementation Root ;
