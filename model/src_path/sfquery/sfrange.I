/*________________________________________________________________________
 |                                                                        |
 | OVERVIEW                                                               |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 | KEYWORDS                                                               |
 |                                                                        |
 | CAVEATS                                                                |
 |                                                                        |
 | HISTORY                                                                |
 |                                                                        |
 |________________________________________________________________________|
*/

class implementation Root;

#include <math.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMindex.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "godef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"

#include "EMSmsgdef.h"
#include "emsdef.h"

// Pathway includes

#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/objaccess.h"
#include "PWapi/clsid.h"
#include "PWapi/memfunc.h"

from OMrtree import find_key;
from EMSsubbs import GRgetrang;

/*
  DESCRIPTION

     Given a surface/solid, it finds the range box stored in the R-Tree
     for this surface/solid. For a solid it is the union of the of  the
     range boxes of it's indvidual components.

  NOTES

     All the memory for the output must be allocated by the caller.

  RETURN CODE

*/

PWresult pwGetSubbsRtreeRange(
PWobjid             sfid,
PWosnum             sfos,
short               mat_typ,
PWmatrix            mat,
double              *sfrange)
{
  IGRlong      msg = EMS_S_Success, sts=OM_S_SUCCESS;
  unsigned     int retval = PW_K_Success;
  IGRboolean   world=TRUE;

  GRrange old_range;
  int ret;
  OM_S_KEY_DESC select_key_search_range, select_key_rtree_range;

  PWobjid rtreeObjid = PW_K_NullObjid;
  rtreeObjid = omObjOfClass (omClassidFromName ("GRrtree", sfos), sfos);
  OnErrorState (rtreeObjid == PW_K_NullObjid, retval,
   SetError (PW_K_Pathway, PW_K_NotFound), wrapup);


   old_range[0] = -MAXDOUBLE;
   old_range[1] = -MAXDOUBLE;
   old_range[2] = -MAXDOUBLE;
   old_range[3] = MAXDOUBLE;
   old_range[4] = MAXDOUBLE;
   old_range[5] = MAXDOUBLE;

   select_key_search_range.type = KEY_3D_DBL;
   select_key_search_range.key.p_3ddbl = (DB_3D_DBL_BOX *) old_range;
   select_key_rtree_range.key.p_3ddbl =  (DB_3D_DBL_BOX *) sfrange;

   sts = om$send(msg = message OMrtree.find_key(
                            &select_key_search_range,
                            &sfid, 
                            &select_key_rtree_range,
                            0, &ret),
                 senderid = rtreeObjid,
                 targetid = rtreeObjid,
// 	         senderid = sfenv->md_id.objid,
//		 p_chanselect = &prim_chan,
		 targetos = sfos);
   OnErrorState( (!(1&sts) || ret), retval, SetError(0, PW_K_Internal), wrapup);

wrapup:
  if(!(1&retval))
  {
    msg = EMS_S_Success;
    sts = OM_S_SUCCESS;
    retval = PW_K_Success;

    sts = om$send(msg = message EMSsubbs.GRgetrang(&msg,
			&mat_typ,
			mat,
			&world, sfrange),
                  senderid = sfid,
                  targetos = sfos,
		  targetid = sfid);
    if(!(1&sts&msg)) 
        retval = SetError(0, PW_K_Internal);
  }

  return retval;
}


PWresult pwGetSubbsRtreeRangeFromGRrtree(
PWobjid             sfid,
PWosnum             sfos,
PWobjid             rtreeObjid,
short               mat_typ,
PWmatrix            mat,
double           *sfrange)
{
  IGRlong      msg = EMS_S_Success, sts=OM_S_SUCCESS;
  unsigned     int retval = PW_K_Success;
  IGRboolean   world=TRUE;

  GRrange old_range;
  int ret;
  OM_S_KEY_DESC select_key_search_range, select_key_rtree_range;

   old_range[0] = -MAXDOUBLE;
   old_range[1] = -MAXDOUBLE;
   old_range[2] = -MAXDOUBLE;
   old_range[3] = MAXDOUBLE;
   old_range[4] = MAXDOUBLE;
   old_range[5] = MAXDOUBLE;

   select_key_search_range.type = KEY_3D_DBL;
   select_key_search_range.key.p_3ddbl = (DB_3D_DBL_BOX *) old_range;
   select_key_rtree_range.key.p_3ddbl =  (DB_3D_DBL_BOX *) sfrange;

   sts = om$send(msg = message OMrtree.find_key(
                            &select_key_search_range,
                            &sfid, 
                            &select_key_rtree_range,
                            0, &ret),
                 senderid = rtreeObjid,
                 targetid = rtreeObjid,
// 	         senderid = sfenv->md_id.objid,
//		 p_chanselect = &prim_chan,
		 targetos = sfos);
   OnErrorState( (!(1&sts) || ret), retval, SetError(0, PW_K_Internal), wrapup);

wrapup:
  if(!(1&retval))
  {
    msg = EMS_S_Success;
    sts = OM_S_SUCCESS;
    retval = PW_K_Success;

    sts = om$send(msg = message EMSsubbs.GRgetrang(&msg,
			&mat_typ,
			mat,
			&world, sfrange),
                  senderid = sfid,
                  targetos = sfos,
		  targetid = sfid);
    if(!(1&sts&msg)) 
        retval = SetError(0, PW_K_Internal);
  }

  return retval;
}
 
end implementation Root;

