/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

#include <stdio.h>
#include "msdef.h" /* MS message codes */
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "OMerrordef.h" /* OM message codes */
#include "exdef.h"      /* RESET        */
#include "OMlimits.h"   /* for ex.h     */
#include "ex.h"         /* for grio.h   */
#include "griodef.h"    /* for grio.h   */
#include "grio.h"       /* for lc.h     */
#include "lcdef.h"      /* for lc.h     */
#include "lc.h"         /* GRlc_stack   */
#include "msmacros.h"
#include "madef.h"
#include "emsmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include "EMSerrnumdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "OMindex.h"
#include "bserr.h"
#include "gocmacros.h"

from OMrtree import find_key;

IGRint EMshowrng(targetid)
                 GRobjid targetid;
{
  IGRlong EMmsg, OM_stat;
  GRobjid mod_id;
  int ret;
  GRrange search_range, rtree_range;
  OM_S_CHANSELECT prim_chan;
  OM_S_KEY_DESC select_key_search_range, select_key_rtree_range;
  OMuword mod_osnum;


  OM_stat = OM_S_SUCCESS;
  EMmsg = EMS_S_Success;

  search_range[0] = -MAXDOUBLE;
  search_range[1] = -MAXDOUBLE; 
  search_range[2] = -MAXDOUBLE;

  search_range[3] = MAXDOUBLE;
  search_range[4] = MAXDOUBLE; 
  search_range[5] = MAXDOUBLE;
 
  OM_stat = ex$get_cur_mod(id = &mod_id, osnum = &mod_osnum);
  if(!(1 & OM_stat)) goto wrapup;

  OM_stat = EMmake_chanselect (module_primary, &prim_chan);
  if(!(1&OM_stat)) goto wrapup;
 
  select_key_search_range.type = KEY_3D_DBL;
  select_key_search_range.key.p_3ddbl = (DB_3D_DBL_BOX *)search_range;

  select_key_rtree_range.type = KEY_3D_DBL;
  select_key_rtree_range.key.p_3ddbl = (DB_3D_DBL_BOX *)rtree_range;
 
  OM_stat = om$send(msg = message OMrtree.find_key(
                          &select_key_search_range,
                          &targetid, 
                          &select_key_rtree_range,
                          0, &ret),
                    senderid = mod_id,
                    targetos = mod_osnum,
                    p_chanselect = &prim_chan);
  if(!(1 & OM_stat) || ret) {EMmsg = EMS_E_Fail; goto wrapup;}

  EFdraw_range_box(rtree_range);
  fprintf (stderr, "******* Rtree_range  info ********\n");
  fprintf (stderr, "Objid = %d , Osnum = %d\n", targetid, mod_osnum);
  fprintf (stderr, "Range_Min = %lf, %lf, %lf \n", rtree_range[0],
                   rtree_range[1], rtree_range[2]);
  fprintf (stderr, "Range_Max = %lf, %lf, %lf \n", rtree_range[3],
                   rtree_range[4], rtree_range[5]);

  wrapup:
    EMWRAPUP (EMmsg, OM_stat, "In EMtestrng");
    return (OM_stat);
}
end implementation Root;
