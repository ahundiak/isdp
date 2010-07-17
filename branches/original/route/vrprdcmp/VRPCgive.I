
/* $Id: VRPCgive.I,v 1.2 2001/02/27 19:38:51 ad Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        route/vrprdcmp/VRPCgive.I
 *
 * Description:
 *
 * Override implementation of ACgive_structure for pipe length
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRPCgive.I,v $
 *      Revision 1.2  2001/02/27 19:38:51  ad
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:13:05  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/08/04  21:08:56  pinnacle
# Replaced: vrprdcmp/VRPCgive.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.5  1997/07/24  19:08:38  pinnacle
# Replaced: vrprdcmp/VRPCgive.I for:  by lawaddel for route
#
# Revision 1.4  1997/02/07  06:46:24  pinnacle
# Replaced: vrprdcmp/VRPCgive.I for:  by apazhani for route
#
# Revision 1.3  1996/11/08  11:38:38  pinnacle
# Replaced: vrprdcmp/VRPCgive.I for:  by apazhani for route
#
# Revision 1.2  1996/11/06  05:04:02  pinnacle
# Replaced: vrprdcmp/VRPCgive.I for:  by apazhani for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/05/15  20:06:52  pinnacle
# Replaced: vrprdcmp/VRPCgive.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/17  19:30:34  pinnacle
# Replaced: vrprdcmp/VRPCgive.I for:  by r240_int for route240
#
# Revision 1.1  1995/09/20  22:31:06  pinnacle
# Created: vrprdcmp/VRPCgive.I by hverstee for route240
#
 *
 * History:
 *      09/20/95    HV         split off from VRComponent/VRCompOver.I
 *	01/17/96    tlb		Add prototypes
 *      07/24/97    law        TR179701284-correct scaled lengths
 *
 * -------------------------------------------------------------------*/

class implementation VRPComp;

#include <math.h>
#include "ndmacros.h"
#include "vrparameters.h"
#include "VRparamdef.h"
#include "VRDbParamDef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "bstypes.h"
#include "bserr.h"
#include "VRdef.h"
#include "VRsize.h"
#include "acrepdef.h"
#include "vrdbgmacros.h"

#include "VRPid.h"
#include "bslenvec.h"
#include "bsmkvec.h"
#include "bsvalues.h"


#define AS_DEBUG        1
#define VR_CMP_TYP_PIPE_BEND  12

/***********************************************************************/

method ACgive_structure(int        *msg;
                        int        *direct_index;
                        char       *footname;
                 struct ret_struct *p_rs;
                 struct GRmd_env   *md_env)

{
  IGRint             status=OM_S_SUCCESS;
  IGRlong            retmsg;
  struct ret_struct  bend_ang, comp_type;
  struct GRid 	     ModelId;

  SetProc( VRPComp_ACgive_structure ); Begin

  __DBGpr_str(" footname ", footname );

  *msg=MSSUCC;

  if ( !(strcmp (footname, VR_N_PIPE_LNG_DB)))
  {
     /* Only linear components can compute their length */

     p_rs->type= double_type;

     if ( me->Status&VR_EVALUATE )
     { /*| No Topologic templates -> Return 10 inches */
       p_rs->var.root_pm_st.value = 10.0;
     } /* end return dummy length */
     else
     {
       /* KLUDGE : will not work when we'll place components on a CS */
       if ( me->nNbCpts != 2 )
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
         /* -- Different way of computing for automatic pipe -- */
         if ( (me->Desc.nItemNum == VR_PIPE ) && (me->Status&VR_CORRECTION) )
         {
           /* -- Length depending on neighbors -- */
           /*| DYNAMIC length component */
           status=
           om$send ( msg = message VRComponent.VRGetPipeExtensions
                                    (&retmsg, dCpts, md_env),
                targetid = my_id);
           as$status ( action = RET_STATUS );

         } /* end dynamic length */
         else
         {
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

         } /* end static length treatment */

         BSmkvec( &retmsg, dVect, dCpts, &dCpts[3] );
         if ( retmsg == BSSUCC )
	 {
           /* Get's the Chord length corrected for scale-TR179701284 */
           p_rs->var.root_pm_st.value = (BSlenvec ( &retmsg, dVect) / dscale);	
           /* Get's the Bend_sweep angle */
           status =
               om$send (msg = message VRComponent.ACgive_structure
                              ( (IGRint *) &retmsg, direct_index,
                              VR_N_BEND_ANG_DB, &bend_ang, md_env ),
                       targetid = my_id );
           as$status ( action = RET_STATUS );
 
           if ( bend_ang.var.root_pm_st.value > BSSMALLRELTO1 )
           {
	      ModelId.objid = NULL_OBJID ;
              status = om$send ( msg = message VRGeneric.VRGetModel
                                     ( &retmsg, &ModelId, md_env ),
                                       targetid = my_id );
 
              status =
                   om$send (msg = message VRComponent.ACgive_structure
                           ( (IGRint *) &retmsg, direct_index,
                             VR_N_COMP_TYPE_IN, &comp_type, md_env ),
                             senderid = NULL_OBJID,
                             targetid = ModelId.objid,
                             targetos = ModelId.osnum );
              as$status ( action = RET_STATUS );

              if( comp_type.var.root_pm_st.value == VR_CMP_TYP_PIPE_BEND )
              {

                 p_rs->var.root_pm_st.value *= ( bend_ang.var.root_pm_st.value*VR_PI_RAD) / ( sin(VR_PI_RAD*bend_ang.var.root_pm_st.value/360.0) * 360.0 );

              }
              else
                  p_rs->var.root_pm_st.value= 0.0;
           }
           else if ( !( (me->Desc.nItemNum == VR_PIPE ) && (me->Status&VR_CORRECTION) ) )
               p_rs->var.root_pm_st.value= 0.0;

	 }
         else
           p_rs->var.root_pm_st.value= 0.0;

        } /* end linear component treatment */

      }/* end return real length */
  }
  else
  {

    __DBGpr_com("A Try generic feet management ");
    status=
    om$send (msg = message VRComponent.ACgive_structure 
                             (msg, direct_index, footname, p_rs, md_env),
            mode = OM_e_wrt_message,
        targetid = my_id);

  }/* end try OM_e_wrt_message */

  End ;

  return ( status );

}/* end ACgive_structure */

end implementation VRPComp;
