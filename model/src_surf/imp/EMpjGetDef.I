/* ###################   APOGEE COMPILED   ################## */
class implementation EMSproject;

#include "EMS.h"
# include "msdef.h"         /* MS message codes             */
# include "godef.h"         /* GRIS_...                     */
# include "EMSssprops.h"    /* ss_props                     */
# include "EMSssprops.h"    /* pj_props                     */
# include "EMSproject.h"    /* EMSprojectedSurfaceHeader    */

# define V_ORDER 2
# define V_NUM_POLES 2
# define V_NUM_KNOTS 4

method EMgetbsdef(IGRlong *EMmsg; struct IGRbsp_surface *surface)
/*
Abstract

    This method generates the control information for the surface
    of projection.

Arguments

    surface - output
        Surface control information.

Return Status

    EMS_S_Success       - Success
    EMS_E_InvalidCase   - Surface object has bad format value.

History

    10 Mar 88   AIC     Creation Date
    19 Aug 92   NP	Modified for ANSI compliance. Missing typecast for
			"instance_data" variable.
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

    case EMSprojectedFormat:
      {
        struct EMSprojectedSurfaceHeader     *instance_data;

        *EMmsg = EMS_S_Success;
        instance_data = (struct EMSprojectedSurfaceHeader *)
					(me^^EMSsubbs.packed_data);

        surface->u_order = (IGRshort) instance_data->order;
        surface->v_order = V_ORDER;
        surface->u_periodic = (IGRboolean) instance_data->pj_props &
                              EMSIS_PJ_PERIODIC ? TRUE : FALSE;
        surface->v_periodic = FALSE;
        surface->u_non_uniform = (IGRboolean) instance_data->pj_props &
                                 EMSIS_PJ_NONUNIFORM ? TRUE : FALSE;
        surface->v_non_uniform = FALSE;
        surface->u_num_poles = (IGRlong) instance_data->num_poles;
        surface->v_num_poles = V_NUM_POLES;
        surface->poles = NULL;
        surface->u_num_knots = (IGRlong) instance_data->num_poles +
                               (IGRlong) instance_data->order;
        surface->u_knots = NULL;
        surface->v_num_knots = V_NUM_KNOTS;
        surface->v_knots = NULL;
        surface->rational = (IGRboolean) instance_data->pj_props &
                             EMSIS_PJ_RATIONAL ? TRUE : FALSE;
        surface->weights = NULL;
        surface->planar = (IGRboolean) me^^GRgraphics.properties &
                          GRIS_PLANAR ? TRUE : FALSE;
        surface->u_phy_closed = (IGRboolean) instance_data->pj_props &
                                EMSIS_PJ_PHYCLOSED ? TRUE : FALSE;
        surface->v_phy_closed = FALSE;
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
  return(OM_S_SUCCESS);
}

end implementation EMSproject;
