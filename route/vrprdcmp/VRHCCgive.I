
/* $Id: VRHCCgive.I,v 1.3 2001/02/20 01:16:38 build Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        route/vrprdcmp/VRHCCgive.I
 *
 * Description:
 *
 * Override implementation of ACgive_structure for duct length
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRHCCgive.I,v $
 *      Revision 1.3  2001/02/20 01:16:38  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 17:51:43  anand
 *      SP merge
 *
# Revision 1.1  2000/05/24  00:01:30  pinnacle
# Created: route/vrprdcmp/VRHCCgive.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/08/04  21:08:18  pinnacle
# Replaced: vrprdcmp/VRHCCgive.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/07/24  19:08:12  pinnacle
# Replaced: vrprdcmp/VRHCCgive.I for:  by lawaddel for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/17  19:29:48  pinnacle
# Replaced: vrprdcmp/VRHCCgive.I for:  by r240_int for route240
#
# Revision 1.1  1995/09/20  22:30:12  pinnacle
# Created: vrprdcmp/VRHCCgive.I by hverstee for route240
#
 *
 * History:
 *      09/20/95    HV         	split off from VRConcComp/VRCCompOver.I
 *	01/17/96    tlb		Add prototypes
 *      07/24/97    law        TR179701284-correct scaled lengths
 *
 * -------------------------------------------------------------------*/

class implementation VRHCComp;

#include "vrparameters.h"
#include "VRparamdef.h"
#include "VRDbParamDef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "VRdef.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "VDScheckdef.h"
#include "ACcheckin.h"
#include "ACdb_info.h"
#include "acrepdef.h"
#include "VRPid.h"
#include "bslenvec.h"
#include        "vrdbgmacros.h"

#define AS_DEBUG  1

/***********************************************************************/


method ACgive_structure(int        *msg;
                        int        *direct_index;
                        char       *footname;
                 struct ret_struct *p_rs;
                 struct GRmd_env   *md_env)

{
  IGRint       status=OM_S_SUCCESS;
  IGRlong      retmsg;
  IGRint       BSmkvec();
  IGRdouble    BSlenvec();

  SetProc( VRHCComp_ACgive_structure ); Begin
  *msg=MSSUCC;

  if ( !(strcmp (footname, VR_N_DUCT_LNG_DB)))
  {
    /* Only linear components can compute their length */

    p_rs->type= double_type;

    if ( me->Status&VR_EVALUATE )
    {
      /*| No Topologic templates -> Return 10 inches */

      p_rs->var.root_pm_st.value = 10.0;

    }/* end return dummy length */
    else
    {

      /* KLUDGE : will not work when we'll place components on a CS */
      if (me->nNbCpts != 2)
      {
        /*| ERROR -> Cannot compute length */
        p_rs->var.root_pm_st.value= 0.0;

      } /* end non linear components */
      else
      {
        IGRdouble  dCpts[6]; /* stores the two Cpts */
        IGRdouble  dVect[3]; /* temporary vector */
        IGRdouble  dscale, dX[3], dY[3], dZ[3];
         /* TR179701284 - Correct drawing scale length */
         dX [0]  = md_env->md_env.matrix [0];
         dX [1]  = md_env->md_env.matrix [4];
         dX [2]  = md_env->md_env.matrix [8];
         dY [0]  = md_env->md_env.matrix [1];
         dY [1]  = md_env->md_env.matrix [5];
         dY [2]  = md_env->md_env.matrix [9];
         dZ [0]  = md_env->md_env.matrix [2];
         dZ [1]  = md_env->md_env.matrix [6];
         dZ [2]  = md_env->md_env.matrix [10];
          dscale = (BSlenvec ( &retmsg, dX) +
                    BSlenvec ( &retmsg, dY) +
                    BSlenvec ( &retmsg, dZ)) / 3.0;
        /*| Computing length */
        /* -- Different way of computing for automatic duct -- */

        /* -- Real component length -- */
        /*| STATIC length component */

        status=
        om$send ( msg = message VRGeneric.VRGetCptGeom
                                           (&retmsg, (IGRshort) 0, dCpts,
                                                      NULL, NULL, md_env),
             targetid = my_id );
        as$status ( action = RET_STATUS );

        status=
        om$send ( msg = message VRGeneric.VRGetCptGeom
                                           (&retmsg, (IGRshort) 1, &dCpts[3],
                                                       NULL, NULL, md_env),
             targetid = my_id );
        as$status ( action = RET_STATUS );

        BSmkvec( &retmsg, dVect, dCpts, &dCpts[3] );
         /* TR179701284 - Correct drawing scale length */
        if ( retmsg == BSSUCC )
          p_rs->var.root_pm_st.value = (BSlenvec ( &retmsg, dVect)) / dscale;
        else
          p_rs->var.root_pm_st.value= 0.0;

      } /* end linear component treatment */

    }/* end return real length */
  }
  else
  {
    /*A Try generic feet management */
    status=
    om$send (msg = message VRConcComp.ACgive_structure 
                              (msg, direct_index, footname, p_rs, md_env),
            mode = OM_e_wrt_message,
        targetid = my_id);

  }/* end try OM_e_wrt_message */

  End
  return ( status );

}/* end ACgive_structure */

end implementation VRHCComp;
