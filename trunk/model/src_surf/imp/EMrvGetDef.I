/* ###################   APOGEE COMPILED   ################## */
class implementation EMSrevol;

#include "EMS.h"
# include "msdef.h"         /* MS message codes             */
# include "godef.h"         /* GRIS_...                     */
# include "bsconic.h"       /* BSCIRCLE...                  */
# include "EMSssprops.h"    /* ss_props                     */
# include "EMSssprops.h"    /* rv_props                     */
# include "EMSrevol.h"      /* EMSrevolvedSurfaceHeader     */

# define V_ORDER        BSCIRCLE_ORDER
# define V_NUM_POLES    BSCIRCLE_NUM_POLES_MAX
# define V_NUM_KNOTS    BSCIRCLE_NUM_KNOTS_MAX

method EMgetbsdef(IGRlong *EMmsg; struct IGRbsp_surface *surface)
/*
Abstract

    This method generates the control information for the surface
    of revolion.

Arguments

    surface - output
        Surface control information.

Return Status

    EMS_S_Success       - Success
    EMS_E_InvalidCase   - Surface object has bad format value.

History

    06 May 88   AIC     Creation Date
    21 Aug 92   NP      Modified for ANSI compliance.
    04 Oct 94   Sanjay  If the instance data is pointing to NULL, return 
                        EMS_E_InvalidArg.
*/
{
  IGRlong   sts = OM_S_SUCCESS;

  /*
   * Initialize
   */
  *EMmsg = EMS_S_Success;

  switch(me^^EMSsubbs.ss_props & EMSformat)
  {
    case EMSbsplineFormat:
      sts = om$send(msg = message EMSsubbs.EMgetbsdef(EMmsg, surface),
                    mode = OM_e_wrt_message, targetid = my_id);
      break;

    case EMSrevolvedFormat:
      {
        struct EMSrevolvedSurfaceHeader     *instance_data;

        *EMmsg = EMS_S_Success;
        instance_data = (struct EMSrevolvedSurfaceHeader *)
                                             me^^EMSsubbs.packed_data;
        if(!instance_data)
        {
           memset( surface, 0, sizeof(struct IGRbsp_surface) );
           sts = OM_E_ABORT;
           *EMmsg = EMS_E_InvalidArg;
           goto wrapup;
        }

        surface->u_order = (IGRshort) instance_data->order;
        surface->v_order = V_ORDER;
        surface->u_periodic = (IGRboolean) instance_data->rv_props &
                              EMSIS_RV_PERIODIC ? TRUE : FALSE;
        surface->v_periodic = FALSE;
        surface->u_non_uniform = (IGRboolean) instance_data->rv_props &
                                 EMSIS_RV_NONUNIFORM ? TRUE : FALSE;
        surface->v_non_uniform = FALSE;
        surface->u_num_poles = (IGRlong) instance_data->num_poles;
        surface->v_num_poles = V_NUM_POLES;
        surface->poles = NULL;
        surface->u_num_knots = (IGRlong) instance_data->num_poles +
                               (IGRlong) instance_data->order;
        surface->u_knots = NULL;
        surface->v_num_knots = V_NUM_KNOTS;
        surface->v_knots = NULL;
        surface->rational = TRUE;
        surface->weights = NULL;
        surface->planar = (IGRboolean) me^^GRgraphics.properties &
                          GRIS_PLANAR ? TRUE : FALSE;
        surface->u_phy_closed = (IGRboolean) instance_data->rv_props &
                                EMSIS_RV_PHYCLOSED ? TRUE : FALSE;
        surface->v_phy_closed = (IGRboolean) instance_data->rv_props &
                                EMSIS_RV_360 ? TRUE : FALSE;
        surface->pos_orient = (IGRboolean) me^^EMSsubbs.ss_props &
                              EMSIS_NRML_REVERSED ? FALSE : TRUE;
        surface->on_off = (IGRboolean) FALSE;
        surface->num_boundaries = 0;
        surface->bdrys = NULL;
      }
      break;

    default:
      *EMmsg = EMS_E_InvalidCase;
  }

wrapup:
  return(sts);
}

end implementation EMSrevol;
