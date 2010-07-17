
/* $Id: VRRCgive.I,v 1.1.1.1 2001/01/04 21:13:05 cvs Exp $  */

/******************************************************************
 * Product:   	I/ROUTE
 *
 * File:        vrprdcmp/VRRCgive.I
 *
 * Description:
 *      This file contains the implemention for the override
 *      of ACgive_structure message
 *
 * Revision History:
 *	$Log: VRRCgive.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:05  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/08/04  21:07:34  pinnacle
# Replaced: vrprdcmp/VRRCgive.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/07/24  19:07:42  pinnacle
# Replaced: vrprdcmp/VRRCgive.I for:  by lawaddel for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.1  1996/03/27  20:02:12  pinnacle
# Created: vrprdcmp/VRRCgive.I by hverstee for route240
#
 *
 * History:
 *      07/24/97    law        TR179701284-correct scaled lengths
 *
 **********************************************************************/
class implementation VRRComp;

#include "vrparameters.h"
#include "VRparamdef.h"
#include "VRDbParamDef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "bstypes.h"
#include "bserr.h"
#include "VRdef.h"
#include "VDmsg.h"
#include "acrepdef.h"
#include "bslenvec.h"
#include "bsmkvec.h"

/*
#define MY_DEBUG
*/


method      ACgive_structure( int           *msg;
                              int           *direct_index; 
                              char          *footname;
                       struct ret_struct    *p_rs;
                       struct GRmd_env      *md_env)
{
  IGRint             status=OM_S_SUCCESS;
  IGRlong            retmsg;

  *msg=MSSUCC;

#ifdef MY_DEBUG
  printf ("Rway comp give struct foot %s\n", footname);
#endif

  if ( !(strcmp (footname, VR_N_FLOW_RATE_DB) ) )
  {
    p_rs->type= double_type;
    p_rs->var.root_pm_st.value= 0.0;
    return (status);
  }   

  if ( !(strcmp (footname, VR_N_PRESS_DROP_DB) ) )
  {
    p_rs->type= double_type;
    p_rs->var.root_pm_st.value= 0.0;
    return (status);
  }

  if ( !(strcmp (footname, VR_N_DUCT_LNG_DB)))
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
       if (( me->Orientation.nSecIndex != -1) || (me->nNbCpts != 2) )
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
         /* -- Different way of computing for automatic pipe or duct -- */
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
         /* TR179701284 - Correct drawing scale length */
         if ( retmsg == BSSUCC )
           p_rs->var.root_pm_st.value = (BSlenvec ( &retmsg, dVect))/dscale;
         else
           p_rs->var.root_pm_st.value= 0.0;

        } /* end linear component treatment */

      }/* end return real length */
      return (status);
  }


  /*A Try generic component feet management */
  status=
  om$send (msg = message VRComponent.ACgive_structure 
                       (msg, direct_index, footname, p_rs, md_env),
          mode = OM_e_wrt_message,
      targetid = my_id);

  /*" status = %d, msg = %d\n", status, *msg */

  return ( status );

}/* end ACgive_structure */

end implementation VRRComp;
