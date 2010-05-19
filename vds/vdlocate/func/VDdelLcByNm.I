/* $Id: VDdelLcByNm.I,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdlocate/func/VDdelLcByNm.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdelLcByNm.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/05/12  14:15:34  pinnacle
# TR179802375
#
 * History:
 * MM/DD/YY   AUTHOR    DESCRIPTION
 * 05/11/99   ylong     created for TR179802375
* -------------------------------------------------------------------------*/

class implementation Root;

#include "coimport.h"
#include "OMerrordef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "ODE.h"
#include "ex.h"
#include "grmessage.h"
#include "exmacros.h"
#include "griomacros.h"
#include "DImacros.h"
#include "FI.h"
#include <stdio.h>
#include "msmacros.h"
#include "VDCmdDirFrm.h"
#include "VDmsg.h"


extern	GRclassid	OPP_VDCmdLcNm_class_id;
from	VDCmdLcNm	import	form_notification;


void VDdelete_LocateByName()
{

    int         i, sts;
    OM_S_OBJID	objid = NULL_OBJID;
    GRclassid 	class;
    extern OM_p_OSD *OM_GA_OSDs;

    /* delete the reference expression. */
    sts = di$translate ( osnum   = OM_Gw_TransOSnum_0,
                         p_objid = &objid,
                         path    = "IGENOD",
                         objname = "VDSpath_text_id" );

    if (sts == DIR_S_SUCCESS)
    {
      om$send ( msg      = message Root.delete ( 1 ),
                targetid = objid,
                targetos = OM_Gw_TransOSnum_0, 
                senderid = NULL_OBJID );
    }

    /* 
     * Delete the command. This needs to be resolved by finding the
     * component inside the transient object space. (TransOSnum ) 
     */

    for(i=0 ; i< OM_GA_OSDs[OM_Gw_TransOSnum_0]->CurSpaceMapSize; i++){
      if( om$get_classid(
			objid = i,
			osnum = OM_Gw_TransOSnum_0,
                	p_classid = &class) != OM_S_SUCCESS)
              continue;

      if( om$is_ancestry_valid(superclassid = OPP_VDCmdLcNm_class_id,
                           	 subclassid = class) == OM_S_SUCCESS ){

		/*
	         * Delete the form.
		 */
	/* printf(" Object : %d\n", i ); */
      	om$send (msg      = message VDCmdLcNm.form_notification(
						0, 1000, 0.0, NULL ),
	 	 targetid = i,
        	 targetos = OM_Gw_TransOSnum_0,
		 senderid = NULL_OBJID );

      	om$send (msg      = message Root.delete ( 1 ),
	 	 targetid = i,
        	 targetos = OM_Gw_TransOSnum_0,
		 senderid = NULL_OBJID );
	break; 
      }
  } /* for ... */
}
end implementation Root;

