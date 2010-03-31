/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
# include "msdef.h"         /* MS message codes         */
# include "godef.h"         /* GRIS_...                 */
# include "EMSssprops.h"    /* EMSIS_NRML_REVERSED      */
# include "EMSsubbs.h"      /* EMSbsplineSurfaceHeader  */

method EMgetbsdef(IGRlong *EMmsg; struct IGRbsp_surface *surface)
/*
History

    29 October 87   AIC     Creation Date
    25 August  92   NP      Modified for ANSI compliance. Typecasts added.
    04 October 94   Sanjay  If the instance data is pointing to NULL, return
                            EMS_E_InvalidArg.

*/
{
  IGRlong                            status = OM_S_SUCCESS;
  struct EMSbsplineSurfaceHeader     *instance_data;

  *EMmsg = MSSUCC;
  instance_data = (struct EMSbsplineSurfaceHeader *) me^^EMSsubbs.packed_data;
  if( !instance_data ) 
  {
     memset( surface, 0, sizeof(struct IGRbsp_surface) );
     status = OM_E_ABORT;
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
  }
  surface->u_order = (IGRshort) instance_data->u_order;
  surface->v_order = (IGRshort) instance_data->v_order;
  surface->u_periodic = (IGRboolean) instance_data->bs_props &
                        EMSIS_U_PERIODIC ? TRUE : FALSE;
  surface->v_periodic = (IGRboolean) instance_data->bs_props &
                        EMSIS_V_PERIODIC ? TRUE : FALSE;
  surface->u_non_uniform = (IGRboolean) instance_data->bs_props &
                        EMSIS_U_NONUNIFORM ? TRUE : FALSE;
  surface->v_non_uniform = (IGRboolean) instance_data->bs_props &
                        EMSIS_V_NONUNIFORM ? TRUE : FALSE;
  surface->u_num_poles = (IGRlong) instance_data->u_num_poles;
  surface->v_num_poles = (IGRlong) instance_data->v_num_poles;
  surface->poles = NULL;
  surface->u_num_knots = (IGRlong) instance_data->u_num_poles +
                         (IGRlong) instance_data->u_order;
  surface->u_knots = NULL;
  surface->v_num_knots = (IGRlong) instance_data->v_num_poles +
                         (IGRlong) instance_data->v_order;
  surface->v_knots = NULL;
  surface->rational = (IGRboolean) instance_data->bs_props &
                       EMSIS_RATIONAL ? TRUE : FALSE;
  surface->weights = NULL;
  surface->planar = (IGRboolean) me^^GRgraphics.properties &
                    GRIS_PLANAR ? TRUE : FALSE;
  surface->u_phy_closed = (IGRboolean) instance_data->bs_props &
                           EMSIS_U_PHYCLOSED ? TRUE : FALSE;
  surface->v_phy_closed = (IGRboolean) instance_data->bs_props &
                           EMSIS_V_PHYCLOSED ? TRUE : FALSE;
  surface->pos_orient = (IGRboolean) me^^EMSsubbs.ss_props &
                        EMSIS_NRML_REVERSED ? FALSE : TRUE;
  surface->on_off = (IGRboolean) FALSE;
  surface->num_boundaries = 0;
  surface->bdrys = NULL;

wrapup:
  return(status);
}

end implementation EMSsubbs;
